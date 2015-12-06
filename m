From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH 1/2] blkcipher: Copy iv from desc even for 0-len walks
Date: Sun,  6 Dec 2015 02:51:37 +0100
Message-ID: <1449366698-2422-1-git-send-email-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>, stable@vger.kernel.org
To: herbert@gondor.apana.org.au, davem@davemloft.net,
	linux-crypto@vger.kernel.org, linux-kernel@vger.kernel.org,
	Netdev <netdev@vger.kernel.org>, martin@strongswan.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:40064 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752706AbbLFBvz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Dec 2015 20:51:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some ciphers actually support encrypting zero length plaintexts. For
example, many AEAD modes support this. The resulting ciphertext for
those winds up being only the authentication tag, which is a result of
the key, the iv, the additional data, and the fact that the plaintext
had zero length. The blkcipher constructors won't copy the IV to the
right place, however, when using a zero length input, resulting in
some significant problems when ciphers call their initialization
routines, only to find that the ->iv parameter is uninitialized. One
such example of this would be using chacha20poly1305 with a zero length
input, which then calls chacha20, which calls the key setup routine,
which eventually OOPSes due to the uninitialized ->iv member.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
Cc: <stable@vger.kernel.org>
---
 crypto/ablkcipher.c | 2 +-
 crypto/blkcipher.c  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/crypto/ablkcipher.c b/crypto/ablkcipher.c
index b4ffc5b..e5b5721 100644
--- a/crypto/ablkcipher.c
+++ b/crypto/ablkcipher.c
@@ -277,12 +277,12 @@ static int ablkcipher_walk_first(struct ablkcipher_request *req,
 	if (WARN_ON_ONCE(in_irq()))
 		return -EDEADLK;
 
+	walk->iv = req->info;
 	walk->nbytes = walk->total;
 	if (unlikely(!walk->total))
 		return 0;
 
 	walk->iv_buffer = NULL;
-	walk->iv = req->info;
 	if (unlikely(((unsigned long)walk->iv & alignmask))) {
 		int err = ablkcipher_copy_iv(walk, tfm, alignmask);
 
diff --git a/crypto/blkcipher.c b/crypto/blkcipher.c
index 11b9814..8cc1622 100644
--- a/crypto/blkcipher.c
+++ b/crypto/blkcipher.c
@@ -326,12 +326,12 @@ static int blkcipher_walk_first(struct blkcipher_desc *desc,
 	if (WARN_ON_ONCE(in_irq()))
 		return -EDEADLK;
 
+	walk->iv = desc->info;
 	walk->nbytes = walk->total;
 	if (unlikely(!walk->total))
 		return 0;
 
 	walk->buffer = NULL;
-	walk->iv = desc->info;
 	if (unlikely(((unsigned long)walk->iv & walk->alignmask))) {
 		int err = blkcipher_copy_iv(walk);
 		if (err)
-- 
2.6.3
