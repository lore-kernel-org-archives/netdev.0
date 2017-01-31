From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH RFC net-next 2/4] bridge: move to workqueue gc
Date: Tue, 31 Jan 2017 16:31:56 +0100
Message-ID: <1485876718-18091-3-git-send-email-nikolay@cumulusnetworks.com>
References: <1485876718-18091-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
        davem@davemloft.net,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:35509 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750849AbdAaPcY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 10:32:24 -0500
Received: by mail-wm0-f46.google.com with SMTP id b65so84084663wmf.0
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 07:32:23 -0800 (PST)
In-Reply-To: <1485876718-18091-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the fdb garbage collector to a workqueue which fires at least 10
milliseconds apart and cleans chain by chain allowing for other tasks
to run in the meantime. When having thousands of fdbs the system is much
more responsive. Most importantly remove the need to check if the
matched entry has expired in __br_fdb_get that causes false-sharing and
is completely unnecessary if we cleanup entries, at worst we'll get ~10ms
of traffic for that entry before it gets deleted.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_device.c    |  1 +
 net/bridge/br_fdb.c       | 31 +++++++++++++++++++------------
 net/bridge/br_if.c        |  2 +-
 net/bridge/br_ioctl.c     |  2 +-
 net/bridge/br_netlink.c   |  2 +-
 net/bridge/br_private.h   |  4 ++--
 net/bridge/br_stp.c       |  2 +-
 net/bridge/br_stp_if.c    |  4 ++--
 net/bridge/br_stp_timer.c |  2 --
 net/bridge/br_sysfs_br.c  |  2 +-
 10 files changed, 29 insertions(+), 23 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 6c46d1b4cdbb..89b414fd1901 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -413,4 +413,5 @@ void br_dev_setup(struct net_device *dev)
 	br_netfilter_rtable_init(br);
 	br_stp_timer_init(br);
 	br_multicast_init(br);
+	INIT_DELAYED_WORK(&br->gc_work, br_fdb_cleanup);
 }
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index e4a4176171c9..5cbed5c0db88 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -154,7 +154,7 @@ static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
 	if (f->added_by_external_learn)
 		fdb_del_external_learn(f);
 
-	hlist_del_rcu(&f->hlist);
+	hlist_del_init_rcu(&f->hlist);
 	fdb_notify(br, f, RTM_DELNEIGH);
 	call_rcu(&f->rcu, fdb_rcu_free);
 }
@@ -290,34 +290,43 @@ void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
 	spin_unlock_bh(&br->hash_lock);
 }
 
-void br_fdb_cleanup(unsigned long _data)
+void br_fdb_cleanup(struct work_struct *work)
 {
-	struct net_bridge *br = (struct net_bridge *)_data;
+	struct net_bridge *br = container_of(work, struct net_bridge,
+					     gc_work.work);
 	unsigned long delay = hold_time(br);
-	unsigned long next_timer = jiffies + br->ageing_time;
+	unsigned long work_delay = delay;
+	unsigned long now = jiffies;
 	int i;
 
-	spin_lock(&br->hash_lock);
 	for (i = 0; i < BR_HASH_SIZE; i++) {
 		struct net_bridge_fdb_entry *f;
 		struct hlist_node *n;
 
+		if (!br->hash[i].first)
+			continue;
+
+		spin_lock_bh(&br->hash_lock);
 		hlist_for_each_entry_safe(f, n, &br->hash[i], hlist) {
 			unsigned long this_timer;
+
 			if (f->is_static)
 				continue;
 			if (f->added_by_external_learn)
 				continue;
 			this_timer = f->updated + delay;
-			if (time_before_eq(this_timer, jiffies))
+			if (time_after(this_timer, now))
+				work_delay = min(work_delay, this_timer - now);
+			else
 				fdb_delete(br, f);
-			else if (time_before(this_timer, next_timer))
-				next_timer = this_timer;
 		}
+		spin_unlock_bh(&br->hash_lock);
+		cond_resched();
 	}
-	spin_unlock(&br->hash_lock);
 
-	mod_timer(&br->gc_timer, round_jiffies_up(next_timer));
+	/* Cleanup minimum 10 milliseconds apart */
+	work_delay = max_t(unsigned long, work_delay, msecs_to_jiffies(10));
+	mod_delayed_work(system_long_wq, &br->gc_work, work_delay);
 }
 
 /* Completely flush all dynamic entries in forwarding database.*/
@@ -382,8 +391,6 @@ struct net_bridge_fdb_entry *__br_fdb_get(struct net_bridge *br,
 				&br->hash[br_mac_hash(addr, vid)], hlist) {
 		if (ether_addr_equal(fdb->addr.addr, addr) &&
 		    fdb->vlan_id == vid) {
-			if (unlikely(has_expired(br, fdb)))
-				break;
 			return fdb;
 		}
 	}
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index ed0dd3340084..8ac1770aa222 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -313,7 +313,7 @@ void br_dev_delete(struct net_device *dev, struct list_head *head)
 
 	br_vlan_flush(br);
 	br_multicast_dev_del(br);
-	del_timer_sync(&br->gc_timer);
+	cancel_delayed_work_sync(&br->gc_work);
 
 	br_sysfs_delbr(br->dev);
 	unregister_netdevice_queue(br->dev, head);
diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
index da8157c57eb1..7970f8540cbb 100644
--- a/net/bridge/br_ioctl.c
+++ b/net/bridge/br_ioctl.c
@@ -149,7 +149,7 @@ static int old_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 		b.hello_timer_value = br_timer_value(&br->hello_timer);
 		b.tcn_timer_value = br_timer_value(&br->tcn_timer);
 		b.topology_change_timer_value = br_timer_value(&br->topology_change_timer);
-		b.gc_timer_value = br_timer_value(&br->gc_timer);
+		b.gc_timer_value = br_timer_value(&br->gc_work.timer);
 		rcu_read_unlock();
 
 		if (copy_to_user((void __user *)args[1], &b, sizeof(b)))
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 1ca25498fe4d..d63ad8337dcd 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -1200,7 +1200,7 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	if (nla_put_u64_64bit(skb, IFLA_BR_TOPOLOGY_CHANGE_TIMER, clockval,
 			      IFLA_BR_PAD))
 		return -EMSGSIZE;
-	clockval = br_timer_value(&br->gc_timer);
+	clockval = br_timer_value(&br->gc_work.timer);
 	if (nla_put_u64_64bit(skb, IFLA_BR_GC_TIMER, clockval, IFLA_BR_PAD))
 		return -EMSGSIZE;
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index d3be859a6346..9658c6484935 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -369,7 +369,7 @@ struct net_bridge {
 	struct timer_list		hello_timer;
 	struct timer_list		tcn_timer;
 	struct timer_list		topology_change_timer;
-	struct timer_list		gc_timer;
+	struct delayed_work		gc_work;
 	struct kobject			*ifobj;
 	u32				auto_cnt;
 
@@ -492,7 +492,7 @@ void br_fdb_find_delete_local(struct net_bridge *br,
 			      const unsigned char *addr, u16 vid);
 void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr);
 void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr);
-void br_fdb_cleanup(unsigned long arg);
+void br_fdb_cleanup(struct work_struct *work);
 void br_fdb_delete_by_port(struct net_bridge *br,
 			   const struct net_bridge_port *p, u16 vid, int do_all);
 struct net_bridge_fdb_entry *__br_fdb_get(struct net_bridge *br,
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 71fd1a4e63cc..8f56c2d1f1a7 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -602,7 +602,7 @@ int br_set_ageing_time(struct net_bridge *br, clock_t ageing_time)
 	br->ageing_time = t;
 	spin_unlock_bh(&br->lock);
 
-	mod_timer(&br->gc_timer, jiffies);
+	mod_delayed_work(system_long_wq, &br->gc_work, 0);
 
 	return 0;
 }
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 6c1e21411125..08341d2aa9c9 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -57,7 +57,7 @@ void br_stp_enable_bridge(struct net_bridge *br)
 	spin_lock_bh(&br->lock);
 	if (br->stp_enabled == BR_KERNEL_STP)
 		mod_timer(&br->hello_timer, jiffies + br->hello_time);
-	mod_timer(&br->gc_timer, jiffies + HZ/10);
+	mod_delayed_work(system_long_wq, &br->gc_work, HZ / 10);
 
 	br_config_bpdu_generation(br);
 
@@ -88,7 +88,7 @@ void br_stp_disable_bridge(struct net_bridge *br)
 	del_timer_sync(&br->hello_timer);
 	del_timer_sync(&br->topology_change_timer);
 	del_timer_sync(&br->tcn_timer);
-	del_timer_sync(&br->gc_timer);
+	cancel_delayed_work_sync(&br->gc_work);
 }
 
 /* called under bridge lock */
diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
index 7ddb38e0a06e..c98b3e5c140a 100644
--- a/net/bridge/br_stp_timer.c
+++ b/net/bridge/br_stp_timer.c
@@ -153,8 +153,6 @@ void br_stp_timer_init(struct net_bridge *br)
 	setup_timer(&br->topology_change_timer,
 		      br_topology_change_timer_expired,
 		      (unsigned long) br);
-
-	setup_timer(&br->gc_timer, br_fdb_cleanup, (unsigned long) br);
 }
 
 void br_stp_port_timer_init(struct net_bridge_port *p)
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index a18148213b08..0f4034934d56 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -263,7 +263,7 @@ static ssize_t gc_timer_show(struct device *d, struct device_attribute *attr,
 			     char *buf)
 {
 	struct net_bridge *br = to_bridge(d);
-	return sprintf(buf, "%ld\n", br_timer_value(&br->gc_timer));
+	return sprintf(buf, "%ld\n", br_timer_value(&br->gc_work.timer));
 }
 static DEVICE_ATTR_RO(gc_timer);
 
-- 
2.1.4
