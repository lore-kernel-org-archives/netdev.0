From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [patch 3/4] net: Percpufy frequently used variables -- proto.sockets_allocated
Date: Sat, 28 Jan 2006 01:35:03 +0100
Message-ID: <43DABC37.6070603@cosmosbay.com>
References: <20060126185649.GB3651@localhost.localdomain>	<20060126190357.GE3651@localhost.localdomain>	<43D9DFA1.9070802@cosmosbay.com>	<20060127195227.GA3565@localhost.localdomain>	<20060127121602.18bc3f25.akpm@osdl.org>	<20060127224433.GB3565@localhost.localdomain>	<43DAA586.5050609@cosmosbay.com> <20060127151635.3a149fe2.akpm@osdl.org> <43DABAA4.8040208@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>, kiran@scalex86.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	shai@scalex86.org, netdev@vger.kernel.org, pravins@calsoftinc.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422748AbWA1AfK@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <43DABAA4.8040208@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet a =E9crit :
> Andrew Morton a =E9crit :
>> Eric Dumazet <dada1@cosmosbay.com> wrote:
>>> Ravikiran G Thirumalai a =E9crit :
>>>> On Fri, Jan 27, 2006 at 12:16:02PM -0800, Andrew Morton wrote:
>>>>> Ravikiran G Thirumalai <kiran@scalex86.org> wrote:
>>>>>> which can be assumed as not frequent.  At=20
>>>>>> sk_stream_mem_schedule(), read_sockets_allocated() is invoked on=
ly=20
>>>>>> certain conditions, under memory pressure -- on a large CPU coun=
t=20
>>>>>> machine, you'd have large memory, and I don't think=20
>>>>>> read_sockets_allocated would get called often.  It did not atlea=
st=20
>>>>>> on our 8cpu/16G box.  So this should be OK I think.
>>>>> That being said, the percpu_counters aren't a terribly successful=
=20
>>>>> concept
>>>>> and probably do need a revisit due to the high inaccuracy at high=
 CPU
>>>>> counts.  It might be better to do some generic version of=20
>>>>> vm_acct_memory()
>>>>> instead.
>>>> AFAICS vm_acct_memory is no better.  The deviation on large cpu=20
>>>> counts is the same as percpu_counters -- (NR_CPUS * NR_CPUS * 2) .=
=2E.
>>> Ah... yes you are right, I read min(16, NR_CPUS*2)
>>
>> So did I ;)
>>
>>> I wonder if it is not a typo... I mean, I understand the more cpus=20
>>> you have, the less updates on central atomic_t is desirable, but a=20
>>> quadratic offset seems too much...
>>
>> I'm not sure whether it was a mistake or if I intended it and didn't=
=20
>> do the
>> sums on accuracy :(
>>
>> An advantage of retaining a spinlock in percpu_counter is that if=20
>> accuracy
>> is needed at a low rate (say, /proc reading) we can take the lock an=
d=20
>> then
>> go spill each CPU's local count into the main one.  It would need to=
 be a
>> very low rate though.   Or we make the cpu-local counters atomic too=
=2E
>=20
> We might use atomic_long_t only (and no spinlocks)
> Something like this ?
>=20
>=20
> ---------------------------------------------------------------------=
---
>=20
> struct percpu_counter {
> 	atomic_long_t count;
> 	atomic_long_t *counters;
> };
>=20
> #ifdef CONFIG_SMP
> void percpu_counter_mod(struct percpu_counter *fbc, long amount)
> {
> 	long old, new;
> 	atomic_long_t *pcount;
>=20
> 	pcount =3D per_cpu_ptr(fbc->counters, get_cpu());
> start:
> 	old =3D atomic_long_read(pcount);
> 	new =3D old + amount;
> 	if (new >=3D FBC_BATCH || new <=3D -FBC_BATCH) {
> 		if (unlikely(atomic_long_cmpxchg(pcount, old, 0) !=3D old))
> 			goto start;
> 		atomic_long_add(new, &fbc->count);
> 	} else
> 		atomic_long_add(amount, pcount);
>=20
> 	put_cpu();
> }
> EXPORT_SYMBOL(percpu_counter_mod);
>=20
> long percpu_counter_read_accurate(struct percpu_counter *fbc)
> {
> 	long res =3D 0;
> 	int cpu;
> 	atomic_long_t *pcount;
>=20
> 	for_each_cpu(cpu) {
> 		pcount =3D per_cpu_ptr(fbc->counters, cpu);
> 		/* dont dirty cache line if not necessary */
> 		if (atomic_long_read(pcount))
> 			res +=3D atomic_long_xchg(pcount, 0);
> 	}

	atomic_long_add(res, &fbc->count);
	res =3D atomic_long_read(&fbc->count);

> 	return res;
> }
> EXPORT_SYMBOL(percpu_counter_read_accurate);
> #endif /* CONFIG_SMP */
>=20
