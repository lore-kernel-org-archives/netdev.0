From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: fix napi_reuse_skb() skb reserve
Date: Wed, 21 Mar 2012 09:58:03 -0700
Message-ID: <1332349083.5330.49.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:47338 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753315Ab2CUQ6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 12:58:06 -0400
Received: by dajr28 with SMTP id r28so1828909daj.19
        for <netdev@vger.kernel.org>; Wed, 21 Mar 2012 09:58:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

napi->skb is allocated in napi_get_frags() using
netdev_alloc_skb_ip_align(), with a reserve of NET_SKB_PAD +
NET_IP_ALIGN bytes.

However, when such skb is recycled in napi_reuse_skb(), it ends with a
reserve of NET_IP_ALIGN which is suboptimal.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 net/core/dev.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0f3eb7d..452db70 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3560,7 +3560,8 @@ EXPORT_SYMBOL(napi_gro_receive);
 static void napi_reuse_skb(struct napi_struct *napi, struct sk_buff *skb)
 {
 	__skb_pull(skb, skb_headlen(skb));
-	skb_reserve(skb, NET_IP_ALIGN - skb_headroom(skb));
+	/* restore the reserve we had after netdev_alloc_skb_ip_align() */
+	skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN - skb_headroom(skb));
 	skb->vlan_tci = 0;
 	skb->dev = napi->dev;
 	skb->skb_iif = 0;
