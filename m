From: Eric Lemoine <Eric.Lemoine@ens-lyon.fr>
Subject: Re: [Question] SMP for Linux
Date: Wed, 13 Nov 2002 07:53:04 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021113065304.GC402@udine>
References: <15793.3958.926796.634263@robur.slu.se> <001701c27ba0$6ff02c70$3701020a@CONCORDIA>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Fraser <J_Fraser@bit-net.com>
Content-Disposition: inline
In-Reply-To: <001701c27ba0$6ff02c70$3701020a@CONCORDIA>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> >  > I'll repeat the same tests on Monday with 82543 based cards.
> >  > I would expect similar results.
> >  > Oh, I used top and vmstat to collect cpu percentages, 
> > interrupts/second,
> > 
> >  Hmm top and vmstat doesn't give you time spent in 
> > irq/softirq's except for 
> >  softirq's run via ksoftird?
> 
> Right.

You guys sure about this?

vmstat uses stats gathered by the kernel in the structure variable kstat
(of type struct kernel_stat). Here follows the func that updates this
variable, it seems that time spent in irq/softirq is accounted, isn't
it?

void update_process_times(int user_tick)
{
        struct task_struct *p = current;
        int cpu = smp_processor_id(), system = user_tick ^ 1;

        update_one_process(p, user_tick, system, cpu);
        if (p->pid) {
                if (--p->counter <= 0) {
                        p->counter = 0;
                        p->need_resched = 1;
                }
                if (p->nice > 0)
                        kstat.per_cpu_nice[cpu] += user_tick;
                else
                        kstat.per_cpu_user[cpu] += user_tick;
                kstat.per_cpu_system[cpu] += system;
        } else if (local_bh_count(cpu) || local_irq_count(cpu) > 1)
                kstat.per_cpu_system[cpu] += system;
}

PS: I agree this has nothing to do with netdev discussions but I just want 
to make sure...

Thx.
-- 
Eric
