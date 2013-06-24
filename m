From: Jesper Nilsson <jesper.nilsson@axis.com>
Subject: Re: [PATCH 33/45] cris/smp: Use get/put_online_cpus_atomic() to
 prevent CPU offline
Date: Mon, 24 Jun 2013 08:41:56 +0200
Message-ID: <20130624064156.GR23735@axis.com>
References: <20130623133642.19094.16038.stgit@srivatsabhat.in.ibm.com>
 <20130623134536.19094.52797.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org,
	laijs@cn.fujitsu.com, rostedt@goodmis.org,
	wangyun@linux.vnet.ibm.com, xiaoguangrong@linux.vnet.ibm.com,
	sbw@mit.edu, fweisbec@gmail.com, zhong@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mikael Starvik <starvik@axis.com>,
	Jesper Nilsson <jespern@axis.com>, linux-cris-kernel@axis.com
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.se.axis.com ([195.60.68.13]:57304 "EHLO ra.se.axis.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751922Ab3FXGmD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jun 2013 02:42:03 -0400
Content-Disposition: inline
In-Reply-To: <20130623134536.19094.52797.stgit@srivatsabhat.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 23, 2013 at 07:15:39PM +0530, Srivatsa S. Bhat wrote:
> Once stop_machine() is gone from the CPU offline path, we won't be able
> to depend on disabling preemption to prevent CPUs from going offline
> from under us.
> 
> Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going
> offline, while invoking from atomic context.
> 
> Cc: Mikael Starvik <starvik@axis.com>

Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>

> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: linux-cris-kernel@axis.com
> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
> ---
> 
>  arch/cris/arch-v32/kernel/smp.c |    5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/arch/cris/arch-v32/kernel/smp.c b/arch/cris/arch-v32/kernel/smp.c
> index cdd1202..b2d4612 100644
> --- a/arch/cris/arch-v32/kernel/smp.c
> +++ b/arch/cris/arch-v32/kernel/smp.c
> @@ -13,6 +13,7 @@
>  #include <linux/init.h>
>  #include <linux/timex.h>
>  #include <linux/sched.h>
> +#include <linux/cpu.h>
>  #include <linux/kernel.h>
>  #include <linux/cpumask.h>
>  #include <linux/interrupt.h>
> @@ -222,6 +223,7 @@ void flush_tlb_common(struct mm_struct* mm, struct vm_area_struct* vma, unsigned
>  	unsigned long flags;
>  	cpumask_t cpu_mask;
>  
> +	get_online_cpus_atomic();
>  	spin_lock_irqsave(&tlbstate_lock, flags);
>  	cpu_mask = (mm == FLUSH_ALL ? cpu_all_mask : *mm_cpumask(mm));
>  	cpumask_clear_cpu(smp_processor_id(), &cpu_mask);
> @@ -230,6 +232,7 @@ void flush_tlb_common(struct mm_struct* mm, struct vm_area_struct* vma, unsigned
>  	flush_addr = addr;
>  	send_ipi(IPI_FLUSH_TLB, 1, cpu_mask);
>  	spin_unlock_irqrestore(&tlbstate_lock, flags);
> +	put_online_cpus_atomic();
>  }
>  
>  void flush_tlb_all(void)
> @@ -319,10 +322,12 @@ int smp_call_function(void (*func)(void *info), void *info, int wait)
>  	data.info = info;
>  	data.wait = wait;
>  
> +	get_online_cpus_atomic();
>  	spin_lock(&call_lock);
>  	call_data = &data;
>  	ret = send_ipi(IPI_CALL, wait, cpu_mask);
>  	spin_unlock(&call_lock);
> +	put_online_cpus_atomic();
>  
>  	return ret;
>  }
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

/^JN - Jesper Nilsson
-- 
               Jesper Nilsson -- jesper.nilsson@axis.com
