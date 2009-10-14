From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: bisect results of MSI-X related panic (help!)
Date: Wed, 14 Oct 2009 15:30:38 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.0910141527550.3036@jbrandeb-desk1.amr.corp.intel.com>
References: <1252699744.3877.15.camel@jbrandeb-hc.jf.intel.com>  <200909120623.49764.elendil@planet.nl> <4AAE0F7B.5050203@kernel.org>  <4AAE105E.1080005@kernel.org> <4807377b0910091724k2a332e90i9941971f6032663c@mail.gmail.com> <4AD2E05A.6060700@kernel.org>
 <alpine.WNT.2.00.0910120907170.11804@jbrandeb-mobl2.amr.corp.intel.com> <4AD3E875.5040800@kernel.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Frans Pop <elendil@planet.nl>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>, "hpa@zytor.com" <hpa@zytor.com>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762084AbZJNWbR@vger.kernel.org>
In-Reply-To: <4AD3E875.5040800@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 12 Oct 2009, Tejun Heo wrote:
> Can you please apply the following patch and try to retrigger the
> panic?
> 
> diff --git a/kernel/irq/chip.c b/kernel/irq/chip.c
> index c166019..f5a1482 100644
> --- a/kernel/irq/chip.c
> +++ b/kernel/irq/chip.c
> @@ -63,6 +63,9 @@ void dynamic_irq_cleanup(unsigned int irq)
>  	struct irq_desc *desc = irq_to_desc(irq);
>  	unsigned long flags;
> 
> +	printk("XXX dynamic_irq_cleanup() called on %u\n", irq);
> +	dump_stack();
> +
>  	if (!desc) {
>  		WARN(1, KERN_ERR "Trying to cleanup invalid IRQ%d\n", irq);
>  		return;

I'm working on it, but now that I've added a bunch of debug including the 
above printk, my system panics (with a stack protector canary overwrite) 
when loading the first network adapter with 30+ MSI-X vectors.  I can boot 
single user mode and bring up netconsole, but then as soon as I brought up 
the first port with lots of MSI-X vectors, the system hard locks, no panic 
message.
 
I have a bit of a theory that the node = -1 (numa_node) stuff might be 
playing some havoc with the code in numa_migrate.c.  I'm not sure if that 
is contributing, but the code in there doesn't seem written to handle node 
= - 1 very well.  As in I never see it do an smp_processor_id at the 
bottom before accessing the node value.

Not sure if that is relevant, but I wanted to mention it before I went 
home.

What next?  I made it worse so I guess that is something.
