From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH v2 net-next] tcp_metrics: fix wrong lockdep annotations
Date: Mon, 16 Mar 2015 12:17:46 -0500
Message-ID: <87sid4n9ol.fsf@x220.int.ebiederm.org>
References: <20150316113542.GA27127@paralelels.com>
	<1426514329.11398.204.camel@edumazet-glaptop2.roam.corp.google.com>
	<1426515274.11398.209.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Vagin <avagin@parallels.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:50626 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752280AbbCPRVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 13:21:48 -0400
In-Reply-To: <1426515274.11398.209.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Mon, 16 Mar 2015 07:14:34 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> From: Eric Dumazet <edumazet@google.com>
>
> Changes in tcp_metric hash table are protected by tcp_metrics_lock
> only, not by genl_mutex
>
> While we are at it use deref_locked() instead of rcu_dereference()
> in tcp_new() to avoid unnecessary barrier, as we hold tcp_metrics_lock
> as well.

Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>

Good catch, and good improvement.  Thanks for catching and correcting
this.


> Reported-by: Andrew Vagin <avagin@parallels.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 098a697b497e ("tcp_metrics: Use a single hash table for all network namespaces.")
> ---
>  net/ipv4/tcp_metrics.c |   20 ++++++++------------
>  1 file changed, 8 insertions(+), 12 deletions(-)
>
> diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
> index 366728cbee4a692394696f13e6aacf0331990eed..5bef3513af77afc8943d99a107f74155b9979aaa 100644
> --- a/net/ipv4/tcp_metrics.c
> +++ b/net/ipv4/tcp_metrics.c
> @@ -152,6 +152,9 @@ static void tcpm_check_stamp(struct tcp_metrics_block *tm, struct dst_entry *dst
>  #define TCP_METRICS_RECLAIM_DEPTH	5
>  #define TCP_METRICS_RECLAIM_PTR		(struct tcp_metrics_block *) 0x1UL
>  
> +#define deref_locked(p)	\
> +	rcu_dereference_protected(p, lockdep_is_held(&tcp_metrics_lock))
> +
>  static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
>  					  struct inetpeer_addr *saddr,
>  					  struct inetpeer_addr *daddr,
> @@ -180,9 +183,9 @@ static struct tcp_metrics_block *tcpm_new(struct dst_entry *dst,
>  	if (unlikely(reclaim)) {
>  		struct tcp_metrics_block *oldest;
>  
> -		oldest = rcu_dereference(tcp_metrics_hash[hash].chain);
> -		for (tm = rcu_dereference(oldest->tcpm_next); tm;
> -		     tm = rcu_dereference(tm->tcpm_next)) {
> +		oldest = deref_locked(tcp_metrics_hash[hash].chain);
> +		for (tm = deref_locked(oldest->tcpm_next); tm;
> +		     tm = deref_locked(tm->tcpm_next)) {
>  			if (time_before(tm->tcpm_stamp, oldest->tcpm_stamp))
>  				oldest = tm;
>  		}
> @@ -1040,12 +1043,6 @@ out_free:
>  	return ret;
>  }
>  
> -#define deref_locked_genl(p)	\
> -	rcu_dereference_protected(p, lockdep_genl_is_held() && \
> -				     lockdep_is_held(&tcp_metrics_lock))
> -
> -#define deref_genl(p)	rcu_dereference_protected(p, lockdep_genl_is_held())
> -
>  static void tcp_metrics_flush_all(struct net *net)
>  {
>  	unsigned int max_rows = 1U << tcp_metrics_hash_log;
> @@ -1057,8 +1054,7 @@ static void tcp_metrics_flush_all(struct net *net)
>  		struct tcp_metrics_block __rcu **pp;
>  		spin_lock_bh(&tcp_metrics_lock);
>  		pp = &hb->chain;
> -		for (tm = deref_locked_genl(*pp); tm;
> -		     tm = deref_locked_genl(*pp)) {
> +		for (tm = deref_locked(*pp); tm; tm = deref_locked(*pp)) {
>  			if (net_eq(tm_net(tm), net)) {
>  				*pp = tm->tcpm_next;
>  				kfree_rcu(tm, rcu_head);
> @@ -1097,7 +1093,7 @@ static int tcp_metrics_nl_cmd_del(struct sk_buff *skb, struct genl_info *info)
>  	hb = tcp_metrics_hash + hash;
>  	pp = &hb->chain;
>  	spin_lock_bh(&tcp_metrics_lock);
> -	for (tm = deref_locked_genl(*pp); tm; tm = deref_locked_genl(*pp)) {
> +	for (tm = deref_locked(*pp); tm; tm = deref_locked(*pp)) {
>  		if (addr_same(&tm->tcpm_daddr, &daddr) &&
>  		    (!src || addr_same(&tm->tcpm_saddr, &saddr)) &&
>  		    net_eq(tm_net(tm), net)) {
