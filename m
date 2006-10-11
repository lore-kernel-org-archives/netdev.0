From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] Customizable TCP backoff patch
Date: Wed, 11 Oct 2006 10:01:47 -0400
Message-ID: <452CF94B.9000309@hp.com>
References: <451AC889.5000407@redhat.com>	<20060927.161638.62343616.davem@davemloft.net>	<4522A88E.2070200@redhat.com> <20061004.000722.99203823.davem@davemloft.net> <452C4D12.9060102@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mgrondona@llnl.gov, behlendorf1@llnl.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:6087 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1030208AbWJKOB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 10:01:56 -0400
To: Ben Woodard <woodard@redhat.com>
In-Reply-To: <452C4D12.9060102@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Woodard wrote:
 ------------------------------------------------------------------------
> diff -ru linux-2.6.18/include/net/tcp.h linux-2.6.18.new/include/net/tcp.h
> --- linux-2.6.18/include/net/tcp.h	2006-09-19 20:42:06.000000000 -0700
> +++ linux-2.6.18.new/include/net/tcp.h	2006-10-10 18:42:00.000000000 -0700
> @@ -227,11 +227,23 @@
>  extern int sysctl_tcp_base_mss;
>  extern int sysctl_tcp_workaround_signed_windows;
>  extern int sysctl_tcp_slow_start_after_idle;
> +extern unsigned long sysctl_tcp_rto_max;
> +extern unsigned long sysctl_tcp_rto_init;
>  
>  extern atomic_t tcp_memory_allocated;
>  extern atomic_t tcp_sockets_allocated;
>  extern int tcp_memory_pressure;
>  
> +static inline unsigned long tcp_rto_max(struct tcp_sock *tp)
> +{
> +        return tp->rto_max ? tp->rto_max*HZ/1000 : sysctl_tcp_rto_max;
                                ^^^^^^^^^^^^^^^^^^^
That should probably be msecs_to_jiffies(tp->rto_max)

> +}
> +
> +static inline unsigned long tcp_rto_init(struct tcp_sock *tp)
> +{
> +        return tp->rto_init ? tp->rto_init*HZ/1000 : sysctl_tcp_rto_init;

Ditto.

> +}
> +
>  /*
>   * The next routines deal with comparing 32 bit unsigned ints
>   * and worry about wraparound (automatic with unsigned arithmetic).
> diff -ru linux-2.6.18/net/ipv4/sysctl_net_ipv4.c linux-2.6.18.new/net/ipv4/sysctl_net_ipv4.c
> --- linux-2.6.18/net/ipv4/sysctl_net_ipv4.c	2006-09-19 20:42:06.000000000 -0700
> +++ linux-2.6.18.new/net/ipv4/sysctl_net_ipv4.c	2006-10-10 16:32:08.000000000 -0700
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
> +	        .ctl_name       = NET_TCP_RTO_MAX,
> +		.procname       = "tcp_rto_max",
> +		.data           = &sysctl_tcp_rto_max,
> +		.maxlen         = sizeof(unsigned),
> +		.mode           = 0644,
> +		.proc_handler   = &proc_doulongvec_ms_jiffies,
> +		.extra1         = &tcp_rto_min_constant,
> +		.extra2         = &tcp_rto_max_constant,
> +	},
> +	{
> +	        .ctl_name       = NET_TCP_RTO_INIT,
> +		.procname       = "tcp_rto_init",
> +		.data           = &sysctl_tcp_rto_init,
> +		.maxlen         = sizeof(unsigned),
> +		.mode           = 0644,
> +		.proc_handler   = &proc_doulongvec_ms_jiffies,
> +		.extra1         = &tcp_rto_min_constant,
> +		.extra2         = &tcp_rto_max_constant,
> +	},
>  	{ .ctl_name = 0 }
>  };

Try as I might, I can't find proc_doulongvec_ms_jiffies() anywhere.  I think
you meant proc_doulongvec_ms_jiffies_minmax()?

Also, this function has a bug in that it doesn't do corrections for potentially different
HZ values.  Look at the msecs_to_jiffies...  When I've used proc_doulongvec_ms_jiffies_minmax()
before, I would seen rather interesting truncation errors such that sysctl input didn't match
sysctl output.

>  
> diff -ru linux-2.6.18/net/ipv4/tcp.c linux-2.6.18.new/net/ipv4/tcp.c
> --- linux-2.6.18/net/ipv4/tcp.c	2006-09-19 20:42:06.000000000 -0700
> +++ linux-2.6.18.new/net/ipv4/tcp.c	2006-10-10 18:37:40.000000000 -0700
> @@ -1764,6 +1764,8 @@
>  	return err;
>  }
>  
> +#define TCP_BACKOFF_MAXVAL 65535
> +
>  /*
>   *	Socket option code for TCP.
>   */
> @@ -1939,6 +1941,21 @@
>  		}
>  		break;
>  
> +        case TCP_BACKOFF_MAX:
> +                if (val < 1 || val > TCP_BACKOFF_MAXVAL)
> +                        err = -EINVAL;
> +                else
> +                        tp->rto_max = val;
> +                break;
> + 
> +        case TCP_BACKOFF_INIT:
> +                if (val < 1 || val > TCP_BACKOFF_MAXVAL)
> +                        err = -EINVAL;
> +                else
> +                        tp->rto_init = val;
> +                break;
> + 
> + 
>  	default:
>  		err = -ENOPROTOOPT;
>  		break;
> @@ -2110,6 +2127,12 @@
>  		if (copy_to_user(optval, icsk->icsk_ca_ops->name, len))
>  			return -EFAULT;
>  		return 0;
> +        case TCP_BACKOFF_MAX:
> +	        val = tcp_rto_max(tp)*1000/HZ;
> +                break;
> +        case TCP_BACKOFF_INIT:
> +	        val = tcp_rto_init(tp)*1000/HZ;

The two divisions above introduce truncation errors such the input doesn't
match the output.  Better to use jiffies_to_msecs().

Regards
-vlad
