From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 01 Mar 2011 12:45:09 +0100
Message-ID: <1298979909.3284.28.camel@edumazet-laptop>
References: <20110227110614.GA6246@gondor.apana.org.au>
	 <20110228113659.GA20726@gondor.apana.org.au>
	 <20110228141322.GF9763@canuck.infradead.org>
	 <1298910174.2941.585.camel@edumazet-laptop>
	 <20110228163742.GH9763@canuck.infradead.org>
	 <1298912869.2941.687.camel@edumazet-laptop>
	 <20110301101955.GI9763@canuck.infradead.org>
	 <1298975602.3284.13.camel@edumazet-laptop>
	 <20110301110708.GJ9763@canuck.infradead.org>
	 <1298977984.3284.15.camel@edumazet-laptop>
	 <20110301112759.GK9763@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42108 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756232Ab1CALpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 06:45:15 -0500
Received: by fxm17 with SMTP id 17so4698481fxm.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 03:45:13 -0800 (PST)
In-Reply-To: <20110301112759.GK9763@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 01 mars 2011 =C3=A0 06:27 -0500, Thomas Graf a =C3=A9crit :
> On Tue, Mar 01, 2011 at 12:13:04PM +0100, Eric Dumazet wrote:
> > Its a bit strange two cpus spend time in softirq, unless you have t=
wo
> > queryperf sources, and a multiqueue NIC, or maybe you use two NICS =
?
>=20
> one NIC, 2 clients (12 instances per client)
>=20
> [root@hp-bl460cg7-01 ~]# cat /sys/class/net/eth0/queues/rx-0/rps_cpus=
=20
> 00000000,00000000,00000000,00000000,00000000,00000000,00000000,000000=
00
>=20
> [root@hp-bl460cg7-01 ~]# netstat -s | grep err
>     1781377 packet receive errors
>=20
> > Mind use "perf top -C 1" and "perf top -C 11" to check what these c=
pus
> > do ?
>=20

Thanks that's really interesting

> ---------------------------------------------------------------------=
-----------------------------------------------
>    PerfTop:   16198 irqs/sec  kernel:99.1%  exact:  0.0% [1000Hz cpu-=
clock-msecs],  (all, CPU: 1)
> ---------------------------------------------------------------------=
-----------------------------------------------
>=20
>              samples  pcnt function                    DSO
>              _______ _____ ___________________________ ______________=
_____________________________________________
>=20

CPU 1 handles receives from your BENET NIC

(Its a bit strange, given this NIC should provide 4 rx queues). Load
could be split to two cpus in your case (two sources)

Try :

ethtool -S eth0 | grep rx_pk
     rxq0: rx_pkts: ??
     rxq1: rx_pkts: ??
     rxq2: rx_pkts: ??
     rxq3: rx_pkts: ??
     rxq4: rx_pkts: ??


Its BE_HDR_LEN being 64, small UDP frames are too big to fit in skb
head.




>             51675.00 33.2% _raw_spin_unlock_irqrestore [kernel.kallsy=
ms]                                         =20
>             12426.00  8.0% clflush_cache_range         [kernel.kallsy=
ms]                                         =20
>              5511.00  3.5% be_poll_rx                  /lib/modules/2=
=2E6.38-rc5+/kernel/drivers/net/benet/be2net.ko
>              4567.00  2.9% __udp4_lib_lookup           [kernel.kallsy=
ms]                                         =20
>              3981.00  2.6% __kmalloc_node_track_caller [kernel.kallsy=
ms]                                         =20
>              3975.00  2.6% get_rx_page_info            /lib/modules/2=
=2E6.38-rc5+/kernel/drivers/net/benet/be2net.ko
>              3725.00  2.4% sk_run_filter               [kernel.kallsy=
ms]                                         =20
>              3606.00  2.3% get_page_from_freelist      [kernel.kallsy=
ms]                                         =20
>              3178.00  2.0% __domain_mapping            [kernel.kallsy=
ms]                                         =20
>              3122.00  2.0% kmem_cache_alloc_node       [kernel.kallsy=
ms]                                         =20
>              2839.00  1.8% sock_queue_rcv_skb          [kernel.kallsy=
ms]                                         =20
>              2246.00  1.4% __netif_receive_skb         [kernel.kallsy=
ms]                                         =20
>              2245.00  1.4% nf_iterate                  [kernel.kallsy=
ms]                                         =20
>              2081.00  1.3% __udp4_lib_rcv              [kernel.kallsy=
ms]                                         =20
>              2042.00  1.3% ipt_do_table                [kernel.kallsy=
ms]                                         =20
>              1901.00  1.2% _raw_spin_lock              [kernel.kallsy=
ms]                                         =20
>              1856.00  1.2% __alloc_skb                 [kernel.kallsy=
ms]                                         =20
>              1645.00  1.1% read_tsc                    [kernel.kallsy=
ms]                                         =20
>              1562.00  1.0% nf_ct_tuple_equal           [kernel.kallsy=
ms]                                         =20
>              1562.00  1.0% ip_rcv                      [kernel.kallsy=
ms]                                         =20
>              1495.00  1.0% __nf_conntrack_find_get     [kernel.kallsy=
ms]                                         =20
>              1477.00  0.9% sock_def_readable           [kernel.kallsy=
ms]                                         =20
>              1363.00  0.9% find_first_bit              [kernel.kallsy=
ms]                                         =20
>              1360.00  0.9% domain_get_iommu            [kernel.kallsy=
ms]                                         =20
>              1255.00  0.8% udp_queue_rcv_skb           [kernel.kallsy=
ms]                                         =20
>              1174.00  0.8% xfrm4_policy_check.clone.0  [kernel.kallsy=
ms]                                         =20
>              1138.00  0.7% hash_conntrack_raw          [kernel.kallsy=
ms]                                         =20
>              1000.00  0.6% intel_unmap_page            [kernel.kallsy=
ms]                                         =20
>               959.00  0.6% load_pointer                [kernel.kallsy=
ms]                                         =20
>               957.00  0.6% sock_flag                   [kernel.kallsy=
ms]                                         =20
>               938.00  0.6% nf_conntrack_in             [kernel.kallsy=
ms]                                         =20
>               891.00  0.6% _local_bh_enable_ip         [kernel.kallsy=
ms]                                         =20
>               884.00  0.6% eth_type_trans              [kernel.kallsy=
ms]                                         =20
>               832.00  0.5% be_post_rx_frags            /lib/modules/2=
=2E6.38-rc5+/kernel/drivers/net/benet/be2net.ko
>               829.00  0.5% __alloc_pages_nodemask      [kernel.kallsy=
ms]                                         =20
>               813.00  0.5% kmem_cache_alloc            [kernel.kallsy=
ms]                                         =20
>               802.00  0.5% netif_receive_skb           [kernel.kallsy=
ms]                                         =20
>               802.00  0.5% ip_route_input_common       [kernel.kallsy=
ms]                                         =20
>               723.00  0.5% nf_ct_get_tuple             [kernel.kallsy=
ms]                                         =20
>               720.00  0.5% __intel_map_single          [kernel.kallsy=
ms]                                         =20
>               720.00  0.5% udp_error                   [kernel.kallsy=
ms]                                         =20
>=20
> ---------------------------------------------------------------------=
-----------------------------------------------
>    PerfTop:   16360 irqs/sec  kernel:72.6%  exact:  0.0% [1000Hz cpu-=
clock-msecs],  (all, CPU: 11)
> ---------------------------------------------------------------------=
-----------------------------------------------
>=20

CPU 11 handles all TX completions : Its a potential bottleneck.

I might ressurect XPS patch ;)

>              samples  pcnt function                      DSO
>              _______ _____ _____________________________ ____________=
_______________________________________________
>=20
>             16993.00 32.4% _raw_spin_unlock_irqrestore   [kernel.kall=
syms]                                         =20
>              5833.00 11.1% clflush_cache_range           [kernel.kall=
syms]                                         =20
>              3315.00  6.3% be_tx_compl_process           /lib/modules=
/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
>              1818.00  3.5% kmem_cache_free               [kernel.kall=
syms]                                         =20
>              1415.00  2.7% isc_rwlock_lock               /usr/lib64/l=
ibisc.so.62.0.1                               =20
>              1090.00  2.1% be_poll_tx_mcc                /lib/modules=
/2.6.38-rc5+/kernel/drivers/net/benet/be2net.ko
>               811.00  1.5% skb_release_head_state        [kernel.kall=
syms]                                         =20
>               772.00  1.5% skb_release_data              [kernel.kall=
syms]                                         =20
>               712.00  1.4% dns_rbt_findnode              /usr/lib64/l=
ibdns.so.69.0.1                               =20
>               703.00  1.3% isc_rwlock_unlock             /usr/lib64/l=
ibisc.so.62.0.1                               =20
>               695.00  1.3% dma_pte_clear_range           [kernel.kall=
syms]                                         =20
>               618.00  1.2% kfree_skb                     [kernel.kall=
syms]                                         =20
>               597.00  1.1% kfree                         [kernel.kall=
syms]                                         =20
>               553.00  1.1% intel_unmap_page              [kernel.kall=
syms]                                         =20
>               531.00  1.0% __do_softirq                  [kernel.kall=
syms]                                         =20
>               504.00  1.0% isc_stats_increment           /usr/lib64/l=
ibisc.so.62.0.1                               =20
>               397.00  0.8% virt_to_head_page             [kernel.kall=
syms]                                         =20
>               306.00  0.6% _raw_spin_lock                [kernel.kall=
syms]                                         =20
>               270.00  0.5% domain_get_iommu              [kernel.kall=
syms]                                         =20
>               256.00  0.5% dns_name_fullcompare          /usr/lib64/l=
ibdns.so.69.0.1                               =20
>               233.00  0.4% find_first_bit                [kernel.kall=
syms]                                         =20
>               222.00  0.4% dns_name_equal                /usr/lib64/l=
ibdns.so.69.0.1                               =20
>               218.00  0.4% __pthread_mutex_lock_internal /lib64/libpt=
hread-2.12.so                                 =20
>               207.00  0.4% dns_rbtnodechain_init         /usr/lib64/l=
ibdns.so.69.0.1                               =20
>               196.00  0.4% dns_acl_match                 /usr/lib64/l=
ibdns.so.69.0.1                               =20
>               194.00  0.4% dma_pte_free_pagetable        [kernel.kall=
syms]                                         =20
>               192.00  0.4% dns_name_getlabelsequence     /usr/lib64/l=
ibdns.so.69.0.1                               =20
>=20


