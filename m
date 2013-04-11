From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH repost for-3.9] pci: avoid work_on_cpu for nested SRIOV probes
Date: Fri, 12 Apr 2013 00:52:45 +0300
Message-ID: <CAJZOPZJnRF2qw4w0uv1h9wQ7sP3asH-42B+a0mwm+GCHSrm16Q@mail.gmail.com>
References: <20130411153030.GA22743@redhat.com>
	<20130411180517.GJ17641@mtj.dyndns.org>
	<20130411185853.GE23301@redhat.com>
	<20130411190408.GM17641@mtj.dyndns.org>
	<20130411191717.GB25515@redhat.com>
	<20130411192005.GN17641@mtj.dyndns.org>
	<20130411203053.GC25515@redhat.com>
	<20130411204104.GC11956@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ming Lei <ming.lei@canonical.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20130411204104.GC11956@mtj.dyndns.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 11, 2013 at 11:41 PM, Tejun Heo <tj@kernel.org> wrote:
> Hello,
>
> On Thu, Apr 11, 2013 at 11:30:53PM +0300, Michael S. Tsirkin wrote:
>> Okay, so you are saying it's a false-positive?
>
> Yeah, I think so.  It didn't actually lock up, right?  It it did,
> our analysis upto this point is likely to be completely wrong.
>
>> Want to send a patch so Or can try it out?


I can test that Sunday
>
> Hmmm... something like the following on the workqueue side (completely
> untested).
>
> diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
> index 8afab27..899d470 100644
> --- a/include/linux/workqueue.h
> +++ b/include/linux/workqueue.h
> @@ -466,14 +466,21 @@ static inline bool __deprecated flush_delayed_work_sync(struct delayed_work *dwo
>  }
>
>  #ifndef CONFIG_SMP
> -static inline long work_on_cpu(unsigned int cpu, long (*fn)(void *), void *arg)
> +static inline long work_on_cpu_nested(unsigned int cpu, long (*fn)(void *),
> +                                     void *arg, int subclass)
>  {
>         return fn(arg);
>  }
>  #else
> -long work_on_cpu(unsigned int cpu, long (*fn)(void *), void *arg);
> +long work_on_cpu_nested(unsigned int cpu, long (*fn)(void *), void *arg,
> +                       int subclass);
>  #endif /* CONFIG_SMP */
>
> +static inline long work_on_cpu(unsigned int cpu, long (*fn)(void *), void *arg)
> +{
> +       return work_on_cpu_nested(cpu, fn, arg, 0);
> +}
> +
>  #ifdef CONFIG_FREEZER
>  extern void freeze_workqueues_begin(void);
>  extern bool freeze_workqueues_busy(void);
> diff --git a/kernel/workqueue.c b/kernel/workqueue.c
> index 81f2457..c2be670 100644
> --- a/kernel/workqueue.c
> +++ b/kernel/workqueue.c
> @@ -3555,25 +3555,30 @@ static void work_for_cpu_fn(struct work_struct *work)
>  }
>
>  /**
> - * work_on_cpu - run a function in user context on a particular cpu
> + * work_on_cpu_nested - run a function in user context on a particular cpu
>   * @cpu: the cpu to run on
>   * @fn: the function to run
>   * @arg: the function arg
> + * @subclass: lockdep subclass
>   *
>   * This will return the value @fn returns.
>   * It is up to the caller to ensure that the cpu doesn't go offline.
>   * The caller must not hold any locks which would prevent @fn from completing.
> + *
> + * XXX: explain @subclass
>   */
> -long work_on_cpu(unsigned int cpu, long (*fn)(void *), void *arg)
> +long work_on_cpu_nested(unsigned int cpu, long (*fn)(void *), void *arg,
> +                       int subclass)
>  {
>         struct work_for_cpu wfc = { .fn = fn, .arg = arg };
>
>         INIT_WORK_ONSTACK(&wfc.work, work_for_cpu_fn);
> +       lock_set_subclass(&wfc.work.lockdep_map, subclass, _RET_IP_);
>         schedule_work_on(cpu, &wfc.work);
>         flush_work(&wfc.work);
>         return wfc.ret;
>  }
> -EXPORT_SYMBOL_GPL(work_on_cpu);
> +EXPORT_SYMBOL_GPL(work_on_cpu_nested);
>  #endif /* CONFIG_SMP */
>
>  #ifdef CONFIG_FREEZER
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
