From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 2/2] macvlan: add multicast filter
Date: Tue, 05 Feb 2013 22:22:50 -0800
Message-ID: <1360131770.28557.26.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f42.google.com ([209.85.210.42]:42248 "EHLO
	mail-da0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088Ab3BFGWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 01:22:53 -0500
Received: by mail-da0-f42.google.com with SMTP id z17so475547dal.29
        for <netdev@vger.kernel.org>; Tue, 05 Feb 2013 22:22:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Setting up IPv6 addresses on configurations with many macvlans
is not really working, as many multicast messages are dropped.

Add a multicast filter to macvlan to reduce the amount of cloned
skbs and overhead.

Successfully tested with 1024 macvlans on one ethernet device.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Ben Greear <greearb@candelatech.com>
---
 drivers/net/macvlan.c      |   23 +++++++++++++++++++++++
 include/linux/if_macvlan.h |    6 ++++++
 2 files changed, 29 insertions(+)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 7b44ebd..f494da8 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -29,6 +29,7 @@
 #include <linux/if_vlan.h>
 #include <linux/if_link.h>
 #include <linux/if_macvlan.h>
+#include <linux/hash.h>
 #include <net/rtnetlink.h>
 #include <net/xfrm.h>
 
@@ -126,6 +127,13 @@ static int macvlan_broadcast_one(struct sk_buff *skb,
 	return vlan->receive(skb);
 }
 
+static unsigned int mc_hash(const unsigned char *addr)
+{
+	u32 val = __get_unaligned_cpu32(addr + 2);
+
+	return hash_32(val, MACVLAN_MC_FILTER_BITS);
+}
+
 static void macvlan_broadcast(struct sk_buff *skb,
 			      const struct macvlan_port *port,
 			      struct net_device *src,
@@ -137,6 +145,7 @@ static void macvlan_broadcast(struct sk_buff *skb,
 	struct sk_buff *nskb;
 	unsigned int i;
 	int err;
+	unsigned int hash = mc_hash(eth->h_dest);
 
 	if (skb->protocol == htons(ETH_P_PAUSE))
 		return;
@@ -146,6 +155,8 @@ static void macvlan_broadcast(struct sk_buff *skb,
 			if (vlan->dev == src || !(vlan->mode & mode))
 				continue;
 
+			if (!test_bit(hash, vlan->mc_filter))
+				continue;
 			nskb = skb_clone(skb, GFP_ATOMIC);
 			err = macvlan_broadcast_one(nskb, vlan, eth,
 					 mode == MACVLAN_MODE_BRIDGE);
@@ -405,6 +416,18 @@ static void macvlan_set_mac_lists(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 
+	if (dev->flags & (IFF_PROMISC | IFF_ALLMULTI)) {
+		bitmap_fill(vlan->mc_filter, MACVLAN_MC_FILTER_SZ);
+	} else {
+		struct netdev_hw_addr *ha;
+		DECLARE_BITMAP(filter, MACVLAN_MC_FILTER_SZ);
+
+		bitmap_zero(filter, MACVLAN_MC_FILTER_SZ);
+		netdev_for_each_mc_addr(ha, dev) {
+			__set_bit(mc_hash(ha->addr), filter);
+		}
+		bitmap_copy(vlan->mc_filter, filter, MACVLAN_MC_FILTER_SZ);
+	}
 	dev_uc_sync(vlan->lowerdev, dev);
 	dev_mc_sync(vlan->lowerdev, dev);
 }
diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
index f65e8d2..84dde1d 100644
--- a/include/linux/if_macvlan.h
+++ b/include/linux/if_macvlan.h
@@ -52,6 +52,9 @@ struct macvlan_pcpu_stats {
  */
 #define MAX_MACVTAP_QUEUES	(NR_CPUS < 16 ? NR_CPUS : 16)
 
+#define MACVLAN_MC_FILTER_BITS	8
+#define MACVLAN_MC_FILTER_SZ	(1 << MACVLAN_MC_FILTER_BITS)
+
 struct macvlan_dev {
 	struct net_device	*dev;
 	struct list_head	list;
@@ -59,6 +62,9 @@ struct macvlan_dev {
 	struct macvlan_port	*port;
 	struct net_device	*lowerdev;
 	struct macvlan_pcpu_stats __percpu *pcpu_stats;
+
+	DECLARE_BITMAP(mc_filter, MACVLAN_MC_FILTER_SZ);
+
 	enum macvlan_mode	mode;
 	u16			flags;
 	int (*receive)(struct sk_buff *skb);
