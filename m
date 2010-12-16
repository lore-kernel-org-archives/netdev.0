From: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: [PATCH V7 4/8] posix clocks: hook dynamic clocks into system
 calls
Date: Fri, 17 Dec 2010 00:20:44 +0100 (CET)
Message-ID: <alpine.LFD.2.00.1012162156580.12146@localhost6.localdomain6>
References: <cover.1292512461.git.richard.cochran@omicron.at> <6241238a1df55033e50b151ec9d35ba957e43d53.1292512461.git.richard.cochran@omicron.at>
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
In-Reply-To: <6241238a1df55033e50b151ec9d35ba957e43d53.1292512461.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 16 Dec 2010, Richard Cochran wrote:

Can you please split this into infrastructure and conversion of
posix-timer.c ?

> diff --git a/include/linux/posix-clock.h b/include/linux/posix-clock.h
> index 1ce7fb7..7ea94f5 100644
> --- a/include/linux/posix-clock.h
> +++ b/include/linux/posix-clock.h
> @@ -108,4 +108,29 @@ struct posix_clock *posix_clock_create(struct posix_clock_operations *cops,
>   */
>  void posix_clock_destroy(struct posix_clock *clk);
>  
> +/**
> + * clockid_to_posix_clock() - obtain clock device pointer from a clock id
> + * @id: user space clock id
> + *
> + * Returns a pointer to the clock device, or NULL if the id is not a
> + * dynamic clock id.
> + */
> +struct posix_clock *clockid_to_posix_clock(clockid_t id);
> +
> +/*
> + * The following functions are only to be called from posix-timers.c
> + */

Then they should be in a header file which is not consumable by the
general public. e.g. kernel/time/posix-clock.h

> +int pc_clock_adjtime(struct posix_clock *clk, struct timex *tx);
> +int pc_clock_gettime(struct posix_clock *clk, struct timespec *ts);
> +int pc_clock_getres(struct posix_clock *clk, struct timespec *ts);
> +int pc_clock_settime(struct posix_clock *clk, const struct timespec *ts);
> +
> +int pc_timer_create(struct posix_clock *clk, struct k_itimer *kit);
> +int pc_timer_delete(struct posix_clock *clk, struct k_itimer *kit);
> +
> +void pc_timer_gettime(struct posix_clock *clk, struct k_itimer *kit,
> +		      struct itimerspec *ts);
> +int pc_timer_settime(struct posix_clock *clk, struct k_itimer *kit,
> +		     int flags, struct itimerspec *ts, struct itimerspec *old);
> +
>  #endif
> +
> +static inline bool clock_is_static(const clockid_t id)
> +{
> +	if (0 == (id & ~CLOCKFD_MASK))
> +		return true;
> +	if (CLOCKFD == (id & CLOCKFD_MASK))
> +		return false;

Please use the usual kernel notation.

> +	return true;
> +}
> +
>  /* POSIX.1b interval timer structure. */
>  struct k_itimer {
>  	struct list_head list;		/* free/ allocate list */
> diff --git a/include/linux/time.h b/include/linux/time.h
> index 9f15ac7..914c48d 100644
> --- a/include/linux/time.h
> +++ b/include/linux/time.h
> @@ -299,6 +299,8 @@ struct itimerval {
>  #define CLOCKS_MASK			(CLOCK_REALTIME | CLOCK_MONOTONIC)
>  #define CLOCKS_MONO			CLOCK_MONOTONIC
>  
> +#define CLOCK_INVALID			-1
> +
> @@ -712,6 +720,7 @@ common_timer_get(struct k_itimer *timr, struct itimerspec *cur_setting)
>  SYSCALL_DEFINE2(timer_gettime, timer_t, timer_id,
>  		struct itimerspec __user *, setting)
>  {
> +	struct posix_clock *clk_dev;
>  	struct k_itimer *timr;
>  	struct itimerspec cur_setting;
>  	unsigned long flags;
> @@ -720,7 +729,15 @@ SYSCALL_DEFINE2(timer_gettime, timer_t, timer_id,
>  	if (!timr)
>  		return -EINVAL;
>  
> -	CLOCK_DISPATCH(timr->it_clock, timer_get, (timr, &cur_setting));
> +	if (likely(clock_is_static(timr->it_clock))) {
> +
> +		CLOCK_DISPATCH(timr->it_clock, timer_get, (timr, &cur_setting));
> +
> +	} else {
> +		clk_dev = clockid_to_posix_clock(timr->it_clock);
> +		if (clk_dev)
> +			pc_timer_gettime(clk_dev, timr, &cur_setting);

Why this extra step ? Why can't you call 

      pc_timer_gettime(timr, &cur_setting);

You already established that the timer is fd based, so let the
pc_timer_* functions deal with it.

> +	}
>  
>  	unlock_timer(timr, flags);
>  
> @@ -811,6 +828,7 @@ SYSCALL_DEFINE4(timer_settime, timer_t, timer_id, int, flags,
>  		const struct itimerspec __user *, new_setting,
>  		struct itimerspec __user *, old_setting)
>  {
> +	struct posix_clock *clk_dev;
>  	struct k_itimer *timr;
>  	struct itimerspec new_spec, old_spec;
>  	int error = 0;
> @@ -831,8 +849,19 @@ retry:
>  	if (!timr)
>  		return -EINVAL;
>  
> -	error = CLOCK_DISPATCH(timr->it_clock, timer_set,
> -			       (timr, flags, &new_spec, rtn));
> +	if (likely(clock_is_static(timr->it_clock))) {
> +
> +		error = CLOCK_DISPATCH(timr->it_clock, timer_set,
> +				       (timr, flags, &new_spec, rtn));
> +
> +	} else {
> +		clk_dev = clockid_to_posix_clock(timr->it_clock);
> +		if (clk_dev)
> +			error = pc_timer_settime(clk_dev, timr,
> +						 flags, &new_spec, rtn);
> +		else
> +			error = -EINVAL;
 
 Ditto. pc_timer_settime() can return -EINVAL when there is no valid fd.

> @@ -957,26 +993,51 @@ EXPORT_SYMBOL_GPL(do_posix_clock_nonanosleep);
>  SYSCALL_DEFINE2(clock_settime, const clockid_t, which_clock,
>  		const struct timespec __user *, tp)
>  {
> +	struct posix_clock *clk_dev = NULL;
>  	struct timespec new_tp;
>  
> -	if (invalid_clockid(which_clock))
> -		return -EINVAL;
> +	if (likely(clock_is_static(which_clock))) {
> +
> +		if (invalid_clockid(which_clock))
> +			return -EINVAL;
> +	} else {
> +		clk_dev = clockid_to_posix_clock(which_clock);
> +		if (!clk_dev)
> +			return -EINVAL;
> +	}

It's not a problem to check the validity of that clock fd after the
copy_from_user. That's an error case and we don't care about whether
we return EINVAL here or later. And with your current code this can
happen anyway as you don't hold a reference to the fd. And we do the
same thing for posix_cpu_timers as well. See invalid_clockid()

>  	if (copy_from_user(&new_tp, tp, sizeof (*tp)))
>  		return -EFAULT;
>  
> +	if (unlikely(clk_dev))
> +		return pc_clock_settime(clk_dev, &new_tp);
> +
>  	return CLOCK_DISPATCH(which_clock, clock_set, (which_clock, &new_tp));

I really start to wonder whether we should cleanup that whole
CLOCK_DISPATCH macro magic and provide real inline functions for
each of the clock functions instead.

static inline int dispatch_clock_settime(const clockid_t id, struct timespec *tp)
{
	if (id >= 0) {
	   	return posix_clocks[id].clock_set ?
		        posic_clocks[id].clock_set(id, tp) : -EINVAL;
	}
	if (posix_cpu_clock(id))
		return -EINVAL;

	return pc_timers_clock_set(id, tp);
}

That is a bit of work, but the code will be simpler and we just do the
normal thing of function pointer structures. Stuff which is not
implemented does not magically become called via some common
function. There is no point in doing that. We just have to fill in the
various k_clock structs with the correct pointers in the first place
and let the NULL case return a sensible error value. The data
structure does not become larger that way. It's a little bit more init
code, but that's fine if we make the code better in general. In that
case it's not even more init code, it's just filling the data
structures which we register.

That needs to be done in two steps:

   1) cleanup CLOCK_DISPATCH
   2) add the pc_timer_* extras

That will make the thing way more palatable than working around the
restrictions of CLOCK_DISPATCH and adding the hell to each syscall.

The second step would be a patch consisting of exactly nine lines:

 {
	if (id >= 0)
	        return .....
	if (posix_cpu_clock_id(id))
		return ....
-	return -EINVAL;
+	return pc_timer_xxx(...);
 }

Please don't tell me now that we could even hack this into
CLOCK_DISPATCH. *shudder*

> +
> +struct posix_clock *clockid_to_posix_clock(const clockid_t id)
> +{
> +	struct posix_clock *clk = NULL;
> +	struct file *fp;
> +
> +	if (clock_is_static(id))
> +		return NULL;
> +
> +	fp = fget(CLOCKID_TO_FD(id));
> +	if (!fp)
> +		return NULL;
> +
> +	if (fp->f_op->open == posix_clock_open)
> +		clk = fp->private_data;
> +
> +	fput(fp);
> +	return clk;
> +}
> +
> +int pc_clock_adjtime(struct posix_clock *clk, struct timex *tx)
> +{
> +	int err;
> +
> +	mutex_lock(&clk->mux);
> +
> +	if (clk->zombie)

Uuurgh. That explains the zombie thing. That's really horrible and we
can be more clever. When we leave the file lookup to the pc_timer_*
functions, then we can simply do:

struct posix_clock_descr {
       struct file *fp;
       struct posix_clock *clk;
};

static int get_posix_clock(const clockid_t id, struct posix_clock_descr *cd)
{
	struct file *fp = fget(CLOCKID_TO_FD(id));

	if (!fp || fp->f_op->open != posix_clock_open || !fp->private_data)
	   	return -ENODEV;
	cd->fp = fp;
	cd->clk = fp->private_data;
	return 0;
}

static void put_posix_clock(struct posix_clock_descr *cd)
{
	fput(cd->fp);
}

int pc_timer_****(....)
{
	struct posix_clock_descr cd;
	ret = -EOPNOTSUPP;

	if (get_posix_clock(id, &cd))
		return -ENODEV;
		
	if (cd.clk->ops->whatever)
		ret = cd.clk->ops->whatever(....);

	put_posix_clock(&cd);
	return ret;
}

That get's rid of your life time problems, of clk->mutex, clock->zombie
and makes the code simpler and more robust. And it avoids the whole
mess in posix-timers.c as well.

> +		err = -ENODEV;
> +	else if (!clk->ops->clock_adjtime)
> +		err = -EOPNOTSUPP;
> +	else
> +		err = clk->ops->clock_adjtime(clk->priv, tx);
> +
> +	mutex_unlock(&clk->mux);
> +	return err;
> +}

Though all this feels still a bit backwards.

The whole point of this exercise is to provide dynamic clock ids and
make them available via the standard posix timer interface and aside
of that have standard file operations for these clocks to provide
special purpose ioctls, mmap and whatever. And to make it a bit more
complex these must be removable modules.

I need to read back the previous discussions, but maybe someone can
fill me in why we can't make these dynamic things not just live in
posix_clocks[MAX_CLOCKS ... MAX_DYNAMIC_CLOCKS] (there is no
requirement to have an unlimited number of those) and just get a
mapping from the fd to the clock_id? That creates a different set of
life time problems, but no real horrible ones.

Thanks,

	tglx
