From: Martin Willi <martin@strongswan.org>
Subject: [PATCH 2/3] xfrm: Traffic Flow Confidentiality for IPv4 ESP
Date: Wed,  8 Dec 2010 15:37:50 +0100
Message-ID: <1291819071-17538-3-git-send-email-martin@strongswan.org>
References: <1291819071-17538-1-git-send-email-martin@strongswan.org>
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1291819071-17538-1-git-send-email-martin@strongswan.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add TFC padding to all packets smaller than the boundary configured
on the xfrm state. If the boundary is larger than the PMTU, limit
padding to the PMTU.

Signed-off-by: Martin Willi <martin@strongswan.org>
---
 net/ipv4/esp4.c |   32 ++++++++++++++++++++++++--------
 1 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 14ca1f1..e42a905 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -23,6 +23,8 @@ struct esp_skb_cb {
 
 #define ESP_SKB_CB(__skb) ((struct esp_skb_cb *)&((__skb)->cb[0]))
 
+static u32 esp4_get_mtu(struct xfrm_state *x, int mtu);
+
 /*
  * Allocate an AEAD request structure with extra space for SG and IV.
  *
@@ -117,25 +119,35 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	int blksize;
 	int clen;
 	int alen;
+	int plen;
+	int tfclen;
 	int nfrags;
 
 	/* skb is pure payload to encrypt */
 
 	err = -ENOMEM;
 
-	/* Round to block size */
-	clen = skb->len;
-
 	esp = x->data;
 	aead = esp->aead;
 	alen = crypto_aead_authsize(aead);
 
+	tfclen = 0;
+	if (x->tfcpad) {
+		struct xfrm_dst *dst = (struct xfrm_dst *)skb_dst(skb);
+		u32 padto;
+
+		padto = min(x->tfcpad, esp4_get_mtu(x, dst->child_mtu_cached));
+		if (skb->len < padto)
+			tfclen = padto - skb->len;
+	}
 	blksize = ALIGN(crypto_aead_blocksize(aead), 4);
-	clen = ALIGN(clen + 2, blksize);
+	clen = ALIGN(skb->len + 2 + tfclen, blksize);
 	if (esp->padlen)
 		clen = ALIGN(clen, esp->padlen);
+	plen = clen - skb->len - tfclen;
 
-	if ((err = skb_cow_data(skb, clen - skb->len + alen, &trailer)) < 0)
+	err = skb_cow_data(skb, tfclen + plen + alen, &trailer);
+	if (err < 0)
 		goto error;
 	nfrags = err;
 
@@ -150,13 +162,17 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 
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
-	tail[clen - skb->len - 2] = (clen - skb->len) - 2;
-	tail[clen - skb->len - 1] = *skb_mac_header(skb);
+	tail[plen - 2] = plen - 2;
+	tail[plen - 1] = *skb_mac_header(skb);
 	pskb_put(skb, trailer, clen - skb->len + alen);
 
 	skb_push(skb, -skb_network_offset(skb));
-- 
1.7.1
