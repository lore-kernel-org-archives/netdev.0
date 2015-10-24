From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: no CHECKSUM_PARTIAL on skbs with extension headers
 and recalc checksum during fragmentation
Date: Sat, 24 Oct 2015 16:21:43 +0200
Message-ID: <1445696503.1071726.419107593.5D23540A@webmail.messagingengine.com>
References: <1445605987-15625-1-git-send-email-hannes@stressinduktion.org>
 <1445640525.22974.195.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Benjamin Coddington <bcodding@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:41187 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751766AbbJXOVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2015 10:21:44 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 0D2F22039E
	for <netdev@vger.kernel.org>; Sat, 24 Oct 2015 10:21:44 -0400 (EDT)
In-Reply-To: <1445640525.22974.195.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sat, Oct 24, 2015, at 00:48, Eric Dumazet wrote:
> On Fri, 2015-10-23 at 15:13 +0200, Hannes Frederic Sowa wrote:
> > CHECKSUM_PARTIAL should only be used on plain vanilla IPv6 + UDP packets
> > in ip6_append_data. Some drivers don't correctly handle extension headers,
> > especially not ipv6 fragmentation which could result in broken checksums.
> > 
> > 1) This patch improves the test for fragmentation and extension headers
> > in ip6_append_data, so we set the ip_summed mode as early as possible
> > to the correct value to compute the checksum during memory copy-in from
> > user space.
> > 
> > 2) We always call skb_checksum_help on CHECKSUM_PARTIAL fragments in
> > ip6_fragment, because we don't know if the underlying hardware can deal
> > with ip6_fragments.
> > 
> > Fixes: commit 32dce968dd987 ("ipv6: Allow for partial checksums on non-ufo packets")
> > See-also: commit 72e843bb09d45 ("ipv6: ip6_fragment() should check CHECKSUM_PARTIAL")
> > Cc: Eric Dumazet <edumazet@google.com>
> > Cc: Vlad Yasevich <vyasevich@gmail.com>
> > Cc: Benjamin Coddington <bcodding@redhat.com>
> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > ---
> >  net/ipv6/ip6_output.c | 78 ++++++++++++++++++++++++---------------------------
> >  1 file changed, 37 insertions(+), 41 deletions(-)
> > 
> > diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> > index 8dddb45..26d2911 100644
> > --- a/net/ipv6/ip6_output.c
> > +++ b/net/ipv6/ip6_output.c
> > @@ -593,6 +593,10 @@ int ip6_fragment(struct sock *sk, struct sk_buff *skb,
> >  	frag_id = ipv6_select_ident(net, &ipv6_hdr(skb)->daddr,
> >  				    &ipv6_hdr(skb)->saddr);
> >  
> > +	if ((skb->ip_summed == CHECKSUM_PARTIAL) &&
> > +	    (err = skb_checksum_help(skb)))
> > +		goto fail;
> > +
> >  	hroom = LL_RESERVED_SPACE(rt->dst.dev);
> >  	if (skb_has_frag_list(skb)) {
> >  		int first_len = skb_pagelen(skb);
> > @@ -721,10 +725,6 @@ slow_path_clean:
> >  	}
> >  
> >  slow_path:
> > -	if ((skb->ip_summed == CHECKSUM_PARTIAL) &&
> > -	    skb_checksum_help(skb))
> > -		goto fail;
> > -
> 
> 
> It looks like this patch could be split in two, to ease future bisection
> maybe ?

Sure, will split it up.

Thanks Eric!
