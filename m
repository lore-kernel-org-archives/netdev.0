From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v2] extend taskstats API to support networking
 accounts
Date: Fri, 24 Feb 2012 03:05:10 +0000
Message-ID: <1330052710.2511.37.camel@bwh-desktop>
References: <4F45F73F.3000708@gmail.com>
	 <20120223.033434.1801978370536071654.davem@davemloft.net>
	 <4F46F941.1020401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:62578 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753026Ab2BXDFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 22:05:14 -0500
In-Reply-To: <4F46F941.1020401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-02-24 at 10:43 +0800, Li Yu wrote:
> This patch adds L7 traffic accounting in taskstats API, so
> the iotop like applications can receive these statistics data.
> In fact, I also have an iotop patch for this change.
> 
> It ignores any protocol header overhead, so results of this
> patch should be saw as the applications-aware data statistics
> instead of traffic statistics on wire.
> 
> The changes of v2 are:
> 
> 1. Move up accounting source code, so they are not protocol-aware now.
> 2. Skipping interrupt context accounting.
[...]
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1735,6 +1735,18 @@ static inline int skb_copy_to_page(struct sock 
> *sk, char __user *from,
>   	return 0;
>   }
> 
> +static inline void task_net_accounting_rx(unsigned int len)
> +{
> +	if (!in_irq() && len > 0)
> +		current->rx_bytes += len;
> +}
> +
> +static inline void task_net_accounting_tx(unsigned int len)
> +{
> +	if (!in_irq() && len > 0)
> +		current->tx_bytes += len;
> +}
[...]

These are only called from system calls, so why are you checking for IRQ
context?

> @@ -558,7 +559,10 @@ static inline int __sock_sendmsg_nosec(struct kiocb 
> *iocb, struct socket *sock,
>   	si->msg = msg;
>   	si->size = size;
> 
> -	return sock->ops->sendmsg(iocb, sock, msg, size);
> +	ret = sock->ops->sendmsg(iocb, sock, msg, size);
> +	task_net_accounting_tx(ret);
> +
> +	return ret;
>   }
[...]

So what happens to the totals when sendmsg() returns an error?

It seems to me that the parameter type for the accounting functions
should be ssize_t.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
