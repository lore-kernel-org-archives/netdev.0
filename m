From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net v2 4/9] macsec: fix rx_sa refcounting with decrypt callback
Date: Fri, 22 Apr 2016 11:28:04 +0200
Message-ID: <237ed3772aba308ef012a05d696065332d8ab0d1.1461315621.git.sd@queasysnail.net>
References: <cover.1461315621.git.sd@queasysnail.net>
Cc: Lance Richardson <lrichard@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49793 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754132AbcDVJ2h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 05:28:37 -0400
In-Reply-To: <cover.1461315621.git.sd@queasysnail.net>
In-Reply-To: <cover.1461315621.git.sd@queasysnail.net>
References: <cover.1461315621.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The decrypt callback macsec_decrypt_done needs a reference on the rx_sa
and releases it before returning, but macsec_handle_frame already
put that reference after macsec_decrypt returned NULL.

Set rx_sa to NULL when the decrypt callback runs so that
macsec_handle_frame knows it must not release the reference.

Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/macsec.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 2a2136b7d324..1fd2b147fda1 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -880,12 +880,12 @@ static struct sk_buff *macsec_decrypt(struct sk_buff *skb,
 	macsec_skb_cb(skb)->valid = false;
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (!skb)
-		return NULL;
+		return ERR_PTR(-ENOMEM);
 
 	req = aead_request_alloc(rx_sa->key.tfm, GFP_ATOMIC);
 	if (!req) {
 		kfree_skb(skb);
-		return NULL;
+		return ERR_PTR(-ENOMEM);
 	}
 
 	hdr = (struct macsec_eth_header *)skb->data;
@@ -905,7 +905,7 @@ static struct sk_buff *macsec_decrypt(struct sk_buff *skb,
 		skb = skb_unshare(skb, GFP_ATOMIC);
 		if (!skb) {
 			aead_request_free(req);
-			return NULL;
+			return ERR_PTR(-ENOMEM);
 		}
 	} else {
 		/* integrity only: all headers + data authenticated */
@@ -921,14 +921,14 @@ static struct sk_buff *macsec_decrypt(struct sk_buff *skb,
 	dev_hold(dev);
 	ret = crypto_aead_decrypt(req);
 	if (ret == -EINPROGRESS) {
-		return NULL;
+		return ERR_PTR(ret);
 	} else if (ret != 0) {
 		/* decryption/authentication failed
 		 * 10.6 if validateFrames is disabled, deliver anyway
 		 */
 		if (ret != -EBADMSG) {
 			kfree_skb(skb);
-			skb = NULL;
+			skb = ERR_PTR(ret);
 		}
 	} else {
 		macsec_skb_cb(skb)->valid = true;
@@ -1146,8 +1146,10 @@ static rx_handler_result_t macsec_handle_frame(struct sk_buff **pskb)
 	    secy->validate_frames != MACSEC_VALIDATE_DISABLED)
 		skb = macsec_decrypt(skb, dev, rx_sa, sci, secy);
 
-	if (!skb) {
-		macsec_rxsa_put(rx_sa);
+	if (IS_ERR(skb)) {
+		/* the decrypt callback needs the reference */
+		if (PTR_ERR(skb) != -EINPROGRESS)
+			macsec_rxsa_put(rx_sa);
 		rcu_read_unlock();
 		*pskb = NULL;
 		return RX_HANDLER_CONSUMED;
-- 
2.8.0
