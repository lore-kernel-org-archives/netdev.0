From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 2/7] net-tcp: Fast Open client - cookie cache
Date: Wed, 18 Jul 2012 23:16:06 +0200
Message-ID: <1342646166.2626.3692.camel@edumazet-glaptop>
References: <1342645307-17772-1-git-send-email-ycheng@google.com>
	 <1342645307-17772-3-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com, sivasankar@cs.ucsd.edu,
	netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:48498 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970Ab2GRVQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 17:16:15 -0400
Received: by yenl2 with SMTP id l2so2099523yen.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 14:16:15 -0700 (PDT)
In-Reply-To: <1342645307-17772-3-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 14:01 -0700, Yuchung Cheng wrote:
> Add Fast Open metrics in tcp metrics cache: the basic ones are MSS and
> the cookies. Later patch will cache more to handle unfriendly middleboxes.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> ---
>  include/net/tcp.h      |    4 ++++
>  net/ipv4/tcp_metrics.c |   41 +++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 45 insertions(+), 0 deletions(-)
> 
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 5aed371..e601da1 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -405,6 +405,10 @@ extern void tcp_metrics_init(void);
>  extern bool tcp_peer_is_proven(struct request_sock *req, struct dst_entry *dst, bool paws_check);
>  extern bool tcp_remember_stamp(struct sock *sk);
>  extern bool tcp_tw_remember_stamp(struct inet_timewait_sock *tw);
> +extern void tcp_fastopen_cache_get(struct sock *sk, u16 *mss,
> +				   struct tcp_fastopen_cookie *cookie);
> +extern void tcp_fastopen_cache_set(struct sock *sk, u16 mss,
> +				   struct tcp_fastopen_cookie *cookie);
>  extern void tcp_fetch_timewait_stamp(struct sock *sk, struct dst_entry *dst);
>  extern void tcp_disable_fack(struct tcp_sock *tp);
>  extern void tcp_close(struct sock *sk, long timeout);
> diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
> index 1a115b6..b498954 100644
> --- a/net/ipv4/tcp_metrics.c
> +++ b/net/ipv4/tcp_metrics.c
> @@ -30,6 +30,11 @@ enum tcp_metric_index {
>  	TCP_METRIC_MAX,
>  };
>  
> +struct tcp_fastopen_metrics {
> +	u16	mss;
> +	struct	tcp_fastopen_cookie	cookie;
> +};
> +
>  struct tcp_metrics_block {
>  	struct tcp_metrics_block __rcu	*tcpm_next;
>  	struct inetpeer_addr		tcpm_addr;
> @@ -38,6 +43,7 @@ struct tcp_metrics_block {
>  	u32				tcpm_ts_stamp;
>  	u32				tcpm_lock;
>  	u32				tcpm_vals[TCP_METRIC_MAX];
> +	struct tcp_fastopen_metrics	tcpm_fastopen;
>  };
>  
>  static bool tcp_metric_locked(struct tcp_metrics_block *tm,
> @@ -118,6 +124,8 @@ static void tcpm_suck_dst(struct tcp_metrics_block *tm, struct dst_entry *dst)
>  	tm->tcpm_vals[TCP_METRIC_REORDERING] = dst_metric_raw(dst, RTAX_REORDERING);
>  	tm->tcpm_ts = 0;
>  	tm->tcpm_ts_stamp = 0;
> +	tm->tcpm_fastopen.mss = 0;
> +	tm->tcpm_fastopen.cookie.len = 0;
>  }
>  
>  static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
> @@ -633,6 +641,39 @@ bool tcp_tw_remember_stamp(struct inet_timewait_sock *tw)
>  	return ret;
>  }
>  
> +void tcp_fastopen_cache_get(struct sock *sk, u16 *mss,
> +			    struct tcp_fastopen_cookie *cookie)
> +{
> +	struct tcp_metrics_block *tm;
> +
> +	rcu_read_lock();
> +	tm = tcp_get_metrics(sk, __sk_dst_get(sk), false);
> +	if (tm) {
> +		struct tcp_fastopen_metrics *tfom = &tm->tcpm_fastopen;
> +		if (tfom->mss)
> +			*mss = tfom->mss;
> +		*cookie = tfom->cookie;
> +	}
> +	rcu_read_unlock();
> +}
> +
> +
> +void tcp_fastopen_cache_set(struct sock *sk, u16 mss,
> +			    struct tcp_fastopen_cookie *cookie)
> +{
> +	struct tcp_metrics_block *tm;
> +
> +	rcu_read_lock();
> +	tm = tcp_get_metrics(sk, __sk_dst_get(sk), true);
> +	if (tm) {
> +		struct tcp_fastopen_metrics *tfom = &tm->tcpm_fastopen;
> +		tfom->mss = mss;
> +		if (cookie->len > 0)
> +			tfom->cookie = *cookie;
> +	}
> +	rcu_read_unlock();
> +}
> +

Hmm, this rcu_read_lock() in cache_set() gives a false sense of
security ;)

I suggest using a seqlock instead ?
