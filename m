From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Mon, 20 Apr 2009 21:15:38 -0700
Message-ID: <20090420211538.57a6575d@nehalam>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, jeff.chua.linux@gmail.com,
	mingo@elte.hu, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53817 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752661AbZDUEPp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 00:15:45 -0400
In-Reply-To: <49ED4407.8010200@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Apr 2009 05:56:55 +0200
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Lai Jiangshan a =C3=A9crit :
> > Stephen Hemminger wrote:
> >> +/**
> >> + * xt_table_info_rdlock_bh - recursive read lock for xt table inf=
o
> >> + *
> >> + * Table processing calls this to hold off any changes to table
> >> + * (on current CPU). Always leaves with bottom half disabled.
> >> + * If called recursively, then assumes bh/preempt already disable=
d.
> >> + */
> >> +void xt_info_rdlock_bh(void)
> >> +{
> >> +	struct xt_info_lock *lock;
> >> +
> >> +	preempt_disable();
> >> +	lock =3D &__get_cpu_var(xt_info_locks);
> >> +	if (likely(++lock->depth =3D=3D 0))
> >=20
> > Maybe I missed something. I think softirq may be still enabled here=
=2E
> > So what happen when xt_info_rdlock_bh() called recursively here?
>=20
> well, first time its called, you are right softirqs are enabled until
> the point we call spin_lock_bh(), right after this line :
>=20
>=20
> >=20
> >> +		spin_lock_bh(&lock->lock);
> >> +	preempt_enable_no_resched();
>=20
> After this line, both softirqs and preempt are disabled.
>=20
> Future calls to this function temporarly raise preemptcount and decre=
ase it.
> (Null effect)
>=20
> >> +}
> >> +EXPORT_SYMBOL_GPL(xt_info_rdlock_bh);
> >> +
> >=20
> > Is this OK for you:
> >=20
> > void xt_info_rdlock_bh(void)
> > {
> > 	struct xt_info_lock *lock;
> >=20
> > 	local_bh_disable();
>=20
> well, Stephen was trying to not change preempt count for the 2nd, 3rd=
, 4th?... invocation of this function.
> This is how I understood the code.
>=20
> > 	lock =3D &__get_cpu_var(xt_info_locks);
> > 	if (likely(++lock->depth =3D=3D 0))
> > 		spin_lock(&lock->lock);
> > }
> >=20
> > Lai.
> >=20

In this version, I was trying to use/preserve the optimizations that
are done in spin_unlock_bh().
