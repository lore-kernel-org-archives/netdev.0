From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Tue, 14 Apr 2009 23:40:05 +0200
Message-ID: <49E502B5.7070700@cosmosbay.com>
References: <20090411174801.GG6822@linux.vnet.ibm.com>	<18913.53699.544083.320542@cargo.ozlabs.ibm.com>	<20090412173108.GO6822@linux.vnet.ibm.com>	<20090412.181330.23529546.davem@davemloft.net>	<20090413040413.GQ6822@linux.vnet.ibm.com>	<20090413095309.631cf395@nehalam>	<49E48136.5060700@trash.net>	<49E49C65.8060808@cosmosbay.com>	<20090414074554.7fa73e2f@nehalam>	<49E4B0A5.70404@cosmosbay.com>	<b6a2187b0904140951r3c6a41fdnc26b149202bdfa84@mail.gmail.com>	<20090414111716.28585806@nehalam>	<49E4E3E8.5090201@cosmosbay.com> <20090414141351.0f63ac98@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Chua <jeff.chua.linux@gmail.com>,
	Patrick McHardy <kaber@trash.net>, paulmck@linux.vnet.ibm.com,
	David Miller <davem@davemloft.net>, paulus@samba.org,
	mingo@elte.hu, torvalds@linux-foundation.org, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090414141351.0f63ac98@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger a =E9crit :
> This is an alternative version of ip/ip6/arp tables locking using
> per-cpu locks.  This avoids the overhead of synchronize_net() during
> update but still removes the expensive rwlock in earlier versions.
>=20
> The idea for this came from an earlier version done by Eric Dumazet.
> Locking is done per-cpu, the fast path locks on the current cpu
> and updates counters.  The slow case involves acquiring the locks on
> all cpu's.
>=20
> The mutex that was added for 2.6.30 in xt_table is unnecessary since
> there already is a mutex for xt[af].mutex that is held.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20
> ---
>  include/linux/netfilter/x_tables.h |    5 -
>  net/ipv4/netfilter/arp_tables.c    |  112 +++++++++-----------------=
-------
>  net/ipv4/netfilter/ip_tables.c     |  123 +++++++++++---------------=
-----------
>  net/ipv6/netfilter/ip6_tables.c    |  119 +++++++++++---------------=
---------
>  net/netfilter/x_tables.c           |   28 --------
>  5 files changed, 110 insertions(+), 277 deletions(-)
>=20

Tested successfuly on my dev machine, thanks Stephen.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


"strace -tt -T iptables -L" on this 8 cpu machine show quite fast opera=
tions now
(sub 1/HZ)=20

23:37:26.629489 getsockopt(3, SOL_IP, 0x40 /* IP_??? */, "filter\0\300\=
\\236@\365\271\231\"\300`\225T\367\1\0\0\0\0vm\300`\225T\367\
16"..., [84]) =3D 0 <0.000008>
23:37:26.629579 brk(0)                  =3D 0x8054000 <0.000006>
23:37:26.629613 brk(0x8075000)          =3D 0x8075000 <0.000007>
23:37:26.629660 getsockopt(3, SOL_IP, 0x41 /* IP_??? */, "filter\0\0\0\=
0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0L"..., [10608])
=3D 0 <0.000031>
23:37:26.629772 fstat64(1, {st_mode=3DS_IFCHR|0620, st_rdev=3Dmakedev(1=
36, 0), ...}) =3D 0 <0.000007>

same fast operation for an "iptables -A INPUT" operation


23:37:02.180313 close(4)                =3D 0 <0.000006>
23:37:02.180382 setsockopt(3, SOL_IP, 0x40 /* IP_??? */, "filter\0\0\0\=
0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\16"..., 10664)
=3D 0 <0.000114>
23:37:02.180552 setsockopt(3, SOL_IP, 0x41 /* IP_??? */, "filter\0\0\0\=
0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\20"..., 292) =3D
0 <0.000015>
23:37:02.180635 close(3)                =3D 0 <0.000010>

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
