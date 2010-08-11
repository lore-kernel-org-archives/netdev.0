From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6] bridge: allow hub-like behaviour
Date: Wed, 11 Aug 2010 16:40:18 +0200
Message-ID: <20100811144017.GA2625@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60074 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753062Ab0HKOlc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Aug 2010 10:41:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows bridge to behave much like ordinary hub. That means that
every frame received is forwarded to all ports. This functionality is of course
disabled by default, can be enabled via sysfs. This could be handy mainly for
testing purposes.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 net/bridge/br_device.c   |   14 +++++++++-----
 net/bridge/br_input.c    |   12 +++++++++---
 net/bridge/br_private.h  |    1 +
 net/bridge/br_sysfs_br.c |   25 +++++++++++++++++++++++++
 4 files changed, 44 insertions(+), 8 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index cf09fe5..1bfc1c5 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -60,14 +60,18 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 
 		mdst = br_mdb_get(br, skb);
-		if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb))
+		if ((mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) &&
+		     likely(!br->hub_mode))
 			br_multicast_deliver(mdst, skb);
 		else
 			br_flood_deliver(br, skb);
-	} else if ((dst = __br_fdb_get(br, dest)) != NULL)
-		br_deliver(dst->dst, skb);
-	else
-		br_flood_deliver(br, skb);
+	} else {
+		dst = __br_fdb_get(br, dest);
+		if (dst && likely(!br->hub_mode))
+			br_deliver(dst->dst, skb);
+		else
+			br_flood_deliver(br, skb);
+	}
 
 out:
 	rcu_read_unlock();
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 826cd52..24ee87e 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -75,7 +75,8 @@ int br_handle_frame_finish(struct sk_buff *skb)
 
 	if (is_multicast_ether_addr(dest)) {
 		mdst = br_mdb_get(br, skb);
-		if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) {
+		if ((mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) &&
+		    likely(!br->hub_mode)) {
 			if ((mdst && !hlist_unhashed(&mdst->mglist)) ||
 			    br_multicast_is_router(br))
 				skb2 = skb;
@@ -89,8 +90,13 @@ int br_handle_frame_finish(struct sk_buff *skb)
 		br->dev->stats.multicast++;
 	} else if ((dst = __br_fdb_get(br, dest)) && dst->is_local) {
 		skb2 = skb;
-		/* Do not forward the packet since it's local. */
-		skb = NULL;
+		if (likely(!br->hub_mode)) {
+			/* Do not forward the packet since it's local. */
+			skb = NULL;
+		} else {
+			/* In hub mode we want to forward the packet to all. */
+			dst = NULL;
+		}
 	}
 
 	if (skb) {
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 75c90ed..b6a9a7e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -194,6 +194,7 @@ struct net_bridge
 	unsigned long			ageing_time;
 	unsigned long			bridge_hello_time;
 	unsigned long			bridge_forward_delay;
+	bool				hub_mode;
 
 	u8				group_addr[ETH_ALEN];
 	u16				root_port;
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 5c1e555..ac98aa4 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -345,6 +345,30 @@ static ssize_t store_flush(struct device *d,
 }
 static DEVICE_ATTR(flush, S_IWUSR, NULL, store_flush);
 
+static ssize_t show_hub_mode(struct device *d,
+			     struct device_attribute *attr, char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+
+	return sprintf(buf, "%d\n", br->hub_mode ? 1 : 0);
+}
+
+static int set_hub_mode(struct net_bridge *br, unsigned long val)
+{
+	br->hub_mode = val ? true : false;
+	return 0;
+}
+
+static ssize_t store_hub_mode(struct device *d,
+			      struct device_attribute *attr,
+			      const char *buf, size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_hub_mode);
+}
+
+static DEVICE_ATTR(hub_mode, S_IRUGO | S_IWUSR,
+		   show_hub_mode, store_hub_mode);
+
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 static ssize_t show_multicast_router(struct device *d,
 				     struct device_attribute *attr, char *buf)
@@ -698,6 +722,7 @@ static struct attribute *bridge_attrs[] = {
 	&dev_attr_gc_timer.attr,
 	&dev_attr_group_addr.attr,
 	&dev_attr_flush.attr,
+	&dev_attr_hub_mode.attr,
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&dev_attr_multicast_router.attr,
 	&dev_attr_multicast_snooping.attr,
-- 
1.7.2.1

