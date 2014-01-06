From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 01/12] netfilter: avoid get_random_bytes calls
Date: Mon, 6 Jan 2014 12:54:36 +0100
Message-ID: <20140106115436.GE28854@breakpoint.cc>
References: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
 <1388963586-5049-2-git-send-email-pablo@netfilter.org>
 <20140105234157.GB29910@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, fw@strlen.de
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140105234157.GB29910@order.stressinduktion.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> On Mon, Jan 06, 2014 at 12:12:55AM +0100, Pablo Neira Ayuso wrote:
> > From: Florian Westphal <fw@strlen.de>
> > 
> > All these users need an initial seed value for jhash, prandom is
> > perfectly fine.  This avoids draining the entropy pool where
> > its not strictly required.
> 
> Secrets protecting hash tables should be rather strong.

Yes, which is why e.g. conntrack hash is not converted.

> prandom_u32() has two seeding points at boot-up. One is at late_initcall.

Yes.  None of these locations are executed via initcalls, they are all
in _checkentry (i.e., run when userspace iptables inserts a rule using
the target/match), except hashlimit where its delayed until the first
address is stored (so its even later).

> Thanks to parallel boot-up this gets executed fairly early. The other one is
> when the RNG nonblocking pool is fully initialized. Only after this point we
> can assume prandom_u32() returns truely random values. In between, only
> get_random_bytes or net_get_random_once are safe for use.

Can you elaborate?  If entropy estimate is really really low
(because we're booting up), why would get_random_bytes() be a better
choice [ i understand net_get_random_once() is for delaying
the actual random_bytes call until a later point in time where we've
hopefully collected more entropy ]

> To get the impression when prandom_u32 gets truely seeded, watch out
> for the message "random: nonblocking pool is initialized" in dmesg. ;)

It happens very very early on my machine, even before / is remounted
rw.  I would be more interested in what happens on small embedded
boxes...

> Hmm, some of them look like good candidates for net_get_random_once. I don't
> see such a problem with draining entropy pool, especially as they don't run
> that early and they don't request so many random bits.

I specifically did not use net_get_random_once once because checkentry is
not a hotpath.

I don't see why get_random_bytes use increases the security margin, especially
considering none of these hashes have periodic run-time rehashing?

But sure, if you think this change is a problem, Pablo can just revert it.
