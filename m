From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCH] netfilter: use per-CPU recursive lock {XV}
Date: Sun, 26 Apr 2009 17:39:54 -0400
Message-ID: <20090426213954.GA825@Krystal>
References: <20090421143927.52d7d89d@nehalam> <alpine.LFD.2.00.0904220821240.3101@localhost.localdomain> <20090423210938.1501507b@nehalam> <49F146FF.5050200@cosmosbay.com> <20090424091839.6e13ebec@nehalam> <49F22465.80305@gmail.com> <20090425133052.4cb711f5@nehalam> <49F4A6E3.7080102@cosmosbay.com> <20090426193135.GA30851@Krystal> <49F4CA55.8020705@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, Paul Mackerras <paulus@samba.org>,
	paulmck@linux.vnet.ibm.com, Evgeniy Polyakov <zbr@ioremap.net>,
	kaber@trash.net, jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753200AbZDZVkW@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49F4CA55.8020705@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Eric Dumazet (dada1@cosmosbay.com) wrote:
> Mathieu Desnoyers a =E9crit :
> > * Eric Dumazet (dada1@cosmosbay.com) wrote:
> >> From: Stephen Hemminger <shemminger@vyatta.com>
> >>
> >>> Epilogue due to master Jarek. Lockdep carest not about the lockin=
g
> >>> doth bestowed. Therefore no keys are needed.
> >>>
> >>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >> So far, so good, should be ready for inclusion now, nobody complai=
ned :)
> >>
> >> I include the final patch, merge of your last two patches.
> >>
> >> David, could you please review it once again and apply it if it's =
OK ?
> >>
> > [...]
> >> +/*
> >> + * Per-CPU read/write lock associated with per-cpu table entries.
> >> + * This is not a general solution but makes reader locking fast s=
ince
> >> + * there is no shared variable to cause cache ping-pong; but adds=
 an
> >> + * additional write-side penalty since update must lock all
> >> + * possible CPU's.
> >> + *
> >> + * Read lock is used by ip/arp/ip6 tables rule processing which r=
uns per-cpu.
> >> + * It needs to ensure that the rules are not being changed while =
packet
> >> + * is being processed. In some cases, the read lock will be acqui=
red
> >> + * twice on the same CPU; this is okay because read locks handle =
nesting.
> >> + *
> >> + * Write lock is used in two cases:
> >> + *    1. reading counter values
> >> + *       all readers need to be stopped and the per-CPU values ar=
e summed.
> >> + *
> >> + *    2. replacing tables
> >> + *       any readers that are using the old tables have to comple=
te
> >> + *       before freeing the old table. This is handled by reading
> >> + *	  as a side effect of reading counters
> >> + */
> >> +DECLARE_PER_CPU(rwlock_t, xt_info_locks);
> >> +
> >> +static inline void xt_info_rdlock_bh(void)
> >> +{
> >> +	/*
> >> +	 * Note: can not use read_lock_bh(&__get_cpu_var(xt_info_locks))
> >> +	 * because need to ensure that preemption is disable before
> >> +	 * acquiring per-cpu-variable, so do it as a two step process
> >> +	 */
> >> +	local_bh_disable();
> >=20
> > Why do you need to disable bottom halves on the read-side ? You cou=
ld
> > probably just disable preemption, given this lock is nestable on th=
e
> > read-side anyway. Or I'm missing something obvious ?
>=20
> It may not be obvious, but subject already raised on this list, so I'=
ll
> try to be as precise as possible (But may be wrong on some points, I'=
ll
> let Patrick correct me if necessary)
>=20
> ipt_do_table() is not a readonly function returning a verdict.
>=20
> 1) It handles a stack (check how is used next->comefrom) that seems t=
o
> be stored on rules themselves. (This is how I understand this code)
> This is safe as each cpu has its own copy of rules/counters, and BH p=
rotected.
>=20
> 2) It also updates two 64 bit counters (bytes/packets) on each matche=
d rule.
>=20
> 3) Some netfilter matches/targets probably rely on the fact their han=
dlers
> are run with BH disabled by their caller (ipt_do_table()/arp/ip6...)
>=20
> These must be BH protected (and preempt disabled too), or else :
>=20
> 1) A softirq could interrupt a process in the middle of ipt_do_table(=
)
> and corrupt its "stack".
>=20
> 2) A softirq could interrupt a process in ipt_do_table() in the middl=
e
>  of the ADD_COUNTER(). Some counters could be corrupted.
>=20
> 3) Some netfiler extensions would break.
>=20
> Previous linux versions already used a read_lock_bh() here, on a sing=
le
> and shared rwlock, there is nothing new on this BH locking AFAIK.
>=20
> Thank you

Thanks for the explanation. It might help to document the role of bh
disabling for the reader in a supplementary code comment, otherwise one
might think it's been put there to match the bottom half disabling used
on the write-side, which has the supplementary role of making sure bh
will not deadlock (and this precise behavior is not needed usually on
the read-side).

One more point :

 *    1. reading counter values
 *       all readers need to be stopped and the per-CPU values are summ=
ed.

Maybe it's just me, but this sentence does not seem to clearly indicate
that we have :

for_each_cpu()
  write lock()
  read data
  write unlock()

One might interpret it as :

for_each_cpu()
  write lock()

read data

for_each_cpu()
  write unlock()

Or maybe it's just my understanding of English that's not perfect.
Anyhow, rewording this sentence might not hurt. Something along the
lines of :

"reading counter values
 all readers are iteratively stopped to have their per-CPU values
 summed"

This is an important difference, as this behaves more like a RCU-based
mechanism than a global per-cpu read/write lock where all the write
locks would be taken at once.

Mathieu

--=20
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE =
9A68
