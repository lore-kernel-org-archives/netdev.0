From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 0/4] Netfilter ingress support (v3)
Date: Mon, 4 May 2015 19:43:58 +0200
Message-ID: <20150504174358.GN22481@breakpoint.cc>
References: <1430736649-3546-1-git-send-email-pablo@netfilter.org>
 <20150504155639.GA14367@Alexeis-MBP.westell.com>
 <20150504161956.GK22481@breakpoint.cc>
 <5547AA9C.3030300@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, kaber@trash.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5547AA9C.3030300@mojatatu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 05/04/15 12:19, Florian Westphal wrote:
> >Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> 
> >>wow, I have to say I'm impressed. That's the most genius way to
> >>really kill TC.
> >>Patch 1 looks good, patch 2,3,4 are nicely building on top...
> >>until somebody starts asking how patch 5 will look.
> >>In the future netfilter ingress module will be loaded along with
> >>other iptables modules just like conntrack is today and users
> >>who would want to use ingress tc would have to _unload_
> >>netfilter_ingress module, but if it has interesting dependencies
> >>it may mean to unload iptables and the rest.
> >
> >FWIW while I think this is a valid concern, I believe its unfounded.
> >
> >netfilter_ingress must not force run-time
> >dependencies like 'oh, you want tc, too bad, no conntrack for you)'.
> >
> >(and i don't see any need for such a dependency).
> >
> 
> It is an either-or choice. You cant have both.

Again, why is there a need to have both (at same time)?

> The _evil genius_ part i

Please don't accuse anyone of being 'evil'.

I think that tc and netfilter are both broken by design in the sense
that we have two different systems with partially overlapping
functionality while interaction between them consists of hacks.

It works both ways, iptables CLASSIFY target is also not very
elegant from a design point of view, it bolts the packet/connection matching
functionality provided by iptables to qdisc hierarchy.

> think is that distros which ship with iptables rules and conntracking
> on are going to not even turn on tc and my scripts now have to go
> unload one.

You mean add 'rmmod nft_ingress' or something similar?

That might be a problem.  One possible way out would be to
make 'tc qdisc add dev eth0 ingress' silently unregister nft ingress
on kernel side (but not vice versa).

Not nice, but it would keep compatibility with tc ingress scripts.

> But even if the scripts worked (perhaps there are plans to make sure
> all scripts continue to work transparently), i care about performance
> and  youve suddenly taken that away from me.

I don't think thats an unsolveable problem, currently we have the
qdisc->enqueue() indirection, now we have hook + qdisc->enqueue() BUT
AFAIU the latter could now be avoided by having ingress hook
interact with sch_ingress directly.

That being said, I am not opposed to two hooks, I just don't see any
technical reason whatsoever why one would need two different ingress
classification engines in use at same time.
