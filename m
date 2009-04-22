From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Wed, 22 Apr 2009 10:53:04 +0200
Message-ID: <49EEDAF0.2010507@cosmosbay.com>
References: <20090420103414.1b4c490f@nehalam> <49ECBE0A.7010303@cosmosbay.com> <18924.59347.375292.102385@cargo.ozlabs.ibm.com> <20090420215827.GK6822@linux.vnet.ibm.com> <18924.64032.103954.171918@cargo.ozlabs.ibm.com> <20090420160121.268a8226@nehalam> <alpine.LFD.2.00.0904210831560.2199@localhost.localdomain> <20090421111541.228e977a@nehalam> <20090421191007.GA15485@elte.hu> <49EE2293.4090201@cosmosbay.com> <20090422073524.GA31835@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36788 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752464AbZDVIyd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 04:54:33 -0400
In-Reply-To: <20090422073524.GA31835@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar a =E9crit :
> * Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20
>> Ingo Molnar a =E9crit :
>>> Why not use the obvious solution: a _single_ wrlock for global=20
>>> access and read_can_lock() plus per cpu locks in the fastpath?
>> Obvious is not the qualifier I would use :)
>>
>> Brilliant yes :)
>=20
> thanks :)
>=20
>>> That way there's no global cacheline bouncing (just the=20
>>> _reading_ of a global cacheline - which will be nicely localized=20
>>> - on NUMA too) - and we will hold at most 1-2 locks at once!
>>>
>>> Something like:
>>>
>>> 	__cacheline_aligned DEFINE_RWLOCK(global_wrlock);
>>>
>>> 	DEFINE_PER_CPU(rwlock_t local_lock);
>>>
>>>
>>> 	void local_read_lock(void)
>>> 	{
>>> 	again:
>>> 		read_lock(&per_cpu(local_lock, this_cpu));
>> Hmm... here we can see global_wrlock locked by on writer, while=20
>> this cpu already called local_read_lock(), and calls again this=20
>> function -> Deadlock, because we hold our local_lock locked.
>=20
> Yeah, indeed.
>=20
> I wasnt really concentrating on the nested case, i was concentrating=20
> on the scalability and lock nesting angle. I think the code=20
> submitted here looks rather incestous in that regard.
>=20
> Allowing nested locking _on the same CPU_ is asking for trouble. Use=20
> short critical sections and if there's any exclusion needed, use an=20
> irq-safe lock or a softirq-safe lock. Problem solved.
>=20
>> Very interesting and could be changed to use spinlock + depth per=20
>> cpu.
>>
>> -> we can detect recursion and avoid the deadlock, and we only use=20
>> one atomic operation per lock/unlock pair in fastpath (this was=20
>> the reason we tried hard to use a percpu spinlock during this=20
>> thread)
>>
>>
>> __cacheline_aligned DEFINE_RWLOCK(global_wrlock);
>>
>> struct ingo_local_lock {
>> 	spinlock_t lock;
>> 	int depth;
>> };
>> DEFINE_PER_CPU(struct ingo_local_lock local_lock);
>>
>>
>> void local_read_lock(void)
>> {
>> 	struct ingo_local_lock *lck;
>>
>> 	local_bh_and_preempt_disable();
>> 	lck =3D &get_cpu_var(local_lock);
>> 	if (++lck->depth > 0) /* already locked */
>> 		return;
>> again:
>> 	spin_lock(&lck->lock);
>>
>> 	if (unlikely(!read_can_lock(&global_wrlock))) {
>> 		spin_unlock(&lck->lock);
>> 		/*
>> 		 * Just wait for any global write activity:
>> 		 */
>> 		read_unlock_wait(&global_wrlock);
>> 		goto again;
>> 	}
>> }
>>
>> void global_write_lock(void)
>> {
>> 	write_lock(&global_wrlock);
>>
>> 	for_each_possible_cpu(i)
>> 		spin_unlock_wait(&per_cpu(local_lock, i));
>> }
>>
>> Hmm ?
>=20
> Yeah, this looks IRQ-nesting safe. But i really have to ask: why=20
> does this code try so hard to allow same-CPU nesting?
>=20
> Nesting on the same CPU is _bad_ for several reasons:
>=20
> 1) Performance: it rips apart critical sections cache-wise. Instead=20
>    of a nice:
>=20
>        C1 ... C2 ... C3 ... C4
>=20
>    serial sequence of critical sections, we get:
> =20
>        C1A ... ( C2 ) ... C1B ... C3 ... C4
>=20
>    Note that C1 got "ripped apart" into C1A and C1B with C2 injected=20
>    - reducing cache locality between C1A and C1B. We have to execute
>    C1B no matter what, so we didnt actually win anything in terms of=20
>    total work to do, by processing C2 out of order.
>=20
>    [ Preemption of work (which this kind of nesting is really about)
>      is _the anti-thesis of performance_, and we try to delay it as
>      much as possible and we try to batch up as much as possible.=20
>      For example the CPU scheduler will try _real_ hard to not=20
>      preempt a typical workload, as long as external latency=20
>      boundaries allow that. ]
>=20
> 2) Locking complexity and robustness. Nested locking is rank #1 in
>    terms of introducing regressions into the kernel.
>=20
> 3) Instrumentation/checking complexity. Checking locking=20
>    dependencies is good and catches a boatload of bugs before they=20
>    hit upstream, and nested locks are supported but cause an=20
>    exponential explosion in terms of dependencies to check.
>=20
>    Also, whenever instrumentation explodes is typically the sign of=20
>    some true, physical complexity that has been introduced into the=20
>    code. So it often is a canary for a misdesign at a fundamental=20
>    level, not a failure in the instrumentation framework.
>=20
> In the past i saw lock nesting often used as a wrong solution when=20
> the critical sections were too long (causing too long latencies for=20
> critical work - e.g. delaying hardirq completion processing=20
> unreasonably), or just plain out of confusion about the items above.
>=20

I agree with all this Ingo.

> I dont know whether that's the case here - it could be one of the=20
> rare exceptions calling for a new locking primitive (which should=20
> then be introduced at the core kernel level IMHO) - i dont know the=20
> code that well.


The netfilter case is real simple Ingo, (note I did not use "obvious" h=
ere ;) )

netfilter in 2.6.2[0-9] used :

CPU 1

sofirq handles one packet from a NIC

ipt_do_table() /* to handle INPUT table for example, or FORWARD */
read_lock_bh(&a_central_and_damn_rwlock)
=2E.. parse rules
    -> calling some netfilter sub-function
       re-entering network IP stack to send some packet (say a RST pack=
et)
       ...
       ipt_do_table() /* to handle OUPUT table rules for example */
       read_lock_bh() ; /* WE RECURSE here, but once in a while (if eve=
r) */


This is one of the case, but other can happens with virtual networks, t=
unnels, ...
and so on. (Stephen had some cases with KVM if I remember well)

If this could be done without recursion, I am pretty sure netfilter
and network guys would have done it. I found Linus reaction quite
shocking IMHO, considering hard work done by all people on this.

I was pleased by your locking schem, that was *very* interesting, even
if not yet ready.

1) We can discuss of how bad recursion is.

We know loopback_xmit() could be way faster if we could avoid queeing p=
acket
to softirq handler.
(Remember you and I suggested this patch some months ago ? Please remem=
ber
David rejected this because of recursion and possibility to overflow st=
ack)

So yes, people are aware of recursion problems.

2) We can discuss how bad rwlocks are

We did lot of work on last months to delete some of rwlocks we had in k=
ernel.
UDP stack for example dont use them anymore.

We tried to delete them on x_tables, but we must take care of ipt_do_ta=
ble() nesting,
that is legal on 2.6.30.
Maybe netfilter guys can work to avoid this nesting on 2.6.31,=20
I dont know how hard it is, definitly not 2.6.30 material.

Solutions were discussed many times and Stephen provided 13 versions of=
 the patch.
If this was that obvious, one or two iterations would have been OK.

3) About last patch (v13)
Stephen did not agreed with you (well... maybe after all ..),
he only submitted again a previous version.

With linux-2.6.2[0-9], "iptables -L" used to block all cpus from enteri=
ng netfilter
because we did a write_lock_bh() on the central rwlock while folding co=
unters.

On v13, we dont try to freeze whole x_table context, but cpu per cpu.
Thats a minor change against previous versions, and should not lead to =
strange
application behavior. Its so much scalable that we should accept this c=
hange.



