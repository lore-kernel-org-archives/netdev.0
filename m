From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: gro: fix a potential crash in skb_gro_reset_offset
Date: Sun, 07 Oct 2012 10:28:06 +0200
Message-ID: <1349598486.21172.2063.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:63341 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751672Ab2JGI2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Oct 2012 04:28:11 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so2802444wgb.1
        for <netdev@vger.kernel.org>; Sun, 07 Oct 2012 01:28:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Before accessing skb first fragment, better make sure there
is one.

This is probably not needed for old kernels, since an ethernet frame
cannot contain only an ethernet header, but the recent GRO addition
to tunnels makes this patch needed.

Also skb_gro_reset_offset() can be static, it actually allows
compiler to inline it.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 include/linux/netdevice.h |    1 -
 net/core/dev.c            |   14 ++++++++------
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 01646aa..a659fd0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1663,7 +1663,6 @@ extern int		netpoll_trap(void);
 #endif
 extern int	       skb_gro_receive(struct sk_buff **head,
 				       struct sk_buff *skb);
-extern void	       skb_gro_reset_offset(struct sk_buff *skb);
 
 static inline unsigned int skb_gro_offset(const struct sk_buff *skb)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index 1e0a184..de2bad7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3631,20 +3631,22 @@ gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(napi_skb_finish);
 
-void skb_gro_reset_offset(struct sk_buff *skb)
+static void skb_gro_reset_offset(struct sk_buff *skb)
 {
+	const struct skb_shared_info *pinfo = skb_shinfo(skb);
+	const skb_frag_t *frag0 = &pinfo->frags[0];
+
 	NAPI_GRO_CB(skb)->data_offset = 0;
 	NAPI_GRO_CB(skb)->frag0 = NULL;
 	NAPI_GRO_CB(skb)->frag0_len = 0;
 
 	if (skb->mac_header == skb->tail &&
-	    !PageHighMem(skb_frag_page(&skb_shinfo(skb)->frags[0]))) {
-		NAPI_GRO_CB(skb)->frag0 =
-			skb_frag_address(&skb_shinfo(skb)->frags[0]);
-		NAPI_GRO_CB(skb)->frag0_len = skb_frag_size(&skb_shinfo(skb)->frags[0]);
+	    pinfo->nr_frags &&
+	    !PageHighMem(skb_frag_page(frag0))) {
+		NAPI_GRO_CB(skb)->frag0 = skb_frag_address(frag0);
+		NAPI_GRO_CB(skb)->frag0_len = skb_frag_size(frag0);
 	}
 }
-EXPORT_SYMBOL(skb_gro_reset_offset);
 
 gro_result_t napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
