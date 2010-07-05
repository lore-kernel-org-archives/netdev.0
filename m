From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next-2.6] ipv6: adding ip_nonlocal_bind option from
 ipv4
Date: Mon, 5 Jul 2010 11:03:36 +0900
Message-ID: <20100705020333.GA14260@verge.net.au>
References: <201007032238.28344.michal.humpula@web4u.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Michal Humpula <michal.humpula@web4u.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:47370 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752494Ab0GECDi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jul 2010 22:03:38 -0400
Content-Disposition: inline
In-Reply-To: <201007032238.28344.michal.humpula@web4u.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 03, 2010 at 10:38:28PM +0200, Michal Humpula wrote:
> Adds ability to bind non-local IPv6 address the same way as for IPv4
> 
> Signed-off-by: Michal Humpula <michal.humpula@web4u.cz>
> 
> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
> index f350c69..27fa09a 100644
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -962,6 +962,10 @@ bindv6only - BOOLEAN
>  		FALSE: enable IPv4-mapped address feature
>  
>  	Default: FALSE (as specified in RFC2553bis)

I think a blank line here would be nice.

> +ipv6_nonlocal_bind - BOOLEAN
> +	If set, allows processes to bind() to non-local IPv6 addresses,
> +	which can be quite useful - but may break some applications.
> +	Default: 0
>  
>  IPv6 Fragmentation:
>  
> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> index 7bb5cb6..8957ead 100644
> --- a/include/linux/sysctl.h
> +++ b/include/linux/sysctl.h
> @@ -528,6 +528,7 @@ enum {
>  	NET_IPV6_IP6FRAG_TIME=23,
>  	NET_IPV6_IP6FRAG_SECRET_INTERVAL=24,
>  	NET_IPV6_MLD_MAX_MSF=25,
> +	NET_IPV6_NONLOCAL_BIND=26
>  };
>  
>  enum {
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index 1f84124..f459fcb 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -641,6 +641,8 @@ static inline int snmp6_unregister_dev(struct inet6_dev *idev) { return 0; }
>  #endif
>  
>  #ifdef CONFIG_SYSCTL
> +extern int sysctl_ipv6_nonlocal_bind;
> +
>  extern ctl_table ipv6_route_table_template[];
>  extern ctl_table ipv6_icmp_table_template[];
>  
> diff --git a/kernel/sysctl_binary.c b/kernel/sysctl_binary.c
> index 1357c57..525edae 100644
> --- a/kernel/sysctl_binary.c
> +++ b/kernel/sysctl_binary.c
> @@ -559,6 +559,7 @@ static const struct bin_table bin_net_ipv6_table[] = {
>  	{ CTL_DIR,	NET_IPV6_ROUTE,		"route",	bin_net_ipv6_route_table },
>  	{ CTL_DIR,	NET_IPV6_ICMP,		"icmp",		bin_net_ipv6_icmp_table },
>  	{ CTL_INT,	NET_IPV6_BINDV6ONLY,		"bindv6only" },
> +	{ CTL_INT,	NET_IPV6_NONLOCAL_BIND,		"ipv6_nonlocal_bind" },
>  	{ CTL_INT,	NET_IPV6_IP6FRAG_HIGH_THRESH,	"ip6frag_high_thresh" },
>  	{ CTL_INT,	NET_IPV6_IP6FRAG_LOW_THRESH,	"ip6frag_low_thresh" },
>  	{ CTL_INT,	NET_IPV6_IP6FRAG_TIME,		"ip6frag_time" },
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
>  int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
> @@ -345,8 +347,10 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
>  			if (!(addr_type & IPV6_ADDR_MULTICAST))	{
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

Perhaps the inner two if statements could be combined to remove
unnecessary nesting? And perhaps check for sysctl_ipv6_nonlocal_bind first,
as presumably its a cheaper, though less likely to succeed check.

			if (!(addr_type & IPV6_ADDR_MULTICAST))	{
				if (!sysctl_ipv6_nonlocal_bind &&
				    !ipv6_chk_addr(net, &addr->sin6_addr,
						   dev, 0)) {
					err = -EADDRNOTAVAIL;
					goto out_unlock;
				}
			}

Actually, I wonder if all three if statements could be combined.

			if (!(addr_type & IPV6_ADDR_MULTICAST) &&
		            !sysctl_ipv6_nonlocal_bind &&
			    !ipv6_chk_addr(net, &addr->sin6_addr, dev, 0)) {
				err = -EADDRNOTAVAIL;
				goto out_unlock;
			}

> diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
> index fa1d8f4..56bfe76 100644
> --- a/net/ipv6/sysctl_net_ipv6.c
> +++ b/net/ipv6/sysctl_net_ipv6.c
> @@ -35,6 +35,13 @@ static ctl_table ipv6_table_template[] = {
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec
>  	},
> +	{
> +		.procname = "ipv6_nonlocal_bind",
> +		.data   = &sysctl_ipv6_nonlocal_bind,
> +		.maxlen   = sizeof(int),
> +		.mode   = 0644,
> +		.proc_handler = proc_dointvec
> +	},
>  	{ }
>  };
>  
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
