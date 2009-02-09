From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/4] gro: Optimise Ethernet header comparison
Date: Mon, 09 Feb 2009 15:00:37 +1100
Message-ID: <E1LWNK1-0000ni-V0@gondolin.me.apana.org.au>
References: <20090209035930.GA2988@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34968 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753836AbZBIEAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2009 23:00:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gro: Optimise Ethernet header comparison

This patch optimises the Ethernet header comparison to use 2-byte
and 4-byte xors instead of memcmp.  In order to facilitate this,
the actual comparison is now carried out by the callers of the
shared dev_gro_receive function.

This has a significant impact when receiving 1500B packets through
10GbE.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/etherdevice.h |   21 +++++++++++++++++++++
 include/linux/netdevice.h   |    7 +++++++
 net/8021q/vlan_core.c       |    4 +++-
 net/core/dev.c              |   23 ++---------------------
 4 files changed, 33 insertions(+), 22 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 1cb0f0b..a1f17ab 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -184,4 +184,25 @@ static inline unsigned compare_ether_addr_64bits(const u8 addr1[6+2],
 }
 #endif	/* __KERNEL__ */
 
+/**
+ * compare_ether_header - Compare two Ethernet headers
+ * @a: Pointer to Ethernet header
+ * @b: Pointer to Ethernet header
+ *
+ * Compare two ethernet headers, returns 0 if equal.
+ * This assumes that the network header (i.e., IP header) is 4-byte
+ * aligned OR the platform can handle unaligned access.  This is the
+ * case for all packets coming into netif_receive_skb or similar
+ * entry points.
+ */
+
+static inline int compare_ether_header(const void *a, const void *b)
+{
+	u32 *a32 = (u32 *)((u8 *)a + 2);
+	u32 *b32 = (u32 *)((u8 *)b + 2);
+
+	return (*(u16 *)a ^ *(u16 *)b) | (a32[0] ^ b32[0]) |
+	       (a32[1] ^ b32[1]) | (a32[2] ^ b32[2]);
+}
+
 #endif	/* _LINUX_ETHERDEVICE_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e1d482c..c3af50b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1117,6 +1117,13 @@ static inline void skb_gro_reset_offset(struct sk_buff *skb)
 	NAPI_GRO_CB(skb)->data_offset = 0;
 }
 
+static inline void *skb_gro_mac_header(struct sk_buff *skb)
+{
+	return skb_mac_header(skb) < skb->data ? skb_mac_header(skb) :
+	       page_address(skb_shinfo(skb)->frags[0].page) +
+	       skb_shinfo(skb)->frags[0].page_offset;
+}
+
 static inline int dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 				  unsigned short type,
 				  const void *daddr, const void *saddr,
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 378fa69..70435af 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -85,7 +85,9 @@ static int vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
 		goto drop;
 
 	for (p = napi->gro_list; p; p = p->next) {
-		NAPI_GRO_CB(p)->same_flow = p->dev == skb->dev;
+		NAPI_GRO_CB(p)->same_flow =
+			p->dev == skb->dev && !compare_ether_header(
+				skb_mac_header(p), skb_gro_mac_header(skb));
 		NAPI_GRO_CB(p)->flush = 0;
 	}
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 330534e..dca2225 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -215,13 +215,6 @@ static inline struct hlist_head *dev_index_hash(struct net *net, int ifindex)
 	return &net->dev_index_head[ifindex & ((1 << NETDEV_HASHBITS) - 1)];
 }
 
-static inline void *skb_gro_mac_header(struct sk_buff *skb)
-{
-	return skb_mac_header(skb) < skb->data ? skb_mac_header(skb) :
-	       page_address(skb_shinfo(skb)->frags[0].page) +
-	       skb_shinfo(skb)->frags[0].page_offset;
-}
-
 /* Device list insertion */
 static int list_netdevice(struct net_device *dev)
 {
@@ -2415,29 +2408,16 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, head, list) {
-		struct sk_buff *p;
-		void *mac;
-
 		if (ptype->type != type || ptype->dev || !ptype->gro_receive)
 			continue;
 
 		skb_set_network_header(skb, skb_gro_offset(skb));
-		mac = skb_gro_mac_header(skb);
 		mac_len = skb->network_header - skb->mac_header;
 		skb->mac_len = mac_len;
 		NAPI_GRO_CB(skb)->same_flow = 0;
 		NAPI_GRO_CB(skb)->flush = 0;
 		NAPI_GRO_CB(skb)->free = 0;
 
-		for (p = napi->gro_list; p; p = p->next) {
-			if (!NAPI_GRO_CB(p)->same_flow)
-				continue;
-
-			if (p->mac_len != mac_len ||
-			    memcmp(skb_mac_header(p), mac, mac_len))
-				NAPI_GRO_CB(p)->same_flow = 0;
-		}
-
 		pp = ptype->gro_receive(&napi->gro_list, skb);
 		break;
 	}
@@ -2492,7 +2472,8 @@ static int __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	struct sk_buff *p;
 
 	for (p = napi->gro_list; p; p = p->next) {
-		NAPI_GRO_CB(p)->same_flow = 1;
+		NAPI_GRO_CB(p)->same_flow = !compare_ether_header(
+			skb_mac_header(p), skb_gro_mac_header(skb));
 		NAPI_GRO_CB(p)->flush = 0;
 	}
 
