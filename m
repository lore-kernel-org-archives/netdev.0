From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 0/4] Netfilter ingress support (v3)
Date: Mon, 4 May 2015 18:19:56 +0200
Message-ID: <20150504161956.GK22481@breakpoint.cc>
References: <1430736649-3546-1-git-send-email-pablo@netfilter.org>
 <20150504155639.GA14367@Alexeis-MBP.westell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, kaber@trash.net, jhs@mojatatu.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:46595 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750820AbbEDQUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 12:20:02 -0400
Content-Disposition: inline
In-Reply-To: <20150504155639.GA14367@Alexeis-MBP.westell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> > Another round of the patchset to add Netfilter ingress support. This new
> > patchset introduces the necessary updates in 2 steps:
> > 
> > 1) Add minismalistic ingress hook infrastructure that allows to register one
> >    client at a time, so you hit -EBUSY in case the hook is in use. Basically,
> >    we have a function pointer that is rcu-protected to invoke the corresponding
> >    filter framework which has minimal performance impact in the critical ingress
> >    path and avoid more pollution in it. This patch also ports the ingress qdisc
> >    on top of this.
> ...
> > In summary, this provides the facility to keep both tc and netfilter in place,
> > while the user can select what they prefer to filter from ingress.
> 
> wow, I have to say I'm impressed. That's the most genius way to
> really kill TC.
> Patch 1 looks good, patch 2,3,4 are nicely building on top...
> until somebody starts asking how patch 5 will look.
> In the future netfilter ingress module will be loaded along with
> other iptables modules just like conntrack is today and users
> who would want to use ingress tc would have to _unload_
> netfilter_ingress module, but if it has interesting dependencies
> it may mean to unload iptables and the rest.

FWIW while I think this is a valid concern, I believe its unfounded.

netfilter_ingress must not force run-time
dependencies like 'oh, you want tc, too bad, no conntrack for you)'.

(and i don't see any need for such a dependency).

> So at the end the users will have a binary choice either to use
> iptables/nft or use tc, because they won't be able to co-exist
> because ingress_hook is the only one.
> I don't understand this 'tc hate'. Why go out of the way to
> make TC more difficult to use ?

I don't see this having anything to do with 'TC hate'.

Lets face it, tc and netfilter are horrid when it comes to play
nice with each other, and functionality provided by both partially
overlaps.

Just look at all the hacks we have in tc to use netfilter (iptables,
conntrack) functionality, or even iptables CLASSIFY target (aka
"tc filters are too hard for me").

In case there is later some really good reason why you need both
tc ingress and nft ingress simultaneously then we can always revisit this
and add a second hook for coexistence, at the expense of more
complexity.

> Just add _new_ hook for netfilter ingress and both subsystems
> can happily co-exist.

I don't see a use case where you'd need both tc ingress and nft
ingress at the same time.  Can you elaborate?

At the moment I think having two hooks provides no advantage, it only
complicates code.
