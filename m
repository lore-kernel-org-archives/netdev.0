From: Tejun Heo <tj@kernel.org>
Subject: Re: bisect results of MSI-X related panic (help!)
Date: Tue, 13 Oct 2009 11:39:49 +0900
Message-ID: <4AD3E875.5040800@kernel.org>
References: <1252699744.3877.15.camel@jbrandeb-hc.jf.intel.com>  <200909120623.49764.elendil@planet.nl> <4AAE0F7B.5050203@kernel.org>  <4AAE105E.1080005@kernel.org> <4807377b0910091724k2a332e90i9941971f6032663c@mail.gmail.com> <4AD2E05A.6060700@kernel.org> <alpine.WNT.2.00.0910120907170.11804@jbrandeb-mobl2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Frans Pop <elendil@planet.nl>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>, "hpa@zytor.com" <hpa@zytor.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758879AbZJMCkh@vger.kernel.org>
In-Reply-To: <alpine.WNT.2.00.0910120907170.11804@jbrandeb-mobl2.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brandeburg, Jesse wrote:
> On Mon, 12 Oct 2009, Tejun Heo wrote:
>>> any other debugging tricks/ideas?
>> Hmm... stackprotector adds considerable amount of stack usage and it
>> could be you're seeing stack overflow which would also explain the
>> random crashes you've been seeing.  Do you have DEBUG_STACKOVERFLOW
>> turned on?  This is on x86_64, right?
> 
> Hi, thanks for your response, 
> 
> [root@jbrandeb-hc linux-2.6.32-rc1]# grep STACKO .config
> CONFIG_DEBUG_STACKOVERFLOW=y
> 
> [root@jbrandeb-hc linux-2.6.32-rc1]# grep X86_64 .config
> CONFIG_X86_64=y
> CONFIG_X86_64_SMP=y
> CONFIG_X86_64_ACPI_NUMA=y
> 
> stack size is 8K
> 
> I tried Jarek's suggestion of CPUMASK_OFFSTACK and still panic.
> [66027.266057] Kernel panic - not syncing: stack-protector: Kernel stack 
> is corrupted in: ffffffff810b4eb0
> [66027.266059]
> [66027.266070] Kernel panic - not syncing: stack-protector: Kernel stack 
> is corrupted in: ffffffff81472856
> [66027.266071]
> [66027.266081] Pid: 0, comm: swapper Tainted: G        W  
> 2.6.32-rc2-git-debug #6
> [66027.266086] Call Trace:
> 
> that was all I got.  Interesting double fault, that hadn't happened 
> before.
> 
> the symbols might be off slightly since I rebuilt the kernel, but this was 
> initial poke at offsets above in gdb
> (gdb) l *0xffffffff810b4eb0
> 0xffffffff810b4eb0 is in dynamic_irq_cleanup (kernel/irq/chip.c:86).
> 81              desc->handle_irq = handle_bad_irq;
> 82              desc->chip = &no_irq_chip;
> 83              desc->name = NULL;
> 84              clear_kstat_irqs(desc);
> 85              spin_unlock_irqrestore(&desc->lock, flags);
> 86      }

Can you please apply the following patch and try to retrigger the
panic?

diff --git a/kernel/irq/chip.c b/kernel/irq/chip.c
index c166019..f5a1482 100644
--- a/kernel/irq/chip.c
+++ b/kernel/irq/chip.c
@@ -63,6 +63,9 @@ void dynamic_irq_cleanup(unsigned int irq)
 	struct irq_desc *desc = irq_to_desc(irq);
 	unsigned long flags;

+	printk("XXX dynamic_irq_cleanup() called on %u\n", irq);
+	dump_stack();
+
 	if (!desc) {
 		WARN(1, KERN_ERR "Trying to cleanup invalid IRQ%d\n", irq);
 		return;

-- 
tejun
