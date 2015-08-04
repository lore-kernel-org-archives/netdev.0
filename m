From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: printk from softirq on xen: hard lockup
Date: Tue, 4 Aug 2015 18:41:04 +0200
Message-ID: <CAHmME9rUdafnjz0ej-z_cgznMrj27SJgy6v8GJXM0qGfUpWaMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	xen-devel@lists.xen.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi folks,

Paul McKenney and I had an offline discussion about some rcu questions
that eventually lead into me investigating a strange full lock-up I'm
experiencing as a consequence of a printk in softirq inside of an
rcu_read_lock, when using Xen PV. Relevant excerpts of the
conversation follow:

Jason:
> Looks like if I take away my [fixed text] pr_debug lines inside of
> softirq, then it doesn't lock up. That's crazy! Who knows what sort of
> bug I'm up against. Ahhh, nothing like debugging at 5am. :)

Paul:
> Are you using a serial console line?  If so, what is the baud rate?
> 115Kbaud is usually too slow, and people do get serial-console-induced
> RCU CPU stall warnings from time to time.
> Same could apply due to slow mass storage if you are copying the console
> log to mass storage.

Jason:
> Wait, what?!? What you described sounds completely bonkers. Are you
> saying that printk()ing in softirq and/or while rcu_read_lock is held
> can result, in certain known circumstances, in an unrecoverable full
> system lockup? If so, this would be quite the unresolved kernel bug...

Paul:
> More like printk() while interrupts are disabled, but you got it.
> The RCU CPU stall timeout is 21 seconds in recent kernels.  If you
> have a 115Kbaud serial line, you get about 1,150 characters per second.
> So if you printk() 24K characters within on irqs-disabled code region
> on such a system, you will very likely get an RCU CPU stall warning.
> And I agree that this can be annoying, but on the other hand, that is
> a pretty freaking slow console-output device, especially given that it
> is 2015.

Jason:
> Hah, that's crazy: seems like you were more or less right. Nice intuition.

Here's the backtrace of what's up during this lockup:

(gdb) target remote localhost:9999
Remote debugging using localhost:9999
__xapic_wait_icr_idle () at ./arch/x86/include/asm/ipi.h:56
56              while (native_apic_mem_read(APIC_ICR) & APIC_ICR_BUSY)
(gdb) bt
#0  __xapic_wait_icr_idle () at ./arch/x86/include/asm/ipi.h:56
#1  __default_send_IPI_shortcut (shortcut=<optimized out>,
dest=<optimized out>, vector=<optimized out>) at
./arch/x86/include/asm/ipi.h:75
#2  apic_send_IPI_self (vector=246) at arch/x86/kernel/apic/probe_64.c:54
#3  0xffffffff81011336 in arch_irq_work_raise () at
arch/x86/kernel/irq_work.c:47
#4  0xffffffff8114990c in irq_work_queue (work=0xffff88000fc0e400) at
kernel/irq_work.c:100
#5  0xffffffff8110c29d in wake_up_klogd () at kernel/printk/printk.c:2633
#6  0xffffffff8110ca60 in vprintk_emit (facility=0, level=<optimized
out>, dict=0x0 <irq_stack_union>, dictlen=<optimized out>,
fmt=<optimized out>, args=<optimized out>)
    at kernel/printk/printk.c:1778
#7  0xffffffff816010c8 in printk (fmt=<optimized out>) at
kernel/printk/printk.c:1868
#8  0xffffffffc00013ea in ?? ()
#9  0x0000000000000000 in ?? ()

And meanwhile I get stall message:

> [ 1090.072011] INFO: rcu_sched detected stalls on CPUs/tasks: { 0} (detected by 1, t=61603 jiffies, g=7165, c=7164, q=28)
> [ 1090.072027] Task dump for CPU 0:
> [ 1090.072031] swapper/0       R  running task        0     0      0 0x00000008
> [ 1090.072041] Call Trace:
> [ 1090.072049]  [<ffffffff810013aa>] ? xen_hypercall_sched_op+0xa/0x20
> [ 1090.072054]  [<ffffffff81007acc>] ? xen_safe_halt+0xc/0x20
> [ 1090.072059]  [<ffffffff810159a5>] ? default_idle+0x5/0x10
> [ 1090.072064]  [<ffffffff8110394d>] ? cpu_startup_entry+0x1ed/0x220
> [ 1090.072070]  [<ffffffff81a97e8d>] ? start_kernel+0x426/0x431
> [ 1090.072074]  [<ffffffff81a998cd>] ? xen_start_kernel+0x350/0x356

So what's the deal exactly -- I can't use pr_debug in softirq in
rcu_read_lock()ed regions? I'm not using a slow serial modem -- just
the ordinary xen console. Userspace is logging dmesg to disk as well,
but the disk isn't especially slow.

Is this a xen problem? A softirq problem? Or is this simply... my
problem? It only happens with Xen PV. It doesn't happen otherwise.

Thanks,
Jason
