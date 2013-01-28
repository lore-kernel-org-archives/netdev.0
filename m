From: Bob Liu <lliubbo@gmail.com>
Subject: Re: [PATCH v5 31/45] blackfin/smp: Use get/put_online_cpus_atomic()
 to prevent CPU offline
Date: Mon, 28 Jan 2013 17:09:34 +0800
Message-ID: <CAA_GA1fSLNKSDTGSzHoA+j-mur85BvoSRkARq+DMfORuwrrX4Q@mail.gmail.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com>
	<20130122074123.13822.39102.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	rostedt@goodmis.org, wangyun@linux.vnet.ibm.com,
	xiaoguangrong@linux.vnet.ibm.com, rjw@sisk.pl, sbw@mit.edu,
	fweisbec@gmail.com, linux@arm.linux.org.uk,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20130122074123.13822.39102.stgit@srivatsabhat.in.ibm.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 22, 2013 at 3:41 PM, Srivatsa S. Bhat
<srivatsa.bhat@linux.vnet.ibm.com> wrote:
> Once stop_machine() is gone from the CPU offline path, we won't be able to
> depend on preempt_disable() or local_irq_disable() to prevent CPUs from
> going offline from under us.
>
> Use the get/put_online_cpus_atomic() APIs to prevent CPUs from going offline,
> while invoking from atomic context.
>
> Cc: Mike Frysinger <vapier@gentoo.org>
> Cc: Bob Liu <lliubbo@gmail.com>
> Cc: Steven Miao <realmz6@gmail.com>
> Cc: uclinux-dist-devel@blackfin.uclinux.org
> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>

Thanks, will be applied to my blackfin arch tree.

> ---
>
>  arch/blackfin/mach-common/smp.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/arch/blackfin/mach-common/smp.c b/arch/blackfin/mach-common/smp.c
> index bb61ae4..6cc6d7a 100644
> --- a/arch/blackfin/mach-common/smp.c
> +++ b/arch/blackfin/mach-common/smp.c
> @@ -194,6 +194,7 @@ void send_ipi(const struct cpumask *cpumask, enum ipi_message_type msg)
>         struct ipi_data *bfin_ipi_data;
>         unsigned long flags;
>
> +       get_online_cpus_atomic();
>         local_irq_save(flags);
>         smp_mb();
>         for_each_cpu(cpu, cpumask) {
> @@ -205,6 +206,7 @@ void send_ipi(const struct cpumask *cpumask, enum ipi_message_type msg)
>         }
>
>         local_irq_restore(flags);
> +       put_online_cpus_atomic();
>  }
>
>  void arch_send_call_function_single_ipi(int cpu)
> @@ -238,13 +240,13 @@ void smp_send_stop(void)
>  {
>         cpumask_t callmap;
>
> -       preempt_disable();
> +       get_online_cpus_atomic();
>         cpumask_copy(&callmap, cpu_online_mask);
>         cpumask_clear_cpu(smp_processor_id(), &callmap);
>         if (!cpumask_empty(&callmap))
>                 send_ipi(&callmap, BFIN_IPI_CPU_STOP);
>
> -       preempt_enable();
> +       put_online_cpus_atomic();
>
>         return;
>  }
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Regards,
--Bob
