From: David Miller <davem@davemloft.net>
Subject: Re: printk_ratelimit and net_ratelimit conflict and tunable
 behavior
Date: Wed, 20 Feb 2008 22:32:19 -0800 (PST)
Message-ID: <20080220.223219.165157596.davem@davemloft.net>
References: <7BFDACCD6948EF4D8FE8F4888A91596A016371E8@tx14exm60.ds.mot.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Steve.Hawkes@motorola.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762128AbYBUGb4@vger.kernel.org>
In-Reply-To: <7BFDACCD6948EF4D8FE8F4888A91596A016371E8@tx14exm60.ds.mot.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Hawkes Steve-FSH016" <Steve.Hawkes@motorola.com>
Date: Tue, 19 Feb 2008 15:30:51 -0600

[ netdev CC:'d ]

> The printk_ratelimit() and net_ratelimit() functions are coupled and
> interfere with each other. Each has their own tunable parameters to
> control their respective rate limiting feature, but they share common
> state variables, causing the rate limiting to behave in an unexpected
> fashion when the tunables for each are set to different values.
> 
> Also, changes to rate limiting tunable parameters do not always take
> effect
> properly since state is not recomputed when changes occur. For example,
> if
> the ratelimit_burst tunable value is increased while rate limiting
> is occurring, the change doesn't take full effect until at least enough
> time between messages occurs so that the toks value reaches
> ratelimit_burst * ratelimit_jiffies. This can result in messages being
> suppressed when they should be allowed.

This looks fine to me, please provide a proper "Signed-off-by: " as
described in linux/Documentation/SubmittingPatches

Thanks.

> diff -Naup OLD/include/linux/kernel.h NEW/include/linux/kernel.h
> --- OLD/include/linux/kernel.h	2008-02-19 10:02:07.461496000 -0600
> +++ NEW/include/linux/kernel.h	2008-02-19 10:45:32.858306000 -0600
> @@ -196,8 +196,20 @@ static inline int log_buf_copy(char *des
>  
>  unsigned long int_sqrt(unsigned long);
>  
> +struct printk_ratelimit_state
> +{
> +	unsigned long toks;
> +	unsigned long last_jiffies;
> +	int missed;
> +	int limit_jiffies;
> +	int limit_burst;
> +	char const *facility;
> +};
> +
> +extern int __printk_ratelimit(int ratelimit_jiffies,
> +			      int ratelimit_burst,
> +			      struct printk_ratelimit_state *state);
>  extern int printk_ratelimit(void);
> -extern int __printk_ratelimit(int ratelimit_jiffies, int
> ratelimit_burst);
>  extern bool printk_timed_ratelimit(unsigned long *caller_jiffies,
>  				unsigned int interval_msec);
>  
> diff -Naup OLD/net/core/utils.c NEW/net/core/utils.c
> --- OLD/net/core/utils.c	2008-02-19 10:01:26.442370000 -0600
> +++ NEW/net/core/utils.c	2008-02-19 10:46:45.026731000 -0600
> @@ -41,7 +41,18 @@ EXPORT_SYMBOL(net_msg_warn);
>   */
>  int net_ratelimit(void)
>  {
> -	return __printk_ratelimit(net_msg_cost, net_msg_burst);
> +	static struct printk_ratelimit_state limit_state = {
> +		.toks          = 10 * 5 * HZ,
> +		.last_jiffies  = 0,
> +		.missed        = 0,
> +		.limit_jiffies = 5 * HZ,
> +		.limit_burst   = 10,
> +		.facility      = "net"
> +	};
> +
> +	return __printk_ratelimit(net_msg_cost,
> +				  net_msg_burst,
> +				  &limit_state);
>  }
>  EXPORT_SYMBOL(net_ratelimit);
>  
> diff -Naup OLD/kernel/printk.c NEW/kernel/print.c
> --- OLD/kernel/printk.c	2008-02-19 10:00:47.359068000 -0600
> +++ NEW/kernel/printk.c	2008-02-19 10:46:30.748743000 -0600
> @@ -1236,37 +1236,47 @@ void tty_write_message(struct tty_struct
>  }
>  
>  /*
> - * printk rate limiting, lifted from the networking subsystem.
> + * printk rate limiting.
>   *
> - * This enforces a rate limit: not more than one kernel message
> - * every printk_ratelimit_jiffies to make a denial-of-service
> - * attack impossible.
> + * This enforces a rate limit to mitigate denial-of-service attacks:
> + * not more than ratelimit_burst messages every ratelimit_jiffies.
>   */
> -int __printk_ratelimit(int ratelimit_jiffies, int ratelimit_burst)
> +int __printk_ratelimit(int ratelimit_jiffies,
> +		       int ratelimit_burst,
> +		       struct printk_ratelimit_state *state)
>  {
>  	static DEFINE_SPINLOCK(ratelimit_lock);
> -	static unsigned long toks = 10 * 5 * HZ;
> -	static unsigned long last_msg;
> -	static int missed;
>  	unsigned long flags;
>  	unsigned long now = jiffies;
>  
>  	spin_lock_irqsave(&ratelimit_lock, flags);
> -	toks += now - last_msg;
> -	last_msg = now;
> -	if (toks > (ratelimit_burst * ratelimit_jiffies))
> -		toks = ratelimit_burst * ratelimit_jiffies;
> -	if (toks >= ratelimit_jiffies) {
> -		int lost = missed;
> -
> -		missed = 0;
> -		toks -= ratelimit_jiffies;
> +	state->toks += now - state->last_jiffies;
> +	/* Reset limiting if tunables changed */
> +	if ((state->limit_jiffies != ratelimit_jiffies) ||
> +	    (state->limit_burst != ratelimit_burst)) {
> +		state->toks = ratelimit_burst * ratelimit_jiffies;
> +		state->limit_jiffies = ratelimit_jiffies;
> +		state->limit_burst = ratelimit_burst;
> +	}
> +	state->last_jiffies = now;
> +	if (state->toks > (ratelimit_burst * ratelimit_jiffies))
> +		state->toks = ratelimit_burst * ratelimit_jiffies;
> +	if (state->toks >= ratelimit_jiffies) {
> +		int lost = state->missed;
> +		state->missed = 0;
> +		state->toks -= ratelimit_jiffies;
>  		spin_unlock_irqrestore(&ratelimit_lock, flags);
> -		if (lost)
> -			printk(KERN_WARNING "printk: %d messages
> suppressed.\n", lost);
> +		if (lost) {
> +			printk(KERN_WARNING
> +			       "printk: %d %s%smessage%s suppressed.\n",
> +			       lost,
> +			       (state->facility == 0 ? "" :
> state->facility),
> +			       (state->facility == 0 ? "" : " "),
> +			       (lost > 1 ? "s" : ""));
> +		}
>  		return 1;
>  	}
> -	missed++;
> +	state->missed++;
>  	spin_unlock_irqrestore(&ratelimit_lock, flags);
>  	return 0;
>  }
> @@ -1280,8 +1290,18 @@ int printk_ratelimit_burst = 10;
>  
>  int printk_ratelimit(void)
>  {
> +	static struct printk_ratelimit_state limit_state = {
> +		.toks          = 10 * 5 * HZ,
> +		.last_jiffies  = 0,
> +		.missed        = 0,
> +		.limit_jiffies = 5 * HZ,
> +		.limit_burst   = 10,
> +		.facility      = 0
> +	};
> +
>  	return __printk_ratelimit(printk_ratelimit_jiffies,
> -				printk_ratelimit_burst);
> +				  printk_ratelimit_burst,
> +				  &limit_state);
>  }
>  EXPORT_SYMBOL(printk_ratelimit);
>  
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
