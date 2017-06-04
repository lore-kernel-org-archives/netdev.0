From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH net-next v10 4/5] macsec: check return value of skb_to_sgvec always
Date: Sun,  4 Jun 2017 04:16:25 +0200
Message-ID: <20170604021626.11968-5-Jason@zx2c4.com>
References: <20170604021626.11968-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, kernel-hardening@lists.openwall.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170604021626.11968-1-Jason@zx2c4.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/macsec.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 91642fd87cd1..b79513b8322f 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -740,7 +740,12 @@ static struct sk_buff *macsec_encrypt(struct sk_buff *skb,
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
@@ -947,7 +952,11 @@ static struct sk_buff *macsec_decrypt(struct sk_buff *skb,
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
