From: Dave Jones <davej@codemonkey.org.uk>
Subject: netconsole refcount warning
Date: Sun, 9 Jul 2017 19:57:57 -0400
Message-ID: <20170709235757.43bjgxjbimwqx6yk@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from scorn.kernelslacker.org ([45.56.101.199]:33972 "EHLO
        scorn.kernelslacker.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752765AbdGIX57 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Jul 2017 19:57:59 -0400
Received: from [2601:196:4600:77b0:ae9e:17ff:feb7:72ca] (helo=wopr.kernelslacker.org)
        by scorn.kernelslacker.org with esmtp (Exim 4.89)
        (envelope-from <davej@codemonkey.org.uk>)
        id 1dUM5O-0006gF-BV
        for netdev@vger.kernel.org; Sun, 09 Jul 2017 19:57:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new refcount debugging code spews this twice during boot on my router..


refcount_t: increment on 0; use-after-free.
------------[ cut here ]------------
WARNING: CPU: 1 PID: 17 at lib/refcount.c:152 refcount_inc+0x2b/0x30
CPU: 1 PID: 17 Comm: ksoftirqd/1 Not tainted 4.12.0-firewall+ #8 
task: ffff8801d4441ac0 task.stack: ffff8801d4450000
RIP: 0010:refcount_inc+0x2b/0x30
RSP: 0018:ffff8801d4456da8 EFLAGS: 00010046
RAX: 000000000000002c RBX: ffff8801d4c3cf40 RCX: 0000000000000000
RDX: 000000000000002c RSI: 0000000000000003 RDI: ffffed003a88adab
RBP: ffff8801d4456da8 R08: 0000000000000003 R09: fffffbfff4afcb57
R10: 0000000000000000 R11: fffffbfff4afcb58 R12: ffff8801d4c3c540
R13: 0000000000000082 R14: ffff8801ce9c7ff8 R15: ffff8801ce9c8aa0
FS:  0000000000000000(0000) GS:ffff8801d6a00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fa2b803156e CR3: 00000001c405d000 CR4: 00000000000406e0
Call Trace:
 zap_completion_queue+0xad/0x1a0
 netpoll_poll_dev+0x16f/0x3f0
 netpoll_send_skb_on_dev+0x25a/0x360
 netpoll_send_udp+0x526/0x850
 write_ext_msg+0x212/0x230
 ? _raw_spin_unlock_irqrestore+0x43/0x70
 ? write_msg+0x11f/0x130
 console_unlock+0x3ea/0x6e0
 vprintk_emit+0x298/0x3a0
 vprintk_default+0x1f/0x30
 vprintk_func+0x34/0xb0
 printk+0x95/0xb2
 ? show_regs_print_info+0x45/0x45
 ? nf_log_buf_open+0x2c/0x70
 ? nf_log_buf_close+0x26/0x70
 nf_log_buf_close+0x3c/0x70
 nf_log_ip_packet+0x111/0x250
 nf_log_packet+0x19e/0x330
 ? nf_logger_find_get+0x1c0/0x1c0
 ? debug_show_all_locks+0x1e0/0x1e0
 ? __local_bh_enable_ip+0x64/0xb0
 ? debug_smp_processor_id+0x17/0x20
 log_tg+0x13d/0x170
 ? log_tg_check+0x70/0x70
 ? trace_hardirqs_on+0xe/0x10
 ? __local_bh_enable_ip+0x64/0xb0
 ? _raw_spin_unlock_bh+0x35/0x40
 ipt_do_table+0x770/0xbb0
 ? mark_lock+0xb7/0x7d0
 ? sched_clock_cpu+0x1c/0x130
 ? ipt_alloc_initial_table+0x2d0/0x2d0
 ? debug_smp_processor_id+0x17/0x20
 ? __lock_is_held+0x55/0x110
 ? ipt_unregister_table+0x50/0x50
 iptable_filter_hook+0x53/0xd0
 nf_hook_slow+0x4a/0x120
 ip_local_deliver+0x1ba/0x2c0
 ? ip_local_deliver+0x100/0x2c0
 ? ip_call_ra_chain+0x270/0x270
 ? inet_del_offload+0x40/0x40
 ip_rcv_finish+0x2b9/0x880
 ip_rcv+0x51f/0x8a0
 ? ip_rcv+0x5ae/0x8a0
 ? ip_local_deliver+0x2c0/0x2c0
 ? ip_local_deliver_finish+0x4d0/0x4d0
 ? ip_local_deliver+0x2c0/0x2c0
 __netif_receive_skb_core+0xd4b/0x1210
 ? enqueue_to_backlog+0x620/0x620
 ? ktime_get_with_offset+0x11d/0x290
 __netif_receive_skb+0x27/0xc0
 ? debug_smp_processor_id+0x17/0x20
 netif_receive_skb_internal+0x3e3/0xc90
 ? netif_receive_skb_internal+0x90/0xc90
 ? __build_skb+0x2f/0x140
 ? __dev_queue_xmit+0xd30/0xd30
 ? debug_dma_sync_single_for_device+0xb7/0xc0
 ? debug_dma_sync_single_for_cpu+0xc0/0xc0
 ? dev_gro_receive+0x90/0x9b0
 ? __lock_is_held+0x30/0x110
 ? __asan_loadN+0x10/0x20
 ? skb_gro_reset_offset+0x93/0x140
 napi_gro_receive+0x1d1/0x270
 rtl8169_poll+0x49b/0xb30
 net_rx_action+0x4c4/0x7d0
 ? napi_complete_done+0x1b0/0x1b0
 ? __lock_is_held+0x30/0x110
 __do_softirq+0x113/0x611
 run_ksoftirqd+0x22/0x90
 smpboot_thread_fn+0x348/0x4f0
 ? __local_bh_enable_ip+0xb0/0xb0
 ? sort_range+0x30/0x30
 ? schedule+0x6c/0xe0
 ? __kthread_parkme+0xf2/0x110
 kthread+0x1ab/0x200
 ? sort_range+0x30/0x30
 ? __kthread_create_on_node+0x340/0x340
 ret_from_fork+0x27/0x40
Code: 55 48 89 e5 e8 97 ff ff ff 84 c0 74 02 5d c3 80 3d 5d 3e 06 01 00 75 f5 48 c7 c7 20 69 f1 a4 c6 05 4d 3e 06 01 01 e8 ca 41 bc ff <0f> ff 5d c3 90 55 48 89 e5 41 54 44 8d 27 48 8d 3e 53 48 8d 1e 
---[ end trace a9116b75ea217b54 ]---
