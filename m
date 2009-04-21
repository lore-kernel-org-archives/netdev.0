From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Mon, 20 Apr 2009 22:45:40 -0700
Message-ID: <20090420224540.30d7b0ed@nehalam>
References: <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain>
	<49E72E83.50702@trash.net>
	<20090416.153354.170676392.davem@davemloft.net>
	<20090416234955.GL6924@linux.vnet.ibm.com>
	<20090417012812.GA25534@linux.vnet.ibm.com>
	<20090418094001.GA2369@ioremap.net>
	<20090418141455.GA7082@linux.vnet.ibm.com>
	<20090420103414.1b4c490f@nehalam>
	<49ECBE0A.7010303@cosmosbay.com>
	<18924.59347.375292.102385@cargo.ozlabs.ibm.com>
	<20090420215827.GK6822@linux.vnet.ibm.com>
	<18924.64032.103954.171918@cargo.ozlabs.ibm.com>
	<20090420160121.268a8226@nehalam>
	<49ED406F.2040401@cn.fujitsu.com>
	<49ED4407.8010200@cosmosbay.com>
	<49ED5813.1000803@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, jeff.chua.linux@gmail.com,
	mingo@elte.hu, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49ED5813.1000803@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 21 Apr 2009 13:22:27 +0800
Lai Jiangshan <laijs@cn.fujitsu.com> wrote:

> Eric Dumazet wrote:
> > Lai Jiangshan a =C3=A9crit :
> >> Stephen Hemminger wrote:
> >>> +/**
> >>> + * xt_table_info_rdlock_bh - recursive read lock for xt table in=
fo
> >>> + *
> >>> + * Table processing calls this to hold off any changes to table
> >>> + * (on current CPU). Always leaves with bottom half disabled.
> >>> + * If called recursively, then assumes bh/preempt already disabl=
ed.
> >>> + */
> >>> +void xt_info_rdlock_bh(void)
> >>> +{
> >>> +	struct xt_info_lock *lock;
> >>> +
> >>> +	preempt_disable();
> >>> +	lock =3D &__get_cpu_var(xt_info_locks);
> >>> +	if (likely(++lock->depth =3D=3D 0))
> >> Maybe I missed something. I think softirq may be still enabled her=
e.
> >> So what happen when xt_info_rdlock_bh() called recursively here?
> >=20
> > well, first time its called, you are right softirqs are enabled unt=
il
> > the point we call spin_lock_bh(), right after this line :
>=20
> xt_info_rdlock_bh() called recursively here will enter the
> critical region without &__get_cpu_var(xt_info_locks)->lock.

NO spin_lock_bh always does a preempt_disable

  xt_info_rdlock_bh            (depth =3D -1)
+1         preempt_disable
           spin_lock_bh
+1             preempt_disable
-1         preempt_enable_no_resched
---
+1

Second call preempt_count=3D1   (depth =3D 0)
       xt_info_rdlock_bh
+1         preempt_disable
-1         preempt_enable_no_resched
---

Result is preempt_count=3D1 (depth =3D 1)


Now lets do unlocks
       xt_info_rdunlock_bh  preempt_count=3D1 depth=3D1
          does nothing
   xt_info_rdunlock_bh      preempt_count=3D1 depth =3D 0
-1      spin_unlock_bh

Resulting preempt_count=3D0  depth =3D -1

Same as starting point.

> Because xt_info_rdlock_bh() called recursively here sees
> lock->depth >=3D 0, and "++lock->depth =3D=3D 0" is false.
>=20
> >=20
> >=20
> >>> +		spin_lock_bh(&lock->lock);
> >>> +	preempt_enable_no_resched();
> >=20
> > After this line, both softirqs and preempt are disabled.

No. spin_lock_bh on first pass does this.

> > Future calls to this function temporarly raise preemptcount and dec=
rease it.
> > (Null effect)
> >=20
> >>> +}
> >>> +EXPORT_SYMBOL_GPL(xt_info_rdlock_bh);
> >>> +
> >> Is this OK for you:
> >>
> >> void xt_info_rdlock_bh(void)
> >> {
> >> 	struct xt_info_lock *lock;
> >>
> >> 	local_bh_disable();
> >=20
> > well, Stephen was trying to not change preempt count for the 2nd, 3=
rd, 4th?... invocation of this function.
> > This is how I understood the code.
> >=20
> >> 	lock =3D &__get_cpu_var(xt_info_locks);
> >> 	if (likely(++lock->depth =3D=3D 0))
> >> 		spin_lock(&lock->lock);
> >> }
> >>
>=20
> Sorry for it.
> Is this OK:
>=20
> void xt_info_rdlock_bh(void)
> {
> 	struct xt_info_lock *lock;
>=20
> 	local_bh_disable();
> 	lock =3D &__get_cpu_var(xt_info_locks);
> 	if (likely(++lock->depth =3D=3D 0))
> 		spin_lock(&lock->lock);
> 	else
> 		local_bh_enable();
> }

Unnecessary.

> I did not think things carefully enough, and I do know
> nothing about ip/ip6/arp.
>=20
> Lai
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
