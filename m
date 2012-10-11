From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 qfq_dequeue()
Date: Thu, 11 Oct 2012 17:05:08 +0200
Message-ID: <1349967908.21172.9459.camel@edumazet-glaptop>
References: <1349687756.2707.21.camel@cr0>  <1349944709.3412.2.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: stephen hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@redhat.com>, rizzo@iet.unipi.it
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44829 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755823Ab2JKPFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 11:05:14 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1047208bkc.19
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 08:05:12 -0700 (PDT)
In-Reply-To: <1349944709.3412.2.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-11 at 16:38 +0800, Cong Wang wrote:
> On Mon, 2012-10-08 at 17:15 +0800, Cong Wang wrote:
> > Hi, all,
> > 
> > We got the following kernel crash on RHEL6 and I confirmed upstream has
> > the same problem (I didn't save this kernel log though):
> 
> Ok, I got the backtrace of the latest kernel, see below. Seems
> qfq_slot_scan() in qfq_dequeue() returns something bad, 'cl' becomes
> '0x10'.

not exactly, cl is -0x50

> 
> (gdb) bt
> #0  delay_tsc (__loops=<optimized out>) at arch/x86/lib/delay.c:69
> #1  0xffffffff8143f4c9 in __delay (loops=<optimized out>) at
> arch/x86/lib/delay.c:112
> #2  0xffffffff8143f4ef in __const_udelay (xloops=<optimized out>) at
> arch/x86/lib/delay.c:126
> #3  0xffffffff81914536 in panic (fmt=<optimized out>) at
> kernel/panic.c:182
> #4  0xffffffff8193de42 in oops_end (flags=582, regs=0xffff88007d203d08,
> signr=9) at arch/x86/kernel/dumpstack.c:248
> #5  0xffffffff81913698 in no_context (regs=0xffff88007d203d08,
> error_code=<optimized out>, address=16, signal=<optimized out>, 
>     si_code=<optimized out>) at arch/x86/mm/fault.c:690
> #6  0xffffffff81913885 in __bad_area_nosemaphore
> (regs=0xffff88007d203d08, error_code=0, address=16, si_code=196609)
>     at arch/x86/mm/fault.c:768
> #7  0xffffffff819138b9 in bad_area_nosemaphore (regs=<optimized out>,
> error_code=<optimized out>, address=<optimized out>)
>     at arch/x86/mm/fault.c:775
> #8  0xffffffff81940803 in __do_page_fault (regs=0xffff88007d203d08,
> error_code=0) at arch/x86/mm/fault.c:1105
> #9  0xffffffff81940883 in do_page_fault (regs=<optimized out>,
> error_code=<optimized out>) at arch/x86/mm/fault.c:1237
> #10 0xffffffff81940129 in do_async_page_fault (regs=<optimized out>,
> error_code=<optimized out>) at arch/x86/kernel/kvm.c:246
> #11 <signal handler called>
> #12 0xffffffff8176c72c in qfq_round_down (shift=41, ts=Cannot access
> memory at address 0x10
> ) at net/sched/sch_qfq.c:575
> #13 qfq_dequeue (sch=0xffff8800757542c0) at net/sched/sch_qfq.c:819
> #14 0xffffffff8175c0cb in cbq_dequeue_prio (prio=1,
> sch=0xffff880076b15d00) at net/sched/sch_cbq.c:851
> #15 cbq_dequeue_1 (sch=0xffff880076b15d00) at net/sched/sch_cbq.c:934
> #16 cbq_dequeue (sch=0xffff880076b15d00) at net/sched/sch_cbq.c:973
> #17 0xffffffff81750ff7 in dequeue_skb (q=0xffff880076b15d00) at
> net/sched/sch_generic.c:69
> #18 qdisc_restart (q=0xffff880076b15d00) at net/sched/sch_generic.c:178
> #19 __qdisc_run (q=0xffff880076b15d00) at net/sched/sch_generic.c:193
> #20 0xffffffff81725625 in qdisc_run (q=0xffff880076b15d00) at
> include/net/pkt_sched.h:99
> #21 net_tx_action (h=<optimized out>) at net/core/dev.c:3070
> #22 0xffffffff81057069 in __do_softirq () at kernel/softirq.c:247
> #23 0xffffffff81945b3c in ?? () at arch/x86/kernel/entry_64.S:1353
> #24 0xffffffff81003f36 in do_softirq () at arch/x86/kernel/irq_64.c:106
> #25 0xffffffff810572f8 in invoke_softirq () at kernel/softirq.c:329
> #26 irq_exit () at kernel/softirq.c:348
> #27 0xffffffff81081dd3 in scheduler_ipi () at kernel/sched/core.c:1355
> #28 0xffffffff8101fee4 in smp_reschedule_interrupt (regs=<optimized
> out>) at arch/x86/kernel/smp.c:256
> #29 <signal handler called>
> #30 0xffffffffffffff02 in ?? ()
> Cannot access memory at address 0x246
> 
> 


static struct qfq_class *qfq_slot_head(struct qfq_group *grp)
{
        return hlist_entry(grp->slots[grp->front].first,
                           struct qfq_class, next);
}


problem is : grp->slots[grp->front].first is NULL here,

so we return RAX = -offsetof(struct qfq_class, next)

(ie -0x50 : ffffffffffffffb0)


So one bit is set in full_slots while the corresponding slots[] is
empty.

I wonder if qfq_slot_remove() is correct ?

static void qfq_slot_remove(struct qfq_sched *q, struct qfq_group *grp,
                            struct qfq_class *cl)
{
        unsigned int i, offset;
        u64 roundedS;

        roundedS = qfq_round_down(cl->S, grp->slot_shift);
        offset = (roundedS - grp->S) >> grp->slot_shift;
        i = (grp->front + offset) % QFQ_MAX_SLOTS;

        hlist_del(&cl->next);
        if (hlist_empty(&grp->slots[i]))
                __clear_bit(offset, &grp->full_slots);
}

What guarantee do we have cl was removed from slots[i] and not another
one ?
