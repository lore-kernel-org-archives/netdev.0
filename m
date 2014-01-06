From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 01/12] netfilter: avoid get_random_bytes calls
Date: Mon, 6 Jan 2014 13:43:40 +0100
Message-ID: <20140106124340.GC4611@order.stressinduktion.org>
References: <1388963586-5049-1-git-send-email-pablo@netfilter.org> <1388963586-5049-2-git-send-email-pablo@netfilter.org> <20140105234157.GB29910@order.stressinduktion.org> <20140106115436.GE28854@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42005 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbaAFMnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 07:43:42 -0500
Content-Disposition: inline
In-Reply-To: <20140106115436.GE28854@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On Mon, Jan 06, 2014 at 12:54:36PM +0100, Florian Westphal wrote:
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> > On Mon, Jan 06, 2014 at 12:12:55AM +0100, Pablo Neira Ayuso wrote:
> > > From: Florian Westphal <fw@strlen.de>
> > > 
> > > All these users need an initial seed value for jhash, prandom is
> > > perfectly fine.  This avoids draining the entropy pool where
> > > its not strictly required.
> > 
> > Secrets protecting hash tables should be rather strong.
> 
> Yes, which is why e.g. conntrack hash is not converted.
> 
> > prandom_u32() has two seeding points at boot-up. One is at late_initcall.
> 
> Yes.  None of these locations are executed via initcalls, they are all
> in _checkentry (i.e., run when userspace iptables inserts a rule using
> the target/match), except hashlimit where its delayed until the first
> address is stored (so its even later).
> 
> > Thanks to parallel boot-up this gets executed fairly early. The other one is
> > when the RNG nonblocking pool is fully initialized. Only after this point we
> > can assume prandom_u32() returns truely random values. In between, only
> > get_random_bytes or net_get_random_once are safe for use.
> 
> Can you elaborate?  If entropy estimate is really really low
> (because we're booting up), why would get_random_bytes() be a better
> choice [ i understand net_get_random_once() is for delaying
> the actual random_bytes call until a later point in time where we've
> hopefully collected more entropy ]

I hope, I answer that below.

> > To get the impression when prandom_u32 gets truely seeded, watch out
> > for the message "random: nonblocking pool is initialized" in dmesg. ;)
> 
> It happens very very early on my machine, even before / is remounted
> rw.  I would be more interested in what happens on small embedded
> boxes...

On some of my small virtual machines (amd64) I even see this message while
login on the console (small iptables set also loaded before). In the mean
time prandom_u32() is still seeded with maybe 3 bits (I once measured it)
at the beginning and won't get a refresh until the nonblocking pool is
fully initialized. prandom_u32 will just iterate over its seed until it
is renewed whereas get_random_bytes does try to stretch (with help of the
twisted GFSR and SHA-1) the available entropy in case the nonblocking_pool
is limited, thus it is more probable to get better random results.

E.g. on an amd64 athlon x2 with two VMs:
[Mon Jan  6 13:35:40 2014] Initializing cgroup subsys cpuset
...
[Mon Jan  6 13:36:21 2014] random: nonblocking pool is initialized

I normally get the message while typing in the password on the prompt of the
serial console.

Single integers are not so much of a problem. E.g. one problem in
wireless code was, where get_random_bytes was called in a loop to fill
a structure, that did hurt: f7d8ad81ca8c44 ("mac80211: minstrels: spare
numerous useless calls to get_random_bytes").

> > Hmm, some of them look like good candidates for net_get_random_once. I don't
> > see such a problem with draining entropy pool, especially as they don't run
> > that early and they don't request so many random bits.
> 
> I specifically did not use net_get_random_once once because checkentry is
> not a hotpath.
> 
> I don't see why get_random_bytes use increases the security margin, especially
> considering none of these hashes have periodic run-time rehashing?
> 
> But sure, if you think this change is a problem, Pablo can just revert it.

I don't know if it is a real problem. Most of the time the initial seed
should be enough, but I guess get_random_bytes would still be a more
defensive choice. I would have used it. ;)

Greetings,

  Hannes
