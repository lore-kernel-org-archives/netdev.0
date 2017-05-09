From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v7 4/5] macsec: check return value of skb_to_sgvec always
Date: Tue,  9 May 2017 15:50:08 +0200
Message-ID: <20170509135009.13751-5-Jason@zx2c4.com>
References: <20170509135009.13751-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	davem@davemloft.net,
	kernel-hardening@lists.openwall.com
Return-path: <kernel-hardening-return-7784-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170509135009.13751-1-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/macsec.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 49ce4e9f4a0f..e022e3fcd012 100644
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
2.12.2
