From: Ben Greear <greearb@candelatech.com>
Subject: OOM when adding ipv6 route:  How to make available more per-cpu memory?
Date: Fri, 05 Nov 2010 10:19:03 -0700
Message-ID: <4CD43C87.5040403@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49867 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752959Ab0KERTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 13:19:07 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id oA5HJ3uE003033
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 5 Nov 2010 10:19:03 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We are testing 500 mac-vlans with IPv6 addresses on a 32-bit kernel
(2.6.36 + ubuntu patches + our patches)  We have one
routing table per interface.  It seems that some of them cannot
add routes due to lack of memory.

root@lanforge-ubuntu:/home/lanforge# ip route show table 29
root@lanforge-ubuntu:/home/lanforge# ./local/sbin/ip -6 route add default via 2001:98::1 dev eth12#15 table 29
RTNETLINK answers: Cannot allocate memory

I see errors such as this in the logs:

[507107.846864] PERCPU: allocation failed, size=2048 align=4, failed to allocate new chunk
[507107.846867] Pid: 3246, comm: ip Tainted: P            2.6.36-1-ct #7
[507107.846869] Call Trace:
[507107.846874]  [<c05d4996>] ? printk+0x2d/0x2f
[507107.846878]  [<c021405e>] pcpu_alloc+0x32e/0x360
[507107.846880]  [<c02140bf>] __alloc_percpu+0xf/0x20
[507107.846883]  [<c0558d6d>] snmp_mib_init+0x3d/0x70
[507107.846885]  [<c0585692>] ipv6_add_dev+0x132/0x350
[507107.846887]  [<c0557f39>] ? inetdev_init+0xb9/0x180
[507107.846889]  [<c05895ff>] addrconf_notify+0x3f/0x490
[507107.846891]  [<c055884f>] ? inetdev_event+0x20f/0x280
[507107.846894]  [<c05daef3>] notifier_call_chain+0x43/0x60
[507107.846897]  [<c016df4f>] raw_notifier_call_chain+0x1f/0x30
[507107.846899]  [<c05008ec>] call_netdevice_notifiers+0x2c/0x60
[507107.846901]  [<c0502ecc>] register_netdevice+0x23c/0x380
[507107.846907]  [<f80aecf7>] macvlan_common_newlink+0x187/0x2a0 [macvlan]
[507107.846910]  [<f80ae540>] ? macvlan_setup+0x0/0x20 [macvlan]
[507107.846912]  [<f80aee37>] macvlan_newlink+0x27/0x30 [macvlan]
[507107.846914]  [<c0503060>] ? netif_rx+0x0/0x120
[507107.846915]  [<c05033c0>] ? dev_forward_skb+0x0/0xf0
[507107.846917]  [<f80aee10>] ? macvlan_newlink+0x0/0x30 [macvlan]
[507107.846920]  [<c050ea94>] rtnl_newlink+0x464/0x590
[507107.846921]  [<c050e7e6>] ? rtnl_newlink+0x1b6/0x590
[507107.846927]  [<c050cd2d>] rtnetlink_rcv_msg+0x13d/0x230
[507107.846929]  [<c05d721f>] ? _raw_spin_lock_irqsave+0x2f/0x50
[507107.846931]  [<c050e630>] ? rtnl_newlink+0x0/0x590
[507107.846933]  [<c050cbf0>] ? rtnetlink_rcv_msg+0x0/0x230
[507107.846935]  [<c0522276>] netlink_rcv_skb+0x86/0xb0
[507107.846936]  [<c050cbdc>] rtnetlink_rcv+0x1c/0x30
[507107.846938]  [<c0521f69>] netlink_unicast+0x259/0x280
[507107.846940]  [<c0522ba8>] netlink_sendmsg+0x1f8/0x300
[507107.846943]  [<c04f0b79>] sock_sendmsg+0xd9/0x100
[507107.846945]  [<c013e0dd>] ? finish_task_switch+0x3d/0xc0
[507107.846947]  [<c04f0b79>] ? sock_sendmsg+0xd9/0x100
[507107.846950]  [<c013361d>] ? kmap_atomic_prot+0xcd/0xf0
[507107.846957]  [<f88bd559>] ? h_d_revalidate+0xe9/0x240 [aufs]
[507107.846958]  [<c013361d>] ? kmap_atomic_prot+0xcd/0xf0
[507107.846962]  [<c0364c7d>] ? _copy_from_user+0x3d/0x130
[507107.846965]  [<c04f947a>] ? verify_iovec+0x5a/0xa0
[507107.846966]  [<c04f112d>] sys_sendmsg+0x15d/0x290
[507107.846972]  [<f88c05f1>] ? aufs_fault+0xf1/0x110 [aufs]
[507107.846974]  [<c013361d>] ? kmap_atomic_prot+0xcd/0xf0
[507107.846977]  [<c01f8726>] ? handle_mm_fault+0x146/0x400
[507107.846979]  [<c05dac0d>] ? do_page_fault+0x1cd/0x470
[507107.846981]  [<c023419d>] ? alloc_fd+0xbd/0xf0
[507107.846983]  [<c0364c7d>] ? _copy_from_user+0x3d/0x130
[507107.846986]  [<c04f183b>] sys_socketcall+0xeb/0x2a0
[507107.846989]  [<c0151d99>] ? irq_exit+0x39/0x70
[507107.846991]  [<c021bb2e>] ? sys_open+0x2e/0x40
[507107.846993]  [<c05d77a4>] syscall_call+0x7/0xb


But, it appears to me that we have plenty of memory available.

top - 10:09:13 up 6 days, 15:56,  9 users,  load average: 0.37, 0.39, 0.45
Tasks: 211 total,   2 running, 209 sleeping,   0 stopped,   0 zombie
Cpu(s):  0.7%us,  2.1%sy,  0.0%ni, 97.2%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Mem:   3604332k total,  1510252k used,  2094080k free,    84928k buffers
Swap:   154620k total,        0k used,   154620k free,  1045912k cached

   PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND


      root@lanforge-ubuntu:/home/lanforge# cat /proc/meminfo
MemTotal:        3604332 kB
MemFree:         2094568 kB
Buffers:           84928 kB
Cached:          1045920 kB
SwapCached:            0 kB
Active:           466784 kB
Inactive:         805632 kB
Active(anon):     148988 kB
Inactive(anon):     6788 kB
Active(file):     317796 kB
Inactive(file):   798844 kB
Unevictable:           0 kB
Mlocked:               0 kB
HighTotal:       2752008 kB
HighFree:        1512380 kB
LowTotal:         852324 kB
LowFree:          582188 kB
SwapTotal:        154620 kB
SwapFree:         154620 kB
Dirty:               492 kB
Writeback:             0 kB
AnonPages:        141316 kB
Mapped:            39428 kB
Shmem:             14208 kB
Slab:             170788 kB
SReclaimable:      81904 kB
SUnreclaim:        88884 kB
KernelStack:        2520 kB
PageTables:         4516 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     1956784 kB
Committed_AS:     582604 kB
VmallocTotal:     122880 kB
VmallocUsed:       48592 kB
VmallocChunk:      24280 kB
HardwareCorrupted:     0 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       4096 kB
DirectMap4k:       12280 kB
DirectMap4M:      897024 kB


Is there any way to tune the system so that it has more memory available
for per-cpu data structures?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

