From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [v3 PATCH 6/8] mac802154: Switch to new AEAD interface
Date: Wed, 27 May 2015 16:03:48 +0800
Message-ID: <E1YxWJY-0006zp-WF@gondolin.me.apana.org.au>
References: <20150527080105.GA26751@gondor.apana.org.au>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Stephan Mueller <smueller@chronox.de>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes use of the new AEAD interface which uses a single
SG list instead of separate lists for the AD and plain text.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/mac802154/llsec.c |   41 ++++++++++++++---------------------------
 1 file changed, 14 insertions(+), 27 deletions(-)

diff --git a/net/mac802154/llsec.c b/net/mac802154/llsec.c
index 3ccf1e9..5210841 100644
--- a/net/mac802154/llsec.c
+++ b/net/mac802154/llsec.c
@@ -650,7 +650,7 @@ llsec_do_encrypt_auth(struct sk_buff *skb, const struct mac802154_llsec *sec,
 	u8 iv[16];
 	unsigned char *data;
 	int authlen, assoclen, datalen, rc;
-	struct scatterlist src, assoc[2], dst[2];
+	struct scatterlist sg;
 	struct aead_request *req;
 
 	authlen = ieee802154_sechdr_authtag_len(&hdr->sec);
@@ -660,30 +660,23 @@ llsec_do_encrypt_auth(struct sk_buff *skb, const struct mac802154_llsec *sec,
 	if (!req)
 		return -ENOMEM;
 
-	sg_init_table(assoc, 2);
-	sg_set_buf(&assoc[0], skb_mac_header(skb), skb->mac_len);
 	assoclen = skb->mac_len;
 
 	data = skb_mac_header(skb) + skb->mac_len;
 	datalen = skb_tail_pointer(skb) - data;
 
-	if (hdr->sec.level & IEEE802154_SCF_SECLEVEL_ENC) {
-		sg_set_buf(&assoc[1], data, 0);
-	} else {
-		sg_set_buf(&assoc[1], data, datalen);
+	skb_put(skb, authlen);
+
+	sg_init_one(&sg, skb_mac_header(skb), assoclen + datalen + authlen);
+
+	if (!(hdr->sec.level & IEEE802154_SCF_SECLEVEL_ENC)) {
 		assoclen += datalen;
 		datalen = 0;
 	}
 
-	sg_init_one(&src, data, datalen);
-
-	sg_init_table(dst, 2);
-	sg_set_buf(&dst[0], data, datalen);
-	sg_set_buf(&dst[1], skb_put(skb, authlen), authlen);
-
 	aead_request_set_callback(req, 0, NULL, NULL);
-	aead_request_set_assoc(req, assoc, assoclen);
-	aead_request_set_crypt(req, &src, dst, datalen, iv);
+	aead_request_set_crypt(req, &sg, &sg, datalen, iv);
+	aead_request_set_ad(req, assoclen);
 
 	rc = crypto_aead_encrypt(req);
 
@@ -859,7 +852,7 @@ llsec_do_decrypt_auth(struct sk_buff *skb, const struct mac802154_llsec *sec,
 	u8 iv[16];
 	unsigned char *data;
 	int authlen, datalen, assoclen, rc;
-	struct scatterlist src, assoc[2];
+	struct scatterlist sg;
 	struct aead_request *req;
 
 	authlen = ieee802154_sechdr_authtag_len(&hdr->sec);
@@ -869,27 +862,21 @@ llsec_do_decrypt_auth(struct sk_buff *skb, const struct mac802154_llsec *sec,
 	if (!req)
 		return -ENOMEM;
 
-	sg_init_table(assoc, 2);
-	sg_set_buf(&assoc[0], skb_mac_header(skb), skb->mac_len);
 	assoclen = skb->mac_len;
 
 	data = skb_mac_header(skb) + skb->mac_len;
 	datalen = skb_tail_pointer(skb) - data;
 
-	if (hdr->sec.level & IEEE802154_SCF_SECLEVEL_ENC) {
-		sg_set_buf(&assoc[1], data, 0);
-	} else {
-		sg_set_buf(&assoc[1], data, datalen - authlen);
+	sg_init_one(&sg, skb_mac_header(skb), assoclen + datalen);
+
+	if (!(hdr->sec.level & IEEE802154_SCF_SECLEVEL_ENC)) {
 		assoclen += datalen - authlen;
-		data += datalen - authlen;
 		datalen = authlen;
 	}
 
-	sg_init_one(&src, data, datalen);
-
 	aead_request_set_callback(req, 0, NULL, NULL);
-	aead_request_set_assoc(req, assoc, assoclen);
-	aead_request_set_crypt(req, &src, &src, datalen, iv);
+	aead_request_set_crypt(req, &sg, &sg, datalen, iv);
+	aead_request_set_ad(req, assoclen);
 
 	rc = crypto_aead_decrypt(req);
 
