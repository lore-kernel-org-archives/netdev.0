From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] net: TCP_MSS_DEFAULT, TCP_MSS_DESIRED
Date: Tue, 2 Mar 2010 15:16:59 +1100
Message-ID: <20100302041658.GA5474@verge.net.au>
References: <4AF9C436.8060403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:45514 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690Ab0CBERA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Mar 2010 23:17:00 -0500
Content-Disposition: inline
In-Reply-To: <4AF9C436.8060403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 10, 2009 at 02:51:18PM -0500, William Allen Simpson wrote:
> Define two symbols needed in both kernel and user space.
> 
> Remove old (somewhat incorrect) kernel variant that wasn't used in
> most cases.  Default should apply to both RMSS and SMSS (RFC2581).

The name was somewhat incorrect in the sense that it was named
differently in the RFCs?

> Replace numeric constants with defined symbols.

That bit sounds very reasonable.

> Stand-alone patch, originally developed for TCPCT.
> 
> Signed-off-by: William.Allen.Simpson@gmail.com
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>   include/linux/tcp.h      |    6 ++++++
>   include/net/tcp.h        |    3 ---
>   net/ipv4/tcp_input.c     |    4 ++--
>   net/ipv4/tcp_ipv4.c      |    6 +++---
>   net/ipv4/tcp_minisocks.c |    2 +-
>   net/ipv6/tcp_ipv6.c      |    2 +-
>   6 files changed, 13 insertions(+), 10 deletions(-)

> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index eeecb85..32d7d77 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -81,6 +81,12 @@ enum {
>  	TCP_DATA_OFFSET = __cpu_to_be32(0xF0000000)
>  }; 
>  
> +/*
> + * TCP general constants
> + */
> +#define TCP_MSS_DEFAULT		 536U	/* IPv4 (RFC1122, RFC2581) */
> +#define TCP_MSS_DESIRED		1220U	/* IPv6 (tunneled), EDNS0 (RFC3226) */

Are you planing to use TCP_MSS_DESIRED anywhere?

> +
>  /* TCP socket options */
>  #define TCP_NODELAY		1	/* Turn off Nagle's algorithm. */
>  #define TCP_MAXSEG		2	/* Limit MSS */
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 25bf3ba..a413e9f 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -62,9 +62,6 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
>  /* Minimal accepted MSS. It is (60+60+8) - (20+20). */
>  #define TCP_MIN_MSS		88U
>  
> -/* Minimal RCV_MSS. */
> -#define TCP_MIN_RCVMSS		536U
> -
>  /* The least MTU to use for probing */
>  #define TCP_BASE_MSS		512
>  
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index be0c5bf..cc306ac 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -140,7 +140,7 @@ static void tcp_measure_rcv_mss(struct sock *sk, const struct sk_buff *skb)
>  		 * "len" is invariant segment length, including TCP header.
>  		 */
>  		len += skb->data - skb_transport_header(skb);
> -		if (len >= TCP_MIN_RCVMSS + sizeof(struct tcphdr) ||
> +		if (len >= TCP_MSS_DEFAULT + sizeof(struct tcphdr) ||
>  		    /* If PSH is not set, packet should be
>  		     * full sized, provided peer TCP is not badly broken.
>  		     * This observation (if it is correct 8)) allows
> @@ -411,7 +411,7 @@ void tcp_initialize_rcv_mss(struct sock *sk)
>  	unsigned int hint = min_t(unsigned int, tp->advmss, tp->mss_cache);
>  
>  	hint = min(hint, tp->rcv_wnd / 2);
> -	hint = min(hint, TCP_MIN_RCVMSS);
> +	hint = min(hint, TCP_MSS_DEFAULT);
>  	hint = max(hint, TCP_MIN_MSS);
>  
>  	inet_csk(sk)->icsk_ack.rcv_mss = hint;
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index f83ac91..0718fde 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -217,7 +217,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
>  	if (inet->opt)
>  		inet_csk(sk)->icsk_ext_hdr_len = inet->opt->optlen;
>  
> -	tp->rx_opt.mss_clamp = 536;
> +	tp->rx_opt.mss_clamp = TCP_MSS_DEFAULT;
>  
>  	/* Socket identity is still unknown (sport may be zero).
>  	 * However we set state to SYN-SENT and not releasing socket
> @@ -1270,7 +1270,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
>  		goto drop_and_free;
>  
>  	tcp_clear_options(&tmp_opt);
> -	tmp_opt.mss_clamp = 536;
> +	tmp_opt.mss_clamp = TCP_MSS_DEFAULT;
>  	tmp_opt.user_mss  = tcp_sk(sk)->rx_opt.user_mss;
>  
>  	tcp_parse_options(skb, &tmp_opt, 0, dst);
> @@ -1818,7 +1818,7 @@ static int tcp_v4_init_sock(struct sock *sk)
>  	 */
>  	tp->snd_ssthresh = TCP_INFINITE_SSTHRESH;
>  	tp->snd_cwnd_clamp = ~0;
> -	tp->mss_cache = 536;
> +	tp->mss_cache = TCP_MSS_DEFAULT;
>  
>  	tp->reordering = sysctl_tcp_reordering;
>  	icsk->icsk_ca_ops = &tcp_init_congestion_ops;
> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> index fb68bab..7a42990 100644
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
> @@ -476,7 +476,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
>  		if (newtp->af_specific->md5_lookup(sk, newsk))
>  			newtp->tcp_header_len += TCPOLEN_MD5SIG_ALIGNED;
>  #endif
> -		if (skb->len >= TCP_MIN_RCVMSS+newtp->tcp_header_len)
> +		if (skb->len >= TCP_MSS_DEFAULT + newtp->tcp_header_len)
>  			newicsk->icsk_ack.last_seg_size = skb->len - newtp->tcp_header_len;
>  		newtp->rx_opt.mss_clamp = req->mss;
>  		TCP_ECN_openreq_child(newtp, req);
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 6951827..b528f75 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -1849,7 +1849,7 @@ static int tcp_v6_init_sock(struct sock *sk)
>  	 */
>  	tp->snd_ssthresh = TCP_INFINITE_SSTHRESH;
>  	tp->snd_cwnd_clamp = ~0;
> -	tp->mss_cache = 536;
> +	tp->mss_cache = TCP_MSS_DEFAULT;
>  
>  	tp->reordering = sysctl_tcp_reordering;
>  
> -- 
> 1.6.3.3
> 

