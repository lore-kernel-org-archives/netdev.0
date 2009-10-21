From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH v2 2/8] Allow tcp_parse_options to consult dst entry
Date: Wed, 21 Oct 2009 16:03:12 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.0910211559050.5304@wel-95.cs.helsinki.fi>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com> <1256115421-12714-3-git-send-email-gilad@codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, ori@comsleep.com
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59583 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753231AbZJUNDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 09:03:09 -0400
In-Reply-To: <1256115421-12714-3-git-send-email-gilad@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Oct 2009, Gilad Ben-Yossef wrote:

> We need tcp_parse_options to be aware of dst_entry to 
> take into account per dst_entry TCP options settings
> 
> Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
> Sigend-off-by: Ori Finkelman <ori@comsleep.com>
> Sigend-off-by: Yony Amit <yony@comsleep.com>
> 
> ---
>  include/net/tcp.h        |    3 ++-
>  net/ipv4/syncookies.c    |   27 ++++++++++++++-------------
>  net/ipv4/tcp_input.c     |    9 ++++++---
>  net/ipv4/tcp_ipv4.c      |   19 ++++++++++---------
>  net/ipv4/tcp_minisocks.c |    7 +++++--
>  net/ipv6/syncookies.c    |   28 +++++++++++++++-------------
>  net/ipv6/tcp_ipv6.c      |    3 ++-
>  7 files changed, 54 insertions(+), 42 deletions(-)
> 
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 03a49c7..740d09b 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -409,7 +409,8 @@ extern int			tcp_recvmsg(struct kiocb *iocb, struct sock *sk,
>  
>  extern void			tcp_parse_options(struct sk_buff *skb,
>  						  struct tcp_options_received *opt_rx,
> -						  int estab);
> +						  int estab,
> +						  struct dst_entry *dst);
>  
>  extern u8			*tcp_parse_md5sig_option(struct tcphdr *th);
>  
> diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
> index a6e0e07..4990dd4 100644
> --- a/net/ipv4/syncookies.c
> +++ b/net/ipv4/syncookies.c
> @@ -276,13 +276,6 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
>  
>  	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESRECV);
>  
> -	/* check for timestamp cookie support */
> -	memset(&tcp_opt, 0, sizeof(tcp_opt));
> -	tcp_parse_options(skb, &tcp_opt, 0);
> -
> -	if (tcp_opt.saw_tstamp)
> -		cookie_check_timestamp(&tcp_opt);
> -
>  	ret = NULL;
>  	req = inet_reqsk_alloc(&tcp_request_sock_ops); /* for safety */
>  	if (!req)
> @@ -298,12 +291,6 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
>  	ireq->loc_addr		= ip_hdr(skb)->daddr;
>  	ireq->rmt_addr		= ip_hdr(skb)->saddr;
>  	ireq->ecn_ok		= 0;
> -	ireq->snd_wscale	= tcp_opt.snd_wscale;
> -	ireq->rcv_wscale	= tcp_opt.rcv_wscale;
> -	ireq->sack_ok		= tcp_opt.sack_ok;
> -	ireq->wscale_ok		= tcp_opt.wscale_ok;
> -	ireq->tstamp_ok		= tcp_opt.saw_tstamp;
> -	req->ts_recent		= tcp_opt.saw_tstamp ? tcp_opt.rcv_tsval : 0;
>  
>  	/* We throwed the options of the initial SYN away, so we hope
>  	 * the ACK carries the same options again (see RFC1122 4.2.3.8)
> @@ -351,6 +338,20 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
>  		}
>  	}
>  
> +	/* check for timestamp cookie support */
> +	memset(&tcp_opt, 0, sizeof(tcp_opt));
> +	tcp_parse_options(skb, &tcp_opt, 0, &rt->u.dst);
> +
> +	if (tcp_opt.saw_tstamp)
> +		cookie_check_timestamp(&tcp_opt);
> +
> +	ireq->snd_wscale        = tcp_opt.snd_wscale;
> +	ireq->rcv_wscale        = tcp_opt.rcv_wscale;
> +	ireq->sack_ok           = tcp_opt.sack_ok;
> +	ireq->wscale_ok         = tcp_opt.wscale_ok;
> +	ireq->tstamp_ok         = tcp_opt.saw_tstamp;
> +	req->ts_recent          = tcp_opt.saw_tstamp ? tcp_opt.rcv_tsval : 0;
> +
>  	/* Try to redo what tcp_v4_send_synack did. */
>  	req->window_clamp = tp->window_clamp ? :dst_metric(&rt->u.dst, RTAX_WINDOW);
>  
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index d86784b..d502f49 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -3698,12 +3698,14 @@ old_ack:
>   * the fast version below fails.
>   */
>  void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
> -		       int estab)
> +		       int estab,  struct dst_entry *dst)
>  {
>  	unsigned char *ptr;
>  	struct tcphdr *th = tcp_hdr(skb);
>  	int length = (th->doff * 4) - sizeof(struct tcphdr);
>  
> +	BUG_ON(!estab && !dst);
> +
>  	ptr = (unsigned char *)(th + 1);
>  	opt_rx->saw_tstamp = 0;
>  
> @@ -3820,7 +3822,7 @@ static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
>  		if (tcp_parse_aligned_timestamp(tp, th))
>  			return 1;
>  	}
> -	tcp_parse_options(skb, &tp->rx_opt, 1);
> +	tcp_parse_options(skb, &tp->rx_opt, 1, NULL);
>  	return 1;
>  }
>  
> @@ -5364,8 +5366,9 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
>  	struct tcp_sock *tp = tcp_sk(sk);
>  	struct inet_connection_sock *icsk = inet_csk(sk);
>  	int saved_clamp = tp->rx_opt.mss_clamp;
> +	struct dst_entry *dst = __sk_dst_get(sk);
>  
> -	tcp_parse_options(skb, &tp->rx_opt, 0);
> +	tcp_parse_options(skb, &tp->rx_opt, 0, dst);
>  
>  	if (th->ack) {
>  		/* rfc793:
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 7cda24b..1cb0ec4 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1256,11 +1256,18 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
>  	tcp_rsk(req)->af_specific = &tcp_request_sock_ipv4_ops;
>  #endif
>  
> +	ireq = inet_rsk(req);
> +	ireq->loc_addr = daddr;
> +	ireq->rmt_addr = saddr;
> +	ireq->no_srccheck = inet_sk(sk)->transparent;
> +	ireq->opt = tcp_v4_save_options(sk, skb);
> +
> +	dst = inet_csk_route_req(sk, req);
>  	tcp_clear_options(&tmp_opt);
>  	tmp_opt.mss_clamp = 536;
>  	tmp_opt.user_mss  = tcp_sk(sk)->rx_opt.user_mss;
>  
> -	tcp_parse_options(skb, &tmp_opt, 0);
> +	tcp_parse_options(skb, &tmp_opt, 0, dst);
>  
>  	if (want_cookie && !tmp_opt.saw_tstamp)
>  		tcp_clear_options(&tmp_opt);
> @@ -1269,14 +1276,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
>  
>  	tcp_openreq_init(req, &tmp_opt, skb);
>  
> -	ireq = inet_rsk(req);
> -	ireq->loc_addr = daddr;
> -	ireq->rmt_addr = saddr;
> -	ireq->no_srccheck = inet_sk(sk)->transparent;
> -	ireq->opt = tcp_v4_save_options(sk, skb);
> -
>  	if (security_inet_conn_request(sk, skb, req))
> -		goto drop_and_free;
> +		goto drop_and_release;
>  
>  	if (!want_cookie)
>  		TCP_ECN_create_request(req, tcp_hdr(skb));
> @@ -1301,7 +1302,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
>  		 */
>  		if (tmp_opt.saw_tstamp &&
>  		    tcp_death_row.sysctl_tw_recycle &&
> -		    (dst = inet_csk_route_req(sk, req)) != NULL &&
> +		    dst != NULL &&

Why you need this NULL check this here while you trap it with BUG_ON 
elsewhere? Does your patch perhaps create a remote DoS opportunity?


-- 
 i.
