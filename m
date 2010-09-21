From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [2.6.35-rc5] INET?: possible irq lock inversion dependency
Date: Tue, 21 Sep 2010 15:51:37 +0900
Message-ID: <201009210651.o8L6pbkP038129@www262.sakura.ne.jp>
References: <201006242053.IAG26562.JHQFFOMSVFtOLO@I-love.SAKURA.ne.jp> <201009072132.FHA93457.MHOJFQOOFLVStF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <201009072132.FHA93457.MHOJFQOOFLVStF@I-love.SAKURA.ne.jp>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I succeeded to save undamaged messages by doing

  echo 1 > /proc/sys/kernel/printk_delay

. (Well, it would be nice to do above before printing lockdep warning because
it prints a lot of lines enough to drop some lines.)

Although my patch is still applied, I believe my patch is not the culprit.
This warning might be related to lock_sock_fast() which was introduced in
2.6.35 because I'm seeing this warning since 2.6.35-rcX . What can I do next?

Regards.

[  199.267633] nfsd: last server has exited, flushing export cache
[  200.784089] 
[  200.784094] =========================================================
[  200.786186] [ INFO: possible irq lock inversion dependency detected ]
[  200.786186] 2.6.36-rc5-old #2
[  200.786186] ---------------------------------------------------------
[  200.786186] kworker/0:1/10 just changed the state of lock:
[  200.786186]  (clock-AF_INET){++.?..}, at: [<c135e9be>] xs_tcp_state_change+0x1e/0x1d0
[  200.786186] but this lock was taken by another, SOFTIRQ-safe lock in the past:
[  200.786186]  (slock-AF_INET){+.-...}
[  200.786186] 
[  200.786186] and interrupts could create inverse lock ordering between them.
[  200.786186] 
[  200.786186] 
[  200.786186] other info that might help us debug this:
[  200.786186] 3 locks held by kworker/0:1/10:
[  200.786186]  #0:  (rpciod){+.+.+.}, at: [<c10516f6>] process_one_work+0xd6/0x3a0
[  200.786186]  #1:  ((&xprt->task_cleanup)){+.+...}, at: [<c10516f6>] process_one_work+0xd6/0x3a0
[  200.786186]  #2:  (sk_lock-AF_INET-RPC){+.+...}, at: [<c1333119>] inet_shutdown+0x49/0x110
[  200.786186] 
[  200.786186] the shortest dependencies between 2nd lock and 1st lock:
[  200.786186]  -> (slock-AF_INET){+.-...} ops: 11832 {
[  200.786186]     HARDIRQ-ON-W at:
[  200.786186]                                          [<c106ab8e>] mark_irqflags+0xfe/0x180
[  200.786186]                                          [<c106b90d>] __lock_acquire+0x38d/0x8e0
[  200.786186]                                          [<c106ceaa>] lock_acquire+0x7a/0xa0
[  200.786186]                                          [<c138ca3e>] _raw_spin_lock_bh+0x3e/0x80
[  200.786186]                                          [<c12dba59>] lock_sock_fast+0x29/0x90
[  200.786186]                                          [<c132bdb4>] udp_destroy_sock+0x14/0x40
[  200.786186]                                          [<c12dbdb3>] sk_common_release+0xb3/0xc0
[  200.786186]                                          [<c132c728>] udp_lib_close+0x8/0x10
[  200.786186]                                          [<c133268e>] inet_release+0xbe/0x100
[  200.786186]                                          [<c12d5f66>] sock_release+0x66/0x80
[  200.786186]                                          [<c12d6ce2>] sock_close+0x12/0x30
[  200.786186]                                          [<c10c66fb>] __fput+0x1cb/0x240
[  200.786186]                                          [<c10c6789>] fput+0x19/0x20
[  200.786186]                                          [<c10c45c3>] filp_close+0x43/0x70
[  200.786186]                                          [<c103fded>] close_files+0xad/0x150
[  200.786186]                                          [<c103fef9>] put_files_struct+0x29/0xf0
[  200.786186]                                          [<c1040050>] exit_files+0x40/0x50
[  200.786186]                                          [<c1040716>] do_exit+0x116/0x2e0
[  200.786186]                                          [<c1040944>] do_group_exit+0x34/0xb0
[  200.786186]                                          [<c10409cf>] sys_exit_group+0xf/0x20
[  200.786186]                                          [<c138d4e1>] syscall_call+0x7/0xb
[  200.786186]     IN-SOFTIRQ-W at:
[  200.786186]                                          [<c106abae>] mark_irqflags+0x11e/0x180
[  200.786186]                                          [<c106b90d>] __lock_acquire+0x38d/0x8e0
[  200.786186]                                          [<c106ceaa>] lock_acquire+0x7a/0xa0
[  200.786186]                                          [<c138c8c9>] _raw_spin_lock+0x39/0x70
[  200.786186]                                          [<c12da3f1>] sk_clone+0xb1/0x2c0
[  200.786186]                                          [<c13108ea>] inet_csk_clone+0x1a/0xb0
[  200.786186]                                          [<c1325ecc>] tcp_create_openreq_child+0x1c/0x460
[  200.786186]                                          [<c132359f>] tcp_v4_syn_recv_sock+0x3f/0x1e0
[  200.786186]                                          [<c132649c>] tcp_check_req+0x18c/0x3b0
[  200.786186]                                          [<c132378d>] tcp_v4_hnd_req+0x4d/0x160
[  200.786186]                                          [<c1323ab9>] tcp_v4_do_rcv+0x159/0x280
[  200.786186]                                          [<c1324154>] tcp_v4_rcv+0x574/0xa30
[  200.786186]                                          [<c1305f63>] ip_local_deliver_finish+0x103/0x320
[  200.786186]                                          [<c13061b0>] ip_local_deliver+0x30/0x40
[  200.786186]                                          [<c1306329>] ip_rcv_finish+0x169/0x480
[  200.786186]                                          [<c13067da>] ip_rcv+0x19a/0x2b0
[  200.786186]                                          [<c12e743d>] __netif_receive_skb+0x21d/0x310
[  200.786186]                                          [<c12e7f48>] process_backlog+0x88/0x160
[  200.786186]                                          [<c12e8317>] net_rx_action+0x127/0x140
[  200.786186]                                          [<c1042e90>] __do_softirq+0xd0/0x130
[  200.786186]     INITIAL USE at:
[  200.786186]                                         [<c106b740>] __lock_acquire+0x1c0/0x8e0
[  200.786186]                                         [<c106ceaa>] lock_acquire+0x7a/0xa0
[  200.786186]                                         [<c138ca3e>] _raw_spin_lock_bh+0x3e/0x80
[  200.786186]                                         [<c12dba59>] lock_sock_fast+0x29/0x90
[  200.786186]                                         [<c132bdb4>] udp_destroy_sock+0x14/0x40
[  200.786186]                                         [<c12dbdb3>] sk_common_release+0xb3/0xc0
[  200.786186]                                         [<c132c728>] udp_lib_close+0x8/0x10
[  200.786186]                                         [<c133268e>] inet_release+0xbe/0x100
[  200.786186]                                         [<c12d5f66>] sock_release+0x66/0x80
[  200.786186]                                         [<c12d6ce2>] sock_close+0x12/0x30
[  200.786186]                                         [<c10c66fb>] __fput+0x1cb/0x240
[  200.786186]                                         [<c10c6789>] fput+0x19/0x20
[  200.786186]                                         [<c10c45c3>] filp_close+0x43/0x70
[  200.786186]                                         [<c103fded>] close_files+0xad/0x150
[  200.786186]                                         [<c103fef9>] put_files_struct+0x29/0xf0
[  200.786186]                                         [<c1040050>] exit_files+0x40/0x50
[  200.786186]                                         [<c1040716>] do_exit+0x116/0x2e0
[  200.786186]                                         [<c1040944>] do_group_exit+0x34/0xb0
[  200.786186]                                         [<c10409cf>] sys_exit_group+0xf/0x20
[  200.786186]                                         [<c138d4e1>] syscall_call+0x7/0xb
[  200.786186]   }
[  200.786186]   ... key      at: [<c1d4d9f0>] af_family_slock_keys+0x10/0x140
[  200.786186]   ... acquired at:
[  200.786186]    [<c10693bb>] check_prevs_add+0xab/0x100
[  200.786186]    [<c1069745>] validate_chain+0x305/0x5a0
[  200.786186]    [<c106b82d>] __lock_acquire+0x2ad/0x8e0
[  200.786186]    [<c106ceaa>] lock_acquire+0x7a/0xa0
[  200.786186]    [<c138d07e>] _raw_write_lock_bh+0x3e/0x80
[  200.786186]    [<c1310c16>] inet_csk_listen_stop+0x86/0x160
[  200.786186]    [<c1313772>] tcp_close+0x382/0x390
[  200.786186]    [<c133268e>] inet_release+0xbe/0x100
[  200.786186]    [<c12d5f66>] sock_release+0x66/0x80
[  200.786186]    [<c12d6ce2>] sock_close+0x12/0x30
[  200.786186]    [<c10c66fb>] __fput+0x1cb/0x240
[  200.786186]    [<c10c6789>] fput+0x19/0x20
[  200.786186]    [<c10c45c3>] filp_close+0x43/0x70
[  200.786186]    [<c10c465d>] sys_close+0x6d/0x110
[  200.786186]    [<c138d4e1>] syscall_call+0x7/0xb
[  200.786186] 
[  200.786186] -> (clock-AF_INET){++.?..} ops: 2429 {
[  200.786186]    HARDIRQ-ON-W at:
[  200.786186]                                        [<c106ab8e>] mark_irqflags+0xfe/0x180
[  200.786186]                                        [<c106b90d>] __lock_acquire+0x38d/0x8e0
[  200.786186]                                        [<c106ceaa>] lock_acquire+0x7a/0xa0
[  200.786186]                                        [<c138d07e>] _raw_write_lock_bh+0x3e/0x80
[  200.786186]                                        [<c12dbd2f>] sk_common_release+0x2f/0xc0
[  200.786186]                                        [<c132c728>] udp_lib_close+0x8/0x10
[  200.786186]                                        [<c133268e>] inet_release+0xbe/0x100
[  200.786186]                                        [<c12d5f66>] sock_release+0x66/0x80
[  200.786186]                                        [<c12d6ce2>] sock_close+0x12/0x30
[  200.786186]                                        [<c10c66fb>] __fput+0x1cb/0x240
[  200.786186]                                        [<c10c6789>] fput+0x19/0x20
[  200.786186]                                        [<c10c45c3>] filp_close+0x43/0x70
[  200.786186]                                        [<c103fded>] close_files+0xad/0x150
[  200.786186]                                        [<c103fef9>] put_files_struct+0x29/0xf0
[  200.786186]                                        [<c1040050>] exit_files+0x40/0x50
[  200.786186]                                        [<c1040716>] do_exit+0x116/0x2e0
[  200.786186]                                        [<c1040944>] do_group_exit+0x34/0xb0
[  200.786186]                                        [<c10409cf>] sys_exit_group+0xf/0x20
[  200.786186]                                        [<c138d4e1>] syscall_call+0x7/0xb
[  200.786186]    HARDIRQ-ON-R at:
[  200.786186]                                        [<c106aafe>] mark_irqflags+0x6e/0x180
[  200.786186]                                        [<c106b90d>] __lock_acquire+0x38d/0x8e0
[  200.786186]                                        [<c106ceaa>] lock_acquire+0x7a/0xa0
[  200.786186]                                        [<c138cbe9>] _raw_read_lock+0x39/0x70
[  200.786186]                                        [<c135e9be>] xs_tcp_state_change+0x1e/0x1d0
[  200.786186]                                        [<c131c8a8>] tcp_rcv_synsent_state_process+0x398/0x590
[  200.786186]                                        [<c131cf47>] tcp_rcv_state_process+0x4a7/0x560
[  200.786186]                                        [<c13239d1>] tcp_v4_do_rcv+0x71/0x280
[  200.786186]                                        [<c12dad26>] __release_sock+0x66/0x150
[  200.786186]                                        [<c12dba27>] release_sock+0x87/0x90
[  200.786186]                                        [<c1332a7a>] inet_stream_connect+0x5a/0x1b0
[  200.786186]                                        [<c12d8888>] kernel_connect+0x18/0x30
[  200.786186]                                        [<c135f66e>] xs_tcp_finish_connecting+0x4e/0x120
[  200.786186]                                        [<c135f79b>] xs_tcp_setup_socket+0x5b/0x180
[  200.786186]                                        [<c135f9d4>] xs_tcp_connect_worker4+0x14/0x20
[  200.786186]                                        [<c1051767>] process_one_work+0x147/0x3a0
[  200.786186]                                        [<c1051aa6>] worker_thread+0xa6/0x200
[  200.786186]                                        [<c1056985>] kthread+0x75/0x80
[  200.786186]                                        [<c10031fa>] kernel_thread_helper+0x6/0x1c
[  200.786186]    IN-SOFTIRQ-R at:
[  200.786186]                                        [<c106abae>] mark_irqflags+0x11e/0x180
[  200.786186]                                        [<c106b90d>] __lock_acquire+0x38d/0x8e0
[  200.786186]                                        [<c106ceaa>] lock_acquire+0x7a/0xa0
[  200.786186]                                        [<c138cbe9>] _raw_read_lock+0x39/0x70
[  200.786186]                                        [<c135e891>] xs_tcp_data_ready+0x21/0x90
[  200.786186]                                        [<c131ad68>] tcp_data_queue+0x248/0x820
[  200.786186]                                        [<c131c0de>] tcp_rcv_established+0xae/0x4e0
[  200.786186]                                        [<c1323b31>] tcp_v4_do_rcv+0x1d1/0x280
[  200.786186]                                        [<c1324154>] tcp_v4_rcv+0x574/0xa30
[  200.786186]                                        [<c1305f63>] ip_local_deliver_finish+0x103/0x320
[  200.786186]                                        [<c13061b0>] ip_local_deliver+0x30/0x40
[  200.786186]                                        [<c1306329>] ip_rcv_finish+0x169/0x480
[  200.786186]                                        [<c13067da>] ip_rcv+0x19a/0x2b0
[  200.786186]                                        [<c12e743d>] __netif_receive_skb+0x21d/0x310
[  200.786186]                                        [<c12e7f48>] process_backlog+0x88/0x160
[  200.786186]                                        [<c12e8317>] net_rx_action+0x127/0x140
[  200.786186]                                        [<c1042e90>] __do_softirq+0xd0/0x130
[  200.786186]    SOFTIRQ-ON-R at:
[  200.786186]                                        [<c106ab72>] mark_irqflags+0xe2/0x180
[  200.786186]                                        [<c106b90d>] __lock_acquire+0x38d/0x8e0
[  200.786186]                                        [<c106ceaa>] lock_acquire+0x7a/0xa0
[  200.786186]                                        [<c138cbe9>] _raw_read_lock+0x39/0x70
[  200.786186]                                        [<c135e9be>] xs_tcp_state_change+0x1e/0x1d0
[  200.786186]                                        [<c1333167>] inet_shutdown+0x97/0x110
[  200.786186]                                        [<c12d8a89>] kernel_sock_shutdown+0x9/0x10
[  200.786186]                                        [<c135dcb7>] xs_tcp_shutdown+0x17/0x20
[  200.786186]                                        [<c135dfb7>] xs_tcp_close+0x27/0x30
[  200.786186]                                        [<c135c20d>] xprt_autoclose+0x1d/0x50
[  200.786186]                                        [<c1051767>] process_one_work+0x147/0x3a0
[  200.786186]                                        [<c1051aa6>] worker_thread+0xa6/0x200
[  200.786186]                                        [<c1056985>] kthread+0x75/0x80
[  200.786186]                                        [<c10031fa>] kernel_thread_helper+0x6/0x1c
[  200.786186]    INITIAL USE at:
[  200.786186]                                       [<c106b740>] __lock_acquire+0x1c0/0x8e0
[  200.786186]                                       [<c106ceaa>] lock_acquire+0x7a/0xa0
[  200.786186]                                       [<c138d07e>] _raw_write_lock_bh+0x3e/0x80
[  200.786186]                                       [<c12dbd2f>] sk_common_release+0x2f/0xc0
[  200.786186]                                       [<c132c728>] udp_lib_close+0x8/0x10
[  200.786186]                                       [<c133268e>] inet_release+0xbe/0x100
[  200.786186]                                       [<c12d5f66>] sock_release+0x66/0x80
[  200.786186]                                       [<c12d6ce2>] sock_close+0x12/0x30
[  200.786186]                                       [<c10c66fb>] __fput+0x1cb/0x240
[  200.786186]                                       [<c10c6789>] fput+0x19/0x20
[  200.786186]                                       [<c10c45c3>] filp_close+0x43/0x70
[  200.786186]                                       [<c103fded>] close_files+0xad/0x150
[  200.786186]                                       [<c103fef9>] put_files_struct+0x29/0xf0
[  200.786186]                                       [<c1040050>] exit_files+0x40/0x50
[  200.786186]                                       [<c1040716>] do_exit+0x116/0x2e0
[  200.786186]                                       [<c1040944>] do_group_exit+0x34/0xb0
[  200.786186]                                       [<c10409cf>] sys_exit_group+0xf/0x20
[  200.786186]                                       [<c138d4e1>] syscall_call+0x7/0xb
[  200.786186]  }
[  200.786186]  ... key      at: [<c1d4db30>] af_callback_keys+0x10/0x130
[  200.786186]  ... acquired at:
[  200.786186]    [<c1069ff6>] check_usage_backwards+0x76/0xd0
[  200.786186]    [<c106a209>] mark_lock_irq+0x99/0x240
[  200.786186]    [<c106aeac>] mark_lock+0x21c/0x3c0
[  200.786186]    [<c106ab72>] mark_irqflags+0xe2/0x180
[  200.786186]    [<c106b90d>] __lock_acquire+0x38d/0x8e0
[  200.786186]    [<c106ceaa>] lock_acquire+0x7a/0xa0
[  200.786186]    [<c138cbe9>] _raw_read_lock+0x39/0x70
[  200.786186]    [<c135e9be>] xs_tcp_state_change+0x1e/0x1d0
[  200.786186]    [<c1333167>] inet_shutdown+0x97/0x110
[  200.786186]    [<c12d8a89>] kernel_sock_shutdown+0x9/0x10
[  200.786186]    [<c135dcb7>] xs_tcp_shutdown+0x17/0x20
[  200.786186]    [<c135dfb7>] xs_tcp_close+0x27/0x30
[  200.786186]    [<c135c20d>] xprt_autoclose+0x1d/0x50
[  200.786186]    [<c1051767>] process_one_work+0x147/0x3a0
[  200.786186]    [<c1051aa6>] worker_thread+0xa6/0x200
[  200.786186]    [<c1056985>] kthread+0x75/0x80
[  200.786186]    [<c10031fa>] kernel_thread_helper+0x6/0x1c
[  200.786186] 
[  200.786186] 
[  200.786186] stack backtrace:
[  200.786186] Pid: 10, comm: kworker/0:1 Not tainted 2.6.36-rc5-old #2
[  200.786186] Call Trace:
[  200.786186]  [<c103ded8>] ? printk+0x18/0x20
[  200.786186]  [<c1069e88>] print_irq_inversion_bug+0x108/0x120
[  200.786186]  [<c1069ff6>] check_usage_backwards+0x76/0xd0
[  200.786186]  [<c106a209>] mark_lock_irq+0x99/0x240
[  200.786186]  [<c1069f80>] ? check_usage_backwards+0x0/0xd0
[  200.786186]  [<c106aeac>] mark_lock+0x21c/0x3c0
[  200.786186]  [<c106ab72>] mark_irqflags+0xe2/0x180
[  200.786186]  [<c106b90d>] __lock_acquire+0x38d/0x8e0
[  200.786186]  [<c106cc0a>] ? __lock_is_held+0x3a/0x60
[  200.786186]  [<c106ceaa>] lock_acquire+0x7a/0xa0
[  200.786186]  [<c135e9be>] ? xs_tcp_state_change+0x1e/0x1d0
[  200.786186]  [<c138cbe9>] _raw_read_lock+0x39/0x70
[  200.786186]  [<c135e9be>] ? xs_tcp_state_change+0x1e/0x1d0
[  200.786186]  [<c135e9be>] xs_tcp_state_change+0x1e/0x1d0
[  200.786186]  [<c131fddf>] ? tcp_send_fin+0x4f/0xc0
[  200.786186]  [<c1333167>] inet_shutdown+0x97/0x110
[  200.786186]  [<c12d8a89>] kernel_sock_shutdown+0x9/0x10
[  200.786186]  [<c135dcb7>] xs_tcp_shutdown+0x17/0x20
[  200.786186]  [<c135dfb7>] xs_tcp_close+0x27/0x30
[  200.786186]  [<c135c20d>] xprt_autoclose+0x1d/0x50
[  200.786186]  [<c1051767>] process_one_work+0x147/0x3a0
[  200.786186]  [<c10516f6>] ? process_one_work+0xd6/0x3a0
[  200.786186]  [<c106d429>] ? __lock_acquired+0x119/0x1c0
[  200.786186]  [<c135c1f0>] ? xprt_autoclose+0x0/0x50
[  200.786186]  [<c1051a1c>] ? worker_thread+0x1c/0x200
[  200.786186]  [<c1050537>] ? __need_more_worker+0x17/0x40
[  200.786186]  [<c1051aa6>] worker_thread+0xa6/0x200
[  200.786186]  [<c1056985>] kthread+0x75/0x80
[  200.786186]  [<c1051a00>] ? worker_thread+0x0/0x200
[  200.786186]  [<c1056910>] ? kthread+0x0/0x80
[  200.786186]  [<c10031fa>] kernel_thread_helper+0x6/0x1c
[  208.718821] Restarting system.
[  208.720581] machine restart
