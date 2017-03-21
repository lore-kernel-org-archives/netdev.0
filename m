From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: run_timer_softirq gpf. [smc]
Date: Tue, 21 Mar 2017 22:45:18 +0100 (CET)
Message-ID: <alpine.DEB.2.20.1703212228090.3776@nanos>
References: <20170321181710.5hoxel4ss4z55xew@codemonkey.org.uk> <alpine.DEB.2.20.1703211954170.3776@nanos> <20170321201452.l7iqcwopwcq22h35@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        netdev@vger.kernel.org
To: Dave Jones <davej@codemonkey.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170321201452.l7iqcwopwcq22h35@codemonkey.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 21 Mar 2017, Dave Jones wrote:
> On Tue, Mar 21, 2017 at 08:25:39PM +0100, Thomas Gleixner wrote:
>  
>  > > I just hit this while fuzzing..
>  > > 
>  > > general protection fault: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
>  > > CPU: 2 PID: 0 Comm: swapper/2 Not tainted 4.11.0-rc2-think+ #1 
>  > > task: ffff88017f0ed440 task.stack: ffffc90000094000
>  > > RIP: 0010:run_timer_softirq+0x15f/0x700
>  > > RSP: 0018:ffff880507c03ec8 EFLAGS: 00010086
>  > > RAX: dead000000000200 RBX: ffff880507dd0d00 RCX: 0000000000000002
>  > > RDX: ffff880507c03ed0 RSI: 00000000ffffffff RDI: ffffffff8204b3a0
>  > > RBP: ffff880507c03f48 R08: ffff880507dd12d0 R09: ffff880507c03ed8
>  > > R10: ffff880507dd0db0 R11: 0000000000000000 R12: ffffffff8215cc38
>  > > R13: ffff880507c03ed0 R14: ffffffff82005188 R15: ffff8804b55491a8
>  > > FS:  0000000000000000(0000) GS:ffff880507c00000(0000) knlGS:0000000000000000
>  > > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>  > > CR2: 0000000000000004 CR3: 0000000005011000 CR4: 00000000001406e0
>  > > Call Trace:
>  > >  <IRQ>
>  > >  ? clockevents_program_event+0x47/0x120
>  > >  __do_softirq+0xbf/0x5b1
>  > >  irq_exit+0xb5/0xc0
>  > >  smp_apic_timer_interrupt+0x3d/0x50
>  > >  apic_timer_interrupt+0x97/0xa0
>  > > RIP: 0010:cpuidle_enter_state+0x12e/0x400
>  > > RSP: 0018:ffffc90000097e40 EFLAGS: 00000202
>  > > [CONT START]  ORIG_RAX: ffffffffffffff10
>  > > RAX: ffff88017f0ed440 RBX: ffffe8ffffa03cc8 RCX: 0000000000000001
>  > > RDX: 20c49ba5e353f7cf RSI: 0000000000000001 RDI: ffff88017f0ed440
>  > > RBP: ffffc90000097e80 R08: 00000000ffffffff R09: 0000000000000008
>  > > R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000005
>  > > R13: ffffffff820b9338 R14: 0000000000000005 R15: ffffffff820b9320
>  > >  </IRQ>
>  > >  cpuidle_enter+0x17/0x20
>  > >  call_cpuidle+0x23/0x40
>  > >  do_idle+0xfb/0x200
>  > >  cpu_startup_entry+0x71/0x80
>  > >  start_secondary+0x16a/0x210
>  > >  start_cpu+0x14/0x14
>  > > Code: 8b 05 ce 1b ef 7e 83 f8 03 0f 87 4e 01 00 00 89 c0 49 0f a3 04 24 0f 82 0a 01 00 00 49 8b 07 49 8b 57 08 48 85 c0 48 89 02 74 04 <48> 89 50 08 41 f6 47 2a 20 49 c7 47 08 00 00 00 00 48 89 df 48 
>  > 
>  > The timer which expires has timer->entry.next == POISON2 !
>  > 
>  > it's a classic list corruption.  The
>  > bad news is that there is no trace of the culprit because that happens when
>  > some other timer expires after some random amount of time.
>  > 
>  > If that is reproducible, then please enable debugobjects. That should
>  > pinpoint the culprit.
> 
> It's net/smc.  This recently had a similar bug with workqueues. 
> (https://marc.info/?l=linux-kernel&m=148821582909541) fixed by
> 637fdbae60d6cb9f6e963c1079d7e0445c86ff7d

Fixed? It's not fixed by that commit. The workqueue code merily got a new
WARN_ON_ONCE(). But the underlying problem is still unfixed in net/smc

> so it's probably unsurprising that there are similar issues.

That one is related to workqueues:

> WARNING: CPU: 0 PID: 2430 at lib/debugobjects.c:289 debug_print_object+0x87/0xb0
> ODEBUG: free active (active state 0) object type: timer_list hint: delayed_work_timer_fn+0x0/0x20

delayed_work_timer_fn() is what queues the work once the timer expires.

> CPU: 0 PID: 2430 Comm: trinity-c4 Not tainted 4.11.0-rc3-think+ #3 
> Call Trace:
>  dump_stack+0x68/0x93
>  __warn+0xcb/0xf0
>  warn_slowpath_fmt+0x5f/0x80
>  ? debug_check_no_obj_freed+0xd9/0x260
>  debug_print_object+0x87/0xb0
>  ? work_on_cpu+0xd0/0xd0
>  debug_check_no_obj_freed+0x219/0x260
>  ? __sk_destruct+0x10d/0x1c0
>  kmem_cache_free+0x9f/0x370
>  __sk_destruct+0x10d/0x1c0
>  sk_destruct+0x20/0x30
>  __sk_free+0x43/0xa0
>  sk_free+0x18/0x20

smc_release does at the end of the function:

        if (smc->use_fallback) {
                schedule_delayed_work(&smc->sock_put_work, TCP_TIMEWAIT_LEN);
        } else if (sk->sk_state == SMC_CLOSED) {
                smc_conn_free(&smc->conn);
                schedule_delayed_work(&smc->sock_put_work,
                                      SMC_CLOSE_SOCK_PUT_DELAY);
        }
        sk->sk_prot->unhash(sk);
        release_sock(sk);

        sock_put(sk);

sock_put(sk)
{
        if (atomic_dec_and_test(&sk->sk_refcnt))
                sk_free(sk);
}

That means either smc_release() queued delayed work or it was already
queued.

But in neither case it holds an extra refcount on sk. Otherwise sock_put()
would not end up in sk_free().

Thanks,

	tglx
