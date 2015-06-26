From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] Added additional callback to ptp_clock_info:
Date: Fri, 26 Jun 2015 08:40:27 +0200
Message-ID: <20150626064027.GA1511@localhost.localdomain>
References: <1435275777-3918-1-git-send-email-christopher.s.hall@intel.com>
 <1435275777-3918-2-git-send-email-christopher.s.hall@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jacob.e.keller@intel.com,
	john.ronciak@intel.com, kevin.b.stanton@intel.com
To: Christopher Hall <christopher.s.hall@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:38243 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704AbbFZGkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 02:40:32 -0400
Received: by wibdq8 with SMTP id dq8so8544008wib.1
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 23:40:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1435275777-3918-2-git-send-email-christopher.s.hall@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 25, 2015 at 04:42:57PM -0700, Christopher Hall wrote:
> @@ -196,19 +196,31 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
>  			break;
>  		}
>  		pct = &sysoff->ts[0];
> -		for (i = 0; i < sysoff->n_samples; i++) {
> -			getnstimeofday64(&ts);
> +		if (ptp->info->getsynctime64 && sysoff->n_samples == 1) {
> +			ptp->info->getsynctime64(ptp->info, &ts, &systs);
> +			pct->sec = systs.tv_sec;
> +			pct->nsec = systs.tv_nsec;
> +			++pct;

Please use pct++ for the sake of consistency.

>  			pct->sec = ts.tv_sec;
>  			pct->nsec = ts.tv_nsec;
> -			pct++;
> -			ptp->info->gettime64(ptp->info, &ts);
> +			++pct;
> +			pct->sec = systs.tv_sec;
> +			pct->nsec = systs.tv_nsec;
> +		} else {
> +			for (i = 0; i < sysoff->n_samples; i++) {
> +				getnstimeofday64(&ts);
> +				pct->sec = ts.tv_sec;
> +				pct->nsec = ts.tv_nsec;
> +				pct++;
> +				ptp->info->gettime64(ptp->info, &ts);
> +				pct->sec = ts.tv_sec;
> +				pct->nsec = ts.tv_nsec;
> +				pct++;
> +			}
> +			getnstimeofday64(&ts);
>  			pct->sec = ts.tv_sec;
>  			pct->nsec = ts.tv_nsec;
> -			pct++;
>  		}
> -		getnstimeofday64(&ts);
> -		pct->sec = ts.tv_sec;
> -		pct->nsec = ts.tv_nsec;
>  		if (copy_to_user((void __user *)arg, sysoff, sizeof(*sysoff)))
>  			err = -EFAULT;
>  		break;
> diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
> index b8b7306..edff9a5 100644
> --- a/include/linux/ptp_clock_kernel.h
> +++ b/include/linux/ptp_clock_kernel.h
> @@ -105,6 +105,9 @@ struct ptp_clock_info {
>  	int (*adjfreq)(struct ptp_clock_info *ptp, s32 delta);
>  	int (*adjtime)(struct ptp_clock_info *ptp, s64 delta);
>  	int (*gettime64)(struct ptp_clock_info *ptp, struct timespec64 *ts);
> +	int (*getsynctime64)
> +		(struct ptp_clock_info *ptp, struct timespec64 *dev,
> +		 struct timespec64 *sys);

The struct's KernelDoc also needs updating.

>  	int (*settime64)(struct ptp_clock_info *p, const struct timespec64 *ts);
>  	int (*enable)(struct ptp_clock_info *ptp,
>  		      struct ptp_clock_request *request, int on);
> -- 
> 1.9.1

Thanks,
Richard
