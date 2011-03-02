From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH] sysctl: ipv6: use correct net in ipv6_sysctl_rtcache_flush
Date: Wed, 02 Mar 2011 11:25:18 +0800
Message-ID: <4D6DB89E.6010709@cn.fujitsu.com>
References: <1298612883-18762-1-git-send-email-lucian.grijincu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64368 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1757722Ab1CBD2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 22:28:22 -0500
In-Reply-To: <1298612883-18762-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lucian Adrian Grijincu wrote, at 02/25/2011 01:48 PM:
> Before this patch issuing these commands:
> 
>   fd = open("/proc/sys/net/ipv6/route/flush")
>   unshare(CLONE_NEWNET)
>   write(fd, "stuff")
> 
> would flush the newly created net, not the original one.

After appling your patch, when excuting above commands, 
router cache still not be flushed in init net namespace.
But IPv4 is ok.

Host1:                   Host2 
ping6 Host2
                        (shell1)                                 
			open(/proc/sys/net/ipv6/route/flush)
			unshare(CLONE_NEWNET)
			while(1) {write(fd, "stuff")}           


			(shell2)  
                        ip -6 route show cache <==1*
			1*: IPv6 will show one route cache entry.
			    But IPv4 shows nothing.

As changlog said, after this patch, shell1 only fulsh the original
net namespace, not the newly created one. But from shell2, we 
can see that IPv6 route cache is not flushed.

Have i missed something?


-- 
Best Regards
-----
Shan Wei

> 
> The equivalent ipv4 code is correct (stores the net inside ->extra1).
> ---
>  net/ipv6/route.c |   17 ++++++++++-------
>  1 files changed, 10 insertions(+), 7 deletions(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index f786aed..522563e 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -2604,14 +2604,16 @@ static
>  int ipv6_sysctl_rtcache_flush(ctl_table *ctl, int write,
>  			      void __user *buffer, size_t *lenp, loff_t *ppos)
>  {
> -	struct net *net = current->nsproxy->net_ns;
> -	int delay = net->ipv6.sysctl.flush_delay;
> -	if (write) {
> -		proc_dointvec(ctl, write, buffer, lenp, ppos);
> -		fib6_run_gc(delay <= 0 ? ~0UL : (unsigned long)delay, net);
> -		return 0;
> -	} else
> +	struct net *net;
> +	int delay;
> +	if (!write)
>  		return -EINVAL;
> +
> +	net = (struct net *)ctl->extra1;
> +	delay = net->ipv6.sysctl.flush_delay;
> +	proc_dointvec(ctl, write, buffer, lenp, ppos);
> +	fib6_run_gc(delay <= 0 ? ~0UL : (unsigned long)delay, net);
> +	return 0;
>  }
>  
>  ctl_table ipv6_route_table_template[] = {
> @@ -2698,6 +2700,7 @@ struct ctl_table * __net_init ipv6_route_sysctl_init(struct net *net)
>  
>  	if (table) {
>  		table[0].data = &net->ipv6.sysctl.flush_delay;
> +		table[0].extra1 = net;
>  		table[1].data = &net->ipv6.ip6_dst_ops.gc_thresh;
>  		table[2].data = &net->ipv6.sysctl.ip6_rt_max_size;
>  		table[3].data = &net->ipv6.sysctl.ip6_rt_gc_min_interval;

