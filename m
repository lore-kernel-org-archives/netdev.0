From: Martin Willi <martin@strongswan.org>
Subject: [PATCH 4/5] xfrm: Traffic Flow Confidentiality for IPv6 ESP
Date: Tue, 30 Nov 2010 16:49:14 +0100
Message-ID: <1291132155-31277-5-git-send-email-martin@strongswan.org>
References: <1291132155-31277-1-git-send-email-martin@strongswan.org>
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zaes.ch ([213.133.111.41]:38105 "EHLO zaes.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753863Ab0K3QbK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Nov 2010 11:31:10 -0500
In-Reply-To: <1291132155-31277-1-git-send-email-martin@strongswan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If configured on xfrm state, increase the length of all packets to
a given boundary using TFC padding as specified in RFC4303. For
transport mode, or if the XFRM_TFC_ESPV3 is not set, grow the ESP
padding field instead.

Signed-off-by: Martin Willi <martin@strongswan.org>
---
 net/ipv6/esp6.c |   42 +++++++++++++++++++++++++++++++++---------
 1 files changed, 33 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index e9e6e1c..9494cb1 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -140,6 +140,9 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	int blksize;
 	int clen;
 	int alen;
+	int plen;
+	int tfclen;
+	int tfcpadto;
 	int nfrags;
 	u8 *iv;
 	u8 *tail;
@@ -148,16 +151,33 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	/* skb is pure payload to encrypt */
 	err = -ENOMEM;
 
-	/* Round to block size */
-	clen = skb->len;
-
 	aead = esp->aead;
 	alen = crypto_aead_authsize(aead);
 
 	blksize = ALIGN(crypto_aead_blocksize(aead), 4);
-	clen = ALIGN(clen + 2, blksize);
-
-	if ((err = skb_cow_data(skb, clen - skb->len + alen, &trailer)) < 0)
+	tfclen = 0;
+	tfcpadto = x->tfc.pad;
+
+	if (skb->len >= tfcpadto) {
+		clen = ALIGN(skb->len + 2, blksize);
+	} else if (x->tfc.flags & XFRM_TFC_ESPV3 &&
+		   x->props.mode == XFRM_MODE_TUNNEL) {
+		/* ESPv3 TFC padding, append bytes to payload */
+		tfclen = tfcpadto - skb->len;
+		clen = ALIGN(skb->len + 2 + tfclen, blksize);
+	} else {
+		/* ESPv2 TFC padding. If we exceed the 255 byte maximum, use
+		 * random padding to hide payload length as good as possible. */
+		clen = ALIGN(skb->len + 2 + tfcpadto - skb->len, blksize);
+		if (clen - skb->len - 2 > 255) {
+			clen = ALIGN(skb->len + (u8)random32() + 2, blksize);
+			if (clen - skb->len - 2 > 255)
+				clen -= blksize;
+		}
+	}
+	plen = clen - skb->len - tfclen;
+	err = skb_cow_data(skb, tfclen + plen + alen, &trailer);
+	if (err < 0)
 		goto error;
 	nfrags = err;
 
@@ -172,13 +192,17 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	/* Fill padding... */
 	tail = skb_tail_pointer(trailer);
+	if (tfclen) {
+		memset(tail, 0, tfclen);
+		tail += tfclen;
+	}
 	do {
 		int i;
-		for (i=0; i<clen-skb->len - 2; i++)
+		for (i = 0; i < plen - 2; i++)
 			tail[i] = i + 1;
 	} while (0);
-	tail[clen-skb->len - 2] = (clen - skb->len) - 2;
-	tail[clen - skb->len - 1] = *skb_mac_header(skb);
+	tail[plen - 2] = plen - 2;
+	tail[plen - 1] = *skb_mac_header(skb);
 	pskb_put(skb, trailer, clen - skb->len + alen);
 
 	skb_push(skb, -skb_network_offset(skb));
-- 
1.7.1

