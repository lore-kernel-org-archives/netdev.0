From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: Fix compiler warning.
Date: Wed, 09 Dec 2009 18:07:17 -0800 (PST)
Message-ID: <20091209.180717.193708062.davem@davemloft.net>
References: <pvmhbrzboyb.fsf@chavey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: chavey@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59049
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759439AbZLJCHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 21:07:11 -0500
In-Reply-To: <pvmhbrzboyb.fsf@chavey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: chavey@google.com
Date: Wed, 09 Dec 2009 17:25:00 -0800

> Fix compiler warning "discards qualifiers from pointer target type".
> The function prototype defines parameters as pointer to a constant.
> Such parameters should not have their content modified in the
> function.
> 
> Signed-off-by: Laurent Chavey <chavey@google.com>

Please CC: netfilter patches to netfilter-devel, added...

> ---
>  net/ipv4/netfilter/ipt_ULOG.c |    6 ++++--
>  net/netfilter/xt_time.c       |    6 ++++--
>  2 files changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
> index d32cc4b..8490f9f 100644
> --- a/net/ipv4/netfilter/ipt_ULOG.c
> +++ b/net/ipv4/netfilter/ipt_ULOG.c
> @@ -166,6 +166,7 @@ static void ipt_ulog_packet(unsigned int hooknum,
>  	size_t size, copy_len;
>  	struct nlmsghdr *nlh;
>  	struct timeval tv;
> +	ktime_t	tstamp;
>  
>  	/* ffs == find first bit set, necessary because userspace
>  	 * is already shifting groupnumber, but we need unshifted.
> @@ -208,13 +209,14 @@ static void ipt_ulog_packet(unsigned int hooknum,
>  
>  	pm = NLMSG_DATA(nlh);
>  
> +	tstamp = skb->tstamp;
>  	/* We might not have a timestamp, get one */
>  	if (skb->tstamp.tv64 == 0)
> -		__net_timestamp((struct sk_buff *)skb);
> +		tstamp = ktime_get_real();
>  
>  	/* copy hook, prefix, timestamp, payload, etc. */
>  	pm->data_len = copy_len;
> -	tv = ktime_to_timeval(skb->tstamp);
> +	tv = ktime_to_timeval(tstamp);
>  	put_unaligned(tv.tv_sec, &pm->timestamp_sec);
>  	put_unaligned(tv.tv_usec, &pm->timestamp_usec);
>  	put_unaligned(skb->mark, &pm->mark);
> diff --git a/net/netfilter/xt_time.c b/net/netfilter/xt_time.c
> index 93acaa5..66e2a75 100644
> --- a/net/netfilter/xt_time.c
> +++ b/net/netfilter/xt_time.c
> @@ -159,6 +159,7 @@ time_mt(const struct sk_buff *skb, const struct xt_match_param *par)
>  	unsigned int packet_time;
>  	struct xtm current_time;
>  	s64 stamp;
> +	ktime_t	tstamp;
>  
>  	/*
>  	 * We cannot use get_seconds() instead of __net_timestamp() here.
> @@ -169,10 +170,11 @@ time_mt(const struct sk_buff *skb, const struct xt_match_param *par)
>  	 * may happen that the same packet matches both rules if
>  	 * it arrived at the right moment before 13:00.
>  	 */
> +	tstamp = skb->tstamp;
>  	if (skb->tstamp.tv64 == 0)
> -		__net_timestamp((struct sk_buff *)skb);
> +		tstamp = ktime_get_real();
>  
> -	stamp = ktime_to_ns(skb->tstamp);
> +	stamp = ktime_to_ns(tstamp);
>  	stamp = div_s64(stamp, NSEC_PER_SEC);
>  
>  	if (info->flags & XT_TIME_LOCAL_TZ)
