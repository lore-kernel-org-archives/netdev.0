From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v2 -next] net: fib: use fib result when zero-length
 prefix aliases exist
Date: Mon, 20 Jul 2015 13:15:40 +0200
Message-ID: <20150720111539.GB11985@breakpoint.cc>
References: <1437154621-18180-1-git-send-email-fw@strlen.de>
 <alpine.LFD.2.11.1507180045330.2410@ja.home.ssi.bg>
 <20150718180546.GA7835@breakpoint.cc>
 <alpine.LFD.2.11.1507191327090.1658@ja.home.ssi.bg>
 <20150719230345.GA11985@breakpoint.cc>
 <alpine.LFD.2.11.1507200938570.1481@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34251 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752667AbbGTLPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 07:15:42 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1507200938570.1481@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julian Anastasov <ja@ssi.bg> wrote:
> On Mon, 20 Jul 2015, Florian Westphal wrote:
> > The VM has two interfaces,
> > eth0, 192.168.7.10
> > eth1, 192.168.8.10
> > 
> > ip route del default
> > ip route add tos 0x0 via 192.168.7.1
> > ip route add tos 0x10 via 192.168.8.2
> > 
> > 7.1 is reachable via eth0 (7.10/24)
> > 8.2 *should* be rechable via eth1 (8.10/24)
> > 
> > I say *should* because I deliberately deleted this address from gateway
> > connected to that interface.
> > 
> > Now, I run
> > 
> > ping -Q 0x10 192.168.0.7
> > 
> > Packets get sent via tos 0x0.  So far, so good.
> > 
> > Now I add back 192.168.8.2.
> > 
> > But no probe takes place so packets continue to be sent via tos 0 route.
> > 
> > neigh_lookup returns NULL -> state is NUD_NONE -> gw is deemed unreachable
> 
> 	So, this is a case when configuration changes,
> for example, simple change in list of routes is not noticed?

There are no changes on the test system, the address 192.168.8.2 is
added back to the gateway only.

> 	May be we can just play with the state as already
> discussed? Example separate diff (to be ported for net-next).
> 
> ipv4: be more aggressive when probing alternative gateways
> 
> Currently, we do not notice if new alternative gateways
> are added. We can do it by checking for present neigh
> entry. Also, gateways that are currently probed (NUD_INCOMPLETE)
> can be skipped from round-robin probing.
> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index c7358ea..cd1732a 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -421,13 +421,15 @@ static int fib_detect_death(struct fib_info *fi, int order,
>  	if (n) {
>  		state = n->nud_state;
>  		neigh_release(n);
> +	} else {
> +		return 0;
>  	}
>  	if (state == NUD_REACHABLE)
>  		return 0;
>  	if ((state & NUD_VALID) && order != dflt)
>  		return 0;
>  	if ((state & NUD_VALID) ||
> -	    (*last_idx < 0 && order > dflt)) {
> +	    (*last_idx < 0 && order > dflt && state != NUD_INCOMPLETE)) {
>  		*last_resort = fi;
>  		*last_idx = order;
>  	}

I think its a good idea.

Could you please submit your two patches (tos fix and this one)
formally?

Thanks!
