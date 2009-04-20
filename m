From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v10)
Date: Mon, 20 Apr 2009 13:42:49 -0700
Message-ID: <20090420134249.43ab1f6f@nehalam>
References: <20090415170111.6e1ca264@nehalam>
	<alpine.LFD.2.00.0904151705120.4042@localhost.localdomain>
	<49E72E83.50702@trash.net>
	<20090416.153354.170676392.davem@davemloft.net>
	<20090416234955.GL6924@linux.vnet.ibm.com>
	<20090417012812.GA25534@linux.vnet.ibm.com>
	<20090418094001.GA2369@ioremap.net>
	<20090418141455.GA7082@linux.vnet.ibm.com>
	<20090420103414.1b4c490f@nehalam>
	<49ECBE0A.7010303@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, jeff.chua.linux@gmail.com,
	paulus@samba.org, mingo@elte.hu, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756982AbZDTUnZ@vger.kernel.org>
In-Reply-To: <49ECBE0A.7010303@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Apr 2009 20:25:14 +0200
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> > This version of x_tables (ip/ip6/arp) locking uses a per-cpu
> > recursive lock that can be nested. It is sort of like existing kern=
el_lock,
> > rwlock_t and even old 2.4 brlock.
> >=20
> > "Reader" is ip/arp/ip6 tables rule processing which runs per-cpu.
> > It needs to ensure that the rules are not being changed while packe=
t
> > is being processed.
> >=20
> > "Writer" is used in two cases: first is replacing rules in which ca=
se
> > all packets in flight have to be processed before rules are swapped=
,
> > then counters are read from the old (stale) info. Second case is wh=
ere
> > counters need to be read on the fly, in this case all CPU's are blo=
cked
> > from further rule processing until values are aggregated.
> >=20
> > The idea for this came from an earlier version done by Eric Dumazet=
=2E
> > Locking is done per-cpu, the fast path locks on the current cpu
> > and updates counters.  This reduces the contention of a
> > single reader lock (in 2.6.29) without the delay of synchronize_net=
()
> > (in 2.6.30-rc2).=20
> >=20
> > The mutex that was added for 2.6.30 in xt_table is unnecessary sinc=
e
> > there already is a mutex for xt[af].mutex that is held.
> >=20
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com
> >=20
> > ---
> > Changes from earlier patches.
> >   - function name changes
> >   - disable bottom half in info_rdlock
>=20
> OK, but we still have a problem on machines with >=3D 250 cpus,
> because calling 250 times spin_lock() is going to overflow preempt_co=
unt,
> as each spin_lock() increases preempt_count by one.
>=20
> PREEMPT_MASK: 0x000000ff
>=20
> add_preempt_count() should warn us about this overflow if CONFIG_DEBU=
G_PREEMPT is set

Wouldn't 256 or higher CPU system be faster without preempt?  If there =
are that many
CPU's, it is faster to do the work on other cpu and avoid the overhead =
of a hotly
updated preempt count.
