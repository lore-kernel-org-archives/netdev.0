From: Martin Willi <martin@strongswan.org>
Subject: [PATCH 2/5] xfrm: Remove unused ESP padlen field
Date: Tue, 30 Nov 2010 16:49:12 +0100
Message-ID: <1291132155-31277-3-git-send-email-martin@strongswan.org>
References: <1291132155-31277-1-git-send-email-martin@strongswan.org>
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zaes.ch ([213.133.111.41]:38103 "EHLO zaes.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753863Ab0K3QbH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Nov 2010 11:31:07 -0500
In-Reply-To: <1291132155-31277-1-git-send-email-martin@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The padlen field in IPv4/6 ESP is used to align the ESP padding length
to a value larger than the aead block size. There is however no
option to set this field, hence it is removed.

Signed-off-by: Martin Willi <martin@strongswan.org>
---
 include/net/esp.h |    3 ---
 net/ipv4/esp4.c   |   11 ++---------
 net/ipv6/esp6.c   |   11 ++---------
 3 files changed, 4 insertions(+), 21 deletions(-)

diff --git a/include/net/esp.h b/include/net/esp.h
index d584513..6dfb4d0 100644
--- a/include/net/esp.h
+++ b/include/net/esp.h
@@ -6,9 +6,6 @@
 struct crypto_aead;
 
 struct esp_data {
-	/* 0..255 */
-	int padlen;
-
 	/* Confidentiality & Integrity */
 	struct crypto_aead *aead;
 };
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 14ca1f1..67e4c12 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -132,8 +132,6 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	blksize = ALIGN(crypto_aead_blocksize(aead), 4);
 	clen = ALIGN(clen + 2, blksize);
-	if (esp->padlen)
-		clen = ALIGN(clen, esp->padlen);
 
 	if ((err = skb_cow_data(skb, clen - skb->len + alen, &trailer)) < 0)
 		goto error;
@@ -386,12 +384,11 @@ static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
 {
 	struct esp_data *esp = x->data;
 	u32 blksize = ALIGN(crypto_aead_blocksize(esp->aead), 4);
-	u32 align = max_t(u32, blksize, esp->padlen);
 	u32 rem;
 
 	mtu -= x->props.header_len + crypto_aead_authsize(esp->aead);
-	rem = mtu & (align - 1);
-	mtu &= ~(align - 1);
+	rem = mtu & (blksize - 1);
+	mtu &= ~(blksize - 1);
 
 	switch (x->props.mode) {
 	case XFRM_MODE_TUNNEL:
@@ -570,8 +567,6 @@ static int esp_init_state(struct xfrm_state *x)
 
 	aead = esp->aead;
 
-	esp->padlen = 0;
-
 	x->props.header_len = sizeof(struct ip_esp_hdr) +
 			      crypto_aead_ivsize(aead);
 	if (x->props.mode == XFRM_MODE_TUNNEL)
@@ -594,8 +589,6 @@ static int esp_init_state(struct xfrm_state *x)
 	}
 
 	align = ALIGN(crypto_aead_blocksize(aead), 4);
-	if (esp->padlen)
-		align = max_t(u32, align, esp->padlen);
 	x->props.trailer_len = align + 1 + crypto_aead_authsize(esp->aead);
 
 error:
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index ee9b93b..e9e6e1c 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -156,8 +156,6 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	blksize = ALIGN(crypto_aead_blocksize(aead), 4);
 	clen = ALIGN(clen + 2, blksize);
-	if (esp->padlen)
-		clen = ALIGN(clen, esp->padlen);
 
 	if ((err = skb_cow_data(skb, clen - skb->len + alen, &trailer)) < 0)
 		goto error;
@@ -337,12 +335,11 @@ static u32 esp6_get_mtu(struct xfrm_state *x, int mtu)
 {
 	struct esp_data *esp = x->data;
 	u32 blksize = ALIGN(crypto_aead_blocksize(esp->aead), 4);
-	u32 align = max_t(u32, blksize, esp->padlen);
 	u32 rem;
 
 	mtu -= x->props.header_len + crypto_aead_authsize(esp->aead);
-	rem = mtu & (align - 1);
-	mtu &= ~(align - 1);
+	rem = mtu & (blksize - 1);
+	mtu &= ~(blksize - 1);
 
 	if (x->props.mode != XFRM_MODE_TUNNEL) {
 		u32 padsize = ((blksize - 1) & 7) + 1;
@@ -516,8 +513,6 @@ static int esp6_init_state(struct xfrm_state *x)
 
 	aead = esp->aead;
 
-	esp->padlen = 0;
-
 	x->props.header_len = sizeof(struct ip_esp_hdr) +
 			      crypto_aead_ivsize(aead);
 	switch (x->props.mode) {
@@ -536,8 +531,6 @@ static int esp6_init_state(struct xfrm_state *x)
 	}
 
 	align = ALIGN(crypto_aead_blocksize(aead), 4);
-	if (esp->padlen)
-		align = max_t(u32, align, esp->padlen);
 	x->props.trailer_len = align + 1 + crypto_aead_authsize(esp->aead);
 
 error:
-- 
1.7.1

