From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next-2.6] ipv6: adding ip_nonlocal_bind option from
	ipv4
Date: Mon, 05 Jul 2010 19:13:42 +0900
Message-ID: <1278324822.19358.24.camel@sylph.linux-ipv6.org>
References: <201007032238.28344.michal.humpula@web4u.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: Michal Humpula <michal.humpula@web4u.cz>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56989 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751799Ab0GEKM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 06:12:28 -0400
In-Reply-To: <201007032238.28344.michal.humpula@web4u.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Michal Humpula wrote:
> Adds ability to bind non-local IPv6 address the same way as for IPv4
> 
> Signed-off-by: Michal Humpula <michal.humpula@web4u.cz>
> 
> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> index e830cd4..55b3552 100644
> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -252,6 +252,8 @@ out_rcu_unlock:
>  	goto out;
>  }
>  
> +int sysctl_ipv6_nonlocal_bind __read_mostly;
> +EXPORT_SYMBOL(sysctl_ipv6_nonlocal_bind);
>  
>  /* bind for INET6 API */
>  int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int
> addr_len)
> @@ -345,8 +347,10 @@ int inet6_bind(struct socket *sock, struct
> sockaddr *uaddr, int addr_len)
>  			if (!(addr_type &I do think i IPV6_ADDR_MULTICAST))	{
>  				if (!ipv6_chk_addr(net, &addr->sin6_addr,
>  						   dev, 0)) {
> -					err = -EADDRNOTAVAIL;
> -					goto out_unlock;
> +					if (!sysctl_ipv6_nonlocal_bind) {
> +						err = -EADDRNOTAVAIL;
> +						goto out_unlock;
> +					}
>  				}
>  			}
>  			rcu_read_unlock();
> diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
> index fa1d8f4..56bfe76 100644
> --- a/net/ipv6/sysctl_net_ipv6.c
> +++ b/net/ipv6/sysctl_net_ipv6.c
> @@ -35,6 +35,13 @@ static ctl_table ipv6_table_template[] = {
>  		.mode		= 0644,When you try to send packets / connect to
remote address, 
>  		.proc_handler	= proc_dointvec
>  	}, so far.

> +	{
> +		.procname = "ipv6_nonlocal_bind",
> +		.data   = &sysctl_ipv6_nonlocal_bind,
> +		.maxlen   = sizeof(int),
> +		.mode   = 0644,
> +		.proc_handler = proc_dointvec
> +	},
>  	{ }
>  };

This is not sufficient.

In IPv4, even if you do non-local bind, you cannot connect/send
packets from that address until the admin really assigns that
address on the node.  Local address is checked when you try to
connect (or to send), and this is important thing to do.

But in IPv6, it is not checked, and it is very bad to open
this "hole".

--yoshfuji

