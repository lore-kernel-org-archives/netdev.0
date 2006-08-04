From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: Improve MTU estimation
Date: Fri, 04 Aug 2006 11:27:11 +0200
Message-ID: <44D312EF.8010202@trash.net>
References: <44D30A48.4050403@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040507060508090009020303"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59084 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1030250AbWHDJ3E
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 05:29:04 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <44D30A48.4050403@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040507060508090009020303
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
>  int xfrm_state_mtu(struct xfrm_state *x, int mtu)
>  {
> -	int res = mtu;
> -
> -	res -= x->props.header_len;
> -
> -	for (;;) {
> -		int m = res;
> -
> -		if (m < 68)
> -			return 68;
> -
> -		spin_lock_bh(&x->lock);
> -		if (x->km.state == XFRM_STATE_VALID &&
> -		    x->type && x->type->get_max_size)
> -			m = x->type->get_max_size(x, m);
> -		else
> -			m += x->props.header_len;
> -		spin_unlock_bh(&x->lock);
> -
> -		if (m <= mtu)
> -			break;
> -		res -= (m - mtu);
> -	}
> +	int res;
>  
> +	spin_lock_bh(&x->lock);
> +	if (x->km.state == XFRM_STATE_VALID &&
> +	    x->type && x->type->get_mtu)
> +		res = x->type->get_mtu(x, mtu);
> +	else
> +		res = mtu;
> +	spin_unlock_bh(&x->lock);
>  	return res;
>  }


That broke estimation for AH. This one should be fine.

--------------040507060508090009020303
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[XFRM]: Improve MTU estimation

Replace the probing based MTU estimation, which usually takes 2-3
iterations to find a fitting value and may underestimate the MTU,
by an exact calculation.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 503d86d9420b2c21121a5c2cbda9e42cc559031f
tree a65939379cd3f200070a784fb079854270d26940
parent a205729e2cd8e51257cd0ea738524c64da99b9e0
author Patrick McHardy <kaber@trash.net> Fri, 04 Aug 2006 11:27:20 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 04 Aug 2006 11:27:20 +0200

 include/net/xfrm.h    |    3 +--
 net/ipv4/esp4.c       |   28 +++++++++++++++-------------
 net/ipv6/esp6.c       |   25 +++++++++++--------------
 net/xfrm/xfrm_state.c |   37 ++++++++++---------------------------
 4 files changed, 37 insertions(+), 56 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 9c5ee9f..ea1b028 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -262,8 +262,7 @@ struct xfrm_type
 	void			(*destructor)(struct xfrm_state *);
 	int			(*input)(struct xfrm_state *, struct sk_buff *skb);
 	int			(*output)(struct xfrm_state *, struct sk_buff *pskb);
-	/* Estimate maximal size of result of transformation of a dgram */
-	u32			(*get_max_size)(struct xfrm_state *, int size);
+	u32			(*get_mtu)(struct xfrm_state *, int size);
 };
 
 extern int xfrm_register_type(struct xfrm_type *type, unsigned short family);
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index fc2f8ce..5393dc2 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -251,21 +251,19 @@ out:
 	return -EINVAL;
 }
 
-static u32 esp4_get_max_size(struct xfrm_state *x, int mtu)
+static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
 {
 	struct esp_data *esp = x->data;
-	u32 blksize = ALIGN(crypto_tfm_alg_blocksize(esp->conf.tfm), 4);
+	u32 align = ALIGN(crypto_tfm_alg_blocksize(esp->conf.tfm), 4);
 
-	if (x->props.mode) {
-		mtu = ALIGN(mtu + 2, blksize);
-	} else {
-		/* The worst case. */
-		mtu = ALIGN(mtu + 2, 4) + blksize - 4;
-	}
-	if (esp->conf.padlen)
-		mtu = ALIGN(mtu, esp->conf.padlen);
+	if (esp->conf.padlen > align)
+		align = esp->conf.padlen;
 
-	return mtu + x->props.header_len + esp->auth.icv_trunc_len;
+	mtu -= x->props.header_len + esp->auth.icv_trunc_len;
+	mtu &= ~(align - 1);
+	mtu -= 2;
+
+	return mtu;
 }
 
 static void esp4_err(struct sk_buff *skb, u32 info)
@@ -307,6 +305,7 @@ static void esp_destroy(struct xfrm_stat
 static int esp_init_state(struct xfrm_state *x)
 {
 	struct esp_data *esp = NULL;
+	u32 align;
 
 	/* null auth and encryption can have zero length keys */
 	if (x->aalg) {
@@ -385,7 +384,10 @@ static int esp_init_state(struct xfrm_st
 		}
 	}
 	x->data = esp;
-	x->props.trailer_len = esp4_get_max_size(x, 0) - x->props.header_len;
+	align = ALIGN(crypto_tfm_alg_blocksize(esp->conf.tfm), 4);
+	if (esp->conf.padlen)
+		align = ALIGN(align, esp->conf.padlen);
+	x->props.trailer_len = align - 1 + esp->auth.icv_trunc_len;
 	return 0;
 
 error:
@@ -402,7 +404,7 @@ static struct xfrm_type esp_type =
 	.proto	     	= IPPROTO_ESP,
 	.init_state	= esp_init_state,
 	.destructor	= esp_destroy,
-	.get_max_size	= esp4_get_max_size,
+	.get_mtu	= esp4_get_mtu,
 	.input		= esp_input,
 	.output		= esp_output
 };
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index a278d5e..b8d0a05 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -222,22 +222,19 @@ out:
 	return ret;
 }
 
-static u32 esp6_get_max_size(struct xfrm_state *x, int mtu)
+static u32 esp6_get_mtu(struct xfrm_state *x, int mtu)
 {
 	struct esp_data *esp = x->data;
-	u32 blksize = ALIGN(crypto_tfm_alg_blocksize(esp->conf.tfm), 4);
-
-	if (x->props.mode) {
-		mtu = ALIGN(mtu + 2, blksize);
-	} else {
-		/* The worst case. */
-		u32 padsize = ((blksize - 1) & 7) + 1;
-		mtu = ALIGN(mtu + 2, padsize) + blksize - padsize;
-	}
-	if (esp->conf.padlen)
-		mtu = ALIGN(mtu, esp->conf.padlen);
+	u32 align = ALIGN(crypto_tfm_alg_blocksize(esp->conf.tfm), 4);
+
+	if (esp->conf.padlen > align)
+		align = esp->conf.padlen;
+	
+	mtu -= x->props.header_len + esp->auth.icv_trunc_len;
+	mtu &= ~(align - 1);
+	mtu -= 2;
 
-	return mtu + x->props.header_len + esp->auth.icv_trunc_len;
+	return mtu;
 }
 
 static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
@@ -363,7 +360,7 @@ static struct xfrm_type esp6_type =
 	.proto	     	= IPPROTO_ESP,
 	.init_state	= esp6_init_state,
 	.destructor	= esp6_destroy,
-	.get_max_size	= esp6_get_max_size,
+	.get_mtu	= esp6_get_mtu,
 	.input		= esp6_input,
 	.output		= esp6_output
 };
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 0021aad..7b0b100 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1129,37 +1129,20 @@ void xfrm_state_delete_tunnel(struct xfr
 }
 EXPORT_SYMBOL(xfrm_state_delete_tunnel);
 
-/*
- * This function is NOT optimal.  For example, with ESP it will give an
- * MTU that's usually two bytes short of being optimal.  However, it will
- * usually give an answer that's a multiple of 4 provided the input is
- * also a multiple of 4.
- */
 int xfrm_state_mtu(struct xfrm_state *x, int mtu)
 {
-	int res = mtu;
-
-	res -= x->props.header_len;
-
-	for (;;) {
-		int m = res;
-
-		if (m < 68)
-			return 68;
-
-		spin_lock_bh(&x->lock);
-		if (x->km.state == XFRM_STATE_VALID &&
-		    x->type && x->type->get_max_size)
-			m = x->type->get_max_size(x, m);
-		else
-			m += x->props.header_len;
-		spin_unlock_bh(&x->lock);
+	int res;
 
-		if (m <= mtu)
-			break;
-		res -= (m - mtu);
-	}
+	spin_lock_bh(&x->lock);
+	if (x->km.state == XFRM_STATE_VALID &&
+	    x->type && x->type->get_mtu)
+		res = x->type->get_mtu(x, mtu);
+	else
+		res = mtu - x->props.header_len;
+	spin_unlock_bh(&x->lock);
 
+	if (res < 68)
+		res = 68;
 	return res;
 }
 

--------------040507060508090009020303--
