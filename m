From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 12/13] crypto: Make the page handling of hash walk compatible to networking.
Date: Thu, 4 Feb 2016 07:37:05 +0100
Message-ID: <1454567826-13018-13-git-send-email-steffen.klassert@secunet.com>
References: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	<sowmini.varadhan@oracle.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36665 "EHLO
	h-62.96.220.36.host.de.colt.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752866AbcBDHFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 02:05:48 -0500
In-Reply-To: <1454567826-13018-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The network layer tries to allocate high order pages for skb_buff
fragments, this leads to problems if we pass such a buffer to
crypto because crypto assumes to have always order null pages
in the scatterlists.

This was not a problem so far, bacause the network stack linearized
all buffers before passing them to crypto. Due to a recent change to
IPsec "esp: Avoid skb_cow_data whenever possible" the linearization
is avoided in most of the cases what made this incompatibility
visible.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 crypto/ahash.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/crypto/ahash.c b/crypto/ahash.c
index d19b523..a0eb4e6 100644
--- a/crypto/ahash.c
+++ b/crypto/ahash.c
@@ -44,8 +44,7 @@ static int hash_walk_next(struct crypto_hash_walk *walk)
 {
 	unsigned int alignmask = walk->alignmask;
 	unsigned int offset = walk->offset;
-	unsigned int nbytes = min(walk->entrylen,
-				  ((unsigned int)(PAGE_SIZE)) - offset);
+	unsigned int nbytes = walk->entrylen;
 
 	if (walk->flags & CRYPTO_ALG_ASYNC)
 		walk->data = kmap(walk->pg);
@@ -91,8 +90,6 @@ int crypto_hash_walk_done(struct crypto_hash_walk *walk, int err)
 		walk->offset = ALIGN(walk->offset, alignmask + 1);
 		walk->data += walk->offset;
 
-		nbytes = min(nbytes,
-			     ((unsigned int)(PAGE_SIZE)) - walk->offset);
 		walk->entrylen -= nbytes;
 
 		return nbytes;
-- 
1.9.1
