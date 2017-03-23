From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH V8 1/3] irq: Add flags to request_percpu_irq function
Date: Thu, 23 Mar 2017 18:54:52 +0000
Message-ID: <20170323185449.GA21359@leverpostej>
References: <1490290924-12958-1-git-send-email-daniel.lezcano@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tglx@linutronix.de, nicolas.pitre@linaro.org,
        linux-samsung-soc@vger.kernel.org, vincent.guittot@linaro.org,
        kernel@stlinux.com, kvm@vger.kernel.org, rafael@kernel.org,
        peterz@infradead.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org,
        linux-snps-arc@lists.infradead.org, kvmarm@lists.cs.columbia.edu,
        linux-arm-kernel@lists.infradead.org, will.deacon@arm.com,
        marc.zyngier@arm.com
To: Daniel Lezcano <daniel.lezcano@linaro.org>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1490290924-12958-1-git-send-email-daniel.lezcano@linaro.org>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Daniel,

On Thu, Mar 23, 2017 at 06:42:01PM +0100, Daniel Lezcano wrote:
> In the next changes, we track the interrupts but we discard the timers as
> that does not make sense. The next interrupt on a timer is predictable.

Sorry, but I could not parse this. 

[...]

> diff --git a/drivers/perf/arm_pmu.c b/drivers/perf/arm_pmu.c
> index 9612b84..0f5ab4a 100644
> --- a/drivers/perf/arm_pmu.c
> +++ b/drivers/perf/arm_pmu.c
> @@ -661,7 +661,7 @@ static int cpu_pmu_request_irq(struct arm_pmu *cpu_pmu, irq_handler_t handler)
>  
>  	irq = platform_get_irq(pmu_device, 0);
>  	if (irq > 0 && irq_is_percpu(irq)) {
> -		err = request_percpu_irq(irq, handler, "arm-pmu",
> +		err = request_percpu_irq(irq, 0, handler, "arm-pmu",
>  					 &hw_events->percpu_pmu);
>  		if (err) {
>  			pr_err("unable to request IRQ%d for ARM PMU counters\n",

Please Cc myself and Will Deacon when modifying the arm_pmu driver, as
per MAINTAINERS. I only spotted this patch by chance.

This conflicts with arm_pmu changes I have queued for v4.12 [1].

So, can we leave the prototype of request_percpu_irq() as-is?

Why not add a new request_percpu_irq_flags() function, and leave
request_percpu_irq() as a wrapper for that? e.g.

static inline int
request_percpu_irq(unsigned int irq, irq_handler_t handler,
		   const char *devname, void __percpu *percpu_dev_id)
{
	return request_percpu_irq_flags(irq, handler, devname,
					percpu_dev_id, 0);
}

... that would avoid having to touch any non-timer driver for now.

[...]

> -request_percpu_irq(unsigned int irq, irq_handler_t handler,
> -		   const char *devname, void __percpu *percpu_dev_id);
> +request_percpu_irq(unsigned int irq, unsigned long flags,
> +		   irq_handler_t handler,  const char *devname,
> +		   void __percpu *percpu_dev_id);
>  

Looking at request_irq, the prototype is:

int __must_check
request_irq(unsigned int irq, irq_handler_t handler,
	    unsigned long flags, const char *name,
	    void *dev);

... surely it would be better to share the same argument order? i.e.

int __must_check
request_percpu_irq(unsigned int irq, irq_handler_t handler,
		   unsigned long flags, const char *devname,
		   void __percpu *percpu_dev_id);

Thanks,
Mark.

[1] https://git.kernel.org/pub/scm/linux/kernel/git/mark/linux.git/log/?h=arm/perf/refactoring
