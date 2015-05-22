From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 7/7] mac80211: Switch to new AEAD interface
Date: Fri, 22 May 2015 16:05:39 +0800
Message-ID: <20150522080539.GA3194@gondor.apana.org.au>
References: <20150521103938.GA23035@gondor.apana.org.au>
 <E1YvNxS-00063i-AZ@gondolin.me.apana.org.au>
 <1432279948.3493.2.camel@sipsolutions.net>
 <20150522074126.GA2921@gondor.apana.org.au>
 <1432280608.3493.4.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1432280608.3493.4.camel@sipsolutions.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 22, 2015 at 09:43:28AM +0200, Johannes Berg wrote:
> 
> Oops, sorry, of course - I was running in a VM :)

Thanks!

Does this patch on top help?

diff --git a/net/mac80211/aes_gmac.c b/net/mac80211/aes_gmac.c
index 7eee32b..133be53 100644
--- a/net/mac80211/aes_gmac.c
+++ b/net/mac80211/aes_gmac.c
@@ -24,22 +24,24 @@
 int ieee80211_aes_gmac(struct crypto_aead *tfm, const u8 *aad, u8 *nonce,
 		       const u8 *data, size_t data_len, u8 *mic)
 {
-	struct scatterlist sg[3];
+	struct scatterlist sg[4];
 	char aead_req_data[sizeof(struct aead_request) +
 			   crypto_aead_reqsize(tfm)]
 		__aligned(__alignof__(struct aead_request));
 	struct aead_request *aead_req = (void *)aead_req_data;
-	u8 iv[AES_BLOCK_SIZE];
+	u8 zero[GMAC_MIC_LEN], iv[AES_BLOCK_SIZE];
 
 	if (data_len < GMAC_MIC_LEN)
 		return -EINVAL;
 
 	memset(aead_req, 0, sizeof(aead_req_data));
 
-	sg_init_table(sg, 3);
+	memset(zero, 0, GMAC_MIC_LEN);
+	sg_init_table(sg, 4);
 	sg_set_buf(&sg[0], aad, AAD_LEN);
 	sg_set_buf(&sg[1], data, data_len - GMAC_MIC_LEN);
-	sg_set_buf(&sg[2], mic, GMAC_MIC_LEN);
+	sg_set_buf(&sg[2], zero, GMAC_MIC_LEN);
+	sg_set_buf(&sg[3], mic, GMAC_MIC_LEN);
 
 	memcpy(iv, nonce, GMAC_NONCE_LEN);
 	memset(iv + GMAC_NONCE_LEN, 0, sizeof(iv) - GMAC_NONCE_LEN);
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
