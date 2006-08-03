From: Patrick McHardy <kaber@trash.net>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help() 2.6.18-rc3
Date: Thu, 03 Aug 2006 11:21:45 +0200
Message-ID: <44D1C029.1030300@trash.net>
References: <44CD8415.2020403@davidcoulson.net> <44CD85FF.9010607@trash.net> <20060730.215907.58439803.davem@davemloft.net> <44CD9013.7020401@trash.net> <44CDDDF7.70004@trash.net> <20060731113050.GA25972@gondor.apana.org.au> <44CE4DCA.8000609@trash.net> <44CF0086.1030404@trash.net> <20060801115102.GA5638@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:9723 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S932421AbWHCJVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 05:21:47 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060801115102.GA5638@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Tue, Aug 01, 2006 at 09:19:34AM +0200, Patrick McHardy wrote:
> 
>>- nfct/nfctinfo/nfct_reasm: the xfrm output path does an immediate
>>  nf_reset, so they were not necessary until now. Queueing can happen
>>  on any hook, so we need to preserve them.
> 
> 
> This looks OK to me.  However, we should do this in a wrapper around
> skb_gso_segment rather than in skb_segment.
> 
> The idea with skb_gso_segment is that it's the most generic (or basic)
> level of service which is needed by everyone.  If you need anything
> more specific, you can do it around skb_gso_segment.
> 
> For exmample, dev_gso_segment is the version that's tailored for
> device transmission.
> 
> So I'd imagine something like
> 
> nf_gso_segment(skb)
> {
> 	segs = skb_gso_segment(skb, 0);
> 	if (IS_ERR(segs))
> 		goto out;
> 
> 	nskb = segs;
> 	do {
> 		copy_nf_attributes(nskb, skb);
> 	} while ((nskb = nskb->next));
> 
> out:
> 	kfree_skb(skb);
> 	return segs;
> }

This looks OK. But we also need this for the redirect to loopback case,
do you want me to put it in dev_gso_segment as well? nfmark and
secmark should go in skb_segment I guess?

>>- nf_bridge: needed for GSO on a bridge device until the deferred
>>  hooks are removed
> 
> 
> I presume this is only needed for netfilter queueing as well?

No, we also need this for XFRM until the deferred hooks are removed.
It is allocated on the first invocation of the NF_IP_LOCAL_OUT hook
and bridge netfilter expects it to be present later on.
