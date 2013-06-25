From: Michael Ellerman <michael@ellerman.id.au>
Subject: Re: [PATCH 40/45] powerpc, irq: Use GFP_ATOMIC allocations in atomic
 context
Date: Tue, 25 Jun 2013 12:08:42 +1000
Message-ID: <20130625020842.GD14051@concordia>
References: <20130623133642.19094.16038.stgit@srivatsabhat.in.ibm.com>
 <20130623134657.19094.93687.stgit@srivatsabhat.in.ibm.com>
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
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Ian Munsie <imunsie@au1.ibm.com>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-pm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130623134657.19094.93687.stgit@srivatsabhat.in.ibm.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 23, 2013 at 07:17:00PM +0530, Srivatsa S. Bhat wrote:
> The function migrate_irqs() is called with interrupts disabled
> and hence its not safe to do GFP_KERNEL allocations inside it,
> because they can sleep. So change the gfp mask to GFP_ATOMIC.

OK so it gets there via:
  __stop_machine()
    take_cpu_down()
      __cpu_disable()
        smp_ops->cpu_disable()
          generic_cpu_disable()
            migrate_irqs()

> diff --git a/arch/powerpc/kernel/irq.c b/arch/powerpc/kernel/irq.c
> index ea185e0..ca39bac 100644
> --- a/arch/powerpc/kernel/irq.c
> +++ b/arch/powerpc/kernel/irq.c
> @@ -412,7 +412,7 @@ void migrate_irqs(void)
>  	cpumask_var_t mask;
>  	const struct cpumask *map = cpu_online_mask;
>  
> -	alloc_cpumask_var(&mask, GFP_KERNEL);
> +	alloc_cpumask_var(&mask, GFP_ATOMIC);

We're not checking for allocation failure, which we should be.

But this code is only used on powermac and 85xx, so it should probably
just be a TODO to fix this up to handle the failure.

cheers
