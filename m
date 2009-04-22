From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v13)
Date: Wed, 22 Apr 2009 16:57:02 +0200
Message-ID: <49EF303E.9070009@cosmosbay.com>
References: <20090418094001.GA2369@ioremap.net>	<20090418141455.GA7082@linux.vnet.ibm.com>	<20090420103414.1b4c490f@nehalam>	<49ECBE0A.7010303@cosmosbay.com>	<18924.59347.375292.102385@cargo.ozlabs.ibm.com>	<20090420215827.GK6822@linux.vnet.ibm.com>	<18924.64032.103954.171918@cargo.ozlabs.ibm.com>	<20090420160121.268a8226@nehalam>	<alpine.LFD.2.00.0904210831560.2199@localhost.localdomain>	<20090421111541.228e977a@nehalam>	<20090421193924.GA24404@elte.hu> <20090421143927.52d7d89d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51029 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246AbZDVO6T convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 10:58:19 -0400
In-Reply-To: <20090421143927.52d7d89d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> This version of x_tables (ip/ip6/arp) locking uses a per-cpu
> recursive lock that can be nested.
>=20
> The idea for this came from an earlier version done by Eric Dumazet.
> Locking is done per-cpu, the fast path locks on the current cpu
> and updates counters.  This reduces the contention of a
> single reader lock (in 2.6.29) without the delay of synchronize_net()
> (in 2.6.30-rc2).=20
>=20
> The mutex that was added for 2.6.30 in xt_table is unnecessary since
> there already is a mutex for xt[af].mutex that is held.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Tested today on various machines and no problem so far
tbench/oprofile results, 3.7236% cpu spent in ipt_do_table, and 0.84% u=
sed
on read_lock/read_unlock

c04a5c30 <ipt_do_table>: /* ipt_do_table total: 217134  3.7236 */
=2E..
   349  0.0060 :c04a5ccc:   call   c04ce380 <_read_lock>
 23914  0.4101 :c04a5cd1:   mov    0xc(%edi),%eax
=2E..
               :c04a5ecb:   call   c04ce5f0 <_read_unlock_bh>
 25279  0.4335 :c04a5ed0:   cmpb   $0x0,-0xd(%ebp)

"iptables -L" fetches its data very fast too.
150 us on a 8 cpus machine, small firewall rules.
400-700 us on same machine, 1000 fw rules set (160000 bytes per cpu)
 depending on network trafic (from light to flood)


Thanks

>=20
> ---
> CHANGES=20
>   - reader and write now inline
>   - only acquire one cpu write lock at a time
>   - write lock pushed down into get_counters
>=20
>  include/linux/netfilter/x_tables.h |   50 +++++++++++++--
>  net/ipv4/netfilter/arp_tables.c    |  121 ++++++++++----------------=
-----------
>  net/ipv4/netfilter/ip_tables.c     |  120 +++++++++-----------------=
----------
>  net/ipv6/netfilter/ip6_tables.c    |  120 ++++++++++----------------=
----------
>  net/netfilter/x_tables.c           |   55 +++++++++-------
>  5 files changed, 174 insertions(+), 292 deletions(-)
>=20

