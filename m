From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU
Date: Mon, 13 Apr 2009 19:40:24 +0200
Message-ID: <49E37908.2080903@cosmosbay.com>
References: <20090411174801.GG6822@linux.vnet.ibm.com>	<18913.53699.544083.320542@cargo.ozlabs.ibm.com>	<20090412173108.GO6822@linux.vnet.ibm.com>	<20090412.181330.23529546.davem@davemloft.net>	<20090413040413.GQ6822@linux.vnet.ibm.com> <20090413095309.631cf395@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	paulus@samba.org, mingo@elte.hu, torvalds@linux-foundation.org,
	laijs@cn.fujitsu.com, jeff.chua.linux@gmail.com,
	jengelh@medozas.de, kaber@trash.net, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090413095309.631cf395@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger a =E9crit :
> This is an alternative version of ip/ip6/arp tables locking using
> per-cpu locks.  This avoids the overhead of synchronize_net() during
> update but still removes the expensive rwlock in earlier versions.
>=20
> The idea for this came from an earlier version done by Eric Duzamet.
> Locking is done per-cpu, the fast path locks on the current cpu
> and updates counters.  The slow case involves acquiring the locks on
> all cpu's.
>=20
> The mutex that was added for 2.6.30 in xt_table is unnecessary since
> there already is a mutex for xt[af].mutex that is held.
>=20
> Tested basic functionality (add/remove/list), but don't have test cas=
es
> for stress, ip6tables or arptables.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Patch seems good to me, but apparently xt_replace_table()
misses the "acquiring the locks on all cpus" you mentioned in ChangeLog=
 ?

I am still off-computers until tomorrow so cannot provide a patch for t=
his, sorry.

Some form of

local_bh_disable();
for_each_possible_cpu(cpu)
	spin_lock(&per_cpu(ip_tables_lock, cpu));

oldinfo =3D private;
/* do the substitution */
table->private =3D newinfo;
newinfo->initial_entries =3D oldinfo->initial_entries;

for_each_possible_cpu(cpu)
	spin_unlock(&per_cpu(ip_tables_lock, cpu));
local_bh_enable();


But I wonder if this could hit a limit of max spinlocks held by this cp=
u, say on a 4096 cpu machine ?



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
