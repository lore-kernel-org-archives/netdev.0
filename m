From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: [patch 3/4] net: Percpufy frequently used variables -- proto.sockets_allocated
Date: Fri, 27 Jan 2006 20:52:48 -0800
Message-ID: <20060128045248.GA3584@localhost.localdomain>
References: <20060126185649.GB3651@localhost.localdomain> <20060126190357.GE3651@localhost.localdomain> <43D9DFA1.9070802@cosmosbay.com> <20060127195227.GA3565@localhost.localdomain> <20060127121602.18bc3f25.akpm@osdl.org> <20060127224433.GB3565@localhost.localdomain> <43DAA586.5050609@cosmosbay.com> <20060127151635.3a149fe2.akpm@osdl.org> <43DABAA4.8040208@cosmosbay.com> <43DABC37.6070603@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, shai@scalex86.org,
	netdev@vger.kernel.org, pravins@calsoftinc.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932518AbWA1Ews@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <43DABC37.6070603@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 28, 2006 at 01:35:03AM +0100, Eric Dumazet wrote:
> Eric Dumazet a =E9crit :
> >Andrew Morton a =E9crit :
> >>Eric Dumazet <dada1@cosmosbay.com> wrote:
> >
> >#ifdef CONFIG_SMP
> >void percpu_counter_mod(struct percpu_counter *fbc, long amount)
> >{
> >	long old, new;
> >	atomic_long_t *pcount;
> >
> >	pcount =3D per_cpu_ptr(fbc->counters, get_cpu());
> >start:
> >	old =3D atomic_long_read(pcount);
> >	new =3D old + amount;
> >	if (new >=3D FBC_BATCH || new <=3D -FBC_BATCH) {
> >		if (unlikely(atomic_long_cmpxchg(pcount, old, 0) !=3D old))
> >			goto start;
> >		atomic_long_add(new, &fbc->count);
> >	} else
> >		atomic_long_add(amount, pcount);
> >
> >	put_cpu();
> >}
> >EXPORT_SYMBOL(percpu_counter_mod);
> >
> >long percpu_counter_read_accurate(struct percpu_counter *fbc)
> >{
> >	long res =3D 0;
> >	int cpu;
> >	atomic_long_t *pcount;
> >
> >	for_each_cpu(cpu) {
> >		pcount =3D per_cpu_ptr(fbc->counters, cpu);
> >		/* dont dirty cache line if not necessary */
> >		if (atomic_long_read(pcount))
> >			res +=3D atomic_long_xchg(pcount, 0);
				--------------------------->  (A)
> >	}
>=20

> 	atomic_long_add(res, &fbc->count);
				--------------------------->  (B)
> 	res =3D atomic_long_read(&fbc->count);
>=20
> >	return res;
> >}

The read is still theoritically FBC_BATCH * NR_CPUS inaccurate no?
What happens when other cpus update  their local counters at (A) and (B=
)?

(I am hoping we don't need percpu_counter_read_accurate anywhere yet an=
d
this is just demo ;).  I certainly don't want to go on all cpus for rea=
d /=20
add cmpxchg on the write path for the proto counters that started this=20
discussion)

Thanks,
Kiran
