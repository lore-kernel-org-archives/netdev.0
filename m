From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH] workqueue.c: should schedule work serialize work->func
Date: Thu, 07 Jan 2010 09:42:57 +0900
Message-ID: <4B452E11.90404@kernel.org>
References: <20100106230512.17900.47310.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@ingel.com,
	tglx@linuxtronix.de
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:40535 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756326Ab0AGAhZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2010 19:37:25 -0500
In-Reply-To: <20100106230512.17900.47310.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 01/07/2010 08:05 AM, John Fastabend wrote:
> codepath
> schedule_work(); ... ; run_workqueue() -> work_clear_pending() -> f(work)
> 
> Although schedule_work() will only schedule the task if it is not already
> on the work queue the WORK_STRUCT_PENDING bits are cleared just before
> calling the work function.  If work is scheduled after this occurs and
> before f(work) completes it is possible to have multiple calls into f().
> 
> Should the kernel protect us from this? With something like the patch
> below.

This is by design.  Multithread workqueue doesn't protect against
works running simultaneously on different cpus.  The callback is
responsible for synchronization.

> diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
> index 9466e86..fa6ffea 100644
> --- a/include/linux/workqueue.h
> +++ b/include/linux/workqueue.h
> @@ -26,7 +26,8 @@ struct work_struct {
>  	atomic_long_t data;
>  #define WORK_STRUCT_PENDING 0		/* T if work item pending execution */
>  #define WORK_STRUCT_STATIC  1		/* static initializer (debugobjects) */
> -#define WORK_STRUCT_FLAG_MASK (3UL)
> +#define WORK_STRUCT_RUNNING 2
> +#define WORK_STRUCT_FLAG_MASK (7UL)	/* 0111 */
>  #define WORK_STRUCT_WQ_DATA_MASK (~WORK_STRUCT_FLAG_MASK)
>  	struct list_head entry;
>  	work_func_t func;
> diff --git a/kernel/workqueue.c b/kernel/workqueue.c
> index dee4865..b867125 100644
> --- a/kernel/workqueue.c
> +++ b/kernel/workqueue.c
> @@ -397,10 +397,13 @@ static void run_workqueue(struct cpu_workqueue_struct *cwq)
>  		spin_unlock_irq(&cwq->lock);
>  
>  		BUG_ON(get_wq_data(work) != cwq);
> +		while (test_and_set_bit(WORK_STRUCT_RUNNING, work_data_bits(work)))
> +			cpu_relax();
>  		work_clear_pending(work);
>  		lock_map_acquire(&cwq->wq->lockdep_map);
>  		lock_map_acquire(&lockdep_map);
>  		f(work);
> +		clear_bit(WORK_STRUCT_RUNNING, work_data_bits(work));

work is not accessible at this point.  f() may have freed it already.

Thanks.

-- 
tejun
