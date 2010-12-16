From: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: [PATCH V7 1/8] ntp: add ADJ_SETOFFSET mode bit
Date: Thu, 16 Dec 2010 18:48:12 +0100 (CET)
Message-ID: <alpine.LFD.2.00.1012161844140.12146@localhost6.localdomain6>
References: <cover.1292512461.git.richard.cochran@omicron.at> <880d82bb8120f73973db27e0c48e949014b1a106.1292512461.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <880d82bb8120f73973db27e0c48e949014b1a106.1292512461.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 16 Dec 2010, Richard Cochran wrote:
> +	if (txc->modes & ADJ_SETOFFSET) {
> +		/* Validate the delta value. */
> +		if (txc->time.tv_sec && txc->time.tv_usec < 0)
> +			return -EINVAL;
> +
> +		if (txc->modes & ADJ_NANO) {
> +			struct timespec tmp;
> +			tmp.tv_sec  = txc->time.tv_sec;
> +			tmp.tv_nsec = txc->time.tv_usec;
> +			delta = timespec_to_ktime(tmp);
> +		} else
> +			delta = timeval_to_ktime(txc->time);
> +
> +		/* Adding the delta should be an "atomic" operation. */
> +		local_irq_disable();

I really do not like that conditional irq_disable(), especially as we
disable them further down again and we only safe the getnstimeofday()
call in the non ADJSETOFFSET code path.

So we really better do that unconditionally before getnstimeofday()
with an appropriate comment and change the write_seqlock_irq() to
write_seqlock().

> +	}
> +
>  	getnstimeofday(&ts);
>  
> +	if (txc->modes & ADJ_SETOFFSET) {
> +		kt = timespec_to_ktime(ts);
> +		kt = ktime_add(kt, delta);
> +		ts = ktime_to_timespec(kt);
> +		do_settimeofday(&ts);
> +		local_irq_enable();
> +	}
> +
>  	write_seqlock_irq(&xtime_lock);

Thanks,

	tglx
> 
