From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v2 2/5] tcp: implemented pacing_expired
Date: Sun, 15 Oct 2017 10:30:48 -0700
Message-ID: <1508088648.31614.63.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171014114714.3694-1-natale.patriciello@gmail.com>
         <20171014114714.3694-3-natale.patriciello@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Ahmed Said <ahmed.said@uniroma2.it>,
        Francesco Zampognaro <zampognaro@ing.uniroma2.it>,
        Cesare Roseti <roseti@ing.uniroma2.it>
To: Natale Patriciello <natale.patriciello@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:48919 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751502AbdJORav (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 13:30:51 -0400
Received: by mail-pg0-f65.google.com with SMTP id v78so4989416pgb.5
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 10:30:51 -0700 (PDT)
In-Reply-To: <20171014114714.3694-3-natale.patriciello@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-10-14 at 13:47 +0200, Natale Patriciello wrote:
> Inform the congestion control that the pacing timer, previously set,
> has expired. The commit does not consider situations in which another
> kind of timer has expired (e.g., a tail loss probe, a retransmission
> timer...)
> 
> Signed-off-by: Natale Patriciello <natale.patriciello@gmail.com>
> ---
>  include/net/tcp.h     | 2 ++
>  net/ipv4/tcp_output.c | 6 ++++++
>  2 files changed, 8 insertions(+)
> 
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 42c7aa96c4cf..e817f0669d0e 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1017,6 +1017,8 @@ struct tcp_congestion_ops {
>  			   union tcp_cc_info *info);
>  	/* get the expiration time for the pacing timer (optional) */
>  	u64 (*get_pacing_time)(struct sock *sk);
> +	/* the pacing timer is expired (optional) */
> +	void (*pacing_timer_expired)(struct sock *sk);
>  
>  	char 		name[TCP_CA_NAME_MAX];
>  	struct module 	*owner;
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index ec5977156c26..25b4cf0802f2 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2241,6 +2241,7 @@ void tcp_chrono_stop(struct sock *sk, const enum tcp_chrono type)
>  static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
>  			   int push_one, gfp_t gfp)
>  {
> +	const struct tcp_congestion_ops *ca_ops = inet_csk(sk)->icsk_ca_ops;
>  	struct tcp_sock *tp = tcp_sk(sk);
>  	struct sk_buff *skb;
>  	unsigned int tso_segs, sent_pkts;
> @@ -2263,6 +2264,11 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
>  
>  	max_segs = tcp_tso_segs(sk, mss_now);
>  	tcp_mstamp_refresh(tp);
> +
> +	if (!tcp_pacing_timer_check(sk) &&
> +	    ca_ops && ca_ops->pacing_timer_expired)
> +		ca_ops->pacing_timer_expired(sk);
> +
>  

1) We do not want hrtimer_active() being called for each
tcp_write_xmit() ... :/

2) ca_ops can not be NULL.


->
       if (ca_ops->pacing_timer_expired && !tcp_pacing_timer_check(sk))
               ca_ops->pacing_timer_expired(sk);
