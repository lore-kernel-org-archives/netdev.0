From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [linux-next-20130607] rcu warning, sleep in atomic, unchecked dma alloc, bad address access
Date: Mon, 17 Jun 2013 00:39:49 +0900
Message-ID: <201306170039.GEG18281.MQFtOOSJFOLHVF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I get below failures using 3.10.0-rc4-next-20130607.

Let me know whether these are already reported/bisected or not.
Trace 3 is known since linux-next-20121127, and still waiting for patches from
Don Fry.

Config is at http://I-love.SAKURA.ne.jp/tmp/config-3.10-rc4-next-20130607 .
Full log is at http://I-love.SAKURA.ne.jp/tmp/dmesg-3.10-rc4-next-20120607.txt .

Trace 5 is a trace with TOMOYO 1.8 patch applied (though TOMOYO 1.8 should be
unrelated).

Regards.

---------- Trace 1 start ----------

[   52.252768] ===============================
[   52.253874] [ INFO: suspicious RCU usage. ]
[   52.255202] 3.10.0-rc4-next-20130607 #6 Not tainted
[   52.255302] -------------------------------
[   52.257909] include/linux/rcupdate.h:471 Illegal context switch in RCU read-side critical section!
[   52.265938] 
[   52.265938] other info that might help us debug this:
[   52.265938] 
[   52.268165] 
[   52.268165] rcu_scheduler_active = 1, debug_locks = 1
[   52.271240] 2 locks held by udevd/1909:
[   52.272229]  #0:  (&ids->rw_mutex){+.+.+.}, at: [<c038bda5>] ipcget+0x45/0x70
[   52.275183]  #1:  (rcu_read_lock){.+.+..}, at: [<c038d850>] rcu_read_lock+0x0/0x80
[   52.277663] 
[   52.277663] stack backtrace:
[   52.277955] CPU: 0 PID: 1909 Comm: udevd Not tainted 3.10.0-rc4-next-20130607 #6
[   52.281381] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 08/15/2008
[   52.285386]  00000001 da601e94 c06765af 00000001 da601ebc c0199376 c07f561b c07f7108
[   52.287848]  00000001 00000001 c07e6614 00000000 000001a8 c081d2f7 da601ee4 c0176011
[   52.290814]  00000246 00000002 00000001 00000000 00000000 000000d0 de40ff0c ffffffe4
[   52.293472] Call Trace:
[   52.294297]  [<c06765af>] dump_stack+0x4c/0x6d
[   52.301317]  [<c0199376>] lockdep_rcu_suspicious+0xc6/0x100
[   52.302814]  [<c0176011>] __might_sleep+0xb1/0x200
[   52.303092]  [<c0408cc1>] idr_preload+0xa1/0xd0
[   52.305500]  [<c038adc2>] ipc_addid+0x52/0x190
[   52.306692]  [<c038d8ad>] ? rcu_read_lock+0x5d/0x80
[   52.308119]  [<c038e09a>] newary+0xba/0x1a0
[   52.310552]  [<c038bdae>] ipcget+0x4e/0x70
[   52.311643]  [<c019d512>] ? __lock_release+0x72/0x1b0
[   52.313194]  [<c038dfbf>] SyS_semget+0x6f/0x80
[   52.314338]  [<c038dfe0>] ? sem_security+0x10/0x10
[   52.315562]  [<c038dfd0>] ? SyS_semget+0x80/0x80
[   52.316920]  [<c038d670>] ? SyS_msgctl+0xb0/0xb0
[   52.318119]  [<c03923a3>] SyS_ipc+0xa3/0x250
[   52.318560]  [<c0235446>] ? vm_munmap+0x46/0x60
[   52.320684]  [<c067b51a>] sysenter_do_call+0x12/0x32

---------- Trace 1 end ----------

---------- Trace 2 start ----------

[   52.322037] BUG: sleeping function called from invalid context at lib/idr.c:424
[   52.324064] in_atomic(): 1, irqs_disabled(): 0, pid: 1909, name: udevd
[   52.325711] 2 locks held by udevd/1909:
[   52.326703]  #0:  (&ids->rw_mutex){+.+.+.}, at: [<c038bda5>] ipcget+0x45/0x70
[   52.334105]  #1:  (rcu_read_lock){.+.+..}, at: [<c038d850>] rcu_read_lock+0x0/0x80
[   52.337009] CPU: 0 PID: 1909 Comm: udevd Not tainted 3.10.0-rc4-next-20130607 #6
[   52.338954] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 08/15/2008
[   52.341290]  000001a8 da601ebc c06765af daae2920 da601ee4 c01760bd c07e670c 00000001
[   52.345513]  00000000 00000775 daae2bd8 000000d0 de40ff0c ffffffe4 da601ef0 c0408cc1
[   52.348492]  c08e2b84 da601f10 c038adc2 da601f10 c038d8ad ffffffff 00000001 c08e2b80
[   52.350955] Call Trace:
[   52.352001]  [<c06765af>] dump_stack+0x4c/0x6d
[   52.352001]  [<c01760bd>] __might_sleep+0x15d/0x200
[   52.352001]  [<c0408cc1>] idr_preload+0xa1/0xd0
[   52.352001]  [<c038adc2>] ipc_addid+0x52/0x190
[   52.352001]  [<c038d8ad>] ? rcu_read_lock+0x5d/0x80
[   52.352001]  [<c038e09a>] newary+0xba/0x1a0
[   52.360934]  [<c038bdae>] ipcget+0x4e/0x70
[   52.362111]  [<c019d512>] ? __lock_release+0x72/0x1b0
[   52.366977]  [<c038dfbf>] SyS_semget+0x6f/0x80
[   52.367216]  [<c038dfe0>] ? sem_security+0x10/0x10
[   52.367400]  [<c038dfd0>] ? SyS_semget+0x80/0x80
[   52.372241]  [<c038d670>] ? SyS_msgctl+0xb0/0xb0
[   52.376344]  [<c03923a3>] SyS_ipc+0xa3/0x250
[   52.377477]  [<c0235446>] ? vm_munmap+0x46/0x60
[   52.378647]  [<c067b51a>] sysenter_do_call+0x12/0x32

[   70.993965] ------------[ cut here ]------------

---------- Trace 2 end ----------

---------- Trace 3 start ----------

[   70.995522] WARNING: CPU: 1 PID: 13 at lib/dma-debug.c:937 check_unmap+0x4a6/0x8f0()
[   70.996073] pcnet32 0000:02:01.0: DMA-API: device driver failed to check map error[device address=0x000000001a0c0802] [size=90 bytes] [mapped as single]
[   70.996073] Modules linked in: ipv6 binfmt_misc
[   70.996073] CPU: 1 PID: 13 Comm: ksoftirqd/1 Not tainted 3.10.0-rc4-next-20130607 #6
[   70.996073] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 08/15/2008
[   70.996073]  000003a9 dedf1cec c06765af c081ee31 dedf1d1c c013c6ef c08208b8 dedf1d48
[   70.996073]  0000000d c081ee31 000003a9 c042fcc6 c042fcc6 de57a780 dbb76840 c1191320
[   70.996073]  dedf1d34 c013c7b3 00000009 dedf1d2c c08208b8 dedf1d48 dedf1da4 c042fcc6
[   70.996073] Call Trace:
[   70.996073]  [<c06765af>] dump_stack+0x4c/0x6d
[   70.996073]  [<c013c6ef>] warn_slowpath_common+0x7f/0xa0
[   70.996073]  [<c042fcc6>] ? check_unmap+0x4a6/0x8f0
[   70.996073]  [<c042fcc6>] ? check_unmap+0x4a6/0x8f0
[   70.996073]  [<c013c7b3>] warn_slowpath_fmt+0x33/0x40
[   70.996073]  [<c042fcc6>] check_unmap+0x4a6/0x8f0
[   70.996073]  [<c043030b>] debug_dma_unmap_page+0x5b/0x80
[   70.996073]  [<c0519816>] pcnet32_tx+0x146/0x2f0
[   70.996073]  [<c051a4e3>] ? pcnet32_poll+0xb3/0x190
[   70.996073]  [<c051a4ee>] pcnet32_poll+0xbe/0x190
[   70.996073]  [<c05a0908>] net_rx_action+0xa8/0x240
[   70.996073]  [<c0145d2e>] __do_softirq+0xbe/0x330
[   70.996073]  [<c0145fb1>] ? run_ksoftirqd+0x11/0x60
[   70.996073]  [<c0145fcd>] run_ksoftirqd+0x2d/0x60
[   70.996073]  [<c01722b5>] smpboot_thread_fn+0x125/0x1d0
[   70.996073]  [<c01688ef>] kthread+0xaf/0xc0
[   70.996073]  [<c0172190>] ? smpboot_register_percpu_thread+0xd0/0xd0
[   70.996073]  [<c0678c15>] ? wait_for_completion+0xa5/0xe0
[   70.996073]  [<c067b497>] ret_from_kernel_thread+0x1b/0x28
[   70.996073]  [<c0168840>] ? __init_kthread_worker+0x60/0x60
[   70.996073] ---[ end trace 071ca6b1ffc485e6 ]---
[   70.996073] Mapped at:
[   70.996073]  [<c0430618>] debug_dma_map_page+0x68/0x140
[   70.996073]  [<c051b510>] pcnet32_start_xmit+0x130/0x220
[   70.996073]  [<c059faa6>] dev_hard_start_xmit+0x2c6/0x5b0
[   70.996073]  [<c05ba661>] sch_direct_xmit+0xa1/0x240
[   70.996073]  [<c05a0c9e>] dev_queue_xmit+0x1fe/0x760

---------- Trace 3 end ----------

---------- Trace 4 start ----------

[  265.714616] BUG: unable to handle kernel paging request at db8e18b4
[  265.716043] IP: [<c05f8a85>] arp_solicit+0xe5/0x3b0
[  265.716043] *pde = 1f7f5067 *pte = 1b8e1060 
[  265.716043] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[  265.720128] Modules linked in: ipv6 binfmt_misc
[  265.720128] CPU: 0 PID: 4520 Comm: sshd Tainted: G        W    3.10.0-rc4-next-20130607 #6
[  265.720128] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 08/15/2008
[  265.720128] task: dba3e660 ti: dbf2c000 task.ti: dbf2c000
[  265.720128] EIP: 0060:[<c05f8a85>] EFLAGS: 00210282 CPU: 0
[  265.720128] EIP is at arp_solicit+0xe5/0x3b0
[  265.720128] EAX: db8d6800 EBX: d755ee00 ECX: da694740 EDX: 0000b0a8
[  265.720128] ESI: da556e00 EDI: deede800 EBP: dbf2dba4 ESP: dbf2db54
[  265.720128]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[  265.720128] CR0: 80050033 CR2: db8e18b4 CR3: 16419000 CR4: 000006d0
[  265.720128] DR0: c11a5eb8 DR1: 00000000 DR2: 00000000 DR3: 00000000
[  265.720128] DR6: ffff4ff0 DR7: 00000600
[  265.720128] Stack:
[  265.720128]  00000002 00000001 00000000 c05f89a0 c058efd2 00000001 0400a8c0 00000003
[  265.720128]  da694740 dbf2db98 00200246 00000001 00200246 d755ee24 d755ee14 da694740
[  265.720128]  d755ee14 d755ee00 da694740 d755ee14 dbf2dbb4 c05a6bfd d755ee00 d74bef30
[  265.720128] Call Trace:
[  265.720128]  [<c05f89a0>] ? arp_find+0x3a0/0x3a0
[  265.720128]  [<c058efd2>] ? __alloc_skb+0x82/0x180
[  265.720128]  [<c05a6bfd>] neigh_probe+0x3d/0x60
[  265.720128]  [<c05a91d0>] __neigh_event_send+0xb0/0x240
[  265.720128]  [<c05aa125>] neigh_resolve_output+0x165/0x290
[  265.720128]  [<c05aa9ec>] ? __neigh_create+0x32c/0x370
[  265.720128]  [<c05cc15c>] ip_finish_output2+0x2ac/0x5d0
[  265.720128]  [<c05cbf1f>] ? ip_finish_output2+0x6f/0x5d0
[  265.720128]  [<c05cdbd7>] ip_finish_output+0x47/0xd0
[  265.720128]  [<c05cdcc7>] ip_output+0x67/0xd0
[  265.720128]  [<c05cc5f5>] ip_local_out+0x25/0x80
[  265.720128]  [<c05ccdbe>] ip_queue_xmit+0x19e/0x620
[  265.720128]  [<c05ccc20>] ? ip_build_and_send_pkt+0x240/0x240
[  265.720128]  [<c05e2e2e>] tcp_transmit_skb+0x40e/0x730
[  265.720128]  [<c05e528e>] tcp_write_xmit+0x19e/0x540
[  265.720128]  [<c05e5b36>] __tcp_push_pending_frames+0x36/0xd0
[  265.720128]  [<c05d461a>] tcp_push+0x6a/0xa0
[  265.720128]  [<c05d77d6>] tcp_sendmsg+0xe6/0xb50
[  265.720128]  [<c060252e>] inet_sendmsg+0xfe/0x1f0
[  265.720128]  [<c0602430>] ? inet_gro_receive+0x3a0/0x3a0
[  265.720128]  [<c05856c5>] sock_aio_write+0x145/0x170
[  265.720128]  [<c0248953>] do_sync_write+0x73/0xb0
[  265.720128]  [<c0248d6b>] vfs_write+0x10b/0x130
[  265.720128]  [<c02496a6>] SyS_write+0x56/0xa0
[  265.720128]  [<c067b51a>] sysenter_do_call+0x12/0x32
[  265.720128] Code: 38 01 00 00 83 f8 01 0f 84 79 01 00 00 83 f8 02 74 31 8b 54 24 20 85 d2 74 29 8b 4c 24 20 8b 81 9c 00 00 00 0f b7 91 8e 00 00 00 <8b> 54 10 0c 8b 87 bc 02 00 00 e8 bc 1a 01 00 83 f8 02 0f 84 4b
[  265.720128] EIP: [<c05f8a85>] arp_solicit+0xe5/0x3b0 SS:ESP 0068:dbf2db54
[  265.720128] CR2: 00000000db8e18b4
[  265.720128] ---[ end trace 071ca6b1ffc485e7 ]---
[  265.720128] Kernel panic - not syncing: Fatal exception in interrupt

---------- Trace 4 end ----------

---------- Trace 5 start ----------

[  142.033630] BUG: unable to handle kernel paging request at db971f10
[  142.035382] IP: [<c05c77a8>] ip_rcv_finish+0xd8/0x550
[  142.036252] *pde = 1f7f5067 *pte = 1b971060 
[  142.036252] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[  142.036252] Modules linked in: ipv6 binfmt_misc ccsecurity
[  142.036252] CPU: 1 PID: 13 Comm: ksoftirqd/1 Tainted: G        W    3.10.0-rc4-next-20130607-dirty #5
[  142.036252] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 08/15/2008
[  142.036252] task: dedee360 ti: dedf0000 task.ti: dedf0000
[  142.036252] EIP: 0060:[<c05c77a8>] EFLAGS: 00010282 CPU: 1
[  142.036252] EIP is at ip_rcv_finish+0xd8/0x550
[  142.036252] EAX: da63e258 EBX: da63e240 ECX: da63e240 EDX: da63e258
[  142.036252] ESI: da57f800 EDI: db971f10 EBP: dedf1df8 ESP: dedf1ddc
[  142.036252]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[  142.036252] CR0: 8005003b CR2: db971f10 CR3: 175a1000 CR4: 000006d0
[  142.036252] DR0: c11a5ed8 DR1: 00000000 DR2: 00000000 DR3: 00000000
[  142.036252] DR6: ffff0ff0 DR7: 00000600
[  142.036252] Stack:
[  142.036252]  00000020 da63e240 c091ff0c da63e258 ffff0000 da63e240 da57f800 dedf1e10
[  142.036252]  c05c7e67 00000018 c091ff0c c091f00c c091f020 dedf1e4c c059e01f da57f800
[  142.036252]  00000001 00000000 c059de6c 00000000 c091f020 da57f800 00000008 da63e240
[  142.036252] Call Trace:
[  142.036252]  [<c05c7e67>] ip_rcv+0x247/0x330
[  142.036252]  [<c059e01f>] __netif_receive_skb_core+0x20f/0x6a0
[  142.036252]  [<c059de6c>] ? __netif_receive_skb_core+0x5c/0x6a0
[  142.036252]  [<c059e4d3>] __netif_receive_skb+0x23/0x70
[  142.036252]  [<c059e5b8>] process_backlog+0x98/0x160
[  142.036252]  [<c05a1218>] net_rx_action+0xa8/0x240
[  142.036252]  [<c0145d5e>] __do_softirq+0xbe/0x330
[  142.036252]  [<c0145fe1>] ? run_ksoftirqd+0x11/0x60
[  142.036252]  [<c0145ffd>] run_ksoftirqd+0x2d/0x60
[  142.036252]  [<c01723f5>] smpboot_thread_fn+0x125/0x1d0
[  142.036252]  [<c0168a2f>] kthread+0xaf/0xc0
[  142.036252]  [<c01722d0>] ? smpboot_register_percpu_thread+0xd0/0xd0
[  142.036252]  [<c0679685>] ? wait_for_completion+0xa5/0xe0
[  142.036252]  [<c067bef7>] ret_from_kernel_thread+0x1b/0x28
[  142.036252]  [<c0168980>] ? __init_kthread_worker+0x60/0x60
[  142.036252] Code: 01 00 00 00 83 c4 10 5b 5e 5f 5d c3 8d b4 26 00 00 00 00 0f b7 bb 8e 00 00 00 8d 43 18 89 d9 03 bb 9c 00 00 00 89 45 f0 8b 55 f0 <0f> b6 07 83 e0 0f 8d 04 85 ec ff ff ff 88 42 08 8b 86 bc 02 00
[  142.036252] EIP: [<c05c77a8>] ip_rcv_finish+0xd8/0x550 SS:ESP 0068:dedf1ddc
[  142.036252] CR2: 00000000db971f10
[  142.036252] ---[ end trace 4bc6fca0d8aa9d77 ]---
[  142.036252] Kernel panic - not syncing: Fatal exception in interrupt
[  142.116558] ------------[ cut here ]------------
[  142.118644] WARNING: CPU: 1 PID: 13 at arch/x86/kernel/smp.c:123 native_smp_send_reschedule+0x70/0x80()
[  142.120514] Modules linked in: ipv6 binfmt_misc ccsecurity
[  142.120514] CPU: 1 PID: 13 Comm: ksoftirqd/1 Tainted: G      D W    3.10.0-rc4-next-20130607-dirty #5
[  142.120514] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 08/15/2008
[  142.120514]  0000007b dedf1ab0 c067701f c07db88f dedf1ae0 c013c71f c07e5e18 00000001
[  142.120514]  0000000d c07db88f 0000007b c0124c80 c0124c80 00000000 00000001 dfa997c0
[  142.120514]  dedf1af0 c013c762 00000009 00000000 dedf1afc c0124c80 00000000 dedf1b28
[  142.120514] Call Trace:
[  142.120514]  [<c067701f>] dump_stack+0x4c/0x6d
[  142.120514]  [<c013c71f>] warn_slowpath_common+0x7f/0xa0
[  142.120514]  [<c0124c80>] ? native_smp_send_reschedule+0x70/0x80
[  142.120514]  [<c0124c80>] ? native_smp_send_reschedule+0x70/0x80
[  142.120514]  [<c013c762>] warn_slowpath_null+0x22/0x30
[  142.120514]  [<c0124c80>] native_smp_send_reschedule+0x70/0x80
[  142.120514]  [<c01810fa>] trigger_load_balance+0x39a/0x4e0
[  142.120514]  [<c0180dd0>] ? trigger_load_balance+0x70/0x4e0
[  142.120514]  [<c01753ef>] scheduler_tick+0xdf/0x100
[  142.120514]  [<c014d127>] update_process_times+0x57/0x70
[  142.120514]  [<c0194601>] tick_sched_handle+0x31/0x70
[  142.120514]  [<c01948ca>] tick_sched_timer+0x4a/0x90
[  142.120514]  [<c016cb16>] __run_hrtimer+0x86/0x290
[  142.120514]  [<c0194880>] ? tick_nohz_handler+0xd0/0xd0
[  142.120514]  [<c016d010>] hrtimer_interrupt+0x140/0x2f0
[  142.120514]  [<c067c644>] smp_apic_timer_interrupt+0x54/0x88
[  142.120514]  [<c0414a9c>] ? trace_hardirqs_off_thunk+0xc/0x10
[  142.120514]  [<c067babe>] apic_timer_interrupt+0x32/0x38
[  142.120514]  [<c0676dc0>] ? panic+0x15f/0x19b
[  142.120514]  [<c0104e2d>] oops_end+0xcd/0xd0
[  142.120514]  [<c01312d7>] no_context+0xd7/0x140
[  142.120514]  [<c0131400>] __bad_area_nosemaphore+0xc0/0x160
[  142.120514]  [<c0132e61>] ? __change_page_attr_set_clr+0x41/0x90
[  142.120514]  [<c01314b7>] bad_area_nosemaphore+0x17/0x20
[  142.120514]  [<c01319cc>] __do_page_fault+0x1bc/0x3e0
[  142.120514]  [<c0135897>] ? __phys_addr+0x37/0x90
[  142.120514]  [<c067bcfb>] ? error_code+0x5b/0x64
[  142.120514]  [<c0131bf0>] ? __do_page_fault+0x3e0/0x3e0
[  142.120514]  [<c058fec0>] ? pskb_expand_head+0x70/0x200
[  142.120514]  [<c0131bf0>] ? __do_page_fault+0x3e0/0x3e0
[  142.120514]  [<c0131bfd>] do_page_fault+0xd/0x10
[  142.120514]  [<c067bcff>] error_code+0x5f/0x64
[  142.120514]  [<c0131bf0>] ? __do_page_fault+0x3e0/0x3e0
[  142.120514]  [<c05c77a8>] ? ip_rcv_finish+0xd8/0x550
[  142.120514]  [<c05c7e67>] ip_rcv+0x247/0x330
[  142.120514]  [<c059e01f>] __netif_receive_skb_core+0x20f/0x6a0
[  142.120514]  [<c059de6c>] ? __netif_receive_skb_core+0x5c/0x6a0
[  142.120514]  [<c059e4d3>] __netif_receive_skb+0x23/0x70
[  142.120514]  [<c059e5b8>] process_backlog+0x98/0x160
[  142.120514]  [<c05a1218>] net_rx_action+0xa8/0x240
[  142.120514]  [<c0145d5e>] __do_softirq+0xbe/0x330
[  142.120514]  [<c0145fe1>] ? run_ksoftirqd+0x11/0x60
[  142.120514]  [<c0145ffd>] run_ksoftirqd+0x2d/0x60
[  142.120514]  [<c01723f5>] smpboot_thread_fn+0x125/0x1d0
[  142.120514]  [<c0168a2f>] kthread+0xaf/0xc0
[  142.120514]  [<c01722d0>] ? smpboot_register_percpu_thread+0xd0/0xd0
[  142.120514]  [<c0679685>] ? wait_for_completion+0xa5/0xe0
[  142.120514]  [<c067bef7>] ret_from_kernel_thread+0x1b/0x28
[  142.120514]  [<c0168980>] ? __init_kthread_worker+0x60/0x60
[  142.120514] ---[ end trace 4bc6fca0d8aa9d78 ]---

---------- Trace 5 end ----------
