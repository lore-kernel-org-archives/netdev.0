From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH 2/2] chacha20poly1305: Skip encryption/decryption for 0-len
Date: Sun,  6 Dec 2015 02:51:38 +0100
Message-ID: <1449366698-2422-2-git-send-email-Jason@zx2c4.com>
References: <1449366698-2422-1-git-send-email-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>, stable@vger.kernel.org
To: herbert@gondor.apana.org.au, davem@davemloft.net,
	linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	Netdev <netdev@vger.kernel.org>, martin@strongswan.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:40064 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752756AbbLFBv7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Dec 2015 20:51:59 -0500
In-Reply-To: <1449366698-2422-1-git-send-email-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the length of the plaintext is zero, there's no need to waste cycles
on encryption and decryption. Using the chacha20poly1305 construction
for zero-length plaintexts is a common way of using a shared encryption
key for AAD authentication.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: <stable@vger.kernel.org>
---
 crypto/chacha20poly1305.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/crypto/chacha20poly1305.c b/crypto/chacha20poly1305.c
index 99c3cce..7b6b935 100644
--- a/crypto/chacha20poly1305.c
+++ b/crypto/chacha20poly1305.c
@@ -130,6 +130,9 @@ static int chacha_decrypt(struct aead_request *req)
 	struct scatterlist *src, *dst;
 	int err;
 
+	if (rctx->cryptlen == 0)
+		goto skip;
+
 	chacha_iv(creq->iv, req, 1);
 
 	sg_init_table(rctx->src, 2);
@@ -150,6 +153,7 @@ static int chacha_decrypt(struct aead_request *req)
 	if (err)
 		return err;
 
+skip:
 	return poly_verify_tag(req);
 }
 
@@ -415,6 +419,9 @@ static int chacha_encrypt(struct aead_request *req)
 	struct scatterlist *src, *dst;
 	int err;
 
+	if (req->cryptlen == 0)
+		goto skip;
+
 	chacha_iv(creq->iv, req, 1);
 
 	sg_init_table(rctx->src, 2);
@@ -435,6 +442,7 @@ static int chacha_encrypt(struct aead_request *req)
 	if (err)
 		return err;
 
+skip:
 	return poly_genkey(req);
 }
 
-- 
2.6.3
