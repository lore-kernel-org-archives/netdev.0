From: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>
Subject: Re: intel i40e buggy driver question
Date: Sat, 28 Oct 2017 01:08:40 +0200
Message-ID: <acc3dcb6-2870-b5f7-027b-a1f7020b6ecd@itcare.pl>
References: <3a5e66fb-8751-cce4-59de-b3915c01b5ac@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
To: =?UTF-8?Q?Pawe=c5=82_Staszewski?= <pstaszewski@itcare.pl>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp20.iq.pl ([86.111.242.225]:53583 "EHLO smtp20.iq.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751167AbdJ0XIk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Oct 2017 19:08:40 -0400
In-Reply-To: <3a5e66fb-8751-cce4-59de-b3915c01b5ac@itcare.pl>
Content-Language: pl
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



W dniu 2017-10-28 o 00:34, Paweł Staszewski pisze:
> Hi
>
>
>
>
> I have many problems with 40e driver
>
> memleaks , kernel panics , stack traces , tx hungx , tx timeouts and 
> many many others :)
>
>
> But the main problem that can't be resolved in linux is resolved in 
> freebsd
>
> problem in freebsd with this:
>
> [2501243.181829] i40e 0000:01:00.1 eno2: VSI_seid 390, Hung TX queue 
> 17, tx_pending_hw: 1, NTC:0x16b, HWB: 0x16b, NTU: 0x16c, TAIL: 0x16c
> [2501243.181835] i40e 0000:01:00.1 eno2: VSI_seid 390, Issuing 
> force_wb for TX queue 17, Interrupt Reg: 0x0
>
>
> Was solved by this:
>
>
> "
>
> change this piece in ixl_tso_detect_sparse() in ixl_txrx.c:
>
>             if (mss < 1) {
>                     if (num > IXL_SPARSE_CHAIN)
>                             return (true);
>                     num = (mss == 0) ? 0 : 1;
>                     mss += mp->m_pkthdr.tso_segsz;
>             }
>
> to
>
>             if (num > IXL_SPARSE_CHAIN)
>                     return (true);
>             if (mss < 1) {
>                     num = (mss == 0) ? 0 : 1;
>                     mss += mp->m_pkthdr.tso_segsz;
>             }
>
> Intel FreeBSD Team: This will definitely prevent MDDs on the buffers 
> you sent me.
>
> "
>
>
> An I have a question - how to do the same in linux ? :)
>
> Cause i have same problem in Linux with this i40e buggy driver:
>
> [224051.287277] WARNING: CPU: 3 PID: 25031 at 
> drivers/net/ethernet/intel/i40e/i40e_txrx.c:1248 
> i40e_setup_rx_descriptors+0x15/0xa9
> [224051.287278] Modules linked in: team_mode_roundrobin team 
> x86_pkg_temp_thermal ipmi_si
> [224051.287327] CPU: 3 PID: 25031 Comm: ip Tainted: G W 4.12.14 #2
> [224051.287330] task: ffff880859e09880 task.stack: ffffc900036ec000
> [224051.287332] RIP: 0010:i40e_setup_rx_descriptors+0x15/0xa9
> [224051.287332] RSP: 0018:ffffc900036ef6e8 EFLAGS: 00010286
> [224051.287333] RAX: ffff8808595eda00 RBX: ffff880856d36d00 RCX: 
> 014000c000000001
> [224051.287334] RDX: 0000000000000001 RSI: ffff880844418000 RDI: 
> ffff880856d36d00
> [224051.287334] RBP: ffffc900036ef6f8 R08: 000000000001ccc3 R09: 
> ffffea0021110620
> [224051.287335] R10: 0000000000000000 R11: ffff88087effae90 R12: 
> ffff8808590300a0
> [224051.287335] R13: 0000000000000002 R14: 00000000fffffff0 R15: 
> 0000000000000001
> [224051.287336] FS:  00007f1e4658b740(0000) GS:ffff88085e2c0000(0000) 
> knlGS:0000000000000000
> [224051.287337] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [224051.287337] CR2: 00007ffd74790000 CR3: 000000059e2f4000 CR4: 
> 00000000001406e0
> [224051.287338] Call Trace:
> [224051.287339]  i40e_vsi_open+0x7d/0x1e7
> [224051.287341]  i40e_open+0x4d/0xc3
> [224051.287342]  __dev_open+0x8b/0xcd
> [224051.287344]  __dev_change_flags+0xa2/0x13d
> [224051.287346]  dev_change_flags+0x20/0x53
> [224051.287347]  do_setlink+0x2d0/0xad6
> [224051.287349]  ? zone_statistics+0x5a/0x61
> [224051.287350]  ? get_page_from_freelist+0x4c8/0x627
> [224051.287352]  rtnl_newlink+0x391/0x6d6
> [224051.287353]  ? netdev_master_upper_dev_get+0xd/0x57
> [224051.287354]  ? rtnl_newlink+0x106/0x6d6
> [224051.287356]  ? alloc_pages_vma+0x8c/0x17a
> [224051.287357]  ? pagevec_lru_move_fn+0x20/0xc1
> [224051.287359]  ? lru_cache_add_active_or_unevictable+0x27/0x7a
> [224051.287360]  ? __handle_mm_fault+0x4c1/0x8ae
> [224051.287362]  rtnetlink_rcv_msg+0x166/0x173
> [224051.287363]  ? __kmalloc_node_track_caller+0x11f/0x12f
> [224051.287365]  ? __alloc_skb+0x89/0x175
> [224051.287366]  ? rtnl_newlink+0x6d6/0x6d6
> [224051.287367]  netlink_rcv_skb+0x57/0xa0
> [224051.287369]  rtnetlink_rcv+0x1e/0x25
> [224051.287371]  netlink_unicast+0x103/0x187
> [224051.287372]  netlink_sendmsg+0x28d/0x2ad
> [224051.287374]  sock_sendmsg_nosec+0x12/0x1d
> [224051.287375]  ___sys_sendmsg+0x19d/0x217
> [224051.287377]  ? kmem_cache_free+0x4b/0xf3
> [224051.287492]  ? alloc_pages_vma+0x147/0x17a
> [224051.287494]  ? __page_set_anon_rmap+0x24/0x65
> [224051.287495]  ? get_page+0x9/0xf
> [224051.287496]  ? __lru_cache_add+0x18/0x47
> [224051.287498]  ? __handle_mm_fault+0x4c1/0x8ae
> [224051.287499]  __sys_sendmsg+0x40/0x5e
> [224051.287564]  ? __sys_sendmsg+0x40/0x5e
> [224051.287566]  SyS_sendmsg+0xd/0x17
> [224051.287567]  entry_SYSCALL_64_fastpath+0x13/0x94
> [224051.287568] RIP: 0033:0x7f1e45cac620
> [224051.287569] RSP: 002b:00007ffd7478b4d8 EFLAGS: 00000246 ORIG_RAX: 
> 000000000000002e
> [224051.287570] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 
> 00007f1e45cac620
> [224051.287571] RDX: 0000000000000000 RSI: 00007ffd7478b520 RDI: 
> 0000000000000003
> [224051.287572] RBP: 00007ffd7478b520 R08: 0000000000000001 R09: 
> fefefeff77686d74
> [224051.287572] R10: 00000000000005e6 R11: 0000000000000246 R12: 
> 00007ffd7478b560
> [224051.287573] R13: 00000000006724c0 R14: 00007ffd747935e0 R15: 
> 0000000000000000
> [224051.287574] Code: 00 00 48 8b 7b 10 e8 41 f2 ff ff 48 c7 43 08 00 
> 00 00 00 5b 5d c3 55 48 89 e5 41 54 53 48 83 7f 20 00 48 89 fb 4c 8b 
> 67 10 74 02 <0f> ff 0f b7 7b 44 48 6b ff 18 e8 65 f5 ff ff 48 85 c0 48 
> 89 43
> [224051.287597] ---[ end trace a9810da52af61a5a ]---
> [224051.287607] ------------[ cut here ]------------
> [224051.287609] WARNING: CPU: 3 PID: 25031 at 
> drivers/net/ethernet/intel/i40e/i40e_txrx.c:1248 
> i40e_setup_rx_descriptors+0x15/0xa9
> [224051.287609] Modules linked in: team_mode_roundrobin team 
> x86_pkg_temp_thermal ipmi_si
> [224051.287612] CPU: 3 PID: 25031 Comm: ip Tainted: G W 4.12.14 #2
> [224051.287613] task: ffff880859e09880 task.stack: ffffc900036ec000
> [224051.287614] RIP: 0010:i40e_setup_rx_descriptors+0x15/0xa9
> [224051.287615] RSP: 0018:ffffc900036ef6e8 EFLAGS: 00010286
> [224051.287616] RAX: ffff8808595eda00 RBX: ffff880856d36f00 RCX: 
> 014000c000000002
> [224051.287617] RDX: 0000000000000002 RSI: ffff880590cb4000 RDI: 
> ffff880856d36f00
> [224051.287618] RBP: ffffc900036ef6f8 R08: 000000000001ccc3 R09: 
> ffffea0016432d20
> [224051.287618] R10: 0000000000000000 R11: ffff88087effae90 R12: 
> ffff8808590300a0
> [224051.287619] R13: 0000000000000003 R14: 00000000fffffff0 R15: 
> 0000000000000001
> [224051.287620] FS:  00007f1e4658b740(0000) GS:ffff88085e2c0000(0000) 
> knlGS:0000000000000000
> [224051.287621] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [224051.287622] CR2: 00007ffd74790000 CR3: 000000059e2f4000 CR4: 
> 00000000001406e0
> [224051.287622] Call Trace:
> [224051.287624]  i40e_vsi_open+0x7d/0x1e7
> [224051.288201]  i40e_open+0x4d/0xc3
> [224051.288203]  __dev_open+0x8b/0xcd
> [224051.288205]  __dev_change_flags+0xa2/0x13d
> [224051.288207]  dev_change_flags+0x20/0x53
> [224051.288208]  do_setlink+0x2d0/0xad6
> [224051.288210]  ? zone_statistics+0x5a/0x61
> [224051.288212]  ? get_page_from_freelist+0x4c8/0x627
> [224051.288213]  rtnl_newlink+0x391/0x6d6
> [224051.288215]  ? netdev_master_upper_dev_get+0xd/0x57
> [224051.288216]  ? rtnl_newlink+0x106/0x6d6
> [224051.288217]  ? alloc_pages_vma+0x8c/0x17a
> [224051.288219]  ? pagevec_lru_move_fn+0x20/0xc1
> [224051.288220]  ? lru_cache_add_active_or_unevictable+0x27/0x7a
> [224051.288221]  ? __handle_mm_fault+0x4c1/0x8ae
> [224051.288224]  rtnetlink_rcv_msg+0x166/0x173
> [224051.288225]  ? __kmalloc_node_track_caller+0x11f/0x12f
> [224051.288227]  ? __alloc_skb+0x89/0x175
> [224051.288228]  ? rtnl_newlink+0x6d6/0x6d6
> [224051.288230]  netlink_rcv_skb+0x57/0xa0
> [224051.288232]  rtnetlink_rcv+0x1e/0x25
> [224051.288233]  netlink_unicast+0x103/0x187
> [224051.288235]  netlink_sendmsg+0x28d/0x2ad
> [224051.288236]  sock_sendmsg_nosec+0x12/0x1d
> [224051.288238]  ___sys_sendmsg+0x19d/0x217
> [224051.288239]  ? kmem_cache_free+0x4b/0xf3
> [224051.288241]  ? alloc_pages_vma+0x147/0x17a
> [224051.288242]  ? __page_set_anon_rmap+0x24/0x65
> [224051.288244]  ? get_page+0x9/0xf
> [224051.288245]  ? __lru_cache_add+0x18/0x47
> [224051.288246]  ? __handle_mm_fault+0x4c1/0x8ae
> [224051.288249]  __sys_sendmsg+0x40/0x5e
> [224051.288250]  ? __sys_sendmsg+0x40/0x5e
> [224051.288252]  SyS_sendmsg+0xd/0x17
> [224051.288253]  entry_SYSCALL_64_fastpath+0x13/0x94
> [224051.288254] RIP: 0033:0x7f1e45cac620
> [224051.288255] RSP: 002b:00007ffd7478b4d8 EFLAGS: 00000246 ORIG_RAX: 
> 000000000000002e
> [224051.288256] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 
> 00007f1e45cac620
> [224051.288257] RDX: 0000000000000000 RSI: 00007ffd7478b520 RDI: 
> 0000000000000003
> [224051.288258] RBP: 00007ffd7478b520 R08: 0000000000000001 R09: 
> fefefeff77686d74
> [224051.288259] R10: 00000000000005e6 R11: 0000000000000246 R12: 
> 00007ffd7478b560
> [224051.288259] R13: 00000000006724c0 R14: 00007ffd747935e0 R15: 
> 0000000000000000
> [224051.288260] Code: 00 00 48 8b 7b 10 e8 41 f2 ff ff 48 c7 43 08 00 
> 00 00 00 5b 5d c3 55 48 89 e5 41 54 53 48 83 7f 20 00 48 89 fb 4c 8b 
> 67 10 74 02 <0f> ff 0f b7 7b 44 48 6b ff 18 e8 65 f5 ff ff 48 85 c0 48 
> 89 43
> [224051.288284] ---[ end trace a9810da52af61a5b ]---
> [224051.288291] ------------[ cut here ]------------
> [224051.288293] WARNING: CPU: 3 PID: 25031 at 
> drivers/net/ethernet/intel/i40e/i40e_txrx.c:1248 
> i40e_setup_rx_descriptors+0x15/0xa9
> [224051.288293] Modules linked in: team_mode_roundrobin team 
> x86_pkg_temp_thermal ipmi_si
> [224051.288295] CPU: 3 PID: 25031 Comm: ip Tainted: G W 4.12.14 #2
> [224051.288296] task: ffff880859e09880 task.stack: ffffc900036ec000
> [224051.288297] RIP: 0010:i40e_setup_rx_descriptors+0x15/0xa9
> [224051.288297] RSP: 0018:ffffc900036ef6e8 EFLAGS: 00010286
> [224051.288298] RAX: ffff8808595eda00 RBX: ffff880856d37100 RCX: 
> 014000c000000003
> [224051.288299] RDX: 0000000000000003 RSI: ffff880845df0000 RDI: 
> ffff880856d37100
> [224051.288300] RBP: ffffc900036ef6f8 R08: 000000000001ccc3 R09: 
> ffffea0021177c20
> [224051.288300] R10: 0000000000000000 R11: ffff88087effae90 R12: 
> ffff8808590300a0
> [224051.288301] R13: 0000000000000004 R14: 00000000fffffff0 R15: 
> 0000000000000001
> [224051.288302] FS:  00007f1e4658b740(0000) GS:ffff88085e2c0000(0000) 
> knlGS:0000000000000000
> [224051.288303] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [224051.288303] CR2: 00007ffd74790000 CR3: 000000059e2f4000 CR4: 
> 00000000001406e0
> [224051.288304] Call Trace:
> [224051.288306]  i40e_vsi_open+0x7d/0x1e7
> [224051.288307]  i40e_open+0x4d/0xc3
> [224051.288309]  __dev_open+0x8b/0xcd
> [224051.288311]  __dev_change_flags+0xa2/0x13d
> [224051.288313]  dev_change_flags+0x20/0x53
> [224051.288314]  do_setlink+0x2d0/0xad6
> [224051.288315]  ? zone_statistics+0x5a/0x61
> [224051.288317]  ? get_page_from_freelist+0x4c8/0x627
> [224051.288319]  rtnl_newlink+0x391/0x6d6
> [224051.288320]  ? netdev_master_upper_dev_get+0xd/0x57
> [224051.288321]  ? rtnl_newlink+0x106/0x6d6
> [224051.288322]  ? alloc_pages_vma+0x8c/0x17a
> [224051.288323]  ? pagevec_lru_move_fn+0x20/0xc1
> [224051.288324]  ? lru_cache_add_active_or_unevictable+0x27/0x7a
> [224051.288324]  ? __handle_mm_fault+0x4c1/0x8ae
> [224051.288326]  rtnetlink_rcv_msg+0x166/0x173
> [224051.288327]  ? __kmalloc_node_track_caller+0x11f/0x12f
> [224051.288328]  ? __alloc_skb+0x89/0x175
> [224051.288328]  ? rtnl_newlink+0x6d6/0x6d6
> [224051.288330]  netlink_rcv_skb+0x57/0xa0
> [224051.288331]  rtnetlink_rcv+0x1e/0x25
> [224051.288332]  netlink_unicast+0x103/0x187
> [224051.288333]  netlink_sendmsg+0x28d/0x2ad
> [224051.288334]  sock_sendmsg_nosec+0x12/0x1d
> [224051.288335]  ___sys_sendmsg+0x19d/0x217
> [224051.288336]  ? kmem_cache_free+0x4b/0xf3
> [224051.288337]  ? alloc_pages_vma+0x147/0x17a
> [224051.288339]  ? __page_set_anon_rmap+0x24/0x65
> [224051.288340]  ? get_page+0x9/0xf
> [224051.288341]  ? __lru_cache_add+0x18/0x47
> [224051.288342]  ? __handle_mm_fault+0x4c1/0x8ae
> [224051.288344]  __sys_sendmsg+0x40/0x5e
> [224051.288345]  ? __sys_sendmsg+0x40/0x5e
> [224051.288347]  SyS_sendmsg+0xd/0x17
> [224051.288349]  entry_SYSCALL_64_fastpath+0x13/0x94
> [224051.288349] RIP: 0033:0x7f1e45cac620
> [224051.288350] RSP: 002b:00007ffd7478b4d8 EFLAGS: 00000246 ORIG_RAX: 
> 000000000000002e
> [224051.288351] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 
> 00007f1e45cac620
> [224051.288352] RDX: 0000000000000000 RSI: 00007ffd7478b520 RDI: 
> 0000000000000003
> [224051.288353] RBP: 00007ffd7478b520 R08: 0000000000000001 R09: 
> fefefeff77686d74
> [224051.288353] R10: 00000000000005e6 R11: 0000000000000246 R12: 
> 00007ffd7478b560
> [224051.288354] R13: 00000000006724c0 R14: 00007ffd747935e0 R15: 
> 0000000000000000
> [224051.288355] Code: 00 00 48 8b 7b 10 e8 41 f2 ff ff 48 c7 43 08 00 
> 00 00 00 5b 5d c3 55 48 89 e5 41 54 53 48 83 7f 20 00 48 89 fb 4c 8b 
> 67 10 74 02 <0f> ff 0f b7 7b 44 48 6b ff 18 e8 65 f5 ff ff 48 85 c0 48 
> 89 43
> [224051.288376] ---[ end trace a9810da52af61a5c ]---
> [224051.288382] ------------[ cut here ]------------
> [224051.288384] WARNING: CPU: 3 PID: 25031 at 
> drivers/net/ethernet/intel/i40e/i40e_txrx.c:1248 
> i40e_setup_rx_descriptors+0x15/0xa9
> [224051.288384] Modules linked in: team_mode_roundrobin team 
> x86_pkg_temp_thermal ipmi_si
> [224051.288387] CPU: 3 PID: 25031 Comm: ip Tainted: G W 4.12.14 #2
> [224051.288387] task: ffff880859e09880 task.stack: ffffc900036ec000
> [224051.288389] RIP: 0010:i40e_setup_rx_descriptors+0x15/0xa9
> [224051.288389] RSP: 0018:ffffc900036ef6e8 EFLAGS: 00010286
> [224051.288391] RAX: ffff8808595eda00 RBX: ffff880856d37300 RCX: 
> 014000c000000004
> [224051.288391] RDX: 0000000000000004 RSI: ffff88084bf2c000 RDI: 
> ffff880856d37300
> [224051.288392] RBP: ffffc900036ef6f8 R08: 000000000001ccc3 R09: 
> ffffea00212fcb20
> [224051.288393] R10: 0000000000000000 R11: ffff88087effae90 R12: 
> ffff8808590300a0
> [224051.288393] R13: 0000000000000005 R14: 00000000fffffff0 R15: 
> 0000000000000001
> [224051.288394] FS:  00007f1e4658b740(0000) GS:ffff88085e2c0000(0000) 
> knlGS:0000000000000000
> [224051.288395] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [224051.288396] CR2: 00007ffd74790000 CR3: 000000059e2f4000 CR4: 
> 00000000001406e0
> [224051.288396] Call Trace:
> [224051.288398]  i40e_vsi_open+0x7d/0x1e7
> [224051.288399]  i40e_open+0x4d/0xc3
> [224051.288401]  __dev_open+0x8b/0xcd
> [224051.288403]  __dev_change_flags+0xa2/0x13d
> [224051.288404]  dev_change_flags+0x20/0x53
> [224051.288405]  do_setlink+0x2d0/0xad6
> [224051.288406]  ? zone_statistics+0x5a/0x61
> [224051.288408]  ? get_page_from_freelist+0x4c8/0x627
> [224051.288409]  rtnl_newlink+0x391/0x6d6
> [224051.288409]  ? netdev_master_upper_dev_get+0xd/0x57
> [224051.288410]  ? rtnl_newlink+0x106/0x6d6
> [224051.288411]  ? alloc_pages_vma+0x8c/0x17a
> [224051.288412]  ? pagevec_lru_move_fn+0x20/0xc1
> [224051.288413]  ? lru_cache_add_active_or_unevictable+0x27/0x7a
> [224051.288414]  ? __handle_mm_fault+0x4c1/0x8ae
> [224051.288415]  rtnetlink_rcv_msg+0x166/0x173
> [224051.288416]  ? __kmalloc_node_track_caller+0x11f/0x12f
> [224051.288417]  ? __alloc_skb+0x89/0x175
> [224051.288418]  ? rtnl_newlink+0x6d6/0x6d6
> [224051.288419]  netlink_rcv_skb+0x57/0xa0
> [224051.288421]  rtnetlink_rcv+0x1e/0x25
> [224051.288422]  netlink_unicast+0x103/0x187
> [224051.288424]  netlink_sendmsg+0x28d/0x2ad
> [224051.288425]  sock_sendmsg_nosec+0x12/0x1d
> [224051.288426]  ___sys_sendmsg+0x19d/0x217
> [224051.288427]  ? kmem_cache_free+0x4b/0xf3
> [224051.288429]  ? alloc_pages_vma+0x147/0x17a
> [224051.288431]  ? __page_set_anon_rmap+0x24/0x65
> [224051.288432]  ? get_page+0x9/0xf
> [224051.288433]  ? __lru_cache_add+0x18/0x47
> [224051.288434]  ? __handle_mm_fault+0x4c1/0x8ae
> [224051.288436]  __sys_sendmsg+0x40/0x5e
> [224051.288437]  ? __sys_sendmsg+0x40/0x5e
> [224051.288438]  SyS_sendmsg+0xd/0x17
> [224051.288439]  entry_SYSCALL_64_fastpath+0x13/0x94
> [224051.288440] RIP: 0033:0x7f1e45cac620
> [224051.288440] RSP: 002b:00007ffd7478b4d8 EFLAGS: 00000246 ORIG_RAX: 
> 000000000000002e
> [224051.288441] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 
> 00007f1e45cac620
> [224051.288441] RDX: 0000000000000000 RSI: 00007ffd7478b520 RDI: 
> 0000000000000003
> [224051.288442] RBP: 00007ffd7478b520 R08: 0000000000000001 R09: 
> fefefeff77686d74
> [224051.288442] R10: 00000000000005e6 R11: 0000000000000246 R12: 
> 00007ffd7478b560
> [224051.288443] R13: 00000000006724c0 R14: 00007ffd747935e0 R15: 
> 0000000000000000
> [224051.288444] Code: 00 00 48 8b 7b 10 e8 41 f2 ff ff 48 c7 43 08 00 
> 00 00 00 5b 5d c3 55 48 89 e5 41 54 53 48 83 7f 20 00 48 89 fb 4c 8b 
> 67 10 74 02 <0f> ff 0f b7 7b 44 48 6b ff 18 e8 65 f5 ff ff 48 85 c0 48 
> 89 43
> [224051.288459] ---[ end trace a9810da52af61a5d ]---
> [224051.288467] ------------[ cut here ]------------
> [224051.288469] WARNING: CPU: 3 PID: 25031 at 
> drivers/net/ethernet/intel/i40e/i40e_txrx.c:1248 
> i40e_setup_rx_descriptors+0x15/0xa9
> [224051.288470] Modules linked in: team_mode_roundrobin team 
> x86_pkg_temp_thermal ipmi_si
> [224051.288473] CPU: 3 PID: 25031 Comm: ip Tainted: G W 4.12.14 #2
> [224051.288473] task: ffff880859e09880 task.stack: ffffc900036ec000
> [224051.288475] RIP: 0010:i40e_setup_rx_descriptors+0x15/0xa9
> [224051.288475] RSP: 0018:ffffc900036ef6e8 EFLAGS: 00010286
> [224051.288476] RAX: ffff8808595eda00 RBX: ffff880856d37500 RCX: 
> 014000c000000005
> [224051.288477] RDX: 0000000000000005 RSI: ffff880847778000 RDI: 
> ffff880856d37500
> [224051.288478] RBP: ffffc900036ef6f8 R08: 000000000001ccc3 R09: 
> ffffea00211dde20
> [224051.288479] R10: 0000000000000000 R11: ffff88087effae90 R12: 
> ffff8808590300a0
> [224051.288479] R13: 0000000000000006 R14: 00000000fffffff0 R15: 
> 0000000000000001
> [224051.288480] FS:  00007f1e4658b740(0000) GS:ffff88085e2c0000(0000) 
> knlGS:0000000000000000
> [224051.288481] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [224051.288482] CR2: 00007ffd74790000 CR3: 000000059e2f4000 CR4: 
> 00000000001406e0
> [224051.288482] Call Trace:
> [224051.288484]  i40e_vsi_open+0x7d/0x1e7
> [224051.288486]  i40e_open+0x4d/0xc3
> [224051.288487]  __dev_open+0x8b/0xcd
> [224051.288489]  __dev_change_flags+0xa2/0x13d
> [224051.288491]  dev_change_flags+0x20/0x53
> [224051.288492]  do_setlink+0x2d0/0xad6
> [224051.288494]  ? zone_statistics+0x5a/0x61
> [224051.288496]  ? get_page_from_freelist+0x4c8/0x627
> [224051.288497]  rtnl_newlink+0x391/0x6d6
> [224051.288498]  ? netdev_master_upper_dev_get+0xd/0x57
> [224051.288499]  ? rtnl_newlink+0x106/0x6d6
> [224051.288501]  ? alloc_pages_vma+0x8c/0x17a
> [224051.288503]  ? pagevec_lru_move_fn+0x20/0xc1
> [224051.288504]  ? lru_cache_add_active_or_unevictable+0x27/0x7a
> [224051.288505]  ? __handle_mm_fault+0x4c1/0x8ae
> [224051.288507]  rtnetlink_rcv_msg+0x166/0x173
> [224051.288509]  ? __kmalloc_node_track_caller+0x11f/0x12f
> [224051.288510]  ? __alloc_skb+0x89/0x175
> [224051.288511]  ? rtnl_newlink+0x6d6/0x6d6
> [224051.288513]  netlink_rcv_skb+0x57/0xa0
> [224051.288515]  rtnetlink_rcv+0x1e/0x25
> [224051.288516]  netlink_unicast+0x103/0x187
> [224051.288518]  netlink_sendmsg+0x28d/0x2ad
> [224051.288520]  sock_sendmsg_nosec+0x12/0x1d
> [224051.288521]  ___sys_sendmsg+0x19d/0x217
> [224051.288523]  ? kmem_cache_free+0x4b/0xf3
> [224051.288524]  ? alloc_pages_vma+0x147/0x17a
> [224051.288526]  ? __page_set_anon_rmap+0x24/0x65
> [224051.288527]  ? get_page+0x9/0xf
> [224051.288528]  ? __lru_cache_add+0x18/0x47
> [224051.288530]  ? __handle_mm_fault+0x4c1/0x8ae
> [224051.288531]  __sys_sendmsg+0x40/0x5e
> [224051.288533]  ? __sys_sendmsg+0x40/0x5e
> [224051.288534]  SyS_sendmsg+0xd/0x17
> [224051.288536]  entry_SYSCALL_64_fastpath+0x13/0x94
> [224051.288537] RIP: 0033:0x7f1e45cac620
> [224051.288537] RSP: 002b:00007ffd7478b4d8 EFLAGS: 00000246 ORIG_RAX: 
> 000000000000002e
> [224051.288538] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 
> 00007f1e45cac620
> [224051.288539] RDX: 0000000000000000 RSI: 00007ffd7478b520 RDI: 
> 0000000000000003
> [224051.288540] RBP: 00007ffd7478b520 R08: 0000000000000001 R09: 
> fefefeff77686d74
> [224051.288541] R10: 00000000000005e6 R11: 0000000000000246 R12: 
> 00007ffd7478b560
> [224051.288541] R13: 00000000006724c0 R14: 00007ffd747935e0 R15: 
> 0000000000000000
> [224051.288542] Code: 00 00 48 8b 7b 10 e8 41 f2 ff ff 48 c7 43 08 00 
> 00 00 00 5b 5d c3 55 48 89 e5 41 54 53 48 83 7f 20 00 48 89 fb 4c 8b 
> 67 10 74 02 <0f> ff 0f b7 7b 44 48 6b ff 18 e8 65 f5 ff ff 48 85 c0 48 
> 89 43
> [224051.288564] ---[ end trace a9810da52af61a5e ]---
> [224051.487730] genirq: Flags mismatch irq 64. 00000000 
> (i40e-enp2s0f0-TxRx-0) vs. 00000000 (i40e-enp2s0f0-TxRx-0)
> [224051.487734] i40e 0000:02:00.0: MSIX request_irq failed, error: -16
> [224051.487735] i40e 0000:02:00.0: request_irq failed, Error -16
> [224051.854175] i40e 0000:02:00.0: PF reset failed, -15
>
>
>
>
>
> More here:
> https://bugzilla.kernel.org/show_bug.cgi?id=197325
>
>
>
>
>
> Thanks
> Pawel
>
>
in latest 4.14-rc5 net.git it is only like this:

[ 2184.928191] NETDEV WATCHDOG: enp2s0f1 (i40e): transmit queue 5 timed out
[ 2184.928207] ------------[ cut here ]------------
[ 2184.928212] WARNING: CPU: 2 PID: 19 at net/sched/sch_generic.c:320 
dev_watchdog+0xc5/0x122
[ 2184.928212] Modules linked in: bonding x86_pkg_temp_thermal ipmi_si
[ 2184.928217] CPU: 2 PID: 19 Comm: ksoftirqd/2 Not tainted 4.14.0-rc5 #5
[ 2184.928219] task: ffff88085abb1a00 task.stack: ffffc9000326c000
[ 2184.928220] RIP: 0010:dev_watchdog+0xc5/0x122
[ 2184.928221] RSP: 0018:ffffc9000326fd90 EFLAGS: 00010286
[ 2184.928222] RAX: 000000000000003c RBX: ffff8808598f5000 RCX: 
0000000000000000
[ 2184.928223] RDX: ffff88085e293501 RSI: ffff88085e28cab8 RDI: 
ffff88085e28cab8
[ 2184.928224] RBP: ffffc9000326fda0 R08: 002aca35a1b646e0 R09: 
ffff88087f013c8c
[ 2184.928224] R10: ffffc9000326fe38 R11: 000000000000005c R12: 
0000000000000005
[ 2184.928225] R13: ffffffff815f3840 R14: ffff8808598f5438 R15: 
ffff8808598f5000
[ 2184.928226] FS:  0000000000000000(0000) GS:ffff88085e280000(0000) 
knlGS:0000000000000000
[ 2184.928227] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 2184.928228] CR2: 000000000223b000 CR3: 0000000001c09002 CR4: 
00000000001606e0
[ 2184.928229] Call Trace:
[ 2184.928233]  call_timer_fn+0x56/0x119
[ 2184.928235]  run_timer_softirq+0x136/0x15b
[ 2184.928238]  ? update_next_balance+0x1a/0x2d
[ 2184.928239]  ? pick_next_task_fair+0x1c0/0x30e
[ 2184.928243]  __do_softirq+0xe6/0x23a
[ 2184.928245]  ? sort_range+0x1d/0x1d
[ 2184.928247]  run_ksoftirqd+0x15/0x2a
[ 2184.928248]  smpboot_thread_fn+0x126/0x13d
[ 2184.928250]  kthread+0xf6/0xfb
[ 2184.928252]  ? __init_completion+0x24/0x24
[ 2184.928254]  ret_from_fork+0x22/0x30
[ 2184.928255] Code: 56 50 6f 00 00 75 38 48 89 df c6 05 4a 50 6f 00 01 
e8 fe 42 fe ff 44 89 e1 48 89 de 48 c7 c7 e0 ce ac 81 48 89 c2 e8 26 d4 
a7 ff <0f> ff eb 10 41 ff c4 48 05 40 01 00 00 41 39 f4 75 9a eb 0d 48
[ 2184.928279] ---[ end trace 19de655d7b9e0810 ]---
[ 2184.928284] i40e 0000:02:00.1 enp2s0f1: tx_timeout: VSI_seid: 398, Q 
5, NTC: 0x10d, HWB: 0x10d, NTU: 0xf3, TAIL: 0x10d, INT: 0x1
[ 2184.928285] i40e 0000:02:00.1 enp2s0f1: tx_timeout recovery level 1, 
hung_queue 5

Less debug

tso
gro
are on
