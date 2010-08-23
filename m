From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 1/1] posix clocks: introduce syscall for clock tuning.
Date: Mon, 23 Aug 2010 14:57:26 +0200
Message-ID: <201008231457.26690.arnd@arndb.de>
References: <cover.1282550649.git.richard.cochran@omicron.at> <e253843e07ce5d15c2c8d11ce786bf979ed85ca5.1282550649.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	john stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <e253843e07ce5d15c2c8d11ce786bf979ed85ca5.1282550649.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 23 August 2010, Richard Cochran wrote:
> A new syscall is introduced that allows tuning of a POSIX clock. The
> syscall is implemented for four architectures: arm, blackfin, powerpc,
> and x86.
> 
> The new syscall, clock_adjtime, takes two parameters, a frequency
> adjustment in parts per billion, and a pointer to a struct timespec
> containing the clock offset. If the pointer is NULL, a frequency
> adjustment is performed. Otherwise, the clock offset is immediately
> corrected by skipping to the new time value.

It looks well-implemented, and seems to be a reasonable extension
to the clock API. I'm looking forward to your ptp patches on top
of this to see how it all fits together.

For new syscalls, it's best to take linux-api on Cc. I also added
John, since he participated in the discussion.

> In addtion, the patch provides way to unregister a posix clock. This
> function is need to support posix clocks implemented as modules.

This part should probably be a separate patch, and you need to add
some form of serialization here to avoid races between the clock
system calls and the unregistration.

> diff --git a/kernel/posix-cpu-timers.c b/kernel/posix-cpu-timers.c
> index 9829646..5843f5a 100644
> --- a/kernel/posix-cpu-timers.c
> +++ b/kernel/posix-cpu-timers.c
> @@ -207,6 +207,11 @@ int posix_cpu_clock_set(const clockid_t which_clock, const struct timespec *tp)
>  	return error;
>  }
>  
> +int posix_cpu_clock_adj(const clockid_t which_clock, int ppb,
> +			struct timespec *tp)
> +{
> +	return -EOPNOTSUPP;
> +}

EOPNOTSUPP is specific to sockets, better use -EINVAL here.

Where do you use this function?

>  /*
>   * Sample a per-thread clock for the given task.
> diff --git a/kernel/posix-timers.c b/kernel/posix-timers.c
> index ad72342..089b0d1 100644
> --- a/kernel/posix-timers.c
> +++ b/kernel/posix-timers.c
> @@ -197,6 +197,12 @@ static int common_timer_create(struct k_itimer *new_timer)
>  	return 0;
>  }
>  
> +static inline int common_clock_adj(const clockid_t which_clock, int ppb,
> +				   struct timespec *tp)
> +{
> +	return -EOPNOTSUPP;
> +}
> +
>  static int no_timer_create(struct k_itimer *new_timer)
>  {
>  	return -EOPNOTSUPP;

So we already return -EOPNOTSUPP in some cases? The man page does not document this.
I wonder if we should change that to -EINVAL as well.

> @@ -488,6 +494,21 @@ void register_posix_clock(const clockid_t clock_id, struct k_clock *new_clock)
>  }
>  EXPORT_SYMBOL_GPL(register_posix_clock);
>  
> +void unregister_posix_clock(const clockid_t clock_id)
> +{
> +	struct k_clock *clock;
> +
> +	if ((unsigned) clock_id >= MAX_CLOCKS) {
> +		pr_err("POSIX clock unregister failed for clock_id %d\n",
> +		       clock_id);
> +		return;
> +	}
> +
> +	clock = &posix_clocks[clock_id];
> +	memset(clock, 0, sizeof(*clock));
> +}
> +EXPORT_SYMBOL_GPL(unregister_posix_clock);
> +

It would be possible to add locks here to serialize unregistration of a clock against
dereferencing members of posix_clocks[], but that would cause noticable overhead.
A better alternative might be to make it an RCU-protected array of pointers, and
use a rcu_assign_pointer/rcu_syncronize/kfree or call_rcu sequence in unregister_posix_clock.

Or you just live with not being able to unload this module.

	Arnd
