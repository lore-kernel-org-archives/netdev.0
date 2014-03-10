From: Jakub Kicinski <moorray3@wp.pl>
Subject: net-next: NULL pointer dereference on adding a net namespace and a
 system freeze
Date: Mon, 10 Mar 2014 01:44:52 +0100
Message-ID: <20140310014452.144b0491@north>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:25365 "EHLO mx4.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751987AbaCJAvh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Mar 2014 20:51:37 -0400
Received: from 89-69-164-220.dynamic.chello.pl (HELO north) (moorray3@[89.69.164.220])
          (envelope-sender <moorray3@wp.pl>)
          by smtp.wp.pl (WP-SMTPD) with AES128-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 10 Mar 2014 01:44:52 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Running Fedora 20 with net-next I get the following warning when
libvirt or rtkit comes up:

[  272.143488] kmem_cache_sanity_check (flow_cache): Cache name already exists.
[  272.143586] CPU: 0 PID: 975 Comm: libvirtd Not tainted 3.14.0-rc5+ #1
[  272.143589] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  272.143591]  0000000000000000 ffff88003ceadba0 ffffffff8167baf0 ffff88003db3d300
[  272.143595]  ffff88003ceadc18 ffffffff8117795b ffff88003ceadbc8 ffff88003b235158
[  272.143599]  0000000000000000 0000000000040000 0000000000000068 0000000000000000
[  272.143602] Call Trace:
[  272.143610]  [<ffffffff8167baf0>] dump_stack+0x4d/0x66
[  272.143615]  [<ffffffff8117795b>] kmem_cache_create_memcg+0x12b/0x420
[  272.143618]  [<ffffffff81177c7b>] kmem_cache_create+0x2b/0x30
[  272.143622]  [<ffffffff815c4a0e>] flow_cache_init+0x2e/0x2b0
[  272.143626]  [<ffffffff8164b017>] xfrm_net_init+0x227/0x360
[  272.143629]  [<ffffffff8164af41>] ? xfrm_net_init+0x151/0x360
[  272.143632]  [<ffffffff815a5921>] ops_init+0x41/0x150
[  272.143635]  [<ffffffff815a5aa3>] setup_net+0x73/0x110
[  272.143638]  [<ffffffff815a5fe2>] copy_net_ns+0x72/0x100
[  272.143642]  [<ffffffff810943f9>] create_new_namespaces+0xf9/0x190
[  272.143645]  [<ffffffff81094560>] copy_namespaces+0xd0/0xf0
[  272.143648]  [<ffffffff81094495>] ? copy_namespaces+0x5/0xf0
[  272.143651]  [<ffffffff81069be0>] copy_process.part.31+0x950/0x1b30
[  272.143655]  [<ffffffff8106af95>] do_fork+0xd5/0x370
[  272.143658]  [<ffffffff811c1b2d>] ? __fput+0x17d/0x240
[  272.143662]  [<ffffffff8110440c>] ? __audit_syscall_entry+0x9c/0xf0
[  272.143665]  [<ffffffff8106b2b6>] SyS_clone+0x16/0x20
[  272.143669]  [<ffffffff8168cf19>] stub_clone+0x69/0x90
[  272.143673]  [<ffffffff8168cb69>] ? system_call_fastpath+0x16/0x1b


When I try to add a netns with 
# ip netns add abcd
I it dies with:

[  887.482891] kmem_cache_sanity_check (flow_cache): Cache name already exists.
[  887.483001] CPU: 0 PID: 1135 Comm: ip Not tainted 3.14.0-rc5+ #1
[  887.483003] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  887.483036]  0000000000000000 ffff88003bc71d20 ffffffff8167baf0 ffff88003db3d300
[  887.483041]  ffff88003bc71d98 ffffffff8117795b ffff88003bc71d48 ffff88003d88e218
[  887.483044]  0000000000000000 0000000000040000 0000000000000068 0000000000000000
[  887.483048] Call Trace:
[  887.483056]  [<ffffffff8167baf0>] dump_stack+0x4d/0x66
[  887.483060]  [<ffffffff8117795b>] kmem_cache_create_memcg+0x12b/0x420
[  887.483063]  [<ffffffff81177c7b>] kmem_cache_create+0x2b/0x30
[  887.483068]  [<ffffffff815c4a0e>] flow_cache_init+0x2e/0x2b0
[  887.483072]  [<ffffffff8164b017>] xfrm_net_init+0x227/0x360
[  887.483075]  [<ffffffff8164af41>] ? xfrm_net_init+0x151/0x360
[  887.483078]  [<ffffffff815a5921>] ops_init+0x41/0x150
[  887.483081]  [<ffffffff815a5aa3>] setup_net+0x73/0x110
[  887.483084]  [<ffffffff815a5fe2>] copy_net_ns+0x72/0x100
[  887.483088]  [<ffffffff810943f9>] create_new_namespaces+0xf9/0x190
[  887.483092]  [<ffffffff81094671>] unshare_nsproxy_namespaces+0x61/0xa0
[  887.483095]  [<ffffffff8106b419>] SyS_unshare+0x159/0x270
[  887.483099]  [<ffffffff8168cb69>] system_call_fastpath+0x16/0x1b
[  887.484459] BUG: unable to handle kernel NULL pointer dereference at 0000000000000018
[  887.484546] IP: [<ffffffff81094840>] raw_notifier_chain_register+0x20/0x40
[  887.484627] PGD 3c183067 PUD 3b1ec067 PMD 0 
[  887.484703] Oops: 0000 [#1] SMP 
[  887.484775] Modules linked in: cfg80211 rfkill xt_conntrack iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw ppdev serio_raw virtio_console virtio_balloon i2c_piix4 floppy parport_pc parport nfsd auth_rpcgss nfs_acl lockd sunrpc virtio_blk virtio_net qxl drm_kms_helper ttm virtio_pci virtio_ring virtio
[  887.485019] CPU: 0 PID: 1135 Comm: ip Not tainted 3.14.0-rc5+ #1
[  887.485019] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  887.485019] task: ffff88003b234300 ti: ffff88003bc70000 task.ti: ffff88003bc70000
[  887.485019] RIP: 0010:[<ffffffff81094840>]  [<ffffffff81094840>] raw_notifier_chain_register+0x20/0x40
[  887.485019] RSP: 0018:ffff88003bc71d98  EFLAGS: 00010202
[  887.485019] RAX: 0000000000000008 RBX: ffff88003d88e248 RCX: 0000000000000004
[  887.485019] RDX: 0000000000000000 RSI: ffff88003d88e248 RDI: ffff88003b235190
[  887.485019] RBP: ffff88003bc71d98 R08: 0000000000000000 R09: 0000000000000000
[  887.485019] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88003d88e268
[  887.485019] R13: ffff88003d88e238 R14: ffff88003d88d550 R15: 0000000000000005
[  887.485019] FS:  00007f7de7389740(0000) GS:ffff88003fc00000(0000) knlGS:0000000000000000
[  887.485019] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  887.485019] CR2: 0000000000000018 CR3: 000000003d1de000 CR4: 00000000000006f0
[  887.485019] Stack:
[  887.485019]  ffff88003bc71db0 ffffffff81673f4a ffff88003d88d3c0 ffff88003bc71de0
[  887.485019]  ffffffff815c4bbe ffff88003d88d3c0 0000000000000000 ffff88003d88d420
[  887.485019]  ffff88003d88d550 ffff88003bc71e28 ffffffff8164b017 ffffffff8164af41
[  887.485019] Call Trace:
[  887.485019]  [<ffffffff81673f4a>] register_cpu_notifier+0x2a/0x40
[  887.485019]  [<ffffffff815c4bbe>] flow_cache_init+0x1de/0x2b0
[  887.485019]  [<ffffffff8164b017>] xfrm_net_init+0x227/0x360
[  887.485019]  [<ffffffff8164af41>] ? xfrm_net_init+0x151/0x360
[  887.485019]  [<ffffffff815a5921>] ops_init+0x41/0x150
[  887.485019]  [<ffffffff815a5aa3>] setup_net+0x73/0x110
[  887.485019]  [<ffffffff815a5fe2>] copy_net_ns+0x72/0x100
[  887.485019]  [<ffffffff810943f9>] create_new_namespaces+0xf9/0x190
[  887.485019]  [<ffffffff81094671>] unshare_nsproxy_namespaces+0x61/0xa0
[  887.485019]  [<ffffffff8106b419>] SyS_unshare+0x159/0x270
[  887.485019]  [<ffffffff8168cb69>] system_call_fastpath+0x16/0x1b
[  887.485019] Code: 4c 63 f8 e9 7b ff ff ff 0f 1f 00 66 66 66 66 90 55 48 8b 07 48 89 e5 48 85 c0 74 21 8b 56 10 3b 50 10 7e 0c eb 17 0f 1f 44 00 00 <39> 50 10 7c 0d 48 8d 78 08 48 8b 40 08 48 85 c0 75 ee 48 89 46 
[  887.485019] RIP  [<ffffffff81094840>] raw_notifier_chain_register+0x20/0x40
[  887.485019]  RSP <ffff88003bc71d98>
[  887.485019] CR2: 0000000000000018


If I let the machine run for a few minutes (without adding netns, just
with libvirtd running), I get the following:

[ 1173.850646] WARNING: CPU: 1 PID: 0 at /home/kuba/Development/Linux/net-next/lib/list_debug.c:33 __list_add+0xac/0xc0()
[ 1173.850892] list_add corruption. prev->next should be next (ffffffff81e8e648), but was 0000000000010000. (prev=ffff88003b2351a8).
[ 1173.851333] Modules linked in: cfg80211 rfkill xt_conntrack iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw ppdev serio_raw virtio_console virtio_balloon i2c_piix4 floppy parport_pc parport nfsd auth_rpcgss nfs_acl lockd sunrpc virtio_blk virtio_net qxl drm_kms_helper ttm virtio_pci virtio_ring virtio
[ 1173.851576] CPU: 1 PID: 0 Comm: swapper/1 Tainted: G      D      3.14.0-rc5+ #1
[ 1173.851576] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[ 1173.851576]  0000000000000009 ffff88003fd03928 ffffffff8167baf0 ffff88003fd03970
[ 1173.851576]  ffff88003fd03960 ffffffff8106bd5d ffff88003bee03e0 ffffffff81e8e648
[ 1173.851576]  ffff88003b2351a8 ffffffff81e8d180 000000010011e95a ffff88003fd039c0
[ 1173.851576] Call Trace:
[ 1173.851576]  <IRQ>  [<ffffffff8167baf0>] dump_stack+0x4d/0x66
[ 1173.851576]  [<ffffffff8106bd5d>] warn_slowpath_common+0x7d/0xa0
[ 1173.851576]  [<ffffffff8106bdcc>] warn_slowpath_fmt+0x4c/0x50
[ 1173.851576]  [<ffffffff813217ac>] __list_add+0xac/0xc0
[ 1173.851576]  [<ffffffff810778b3>] __internal_add_timer+0x113/0x130
[ 1173.851576]  [<ffffffff81077ac7>] internal_add_timer+0x17/0x40
[ 1173.851576]  [<ffffffff8107a1fd>] mod_timer_pending+0xfd/0x190
[ 1173.851576]  [<ffffffffa0171748>] __nf_ct_refresh_acct+0xb8/0xd0 [nf_conntrack]
[ 1173.851576]  [<ffffffffa01793a0>] tcp_packet+0x6c0/0x14c0 [nf_conntrack]
[ 1173.851576]  [<ffffffffa01729bd>] ? __nf_conntrack_find_get+0x2fd/0x350 [nf_conntrack]
[ 1173.851576]  [<ffffffffa01726c5>] ? __nf_conntrack_find_get+0x5/0x350 [nf_conntrack]
[ 1173.851576]  [<ffffffffa017393c>] nf_conntrack_in+0x34c/0xa00 [nf_conntrack]
[ 1173.851576]  [<ffffffff815ea050>] ? ip_local_deliver_finish+0x330/0x330
[ 1173.851576]  [<ffffffffa019e2d2>] ipv4_conntrack_in+0x22/0x30 [nf_conntrack_ipv4]
[ 1173.851576]  [<ffffffff815e085a>] nf_iterate+0x9a/0xb0
[ 1173.851576]  [<ffffffff815ea050>] ? ip_local_deliver_finish+0x330/0x330
[ 1173.851576]  [<ffffffff815e0914>] nf_hook_slow+0xa4/0x170
[ 1173.851576]  [<ffffffff815ea050>] ? ip_local_deliver_finish+0x330/0x330
[ 1173.851576]  [<ffffffff815eab48>] ip_rcv+0x2f8/0x3d0
[ 1173.851576]  [<ffffffff815ade16>] __netif_receive_skb_core+0x6c6/0x8b0
[ 1173.851576]  [<ffffffff815ad852>] ? __netif_receive_skb_core+0x102/0x8b0
[ 1173.851576]  [<ffffffff815ae018>] __netif_receive_skb+0x18/0x60
[ 1173.851576]  [<ffffffff815ae093>] netif_receive_skb_internal+0x33/0x120
[ 1173.851576]  [<ffffffff815ae19c>] netif_receive_skb+0x1c/0x70
[ 1173.851576]  [<ffffffffa00166ea>] virtnet_poll+0x4ea/0x840 [virtio_net]
[ 1173.851576]  [<ffffffff815ae56a>] net_rx_action+0x15a/0x270
[ 1173.851576]  [<ffffffff81071345>] __do_softirq+0xf5/0x2b0
[ 1173.851576]  [<ffffffff8107177d>] irq_exit+0xbd/0xd0
[ 1173.851576]  [<ffffffff8168ea48>] do_IRQ+0x58/0xf0
[ 1173.851576]  [<ffffffff81683fed>] common_interrupt+0x6d/0x6d
[ 1173.851576]  <EOI>  [<ffffffff81687dd5>] ? __atomic_notifier_call_chain+0x5/0xa0
[ 1173.851576]  [<ffffffff8103b3f6>] ? native_safe_halt+0x6/0x10
[ 1173.851576]  [<ffffffff8100b8cf>] default_idle+0x1f/0xe0
[ 1173.851576]  [<ffffffff8100c206>] arch_cpu_idle+0x26/0x30
[ 1173.851576]  [<ffffffff810c8d5e>] cpu_startup_entry+0x9e/0x260
[ 1173.851576]  [<ffffffff8102ec04>] start_secondary+0x1d4/0x280

Or a similar warning related to adding a timer to the list (not
necessarily network related timer).  After a few seconds/minutes the
machine freezes (I guess it happens when the broken timer fires).

It didn't happen on wireless-testing from a week ago, but I didn't have
time today to bisect :/

	-- kuba
