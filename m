From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC] percpu: convert SNMP mibs to new infra
Date: Thu, 2 Apr 2009 22:16:23 +1030
Message-ID: <200904022216.24259.rusty@rustcorp.com.au>
References: <49D32212.80607@cosmosbay.com> <200904021534.34084.rusty@rustcorp.com.au> <49D44AD7.8010305@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, Jeremy Fitzhardinge <jeremy@goop.org>,
	Tejun Heo <htejun@gmail.com>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758812AbZDBLqw@vger.kernel.org>
In-Reply-To: <49D44AD7.8010305@cosmosbay.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 02 April 2009 15:49:19 Eric Dumazet wrote:
> Rusty Russell a =E9crit :
> > eg. on S/390, atomic_inc is a win over the two-counter version.  On=
 Sparc,
> > two-counter wins.  On x86, inc wins (obviously).
> >=20
> > But efforts to create a single primitive have been problematic: may=
be
> > open-coding it like this is the Right Thing.
>=20
> I tried to find a generic CONFIG_ define that would annonce that an a=
rche
> has a fast percpu_add() implementation. (faster than __raw_get_cpu_va=
r,
> for example, when we already are in a preempt disabled section)

Nope, we don't have one.  It was supposed to work like this:
	DEFINE_PER_CPU(local_t, counter);

	cpu_local_inc(counter);

That would do incl in x86, local_t could even be a long[3] (one for har=
dirq,
one for softirq, one for user context).  But there were issues:

1) It didn't work on dynamic percpu allocs, which was much of the inter=
esting
   use (Tejun is fixing this bit right now)
2) The x86 version wasn't optimized anyway,
3) Everyone did atomic_long_inc(), so the ftrace code assumed it would =
be nmi
   safe (tho atomic_t isn't nmi-safe on some archs anyway), so the long=
[3]
   method would break them,
4) The long[3] version was overkill for networking, which doesn't need =
hardirq
   so we'd want another variant of local_t plus all the ops,
5) Some people didn't want long: Christoph had a more generic but more =
complex
   version,
6) It's still not used anywhere in the tree (tho local_t is), so there'=
s no
   reason to stick to the current semantics.

> For example, net/ipv4/route.c has :
>=20
> static DEFINE_PER_CPU(struct rt_cache_stat, rt_cache_stat);
> #define RT_CACHE_STAT_INC(field) \
>         (__raw_get_cpu_var(rt_cache_stat).field++)
>=20
> We could use percpu_add(rt_cache_stat.field, 1) instead, only if perc=
pu_add()
> is not the generic one.

Yep, but this one is different from the SNMP stats which needs softirq =
vs
user context safety.  This is where I start wondering how many interfac=
es
we're going to have...

Sorry to add more questions than answers :(
Rusty.
