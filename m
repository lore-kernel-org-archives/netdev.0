From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Tue, 1 Aug 2006 21:51:02 +1000
Message-ID: <20060801115102.GA5638@gondor.apana.org.au>
References: <44CD8415.2020403@davidcoulson.net> <44CD85FF.9010607@trash.net> <20060730.215907.58439803.davem@davemloft.net> <44CD9013.7020401@trash.net> <44CDDDF7.70004@trash.net> <20060731113050.GA25972@gondor.apana.org.au> <44CE4DCA.8000609@trash.net> <44CF0086.1030404@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54033 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932674AbWHALvR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 07:51:17 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44CF0086.1030404@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2006 at 09:19:34AM +0200, Patrick McHardy wrote:
> 
> - nfct/nfctinfo/nfct_reasm: the xfrm output path does an immediate
>   nf_reset, so they were not necessary until now. Queueing can happen
>   on any hook, so we need to preserve them.

This looks OK to me.  However, we should do this in a wrapper around
skb_gso_segment rather than in skb_segment.

The idea with skb_gso_segment is that it's the most generic (or basic)
level of service which is needed by everyone.  If you need anything
more specific, you can do it around skb_gso_segment.

For exmample, dev_gso_segment is the version that's tailored for
device transmission.

So I'd imagine something like

nf_gso_segment(skb)
{
	segs = skb_gso_segment(skb, 0);
	if (IS_ERR(segs))
		goto out;

	nskb = segs;
	do {
		copy_nf_attributes(nskb, skb);
	} while ((nskb = nskb->next));

out:
	kfree_skb(skb);
	return segs;
}

> - nf_bridge: needed for GSO on a bridge device until the deferred
>   hooks are removed

I presume this is only needed for netfilter queueing as well?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
