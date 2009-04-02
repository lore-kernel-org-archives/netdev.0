From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] percpu: convert SNMP mibs to new infra
Date: Thu, 02 Apr 2009 07:19:19 +0200
Message-ID: <49D44AD7.8010305@cosmosbay.com>
References: <49D32212.80607@cosmosbay.com> <49D3A0C2.9000403@cosmosbay.com> <49D3B61F.8010507@cosmosbay.com> <200904021534.34084.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>, Jeremy Fitzhardinge <jeremy@goop.org>,
	Tejun Heo <htejun@gmail.com>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43671 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbZDBFTs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 01:19:48 -0400
In-Reply-To: <200904021534.34084.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell a =E9crit :
> On Thursday 02 April 2009 05:14:47 Eric Dumazet wrote:
>> Here is a preliminary patch for SNMP mibs that seems to work well on=
 x86_32
>>
>> [RFC] percpu: convert SNMP mibs to new infra
>=20
> OK, I have a whole heap of "convert to dynamic per-cpu" patches waiti=
ng in
> the wings too, once Tejun's conversion is complete.
>=20
> Also, what is optimal depends on the arch: we had a long discussion o=
n this
> (it's what local_t was supposed to do, with cpu_local_inc() etc: see
> Subject: local_add_return 2008-12-16 thread).
>=20
> eg. on S/390, atomic_inc is a win over the two-counter version.  On S=
parc,
> two-counter wins.  On x86, inc wins (obviously).
>=20
> But efforts to create a single primitive have been problematic: maybe
> open-coding it like this is the Right Thing.
>=20

I tried to find a generic CONFIG_ define that would annonce that an arc=
he
has a fast percpu_add() implementation. (faster than __raw_get_cpu_var,
for example, when we already are in a preempt disabled section)

Any idea ?


=46or example, net/ipv4/route.c has :

static DEFINE_PER_CPU(struct rt_cache_stat, rt_cache_stat);
#define RT_CACHE_STAT_INC(field) \
        (__raw_get_cpu_var(rt_cache_stat).field++)

We could use percpu_add(rt_cache_stat.field, 1) instead, only if percpu=
_add()
is not the generic one.

#define __percpu_generic_to_op(var, val, op)                           =
 \
do {                                                                   =
 \
        get_cpu_var(var) op val;                                       =
 \
        put_cpu_var(var);                                              =
 \
} while (0)
#ifndef percpu_add
# define percpu_add(var, val)           __percpu_generic_to_op(var, (va=
l), +=3D)
#endif

