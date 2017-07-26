From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 1/3] ptp: introduce ptp auxiliary worker
Date: Wed, 26 Jul 2017 06:24:39 +0200
Message-ID: <20170726042439.b2ulx4zx4iyhirxh@localhost.localdomain>
References: <20170725202420.28229-1-grygorii.strashko@ti.com>
 <20170725202420.28229-2-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, Wingman Kwok <w-kwok2@ti.com>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170725202420.28229-2-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Thanks for coding this up.  I'd like to get some broader review.  On
the next round, please include lkml, John Stultz, and Thomas Gleixner.

On Tue, Jul 25, 2017 at 03:24:18PM -0500, Grygorii Strashko wrote:
> @@ -217,6 +231,19 @@ struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
>  	mutex_init(&ptp->pincfg_mux);
>  	init_waitqueue_head(&ptp->tsev_wq);
>  
> +	if (ptp->info->do_aux_work) {
> +		char *worker_name = kasprintf(GFP_KERNEL, "ptp%d", ptp->index);
> +
> +		kthread_init_delayed_work(&ptp->aux_work, ptp_aux_kworker);
> +		ptp->kworker = kthread_create_worker(0, worker_name ?
> +						     worker_name : info->name);
> +		if (IS_ERR(ptp->kworker)) {
> +			pr_err("failed to create ptp aux_worker task %ld\n",
> +			       PTR_ERR(ptp->kworker));
> +			return ERR_CAST(ptp->kworker);

In case of error, we should undo the allocations.  

> +		}
> +	}
> +
>  	err = ptp_populate_pin_groups(ptp);
>  	if (err)
>  		goto no_pin_groups;

> @@ -339,6 +371,14 @@ int ptp_find_pin(struct ptp_clock *ptp,
>  }
>  EXPORT_SYMBOL(ptp_find_pin);
>  
> +int ptp_schedule_worker(struct ptp_clock *ptp, unsigned long delay)
> +{
> +	if (!ptp->kworker)
> +		return -EOPNOTSUPP;

We don't need error checking here.  Surely the driver knows whether to
call this function or not.

> +	return kthread_mod_delayed_work(ptp->kworker, &ptp->aux_work, delay);
> +}
> +EXPORT_SYMBOL(ptp_schedule_worker);
> +
>  /* module operations */
>  
>  static void __exit ptp_exit(void)

> diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
> index a026bfd..ec86fd2 100644
> --- a/include/linux/ptp_clock_kernel.h
> +++ b/include/linux/ptp_clock_kernel.h
> @@ -98,6 +98,10 @@ struct system_device_crosststamp;
>   *            parameter pin: index of the pin in question.
>   *            parameter func: the desired function to use.
>   *            parameter chan: the function channel index to use.

Blank comment line here please.

> + * @do_work:  Request driver to perform auxiliary (periodic) operations
> + *	      Driver should return delay of the next auxiliary work scheduling
> + *	      time (>=0) or negative value in case further scheduling
> + *	      is not required.
>   *

Thanks,
Richard
