From: Ben Greear <greearb@candelatech.com>
Subject: Re: OOM when adding ipv6 route:  How to make available more per-cpu
 memory?
Date: Fri, 05 Nov 2010 11:15:01 -0700
Message-ID: <4CD449A5.5070305@candelatech.com>
References: <4CD43C87.5040403@candelatech.com> <1288980361.2882.1070.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38569 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259Ab0KESRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 14:17:25 -0400
In-Reply-To: <1288980361.2882.1070.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/05/2010 11:06 AM, Eric Dumazet wrote:
> Le vendredi 05 novembre 2010 =C3=A0 10:19 -0700, Ben Greear a =C3=A9c=
rit :
>> We are testing 500 mac-vlans with IPv6 addresses on a 32-bit kernel
>> (2.6.36 + ubuntu patches + our patches)  We have one
>> routing table per interface.  It seems that some of them cannot
>> add routes due to lack of memory.
>>
>> root@lanforge-ubuntu:/home/lanforge# ip route show table 29
>> root@lanforge-ubuntu:/home/lanforge# ./local/sbin/ip -6 route add de=
fault via 2001:98::1 dev eth12#15 table 29
>> RTNETLINK answers: Cannot allocate memory
>>
>> I see errors such as this in the logs:
>>
>> [507107.846864] PERCPU: allocation failed, size=3D2048 align=3D4, fa=
iled to allocate new chunk
>> [507107.846867] Pid: 3246, comm: ip Tainted: P            2.6.36-1-c=
t #7
>> [507107.846869] Call Trace:
>> [507107.846874]  [<c05d4996>] ? printk+0x2d/0x2f
>> [507107.846878]  [<c021405e>] pcpu_alloc+0x32e/0x360
>> [507107.846880]  [<c02140bf>] __alloc_percpu+0xf/0x20
>> [507107.846883]  [<c0558d6d>] snmp_mib_init+0x3d/0x70
>> [507107.846885]  [<c0585692>] ipv6_add_dev+0x132/0x350
>> [507107.846887]  [<c0557f39>] ? inetdev_init+0xb9/0x180
>> [507107.846889]  [<c05895ff>] addrconf_notify+0x3f/0x490
>> [507107.846891]  [<c055884f>] ? inetdev_event+0x20f/0x280
>> [507107.846894]  [<c05daef3>] notifier_call_chain+0x43/0x60
>> [507107.846897]  [<c016df4f>] raw_notifier_call_chain+0x1f/0x30
>> [507107.846899]  [<c05008ec>] call_netdevice_notifiers+0x2c/0x60
>> [507107.846901]  [<c0502ecc>] register_netdevice+0x23c/0x380
>> [507107.846907]  [<f80aecf7>] macvlan_common_newlink+0x187/0x2a0 [ma=
cvlan]
>> [507107.846910]  [<f80ae540>] ? macvlan_setup+0x0/0x20 [macvlan]
>> [507107.846912]  [<f80aee37>] macvlan_newlink+0x27/0x30 [macvlan]
>> [507107.846914]  [<c0503060>] ? netif_rx+0x0/0x120
>> [507107.846915]  [<c05033c0>] ? dev_forward_skb+0x0/0xf0
>> [507107.846917]  [<f80aee10>] ? macvlan_newlink+0x0/0x30 [macvlan]
>> [507107.846920]  [<c050ea94>] rtnl_newlink+0x464/0x590
>> [507107.846921]  [<c050e7e6>] ? rtnl_newlink+0x1b6/0x590
>> [507107.846927]  [<c050cd2d>] rtnetlink_rcv_msg+0x13d/0x230
>> [507107.846929]  [<c05d721f>] ? _raw_spin_lock_irqsave+0x2f/0x50
>> [507107.846931]  [<c050e630>] ? rtnl_newlink+0x0/0x590
>> [507107.846933]  [<c050cbf0>] ? rtnetlink_rcv_msg+0x0/0x230
>> [507107.846935]  [<c0522276>] netlink_rcv_skb+0x86/0xb0
>> [507107.846936]  [<c050cbdc>] rtnetlink_rcv+0x1c/0x30
>> [507107.846938]  [<c0521f69>] netlink_unicast+0x259/0x280
>> [507107.846940]  [<c0522ba8>] netlink_sendmsg+0x1f8/0x300
>> [507107.846943]  [<c04f0b79>] sock_sendmsg+0xd9/0x100
>> [507107.846945]  [<c013e0dd>] ? finish_task_switch+0x3d/0xc0
>> [507107.846947]  [<c04f0b79>] ? sock_sendmsg+0xd9/0x100
>> [507107.846950]  [<c013361d>] ? kmap_atomic_prot+0xcd/0xf0
>> [507107.846957]  [<f88bd559>] ? h_d_revalidate+0xe9/0x240 [aufs]
>> [507107.846958]  [<c013361d>] ? kmap_atomic_prot+0xcd/0xf0
>> [507107.846962]  [<c0364c7d>] ? _copy_from_user+0x3d/0x130
>> [507107.846965]  [<c04f947a>] ? verify_iovec+0x5a/0xa0
>> [507107.846966]  [<c04f112d>] sys_sendmsg+0x15d/0x290
>> [507107.846972]  [<f88c05f1>] ? aufs_fault+0xf1/0x110 [aufs]
>> [507107.846974]  [<c013361d>] ? kmap_atomic_prot+0xcd/0xf0
>> [507107.846977]  [<c01f8726>] ? handle_mm_fault+0x146/0x400
>> [507107.846979]  [<c05dac0d>] ? do_page_fault+0x1cd/0x470
>> [507107.846981]  [<c023419d>] ? alloc_fd+0xbd/0xf0
>> [507107.846983]  [<c0364c7d>] ? _copy_from_user+0x3d/0x130
>> [507107.846986]  [<c04f183b>] sys_socketcall+0xeb/0x2a0
>> [507107.846989]  [<c0151d99>] ? irq_exit+0x39/0x70
>> [507107.846991]  [<c021bb2e>] ? sys_open+0x2e/0x40
>> [507107.846993]  [<c05d77a4>] syscall_call+0x7/0xb
>>
>>
>> But, it appears to me that we have plenty of memory available.
>>
>> top - 10:09:13 up 6 days, 15:56,  9 users,  load average: 0.37, 0.39=
, 0.45
>> Tasks: 211 total,   2 running, 209 sleeping,   0 stopped,   0 zombie
>> Cpu(s):  0.7%us,  2.1%sy,  0.0%ni, 97.2%id,  0.0%wa,  0.0%hi,  0.0%s=
i,  0.0%st
>> Mem:   3604332k total,  1510252k used,  2094080k free,    84928k buf=
fers
>> Swap:   154620k total,        0k used,   154620k free,  1045912k cac=
hed
>>
>>     PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMA=
ND
>>
>>
>>        root@lanforge-ubuntu:/home/lanforge# cat /proc/meminfo
>> MemTotal:        3604332 kB
>> MemFree:         2094568 kB
>> Buffers:           84928 kB
>> Cached:          1045920 kB
>> SwapCached:            0 kB
>> Active:           466784 kB
>> Inactive:         805632 kB
>> Active(anon):     148988 kB
>> Inactive(anon):     6788 kB
>> Active(file):     317796 kB
>> Inactive(file):   798844 kB
>> Unevictable:           0 kB
>> Mlocked:               0 kB
>> HighTotal:       2752008 kB
>> HighFree:        1512380 kB
>> LowTotal:         852324 kB
>> LowFree:          582188 kB
>> SwapTotal:        154620 kB
>> SwapFree:         154620 kB
>> Dirty:               492 kB
>> Writeback:             0 kB
>> AnonPages:        141316 kB
>> Mapped:            39428 kB
>> Shmem:             14208 kB
>> Slab:             170788 kB
>> SReclaimable:      81904 kB
>> SUnreclaim:        88884 kB
>> KernelStack:        2520 kB
>> PageTables:         4516 kB
>> NFS_Unstable:          0 kB
>> Bounce:                0 kB
>> WritebackTmp:          0 kB
>> CommitLimit:     1956784 kB
>> Committed_AS:     582604 kB
>> VmallocTotal:     122880 kB
>> VmallocUsed:       48592 kB
>> VmallocChunk:      24280 kB
>> HardwareCorrupted:     0 kB
>> HugePages_Total:       0
>> HugePages_Free:        0
>> HugePages_Rsvd:        0
>> HugePages_Surp:        0
>> Hugepagesize:       4096 kB
>> DirectMap4k:       12280 kB
>> DirectMap4M:      897024 kB
>>
>>
>> Is there any way to tune the system so that it has more memory avail=
able
>> for per-cpu data structures?
>
> CC linux-kernel and Tejun Heo
>
> How many possible cpus do you have ?
> head -1 /proc/interrupts

oot@lanforge-ubuntu:/home/lanforge# head -1 /proc/interrupts
            CPU0       CPU1       CPU2       CPU3       CPU4       CPU5=
       CPU6       CPU7

>
> and please post :
> cat /proc/vmallocinfo

root@lanforge-ubuntu:/home/lanforge# cat /proc/vmallocinfo
0xf7ffe000-0xf8000000    8192 hpet_enable+0x2d/0x1b8 phys=3Dfed00000 io=
remap
0xf8002000-0xf8004000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf79e=
000 ioremap
0xf8004000-0xf8007000   12288 acpi_os_map_memory+0x16/0x1f phys=3Ddf7a0=
000 ioremap
0xf8008000-0xf800a000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf790=
000 ioremap
0xf800b000-0xf8010000   20480 module_alloc+0x72/0x80 pages=3D4 vmalloc
0xf8010000-0xf8019000   36864 acpi_os_map_memory+0x16/0x1f phys=3Ddf790=
000 ioremap
0xf801a000-0xf801c000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xf801d000-0xf8020000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8023000-0xf8026000   12288 module_alloc+0x72/0x80 pages=3D2 vmalloc
0xf8026000-0xf8028000    8192 msix_capability_init+0xae/0x2b0 phys=3Dfa=
4fe000 ioremap
0xf8028000-0xf802a000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xf802b000-0xf802e000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf802f000-0xf8032000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8033000-0xf8036000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8037000-0xf803a000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf803b000-0xf803e000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf803f000-0xf8048000   36864 module_alloc+0x72/0x80 pages=3D8 vmalloc
0xf804b000-0xf8055000   40960 module_alloc+0x72/0x80 pages=3D9 vmalloc
0xf8056000-0xf8059000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf805b000-0xf8063000   32768 module_alloc+0x72/0x80 pages=3D7 vmalloc
0xf8066000-0xf8068000    8192 msix_capability_init+0xae/0x2b0 phys=3Dfa=
4fa000 ioremap
0xf8068000-0xf8070000   32768 module_alloc+0x72/0x80 pages=3D7 vmalloc
0xf8072000-0xf8075000   12288 module_alloc+0x72/0x80 pages=3D2 vmalloc
0xf8076000-0xf8083000   53248 module_alloc+0x72/0x80 pages=3D12 vmalloc
0xf8084000-0xf8087000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8088000-0xf808b000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf808c000-0xf808f000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8090000-0xf8093000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8094000-0xf8097000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8098000-0xf809b000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf809c000-0xf809f000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf80a2000-0xf80ad000   45056 module_alloc+0x72/0x80 pages=3D10 vmalloc
0xf80ae000-0xf80b2000   16384 module_alloc+0x72/0x80 pages=3D3 vmalloc
0xf80b3000-0xf80b6000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf80b7000-0xf80ba000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf80bb000-0xf80be000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf80bf000-0xf80c2000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf80c3000-0xf80c6000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf80c8000-0xf80cd000   20480 pci_iomap+0x81/0x90 phys=3Dfa4fc000 iorem=
ap
0xf80ce000-0xf80d1000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf80d2000-0xf80d5000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf80d6000-0xf80d9000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf80da000-0xf80dd000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf80de000-0xf80e1000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf80e2000-0xf80e5000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf80e6000-0xf80e9000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf80ea000-0xf80ed000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf80ee000-0xf80f1000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf80f2000-0xf80f5000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf80f6000-0xf80f9000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf80fa000-0xf80fd000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf80fe000-0xf8101000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8102000-0xf8105000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8106000-0xf8109000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf810a000-0xf810d000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf810d000-0xf8118000   45056 module_alloc+0x72/0x80 pages=3D10 vmalloc
0xf8119000-0xf811c000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf811d000-0xf8120000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8121000-0xf8124000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8125000-0xf8128000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8129000-0xf812c000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf812d000-0xf8130000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8130000-0xf8132000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xf8133000-0xf8136000   12288 module_alloc+0x72/0x80 pages=3D2 vmalloc
0xf8137000-0xf813a000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf813e000-0xf8140000    8192 msix_capability_init+0xae/0x2b0 phys=3Dfa=
4f6000 ioremap
0xf8140000-0xf8145000   20480 pci_iomap+0x81/0x90 phys=3Dfa4f8000 iorem=
ap
0xf8146000-0xf8148000    8192 msix_capability_init+0xae/0x2b0 phys=3Dfa=
4f2000 ioremap
0xf8148000-0xf814d000   20480 pci_iomap+0x81/0x90 phys=3Dfa4f4000 iorem=
ap
0xf814e000-0xf8150000    8192 msix_capability_init+0xae/0x2b0 phys=3Dfa=
4ee000 ioremap
0xf8150000-0xf8155000   20480 pci_iomap+0x81/0x90 phys=3Dfa4f0000 iorem=
ap
0xf8156000-0xf8158000    8192 msix_capability_init+0xae/0x2b0 phys=3Dfa=
4ea000 ioremap
0xf8158000-0xf815d000   20480 pci_iomap+0x81/0x90 phys=3Dfa4ec000 iorem=
ap
0xf815e000-0xf8160000    8192 msix_capability_init+0xae/0x2b0 phys=3Dfa=
4e6000 ioremap
0xf8160000-0xf8165000   20480 pci_iomap+0x81/0x90 phys=3Dfa4e8000 iorem=
ap
0xf8166000-0xf8168000    8192 msix_capability_init+0xae/0x2b0 phys=3Dfa=
4e2000 ioremap
0xf8168000-0xf816d000   20480 pci_iomap+0x81/0x90 phys=3Dfa4e4000 iorem=
ap
0xf816e000-0xf8170000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xf8170000-0xf8175000   20480 pci_iomap+0x81/0x90 phys=3Dfa4e0000 iorem=
ap
0xf8176000-0xf8179000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf817a000-0xf817d000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf817e000-0xf8181000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8182000-0xf8185000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8186000-0xf8189000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf818e000-0xf819d000   61440 module_alloc+0x72/0x80 pages=3D14 vmalloc
0xf819e000-0xf81a1000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf81a2000-0xf81a5000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf81a6000-0xf81a9000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf81aa000-0xf81ad000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf81ae000-0xf81b1000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf81b2000-0xf81b5000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf81b6000-0xf81b9000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf81ba000-0xf81bd000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf81be000-0xf81c1000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf81c2000-0xf81c5000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf81fe000-0xf8201000   12288 e1000e_setup_tx_resources+0x27/0xb0 [e100=
0e] pages=3D2 vmalloc
0xf8202000-0xf8205000   12288 e1000e_setup_rx_resources+0x2a/0x120 [e10=
00e] pages=3D2 vmalloc
0xf8206000-0xf8209000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf820c000-0xf820f000   12288 module_alloc+0x72/0x80 pages=3D2 vmalloc
0xf8210000-0xf8213000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8214000-0xf8217000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8218000-0xf821c000   16384 module_alloc+0x72/0x80 pages=3D3 vmalloc
0xf8225000-0xf8228000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8229000-0xf822b000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xf82ab000-0xf82ae000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf82af000-0xf82b2000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf82b3000-0xf82b6000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf82b7000-0xf82ba000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf82bb000-0xf82be000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf82bf000-0xf82c2000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf82c3000-0xf82c6000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf82c7000-0xf82ca000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf82cb000-0xf82ce000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf82cf000-0xf82d2000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf82d3000-0xf82d6000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf82d7000-0xf82da000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf82db000-0xf82de000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf82df000-0xf82e2000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf82e3000-0xf82e6000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf82e7000-0xf82ea000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf82eb000-0xf82ee000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf82ef000-0xf82f2000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8332000-0xf8363000  200704 module_alloc+0x72/0x80 pages=3D48 vmalloc
0xf8364000-0xf8367000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8368000-0xf836b000   12288 e1000e_setup_tx_resources+0x27/0xb0 [e100=
0e] pages=3D2 vmalloc
0xf836c000-0xf836f000   12288 e1000e_setup_rx_resources+0x2a/0x120 [e10=
00e] pages=3D2 vmalloc
0xf8370000-0xf8373000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8374000-0xf8377000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8378000-0xf837b000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf837c000-0xf837f000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf837f000-0xf83a0000  135168 module_alloc+0x72/0x80 pages=3D32 vmalloc
0xf83a1000-0xf83a4000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf83a5000-0xf83a8000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf83a9000-0xf83ac000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf83ad000-0xf83b0000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf83b0000-0xf83ba000   40960 module_alloc+0x72/0x80 pages=3D9 vmalloc
0xf83bb000-0xf83bd000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xf83be000-0xf83c1000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf83cc000-0xf83e5000  102400 module_alloc+0x72/0x80 pages=3D24 vmalloc
0xf83ec000-0xf83ee000    8192 msix_capability_init+0xae/0x2b0 phys=3Dfa=
edc000 ioremap
0xf83f0000-0xf83f2000    8192 msix_capability_init+0xae/0x2b0 phys=3Dfa=
69c000 ioremap
0xf83fa000-0xf83fc000    8192 msix_capability_init+0xae/0x2b0 phys=3Dfa=
fdc000 ioremap
0xf83fe000-0xf8400000    8192 msix_capability_init+0xae/0x2b0 phys=3Dfa=
698000 ioremap
0xf8400000-0xf8421000  135168 e1000_probe+0x206/0x9d0 [e1000e] phys=3Df=
aee0000 ioremap
0xf8422000-0xf8424000    8192 msix_capability_init+0xae/0x2b0 phys=3Dfa=
79c000 ioremap
0xf8426000-0xf8428000    8192 msix_capability_init+0xae/0x2b0 phys=3Dfa=
798000 ioremap
0xf842a000-0xf842c000    8192 msix_capability_init+0xae/0x2b0 phys=3Dfa=
99c000 ioremap
0xf842e000-0xf8430000    8192 msix_capability_init+0xae/0x2b0 phys=3Dfa=
998000 ioremap
0xf8432000-0xf8434000    8192 msix_capability_init+0xae/0x2b0 phys=3Dfa=
a9c000 ioremap
0xf8436000-0xf8438000    8192 msix_capability_init+0xae/0x2b0 phys=3Dfa=
a98000 ioremap
0xf843a000-0xf843c000    8192 msix_capability_init+0xae/0x2b0 phys=3Dfa=
c9c000 ioremap
0xf843e000-0xf8440000    8192 msix_capability_init+0xae/0x2b0 phys=3Dfa=
c98000 ioremap
0xf8440000-0xf8461000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dfa6e00=
00 ioremap
0xf8462000-0xf8464000    8192 msix_capability_init+0xae/0x2b0 phys=3Dfa=
d9c000 ioremap
0xf8466000-0xf8468000    8192 msix_capability_init+0xae/0x2b0 phys=3Dfa=
d98000 ioremap
0xf846c000-0xf846e000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xf8476000-0xf8478000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xf8480000-0xf84a1000  135168 e1000_probe+0x206/0x9d0 [e1000e] phys=3Df=
afe0000 ioremap
0xf84a9000-0xf84af000   24576 module_alloc+0x72/0x80 pages=3D5 vmalloc
0xf84bc000-0xf84bf000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf84c0000-0xf84e1000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dfa6600=
00 ioremap
0xf84e2000-0xf84e5000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf84e6000-0xf84e9000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf84ea000-0xf84ed000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf84ee000-0xf84f1000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf84f2000-0xf84f5000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf84f6000-0xf84f9000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf84fb000-0xf84ff000   16384 module_alloc+0x72/0x80 pages=3D3 vmalloc
0xf8500000-0xf8521000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dfa7e00=
00 ioremap
0xf8522000-0xf852f000   53248 module_alloc+0x72/0x80 pages=3D12 vmalloc
0xf8530000-0xf8533000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8534000-0xf8537000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8538000-0xf853b000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf853c000-0xf853f000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8540000-0xf8561000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dfa7600=
00 ioremap
0xf8562000-0xf8565000   12288 module_alloc+0x72/0x80 pages=3D2 vmalloc
0xf8566000-0xf8569000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf856a000-0xf856c000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xf856d000-0xf8570000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8571000-0xf8574000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8575000-0xf8578000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8579000-0xf857c000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf857d000-0xf857f000    8192 swap_cgroup_swapon+0x3c/0x140 pages=3D1 v=
malloc
0xf8580000-0xf85a1000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dfa9e00=
00 ioremap
0xf85a2000-0xf85a5000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf85a6000-0xf85a9000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf85aa000-0xf85ad000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf85af000-0xf85b7000   32768 module_alloc+0x72/0x80 pages=3D7 vmalloc
0xf85b8000-0xf85bb000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf85bc000-0xf85bf000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf85c0000-0xf85e1000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dfa9600=
00 ioremap
0xf85e2000-0xf85ed000   45056 sys_swapon+0x5a6/0xa40 pages=3D10 vmalloc
0xf85ee000-0xf8600000   73728 module_alloc+0x72/0x80 pages=3D17 vmalloc
0xf8600000-0xf8621000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dfaae00=
00 ioremap
0xf8622000-0xf8625000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8626000-0xf8629000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf862a000-0xf862d000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf862e000-0xf8631000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8632000-0xf8635000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8636000-0xf8639000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf863a000-0xf863d000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8640000-0xf8661000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dfaa600=
00 ioremap
0xf8662000-0xf8665000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8666000-0xf8669000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf866a000-0xf866d000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf866e000-0xf8671000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8672000-0xf8675000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8676000-0xf8679000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf867a000-0xf867d000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8680000-0xf86a1000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dface00=
00 ioremap
0xf86a2000-0xf86a5000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf86a6000-0xf86a9000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf86aa000-0xf86ad000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf86ae000-0xf86b1000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf86b2000-0xf86b5000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf86b6000-0xf86b9000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf86ba000-0xf86bd000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf86c0000-0xf86e1000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dfac600=
00 ioremap
0xf86e2000-0xf86e5000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8700000-0xf8721000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dfade00=
00 ioremap
0xf8740000-0xf8761000  135168 igb_probe+0x1f5/0x87a [igb] phys=3Dfad600=
00 ioremap
0xf8762000-0xf8767000   20480 module_alloc+0x72/0x80 pages=3D4 vmalloc
0xf8768000-0xf876b000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf876c000-0xf876f000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8770000-0xf8773000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8774000-0xf8777000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8778000-0xf877b000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf877c000-0xf877f000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8780000-0xf8783000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8784000-0xf8787000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8788000-0xf878b000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf878c000-0xf878f000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8790000-0xf8793000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8793000-0xf87a4000   69632 module_alloc+0x72/0x80 pages=3D16 vmalloc
0xf87a5000-0xf87a8000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf87aa000-0xf87e7000  249856 module_alloc+0x72/0x80 pages=3D60 vmalloc
0xf87f4000-0xf87f7000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf87f8000-0xf87fb000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf87fe000-0xf8877000  495616 module_alloc+0x72/0x80 pages=3D120 vmallo=
c
0xf8878000-0xf887b000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf887c000-0xf887f000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8880000-0xf8883000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8884000-0xf8887000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8888000-0xf888b000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf888c000-0xf888f000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8890000-0xf8893000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8894000-0xf8897000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf8898000-0xf889b000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf889c000-0xf889f000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf88a0000-0xf88a3000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf88a4000-0xf88a7000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf88a8000-0xf88ab000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf88ac000-0xf88af000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xf88af000-0xf88d5000  155648 module_alloc+0x72/0x80 pages=3D37 vmalloc
0xf8a65000-0xf8a67000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xfa026000-0xfa028000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf79e=
000 ioremap
0xfa02a000-0xfa02c000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf790=
000 ioremap
0xfa03a000-0xfa03c000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf790=
000 ioremap
0xfa03e000-0xfa040000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf790=
000 ioremap
0xfa042000-0xfa044000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf79e=
000 ioremap
0xfa046000-0xfa048000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf79a=
000 ioremap
0xfa04a000-0xfa04c000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf79a=
000 ioremap
0xfa04e000-0xfa050000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf79a=
000 ioremap
0xfa052000-0xfa054000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf79a=
000 ioremap
0xfa056000-0xfa058000    8192 acpi_os_map_memory+0x16/0x1f phys=3Ddf79a=
000 ioremap
0xfa05e000-0xfa060000    8192 acpi_os_map_memory+0x16/0x1f phys=3Dfed1f=
000 ioremap
0xfa06e000-0xfa070000    8192 usb_hcd_pci_probe+0x17b/0x350 phys=3Dfa4d=
e000 ioremap
0xfa072000-0xfa074000    8192 usb_hcd_pci_probe+0x17b/0x350 phys=3Dfa4d=
c000 ioremap
0xfa78c000-0xfa79d000   69632 module_alloc+0x72/0x80 pages=3D16 vmalloc
0xfa805000-0xfa84a000  282624 module_alloc+0x72/0x80 pages=3D68 vmalloc
0xfc000000-0xfc400000 4194304 pcpu_get_vm_areas+0x0/0x610 vmalloc
0xfc400000-0xfc800000 4194304 pcpu_get_vm_areas+0x0/0x610 vmalloc
0xfc93f000-0xfc941000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xfc94b000-0xfc94e000   12288 module_alloc+0x72/0x80 pages=3D2 vmalloc
0xfc95e000-0xfc964000   24576 module_alloc+0x72/0x80 pages=3D5 vmalloc
0xfc96f000-0xfc972000   12288 module_alloc+0x72/0x80 pages=3D2 vmalloc
0xfcdcc000-0xfcddf000   77824 module_alloc+0x72/0x80 pages=3D18 vmalloc
0xfce11000-0xfce14000   12288 reqsk_queue_alloc+0x54/0xd0 pages=3D2 vma=
lloc
0xfce15000-0xfce18000   12288 reqsk_queue_alloc+0x54/0xd0 pages=3D2 vma=
lloc
0xfce19000-0xfce1c000   12288 reqsk_queue_alloc+0x54/0xd0 pages=3D2 vma=
lloc
0xfce21000-0xfce23000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xfce2a000-0xfce2c000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xfce30000-0xfce33000   12288 reqsk_queue_alloc+0x54/0xd0 pages=3D2 vma=
lloc
0xfce34000-0xfce37000   12288 reqsk_queue_alloc+0x54/0xd0 pages=3D2 vma=
lloc
0xfce38000-0xfce3b000   12288 reqsk_queue_alloc+0x54/0xd0 pages=3D2 vma=
lloc
0xfd0e7000-0xfd0ea000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd0eb000-0xfd0ee000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd0ef000-0xfd0f2000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd0f3000-0xfd0f6000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd0f7000-0xfd0fa000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd0fb000-0xfd0fe000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd0ff000-0xfd102000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd103000-0xfd106000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd107000-0xfd10a000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd10b000-0xfd10e000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd10f000-0xfd112000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd113000-0xfd116000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd117000-0xfd11a000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd11b000-0xfd11e000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd11f000-0xfd122000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd123000-0xfd126000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd127000-0xfd12a000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd12b000-0xfd12e000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd12f000-0xfd132000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd133000-0xfd136000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd137000-0xfd13a000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd13b000-0xfd13e000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd13f000-0xfd142000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd143000-0xfd146000   12288 igb_setup_tx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd147000-0xfd14a000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd14b000-0xfd14e000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd14f000-0xfd152000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd153000-0xfd156000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd157000-0xfd15a000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd15b000-0xfd15e000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd15f000-0xfd162000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd163000-0xfd166000   12288 igb_setup_rx_resources+0x27/0x140 [igb] p=
ages=3D2 vmalloc
0xfd1b2000-0xfd1b6000   16384 module_alloc+0x72/0x80 pages=3D3 vmalloc
0xfd1bf000-0xfd1c1000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xfd1cb000-0xfd1ce000   12288 module_alloc+0x72/0x80 pages=3D2 vmalloc
0xfd1d5000-0xfd1d7000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xfd1de000-0xfd1e0000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xfd1e8000-0xfd1ea000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xfd1f2000-0xfd1f4000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xfd1fb000-0xfd1fd000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xfd205000-0xfd207000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xfd20f000-0xfd211000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xfd219000-0xfd21b000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xfd223000-0xfd225000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xfd22d000-0xfd22f000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xfd23a000-0xfd23c000    8192 module_alloc+0x72/0x80 pages=3D1 vmalloc
0xfd248000-0xfd24c000   16384 module_alloc+0x72/0x80 pages=3D3 vmalloc
0xfd400000-0xfd800000 4194304 pcpu_get_vm_areas+0x0/0x610 vmalloc
0xfd800000-0xfdc00000 4194304 pcpu_get_vm_areas+0x0/0x610 vmalloc
0xfdc00000-0xfe000000 4194304 pcpu_get_vm_areas+0x0/0x610 vmalloc
0xfe000000-0xfe400000 4194304 pcpu_get_vm_areas+0x0/0x610 vmalloc
0xfe400000-0xfe800000 4194304 pcpu_get_vm_areas+0x0/0x610 vmalloc
0xfe800000-0xfec00000 4194304 pcpu_get_vm_areas+0x0/0x610 vmalloc
0xfec00000-0xff000000 4194304 pcpu_get_vm_areas+0x0/0x610 vmalloc
0xff000000-0xff400000 4194304 pcpu_get_vm_areas+0x0/0x610 vmalloc

Thanks,
Ben


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

