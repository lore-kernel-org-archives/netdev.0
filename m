From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v2 PATCH 13/13] crypto: algif_aead - Switch to new AEAD
 interface
Date: Sat, 23 May 2015 05:58:18 +0800
Message-ID: <20150522215818.GB11512@gondor.apana.org.au>
References: <20150522082708.GA3507@gondor.apana.org.au>
 <E1YviMC-00010E-Uk@gondolin.me.apana.org.au>
 <1711949.C5mmxUsD4a@myon.chronox.de>
 <13023896.hEcYqcIc2j@myon.chronox.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Stephan Mueller <smueller@chronox.de>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <13023896.hEcYqcIc2j@myon.chronox.de>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 22, 2015 at 11:04:39PM +0200, Stephan Mueller wrote:
>
> Note, gcm(aes) looks good. Only rfc4106(gcm(aes)) causes the crash.

Actually it looks like the culprit hasn't been merged yet so I'll
just respin the series.

Anyway, this patch should fix your crash:

diff --git a/crypto/ablkcipher.c b/crypto/ablkcipher.c
index b3dded4..b15d797 100644
--- a/crypto/ablkcipher.c
+++ b/crypto/ablkcipher.c
@@ -586,6 +586,13 @@ static int crypto_givcipher_default(struct crypto_alg *alg, u32 type, u32 mask)
 	if (!tmpl)
 		goto kill_larval;
 
+	if (tmpl->create) {
+		err = tmpl->create(tmpl, tb);
+		if (err)
+			goto put_tmpl;
+		goto ok;
+	}
+
 	inst = tmpl->alloc(tb);
 	err = PTR_ERR(inst);
 	if (IS_ERR(inst))
@@ -597,6 +604,7 @@ static int crypto_givcipher_default(struct crypto_alg *alg, u32 type, u32 mask)
 		goto put_tmpl;
 	}
 
+ok:
 	/* Redo the lookup to use the instance we just registered. */
 	err = -EAGAIN;
 
diff --git a/crypto/aead.c b/crypto/aead.c
index 8b26613..070e4b9 100644
--- a/crypto/aead.c
+++ b/crypto/aead.c
@@ -570,6 +570,13 @@ static int crypto_nivaead_default(struct crypto_alg *alg, u32 type, u32 mask)
 	if (!tmpl)
 		goto kill_larval;
 
+	if (tmpl->create) {
+		err = tmpl->create(tmpl, tb);
+		if (err)
+			goto put_tmpl;
+		goto ok;
+	}
+
 	inst = tmpl->alloc(tb);
 	err = PTR_ERR(inst);
 	if (IS_ERR(inst))
@@ -581,6 +588,7 @@ static int crypto_nivaead_default(struct crypto_alg *alg, u32 type, u32 mask)
 		goto put_tmpl;
 	}
 
+ok:
 	/* Redo the lookup to use the instance we just registered. */
 	err = -EAGAIN;
 
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
