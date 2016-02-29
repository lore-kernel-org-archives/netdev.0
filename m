From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH v2 1/3] net: ipv4: Convert IP network timestamps to be
 y2038 safe
Date: Mon, 29 Feb 2016 13:26:57 +0900
Message-ID: <56D3C891.7060209@miraclelinux.com>
References: <1456561938-7653-1-git-send-email-deepa.kernel@gmail.com>
 <1456561938-7653-2-git-send-email-deepa.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, arnd@arndb.de,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>
To: Deepa Dinamani <deepa.kernel@gmail.com>, netdev@vger.kernel.org,
	y2038@lists.linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34295 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756276AbcB2E1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2016 23:27:02 -0500
Received: by mail-pa0-f44.google.com with SMTP id fy10so84715196pac.1
        for <netdev@vger.kernel.org>; Sun, 28 Feb 2016 20:27:01 -0800 (PST)
In-Reply-To: <1456561938-7653-2-git-send-email-deepa.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Deepa Dinamani wrote:
> ICMP timestamp messages and IP source route options require
> timestamps to be in milliseconds modulo 24 hours from
> midnight UT format.
> 
> Add inet_current_timestamp() function to support this. The function
> returns the required timestamp in network byte order.
> 
> Timestamp calculation is also changed to call ktime_get_real_ts64()
> which uses struct timespec64. struct timespec64 is y2038 safe.
> Previously it called getnstimeofday() which uses struct timespec.
> struct timespec is not y2038 safe.
> 
> Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji

> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: James Morris <jmorris@namei.org>
> Cc: Patrick McHardy <kaber@trash.net>
> ---
>  include/net/ip.h      |  2 ++
>  net/ipv4/af_inet.c    | 26 ++++++++++++++++++++++++++
>  net/ipv4/icmp.c       |  5 +----
>  net/ipv4/ip_options.c | 14 ++++++--------
>  4 files changed, 35 insertions(+), 12 deletions(-)
> 
> diff --git a/include/net/ip.h b/include/net/ip.h
> index 1a98f1c..5d3a9eb 100644
> --- a/include/net/ip.h
> +++ b/include/net/ip.h
> @@ -240,6 +240,8 @@ static inline int inet_is_local_reserved_port(struct net *net, int port)
>  }
>  #endif
>  
> +__be32 inet_current_timestamp(void);
> +
>  /* From inetpeer.c */
>  extern int inet_peer_threshold;
>  extern int inet_peer_minttl;
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index eade66d..408e2b3 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1386,6 +1386,32 @@ out:
>  	return pp;
>  }
>  
> +#define SECONDS_PER_DAY	86400
> +
> +/* inet_current_timestamp - Return IP network timestamp
> + *
> + * Return milliseconds since midnight in network byte order.
> + */
> +__be32 inet_current_timestamp(void)
> +{
> +	u32 secs;
> +	u32 msecs;
> +	struct timespec64 ts;
> +
> +	ktime_get_real_ts64(&ts);
> +
> +	/* Get secs since midnight. */
> +	(void)div_u64_rem(ts.tv_sec, SECONDS_PER_DAY, &secs);
> +	/* Convert to msecs. */
> +	msecs = secs * MSEC_PER_SEC;
> +	/* Convert nsec to msec. */
> +	msecs += (u32)ts.tv_nsec / NSEC_PER_MSEC;
> +
> +	/* Convert to network byte order. */
> +	return htons(msecs);
> +}
> +EXPORT_SYMBOL(inet_current_timestamp);
> +
>  int inet_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
>  {
>  	if (sk->sk_family == AF_INET)
> diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
> index 36e2697..6333489 100644
> --- a/net/ipv4/icmp.c
> +++ b/net/ipv4/icmp.c
> @@ -931,7 +931,6 @@ static bool icmp_echo(struct sk_buff *skb)
>   */
>  static bool icmp_timestamp(struct sk_buff *skb)
>  {
> -	struct timespec tv;
>  	struct icmp_bxm icmp_param;
>  	/*
>  	 *	Too short.
> @@ -942,9 +941,7 @@ static bool icmp_timestamp(struct sk_buff *skb)
>  	/*
>  	 *	Fill in the current time as ms since midnight UT:
>  	 */
> -	getnstimeofday(&tv);
> -	icmp_param.data.times[1] = htonl((tv.tv_sec % 86400) * MSEC_PER_SEC +
> -					 tv.tv_nsec / NSEC_PER_MSEC);
> +	icmp_param.data.times[1] = inet_current_timestamp();
>  	icmp_param.data.times[2] = icmp_param.data.times[1];
>  	if (skb_copy_bits(skb, 0, &icmp_param.data.times[0], 4))
>  		BUG();
> diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
> index bd24679..4d158ff 100644
> --- a/net/ipv4/ip_options.c
> +++ b/net/ipv4/ip_options.c
> @@ -58,10 +58,9 @@ void ip_options_build(struct sk_buff *skb, struct ip_options *opt,
>  		if (opt->ts_needaddr)
>  			ip_rt_get_source(iph+opt->ts+iph[opt->ts+2]-9, skb, rt);
>  		if (opt->ts_needtime) {
> -			struct timespec tv;
>  			__be32 midtime;
> -			getnstimeofday(&tv);
> -			midtime = htonl((tv.tv_sec % 86400) * MSEC_PER_SEC + tv.tv_nsec / NSEC_PER_MSEC);
> +
> +			midtime = inet_current_timestamp();
>  			memcpy(iph+opt->ts+iph[opt->ts+2]-5, &midtime, 4);
>  		}
>  		return;
> @@ -415,11 +414,10 @@ int ip_options_compile(struct net *net,
>  					break;
>  				}
>  				if (timeptr) {
> -					struct timespec tv;
> -					u32  midtime;
> -					getnstimeofday(&tv);
> -					midtime = (tv.tv_sec % 86400) * MSEC_PER_SEC + tv.tv_nsec / NSEC_PER_MSEC;
> -					put_unaligned_be32(midtime, timeptr);
> +					__be32 midtime;
> +
> +					midtime = inet_current_timestamp();
> +					memcpy(timeptr, &midtime, 4);
>  					opt->is_changed = 1;
>  				}
>  			} else if ((optptr[3]&0xF) != IPOPT_TS_PRESPEC) {
> 

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
