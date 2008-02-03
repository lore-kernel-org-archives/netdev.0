From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_input() and ->seq oddities
Date: Sun, 3 Feb 2008 11:20:19 +1100
Message-ID: <20080203002019.GA32295@gondor.apana.org.au>
References: <20080202211635.GF9375@cs181133002.pp.htv.fi> <20080202222226.GB31388@gondor.apana.org.au> <20080202235827.GP27894@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:32881 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1765648AbYBCAUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 19:20:30 -0500
Content-Disposition: inline
In-Reply-To: <20080202235827.GP27894@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 02, 2008 at 11:58:27PM +0000, Al Viro wrote:
> 	What's going on with XFRM_SKB_CB(skb)->seq?  Almost all users
> expect it to be u32 (feeding it to htonl()), except xfrm_input().
> That one expects __be32 in there - check what it does to seq and
> you'll see.  Moreover, it updates the sucker in a way that makes
> sense only for __be32.

My bad.

> 	a) are we just missing ntohl() and htonl() in obvious places
> in xfrm_input()?

It's semantically correct.  However, my mistake that I'm mixing the
input sequence number which is network endian with the output sequence
number which is host endian (and 64-bit).

> 	b) WTF is it declared as 64bit, anyway?

For extended sequence numbers which we'll support soon (I hope).

[IPSEC]: Fix bogus usage of u64 on input sequence number

Al Viro spotted a bogus use of u64 on the input sequence number which
is big-endian.  This patch fixes it by giving the input sequence number
its own member in the xfrm_skb_cb structure.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index ac72116..eea7785 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -508,7 +508,10 @@ struct xfrm_skb_cb {
         } header;
 
         /* Sequence number for replay protection. */
-        u64 seq;
+	union {
+		u64 output;
+		__be32 input;
+	} seq;
 };
 
 #define XFRM_SKB_CB(__skb) ((struct xfrm_skb_cb *)&((__skb)->cb[0]))
diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 9d4555e..8219b7e 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -96,7 +96,7 @@ static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	ah->reserved = 0;
 	ah->spi = x->id.spi;
-	ah->seq_no = htonl(XFRM_SKB_CB(skb)->seq);
+	ah->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output);
 
 	spin_lock_bh(&x->lock);
 	err = ah_mac_digest(ahp, skb, ah->auth_data);
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 258d176..091e670 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -199,7 +199,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	}
 
 	esph->spi = x->id.spi;
-	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq);
+	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output);
 
 	sg_init_table(sg, nfrags);
 	skb_to_sgvec(skb, sg,
@@ -210,7 +210,8 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	aead_givcrypt_set_callback(req, 0, esp_output_done, skb);
 	aead_givcrypt_set_crypt(req, sg, sg, clen, iv);
 	aead_givcrypt_set_assoc(req, asg, sizeof(*esph));
-	aead_givcrypt_set_giv(req, esph->enc_data, XFRM_SKB_CB(skb)->seq);
+	aead_givcrypt_set_giv(req, esph->enc_data,
+			      XFRM_SKB_CB(skb)->seq.output);
 
 	ESP_SKB_CB(skb)->tmp = tmp;
 	err = crypto_aead_givencrypt(req);
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 379c8e0..2ff0c82 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -283,7 +283,7 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	ah->reserved = 0;
 	ah->spi = x->id.spi;
-	ah->seq_no = htonl(XFRM_SKB_CB(skb)->seq);
+	ah->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output);
 
 	spin_lock_bh(&x->lock);
 	err = ah_mac_digest(ahp, skb, ah->auth_data);
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 8e0f142..0ec1402 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -188,7 +188,7 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	*skb_mac_header(skb) = IPPROTO_ESP;
 
 	esph->spi = x->id.spi;
-	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq);
+	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq.output);
 
 	sg_init_table(sg, nfrags);
 	skb_to_sgvec(skb, sg,
@@ -199,7 +199,8 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	aead_givcrypt_set_callback(req, 0, esp_output_done, skb);
 	aead_givcrypt_set_crypt(req, sg, sg, clen, iv);
 	aead_givcrypt_set_assoc(req, asg, sizeof(*esph));
-	aead_givcrypt_set_giv(req, esph->enc_data, XFRM_SKB_CB(skb)->seq);
+	aead_givcrypt_set_giv(req, esph->enc_data,
+			      XFRM_SKB_CB(skb)->seq.output);
 
 	ESP_SKB_CB(skb)->tmp = tmp;
 	err = crypto_aead_givencrypt(req);
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 4d6ebc6..62188c6 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -109,7 +109,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 	if (encap_type < 0) {
 		async = 1;
 		x = xfrm_input_state(skb);
-		seq = XFRM_SKB_CB(skb)->seq;
+		seq = XFRM_SKB_CB(skb)->seq.input;
 		goto resume;
 	}
 
@@ -175,7 +175,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 		spin_unlock(&x->lock);
 
-		XFRM_SKB_CB(skb)->seq = seq;
+		XFRM_SKB_CB(skb)->seq.input = seq;
 
 		nexthdr = x->type->input(x, skb);
 
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index fc69036..569d377 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -62,7 +62,7 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 		}
 
 		if (x->type->flags & XFRM_TYPE_REPLAY_PROT) {
-			XFRM_SKB_CB(skb)->seq = ++x->replay.oseq;
+			XFRM_SKB_CB(skb)->seq.output = ++x->replay.oseq;
 			if (unlikely(x->replay.oseq == 0)) {
 				XFRM_INC_STATS(LINUX_MIB_XFRMOUTSTATESEQERROR);
 				x->replay.oseq--;
