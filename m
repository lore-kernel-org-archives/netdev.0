From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/14] gro: Inline skb_gro_header and cache frag0 virtual address
Date: Wed, 27 May 2009 14:50:21 +1000
Message-ID: <E1M9B5p-0001Qp-4l@gondolin.me.apana.org.au>
References: <20090527044539.GA32372@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49813 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754887AbZE0FH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 01:07:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gro: Inline skb_gro_header and cache frag0 virtual address

The function skb_gro_header is called four times per packet which
quickly adds up at 10Gb/s.  This patch inlines it to allow better
optimisations.

Some architectures perform multiplication for page_address, which
is done by each skb_gro_header invocation.  This patch caches that
value in skb->cb to avoid the unnecessary multiplications.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/netdevice.h |   22 +++++++++++++++-------
 net/core/dev.c            |   27 ++++++++++++---------------
 2 files changed, 27 insertions(+), 22 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ae3c209..fcb1cc9 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1008,6 +1008,9 @@ void netif_napi_add(struct net_device *dev, struct napi_struct *napi,
 void netif_napi_del(struct napi_struct *napi);
 
 struct napi_gro_cb {
+	/* Virtual address of skb_shinfo(skb)->frags[0].page + offset. */
+	void *frag0;
+
 	/* This indicates where we are processing relative to skb->data. */
 	int data_offset;
 
@@ -1107,9 +1110,9 @@ extern int		dev_restart(struct net_device *dev);
 #ifdef CONFIG_NETPOLL_TRAP
 extern int		netpoll_trap(void);
 #endif
-extern void	      *skb_gro_header(struct sk_buff *skb, unsigned int hlen);
 extern int	       skb_gro_receive(struct sk_buff **head,
 				       struct sk_buff *skb);
+extern void	       skb_gro_reset_offset(struct sk_buff *skb);
 
 static inline unsigned int skb_gro_offset(const struct sk_buff *skb)
 {
@@ -1126,23 +1129,28 @@ static inline void skb_gro_pull(struct sk_buff *skb, unsigned int len)
 	NAPI_GRO_CB(skb)->data_offset += len;
 }
 
-static inline void skb_gro_reset_offset(struct sk_buff *skb)
+static inline void *skb_gro_header(struct sk_buff *skb, unsigned int hlen)
 {
-	NAPI_GRO_CB(skb)->data_offset = 0;
+	unsigned int offset = skb_gro_offset(skb);
+
+	hlen += offset;
+	if (!NAPI_GRO_CB(skb)->frag0 ||
+	    unlikely(skb_shinfo(skb)->frags[0].size + skb_headlen(skb) < hlen))
+		return pskb_may_pull(skb, hlen) ? skb->data + offset : NULL;
+
+	return NAPI_GRO_CB(skb)->frag0 + offset;
 }
 
 static inline void *skb_gro_mac_header(struct sk_buff *skb)
 {
 	return skb_headlen(skb) ? skb_mac_header(skb) :
-	       page_address(skb_shinfo(skb)->frags[0].page) +
-	       skb_shinfo(skb)->frags[0].page_offset;
+	       NAPI_GRO_CB(skb)->frag0;
 }
 
 static inline void *skb_gro_network_header(struct sk_buff *skb)
 {
 	return skb_headlen(skb) ? skb_network_header(skb) :
-	       page_address(skb_shinfo(skb)->frags[0].page) +
-	       skb_shinfo(skb)->frags[0].page_offset + skb_network_offset(skb);
+	       NAPI_GRO_CB(skb)->frag0 + skb_network_offset(skb);
 }
 
 static inline int dev_hard_header(struct sk_buff *skb, struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index 241613f..9b4c8da 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2387,21 +2387,6 @@ void napi_gro_flush(struct napi_struct *napi)
 }
 EXPORT_SYMBOL(napi_gro_flush);
 
-void *skb_gro_header(struct sk_buff *skb, unsigned int hlen)
-{
-	unsigned int offset = skb_gro_offset(skb);
-
-	hlen += offset;
-	if (unlikely(skb_headlen(skb) ||
-		     skb_shinfo(skb)->frags[0].size < hlen ||
-		     PageHighMem(skb_shinfo(skb)->frags[0].page)))
-		return pskb_may_pull(skb, hlen) ? skb->data + offset : NULL;
-
-	return page_address(skb_shinfo(skb)->frags[0].page) +
-	       skb_shinfo(skb)->frags[0].page_offset + offset;
-}
-EXPORT_SYMBOL(skb_gro_header);
-
 int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
 	struct sk_buff **pp = NULL;
@@ -2517,6 +2502,18 @@ int napi_skb_finish(int ret, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(napi_skb_finish);
 
+void skb_gro_reset_offset(struct sk_buff *skb)
+{
+	NAPI_GRO_CB(skb)->data_offset = 0;
+	NAPI_GRO_CB(skb)->frag0 = NULL;
+
+	if (!skb_headlen(skb) && !PageHighMem(skb_shinfo(skb)->frags[0].page))
+		NAPI_GRO_CB(skb)->frag0 =
+			page_address(skb_shinfo(skb)->frags[0].page) +
+			skb_shinfo(skb)->frags[0].page_offset;
+}
+EXPORT_SYMBOL(skb_gro_reset_offset);
+
 int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
 	skb_gro_reset_offset(skb);
