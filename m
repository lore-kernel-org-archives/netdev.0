From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 11/11] k_clock:Remove the 32bit methods with timespec type
Date: Mon, 20 Apr 2015 10:42:30 +0200
Message-ID: <20150420084229.GA4608@localhost.localdomain>
References: <1429509459-17068-1-git-send-email-baolin.wang@linaro.org>
 <1429509459-17068-12-git-send-email-baolin.wang@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tglx@linutronix.de, arnd@arndb.de, john.stultz@linaro.org,
	heenasirwani@gmail.com, pang.xunlei@linaro.org,
	peterz@infradead.org, rafael.j.wysocki@intel.com,
	gregkh@linuxfoundation.org, benh@kernel.crashing.org,
	paulus@samba.org, mpe@ellerman.id.au, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, linux390@de.ibm.com, rth@twiddle.net,
	riel@redhat.com, cl@linux.com, tj@kernel.org, fweisbec@gmail.com,
	ahh@google.com, pjt@google.com, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	y2038@lists.linaro.org
To: Baolin Wang <baolin.wang@linaro.org>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1429509459-17068-12-git-send-email-baolin.wang@linaro.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 20, 2015 at 01:57:39PM +0800, Baolin Wang wrote:

> @@ -911,18 +907,14 @@ retry:
>  		return -EINVAL;
>  
>  	kc = clockid_to_kclock(timr->it_clock);
> -	if (WARN_ON_ONCE(!kc || (!kc->timer_set && !kc->timer_set64))) {
> +	if (WARN_ON_ONCE(!kc || !kc->timer_set64)) {
>  		error = -EINVAL;
>  	} else {
> -		if (kc->timer_set64) {
> -			new_spec64 = itimerspec_to_itimerspec64(new_spec);
> -			error = kc->timer_set64(timr, flags, &new_spec64,
> -						&old_spec64);
> -			if (old_setting)
> -				old_spec = itimerspec64_to_itimerspec(old_spec64);
> -		} else {
> -			error = kc->timer_set(timr, flags, &new_spec, rtn);
> -		}
> +		new_spec64 = itimerspec_to_itimerspec64(new_spec);
> +		error = kc->timer_set64(timr, flags, &new_spec64,
> +					&old_spec64);

This statement can fit on one line.

> +		if (old_setting)
> +			old_spec = itimerspec64_to_itimerspec(old_spec64);
>  	}
>  
>  	unlock_timer(timr, flag);

> @@ -1057,14 +1045,13 @@ SYSCALL_DEFINE2(clock_gettime, const clockid_t, which_clock,
>  	if (!kc)
>  		return -EINVAL;
>  
> -	if (kc->clock_get64) {
> -		error = kc->clock_get64(which_clock, &kernel_tp64);
> -		kernel_tp = timespec64_to_timespec(kernel_tp64);
> -	} else {
> -		error = kc->clock_get(which_clock, &kernel_tp);
> -	}
> +	error = kc->clock_get64(which_clock, &kernel_tp64);
> +	if (!error)
> +		return error;

Wrong test, should be: if (error) ...

> +
> +	kernel_tp = timespec64_to_timespec(kernel_tp64);
>  
> -	if (!error && copy_to_user(tp, &kernel_tp, sizeof (kernel_tp)))

The (!error && ...) was correct here!

> +	if (copy_to_user(tp, &kernel_tp, sizeof (kernel_tp)))
>  		error = -EFAULT;
>  
>  	return error;

You can simplify this like so:

	return copy_to_user(tp, &kernel_tp, sizeof(kernel_tp)) ? -EFAULT : 0;

> @@ -1104,14 +1091,13 @@ SYSCALL_DEFINE2(clock_getres, const clockid_t, which_clock,
>  	if (!kc)
>  		return -EINVAL;
>  
> -	if (kc->clock_getres64) {
> -		error = kc->clock_getres64(which_clock, &rtn_tp64);
> -		rtn_tp = timespec64_to_timespec(rtn_tp64);
> -	} else {
> -		error = kc->clock_getres(which_clock, &rtn_tp);
> -	}
> +	error = kc->clock_getres64(which_clock, &rtn_tp64);
> +	if (!error)
> +		return error;

Also wrong.

> +
> +	rtn_tp = timespec64_to_timespec(rtn_tp64);
>  
> -	if (!error && tp && copy_to_user(tp, &rtn_tp, sizeof (rtn_tp)))
> +	if (tp && copy_to_user(tp, &rtn_tp, sizeof (rtn_tp)))
>  		error = -EFAULT;
>  
>  	return error;
> -- 
> 1.7.9.5
> 

Thanks,
Richard
