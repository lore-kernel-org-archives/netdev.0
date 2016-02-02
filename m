From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 3/3] ipvlan: misc changes
Date: Tue,  2 Feb 2016 11:20:44 -0800
Message-ID: <1454440844-2185-1-git-send-email-mahesh@bandewar.net>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36211 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965462AbcBBTUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 14:20:48 -0500
Received: by mail-pa0-f65.google.com with SMTP id y7so487978paa.3
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 11:20:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

1. scope correction for few functions that are used in single file.
2. Adjust variables that are used in fast-path to fit into single cacheline
3. Update rcv_frame() to skip shared check for frames coming over wire

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/ipvlan/ipvlan.h      |  9 +++------
 drivers/net/ipvlan/ipvlan_core.c | 27 ++++++++++++++++-----------
 drivers/net/ipvlan/ipvlan_main.c |  2 +-
 3 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index 817cab1a7959..695a5dc9ace3 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -84,19 +84,19 @@ struct ipvl_addr {
 #define ip4addr ipu.ip4
 	struct hlist_node	hlnode;  /* Hash-table linkage */
 	struct list_head	anode;   /* logical-interface linkage */
-	struct rcu_head		rcu;
 	ipvl_hdr_type		atype;
+	struct rcu_head		rcu;
 };
 
 struct ipvl_port {
 	struct net_device	*dev;
 	struct hlist_head	hlhead[IPVLAN_HASH_SIZE];
 	struct list_head	ipvlans;
-	struct rcu_head		rcu;
+	u16			mode;
 	struct work_struct	wq;
 	struct sk_buff_head	backlog;
 	int			count;
-	u16			mode;
+	struct rcu_head		rcu;
 };
 
 static inline struct ipvl_port *ipvlan_port_get_rcu(const struct net_device *d)
@@ -114,7 +114,6 @@ static inline struct ipvl_port *ipvlan_port_get_rtnl(const struct net_device *d)
 	return rtnl_dereference(d->rx_handler_data);
 }
 
-void ipvlan_adjust_mtu(struct ipvl_dev *ipvlan, struct net_device *dev);
 void ipvlan_init_secret(void);
 unsigned int ipvlan_mac_hash(const unsigned char *addr);
 rx_handler_result_t ipvlan_handle_frame(struct sk_buff **pskb);
@@ -124,7 +123,5 @@ void ipvlan_ht_addr_add(struct ipvl_dev *ipvlan, struct ipvl_addr *addr);
 struct ipvl_addr *ipvlan_find_addr(const struct ipvl_dev *ipvlan,
 				   const void *iaddr, bool is_v6);
 bool ipvlan_addr_busy(struct ipvl_port *port, void *iaddr, bool is_v6);
-struct ipvl_addr *ipvlan_ht_addr_lookup(const struct ipvl_port *port,
-					const void *iaddr, bool is_v6);
 void ipvlan_ht_addr_del(struct ipvl_addr *addr);
 #endif /* __IPVLAN_H */
diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 21c380f9ccd5..5f79cd3eb8be 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -53,8 +53,8 @@ static u8 ipvlan_get_v4_hash(const void *iaddr)
 	       IPVLAN_HASH_MASK;
 }
 
-struct ipvl_addr *ipvlan_ht_addr_lookup(const struct ipvl_port *port,
-					const void *iaddr, bool is_v6)
+static struct ipvl_addr *ipvlan_ht_addr_lookup(const struct ipvl_port *port,
+					       const void *iaddr, bool is_v6)
 {
 	struct ipvl_addr *addr;
 	u8 hash;
@@ -265,20 +265,25 @@ static int ipvlan_rcv_frame(struct ipvl_addr *addr, struct sk_buff **pskb,
 	struct sk_buff *skb = *pskb;
 
 	len = skb->len + ETH_HLEN;
-	if (unlikely(!(dev->flags & IFF_UP))) {
-		kfree_skb(skb);
-		goto out;
-	}
+	/* Only packets exchanged between two local slaves need to have
+	 * device-up check as well as skb-share check.
+	 */
+	if (local) {
+		if (unlikely(!(dev->flags & IFF_UP))) {
+			kfree_skb(skb);
+			goto out;
+		}
 
-	skb = skb_share_check(skb, GFP_ATOMIC);
-	if (!skb)
-		goto out;
+		skb = skb_share_check(skb, GFP_ATOMIC);
+		if (!skb)
+			goto out;
 
-	*pskb = skb;
+		*pskb = skb;
+	}
 	skb->dev = dev;
-	skb->pkt_type = PACKET_HOST;
 
 	if (local) {
+		skb->pkt_type = PACKET_HOST;
 		if (dev_forward_skb(ipvlan->dev, skb) == NET_RX_SUCCESS)
 			success = true;
 	} else {
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 54c542526262..b20951583b46 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -9,7 +9,7 @@
 
 #include "ipvlan.h"
 
-void ipvlan_adjust_mtu(struct ipvl_dev *ipvlan, struct net_device *dev)
+static void ipvlan_adjust_mtu(struct ipvl_dev *ipvlan, struct net_device *dev)
 {
 	ipvlan->dev->mtu = dev->mtu - ipvlan->mtu_adj;
 }
-- 
2.7.0.rc3.207.g0ac5344
