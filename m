From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: mmap()ed AF_NETLINK: lockdep and sleep-in-atomic warnings
Date: Mon, 13 Jul 2015 16:18:25 +0300
Message-ID: <20150713131825.GA16186@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This simple test-case trigers few locking asserts in kernel:

#define _GNU_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <linux/netlink.h>

#define SOL_NETLINK 270

int main(int argc, char **argv)
{
        unsigned int block_size = 16 * 4096;
        struct nl_mmap_req req = {
                .nm_block_size          = block_size,
                .nm_block_nr            = 64,
                .nm_frame_size          = 16384,
                .nm_frame_nr            = 64 * block_size / 16384,
        };
        unsigned int ring_size;
	int fd;

	fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_GENERIC);
        if (setsockopt(fd, SOL_NETLINK, NETLINK_RX_RING, &req, sizeof(req)) < 0)
                exit(1);
        if (setsockopt(fd, SOL_NETLINK, NETLINK_TX_RING, &req, sizeof(req)) < 0)
                exit(1);

	ring_size = req.nm_block_nr * req.nm_block_size;
	mmap(NULL, 2 * ring_size, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	return 0;
}

+++ exited with 0 +++
[    2.500126] BUG: sleeping function called from invalid context at /home/kas/git/public/linux-mm/kernel/locking/mutex.c:616
[    2.501328] in_atomic(): 1, irqs_disabled(): 0, pid: 1, name: init
[    2.501997] 3 locks held by init/1:
[    2.502380]  #0:  (reboot_mutex){+.+...}, at: [<ffffffff81080959>] SyS_reboot+0xa9/0x220
[    2.503328]  #1:  ((reboot_notifier_list).rwsem){.+.+..}, at: [<ffffffff8107f379>] __blocking_notifier_call_chain+0x39/0x70
[    2.504659]  #2:  (rcu_callback){......}, at: [<ffffffff810d32e0>] rcu_do_batch.isra.49+0x160/0x10c0
[    2.505724] Preemption disabled at:[<ffffffff8145365f>] __delay+0xf/0x20
[    2.506443] 
[    2.506612] CPU: 1 PID: 1 Comm: init Not tainted 4.1.0-00009-gbddf4c4818e0 #253
[    2.507378] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS Debian-1.8.2-1 04/01/2014
[    2.508386]  ffff88017b3d8000 ffff88027bc03c38 ffffffff81929ceb 0000000000000102
[    2.509233]  0000000000000000 ffff88027bc03c68 ffffffff81085a9d 0000000000000002
[    2.510057]  ffffffff81ca2a20 0000000000000268 0000000000000000 ffff88027bc03c98
[    2.510882] Call Trace:
[    2.511146]  <IRQ>  [<ffffffff81929ceb>] dump_stack+0x4f/0x7b
[    2.511763]  [<ffffffff81085a9d>] ___might_sleep+0x16d/0x270
[    2.512476]  [<ffffffff81085bed>] __might_sleep+0x4d/0x90
[    2.513071]  [<ffffffff8192e96f>] mutex_lock_nested+0x2f/0x430
[    2.513683]  [<ffffffff81932fed>] ? _raw_spin_unlock_irqrestore+0x5d/0x80
[    2.514385]  [<ffffffff81464143>] ? __this_cpu_preempt_check+0x13/0x20
[    2.515066]  [<ffffffff8182fc3d>] netlink_set_ring+0x1ed/0x350
[    2.515694]  [<ffffffff8182e000>] ? netlink_undo_bind+0x70/0x70
[    2.516411]  [<ffffffff8182fe20>] netlink_sock_destruct+0x80/0x150
[    2.517070]  [<ffffffff817e484d>] __sk_free+0x1d/0x160
[    2.517607]  [<ffffffff817e49a9>] sk_free+0x19/0x20
[    2.518118]  [<ffffffff8182e020>] deferred_put_nlk_sk+0x20/0x30
[    2.518735]  [<ffffffff810d391c>] rcu_do_batch.isra.49+0x79c/0x10c0
[    2.519386]  [<ffffffff810d32e0>] ? rcu_do_batch.isra.49+0x160/0x10c0
[    2.520101]  [<ffffffff810d787b>] rcu_process_callbacks+0xdb/0x6d0
[    2.520790]  [<ffffffff8105dd52>] __do_softirq+0x152/0x630
[    2.521370]  [<ffffffff8105e3be>] irq_exit+0x8e/0xb0
[    2.521895]  [<ffffffff81936366>] smp_apic_timer_interrupt+0x46/0x60
[    2.522558]  [<ffffffff8145365f>] ? __delay+0xf/0x20
[    2.523079]  [<ffffffff81934a00>] apic_timer_interrupt+0x70/0x80
[    2.523705]  <EOI>  [<ffffffff8145365f>] ? __delay+0xf/0x20
[    2.524366]  [<ffffffff810b26ab>] ? in_lock_functions+0x1b/0x20
[    2.524995]  [<ffffffff8108ab81>] get_parent_ip+0x11/0x50
[    2.525562]  [<ffffffff8108ad1f>] preempt_count_sub+0x9f/0xf0
[    2.526179]  [<ffffffff81453778>] delay_tsc+0x68/0xc0
[    2.526706]  [<ffffffff8145365f>] __delay+0xf/0x20
[    2.527207]  [<ffffffff8145369a>] __const_udelay+0x2a/0x30
[    2.527781]  [<ffffffff8172d05a>] md_notify_reboot+0xea/0x100
[    2.528489]  [<ffffffff8107f379>] ? __blocking_notifier_call_chain+0x39/0x70
[    2.529236]  [<ffffffff8107efc6>] notifier_call_chain+0x66/0x90
[    2.529856]  [<ffffffff8107f391>] __blocking_notifier_call_chain+0x51/0x70
[    2.530570]  [<ffffffff810ae8c6>] ? __lock_acquire+0x606/0xf50
[    2.531172]  [<ffffffff8107f3c6>] blocking_notifier_call_chain+0x16/0x20
[    2.531869]  [<ffffffff8108061d>] kernel_restart_prepare+0x1d/0x40
[    2.532593]  [<ffffffff810806e6>] kernel_restart+0x16/0x60
[    2.533183]  [<ffffffff81080a07>] SyS_reboot+0x157/0x220
[    2.533738]  [<ffffffff81010778>] ? __restore_xstate_sig+0xf8/0x720
[    2.534390]  [<ffffffff81464127>] ? debug_smp_processor_id+0x17/0x20
[    2.535051]  [<ffffffff810a836e>] ? put_lock_stats.isra.19+0xe/0x30
[    2.535707]  [<ffffffff81933040>] ? _raw_spin_unlock_irq+0x30/0x60
[    2.536446]  [<ffffffff8108ad2b>] ? preempt_count_sub+0xab/0xf0
[    2.537112]  [<ffffffff81933daa>] ? syscall_return+0x11/0x54
[    2.537709]  [<ffffffff81464143>] ? __this_cpu_preempt_check+0x13/0x20
[    2.538399]  [<ffffffff810abf73>] ? trace_hardirqs_on_caller+0xf3/0x240
[    2.539094]  [<ffffffff81454b98>] ? trace_hardirqs_on_thunk+0x17/0x19
[    2.539764]  [<ffffffff81933b97>] system_call_fastpath+0x12/0x6f
[    2.540523] 
[    2.540695] =================================
[    2.541161] [ INFO: inconsistent lock state ]
[    2.541618] 4.1.0-00009-gbddf4c4818e0 #253 Not tainted
[    2.542154] ---------------------------------
[    2.542610] inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
[    2.543236] init/1 [HC0[0]:SC1[1]:HE1:SE0] takes:
[    2.543729]  (&nlk->pg_vec_lock){+.?.+.}, at: [<ffffffff8182fc3d>] netlink_set_ring+0x1ed/0x350
[    2.544503] {SOFTIRQ-ON-W} state was registered at:
[    2.544503]   [<ffffffff810aedce>] __lock_acquire+0xb0e/0xf50
[    2.544503]   [<ffffffff810afb22>] lock_acquire+0xd2/0x2b0
[    2.544503]   [<ffffffff8192e9b1>] mutex_lock_nested+0x71/0x430
[    2.544503]   [<ffffffff8182fc3d>] netlink_set_ring+0x1ed/0x350
[    2.544503]   [<ffffffff81832010>] netlink_setsockopt+0x1b0/0x300
[    2.544503]   [<ffffffff817e0133>] SyS_setsockopt+0x63/0xc0
[    2.544503]   [<ffffffff81933cbc>] tracesys_phase2+0x84/0x89
[    2.544503] irq event stamp: 1159264
[    2.544503] hardirqs last  enabled at (1159264): [<ffffffff810c3495>] vprintk_emit+0x2c5/0x600
[    2.544503] hardirqs last disabled at (1159263): [<ffffffff810c321e>] vprintk_emit+0x4e/0x600
[    2.544503] softirqs last  enabled at (1159014): [<ffffffff8105de2e>] __do_softirq+0x22e/0x630
[    2.544503] softirqs last disabled at (1159017): [<ffffffff8105e3be>] irq_exit+0x8e/0xb0
[    2.544503] 
[    2.544503] other info that might help us debug this:
[    2.544503]  Possible unsafe locking scenario:
[    2.544503] 
[    2.544503]        CPU0
[    2.544503]        ----
[    2.544503]   lock(&nlk->pg_vec_lock);
[    2.544503]   <Interrupt>
[    2.544503]     lock(&nlk->pg_vec_lock);
[    2.544503] 
[    2.544503]  *** DEADLOCK ***
[    2.544503] 
[    2.544503] 3 locks held by init/1:
[    2.544503]  #0:  (reboot_mutex){+.+...}, at: [<ffffffff81080959>] SyS_reboot+0xa9/0x220
[    2.544503]  #1:  ((reboot_notifier_list).rwsem){.+.+..}, at: [<ffffffff8107f379>] __blocking_notifier_call_chain+0x39/0x70
[    2.544503]  #2:  (rcu_callback){......}, at: [<ffffffff810d32e0>] rcu_do_batch.isra.49+0x160/0x10c0
[    2.544503] 
[    2.544503] stack backtrace:
[    2.544503] CPU: 1 PID: 1 Comm: init Not tainted 4.1.0-00009-gbddf4c4818e0 #253
[    2.544503] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS Debian-1.8.2-1 04/01/2014
[    2.544503]  ffff88017b3d8000 ffff88027bc03af8 ffffffff81929ceb 0000000000000103
[    2.544503]  ffffffff82ad2ed0 ffff88027bc03b38 ffffffff819279f8 0000000000000001
[    2.544503]  ffff88017b3d8810 0000000000000004 0000000000000004 0000000000000006
[    2.544503] Call Trace:
[    2.544503]  <IRQ>  [<ffffffff81929ceb>] dump_stack+0x4f/0x7b
[    2.544503]  [<ffffffff819279f8>] print_usage_bug.part.35+0x281/0x290
[    2.544503]  [<ffffffff810ab89c>] mark_lock+0x22c/0x760
[    2.544503]  [<ffffffff810a97b0>] ? check_usage_backwards+0x150/0x150
[    2.544503]  [<ffffffff810aed77>] __lock_acquire+0xab7/0xf50
[    2.544503]  [<ffffffff810afb22>] lock_acquire+0xd2/0x2b0
[    2.544503]  [<ffffffff8182fc3d>] ? netlink_set_ring+0x1ed/0x350
[    2.544503]  [<ffffffff81085a9d>] ? ___might_sleep+0x16d/0x270
[    2.544503]  [<ffffffff8182fc3d>] ? netlink_set_ring+0x1ed/0x350
[    2.544503]  [<ffffffff8192e9b1>] mutex_lock_nested+0x71/0x430
[    2.544503]  [<ffffffff8182fc3d>] ? netlink_set_ring+0x1ed/0x350
[    2.544503]  [<ffffffff8182fc3d>] ? netlink_set_ring+0x1ed/0x350
[    2.544503]  [<ffffffff81464143>] ? __this_cpu_preempt_check+0x13/0x20
[    2.544503]  [<ffffffff8182fc3d>] netlink_set_ring+0x1ed/0x350
[    2.544503]  [<ffffffff8182e000>] ? netlink_undo_bind+0x70/0x70
[    2.544503]  [<ffffffff8182fe20>] netlink_sock_destruct+0x80/0x150
[    2.544503]  [<ffffffff817e484d>] __sk_free+0x1d/0x160
[    2.544503]  [<ffffffff817e49a9>] sk_free+0x19/0x20
[    2.544503]  [<ffffffff8182e020>] deferred_put_nlk_sk+0x20/0x30
[    2.544503]  [<ffffffff810d391c>] rcu_do_batch.isra.49+0x79c/0x10c0
[    2.544503]  [<ffffffff810d32e0>] ? rcu_do_batch.isra.49+0x160/0x10c0
[    2.544503]  [<ffffffff810d787b>] rcu_process_callbacks+0xdb/0x6d0
[    2.544503]  [<ffffffff8105dd52>] __do_softirq+0x152/0x630
[    2.544503]  [<ffffffff8105e3be>] irq_exit+0x8e/0xb0
[    2.544503]  [<ffffffff81936366>] smp_apic_timer_interrupt+0x46/0x60
[    2.544503]  [<ffffffff8145365f>] ? __delay+0xf/0x20
[    2.544503]  [<ffffffff81934a00>] apic_timer_interrupt+0x70/0x80
[    2.544503]  <EOI>  [<ffffffff8145365f>] ? __delay+0xf/0x20
[    2.544503]  [<ffffffff810b26ab>] ? in_lock_functions+0x1b/0x20
[    2.544503]  [<ffffffff8108ab81>] get_parent_ip+0x11/0x50
[    2.544503]  [<ffffffff8108ad1f>] preempt_count_sub+0x9f/0xf0
[    2.544503]  [<ffffffff81453778>] delay_tsc+0x68/0xc0
[    2.544503]  [<ffffffff8145365f>] __delay+0xf/0x20
[    2.544503]  [<ffffffff8145369a>] __const_udelay+0x2a/0x30
[    2.544503]  [<ffffffff8172d05a>] md_notify_reboot+0xea/0x100
[    2.544503]  [<ffffffff8107f379>] ? __blocking_notifier_call_chain+0x39/0x70
[    2.544503]  [<ffffffff8107efc6>] notifier_call_chain+0x66/0x90
[    2.544503]  [<ffffffff8107f391>] __blocking_notifier_call_chain+0x51/0x70
[    2.544503]  [<ffffffff810ae8c6>] ? __lock_acquire+0x606/0xf50
[    2.544503]  [<ffffffff8107f3c6>] blocking_notifier_call_chain+0x16/0x20
[    2.544503]  [<ffffffff8108061d>] kernel_restart_prepare+0x1d/0x40
[    2.544503]  [<ffffffff810806e6>] kernel_restart+0x16/0x60
[    2.544503]  [<ffffffff81080a07>] SyS_reboot+0x157/0x220
[    2.544503]  [<ffffffff81010778>] ? __restore_xstate_sig+0xf8/0x720
[    2.544503]  [<ffffffff81464127>] ? debug_smp_processor_id+0x17/0x20
[    2.544503]  [<ffffffff810a836e>] ? put_lock_stats.isra.19+0xe/0x30
[    2.544503]  [<ffffffff81933040>] ? _raw_spin_unlock_irq+0x30/0x60
[    2.544503]  [<ffffffff8108ad2b>] ? preempt_count_sub+0xab/0xf0
[    2.544503]  [<ffffffff81933daa>] ? syscall_return+0x11/0x54
[    2.544503]  [<ffffffff81464143>] ? __this_cpu_preempt_check+0x13/0x20
[    2.544503]  [<ffffffff810abf73>] ? trace_hardirqs_on_caller+0xf3/0x240
[    2.544503]  [<ffffffff81454b98>] ? trace_hardirqs_on_thunk+0x17/0x19
[    2.544503]  [<ffffffff81933b97>] system_call_fastpath+0x12/0x6f

-- 
 Kirill A. Shutemov
