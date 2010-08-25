From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] gro: __napi_gro_receive() optimizations
Date: Wed, 25 Aug 2010 22:33:51 +0200
Message-ID: <1282768431.2681.144.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55731 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753808Ab0HYUd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 16:33:57 -0400
Received: by wwb28 with SMTP id 28so310806wwb.1
        for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 13:33:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

compare_ether_header() can have a special implementation on 64 bit
arches if CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is defined

__napi_gro_receive() can avoid a conditional branch to perform device
match.

__napi_gro_receive() can be used from vlan_gro_common() instead of being
duplicated.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/etherdevice.h |   10 +++++++++-
 include/linux/netdevice.h   |    2 ++
 net/8021q/vlan_core.c       |   14 ++------------
 net/core/dev.c              |   12 +++++++-----
 4 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 2308fbb..02144fd 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -237,13 +237,21 @@ static inline bool is_etherdev_addr(const struct net_device *dev,
  * entry points.
  */
 
-static inline int compare_ether_header(const void *a, const void *b)
+static inline unsigned long compare_ether_header(const void *a, const void *b)
 {
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
+	unsigned long fold;
+
+	fold = *(unsigned long *)a ^ *(unsigned long *)b;
+	fold |= *(unsigned long *)(a + 6) ^ *(unsigned long *)(b + 6);
+	return fold;
+#else
 	u32 *a32 = (u32 *)((u8 *)a + 2);
 	u32 *b32 = (u32 *)((u8 *)b + 2);
 
 	return (*(u16 *)a ^ *(u16 *)b) | (a32[0] ^ b32[0]) |
 	       (a32[1] ^ b32[1]) | (a32[2] ^ b32[2]);
+#endif
 }
 
 #endif	/* _LINUX_ETHERDEVICE_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 59962db..629773e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1695,6 +1695,8 @@ extern gro_result_t	dev_gro_receive(struct napi_struct *napi,
 extern gro_result_t	napi_skb_finish(gro_result_t ret, struct sk_buff *skb);
 extern gro_result_t	napi_gro_receive(struct napi_struct *napi,
 					 struct sk_buff *skb);
+extern gro_result_t   __napi_gro_receive(struct napi_struct *napi,
+					 struct sk_buff *skb);
 extern void		napi_reuse_skb(struct napi_struct *napi,
 				       struct sk_buff *skb);
 extern struct sk_buff *	napi_get_frags(struct napi_struct *napi);
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 07eeb5b..947650a 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -102,19 +102,9 @@ vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
 	if (vlan_dev)
 		skb->dev = vlan_dev;
 	else if (vlan_id)
-		goto drop;
-
-	for (p = napi->gro_list; p; p = p->next) {
-		NAPI_GRO_CB(p)->same_flow =
-			p->dev == skb->dev && !compare_ether_header(
-				skb_mac_header(p), skb_gro_mac_header(skb));
-		NAPI_GRO_CB(p)->flush = 0;
-	}
-
-	return dev_gro_receive(napi, skb);
+		return GRO_DROP;
 
-drop:
-	return GRO_DROP;
+	return __napi_gro_receive(napi, skb);
 }
 
 gro_result_t vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
diff --git a/net/core/dev.c b/net/core/dev.c
index 859e30f..61e9c96 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3169,21 +3169,23 @@ normal:
 }
 EXPORT_SYMBOL(dev_gro_receive);
 
-static gro_result_t
-__napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
+gro_result_t __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
 	struct sk_buff *p;
 
 	for (p = napi->gro_list; p; p = p->next) {
-		NAPI_GRO_CB(p)->same_flow =
-			(p->dev == skb->dev) &&
-			!compare_ether_header(skb_mac_header(p),
+		unsigned long diffs;
+
+		diffs = (unsigned long)p->dev ^ (unsigned long)skb->dev;
+		diffs |= compare_ether_header(skb_mac_header(p),
 					      skb_gro_mac_header(skb));
+		NAPI_GRO_CB(p)->same_flow = !diffs;
 		NAPI_GRO_CB(p)->flush = 0;
 	}
 
 	return dev_gro_receive(napi, skb);
 }
+EXPORT_SYMBOL(__napi_gro_receive);
 
 gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 {


