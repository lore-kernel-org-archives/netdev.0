From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next] bridge: implement multicast fast leave
Date: Mon,  3 Dec 2012 22:36:03 +0800
Message-ID: <1354545363-11953-1-git-send-email-amwang@redhat.com>
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	bridge@lists.linux-foundation.org, "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Fast leave allows bridge to immediately stops the multicast
traffic on the port receives IGMP Leave when IGMP snooping is enabled,
no timeouts are observed.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index d53e4f4..05e0572 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1226,6 +1226,40 @@ static void br_multicast_leave_group(struct net_bridge *br,
 	if (!mp)
 		goto out;
 
+	if (br->multicast_fast_leave) {
+		struct net_bridge_port_group __rcu **pp;
+
+		if (!port) {
+			mp->mglist = false;
+
+			if (mp->ports)
+				goto out;
+
+			hlist_del_rcu(&mp->hlist[mdb->ver]);
+			mdb->size--;
+			del_timer(&mp->timer);
+			call_rcu_bh(&mp->rcu, br_multicast_free_group);
+			goto out;
+		}
+
+		for (pp = &mp->ports;
+		     (p = mlock_dereference(*pp, br)) != NULL;
+		     pp = &p->next) {
+			if (p->port != port)
+				continue;
+
+			rcu_assign_pointer(*pp, p->next);
+			hlist_del_init(&p->mglist);
+			del_timer(&p->timer);
+			call_rcu_bh(&p->rcu, br_multicast_free_pg);
+
+			if (!mp->ports && !mp->mglist &&
+			    netif_running(br->dev))
+				mod_timer(&mp->timer, jiffies);
+		}
+		goto out;
+	}
+
 	now = jiffies;
 	time = now + br->multicast_last_member_count *
 		     br->multicast_last_member_interval;
@@ -1567,6 +1601,7 @@ void br_multicast_init(struct net_bridge *br)
 	br->hash_max = 512;
 
 	br->multicast_router = 1;
+	br->multicast_fast_leave = 0;
 	br->multicast_querier = 0;
 	br->multicast_last_member_count = 2;
 	br->multicast_startup_query_count = 2;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 6484069..2f5f5b8 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -230,6 +230,7 @@ struct net_bridge
 
 	u8				multicast_disabled:1;
 	u8				multicast_querier:1;
+	u8				multicast_fast_leave:1;
 
 	u32				hash_elasticity;
 	u32				hash_max;
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 5913a3a..f88389f 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -375,6 +375,32 @@ static ssize_t store_multicast_snooping(struct device *d,
 static DEVICE_ATTR(multicast_snooping, S_IRUGO | S_IWUSR,
 		   show_multicast_snooping, store_multicast_snooping);
 
+static ssize_t show_multicast_fast_leave(struct device *d,
+				       struct device_attribute *attr,
+				       char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%d\n", br->multicast_fast_leave);
+}
+
+static int set_fast_leave(struct net_bridge *br, unsigned long val)
+{
+	if (br->multicast_disabled)
+		return -EINVAL;
+
+	br->multicast_fast_leave = !!val;
+	return 0;
+}
+
+static ssize_t store_multicast_fast_leave(struct device *d,
+					struct device_attribute *attr,
+					const char *buf, size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_fast_leave);
+}
+static DEVICE_ATTR(multicast_fast_leave, S_IRUGO | S_IWUSR,
+		   show_multicast_fast_leave, store_multicast_fast_leave);
+
 static ssize_t show_multicast_querier(struct device *d,
 				      struct device_attribute *attr,
 				      char *buf)
@@ -715,6 +741,7 @@ static struct attribute *bridge_attrs[] = {
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&dev_attr_multicast_router.attr,
 	&dev_attr_multicast_snooping.attr,
+	&dev_attr_multicast_fast_leave.attr,
 	&dev_attr_multicast_querier.attr,
 	&dev_attr_hash_elasticity.attr,
 	&dev_attr_hash_max.attr,
