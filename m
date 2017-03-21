From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: run_timer_softirq gpf. [smc]
Date: Tue, 21 Mar 2017 16:14:52 -0400
Message-ID: <20170321201452.l7iqcwopwcq22h35@codemonkey.org.uk>
References: <20170321181710.5hoxel4ss4z55xew@codemonkey.org.uk>
 <alpine.DEB.2.20.1703211954170.3776@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        netdev@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1703211954170.3776@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 21, 2017 at 08:25:39PM +0100, Thomas Gleixner wrote:
 
 > > I just hit this while fuzzing..
 > > 
 > > general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
 > > CPU: 2 PID: 0 Comm: swapper/2 Not tainted 4.11.0-rc2-think+ #1 
 > > task: ffff88017f0ed440 task.stack: ffffc90000094000
 > > RIP: 0010:run_timer_softirq+0x15f/0x700
 > > RSP: 0018:ffff880507c03ec8 EFLAGS: 00010086
 > > RAX: dead000000000200 RBX: ffff880507dd0d00 RCX: 0000000000000002
 > > RDX: ffff880507c03ed0 RSI: 00000000ffffffff RDI: ffffffff8204b3a0
 > > RBP: ffff880507c03f48 R08: ffff880507dd12d0 R09: ffff880507c03ed8
 > > R10: ffff880507dd0db0 R11: 0000000000000000 R12: ffffffff8215cc38
 > > R13: ffff880507c03ed0 R14: ffffffff82005188 R15: ffff8804b55491a8
 > > FS:  0000000000000000(0000) GS:ffff880507c00000(0000) knlGS:0000000000000000
 > > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
 > > CR2: 0000000000000004 CR3: 0000000005011000 CR4: 00000000001406e0
 > > Call Trace:
 > >  <IRQ>
 > >  ? clockevents_program_event+0x47/0x120
 > >  __do_softirq+0xbf/0x5b1
 > >  irq_exit+0xb5/0xc0
 > >  smp_apic_timer_interrupt+0x3d/0x50
 > >  apic_timer_interrupt+0x97/0xa0
 > > RIP: 0010:cpuidle_enter_state+0x12e/0x400
 > > RSP: 0018:ffffc90000097e40 EFLAGS: 00000202
 > > [CONT START]  ORIG_RAX: ffffffffffffff10
 > > RAX: ffff88017f0ed440 RBX: ffffe8ffffa03cc8 RCX: 0000000000000001
 > > RDX: 20c49ba5e353f7cf RSI: 0000000000000001 RDI: ffff88017f0ed440
 > > RBP: ffffc90000097e80 R08: 00000000ffffffff R09: 0000000000000008
 > > R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000005
 > > R13: ffffffff820b9338 R14: 0000000000000005 R15: ffffffff820b9320
 > >  </IRQ>
 > >  cpuidle_enter+0x17/0x20
 > >  call_cpuidle+0x23/0x40
 > >  do_idle+0xfb/0x200
 > >  cpu_startup_entry+0x71/0x80
 > >  start_secondary+0x16a/0x210
 > >  start_cpu+0x14/0x14
 > > Code: 8b 05 ce 1b ef 7e 83 f8 03 0f 87 4e 01 00 00 89 c0 49 0f a3 04 24 0f 82 0a 01 00 00 49 8b 07 49 8b 57 08 48 85 c0 48 89 02 74 04 <48> 89 50 08 41 f6 47 2a 20 49 c7 47 08 00 00 00 00 48 89 df 48 
 > 
 > The timer which expires has timer->entry.next == POISON2 !
 > 
 > it's a classic list corruption.  The
 > bad news is that there is no trace of the culprit because that happens when
 > some other timer expires after some random amount of time.
 > 
 > If that is reproducible, then please enable debugobjects. That should
 > pinpoint the culprit.

It's net/smc.  This recently had a similar bug with workqueues. 
(https://marc.info/?l=linux-kernel&m=148821582909541) fixed by 637fdbae60d6cb9f6e963c1079d7e0445c86ff7d
so it's probably unsurprising that there are similar issues.


WARNING: CPU: 0 PID: 2430 at lib/debugobjects.c:289 debug_print_object+0x87/0xb0
ODEBUG: free active (active state 0) object type: timer_list hint: delayed_work_timer_fn+0x0/0x20
CPU: 0 PID: 2430 Comm: trinity-c4 Not tainted 4.11.0-rc3-think+ #3 
Call Trace:
 dump_stack+0x68/0x93
 __warn+0xcb/0xf0
 warn_slowpath_fmt+0x5f/0x80
 ? debug_check_no_obj_freed+0xd9/0x260
 debug_print_object+0x87/0xb0
 ? work_on_cpu+0xd0/0xd0
 debug_check_no_obj_freed+0x219/0x260
 ? __sk_destruct+0x10d/0x1c0
 kmem_cache_free+0x9f/0x370
 __sk_destruct+0x10d/0x1c0
 sk_destruct+0x20/0x30
 __sk_free+0x43/0xa0
 sk_free+0x18/0x20
 smc_release+0x100/0x1a0 [smc]
 sock_release+0x1f/0x80
 sock_close+0x12/0x20
 __fput+0xf3/0x200
 ____fput+0xe/0x10
 task_work_run+0x85/0xb0
 do_exit+0x331/0xd70
 __secure_computing+0x9c/0xa0
 syscall_trace_enter+0xd1/0x3d0
 do_syscall_64+0x15f/0x1d0
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x7f535f4b19e7
RSP: 002b:00007fff1a0f40e8 EFLAGS: 00000246
 ORIG_RAX: 0000000000000008
RAX: ffffffffffffffda RBX: 0000000000000004 RCX: 00007f535f4b19e7
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000004
RBP: 0000000000000000 R08: 00007f535fb8b000 R09: 00c17c2740a303e4
R10: 0000000000000000 R11: 0000000000000246 R12: 00007fff1a0f40f5
R13: 00007f535fb60048 R14: 00007f535fb83ad8 R15: 00007f535fb60000
---[ end trace ee67155de15508db ]---

======================================================
[ INFO: possible circular locking dependency detected ]
4.11.0-rc3-think+ #3 Not tainted
-------------------------------------------------------
trinity-c4/2430 is trying to acquire lock:
 (
(console_sem).lock
){-.-...}
, at: [<ffffffff810e6be4>] down_trylock+0x14/0x40

but task is already holding lock:
 (
&obj_hash[i].lock
){-.-.-.}
, at: [<ffffffff81515689>] debug_check_no_obj_freed+0xd9/0x260

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #3
 (
&obj_hash[i].lock
){-.-.-.}
:
       lock_acquire+0x102/0x260
       _raw_spin_lock_irqsave+0x4c/0x90
       __debug_object_init+0x79/0x460
       debug_object_init+0x16/0x20
       hrtimer_init+0x25/0x1d0
       init_dl_task_timer+0x20/0x30
       __sched_fork.isra.91+0x9c/0x140
       init_idle+0x51/0x240
       sched_init+0x4cd/0x547
       start_kernel+0x246/0x45d
       x86_64_start_reservations+0x2a/0x2c
       x86_64_start_kernel+0x178/0x18b
       verify_cpu+0x0/0xf1

-> #2
 (
&rq->lock
){-.-.-.}
:
       lock_acquire+0x102/0x260
       _raw_spin_lock+0x41/0x80
       task_fork_fair+0x3a/0x100
       sched_fork+0x12b/0x2e0
       copy_process.part.39+0x65b/0x2080
       _do_fork+0xf6/0x770
       kernel_thread+0x29/0x30
       rest_init+0x22/0x140
       start_kernel+0x43c/0x45d
       x86_64_start_reservations+0x2a/0x2c
       x86_64_start_kernel+0x178/0x18b
       verify_cpu+0x0/0xf1

-> #1
 (
&p->pi_lock
){-.-.-.}
:
       lock_acquire+0x102/0x260
       _raw_spin_lock_irqsave+0x4c/0x90
       try_to_wake_up+0x40/0x6e0
       wake_up_process+0x15/0x20
       __up.isra.0+0x4c/0x50
       up+0x46/0x50
       __up_console_sem+0x37/0x60
       console_unlock+0x275/0x5e0
       do_con_write.part.22+0x761/0xa20
       con_write+0x5c/0x60
       n_tty_write+0x1bf/0x490
       tty_write+0x1b3/0x320
       redirected_tty_write+0x92/0xb0
       __do_readv_writev+0x2e5/0x380
       do_readv_writev+0x7c/0xc0
       vfs_writev+0x3f/0x50
       do_writev+0x64/0x100
       SyS_writev+0x10/0x20
       do_syscall_64+0x66/0x1d0
       return_from_SYSCALL_64+0x0/0x7a

-> #0
 (
(console_sem).lock
){-.-...}
:
       __lock_acquire+0x1134/0x12b0
       lock_acquire+0x102/0x260
       _raw_spin_lock_irqsave+0x4c/0x90
       down_trylock+0x14/0x40
       __down_trylock_console_sem+0x2f/0xa0
       console_trylock+0x16/0x90
       vprintk_emit+0x2ac/0x390
       vprintk_default+0x29/0x50
       vprintk_func+0x25/0x80
       printk+0x52/0x6e
       __warn+0x39/0xf0
       warn_slowpath_fmt+0x5f/0x80
       debug_print_object+0x87/0xb0
       debug_check_no_obj_freed+0x219/0x260
       kmem_cache_free+0x9f/0x370
       __sk_destruct+0x10d/0x1c0
       sk_destruct+0x20/0x30
       __sk_free+0x43/0xa0
       sk_free+0x18/0x20
       smc_release+0x100/0x1a0 [smc]
       sock_release+0x1f/0x80
       sock_close+0x12/0x20
       __fput+0xf3/0x200
       ____fput+0xe/0x10
       task_work_run+0x85/0xb0
       do_exit+0x331/0xd70
       __secure_computing+0x9c/0xa0
       syscall_trace_enter+0xd1/0x3d0
       do_syscall_64+0x15f/0x1d0
       return_from_SYSCALL_64+0x0/0x7a

other info that might help us debug this:

Chain exists of:
  
(console_sem).lock
 --> 
&rq->lock
 --> 
&obj_hash[i].lock

 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(
&obj_hash[i].lock
);
                               lock(
&rq->lock
);
                               lock(
&obj_hash[i].lock
);
  lock(
(console_sem).lock
);

 *** DEADLOCK ***

1 lock held by trinity-c4/2430:
 #0: 
 (
&obj_hash[i].lock
){-.-.-.}
, at: [<ffffffff81515689>] debug_check_no_obj_freed+0xd9/0x260

stack backtrace:
CPU: 0 PID: 2430 Comm: trinity-c4 Not tainted 4.11.0-rc3-think+ #3 
Call Trace:
 dump_stack+0x68/0x93
 print_circular_bug+0x1be/0x210
 __lock_acquire+0x1134/0x12b0
 lock_acquire+0x102/0x260
 ? down_trylock+0x14/0x40
 _raw_spin_lock_irqsave+0x4c/0x90
 ? down_trylock+0x14/0x40
 ? vprintk_emit+0x2ac/0x390
 down_trylock+0x14/0x40
 __down_trylock_console_sem+0x2f/0xa0
 console_trylock+0x16/0x90
 ? trace_hardirqs_off+0xd/0x10
 vprintk_emit+0x2ac/0x390
 ? debug_print_object+0x87/0xb0
 vprintk_default+0x29/0x50
 vprintk_func+0x25/0x80
 ? unwind_next_frame+0x93/0x240
 printk+0x52/0x6e
 ? debug_print_object+0x87/0xb0
 __warn+0x39/0xf0
 warn_slowpath_fmt+0x5f/0x80
 ? debug_check_no_obj_freed+0xd9/0x260
 debug_print_object+0x87/0xb0
 ? work_on_cpu+0xd0/0xd0
 debug_check_no_obj_freed+0x219/0x260
 ? __sk_destruct+0x10d/0x1c0
 kmem_cache_free+0x9f/0x370
 __sk_destruct+0x10d/0x1c0
 sk_destruct+0x20/0x30
 __sk_free+0x43/0xa0
 sk_free+0x18/0x20
 smc_release+0x100/0x1a0 [smc]
 sock_release+0x1f/0x80
 sock_close+0x12/0x20
 __fput+0xf3/0x200
 ____fput+0xe/0x10
 task_work_run+0x85/0xb0
 do_exit+0x331/0xd70
 __secure_computing+0x9c/0xa0
 syscall_trace_enter+0xd1/0x3d0
 do_syscall_64+0x15f/0x1d0
 entry_SYSCALL64_slow_path+0x25/0x25
RIP: 0033:0x7f535f4b19e7
RSP: 002b:00007fff1a0f40e8 EFLAGS: 00000246
 ORIG_RAX: 0000000000000008
RAX: ffffffffffffffda RBX: 0000000000000004 RCX: 00007f535f4b19e7
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000004
RBP: 0000000000000000 R08: 00007f535fb8b000 R09: 00c17c2740a303e4
R10: 0000000000000000 R11: 0000000000000246 R12: 00007fff1a0f40f5
R13: 00007f535fb60048 R14: 00007f535fb83ad8 R15: 00007f535fb60000
