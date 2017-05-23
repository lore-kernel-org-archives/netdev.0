From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH net-next v9 4/5] macsec: check return value of skb_to_sgvec always
Date: Tue, 23 May 2017 18:05:49 +0200
Message-ID: <20170523160550.5203-5-Jason@zx2c4.com>
References: <20170523160550.5203-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:49509 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935857AbdEWQGN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 12:06:13 -0400
In-Reply-To: <20170523160550.5203-1-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/macsec.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index cdc347be68f2..dfcb1e9d2ab2 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -742,7 +742,12 @@ static struct sk_buff *macsec_encrypt(struct sk_buff *skb,
 	macsec_fill_iv(iv, secy->sci, pn);
 
 	sg_init_table(sg, ret);
-	skb_to_sgvec(skb, sg, 0, skb->len);
+	ret = skb_to_sgvec(skb, sg, 0, skb->len);
+	if (unlikely(ret < 0)) {
+		macsec_txsa_put(tx_sa);
+		kfree_skb(skb);
+		return ERR_PTR(ret);
+	}
 
 	if (tx_sc->encrypt) {
 		int len = skb->len - macsec_hdr_len(sci_present) -
@@ -952,7 +957,11 @@ static struct sk_buff *macsec_decrypt(struct sk_buff *skb,
 	macsec_fill_iv(iv, sci, ntohl(hdr->packet_number));
 
 	sg_init_table(sg, ret);
-	skb_to_sgvec(skb, sg, 0, skb->len);
+	ret = skb_to_sgvec(skb, sg, 0, skb->len);
+	if (unlikely(ret < 0)) {
+		kfree_skb(skb);
+		return ERR_PTR(ret);
+	}
 
 	if (hdr->tci_an & MACSEC_TCI_E) {
 		/* confidentiality: ethernet + macsec header
-- 
2.13.0
