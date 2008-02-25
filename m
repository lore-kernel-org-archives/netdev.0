From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: printk_ratelimit and net_ratelimit conflict and tunable
 behavior
Date: Mon, 25 Feb 2008 15:45:21 -0800
Message-ID: <20080225154521.e119cbb6.akpm@linux-foundation.org>
References: <200802252036.m1PKaeMY012587@ftw.mot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, joe@perches.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Steven Hawkes <fsh016@ftw.mot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:46129 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755847AbYBYXrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 18:47:22 -0500
In-Reply-To: <200802252036.m1PKaeMY012587@ftw.mot.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 25 Feb 2008 14:36:40 -0600 Steven Hawkes <fsh016@ftw.mot.com> wrote:

> From: Steve Hawkes <steve.hawkes@motorola.com>
> 
> The printk_ratelimit() and net_ratelimit() functions each have their own
> tunable parameters to control their respective rate limiting feature, but
> they share common state variables, preventing independent tuning of the
> parameters from working correctly. Also, changes to rate limiting tunable
> parameters do not always take effect properly since state is not recomputed
> when changes occur. For example, if ratelimit_burst is increased while rate
> limiting is occurring, the change won't take full effect until at least
> enough time between messages occurs so that the toks value reaches
> ratelimit_burst * ratelimit_jiffies. This can result in messages being
> suppressed when they should be allowed.
> 
> Implement independent state for printk_ratelimit() and net_ratelimit(), and
> update state when tunables are changed.
> 

This patch causes a large and nasty reject.

> ---
> --- linux-2.6.24/include/linux/kernel.h	2008-01-24 16:58:37.000000000 -0600
> +++ linux-2.6.24-printk_ratelimit/include/linux/kernel.h	2008-02-21 11:20:41.751197312 -0600

Probably because you patched 2.6.24.  We're developing 2.6.25 now, and the
difference between the two is very large inded.  Please raise patches
against Linus's latest tree?

There are other patches pending against printk.c (in -mm and in git-sched)
but afacit they won't collide.

> @@ -196,8 +196,19 @@ static inline int log_buf_copy(char *des
>  
>  unsigned long int_sqrt(unsigned long);
>  
> +struct printk_ratelimit_state
> +{

Please do

struct printk_ratelimit_state {

> +	unsigned long toks;
> +	unsigned long last_jiffies;
> +	int missed;
> +	int limit_jiffies;
> +	int limit_burst;
> +	char const *facility;
> +};

I find that the best-value comments one can add to kernel code are to the
members of structures.  If the reader understands what all the fields do, the
code becomes simple to follow.

> --- linux-2.6.24/net/core/utils.c	2008-01-24 16:58:37.000000000 -0600
> +++ linux-2.6.24-printk_ratelimit/net/core/utils.c	2008-02-21 11:03:44.644337698 -0600
> @@ -41,7 +41,16 @@ EXPORT_SYMBOL(net_msg_warn);
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
> +	return __printk_ratelimit(net_msg_cost, net_msg_burst, &limit_state);

I don't get it.  There's one instance of limit_state, kernel-wide, and
__printk_ratelimit() modifies it.  What prevents one CPU's activities from
interfering with a second CPU's activities?

