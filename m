From: Patrick McHardy <kaber@trash.net>
Subject: [XFRM]: Optimize MTU calculation
Date: Tue, 03 Apr 2007 18:36:32 +0200
Message-ID: <46128290.5060701@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040306000601010601020205"
Cc: Herbert Xu <herbert@gondor.apana.org.au>
To: Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38341 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933884AbXDCQgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2007 12:36:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040306000601010601020205
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

I've updated my IPsec MTU optimization patch I've posted a couple
of month ago to net-2.6.22 and added the further optimization
suggested by Herbert to account for the space lost due to alignment
in the room reserved for IP options in transport mode.

Tested with IPv4 and IPv6 in tunnel and transport mode. Beet mode
is untested since no keying daemon seems to support it.


--------------040306000601010601020205
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[XFRM]: Optimize MTU calculation

Replace the probing based MTU estimation, which usually takes 2-3 iterations
to find a fitting value and may underestimate the MTU, by an exact calculation.

Also fixes underestimation of the XFRM trailer_len, which causes unnecessary
reallocations.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit f4de4e63b441ce18a7ef19256fcb85ea737e45bb
tree 7b1feb6d5a47467c6e6a74f19e589e53534c2b56
parent 565b89fa1b7c55b69f66af0ba1e84addbf9a0e1a
author Patrick McHardy <kaber@trash.net> Tue, 03 Apr 2007 17:20:47 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 03 Apr 2007 17:20:47 +0200

 include/net/xfrm.h    |    2 +-
 net/ipv4/esp4.c       |   30 ++++++++++++++++++------------
 net/ipv6/esp6.c       |   22 ++++++++++++----------
 net/xfrm/xfrm_state.c |   36 ++++++++----------------------------
 4 files changed, 39 insertions(+), 51 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 5a00aa8..e144a25 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -279,7 +279,7 @@ struct xfrm_type
 	xfrm_address_t		*(*local_addr)(struct xfrm_state *, xfrm_address_t *);
 	xfrm_address_t		*(*remote_addr)(struct xfrm_state *, xfrm_address_t *);
 	/* Estimate maximal size of result of transformation of a dgram */
-	u32			(*get_max_size)(struct xfrm_state *, int size);
+	u32			(*get_mtu)(struct xfrm_state *, int size);
 };
 
 extern int xfrm_register_type(struct xfrm_type *type, unsigned short family);
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 5e56139..24238fb 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -272,32 +272,34 @@ out:
 	return -EINVAL;
 }
 
-static u32 esp4_get_max_size(struct xfrm_state *x, int mtu)
+static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
 {
 	struct esp_data *esp = x->data;
 	u32 blksize = ALIGN(crypto_blkcipher_blocksize(esp->conf.tfm), 4);
-	int enclen = 0;
+	u32 align = max_t(u32, blksize, esp->conf.padlen);
+	u32 rem;
+
+	mtu -= x->props.header_len + esp->auth.icv_trunc_len;
+	rem = mtu & (align - 1);
+	mtu &= ~(align - 1);
 
 	switch (x->props.mode) {
 	case XFRM_MODE_TUNNEL:
-		mtu = ALIGN(mtu +2, blksize);
 		break;
 	default:
 	case XFRM_MODE_TRANSPORT:
 		/* The worst case */
-		mtu = ALIGN(mtu + 2, 4) + blksize - 4;
+		mtu -= blksize - 4;
+		mtu += min_t(u32, blksize - 4, rem);
 		break;
 	case XFRM_MODE_BEET:
 		/* The worst case. */
-		enclen = IPV4_BEET_PHMAXLEN;
-		mtu = ALIGN(mtu + enclen + 2, blksize);
+		mtu -= IPV4_BEET_PHMAXLEN;
+		mtu += min_t(u32, IPV4_BEET_PHMAXLEN, rem);
 		break;
 	}
 
-	if (esp->conf.padlen)
-		mtu = ALIGN(mtu, esp->conf.padlen);
-
-	return mtu + x->props.header_len + esp->auth.icv_trunc_len - enclen;
+	return mtu - 2;
 }
 
 static void esp4_err(struct sk_buff *skb, u32 info)
@@ -340,6 +342,7 @@ static int esp_init_state(struct xfrm_state *x)
 {
 	struct esp_data *esp = NULL;
 	struct crypto_blkcipher *tfm;
+	u32 align;
 
 	/* null auth and encryption can have zero length keys */
 	if (x->aalg) {
@@ -421,7 +424,10 @@ static int esp_init_state(struct xfrm_state *x)
 		}
 	}
 	x->data = esp;
-	x->props.trailer_len = esp4_get_max_size(x, 0) - x->props.header_len;
+	align = ALIGN(crypto_blkcipher_blocksize(esp->conf.tfm), 4);
+	if (esp->conf.padlen)
+		align = max_t(u32, align, esp->conf.padlen);
+	x->props.trailer_len = align + 1 + esp->auth.icv_trunc_len;
 	return 0;
 
 error:
@@ -438,7 +444,7 @@ static struct xfrm_type esp_type =
 	.proto	     	= IPPROTO_ESP,
 	.init_state	= esp_init_state,
 	.destructor	= esp_destroy,
-	.get_max_size	= esp4_get_max_size,
+	.get_mtu	= esp4_get_mtu,
 	.input		= esp_input,
 	.output		= esp_output
 };
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index b8e8914..61af22d 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -235,22 +235,24 @@ out:
 	return ret;
 }
 
-static u32 esp6_get_max_size(struct xfrm_state *x, int mtu)
+static u32 esp6_get_mtu(struct xfrm_state *x, int mtu)
 {
 	struct esp_data *esp = x->data;
 	u32 blksize = ALIGN(crypto_blkcipher_blocksize(esp->conf.tfm), 4);
+	u32 align = max_t(u32, blksize, esp->conf.padlen);
+	u32 rem;
 
-	if (x->props.mode == XFRM_MODE_TUNNEL) {
-		mtu = ALIGN(mtu + 2, blksize);
-	} else {
-		/* The worst case. */
+	mtu -= x->props.header_len + esp->auth.icv_trunc_len;
+	rem = mtu & (align - 1);
+	mtu &= ~(align - 1);
+
+	if (x->props.mode != XFRM_MODE_TUNNEL) {
 		u32 padsize = ((blksize - 1) & 7) + 1;
-		mtu = ALIGN(mtu + 2, padsize) + blksize - padsize;
+		mtu -= blksize - padsize;
+		mtu += min_t(u32, blksize - padsize, rem);
 	}
-	if (esp->conf.padlen)
-		mtu = ALIGN(mtu, esp->conf.padlen);
 
-	return mtu + x->props.header_len + esp->auth.icv_trunc_len;
+	return mtu - 2;
 }
 
 static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
@@ -380,7 +382,7 @@ static struct xfrm_type esp6_type =
 	.proto	     	= IPPROTO_ESP,
 	.init_state	= esp6_init_state,
 	.destructor	= esp6_destroy,
-	.get_max_size	= esp6_get_max_size,
+	.get_mtu	= esp6_get_mtu,
 	.input		= esp6_input,
 	.output		= esp6_output,
 	.hdr_offset	= xfrm6_find_1stfragopt,
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index a237dfd..790b608 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1666,37 +1666,17 @@ void xfrm_state_delete_tunnel(struct xfrm_state *x)
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
-
-		if (m <= mtu)
-			break;
-		res -= (m - mtu);
-	}
+	int res;
 
+	spin_lock_bh(&x->lock);
+	if (x->km.state == XFRM_STATE_VALID &&
+	    x->type && x->type->get_mtu)
+		res = x->type->get_mtu(x, mtu);
+	else
+		res = mtu;
+	spin_unlock_bh(&x->lock);
 	return res;
 }
 

--------------040306000601010601020205--
