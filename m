From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH v7 net-next 2/5] net: implement support for low latency
 socket polling
Date: Thu, 30 May 2013 18:07:27 +0300
Message-ID: <51A76B2F.8010904@mellanox.com>
References: <20130530114045.12653.79183.stgit@ladj378.jer.intel.com> <20130530114111.12653.25023.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	<e1000-devel@lists.sourceforge.net>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:45635 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933425Ab3E3PJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 11:09:27 -0400
In-Reply-To: <20130530114111.12653.25023.stgit@ladj378.jer.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/05/2013 14:41, Eliezer Tamir wrote:
> diff --git a/fs/select.c b/fs/select.c
> index 8c1c96c..f116bf0 100644
> --- a/fs/select.c
> +++ b/fs/select.c
> @@ -27,6 +27,7 @@
>  #include <linux/rcupdate.h>
>  #include <linux/hrtimer.h>
>  #include <linux/sched/rt.h>
> +#include <net/ll_poll.h>
>  
>  #include <asm/uaccess.h>
>  
> @@ -400,6 +401,7 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
>  	poll_table *wait;
>  	int retval, i, timed_out = 0;
>  	unsigned long slack = 0;
> +	cycles_t ll_time = ll_end_time();
>  
>  	rcu_read_lock();
>  	retval = max_select_fd(n, fds);
> @@ -486,6 +488,8 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
>  			break;
>  		}
>  
> +		if (can_poll_ll(ll_time))
> +			continue;
I don't see here discrimination between sockets that you want to poll
and other sockets.
So it means that select will busy poll every type of file descriptor
instead of going to sleep.
Should have a condition with something like sk_valid_ll()

>  		/*
>  		 * If this is the first loop and we have a timeout
>  		 * given, then we convert to ktime_t and set the to


...

> +static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
> +{
> +}
> +
> +static inline bool can_poll_ll(unsigned long end_time)
should use here cycles_t too.

> +{
> +	return false;
> +}
> +
> +#endif /* CONFIG_NET_LL_RX_POLL */
> +#endif /* _LINUX_NET_LL_POLL_H */


Also, something general about this patch. I think you should split out
to separate patches all the users of the feature, like you did for TCP.
I would suggest small patches for UDP, select and poll.

Thanks,
Amir
