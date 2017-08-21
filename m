From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/4] esp: Fix memleaks on error paths.
Date: Mon, 21 Aug 2017 08:08:00 +0200
Message-ID: <1503295683-19153-2-git-send-email-steffen.klassert@secunet.com>
References: <1503295683-19153-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:35450 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750985AbdHUGIJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 02:08:09 -0400
In-Reply-To: <1503295683-19153-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We leak the temporary allocated resources in error paths,
fix this by freeing them.

Fixes: fca11ebde3f ("esp4: Reorganize esp_output")
Fixes: 383d0350f2c ("esp6: Reorganize esp_output")
Fixes: 3f29770723f ("ipsec: check return value of skb_to_sgvec always")
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/esp4.c | 13 ++++++++-----
 net/ipv6/esp6.c |  9 +++++----
 2 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 0cbee0a..dbb31a9 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -381,7 +381,7 @@ int esp_output_tail(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *
 		           (unsigned char *)esph - skb->data,
 		           assoclen + ivlen + esp->clen + alen);
 	if (unlikely(err < 0))
-		goto error;
+		goto error_free;
 
 	if (!esp->inplace) {
 		int allocsize;
@@ -392,7 +392,7 @@ int esp_output_tail(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *
 		spin_lock_bh(&x->lock);
 		if (unlikely(!skb_page_frag_refill(allocsize, pfrag, GFP_ATOMIC))) {
 			spin_unlock_bh(&x->lock);
-			goto error;
+			goto error_free;
 		}
 
 		skb_shinfo(skb)->nr_frags = 1;
@@ -409,7 +409,7 @@ int esp_output_tail(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *
 			           (unsigned char *)esph - skb->data,
 			           assoclen + ivlen + esp->clen + alen);
 		if (unlikely(err < 0))
-			goto error;
+			goto error_free;
 	}
 
 	if ((x->props.flags & XFRM_STATE_ESN))
@@ -442,8 +442,9 @@ int esp_output_tail(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *
 
 	if (sg != dsg)
 		esp_ssg_unref(x, tmp);
-	kfree(tmp);
 
+error_free:
+	kfree(tmp);
 error:
 	return err;
 }
@@ -695,8 +696,10 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 
 	sg_init_table(sg, nfrags);
 	err = skb_to_sgvec(skb, sg, 0, skb->len);
-	if (unlikely(err < 0))
+	if (unlikely(err < 0)) {
+		kfree(tmp);
 		goto out;
+	}
 
 	skb->ip_summed = CHECKSUM_NONE;
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 9ed3547..392def1 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -345,7 +345,7 @@ int esp6_output_tail(struct xfrm_state *x, struct sk_buff *skb, struct esp_info
 		           (unsigned char *)esph - skb->data,
 		           assoclen + ivlen + esp->clen + alen);
 	if (unlikely(err < 0))
-		goto error;
+		goto error_free;
 
 	if (!esp->inplace) {
 		int allocsize;
@@ -356,7 +356,7 @@ int esp6_output_tail(struct xfrm_state *x, struct sk_buff *skb, struct esp_info
 		spin_lock_bh(&x->lock);
 		if (unlikely(!skb_page_frag_refill(allocsize, pfrag, GFP_ATOMIC))) {
 			spin_unlock_bh(&x->lock);
-			goto error;
+			goto error_free;
 		}
 
 		skb_shinfo(skb)->nr_frags = 1;
@@ -373,7 +373,7 @@ int esp6_output_tail(struct xfrm_state *x, struct sk_buff *skb, struct esp_info
 			           (unsigned char *)esph - skb->data,
 			           assoclen + ivlen + esp->clen + alen);
 		if (unlikely(err < 0))
-			goto error;
+			goto error_free;
 	}
 
 	if ((x->props.flags & XFRM_STATE_ESN))
@@ -406,8 +406,9 @@ int esp6_output_tail(struct xfrm_state *x, struct sk_buff *skb, struct esp_info
 
 	if (sg != dsg)
 		esp_ssg_unref(x, tmp);
-	kfree(tmp);
 
+error_free:
+	kfree(tmp);
 error:
 	return err;
 }
-- 
2.7.4
