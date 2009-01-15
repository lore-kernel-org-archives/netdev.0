From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2/2] igb: Replace LRO with GRO
Date: Thu, 15 Jan 2009 11:32:46 +1100
Message-ID: <20090115003246.GA26461@gondor.apana.org.au>
References: <9929d2390901140349v4483bd23wac254673de591bec@mail.gmail.com> <20090114123653.GA19257@gondor.apana.org.au> <9929d2390901141603s65cd27a3y732c5058de9145c8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Emil Tantilov <emil.s.tantilov@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46865 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759153AbZAOAcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 19:32:51 -0500
Content-Disposition: inline
In-Reply-To: <9929d2390901141603s65cd27a3y732c5058de9145c8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 04:03:10PM -0800, Jeff Kirsher wrote:
> 
> We are seeing a kernel panic during our testing using jumbo frames,
> below is the trace.

Thanks! This was the one case that I didn't test with e1000e,
namely an skb with page frags which comes from the driver (as
opposed to being constructed by the stack through gro_receive_frags).

gro: Fix page ref count for skbs freed normally

When an skb with page frags is merged into an existing one, we
cannibalise its reference count.  This is OK when the skb is
reused because we set nr_frags to zero in that case.  However,
for the case where the skb is freed through kfree_skb, we didn't
clear nr_frags which causes the page to be freed prematurely.

This is fixed by moving the skb resetting into skb_gro_receive.

Reported-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/dev.c b/net/core/dev.c
index 972a47d..4f69a2d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2481,12 +2481,6 @@ EXPORT_SYMBOL(napi_gro_receive);
 
 void napi_reuse_skb(struct napi_struct *napi, struct sk_buff *skb)
 {
-	skb_shinfo(skb)->nr_frags = 0;
-
-	skb->len -= skb->data_len;
-	skb->truesize -= skb->data_len;
-	skb->data_len = 0;
-
 	__skb_pull(skb, skb_headlen(skb));
 	skb_reserve(skb, NET_IP_ALIGN - skb_headroom(skb));
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5110b35..65eac77 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2602,6 +2602,12 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		       skb_shinfo(skb)->nr_frags * sizeof(skb_frag_t));
 
 		skb_shinfo(p)->nr_frags += skb_shinfo(skb)->nr_frags;
+		skb_shinfo(skb)->nr_frags = 0;
+
+		skb->truesize -= skb->data_len;
+		skb->len -= skb->data_len;
+		skb->data_len = 0;
+
 		NAPI_GRO_CB(skb)->free = 1;
 		goto done;
 	}

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
