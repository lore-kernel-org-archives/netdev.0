From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Tue, 21 Apr 2009 10:55:59 +0200
Message-ID: <49ED8A1F.7090506@cosmosbay.com>
References: <49ECBE0A.7010303@cosmosbay.com> <18924.59347.375292.102385@cargo.ozlabs.ibm.com> <20090420215827.GK6822@linux.vnet.ibm.com> <18924.64032.103954.171918@cargo.ozlabs.ibm.com> <20090420160121.268a8226@nehalam> <49ED406F.2040401@cn.fujitsu.com> <49ED4407.8010200@cosmosbay.com> <49ED5813.1000803@cn.fujitsu.com> <20090420224540.30d7b0ed@nehalam> <49ED6D2E.5060808@cn.fujitsu.com> <20090421081649.GA16782@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, jeff.chua.linux@gmail.com,
	mingo@elte.hu, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39079 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752011AbZDUI57 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 04:57:59 -0400
In-Reply-To: <20090421081649.GA16782@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov a =E9crit :
> Hi.
>=20
> On Tue, Apr 21, 2009 at 02:52:30PM +0800, Lai Jiangshan (laijs@cn.fuj=
itsu.com) wrote:
>>> +void xt_info_rdlock_bh(void)
>>>> +{
>>>> +	struct xt_info_lock *lock;
>>>> +
>>>> +	preempt_disable();
>>>> +	lock =3D &__get_cpu_var(xt_info_locks);
>>>> +	if (likely(++lock->depth =3D=3D 0))
>> So what happen when xt_info_rdlock_bh() called recursively here?
>>
>>>> +		spin_lock_bh(&lock->lock);
>>>> +	preempt_enable_no_resched();
>>>> +}
>>>> +EXPORT_SYMBOL_GPL(xt_info_rdlock_bh);
>>>> +
>> ----------
>> Is this OK? (Now I suppose we can enter the read-side critical regio=
n
>> in irq context)
>>
>> void xt_info_rdlock_bh(void)
>> {
>> 	unsigned long flags;
>> 	struct xt_info_lock *lock;
>>
>> 	local_irq_save(flags);
>> 	lock =3D &__get_cpu_var(xt_info_locks);
>> 	if (likely(++lock->depth =3D=3D 0))
>> 		spin_lock_bh(&lock->lock);
>> 	local_irq_restore(flags);
>> }
>=20
> Netfilter as long as other generic network pathes are never accessed
> from interrupt context, but your analysis looks right for the softirq
> case.
>=20
> Stephen, should preempt_disable() be replaced with local_bh_disable()=
 to
> prevent softirq to race on the same cpu for the lock's depth field? O=
r
> can it be made atomic?
>=20


Maybe just dont care about calling several time local_bh_disable()
(since we were doing this in previous kernels anyway, we used to call r=
ead_lock_bh())

This shortens fastpath, is faster than local_irq_save()/local_irq_resto=
re(),
and looks better.

void xt_info_rdlock_bh(void)
{
	struct xt_info_lock *lock;

	local_bh_disable();
 	lock =3D &__get_cpu_var(xt_info_locks);
 	if (likely(++lock->depth =3D=3D 0))
 		spin_lock(&lock->lock);
}

void xt_info_rdunlock_bh(void)
{
	struct xt_info_lock *lock =3D &__get_cpu_var(xt_info_locks);

	BUG_ON(lock->depth < 0);
	if (likely(--lock->depth < 0))
		 spin_unlock(&lock->lock);
	local_bh_enable();
}



