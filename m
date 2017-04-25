From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] macsec: avoid heap overflow in skb_to_sgvec on receive
Date: Tue, 25 Apr 2017 17:19:13 +0200
Message-ID: <f50ef5b9e525d83938f5e419557abb0307ee023b.1493133423.git.sd@queasysnail.net>
Cc: Sabrina Dubroca <sd@queasysnail.net>,
        "Jason A. Donenfeld" <Jason@zx2c4.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2162 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1948906AbdDYPUH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 11:20:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The previous fix for this issue, commit 4d6fa57b4dab ("macsec: avoid
heap overflow in skb_to_sgvec"), doesn't really fix much. It removed the
NETIF_F_FRAGLIST flag from MACsec device features, but this flag isn't
checked anywhere in the codepaths leading to a macsec_decrypt() call.

On TX, macsec could already handle a frag_list because an skb with a
frag_list will get linearized in skb_copy_expand() since it lacks the
necessary tailroom. Removing the NETIF_F_FRAGLIST makes sure
macsec_encrypt() will never see a frag_list.

On RX, we can simply get the number of necessary scatterlist items by
calling skb_cow_data().

Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
Fixes: CVE-2017-7477
Reported-by: "Jason A. Donenfeld" <Jason@zx2c4.com>
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/macsec.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index dbab05afcdbe..c9cc40d2349c 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -617,7 +617,8 @@ static void macsec_encrypt_done(struct crypto_async_request *base, int err)
 
 static struct aead_request *macsec_alloc_req(struct crypto_aead *tfm,
 					     unsigned char **iv,
-					     struct scatterlist **sg)
+					     struct scatterlist **sg,
+					     int nfrags)
 {
 	size_t size, iv_offset, sg_offset;
 	struct aead_request *req;
@@ -629,7 +630,7 @@ static struct aead_request *macsec_alloc_req(struct crypto_aead *tfm,
 
 	size = ALIGN(size, __alignof__(struct scatterlist));
 	sg_offset = size;
-	size += sizeof(struct scatterlist) * (MAX_SKB_FRAGS + 1);
+	size += sizeof(struct scatterlist) * nfrags;
 
 	tmp = kmalloc(size, GFP_ATOMIC);
 	if (!tmp)
@@ -723,7 +724,7 @@ static struct sk_buff *macsec_encrypt(struct sk_buff *skb,
 		return ERR_PTR(-EINVAL);
 	}
 
-	req = macsec_alloc_req(tx_sa->key.tfm, &iv, &sg);
+	req = macsec_alloc_req(tx_sa->key.tfm, &iv, &sg, MAX_SKB_FRAGS + 1);
 	if (!req) {
 		macsec_txsa_put(tx_sa);
 		kfree_skb(skb);
@@ -921,13 +922,21 @@ static struct sk_buff *macsec_decrypt(struct sk_buff *skb,
 	struct aead_request *req;
 	struct macsec_eth_header *hdr;
 	u16 icv_len = secy->icv_len;
+	struct sk_buff *trailer;
+	int nfrags;
 
 	macsec_skb_cb(skb)->valid = false;
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (!skb)
 		return ERR_PTR(-ENOMEM);
 
-	req = macsec_alloc_req(rx_sa->key.tfm, &iv, &sg);
+	nfrags = skb_cow_data(skb, 0, &trailer);
+	if (nfrags < 0) {
+		kfree_skb(skb);
+		return ERR_PTR(nfrags);
+	}
+
+	req = macsec_alloc_req(rx_sa->key.tfm, &iv, &sg, nfrags);
 	if (!req) {
 		kfree_skb(skb);
 		return ERR_PTR(-ENOMEM);
@@ -936,7 +945,7 @@ static struct sk_buff *macsec_decrypt(struct sk_buff *skb,
 	hdr = (struct macsec_eth_header *)skb->data;
 	macsec_fill_iv(iv, sci, ntohl(hdr->packet_number));
 
-	sg_init_table(sg, MAX_SKB_FRAGS + 1);
+	sg_init_table(sg, nfrags);
 	skb_to_sgvec(skb, sg, 0, skb->len);
 
 	if (hdr->tci_an & MACSEC_TCI_E) {
-- 
2.12.2
