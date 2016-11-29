From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net] openvswitch: Fix skb leak in IPv6 reassembly.
Date: Tue, 29 Nov 2016 01:45:05 +0100
Message-ID: <20161129004505.GB11456@breakpoint.cc>
References: <20161128234353.4262-1-diproiettod@ovn.org>
 <1480378950.18162.107.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniele Di Proietto <diproiettod@ovn.org>, netdev@vger.kernel.org,
        Florian Westphal <fw@strlen.de>,
        Pravin B Shelar <pshelar@ovn.org>, Joe Stringer <joe@ovn.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:39118 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752872AbcK2AsB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 19:48:01 -0500
Content-Disposition: inline
In-Reply-To: <1480378950.18162.107.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2016-11-28 at 15:43 -0800, Daniele Di Proietto wrote:
> > If nf_ct_frag6_gather() returns an error other than -EINPROGRESS, it
> > means that we still have a reference to the skb.  We should free it
> > before returning from handle_fragments, as stated in the comment above.
> > 
> > Fixes: daaa7d647f81 ("netfilter: ipv6: avoid nf_iterate recursion")
> > CC: Florian Westphal <fw@strlen.de>
> > CC: Pravin B Shelar <pshelar@ovn.org>
> > CC: Joe Stringer <joe@ovn.org>
> > Signed-off-by: Daniele Di Proietto <diproiettod@ovn.org>
> > ---
> >  net/openvswitch/conntrack.c | 5 ++++-
> >  1 file changed, 4 insertions(+), 1 deletion(-)
> > 
> > diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
> > index 31045ef..fecefa2 100644
> > --- a/net/openvswitch/conntrack.c
> > +++ b/net/openvswitch/conntrack.c
> > @@ -370,8 +370,11 @@ static int handle_fragments(struct net *net, struct sw_flow_key *key,
> >  		skb_orphan(skb);
> >  		memset(IP6CB(skb), 0, sizeof(struct inet6_skb_parm));
> >  		err = nf_ct_frag6_gather(net, skb, user);
> > -		if (err)
> > +		if (err) {
> > +			if (err != -EINPROGRESS)
> > +				kfree_skb(skb);
> >  			return err;
> > +		}
> >  
> >  		key->ip.proto = ipv6_hdr(skb)->nexthdr;
> >  		ovs_cb.mru = IP6CB(skb)->frag_max_size;
> 
> Interesting, have you followed the "GPF in eth_header" thread today ?
> 
> In a nutshell, we want a complete patch, not something that would solve
> part of the problem.

I think this patch is fine, intent seems to be to only take fully reassembled
skb, rather than a stray fragment (ovs does NOT seem to call handle_fragments
in case skb is already known to not contain a fragment header, afaics).

I'll send a patch for the GPF in eth_header thing soon.
