From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v10)
Date: Mon, 20 Apr 2009 14:05:49 -0700
Message-ID: <20090420210549.GJ6822@linux.vnet.ibm.com>
References: <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain> <49E72E83.50702@trash.net> <20090416.153354.170676392.davem@davemloft.net> <20090416234955.GL6924@linux.vnet.ibm.com> <20090417012812.GA25534@linux.vnet.ibm.com> <20090418094001.GA2369@ioremap.net> <20090418141455.GA7082@linux.vnet.ibm.com> <20090420103414.1b4c490f@nehalam> <49ECBE0A.7010303@cosmosbay.com> <20090420134249.43ab1f6f@nehalam>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, jeff.chua.linux@gmail.com,
	paulus@samba.org, mingo@elte.hu, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090420134249.43ab1f6f@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 20, 2009 at 01:42:49PM -0700, Stephen Hemminger wrote:
> On Mon, 20 Apr 2009 20:25:14 +0200
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>=20
> > Stephen Hemminger a =E9crit :
> > > This version of x_tables (ip/ip6/arp) locking uses a per-cpu
> > > recursive lock that can be nested. It is sort of like existing ke=
rnel_lock,
> > > rwlock_t and even old 2.4 brlock.
> > >=20
> > > "Reader" is ip/arp/ip6 tables rule processing which runs per-cpu.
> > > It needs to ensure that the rules are not being changed while pac=
ket
> > > is being processed.
> > >=20
> > > "Writer" is used in two cases: first is replacing rules in which =
case
> > > all packets in flight have to be processed before rules are swapp=
ed,
> > > then counters are read from the old (stale) info. Second case is =
where
> > > counters need to be read on the fly, in this case all CPU's are b=
locked
> > > from further rule processing until values are aggregated.
> > >=20
> > > The idea for this came from an earlier version done by Eric Dumaz=
et.
> > > Locking is done per-cpu, the fast path locks on the current cpu
> > > and updates counters.  This reduces the contention of a
> > > single reader lock (in 2.6.29) without the delay of synchronize_n=
et()
> > > (in 2.6.30-rc2).=20
> > >=20
> > > The mutex that was added for 2.6.30 in xt_table is unnecessary si=
nce
> > > there already is a mutex for xt[af].mutex that is held.
> > >=20
> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com
> > >=20
> > > ---
> > > Changes from earlier patches.
> > >   - function name changes
> > >   - disable bottom half in info_rdlock
> >=20
> > OK, but we still have a problem on machines with >=3D 250 cpus,
> > because calling 250 times spin_lock() is going to overflow preempt_=
count,
> > as each spin_lock() increases preempt_count by one.
> >=20
> > PREEMPT_MASK: 0x000000ff
> >=20
> > add_preempt_count() should warn us about this overflow if CONFIG_DE=
BUG_PREEMPT is set
>=20
> Wouldn't 256 or higher CPU system be faster without preempt?  If ther=
e
> are that many CPU's, it is faster to do the work on other cpu and avo=
id
> the overhead of a hotly updated preempt count.

The preempt count is maintained per-CPU, so has low overhead.  The
problem is that for CONFIG_PREEMPT builds, the preempt disabing is
built into spin_lock().

							Thanx, Paul
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
