From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Tue, 21 Apr 2009 06:59:29 +0200
Message-ID: <49ED52B1.7050601@cosmosbay.com>
References: <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain>	<49E72E83.50702@trash.net>	<20090416.153354.170676392.davem@davemloft.net>	<20090416234955.GL6924@linux.vnet.ibm.com>	<20090417012812.GA25534@linux.vnet.ibm.com>	<20090418094001.GA2369@ioremap.net>	<20090418141455.GA7082@linux.vnet.ibm.com>	<20090420103414.1b4c490f@nehalam>	<49ECBE0A.7010303@cosmosbay.com>	<18924.59347.375292.102385@cargo.ozlabs.ibm.com>	<20090420215827.GK6822@linux.vnet.ibm.com>	<18924.64032.103954.171918@cargo.ozlabs.ibm.com> <20090420160121.268a8226@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, jeff.chua.linux@gmail.com,
	mingo@elte.hu, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090420160121.268a8226@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger a =E9crit :
> This version of x_tables (ip/ip6/arp) locking uses a per-cpu
> recursive lock that can be nested. It is sort of like existing kernel=
_lock,
> rwlock_t and even old 2.4 brlock.
>=20
> "Reader" is ip/arp/ip6 tables rule processing which runs per-cpu.
> It needs to ensure that the rules are not being changed while packet
> is being processed.
>=20
> "Writer" is used in two cases: first is replacing rules in which case
> all packets in flight have to be processed before rules are swapped,
> then counters are read from the old (stale) info. Second case is wher=
e
> counters need to be read on the fly, in this case all CPU's are block=
ed
> from further rule processing until values are aggregated.
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

I reviewed this patch believe its in quite good shape, thanks Stephen.

Then I tested it on a x86_32 8 cpus machine and got no obvious problem.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Hopefully, next rcu_bh (or whatever name is used) will permit us
to switch back to pure RCU in 2.6.31
=20
oprofile snapshot of a tbench session, with light iptables rules.
(4 rules in INPUT chain, 3 rules on OUTPUT)

xt_info_rdlock_bh() uses 0.6786 % of cpu
xt_info_rdunlock_bh() uses 0.1743 % of cpu


CPU: Core 2, speed 3000.77 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a u=
nit mask of 0x00 (Unhalted core cycles) count 100000
samples  cum. samples  %        cum. %     symbol name
1248350  1248350       11.3285  11.3285    copy_from_user
534049   1782399        4.8464  16.1749    copy_to_user
480898   2263297        4.3641  20.5390    __schedule
325581   2588878        2.9546  23.4936    ipt_do_table
312697   2901575        2.8377  26.3312    tcp_ack
309381   3210956        2.8076  29.1388    tcp_sendmsg
248238   3459194        2.2527  31.3915    tcp_v4_rcv
230405   3689599        2.0909  33.4824    tcp_transmit_skb
220638   3910237        2.0022  35.4847    ip_queue_xmit
217099   4127336        1.9701  37.4548    tcp_recvmsg
175885   4303221        1.5961  39.0509    tcp_rcv_established
173112   4476333        1.5710  40.6219    __switch_to
165138   4641471        1.4986  42.1205    sysenter_past_esp
149367   4790838        1.3555  43.4759    dst_release
138619   4929457        1.2579  44.7339    sched_clock_cpu
132724   5062181        1.2044  45.9383    lock_sock_nested
121353   5183534        1.1013  47.0396    nf_iterate
119205   5302739        1.0818  48.1214    netif_receive_skb
118859   5421598        1.0786  49.2000    release_sock
112597   5534195        1.0218  50.2218    __inet_lookup_established
112195   5646390        1.0181  51.2399    sys_socketcall
110018   5756408        0.9984  52.2383    tcp_write_xmit
106466   5862874        0.9662  53.2045    __alloc_skb
93386    5956260        0.8475  54.0519    dev_queue_xmit
89229    6045489        0.8097  54.8617    tcp_event_data_recv
85972    6131461        0.7802  55.6418    local_bh_enable
82882    6214343        0.7521  56.3940    skb_release_data
80898    6295241        0.7341  57.1281    ip_rcv
76380    6371621        0.6931  57.8213    skb_copy_datagram_iovec
74782    6446403        0.6786  58.4999    xt_info_rdlock_bh
73593    6519996        0.6678  59.1677    mod_timer
72884    6592880        0.6614  59.8291    sock_recvmsg
71789    6664669        0.6515  60.4806    __copy_skb_header
70560    6735229        0.6403  61.1209    fget_light
68756    6803985        0.6239  61.7449    get_page_from_freelist
68378    6872363        0.6205  62.3654    put_page
68042    6940405        0.6175  62.9829    ip_finish_output
67618    7008023        0.6136  63.5965    page_address
64894    7072917        0.5889  64.1854    tcp_cleanup_rbuf


>=20
> ---
> CHANGES=20
>   - optimize for UP
>   - disable bottom half in info_rdlock
>   - prevent preempt count overflow
>   - turn off lockdep in writer to avoid bogus warning
>   - optimize unlock_bh
>=20
>

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
