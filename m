From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net 2/3] macsec: allocate sg and iv on the heap
Date: Tue, 14 Jun 2016 15:25:15 +0200
Message-ID: <da30e15d4c309ed7b598b6d0eb12be0436d461a8.1465908271.git.sd@queasysnail.net>
References: <cover.1465908271.git.sd@queasysnail.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43786 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752596AbcFNNZZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 09:25:25 -0400
In-Reply-To: <cover.1465908271.git.sd@queasysnail.net>
In-Reply-To: <cover.1465908271.git.sd@queasysnail.net>
References: <cover.1465908271.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the crypto callbacks to work properly, we cannot have sg and iv on
the stack.  Use kmalloc instead, with a single allocation for
aead_request + scatterlist + iv.

Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/macsec.c | 46 +++++++++++++++++++++++++++++++++++++---------
 1 file changed, 37 insertions(+), 9 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index e80736f6acd7..189ea3e8e8a0 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -605,12 +605,41 @@ static void macsec_encrypt_done(struct crypto_async_request *base, int err)
 	dev_put(dev);
 }
 
+static struct aead_request *macsec_alloc_req(struct crypto_aead *tfm,
+					     unsigned char **iv,
+					     struct scatterlist **sg)
+{
+	size_t size, iv_offset, sg_offset;
+	struct aead_request *req;
+	void *tmp;
+
+	size = sizeof(struct aead_request) + crypto_aead_reqsize(tfm);
+	iv_offset = size;
+	size += GCM_AES_IV_LEN;
+
+	size = ALIGN(size, __alignof__(struct scatterlist));
+	sg_offset = size;
+	size += sizeof(struct scatterlist) * (MAX_SKB_FRAGS + 1);
+
+	tmp = kmalloc(size, GFP_ATOMIC);
+	if (!tmp)
+		return NULL;
+
+	*iv = (unsigned char *)(tmp + iv_offset);
+	*sg = (struct scatterlist *)(tmp + sg_offset);
+	req = tmp;
+
+	aead_request_set_tfm(req, tfm);
+
+	return req;
+}
+
 static struct sk_buff *macsec_encrypt(struct sk_buff *skb,
 				      struct net_device *dev)
 {
 	int ret;
-	struct scatterlist sg[MAX_SKB_FRAGS + 1];
-	unsigned char iv[GCM_AES_IV_LEN];
+	struct scatterlist *sg;
+	unsigned char *iv;
 	struct ethhdr *eth;
 	struct macsec_eth_header *hh;
 	size_t unprotected_len;
@@ -668,8 +697,6 @@ static struct sk_buff *macsec_encrypt(struct sk_buff *skb,
 	macsec_fill_sectag(hh, secy, pn);
 	macsec_set_shortlen(hh, unprotected_len - 2 * ETH_ALEN);
 
-	macsec_fill_iv(iv, secy->sci, pn);
-
 	skb_put(skb, secy->icv_len);
 
 	if (skb->len - ETH_HLEN > macsec_priv(dev)->real_dev->mtu) {
@@ -684,13 +711,15 @@ static struct sk_buff *macsec_encrypt(struct sk_buff *skb,
 		return ERR_PTR(-EINVAL);
 	}
 
-	req = aead_request_alloc(tx_sa->key.tfm, GFP_ATOMIC);
+	req = macsec_alloc_req(tx_sa->key.tfm, &iv, &sg);
 	if (!req) {
 		macsec_txsa_put(tx_sa);
 		kfree_skb(skb);
 		return ERR_PTR(-ENOMEM);
 	}
 
+	macsec_fill_iv(iv, secy->sci, pn);
+
 	sg_init_table(sg, MAX_SKB_FRAGS + 1);
 	skb_to_sgvec(skb, sg, 0, skb->len);
 
@@ -861,7 +890,6 @@ static void macsec_decrypt_done(struct crypto_async_request *base, int err)
 out:
 	macsec_rxsa_put(rx_sa);
 	dev_put(dev);
-	return;
 }
 
 static struct sk_buff *macsec_decrypt(struct sk_buff *skb,
@@ -871,8 +899,8 @@ static struct sk_buff *macsec_decrypt(struct sk_buff *skb,
 				      struct macsec_secy *secy)
 {
 	int ret;
-	struct scatterlist sg[MAX_SKB_FRAGS + 1];
-	unsigned char iv[GCM_AES_IV_LEN];
+	struct scatterlist *sg;
+	unsigned char *iv;
 	struct aead_request *req;
 	struct macsec_eth_header *hdr;
 	u16 icv_len = secy->icv_len;
@@ -882,7 +910,7 @@ static struct sk_buff *macsec_decrypt(struct sk_buff *skb,
 	if (!skb)
 		return ERR_PTR(-ENOMEM);
 
-	req = aead_request_alloc(rx_sa->key.tfm, GFP_ATOMIC);
+	req = macsec_alloc_req(rx_sa->key.tfm, &iv, &sg);
 	if (!req) {
 		kfree_skb(skb);
 		return ERR_PTR(-ENOMEM);
-- 
2.8.3
