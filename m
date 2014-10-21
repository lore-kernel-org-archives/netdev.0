From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RCU stall in af_unix.c, should use spin_lock_irqsave?
Date: Tue, 21 Oct 2014 03:04:34 -0700
Message-ID: <1413885874.23173.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141021100313.397f4962@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexandre FOURNIER <alexandre.fournier@wisp-e.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Gregory =?ISO-8859-1?Q?Cl=E9ment?=
	<gregory.clement@free-electrons.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141021100313.397f4962@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-10-21 at 10:03 +0200, Thomas Petazzoni wrote:
> Hello,
> 
> I stumbled across a reproducible RCU stall related to the AF_UNIX code
> (on 3.17, on an ARM SMP system), and I'm not sure whether the problem
> is caused by:
> 
>  * The af_unix.c code using spin_lock() on sk->sk_receive_queue.lock
>    while it should be using spin_lock_irqsave().
> 
> OR
> 
>  * The mvpp2 Ethernet driver using on_each_cpu() in a softirq context.
> 
> At least, switching to use spin_lock_irqsave() instead of spin_lock()
> has proven to fix the issue (see patch below). The spinlock validator
> complains that a lockup has been detected, which might indicate that
> something is indeed wrong with the spinlock handling.
> 
> Now, to the gory details. When stress-testing a lighttpd web server
> that does a lot of CGI calls and therefore a lot of Unix socket
> traffic, I get typically after couple of minutes the following RCU
> stall:
> 
> INFO: rcu_sched self-detected stall on CPU { 0}  (t=2100 jiffies g=14665 c=14664 q=1352)
> Task dump for CPU 0:
> lighttpd        R running      0  1549      1 0x00000002
> [<c0014f94>] (unwind_backtrace) from [<c001130c>] (show_stack+0x10/0x14)
> [<c001130c>] (show_stack) from [<c0059688>] (rcu_dump_cpu_stacks+0x98/0xd4)
> [<c0059688>] (rcu_dump_cpu_stacks) from [<c005c3ec>] (rcu_check_callbacks+0x424/0x740)
> [<c005c3ec>] (rcu_check_callbacks) from [<c005e7c8>] (update_process_times+0x40/0x60)
> [<c005e7c8>] (update_process_times) from [<c006ce70>] (tick_sched_timer+0x70/0x210)
> [<c006ce70>] (tick_sched_timer) from [<c005efc4>] (__run_hrtimer.isra.35+0x6c/0x128)
> [<c005efc4>] (__run_hrtimer.isra.35) from [<c005f600>] (hrtimer_interrupt+0x11c/0x2d0)
> [<c005f600>] (hrtimer_interrupt) from [<c00148f8>] (twd_handler+0x34/0x44)
> [<c00148f8>] (twd_handler) from [<c00557ec>] (handle_percpu_devid_irq+0x6c/0x84)
> [<c00557ec>] (handle_percpu_devid_irq) from [<c0051c80>] (generic_handle_irq+0x2c/0x3c)
> [<c0051c80>] (generic_handle_irq) from [<c000eafc>] (handle_IRQ+0x40/0x90)
> [<c000eafc>] (handle_IRQ) from [<c00086d0>] (gic_handle_irq+0x2c/0x5c)
> [<c00086d0>] (gic_handle_irq) from [<c0011e40>] (__irq_svc+0x40/0x54)
> Exception stack(0xde0c1ce8 to 0xde0c1d30)
> 1ce0:                   c073a684 20010113 c06e30fc 00000003 de0c1d30 00000001
> 1d00: 00000001 0000012c dfbdcc40 ffffe70c dfbdcc48 df5bd800 00000002 de0c1d30
> 1d20: c00712d4 c00712bc 20010113 ffffffff
> [<c0011e40>] (__irq_svc) from [<c00712bc>] (generic_exec_single+0x10c/0x180)
> [<c00712bc>] (generic_exec_single) from [<c00713d0>] (smp_call_function_single+0xa0/0xcc)
> [<c00713d0>] (smp_call_function_single) from [<c0071818>] (on_each_cpu+0x2c/0x48)
> [<c0071818>] (on_each_cpu) from [<c03312dc>] (mvpp2_poll+0x30/0x594)
> [<c03312dc>] (mvpp2_poll) from [<c041d024>] (net_rx_action+0xb0/0x170)
> [<c041d024>] (net_rx_action) from [<c00220c4>] (__do_softirq+0x120/0x274)
> [<c00220c4>] (__do_softirq) from [<c0022468>] (irq_exit+0x78/0xb0)
> [<c0022468>] (irq_exit) from [<c000eb00>] (handle_IRQ+0x44/0x90)
> [<c000eb00>] (handle_IRQ) from [<c00086d0>] (gic_handle_irq+0x2c/0x5c)
> [<c00086d0>] (gic_handle_irq) from [<c0011e40>] (__irq_svc+0x40/0x54)
> Exception stack(0xde0c1eb8 to 0xde0c1f00)
> 1ea0:                                                       de1b986c 00000000
> 1ec0: 00000420 de1b986c de1b9800 d761c080 be913a34 be913a34 00000007 de0c0000
> 1ee0: d761c0a0 be913a34 00000010 de0c1f00 c0491898 c0491918 60010013 ffffffff
> [<c0011e40>] (__irq_svc) from [<c0491918>] (unix_inq_len+0x9c/0xa8)
> [<c0491918>] (unix_inq_len) from [<c049194c>] (unix_ioctl+0x28/0x88)
> [<c049194c>] (unix_ioctl) from [<c0407ccc>] (sock_ioctl+0x124/0x280)
> [<c0407ccc>] (sock_ioctl) from [<c00c11bc>] (do_vfs_ioctl+0x3fc/0x5c0)
> [<c00c11bc>] (do_vfs_ioctl) from [<c00c13b4>] (SyS_ioctl+0x34/0x5c)
> [<c00c13b4>] (SyS_ioctl) from [<c000e220>] (ret_fast_syscall+0x0/0x30)
> Task dump for CPU 1:
> kiplink_admin.f R running      0  1932   1549 0x00000000
> [<c0513a04>] (__schedule) from [<00000007>] (0x7)
> 
> If my analysis is correct, what happens on CPU0 is that:
> 
>  * lighttpd does an ioctl() on a socket, which ends up calling
>    unix_inq_len(), which tries to get a spinlock using spin_lock(). The
>    lock is probably taken.
> 
>  * while waiting for this lock, we get a network RX interrupt, which
>    schedules the network RX softirq, which ends up calling the ->poll()
>    function of the network driver, in our case mvpp2_poll().
> 
>  * since the network hardware has some per-CPU registers that we need
>    to read on all CPUs, the network driver does a on_each_cpu() call.
>    This apparently leads nowhere, as after a while, the timer interrupt
>    kicks in and decides we're not making progress anymore.
> 
> After enabling spinlock debugging, I get the following right before the
> RCU stall (note how the RCU stall happens on CPU0, while the spinlock
> lockup suspected happens on CPU1) :
> 
> BUG: spinlock lockup suspected on CPU#1, kiplink_admin.f/1938
>  lock: 0xde4998c0, .magic: dead4ead, .owner: lighttpd/1910, .owner_cpu: 0
> CPU: 1 PID: 1938 Comm: kiplink_admin.f Tainted: G        W  O   3.17.0-00017-g53fa061 #2
> [<c00154d8>] (unwind_backtrace) from [<c001183c>] (show_stack+0x10/0x14)
> [<c001183c>] (show_stack) from [<c053f560>] (dump_stack+0x9c/0xbc)
> [<c053f560>] (dump_stack) from [<c0057338>] (do_raw_spin_lock+0x118/0x18c)
> [<c0057338>] (do_raw_spin_lock) from [<c05466fc>] (_raw_spin_lock_irqsave+0x60/0x6c)
> [<c05466fc>] (_raw_spin_lock_irqsave) from [<c042a7d4>] (skb_queue_tail+0x18/0x48)
> [<c042a7d4>] (skb_queue_tail) from [<c04b9f58>] (unix_stream_sendmsg+0x1c8/0x36c)
> [<c04b9f58>] (unix_stream_sendmsg) from [<c0422eb8>] (sock_aio_write+0xcc/0xec)
> [<c0422eb8>] (sock_aio_write) from [<c00bf414>] (do_sync_write+0x80/0xa8)
> [<c00bf414>] (do_sync_write) from [<c00bfe60>] (vfs_write+0x108/0x1b0)
> [<c00bfe60>] (vfs_write) from [<c00c0418>] (SyS_write+0x40/0x94)
> [<c00c0418>] (SyS_write) from [<c000e3a0>] (ret_fast_syscall+0x0/0x48)
> 
> And interestingly, skb_queue_tail() is also taking the same spinlock as
> unix_inq_len(), except that it does so with spin_lock_irqsave(). And
> this is causing the issue: since this spin_lock_irqsave() takes place
> on CPU1, the interupts are disabled, and therefore we're not getting
> the IPI that allows the on_each_cpu() call coming from CPU0 to make
> progress, causing the lockup.
> 
> The patch below has proven to fix the issue: I was able to reproduce
> the issue in maximum 5 to 10 minutes, and with the patch the system has
> survived an entire night of testing.
> 
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index e968843..c60205a 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -2124,11 +2124,12 @@ long unix_inq_len(struct sock *sk)
>  {
>         struct sk_buff *skb;
>         long amount = 0;
> +       unsigned long flags;
>  
>         if (sk->sk_state == TCP_LISTEN)
>                 return -EINVAL;
>  
> -       spin_lock(&sk->sk_receive_queue.lock);
> +       spin_lock_irqsave(&sk->sk_receive_queue.lock, flags);
>         if (sk->sk_type == SOCK_STREAM ||
>             sk->sk_type == SOCK_SEQPACKET) {
>                 skb_queue_walk(&sk->sk_receive_queue, skb)
> @@ -2138,7 +2139,7 @@ long unix_inq_len(struct sock *sk)
>                 if (skb)
>                         amount = skb->len;
>         }
> -       spin_unlock(&sk->sk_receive_queue.lock);
> +       spin_unlock_irqrestore(&sk->sk_receive_queue.lock, flags);
>  
>         return amount;
>  }
> 
> So, the question is: is this patch the correct solution (but then other
> usage of spin_lock in af_unix.c might also need fixing) ? Or is the
> network driver at fault?
> 
> Thanks for your input,
> 
> Thomas

Locks in af_unix do not need to mask irqs. Ever.

skb_queue_tail() uses an irqsave variant because its a generic function,
and _some_ skb list might be manipulated from hard irq handlers in pre
NAPI drivers. But af_unix does not have an interrupt handler that could
potentially try to lock sk_receive_queue.lock

mvpp2 is seriously brain damaged : on_each_cpu() cannot be used from
a bottom half handler.
