From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6] bridge br_multicast: Don't refer to BR_INPUT_SKB_CB(skb)->mrouters_only without IGMP snooping.
Date: Tue, 16 Mar 2010 16:51:18 +0900
Message-ID: <201003160751.o2G7pIwM022633@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:47011 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936515Ab0CPHvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Mar 2010 03:51:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without CONFIG_BRIDGE_IGMP_SNOOPING,
BR_INPUT_SKB_CB(skb)->mrouters_only is not appropriately
initialized, so we can see garbage.

A clear option to fix this is to set it even without that
config, but we cannot optimize out the branch.

Let's introduce a macro that returns value of mrouters_only
and let it return 0 without CONFIG_BRIDGE_IGMP_SNOOPING.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/bridge/br_device.c  |    2 +-
 net/bridge/br_input.c   |    2 +-
 net/bridge/br_private.h |    8 ++++++++
 3 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index eb7062d..90a9024 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -40,7 +40,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 			goto out;
 
 		mdst = br_mdb_get(br, skb);
-		if (mdst || BR_INPUT_SKB_CB(skb)->mrouters_only)
+		if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb))
 			br_multicast_deliver(mdst, skb);
 		else
 			br_flood_deliver(br, skb);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 53b3985..79138cf 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -70,7 +70,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
 
 	if (is_multicast_ether_addr(dest)) {
 		mdst = br_mdb_get(br, skb);
-		if (mdst || BR_INPUT_SKB_CB(skb)->mrouters_only) {
+		if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) {
 			if ((mdst && !hlist_unhashed(&mdst->mglist)) ||
 			    br_multicast_is_router(br))
 				skb2 = skb;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 1cf2cef..1434392 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -206,12 +206,20 @@ struct net_bridge
 
 struct br_input_skb_cb {
 	struct net_device *brdev;
+#ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	int igmp;
 	int mrouters_only;
+#endif
 };
 
 #define BR_INPUT_SKB_CB(__skb)	((struct br_input_skb_cb *)(__skb)->cb)
 
+#ifdef CONFIG_BRIDGE_IGMP_SNOOPING
+# define BR_INPUT_SKB_CB_MROUTERS_ONLY(__skb)	(BR_INPUT_SKB_CB(__skb)->mrouters_only)
+#else
+# define BR_INPUT_SKB_CB_MROUTERS_ONLY(__skb)	(0)
+#endif
+
 extern struct notifier_block br_device_notifier;
 extern const u8 br_group_address[ETH_ALEN];
 
-- 
1.5.6.5

