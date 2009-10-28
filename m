From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 3/3] net: TCP thin dupack
Date: Wed, 28 Oct 2009 16:17:36 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0910281611290.19761@wel-95.cs.helsinki.fi>
References: <4AE7207D.8090402@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>
To: Andreas Petlund <apetlund@simula.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33428 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753680AbZJ1ORc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 10:17:32 -0400
In-Reply-To: <4AE7207D.8090402@simula.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Oct 2009, Andreas Petlund wrote:

> This patch enables fast retransmissions after one dupACK for TCP if the 
> stream is identified as thin. This will reduce latencies for thin 
> streams that are not able to trigger fast retransmissions due to high 
> packet interarrival time. This mechanism is only active if enabled by 
> iocontrol or syscontrol and the stream is identified as thin. 
> 
> 
> Signed-off-by: Andreas Petlund <apetlund@simula.no>
> ---
>  include/linux/tcp.h        |    4 +++-
>  include/net/tcp.h          |    1 +
>  net/ipv4/sysctl_net_ipv4.c |    8 ++++++++
>  net/ipv4/tcp.c             |    5 +++++
>  net/ipv4/tcp_input.c       |    8 ++++++++
>  5 files changed, 25 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index e64368d..f4a05ff 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -97,6 +97,7 @@ enum {
>  #define TCP_CONGESTION		13	/* Congestion control algorithm */
>  #define TCP_MD5SIG		14	/* TCP MD5 Signature (RFC2385) */
>  #define TCP_THIN_RM_EXPB        15      /* Remove exp. backoff for thin streams*/
> +#define TCP_THIN_DUPACK         16      /* Fast retrans. after 1 dupack */
>  
>  #define TCPI_OPT_TIMESTAMPS	1
>  #define TCPI_OPT_SACK		2
> @@ -301,7 +302,8 @@ struct tcp_sock {
>  	u8	frto_counter;	/* Number of new acks after RTO */
>  	u8	nonagle;	/* Disable Nagle algorithm?             */
>  	u8      thin_rm_expb:1, /* Remove exp. backoff for thin streams */
> -		thin_undef : 7;
> +		thin_dupack : 1,/* Fast retransmit on first dupack      */
> +		thin_undef : 6;
>  
>  /* RTT measurement */
>  	u32	srtt;		/* smoothed round trip time << 3	*/
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 412c1bd..41f3a5e 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -238,6 +238,7 @@ extern int sysctl_tcp_workaround_signed_windows;
>  extern int sysctl_tcp_slow_start_after_idle;
>  extern int sysctl_tcp_max_ssthresh;
>  extern int sysctl_tcp_force_thin_rm_expb;
> +extern int sysctl_tcp_force_thin_dupack;
>  
>  extern atomic_t tcp_memory_allocated;
>  extern struct percpu_counter tcp_sockets_allocated;
> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index 7458f37..8653867 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -721,6 +721,14 @@ static struct ctl_table ipv4_table[] = {
>  		.proc_handler   = proc_dointvec
>  	},
>  	{
> +		.ctl_name       = CTL_UNNUMBERED,
> +		.procname       = "tcp_force_thin_dupack",
> +		.data           = &sysctl_tcp_force_thin_dupack,
> +		.maxlen         = sizeof(int),
> +		.mode           = 0644,
> +		.proc_handler   = proc_dointvec
> +	},
> +	{
>  		.ctl_name	= CTL_UNNUMBERED,
>  		.procname	= "udp_mem",
>  		.data		= &sysctl_udp_mem,
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index b4b0931..de190db 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2139,6 +2139,11 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
>  			tp->thin_rm_expb = 1;
>  		break;
>  
> +	case TCP_THIN_DUPACK:
> +		if (val)
> +			tp->thin_dupack = 1;
> +		break;
> +
>  	case TCP_CORK:
>  		/* When set indicates to always queue non-full frames.
>  		 * Later the user clears this option and we transmit
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index d86784b..b71eb89 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -89,6 +89,8 @@ int sysctl_tcp_frto __read_mostly = 2;
>  int sysctl_tcp_frto_response __read_mostly;
>  int sysctl_tcp_nometrics_save __read_mostly;
>  
> +int sysctl_tcp_force_thin_dupack __read_mostly;
> +
>  int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
>  int sysctl_tcp_abc __read_mostly;
>  
> @@ -2447,6 +2449,12 @@ static int tcp_time_to_recover(struct sock *sk)
>  		return 1;
>  	}
>  
> +	/* If a thin stream is detected, retransmit after first
> +	 * received dupack */
> +	if ((tp->thin_dupack || sysctl_tcp_force_thin_dupack) &&
> +	    tcp_dupack_heurestics(tp) > 1 && tcp_stream_is_thin(tp))
> +		return 1;
> +
>  	return 0;
>  }

Have you tested it? ...I doubt this will work like you say and retransmit 
something when the window is small. ...Besides, you should have built this 
patch on top of the function rename you submitted earlier as after DaveM 
applied that this will no longer even compile...

-- 
 i.
