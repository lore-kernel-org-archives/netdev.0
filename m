From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/2] net: ethernet: ti: cpts: convert to use
 kthread_worker
Date: Tue, 25 Jul 2017 06:31:34 +0200
Message-ID: <20170725043134.dxootdk66iqov7jh@localhost.localdomain>
References: <20170721234943.3841-1-grygorii.strashko@ti.com>
 <20170721234943.3841-2-grygorii.strashko@ti.com>
 <20170722052914.yo62jqdqsdv4hc5q@localhost.localdomain>
 <bc4bf624-e58e-657c-0520-9fd50d6666a6@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, Wingman Kwok <w-kwok2@ti.com>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:38531 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750780AbdGYEbj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 00:31:39 -0400
Content-Disposition: inline
In-Reply-To: <bc4bf624-e58e-657c-0520-9fd50d6666a6@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 24, 2017 at 07:34:38PM -0500, Grygorii Strashko wrote:
> Below if pure TBD/RFC version of patch which add kthread worker to PTP core.
> I'm sending it to get you opinion about implementation in general, before 
> continue with more changes. Pls, take a look if you have time?
> - are you ok with names (API, callbacks, ptp structs members)?

The API and naming looks good to me.
 
> I can prepare, update and resend proper patches tom if feedback is positive.

Please do.

> I also can convert dp83640 driver to use new feature, but I can't test it.

No need for that.  It would be enough to have cpts as the first user
and example.
 
> +	if (ptp->info->do_aux_work) {
> +		struct sched_param param = {
> +			.sched_priority = MAX_RT_PRIO - 1 };
> +
> +		kthread_init_delayed_work(&ptp->aux_work, ptp_aux_kworker);
> +		ptp->kworker = kthread_create_worker(0, info->name);
> +		if (IS_ERR(ptp->kworker)) {
> +			pr_err("failed to create ptp aux_worker task %ld\n",
> +			       PTR_ERR(ptp->kworker));
> +			return ERR_CAST(ptp->kworker);
> +		}
> +		err = sched_setscheduler_nocheck(ptp->kworker->task,
> +						 SCHED_FIFO, &param);

I think we should not hard code the scheduler and priority here but
rather leave it to the sysadmin to configure these using chrt(1).
After all, a normal work item is has served just in many situations.

> +		if (err)
> +			pr_err("sched_setscheduler_nocheck err %d\n", err);
> +	}
> +
>  	err = ptp_populate_pin_groups(ptp);
>  	if (err)
>  		goto no_pin_groups;
> @@ -274,6 +305,9 @@ int ptp_clock_unregister(struct ptp_clock *ptp)
>  	ptp->defunct = 1;
>  	wake_up_interruptible(&ptp->tsev_wq);
>  
> +	kthread_cancel_delayed_work_sync(&ptp->aux_work);
> +	kthread_destroy_worker(ptp->kworker);

These can't be called unconditionally.

>  	/* Release the clock's resources. */
>  	if (ptp->pps_source)
>  		pps_unregister_source(ptp->pps_source);

Thanks,
Richard
