From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ixgbe: Replace LRO with GRO
Date: Sun, 18 Jan 2009 00:04:04 +1100
Message-ID: <20090117130404.GA17810@gondor.apana.org.au>
References: <20090113092625.GA28015@gondor.apana.org.au> <20090113092828.GA28052@gondor.apana.org.au> <20090114084412.GA17393@gondor.apana.org.au> <20090115034619.GA28267@gondor.apana.org.au> <9929d2390901161532j57528215mdb01f38be1bd4c7f@mail.gmail.com> <20090117003629.GA22370@gondor.apana.org.au> <EA929A9653AAE14F841771FB1DE5A1365F59F11911@rrsmsx501.amr.corp.intel.com> <20090117034510.GA23714@gondor.apana.org.au> <EA929A9653AAE14F841771FB1DE5A1365F59F11A11@rrsmsx501.amr.corp.intel.com> <20090117095256.GA26169@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33216 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755562AbZAQNEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2009 08:04:11 -0500
Content-Disposition: inline
In-Reply-To: <20090117095256.GA26169@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 17, 2009 at 08:52:56PM +1100, Herbert Xu wrote:
> 
> > > However, it is not very clear what is causing this loss.  BTW,
> > > did you apply the fix b0059b50b70dc3a908bea4ece2f9494a22200018
> > > (gro: Fix page ref count for skbs freed normally) on both sides?
> > > That one is required to make igb or ixgbe work properly.
> > Ah - doesn't seem like I have this fix. Jeff will have to pull this in our test tree.
> 
> OK, although this bug should only manifest itself if aggregation
> occurs, which apparently isn't the case according to the dump.

Doh, it looks like the bug fix itself was broken.  In fact, I
think you do have the fix as it results in exactly what you were
seeing.

Please apply this on top of it.

gro: Fix merging of paged packets

The previous fix to paged packets broke the merging because it
reset the skb->len before we added it to the merged packet.  This
wasn't detected because it simply resulted in the truncation of
the packet while the missing bit is subsequently retransmitted.

The fix is to store skb->len before we clobber it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 65eac77..9127c47 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2588,8 +2588,9 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	struct sk_buff *nskb;
 	unsigned int headroom;
 	unsigned int hlen = p->data - skb_mac_header(p);
+	unsigned int len = skb->len;
 
-	if (hlen + p->len + skb->len >= 65536)
+	if (hlen + p->len + len >= 65536)
 		return -E2BIG;
 
 	if (skb_shinfo(p)->frag_list)
@@ -2651,9 +2652,9 @@ merge:
 
 done:
 	NAPI_GRO_CB(p)->count++;
-	p->data_len += skb->len;
-	p->truesize += skb->len;
-	p->len += skb->len;
+	p->data_len += len;
+	p->truesize += len;
+	p->len += len;
 
 	NAPI_GRO_CB(skb)->same_flow = 1;
 	return 0;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
