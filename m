From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v2] dummy: fix rcu_sched self-detected stalls
Date: Mon, 11 Jun 2012 09:51:15 -0700
Message-ID: <20120611095115.22afbd1b@s6510.linuxnetplumber.net>
References: <1339239546.6001.177.camel@edumazet-glaptop>
	<20120610.224800.602807319671005890.davem@davemloft.net>
	<1339398717.6001.1538.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52708 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750877Ab2FKQvU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 12:51:20 -0400
In-Reply-To: <1339398717.6001.1538.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Jun 2012 09:11:57 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Trying to "modprobe dummy numdummies=30000" triggers :
> 
> INFO: rcu_sched self-detected stall on CPU { 8} (t=60000 jiffies)
> 
> After this splat, RTNL is locked and reboot is needed.
> 
> We must call cond_resched() to avoid this, even holding RTNL.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/dummy.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
> index 442d91a..bab0158 100644
> --- a/drivers/net/dummy.c
> +++ b/drivers/net/dummy.c
> @@ -187,8 +187,10 @@ static int __init dummy_init_module(void)
>  	rtnl_lock();
>  	err = __rtnl_link_register(&dummy_link_ops);
>  
> -	for (i = 0; i < numdummies && !err; i++)
> +	for (i = 0; i < numdummies && !err; i++) {
>  		err = dummy_init_one();
> +		cond_resched();
> +	}
>  	if (err < 0)
>  		__rtnl_link_unregister(&dummy_link_ops);
>  	rtnl_unlock();
> 


Rather than holding lock for the whole loop, why not reacquire
each time to keep from holding off everything els.
