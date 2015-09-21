From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH RFC 0/3] Allow postponed netfilter handling for socket
 matches
Date: Mon, 21 Sep 2015 21:05:55 +0200
Message-ID: <20150921190555.GD931@breakpoint.cc>
References: <1442418180-14322-1-git-send-email-daniel@zonque.org>
 <20150916212100.GT24810@breakpoint.cc>
 <55FA902F.50006@zonque.org>
 <20150917160008.GA32700@breakpoint.cc>
 <560035B4.9010504@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, pablo@netfilter.org,
	daniel@iogearbox.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, balazs.scheidler@balabit.com
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:50560 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756162AbbIUTF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 15:05:58 -0400
Content-Disposition: inline
In-Reply-To: <560035B4.9010504@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Mack <daniel@zonque.org> wrote:
> >> LOCAL_IN, for ingress only? In a sense, it would be called from the
> >> protocol handlers, just as my patches do right now, but instead of
> >> conditionally re-iterating the same rules again, we would walk a
> >> different chain?
> > 
> > Yes, something like that.  Obviously, you'll need to dru^W brib^W
> > convince a LOT of people before that could ever fly.
> > 
> > I think we should not do this and that this 'match on ingress sk
> > properties' is just bad[tm].
> > 
> > f.e. you'd also have to move all of the stuff you want into
> > sock_common ... 8-(
> 
> Hmm, I'm not sure whether I understand which problems you see, or which
> corner cases I am missing in my assessment. I did a quick test with the
> attached 4 patches that
> 
> 1) Allow hook callbacks to look at the socket passed to nf_hook(), so
>    skb->sk does not have to be set
> 
> 2) Make nft_meta look at pkt->sk rather that skb->sk (only for cgroups
>    as proof of concept)
> 
> 3) Introduce a new POST_DEMUX netfilter chain (the name is not
>    perfect, admittedly)
> 
> 4) Iterate POST_DEMUX chains for v4 TCP and UDP unicast+multicast
>    sockets.
> 
> With some really trivial modifications to libnftnl/nftables (which just
> map strings to the new enum value), this works fine in my tests.
> Multicast receivers that match a netclass ID in the ruleset won't see
> any packets, while others do.
> 
> Some more considerations: if we cannot determine a socket for a packet
> and hence don't deliver it, it's IMO perfectly fine not to run the
> netfilter rules for them. All we need to achieve with this chain is that
> for packets that _are_ delivered to a socket, all the necessary rules
> have been processed, at a time when we know who the final receiver of
> the skb is.

Not sure if thats true.  What about Timewait sockets?

Its easy to imagine someone using this feature and then complaining
that it doesn't match some packets, at which point we'd have to grow
sock_common to accomondate all sk member we support matching for :-/

If we'd have kernel releases where we drop features this wouldn't be
much of an issue since we could back out in case it causes issues later.

But once we add your proposed feature we cannot go back...

I'm not sure; I dislike this feature proposal but I can't think of
any alternative [other than "don't do this"] :-(
