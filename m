From: Mathias Krause <mathias.krause@secunet.com>
Subject: [PATCH net-next 2/2] net: esp{4,6}: get rid of struct esp_data
Date: Fri, 18 Oct 2013 12:09:05 +0200
Message-ID: <1382090945-20860-3-git-send-email-mathias.krause@secunet.com>
References: <1382090945-20860-1-git-send-email-mathias.krause@secunet.com>
Cc: Mathias Krause <mathias.krause@secunet.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:54012 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752497Ab3JRKJT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Oct 2013 06:09:19 -0400
In-Reply-To: <1382090945-20860-1-git-send-email-mathias.krause@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct esp_data consists of a single pointer, vanishing the need for it
to be a structure. Fold the pointer into 'data' direcly, removing one
level of pointer indirection.

Signed-off-by: Mathias Krause <mathias.krause@secunet.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
---
 include/net/esp.h |    7 -------
 net/ipv4/esp4.c   |   40 ++++++++++++++--------------------------
 net/ipv6/esp6.c   |   39 ++++++++++++++-------------------------
 3 files changed, 28 insertions(+), 58 deletions(-)

diff --git a/include/net/esp.h b/include/net/esp.h
index 706b740..c92213c 100644
--- a/include/net/esp.h
+++ b/include/net/esp.h
@@ -3,13 +3,6 @@
 
 #include <linux/skbuff.h>
 
-struct crypto_aead;
-
-struct esp_data {
-	/* Confidentiality & Integrity */
-	struct crypto_aead *aead;
-};
-
 void *pskb_put(struct sk_buff *skb, struct sk_buff *tail, int len);
 
 struct ip_esp_hdr;
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 8b5386a..7785b28 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -121,7 +121,6 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	struct aead_givcrypt_request *req;
 	struct scatterlist *sg;
 	struct scatterlist *asg;
-	struct esp_data *esp;
 	struct sk_buff *trailer;
 	void *tmp;
 	u8 *iv;
@@ -139,8 +138,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	/* skb is pure payload to encrypt */
 
-	esp = x->data;
-	aead = esp->aead;
+	aead = x->data;
 	alen = crypto_aead_authsize(aead);
 
 	tfclen = 0;
@@ -278,8 +276,7 @@ static int esp_input_done2(struct sk_buff *skb, int err)
 {
 	const struct iphdr *iph;
 	struct xfrm_state *x = xfrm_input_state(skb);
-	struct esp_data *esp = x->data;
-	struct crypto_aead *aead = esp->aead;
+	struct crypto_aead *aead = x->data;
 	int alen = crypto_aead_authsize(aead);
 	int hlen = sizeof(struct ip_esp_hdr) + crypto_aead_ivsize(aead);
 	int elen = skb->len - hlen;
@@ -374,8 +371,7 @@ static void esp_input_done(struct crypto_async_request *base, int err)
 static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ip_esp_hdr *esph;
-	struct esp_data *esp = x->data;
-	struct crypto_aead *aead = esp->aead;
+	struct crypto_aead *aead = x->data;
 	struct aead_request *req;
 	struct sk_buff *trailer;
 	int elen = skb->len - sizeof(*esph) - crypto_aead_ivsize(aead);
@@ -457,8 +453,8 @@ out:
 
 static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
 {
-	struct esp_data *esp = x->data;
-	u32 blksize = ALIGN(crypto_aead_blocksize(esp->aead), 4);
+	struct crypto_aead *aead = x->data;
+	u32 blksize = ALIGN(crypto_aead_blocksize(aead), 4);
 	unsigned int net_adj;
 
 	switch (x->props.mode) {
@@ -473,7 +469,7 @@ static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
 		BUG();
 	}
 
-	return ((mtu - x->props.header_len - crypto_aead_authsize(esp->aead) -
+	return ((mtu - x->props.header_len - crypto_aead_authsize(aead) -
 		 net_adj) & ~(blksize - 1)) + net_adj - 2;
 }
 
@@ -508,18 +504,16 @@ static void esp4_err(struct sk_buff *skb, u32 info)
 
 static void esp_destroy(struct xfrm_state *x)
 {
-	struct esp_data *esp = x->data;
+	struct crypto_aead *aead = x->data;
 
-	if (!esp)
+	if (!aead)
 		return;
 
-	crypto_free_aead(esp->aead);
-	kfree(esp);
+	crypto_free_aead(aead);
 }
 
 static int esp_init_aead(struct xfrm_state *x)
 {
-	struct esp_data *esp = x->data;
 	struct crypto_aead *aead;
 	int err;
 
@@ -528,7 +522,7 @@ static int esp_init_aead(struct xfrm_state *x)
 	if (IS_ERR(aead))
 		goto error;
 
-	esp->aead = aead;
+	x->data = aead;
 
 	err = crypto_aead_setkey(aead, x->aead->alg_key,
 				 (x->aead->alg_key_len + 7) / 8);
@@ -545,7 +539,6 @@ error:
 
 static int esp_init_authenc(struct xfrm_state *x)
 {
-	struct esp_data *esp = x->data;
 	struct crypto_aead *aead;
 	struct crypto_authenc_key_param *param;
 	struct rtattr *rta;
@@ -580,7 +573,7 @@ static int esp_init_authenc(struct xfrm_state *x)
 	if (IS_ERR(aead))
 		goto error;
 
-	esp->aead = aead;
+	x->data = aead;
 
 	keylen = (x->aalg ? (x->aalg->alg_key_len + 7) / 8 : 0) +
 		 (x->ealg->alg_key_len + 7) / 8 + RTA_SPACE(sizeof(*param));
@@ -635,16 +628,11 @@ error:
 
 static int esp_init_state(struct xfrm_state *x)
 {
-	struct esp_data *esp;
 	struct crypto_aead *aead;
 	u32 align;
 	int err;
 
-	esp = kzalloc(sizeof(*esp), GFP_KERNEL);
-	if (esp == NULL)
-		return -ENOMEM;
-
-	x->data = esp;
+	x->data = NULL;
 
 	if (x->aead)
 		err = esp_init_aead(x);
@@ -654,7 +642,7 @@ static int esp_init_state(struct xfrm_state *x)
 	if (err)
 		goto error;
 
-	aead = esp->aead;
+	aead = x->data;
 
 	x->props.header_len = sizeof(struct ip_esp_hdr) +
 			      crypto_aead_ivsize(aead);
@@ -678,7 +666,7 @@ static int esp_init_state(struct xfrm_state *x)
 	}
 
 	align = ALIGN(crypto_aead_blocksize(aead), 4);
-	x->props.trailer_len = align + 1 + crypto_aead_authsize(esp->aead);
+	x->props.trailer_len = align + 1 + crypto_aead_authsize(aead);
 
 error:
 	return err;
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 0073cd0..87eb79e 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -164,10 +164,9 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	u8 *iv;
 	u8 *tail;
 	__be32 *seqhi;
-	struct esp_data *esp = x->data;
 
 	/* skb is pure payload to encrypt */
-	aead = esp->aead;
+	aead = x->data;
 	alen = crypto_aead_authsize(aead);
 
 	tfclen = 0;
@@ -269,8 +268,7 @@ error:
 static int esp_input_done2(struct sk_buff *skb, int err)
 {
 	struct xfrm_state *x = xfrm_input_state(skb);
-	struct esp_data *esp = x->data;
-	struct crypto_aead *aead = esp->aead;
+	struct crypto_aead *aead = x->data;
 	int alen = crypto_aead_authsize(aead);
 	int hlen = sizeof(struct ip_esp_hdr) + crypto_aead_ivsize(aead);
 	int elen = skb->len - hlen;
@@ -323,8 +321,7 @@ static void esp_input_done(struct crypto_async_request *base, int err)
 static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ip_esp_hdr *esph;
-	struct esp_data *esp = x->data;
-	struct crypto_aead *aead = esp->aead;
+	struct crypto_aead *aead = x->data;
 	struct aead_request *req;
 	struct sk_buff *trailer;
 	int elen = skb->len - sizeof(*esph) - crypto_aead_ivsize(aead);
@@ -412,8 +409,8 @@ out:
 
 static u32 esp6_get_mtu(struct xfrm_state *x, int mtu)
 {
-	struct esp_data *esp = x->data;
-	u32 blksize = ALIGN(crypto_aead_blocksize(esp->aead), 4);
+	struct crypto_aead *aead = x->data;
+	u32 blksize = ALIGN(crypto_aead_blocksize(aead), 4);
 	unsigned int net_adj;
 
 	if (x->props.mode != XFRM_MODE_TUNNEL)
@@ -421,7 +418,7 @@ static u32 esp6_get_mtu(struct xfrm_state *x, int mtu)
 	else
 		net_adj = 0;
 
-	return ((mtu - x->props.header_len - crypto_aead_authsize(esp->aead) -
+	return ((mtu - x->props.header_len - crypto_aead_authsize(aead) -
 		 net_adj) & ~(blksize - 1)) + net_adj - 2;
 }
 
@@ -452,18 +449,16 @@ static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 static void esp6_destroy(struct xfrm_state *x)
 {
-	struct esp_data *esp = x->data;
+	struct crypto_aead *aead = x->data;
 
-	if (!esp)
+	if (!aead)
 		return;
 
-	crypto_free_aead(esp->aead);
-	kfree(esp);
+	crypto_free_aead(aead);
 }
 
 static int esp_init_aead(struct xfrm_state *x)
 {
-	struct esp_data *esp = x->data;
 	struct crypto_aead *aead;
 	int err;
 
@@ -472,7 +467,7 @@ static int esp_init_aead(struct xfrm_state *x)
 	if (IS_ERR(aead))
 		goto error;
 
-	esp->aead = aead;
+	x->data = aead;
 
 	err = crypto_aead_setkey(aead, x->aead->alg_key,
 				 (x->aead->alg_key_len + 7) / 8);
@@ -489,7 +484,6 @@ error:
 
 static int esp_init_authenc(struct xfrm_state *x)
 {
-	struct esp_data *esp = x->data;
 	struct crypto_aead *aead;
 	struct crypto_authenc_key_param *param;
 	struct rtattr *rta;
@@ -524,7 +518,7 @@ static int esp_init_authenc(struct xfrm_state *x)
 	if (IS_ERR(aead))
 		goto error;
 
-	esp->aead = aead;
+	x->data = aead;
 
 	keylen = (x->aalg ? (x->aalg->alg_key_len + 7) / 8 : 0) +
 		 (x->ealg->alg_key_len + 7) / 8 + RTA_SPACE(sizeof(*param));
@@ -579,7 +573,6 @@ error:
 
 static int esp6_init_state(struct xfrm_state *x)
 {
-	struct esp_data *esp;
 	struct crypto_aead *aead;
 	u32 align;
 	int err;
@@ -587,11 +580,7 @@ static int esp6_init_state(struct xfrm_state *x)
 	if (x->encap)
 		return -EINVAL;
 
-	esp = kzalloc(sizeof(*esp), GFP_KERNEL);
-	if (esp == NULL)
-		return -ENOMEM;
-
-	x->data = esp;
+	x->data = NULL;
 
 	if (x->aead)
 		err = esp_init_aead(x);
@@ -601,7 +590,7 @@ static int esp6_init_state(struct xfrm_state *x)
 	if (err)
 		goto error;
 
-	aead = esp->aead;
+	aead = x->data;
 
 	x->props.header_len = sizeof(struct ip_esp_hdr) +
 			      crypto_aead_ivsize(aead);
@@ -621,7 +610,7 @@ static int esp6_init_state(struct xfrm_state *x)
 	}
 
 	align = ALIGN(crypto_aead_blocksize(aead), 4);
-	x->props.trailer_len = align + 1 + crypto_aead_authsize(esp->aead);
+	x->props.trailer_len = align + 1 + crypto_aead_authsize(aead);
 
 error:
 	return err;
-- 
1.7.10.4
