From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [2.6.36-rc5] INET?: possible irq lock inversion dependency
Date: Wed, 22 Sep 2010 16:14:36 +0900
Message-ID: <201009220714.o8M7Ebps067361@www262.sakura.ne.jp>
References: <201006242053.IAG26562.JHQFFOMSVFtOLO@I-love.SAKURA.ne.jp> <201009072132.FHA93457.MHOJFQOOFLVStF@I-love.SAKURA.ne.jp> <201009210651.o8L6pbkP038129@www262.sakura.ne.jp> <1285055760.2617.27.camel@edumazet-laptop> <201009210910.o8L9Anaf071504@www262.sakura.ne.jp> <1285061757.2617.176.camel@edumazet-laptop> <1285064011.2617.238.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:55888 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899Ab0IVHOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 03:14:41 -0400
In-Reply-To: <1285064011.2617.238.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I established steps to reproduce this warning using clean 2.6.36-rc5 .

[   37.539697] =========================================================
[   37.541991] [ INFO: possible irq lock inversion dependency detected ]
[   37.541991] 2.6.36-rc5 #1
[   37.541991] ---------------------------------------------------------
[   37.541991] mount/2681 just changed the state of lock:
[   37.541991]  (clock-AF_INET){++.?..}, at: [<c135e03c>] xs_udp_write_space+0x1c/0x50
[   37.541991] but this lock was taken by another, SOFTIRQ-safe lock in the past:
[   37.541991]  (slock-AF_INET){+.-...}
[   37.541991] 
[   37.541991] and interrupts could create inverse lock ordering between them.
[   37.541991] 
[   37.541991] 
[   37.541991] other info that might help us debug this:
[   37.541991] no locks held by mount/2681.
[   37.541991] 
[   37.541991] the shortest dependencies between 2nd lock and 1st lock:
[   37.541991]  -> (slock-AF_INET){+.-...} ops: 562 {
[   37.541991]     HARDIRQ-ON-W at:
[   37.541991]                                          [<c106a8de>] mark_irqflags+0xfe/0x180
[   37.541991]                                          [<c106b65d>] __lock_acquire+0x38d/0x8e0
[   37.541991]                                          [<c106cbfa>] lock_acquire+0x7a/0xa0
[   37.541991]                                          [<c138be2e>] _raw_spin_lock_bh+0x3e/0x80
[   37.541991]                                          [<c12daf39>] lock_sock_fast+0x29/0x90
[   37.541991]                                          [<c132b1a4>] udp_destroy_sock+0x14/0x40
[   37.541991]                                          [<c12db293>] sk_common_release+0xb3/0xc0
[   37.541991]                                          [<c132bb18>] udp_lib_close+0x8/0x10
[   37.541991]                                          [<c1331a7e>] inet_release+0xbe/0x100
[   37.541991]                                          [<c12d5476>] sock_release+0x66/0x80
[   37.541991]                                          [<c12d61f2>] sock_close+0x12/0x30
[   37.541991]                                          [<c10c637b>] __fput+0x1cb/0x240
[   37.541991]                                          [<c10c6409>] fput+0x19/0x20
[   37.541991]                                          [<c10c4263>] filp_close+0x43/0x70
[   37.541991]                                          [<c103fdcd>] close_files+0xad/0x150
[   37.541991]                                          [<c103fed9>] put_files_struct+0x29/0xf0
[   37.541991]                                          [<c1040030>] exit_files+0x40/0x50
[   37.541991]                                          [<c10406f6>] do_exit+0x116/0x2e0
[   37.541991]                                          [<c1040924>] do_group_exit+0x34/0xb0
[   37.541991]                                          [<c10409af>] sys_exit_group+0xf/0x20
[   37.541991]                                          [<c138c8d1>] syscall_call+0x7/0xb
[   37.541991]     IN-SOFTIRQ-W at:
[   37.541991]                                          [<c106a8fe>] mark_irqflags+0x11e/0x180
[   37.541991]                                          [<c106b65d>] __lock_acquire+0x38d/0x8e0
[   37.541991]                                          [<c106cbfa>] lock_acquire+0x7a/0xa0
[   37.541991]                                          [<c138bcb9>] _raw_spin_lock+0x39/0x70
[   37.541991]                                          [<c12d98d1>] sk_clone+0xb1/0x2c0
[   37.541991]                                          [<c130fd7a>] inet_csk_clone+0x1a/0xb0
[   37.541991]                                          [<c132535c>] tcp_create_openreq_child+0x1c/0x460
[   37.541991]                                          [<c1322a2f>] tcp_v4_syn_recv_sock+0x3f/0x1e0
[   37.940862]                                          [<c132592c>] tcp_check_req+0x18c/0x3b0
[   37.940862]                                          [<c1322c1d>] tcp_v4_hnd_req+0x4d/0x160
[   37.940862]                                          [<c1322f49>] tcp_v4_do_rcv+0x159/0x280
[   37.940862]                                          [<c13235e4>] tcp_v4_rcv+0x574/0xa30
[   37.940862]                                          [<c1305443>] ip_local_deliver_finish+0x103/0x320
[   37.940862]                                          [<c1305690>] ip_local_deliver+0x30/0x40
[   37.940862]                                          [<c1305809>] ip_rcv_finish+0x169/0x480
[   37.940862]                                          [<c1305cba>] ip_rcv+0x19a/0x2b0
[   37.940862]                                          [<c12e691d>] __netif_receive_skb+0x21d/0x310
[   37.940862]                                          [<c12e7428>] process_backlog+0x88/0x160
[   37.940862]                                          [<c12e77f7>] net_rx_action+0x127/0x140
[   37.940862]                                          [<c1042e70>] __do_softirq+0xd0/0x130
[   37.940862]     INITIAL USE at:
[   37.940862]                                         [<c106b490>] __lock_acquire+0x1c0/0x8e0
[   37.940862]                                         [<c106cbfa>] lock_acquire+0x7a/0xa0
[   37.940862]                                         [<c138be2e>] _raw_spin_lock_bh+0x3e/0x80
[   37.940862]                                         [<c12daf39>] lock_sock_fast+0x29/0x90
[   37.940862]                                         [<c132b1a4>] udp_destroy_sock+0x14/0x40
[   37.940862]                                         [<c12db293>] sk_common_release+0xb3/0xc0
[   37.940862]                                         [<c132bb18>] udp_lib_close+0x8/0x10
[   37.940862]                                         [<c1331a7e>] inet_release+0xbe/0x100
[   37.940862]                                         [<c12d5476>] sock_release+0x66/0x80
[   37.940862]                                         [<c12d61f2>] sock_close+0x12/0x30
[   37.940862]                                         [<c10c637b>] __fput+0x1cb/0x240
[   37.940862]                                         [<c10c6409>] fput+0x19/0x20
[   37.940862]                                         [<c10c4263>] filp_close+0x43/0x70
[   37.940862]                                         [<c103fdcd>] close_files+0xad/0x150
[   37.940862]                                         [<c103fed9>] put_files_struct+0x29/0xf0
[   37.940862]                                         [<c1040030>] exit_files+0x40/0x50
[   37.940862]                                         [<c10406f6>] do_exit+0x116/0x2e0
[   37.940862]                                         [<c1040924>] do_group_exit+0x34/0xb0
[   37.940862]                                         [<c10409af>] sys_exit_group+0xf/0x20
[   37.940862]                                         [<c138c8d1>] syscall_call+0x7/0xb
[   37.940862]   }
[   37.940862]   ... key      at: [<c1d4c9d0>] af_family_slock_keys+0x10/0x140
[   37.940862]   ... acquired at:
[   37.940862]    [<c106910b>] check_prevs_add+0xab/0x100
[   37.940862]    [<c1069495>] validate_chain+0x305/0x5a0
[   37.940862]    [<c106b57d>] __lock_acquire+0x2ad/0x8e0
[   37.940862]    [<c106cbfa>] lock_acquire+0x7a/0xa0
[   37.940862]    [<c138c46e>] _raw_write_lock_bh+0x3e/0x80
[   37.940862]    [<c13100a6>] inet_csk_listen_stop+0x86/0x160
[   37.940862]    [<c1312c02>] tcp_close+0x382/0x390
[   37.940862]    [<c1331a7e>] inet_release+0xbe/0x100
[   37.940862]    [<c12d5476>] sock_release+0x66/0x80
[   37.940862]    [<c12d61f2>] sock_close+0x12/0x30
[   37.940862]    [<c10c637b>] __fput+0x1cb/0x240
[   37.940862]    [<c10c6409>] fput+0x19/0x20
[   37.940862]    [<c10c4263>] filp_close+0x43/0x70
[   37.940862]    [<c10c42fd>] sys_close+0x6d/0x110
[   37.940862]    [<c138c8d1>] syscall_call+0x7/0xb
[   37.940862] 
[   37.940862] -> (clock-AF_INET){++.?..} ops: 72 {
[   37.940862]    HARDIRQ-ON-W at:
[   37.940862]                                        [<c106a8de>] mark_irqflags+0xfe/0x180
[   37.940862]                                        [<c106b65d>] __lock_acquire+0x38d/0x8e0
[   37.940862]                                        [<c106cbfa>] lock_acquire+0x7a/0xa0
[   37.940862]                                        [<c138c46e>] _raw_write_lock_bh+0x3e/0x80
[   37.940862]                                        [<c12db20f>] sk_common_release+0x2f/0xc0
[   37.940862]                                        [<c132bb18>] udp_lib_close+0x8/0x10
[   37.940862]                                        [<c1331a7e>] inet_release+0xbe/0x100
[   37.940862]                                        [<c12d5476>] sock_release+0x66/0x80
[   37.940862]                                        [<c12d61f2>] sock_close+0x12/0x30
[   37.940862]                                        [<c10c637b>] __fput+0x1cb/0x240
[   37.940862]                                        [<c10c6409>] fput+0x19/0x20
[   37.940862]                                        [<c10c4263>] filp_close+0x43/0x70
[   37.940862]                                        [<c103fdcd>] close_files+0xad/0x150
[   37.940862]                                        [<c103fed9>] put_files_struct+0x29/0xf0
[   37.940862]                                        [<c1040030>] exit_files+0x40/0x50
[   37.940862]                                        [<c10406f6>] do_exit+0x116/0x2e0
[   37.940862]                                        [<c1040924>] do_group_exit+0x34/0xb0
[   37.940862]                                        [<c10409af>] sys_exit_group+0xf/0x20
[   37.940862]                                        [<c138c8d1>] syscall_call+0x7/0xb
[   37.940862]    HARDIRQ-ON-R at:
[   37.940862]                                        [<c106a84e>] mark_irqflags+0x6e/0x180
[   37.940862]                                        [<c106b65d>] __lock_acquire+0x38d/0x8e0
[   37.940862]                                        [<c106cbfa>] lock_acquire+0x7a/0xa0
[   37.940862]                                        [<c138bfd9>] _raw_read_lock+0x39/0x70
[   37.940862]                                        [<c135ddae>] xs_tcp_state_change+0x1e/0x1d0
[   37.940862]                                        [<c131bd38>] tcp_rcv_synsent_state_process+0x398/0x590
[   37.940862]                                        [<c131c3d7>] tcp_rcv_state_process+0x4a7/0x560
[   37.940862]                                        [<c1322e61>] tcp_v4_do_rcv+0x71/0x280
[   37.940862]                                        [<c12da206>] __release_sock+0x66/0x150
[   37.940862]                                        [<c12daf07>] release_sock+0x87/0x90
[   37.940862]                                        [<c1331e6a>] inet_stream_connect+0x5a/0x1b0
[   37.940862]                                        [<c12d7d68>] kernel_connect+0x18/0x30
[   37.940862]                                        [<c135ea5e>] xs_tcp_finish_connecting+0x4e/0x120
[   37.940862]                                        [<c135eb8b>] xs_tcp_setup_socket+0x5b/0x180
[   37.940862]                                        [<c135edc4>] xs_tcp_connect_worker4+0x14/0x20
[   37.940862]                                        [<c1051547>] process_one_work+0x147/0x3a0
[   37.940862]                                        [<c1051886>] worker_thread+0xa6/0x200
[   37.940862]                                        [<c1056765>] kthread+0x75/0x80
[   37.940862]                                        [<c10031fa>] kernel_thread_helper+0x6/0x1c
[   37.940862]    IN-SOFTIRQ-R at:
[   37.940862]                                        [<c106a8fe>] mark_irqflags+0x11e/0x180
[   37.940862]                                        [<c106b65d>] __lock_acquire+0x38d/0x8e0
[   37.940862]                                        [<c106cbfa>] lock_acquire+0x7a/0xa0
[   37.940862]                                        [<c138bfd9>] _raw_read_lock+0x39/0x70
[   37.940862]                                        [<c135dc81>] xs_tcp_data_ready+0x21/0x90
[   37.940862]                                        [<c131a1f8>] tcp_data_queue+0x248/0x820
[   37.940862]                                        [<c131b56e>] tcp_rcv_established+0xae/0x4e0
[   37.940862]                                        [<c1322fc1>] tcp_v4_do_rcv+0x1d1/0x280
[   37.940862]                                        [<c13235e4>] tcp_v4_rcv+0x574/0xa30
[   37.940862]                                        [<c1305443>] ip_local_deliver_finish+0x103/0x320
[   37.940862]                                        [<c1305690>] ip_local_deliver+0x30/0x40
[   37.940862]                                        [<c1305809>] ip_rcv_finish+0x169/0x480
[   37.940862]                                        [<c1305cba>] ip_rcv+0x19a/0x2b0
[   37.940862]                                        [<c12e691d>] __netif_receive_skb+0x21d/0x310
[   37.940862]                                        [<c12e7428>] process_backlog+0x88/0x160
[   37.940862]                                        [<c12e77f7>] net_rx_action+0x127/0x140
[   37.940862]                                        [<c1042e70>] __do_softirq+0xd0/0x130
[   37.940862]    SOFTIRQ-ON-R at:
[   37.940862]                                        [<c106a8c2>] mark_irqflags+0xe2/0x180
[   37.940862]                                        [<c106b65d>] __lock_acquire+0x38d/0x8e0
[   37.940862]                                        [<c106cbfa>] lock_acquire+0x7a/0xa0
[   37.940862]                                        [<c138bfd9>] _raw_read_lock+0x39/0x70
[   37.940862]                                        [<c135e03c>] xs_udp_write_space+0x1c/0x50
[   37.940862]                                        [<c135e14a>] xs_udp_do_set_buffer_size+0x8a/0x90
[   37.940862]                                        [<c135e18d>] xs_udp_set_buffer_size+0x3d/0x40
[   37.940862]                                        [<c13594d8>] rpc_setbufsize+0x28/0x30
[   37.940862]                                        [<e0967314>] nfs_server_set_fsinfo+0x364/0x400 [nfs]
[   37.940862]                                        [<e0967415>] nfs_probe_fsinfo+0x65/0x100 [nfs]
[   37.940862]                                        [<e0967717>] nfs_create_server+0x87/0x240 [nfs]
[   37.940862]                                        [<e0971aeb>] nfs_get_sb+0x8b/0x240 [nfs]
[   37.940862]                                        [<c10c7f41>] vfs_kern_mount+0x71/0x190
[   37.940862]                                        [<c10c8287>] do_kern_mount+0x37/0x90
[   37.940862]                                        [<c10de6c7>] do_new_mount+0x57/0xa0
[   37.940862]                                        [<c10decc1>] do_mount+0x171/0x1b0
[   37.940862]                                        [<c10defbc>] sys_mount+0x6c/0xa0
[   37.940862]                                        [<c138c8d1>] syscall_call+0x7/0xb
[   37.940862]    INITIAL USE at:
[   37.940862]                                       [<c106b490>] __lock_acquire+0x1c0/0x8e0
[   37.940862]                                       [<c106cbfa>] lock_acquire+0x7a/0xa0
[   37.940862]                                       [<c138c46e>] _raw_write_lock_bh+0x3e/0x80
[   37.940862]                                       [<c12db20f>] sk_common_release+0x2f/0xc0
[   37.940862]                                       [<c132bb18>] udp_lib_close+0x8/0x10
[   37.940862]                                       [<c1331a7e>] inet_release+0xbe/0x100
[   37.940862]                                       [<c12d5476>] sock_release+0x66/0x80
[   37.940862]                                       [<c12d61f2>] sock_close+0x12/0x30
[   37.940862]                                       [<c10c637b>] __fput+0x1cb/0x240
[   37.940862]                                       [<c10c6409>] fput+0x19/0x20
[   37.940862]                                       [<c10c4263>] filp_close+0x43/0x70
[   37.940862]                                       [<c103fdcd>] close_files+0xad/0x150
[   37.940862]                                       [<c103fed9>] put_files_struct+0x29/0xf0
[   37.940862]                                       [<c1040030>] exit_files+0x40/0x50
[   37.940862]                                       [<c10406f6>] do_exit+0x116/0x2e0
[   37.940862]                                       [<c1040924>] do_group_exit+0x34/0xb0
[   37.940862]                                       [<c10409af>] sys_exit_group+0xf/0x20
[   37.940862]                                       [<c138c8d1>] syscall_call+0x7/0xb
[   37.940862]  }
[   37.940862]  ... key      at: [<c1d4cb10>] af_callback_keys+0x10/0x130
[   37.940862]  ... acquired at:
[   37.940862]    [<c1069d46>] check_usage_backwards+0x76/0xd0
[   37.940862]    [<c1069f59>] mark_lock_irq+0x99/0x240
[   37.940862]    [<c106abfc>] mark_lock+0x21c/0x3c0
[   37.940862]    [<c106a8c2>] mark_irqflags+0xe2/0x180
[   37.940862]    [<c106b65d>] __lock_acquire+0x38d/0x8e0
[   37.940862]    [<c106cbfa>] lock_acquire+0x7a/0xa0
[   37.940862]    [<c138bfd9>] _raw_read_lock+0x39/0x70
[   37.940862]    [<c135e03c>] xs_udp_write_space+0x1c/0x50
[   37.940862]    [<c135e14a>] xs_udp_do_set_buffer_size+0x8a/0x90
[   37.940862]    [<c135e18d>] xs_udp_set_buffer_size+0x3d/0x40
[   37.940862]    [<c13594d8>] rpc_setbufsize+0x28/0x30
[   37.940862]    [<e0967314>] nfs_server_set_fsinfo+0x364/0x400 [nfs]
[   37.940862]    [<e0967415>] nfs_probe_fsinfo+0x65/0x100 [nfs]
[   37.940862]    [<e0967717>] nfs_create_server+0x87/0x240 [nfs]
[   37.940862]    [<e0971aeb>] nfs_get_sb+0x8b/0x240 [nfs]
[   37.940862]    [<c10c7f41>] vfs_kern_mount+0x71/0x190
[   37.940862]    [<c10c8287>] do_kern_mount+0x37/0x90
[   37.940862]    [<c10de6c7>] do_new_mount+0x57/0xa0
[   37.940862]    [<c10decc1>] do_mount+0x171/0x1b0
[   37.940862]    [<c10defbc>] sys_mount+0x6c/0xa0
[   37.940862]    [<c138c8d1>] syscall_call+0x7/0xb
[   37.940862] 
[   37.940862] 
[   37.940862] stack backtrace:
[   37.940862] Pid: 2681, comm: mount Not tainted 2.6.36-rc5 #1
[   37.940862] Call Trace:
[   37.940862]  [<c103deb8>] ? printk+0x18/0x20
[   37.940862]  [<c1069bd8>] print_irq_inversion_bug+0x108/0x120
[   37.940862]  [<c1069d46>] check_usage_backwards+0x76/0xd0
[   37.940862]  [<c1069f59>] mark_lock_irq+0x99/0x240
[   37.940862]  [<c1069cd0>] ? check_usage_backwards+0x0/0xd0
[   37.940862]  [<c106abfc>] mark_lock+0x21c/0x3c0
[   37.940862]  [<c106a8c2>] mark_irqflags+0xe2/0x180
[   37.940862]  [<c106b65d>] __lock_acquire+0x38d/0x8e0
[   37.940862]  [<c109a5fe>] ? mempool_free_slab+0xe/0x10
[   37.940862]  [<c109a5d8>] ? mempool_free+0x98/0xa0
[   37.940862]  [<c106cbfa>] lock_acquire+0x7a/0xa0
[   37.940862]  [<c135e03c>] ? xs_udp_write_space+0x1c/0x50
[   37.940862]  [<c138bfd9>] _raw_read_lock+0x39/0x70
[   37.940862]  [<c135e03c>] ? xs_udp_write_space+0x1c/0x50
[   37.940862]  [<c135e03c>] xs_udp_write_space+0x1c/0x50
[   37.940862]  [<c135e14a>] xs_udp_do_set_buffer_size+0x8a/0x90
[   37.940862]  [<c135e18d>] xs_udp_set_buffer_size+0x3d/0x40
[   37.940862]  [<c135e150>] ? xs_udp_set_buffer_size+0x0/0x40
[   37.940862]  [<c13594d8>] rpc_setbufsize+0x28/0x30
[   37.940862]  [<e0967314>] nfs_server_set_fsinfo+0x364/0x400 [nfs]
[   37.940862]  [<e0967415>] nfs_probe_fsinfo+0x65/0x100 [nfs]
[   37.940862]  [<c10bf558>] ? cache_alloc_debugcheck_after+0x98/0x1d0
[   37.940862]  [<e096e1d3>] ? nfs_alloc_fattr+0x23/0x30 [nfs]
[   37.940862]  [<e0967717>] nfs_create_server+0x87/0x240 [nfs]
[   37.940862]  [<e096e1f5>] ? nfs_alloc_fhandle+0x15/0x30 [nfs]
[   37.940862]  [<e0971aeb>] nfs_get_sb+0x8b/0x240 [nfs]
[   37.940862]  [<e09719b0>] ? nfs_compare_super+0x0/0x90 [nfs]
[   37.940862]  [<c10c7f41>] vfs_kern_mount+0x71/0x190
[   37.940862]  [<c10dc11c>] ? get_fs_type+0x8c/0xa0
[   37.940862]  [<c10c8287>] do_kern_mount+0x37/0x90
[   37.940862]  [<c10de6c7>] do_new_mount+0x57/0xa0
[   37.940862]  [<c10decc1>] do_mount+0x171/0x1b0
[   37.940862]  [<c10defbc>] sys_mount+0x6c/0xa0
[   37.940862]  [<c138c8d1>] syscall_call+0x7/0xb

Boot and login and run test.sh below

--- test.sh start ---
#! /bin/sh
./a.out
echo 1 > /proc/sys/kernel/printk_delay
mount 127.0.0.1:/usr/src/ /mnt/
umount /mnt/
--- test.sh end ---

where a.out is made by "gcc -Wall -O3 test.c"

--- test.c start ---
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>

int main(int argc, char *argv[])
{
	int fd1 = socket(AF_INET, SOCK_STREAM, 0);
	int fd2 = socket(AF_INET, SOCK_STREAM, 0);
	struct sockaddr_in addr = { };
	socklen_t size = sizeof(addr);
	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
	addr.sin_port = htons(0);
	bind(fd1, (struct sockaddr *) &addr, sizeof(addr));
	listen(fd1, 5);
	getsockname(fd1, (struct sockaddr *) &addr, &size);
	connect(fd2, (struct sockaddr *) &addr, sizeof(addr));
	close(fd1);
	close(fd2);
	return 0;
}
--- test.c end ---

Config is at http://I-love.SAKURA.ne.jp/tmp/config-2.6.36-rc5
Full log is at http://I-love.SAKURA.ne.jp/tmp/dmesg-2.6.36-rc5.txt

I'm using Debian Sarge on i686.

Regards.
