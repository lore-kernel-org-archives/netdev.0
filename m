From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/2] genl: Fix genl dumpit() locking.
Date: Mon, 26 Aug 2013 08:06:37 +0200
Message-ID: <1377497197.13247.1.camel@jlt4.sipsolutions.net>
References: <1377143882-20717-1-git-send-email-pshelar@nicira.com>
	 <1377156980.14110.16.camel@jlt4.sipsolutions.net>
	 <CALnjE+qgZ_UZ4GdiZ4UCzfTLn-OveoHtE28uQZokz2kPD4srXQ@mail.gmail.com>
	 <1377193906.14110.27.camel@jlt4.sipsolutions.net>
	 <CALnjE+rEOMmyFQ0Nx3-O-Cvu8yePVBg7x8vgpGUOAAnYv3KG4Q@mail.gmail.com>
	 <1377195534.14110.29.camel@jlt4.sipsolutions.net>
	 <CALnjE+osiw-uPdf8JEX=jG+zwaoypoSQ_A+N-WiVUkxxT63y+g@mail.gmail.com>
	 <1377242982.14021.8.camel@jlt4.sipsolutions.net>
	 <1377251485.14021.17.camel@jlt4.sipsolutions.net>
	 <CALnjE+qn8THcPABZojWoE3OW2Y2TKZGSjB24ZWLC5AGM5yKm9w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:49962 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755856Ab3HZGGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Aug 2013 02:06:47 -0400
In-Reply-To: <CALnjE+qn8THcPABZojWoE3OW2Y2TKZGSjB24ZWLC5AGM5yKm9w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-23 at 13:52 -0700, Pravin Shelar wrote:

> > I'm still missing something. Kernel 3.4 had cb_mutex assign to the
> > genl_mutex, but we saw the original crash there, apparently dumpit
> > *wasn't* (always) locked with it?

> Can you point me to original crash on 3.4?

Sure, below.

johannes


[1389854.965295] cfg80211: Calling CRDA to update world regulatory domain
[1389854.973801] Intel(R) Wireless WiFi driver for Linux, in-tree:d
[1389854.973804] Copyright(c) 2003-2013 Intel Corporation
[1389854.982900] cfg80211: World regulatory domain updated:
[1389854.982908] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[1389854.982913] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[1389854.982919] cfg80211:   (2457000 KHz - 2482000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[1389854.982923] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[1389854.982928] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[1389854.982932] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[1389857.247719] BUG: unable to handle kernel paging request at f8467360
[1389857.249716] IP: [<c14c56bb>] ctrl_dumpfamily+0x6b/0xe0
[1389857.251798] *pde = 2ffd7067 *pte = 00000000
[1389857.253903] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[1389857.256002] Modules linked in: cfg80211(O) ...
[1389857.265729]
[1389857.268159] Pid: 20081, comm: wpa_supplicant Tainted: G        W  O 3.4.47-dev #1 Dell Inc. Latitude E6430/0CPWYR
[1389857.270726] EIP: 0060:[<c14c56bb>] EFLAGS: 00210297 CPU: 2
[1389857.273291] EIP is at ctrl_dumpfamily+0x6b/0xe0
[1389857.275829] EAX: f8467378 EBX: f8467340 ECX: 00000000 EDX: ec1610c4
[1389857.278365] ESI: 00000001 EDI: c2077cc0 EBP: c46c3c00 ESP: c46c3bd4
[1389857.280921]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[1389857.283508] CR0: 80050033 CR2: f8467360 CR3: 26e54000 CR4: 001407d0
[1389857.286130] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[1389857.288770] DR6: ffff0ff0 DR7: 00000400
[1389857.291363] Process wpa_supplicant (pid: 20081, ti=c46c2000 task=c44640b0 task.ti=c46c2000)
[1389857.294044] Stack:
[1389857.296668]  00000002 caef8000 00000001 caef8000 00000000 e6ccc3c0 c1861f00 00000000
[1389857.299377]  e73cd910 e6ccc3c0 caef8000 c46c3c28 c14c20bc 000000d0 00200246 00200246
[1389857.302077]  e73cd910 e6ccc3c0 e73cd910 e6ccc3c0 00000000 c46c3c48 c14c3450 d0757b00
[1389857.304794] Call Trace:
[1389857.307443]  [<c14c20bc>] netlink_dump+0x5c/0x200
[1389857.310110]  [<c14c3450>] __netlink_dump_start+0x140/0x160
[1389857.312779]  [<c14c5650>] ? ctrl_fill_info+0x370/0x370
[1389857.315442]  [<c14c5172>] genl_rcv_msg+0x102/0x270
[1389857.318096]  [<c14c5034>] ? genl_lock+0x14/0x20
[1389857.320765]  [<c15acdb2>] ? mutex_lock_nested+0x222/0x2f0
[1389857.323424]  [<c15acdc2>] ? mutex_lock_nested+0x232/0x2f0
[1389857.326026]  [<c14c5034>] ? genl_lock+0x14/0x20
[1389857.328621]  [<c14c5650>] ? ctrl_fill_info+0x370/0x370
[1389857.331224]  [<c14c5070>] ? genl_rcv+0x30/0x30
[1389857.333822]  [<c14c4b5e>] netlink_rcv_skb+0x8e/0xb0
[1389857.336420]  [<c14c505c>] genl_rcv+0x1c/0x30
[1389857.339014]  [<c14c456b>] netlink_unicast+0x17b/0x1c0
[1389857.341617]  [<c14c47d4>] netlink_sendmsg+0x224/0x370
[1389857.344215]  [<c1485adf>] sock_sendmsg+0xff/0x120
[1389857.346812]  [<c112ad04>] ? might_fault+0x54/0xb0
[1389857.349403]  [<c112ad4e>] ? might_fault+0x9e/0xb0
[1389857.351982]  [<c12de3c2>] ? _copy_from_user+0x42/0x60
[1389857.354558]  [<c14926e4>] ? verify_iovec+0x44/0xb0
[1389857.357086]  [<c1486b0a>] __sys_sendmsg+0x24a/0x260
[1389857.359563]  [<c12e39de>] ? do_raw_spin_unlock+0x4e/0x90
[1389857.362025]  [<c110af35>] ? unlock_page+0x45/0x50
[1389857.364443]  [<c112aff8>] ? __do_fault+0x298/0x450
[1389857.366858]  [<c112db01>] ? handle_pte_fault+0xe1/0x7d0
[1389857.369178]  [<c15b3b8b>] ? do_page_fault+0xcb/0x4b0
[1389857.371403]  [<c1150b45>] ? fget_light+0x1d5/0x470
[1389857.373618]  [<c1487fdb>] sys_sendmsg+0x3b/0x60
[1389857.375827]  [<c1488683>] sys_socketcall+0x283/0x2e0
[1389857.377946]  [<c15b072d>] ? restore_all+0xf/0xf
[1389857.379981]  [<c15b3ac0>] ? vmalloc_fault+0x114/0x114
[1389857.381927]  [<c12ddea8>] ? trace_hardirqs_on_thunk+0xc/0x10
[1389857.383796]  [<c15b7c1f>] sysenter_do_call+0x12/0x38
[1389857.385644] Code: 8d 3c c5 c0 7c 07 c2 8b 04 c5 c0 7c 07 c2 39 c7 8d 58 c8 75 16 eb 71 90 81 7d ec 00 1f 86 c1 74 10 8b 43 38 39 c7 8d 58 c8 74 5d <80> 7b 20 00 74 e7 83 c6 01 3b 75 f0 7c e8 8b 55 e8 8b 42 04 8b
[1389857.389897] EIP: [<c14c56bb>] ctrl_dumpfamily+0x6b/0xe0 SS:ESP 0068:c46c3bd4
[1389857.391949] CR2: 00000000f8467360
[1389857.496970] ---[ end trace 52efe903d218886a ]---
[1389857.496977] BUG: sleeping function called from invalid context at kernel/rwsem.c:20
[1389857.496982] in_atomic(): 0, irqs_disabled(): 1, pid: 20081, name: wpa_supplicant
[1389857.496986] INFO: lockdep is turned off.
[1389857.496989] irq event stamp: 0
[1389857.496992] hardirqs last  enabled at (0): [<  (null)>]   (null)
[1389857.496997] hardirqs last disabled at (0): [<c1031aa8>] copy_process+0x468/0x1280
[1389857.497006] softirqs last  enabled at (0): [<c1031aa8>] copy_process+0x468/0x1280
[1389857.497012] softirqs last disabled at (0): [<  (null)>]   (null)
[1389857.497019] Pid: 20081, comm: wpa_supplicant Tainted: G      D W  O 3.4.47-dev #1
[1389857.497022] Call Trace:
[1389857.497031]  [<c1067322>] __might_sleep+0x162/0x200
[1389857.497038]  [<c15add80>] down_read+0x20/0x8b
[1389857.497046]  [<c1049f5e>] exit_signals+0x1e/0x110
[1389857.497053]  [<c10381b7>] do_exit+0x97/0x9b0
[1389857.497059]  [<c1035753>] ? kmsg_dump+0x193/0x270
[1389857.497065]  [<c1035630>] ? kmsg_dump+0x70/0x270
[1389857.497073]  [<c15a60e2>] ? printk+0x2d/0x2f
[1389857.497079]  [<c15b1646>] oops_end+0x96/0xd0
[1389857.497086]  [<c15a5aac>] no_context+0x18c/0x194
[1389857.497098]  [<c15a5bf8>] __bad_area_nosemaphore+0x144/0x14c
[1389857.497106]  [<c10960bb>] ? trace_hardirqs_on+0xb/0x10
[1389857.497114]  [<c148c7cf>] ? sock_rmalloc+0x3f/0x90
[1389857.497122]  [<c15b3ac0>] ? vmalloc_fault+0x114/0x114
[1389857.497128]  [<c15a5c17>] bad_area_nosemaphore+0x17/0x19
[1389857.497135]  [<c15b3d9f>] do_page_fault+0x2df/0x4b0
[1389857.497141]  [<c14c2049>] ? __nlmsg_put+0x59/0x70
[1389857.497149]  [<c12ec362>] ? __nla_reserve+0x42/0x60
[1389857.497154]  [<c15b0e54>] ? error_code+0x68/0x74
[1389857.497160]  [<c15b3ac0>] ? vmalloc_fault+0x114/0x114
[1389857.497167]  [<c1093adf>] ? trace_hardirqs_off_caller+0x1f/0x130
[1389857.497176]  [<c15b3ac0>] ? vmalloc_fault+0x114/0x114
[1389857.497181]  [<c15b0e58>] error_code+0x6c/0x74
[1389857.497191]  [<c14c56bb>] ? ctrl_dumpfamily+0x6b/0xe0
[1389857.497197]  [<c14c20bc>] netlink_dump+0x5c/0x200
[1389857.497204]  [<c14c3450>] __netlink_dump_start+0x140/0x160
[1389857.497210]  [<c14c5650>] ? ctrl_fill_info+0x370/0x370
[1389857.497216]  [<c14c5172>] genl_rcv_msg+0x102/0x270
[1389857.497222]  [<c14c5034>] ? genl_lock+0x14/0x20
[1389857.497229]  [<c15acdb2>] ? mutex_lock_nested+0x222/0x2f0
[1389857.497236]  [<c15acdc2>] ? mutex_lock_nested+0x232/0x2f0
[1389857.497242]  [<c14c5034>] ? genl_lock+0x14/0x20
[1389857.497248]  [<c14c5650>] ? ctrl_fill_info+0x370/0x370
[1389857.497254]  [<c14c5070>] ? genl_rcv+0x30/0x30
[1389857.497260]  [<c14c4b5e>] netlink_rcv_skb+0x8e/0xb0
[1389857.497267]  [<c14c505c>] genl_rcv+0x1c/0x30
[1389857.497273]  [<c14c456b>] netlink_unicast+0x17b/0x1c0
[1389857.497279]  [<c14c47d4>] netlink_sendmsg+0x224/0x370
[1389857.497286]  [<c1485adf>] sock_sendmsg+0xff/0x120
[1389857.497294]  [<c112ad04>] ? might_fault+0x54/0xb0
[1389857.497301]  [<c112ad4e>] ? might_fault+0x9e/0xb0
[1389857.497308]  [<c12de3c2>] ? _copy_from_user+0x42/0x60
[1389857.497313]  [<c14926e4>] ? verify_iovec+0x44/0xb0
[1389857.497320]  [<c1486b0a>] __sys_sendmsg+0x24a/0x260
[1389857.497326]  [<c12e39de>] ? do_raw_spin_unlock+0x4e/0x90
[1389857.497333]  [<c110af35>] ? unlock_page+0x45/0x50
[1389857.497340]  [<c112aff8>] ? __do_fault+0x298/0x450
[1389857.497346]  [<c112db01>] ? handle_pte_fault+0xe1/0x7d0
[1389857.497353]  [<c15b3b8b>] ? do_page_fault+0xcb/0x4b0
[1389857.497359]  [<c1150b45>] ? fget_light+0x1d5/0x470
[1389857.497366]  [<c1487fdb>] sys_sendmsg+0x3b/0x60
[1389857.497372]  [<c1488683>] sys_socketcall+0x283/0x2e0
[1389857.497378]  [<c15b072d>] ? restore_all+0xf/0xf
[1389857.497384]  [<c15b3ac0>] ? vmalloc_fault+0x114/0x114
[1389857.497391]  [<c12ddea8>] ? trace_hardirqs_on_thunk+0xc/0x10
[1389857.497397]  [<c15b7c1f>] sysenter_do_call+0x12/0x38
