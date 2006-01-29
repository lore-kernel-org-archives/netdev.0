From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [patch 3/4] net: Percpufy frequently used variables -- proto.sockets_allocated
Date: Sun, 29 Jan 2006 07:54:09 +0100
Message-ID: <43DC6691.9000001@cosmosbay.com>
References: <20060126185649.GB3651@localhost.localdomain> <20060126190357.GE3651@localhost.localdomain> <43D9DFA1.9070802@cosmosbay.com> <20060127195227.GA3565@localhost.localdomain> <20060127121602.18bc3f25.akpm@osdl.org> <20060127224433.GB3565@localhost.localdomain> <43DAA586.5050609@cosmosbay.com> <20060127151635.3a149fe2.akpm@osdl.org> <43DABAA4.8040208@cosmosbay.com> <20060129004459.GA24099@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>, kiran@scalex86.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	shai@scalex86.org, netdev@vger.kernel.org, pravins@calsoftinc.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750861AbWA2GyS@vger.kernel.org>
To: Benjamin LaHaise <bcrl@kvack.org>
In-Reply-To: <20060129004459.GA24099@kvack.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin LaHaise a =E9crit :
> On Sat, Jan 28, 2006 at 01:28:20AM +0100, Eric Dumazet wrote:
>> We might use atomic_long_t only (and no spinlocks)
>> Something like this ?
>=20
> Erk, complex and slow...  Try using local_t instead, which is substan=
tially=20
> cheaper on the P4 as it doesn't use the lock prefix and act as a memo=
ry=20
> barrier.  See asm/local.h.
>=20

Well, I think that might be doable, maybe RCU magic ?

1) local_t are not that nice on all archs.

2) The consolidation phase (summing all the cpus local offset to consol=
idate=20
the central counter) might be more difficult to do (we would need kind =
of 2=20
counters per cpu, and a index that can be changed by the cpu that wants=
 a=20
consolidation (still 'expensive'))

struct cpu_offset {
	local_t   offset[2];
	};

struct percpu_counter {
	atomic_long_t count;
	unsigned int offidx;
	spinlock_t   lock; /* to guard offidx changes */
	cpu_offset *counters;
};

void percpu_counter_mod(struct percpu_counter *fbc, long amount)
{
         long val;
	struct cpu_offset *cp;
	local_t *l;

	cp =3D per_cpu_ptr(fbc->counters, get_cpu());
	l =3D &cp[fbc->offidx];

         local_add(amount, l);
	val =3D local_read(l);
	if (new >=3D FBC_BATCH || new <=3D -FBC_BATCH) {
                 local_set(l, 0);
                 atomic_long_add(val, &fbc->count);
	}
	put_cpu();
}

long percpu_counter_read_accurate(struct percpu_counter *fbc)
{
	long res =3D 0, val;
	int cpu;
	struct cpu_offset *cp;
	local_t *l;

	spin_lock(&fbc->lock);
	idx =3D fbc->offidx;
	fbc->offidx ^=3D 1;
	mb();
	/*
	 * FIXME :
	 *	must 'wait' other cpus dont touch anymore their old local_t
	 */
	for_each_cpu(cpu) {
		cp =3D per_cpu_ptr(fbc->counters, cpu);
		l =3D &cp[idx];
		val =3D local_read(l);
		/* dont dirty alien cache line if not necessary */
		if (val)
			local_set(l, 0);
		res +=3D val;
	}
	spin_unlock(&fbc->lock);
         atomic_long_add(res, &fbc->count);
         return atomic_long_read(&fbc->count);
}



3) Are the locked ops so expensive if done on a cache line that is most=
ly in=20
exclusive state in cpu cache ?

Thank you
Eric
