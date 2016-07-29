From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net 1/3] macsec: fix reference counting on RXSC in macsec_handle_frame
Date: Fri, 29 Jul 2016 15:37:53 +0200
Message-ID: <caa97dd1b5e36da4ffce0ff29a58a3091be443bc.1469782905.git.sd@queasysnail.net>
References: <cover.1469782905.git.sd@queasysnail.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36378 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751694AbcG2NiH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2016 09:38:07 -0400
In-Reply-To: <cover.1469782905.git.sd@queasysnail.net>
In-Reply-To: <cover.1469782905.git.sd@queasysnail.net>
References: <cover.1469782905.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we lookup the RXSC without taking a reference on it.  The
RXSA holds a reference on the RXSC, but the SA and SC could still both
disappear before we take a reference on the SA.

Take a reference on the RXSC in macsec_handle_frame.

Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/macsec.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 2d0beb1b801c..718cf98023ff 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -863,6 +863,7 @@ static void macsec_decrypt_done(struct crypto_async_request *base, int err)
 	struct net_device *dev = skb->dev;
 	struct macsec_dev *macsec = macsec_priv(dev);
 	struct macsec_rx_sa *rx_sa = macsec_skb_cb(skb)->rx_sa;
+	struct macsec_rx_sc *rx_sc = rx_sa->sc;
 	int len, ret;
 	u32 pn;
 
@@ -891,6 +892,7 @@ static void macsec_decrypt_done(struct crypto_async_request *base, int err)
 
 out:
 	macsec_rxsa_put(rx_sa);
+	macsec_rxsc_put(rx_sc);
 	dev_put(dev);
 }
 
@@ -1106,6 +1108,7 @@ static rx_handler_result_t macsec_handle_frame(struct sk_buff **pskb)
 
 	list_for_each_entry_rcu(macsec, &rxd->secys, secys) {
 		struct macsec_rx_sc *sc = find_rx_sc(&macsec->secy, sci);
+		sc = sc ? macsec_rxsc_get(sc) : NULL;
 
 		if (sc) {
 			secy = &macsec->secy;
@@ -1180,8 +1183,10 @@ static rx_handler_result_t macsec_handle_frame(struct sk_buff **pskb)
 
 	if (IS_ERR(skb)) {
 		/* the decrypt callback needs the reference */
-		if (PTR_ERR(skb) != -EINPROGRESS)
+		if (PTR_ERR(skb) != -EINPROGRESS) {
 			macsec_rxsa_put(rx_sa);
+			macsec_rxsc_put(rx_sc);
+		}
 		rcu_read_unlock();
 		*pskb = NULL;
 		return RX_HANDLER_CONSUMED;
@@ -1197,6 +1202,7 @@ deliver:
 
 	if (rx_sa)
 		macsec_rxsa_put(rx_sa);
+	macsec_rxsc_put(rx_sc);
 
 	ret = gro_cells_receive(&macsec->gro_cells, skb);
 	if (ret == NET_RX_SUCCESS)
@@ -1212,6 +1218,7 @@ deliver:
 drop:
 	macsec_rxsa_put(rx_sa);
 drop_nosa:
+	macsec_rxsc_put(rx_sc);
 	rcu_read_unlock();
 drop_direct:
 	kfree_skb(skb);
-- 
2.9.0
