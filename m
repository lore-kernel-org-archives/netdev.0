From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Customizable TCP backoff patch
Date: Thu, 12 Oct 2006 10:06:15 +0900 (JST)
Message-ID: <20061012.100615.18914547.yoshfuji@linux-ipv6.org>
References: <452C4D12.9060102@redhat.com>
	<452CF94B.9000309@hp.com>
	<452D918C.6050300@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, davem@davemloft.net,
	netdev@vger.kernel.org, mgrondona@llnl.gov, behlendorf1@llnl.gov,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:2570 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S965241AbWJLBDt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Oct 2006 21:03:49 -0400
To: woodard@redhat.com
In-Reply-To: <452D918C.6050300@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <452D918C.6050300@redhat.com> (at Wed, 11 Oct 2006 17:51:24 -0700), Ben Woodard <woodard@redhat.com> says:

> diff -ru linux-2.6.18/net/ipv4/sysctl_net_ipv4.c linux-2.6.18.new/net/ipv4/sysctl_net_ipv4.c
> --- linux-2.6.18/net/ipv4/sysctl_net_ipv4.c	2006-09-19 20:42:06.000000000 -0700
> +++ linux-2.6.18.new/net/ipv4/sysctl_net_ipv4.c	2006-10-11 16:00:37.000000000 -0700
> @@ -128,6 +128,8 @@
>  	return ret;
>  }
>  
> +static unsigned long tcp_rto_min=0;
> +static unsigned long tcp_rto_max=65535;
>  
>  ctl_table ipv4_table[] = {
>          {
> @@ -697,6 +699,26 @@
>  		.mode		= 0644,
>  		.proc_handler	= &proc_dointvec
>  	},
> +	{
> +		.ctl_name	= NET_TCP_RTO_MAX,
> +		.procname	= "tcp_rto_max",
> +		.data		= &sysctl_tcp_rto_max,
> +		.maxlen		= sizeof(unsigned),

sizeof(unsigned long)

> +		.mode		= 0644,
> +		.proc_handler	= &proc_doulongvec_ms_jiffies_minmax,
> +		.extra1		= &tcp_rto_min_constant,
> +		.extra2		= &tcp_rto_max_constant,
> +	},
> +	{
> +		.ctl_name	= NET_TCP_RTO_INIT,
> +		.procname	= "tcp_rto_init",
> +		.data		= &sysctl_tcp_rto_init,
> +		.maxlen		= sizeof(unsigned),

sizeof(unsigned long)

> +		.mode		= 0644,
> +		.proc_handler	= &proc_doulongvec_ms_jiffies_minmax,
> +		.extra1		= &tcp_rto_min_constant,
> +		.extra2		= &tcp_rto_max_constant,
> +	},
>  	{ .ctl_name = 0 }
>  };
>  
> diff -ru linux-2.6.18/net/ipv4/tcp.c linux-2.6.18.new/net/ipv4/tcp.c
> --- linux-2.6.18/net/ipv4/tcp.c	2006-09-19 20:42:06.000000000 -0700
> +++ linux-2.6.18.new/net/ipv4/tcp.c	2006-10-11 16:00:37.000000000 -0700
> @@ -1764,6 +1764,8 @@
>  	return err;
>  }
>  
> +#define TCP_BACKOFF_MAXVAL 65535
> +
>  /*
>   *	Socket option code for TCP.
>   */
> @@ -1939,6 +1941,20 @@
>  		}
>  		break;
>  
> +	case TCP_BACKOFF_MAX:
> +		if (val < 1 || val > TCP_BACKOFF_MAXVAL)
> +			err = -EINVAL;
> +		else
> +			tp->rto_max = val;
> +		break;
> + 
> +	case TCP_BACKOFF_INIT:
> +		if (val < 1 || val > TCP_BACKOFF_MAXVAL)
> +			err = -EINVAL;
> +		else
> +			tp->rto_init = val;
> +		break;
> + 
>  	default:
>  		err = -ENOPROTOOPT;
>  		break;
> @@ -2110,6 +2126,12 @@
>  		if (copy_to_user(optval, icsk->icsk_ca_ops->name, len))
>  			return -EFAULT;
>  		return 0;
> +	case TCP_BACKOFF_MAX:
> +		val = jiffies_to_msecs(tcp_rto_max(tp));
> +		break;

tp->rto_max

> +	case TCP_BACKOFF_INIT:
> +		val = jiffies_to_msecs(tcp_rto_init(tp));
> +		break;
>  	default:

tp->rto_init

--yoshfuji
