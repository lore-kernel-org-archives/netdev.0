From: Patrick McHardy <kaber@trash.net>
Subject: [RFC XFRM]: esp: fix scatterlist of out bounds access with crypto_eseqiv
Date: Mon, 28 Apr 2008 20:55:21 +0200
Message-ID: <48161D99.5070303@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020900000705030909020002"
Cc: linux-crypto@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020900000705030909020002
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

I ran into occasional BUGs in scatterlist.h, which turned
out the be caused by accessing an uninitialized scatterlist
entry from eseqiv. I'm not sure whether this patch is correct
since I'm seeing invalid packets with and without this patch
(probably related to HIFN though) and I don't understand why
scatterwalk_sg_next() returns either a scatterlist or a
struct page dependant on the length, but at least it fixes
the BUG() for me :)


--------------020900000705030909020002
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 7be04e75bc64dc288e51f83495d89135a8c9d4d7
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Apr 28 19:24:23 2008 +0200

    [XFRM]: esp: fix scatterlist of out bounds access with crypto_eseqiv
    
    ESP allocates a src scatterlist for the exact amount of scatterlist
    entries. In the IPSec case (IV is directly before the plaintext data)
    eseqiv_chain() calls scatterwalk_sg_next(), which advances the
    scatterlist by one, pointing to uninitalized memory. When sg->length
    is zero, it returns sg_page(sg), which BUGs with DEBUG_SG enabled
    because the magic number is invalid.
    
    Allocate and initialize a spare scatterlist entry in esp4/esp6 to fix this.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 4e73e57..6803b90 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -139,7 +139,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 		goto error;
 	nfrags = err;
 
-	tmp = esp_alloc_tmp(aead, nfrags + 1);
+	tmp = esp_alloc_tmp(aead, nfrags + 2);
 	if (!tmp)
 		goto error;
 
@@ -201,7 +201,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	esph->spi = x->id.spi;
 	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output);
 
-	sg_init_table(sg, nfrags);
+	sg_init_table(sg, nfrags + 1);
 	skb_to_sgvec(skb, sg,
 		     esph->enc_data + crypto_aead_ivsize(aead) - skb->data,
 		     clen + alen);
@@ -347,7 +347,7 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 	nfrags = err;
 
 	err = -ENOMEM;
-	tmp = esp_alloc_tmp(aead, nfrags + 1);
+	tmp = esp_alloc_tmp(aead, nfrags + 2);
 	if (!tmp)
 		goto out;
 
@@ -364,7 +364,7 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 	/* Get ivec. This can be wrong, check against another impls. */
 	iv = esph->enc_data;
 
-	sg_init_table(sg, nfrags);
+	sg_init_table(sg, nfrags + 1);
 	skb_to_sgvec(skb, sg, sizeof(*esph) + crypto_aead_ivsize(aead), elen);
 	sg_init_one(asg, esph, sizeof(*esph));
 
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index c6bb4c6..d00c74c 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -163,7 +163,7 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 		goto error;
 	nfrags = err;
 
-	tmp = esp_alloc_tmp(aead, nfrags + 1);
+	tmp = esp_alloc_tmp(aead, nfrags + 2);
 	if (!tmp)
 		goto error;
 
@@ -190,7 +190,7 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	esph->spi = x->id.spi;
 	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output);
 
-	sg_init_table(sg, nfrags);
+	sg_init_table(sg, nfrags + 1);
 	skb_to_sgvec(skb, sg,
 		     esph->enc_data + crypto_aead_ivsize(aead) - skb->data,
 		     clen + alen);
@@ -298,7 +298,7 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 	}
 
 	ret = -ENOMEM;
-	tmp = esp_alloc_tmp(aead, nfrags + 1);
+	tmp = esp_alloc_tmp(aead, nfrags + 2);
 	if (!tmp)
 		goto out;
 
@@ -315,7 +315,7 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 	/* Get ivec. This can be wrong, check against another impls. */
 	iv = esph->enc_data;
 
-	sg_init_table(sg, nfrags);
+	sg_init_table(sg, nfrags + 1);
 	skb_to_sgvec(skb, sg, sizeof(*esph) + crypto_aead_ivsize(aead), elen);
 	sg_init_one(asg, esph, sizeof(*esph));
 

--------------020900000705030909020002--
