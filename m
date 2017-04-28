From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] esp: Fix misplaced spin_unlock_bh.
Date: Fri, 28 Apr 2017 10:42:38 +0200
Message-ID: <1493368958-29609-2-git-send-email-steffen.klassert@secunet.com>
References: <1493368958-29609-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:59570 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1164141AbdD1KFQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 06:05:16 -0400
In-Reply-To: <1493368958-29609-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A recent commit moved esp_alloc_tmp() out of a lock
protected region, but forgot to remove the unlock from
the error path. This patch removes the forgotten unlock.
While at it, remove some unneeded error assignments too.

Fixes: fca11ebde3f0 ("esp4: Reorganize esp_output")
Fixes: 383d0350f2cc ("esp6: Reorganize esp_output")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/esp4.c | 6 +-----
 net/ipv6/esp6.c | 6 +-----
 2 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 7e501ad..7f2caf7 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -356,11 +356,8 @@ int esp_output_tail(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *
 	ivlen = crypto_aead_ivsize(aead);
 
 	tmp = esp_alloc_tmp(aead, esp->nfrags + 2, extralen);
-	if (!tmp) {
-		spin_unlock_bh(&x->lock);
-		err = -ENOMEM;
+	if (!tmp)
 		goto error;
-	}
 
 	extra = esp_tmp_extra(tmp);
 	iv = esp_tmp_iv(aead, tmp, extralen);
@@ -389,7 +386,6 @@ int esp_output_tail(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *
 		spin_lock_bh(&x->lock);
 		if (unlikely(!skb_page_frag_refill(allocsize, pfrag, GFP_ATOMIC))) {
 			spin_unlock_bh(&x->lock);
-			err = -ENOMEM;
 			goto error;
 		}
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 8b55abf..1fe99ba 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -330,11 +330,8 @@ int esp6_output_tail(struct xfrm_state *x, struct sk_buff *skb, struct esp_info
 	ivlen = crypto_aead_ivsize(aead);
 
 	tmp = esp_alloc_tmp(aead, esp->nfrags + 2, seqhilen);
-	if (!tmp) {
-		spin_unlock_bh(&x->lock);
-		err = -ENOMEM;
+	if (!tmp)
 		goto error;
-	}
 
 	seqhi = esp_tmp_seqhi(tmp);
 	iv = esp_tmp_iv(aead, tmp, seqhilen);
@@ -362,7 +359,6 @@ int esp6_output_tail(struct xfrm_state *x, struct sk_buff *skb, struct esp_info
 		spin_lock_bh(&x->lock);
 		if (unlikely(!skb_page_frag_refill(allocsize, pfrag, GFP_ATOMIC))) {
 			spin_unlock_bh(&x->lock);
-			err = -ENOMEM;
 			goto error;
 		}
 
-- 
2.7.4
