From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH v5 4/5] macsec: check return value of skb_to_sgvec always
Date: Tue, 25 Apr 2017 17:52:14 +0200
Message-ID: <20170425155215.4835-4-Jason@zx2c4.com>
References: <20170425.111717.1973239615715123840.davem@davemloft.net>
 <20170425155215.4835-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	David.Laight@aculab.com,
	kernel-hardening@lists.openwall.com,
	davem@davemloft.net
Return-path: <kernel-hardening-return-7568-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170425155215.4835-1-Jason@zx2c4.com>
List-Id: netdev.vger.kernel.org

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
 drivers/net/macsec.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index dbab05afcdbe..d846f42b99ec 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -733,7 +733,12 @@ static struct sk_buff *macsec_encrypt(struct sk_buff *skb,
 	macsec_fill_iv(iv, secy->sci, pn);
 
 	sg_init_table(sg, MAX_SKB_FRAGS + 1);
-	skb_to_sgvec(skb, sg, 0, skb->len);
+	ret = skb_to_sgvec(skb, sg, 0, skb->len);
+	if (unlikely(ret < 0)) {
+		macsec_txsa_put(tx_sa);
+		kfree_skb(skb);
+		return ERR_PTR(ret);
+	}
 
 	if (tx_sc->encrypt) {
 		int len = skb->len - macsec_hdr_len(sci_present) -
@@ -937,7 +942,11 @@ static struct sk_buff *macsec_decrypt(struct sk_buff *skb,
 	macsec_fill_iv(iv, sci, ntohl(hdr->packet_number));
 
 	sg_init_table(sg, MAX_SKB_FRAGS + 1);
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
