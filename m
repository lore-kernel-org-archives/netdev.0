From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 v3] gro: __napi_gro_receive() optimizations
Date: Fri, 27 Aug 2010 06:35:13 +0200
Message-ID: <1282883713.2501.29.camel@edumazet-laptop>
References: <1282768431.2681.144.camel@edumazet-laptop>
	 <20100825.135726.189708768.davem@davemloft.net>
	 <1282770911.2681.205.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64726 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109Ab0H0EfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 00:35:20 -0400
Received: by wwb28 with SMTP id 28so2727275wwb.1
        for <netdev@vger.kernel.org>; Thu, 26 Aug 2010 21:35:18 -0700 (PDT)
In-Reply-To: <1282770911.2681.205.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

compare_ether_header() can have a special implementation on 64 bit
arches if CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is defined.

__napi_gro_receive() and vlan_gro_common() can avoid a conditional
branch to perform device match.

On x86_64, __napi_gro_receive() has now 38 instructions instead of 53

As gcc-4.4.3 still choose to not inline it, add inline keyword to this
performance critical function.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Herbert Xu <herbert@gondor.apana.org.au>
---
 include/linux/etherdevice.h |   10 +++++++++-
 net/8021q/vlan_core.c       |    9 ++++++---
 net/core/dev.c              |   10 ++++++----
 3 files changed, 21 insertions(+), 8 deletions(-)

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
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 07eeb5b..3438c01 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -105,9 +105,12 @@ vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
 		goto drop;
 
 	for (p = napi->gro_list; p; p = p->next) {
-		NAPI_GRO_CB(p)->same_flow =
-			p->dev == skb->dev && !compare_ether_header(
-				skb_mac_header(p), skb_gro_mac_header(skb));
+		unsigned long diffs;
+
+		diffs = (unsigned long)p->dev ^ (unsigned long)skb->dev;
+		diffs |= compare_ether_header(skb_mac_header(p),
+					      skb_gro_mac_header(skb));
+		NAPI_GRO_CB(p)->same_flow = !diffs;
 		NAPI_GRO_CB(p)->flush = 0;
 	}
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 859e30f..63bd20a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3169,16 +3169,18 @@ normal:
 }
 EXPORT_SYMBOL(dev_gro_receive);
 
-static gro_result_t
+static inline gro_result_t
 __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
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
 


