From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [RFC PATCH] sctp: Don't lookup dst if transport dst is still
 valid
Date: Tue, 02 Jul 2013 10:29:28 -0400
Message-ID: <51D2E3C8.5050100@gmail.com>
References: <1372747174-23580-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:59913 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503Ab3GBO3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 10:29:31 -0400
Received: by mail-yh0-f44.google.com with SMTP id t59so3160660yho.31
        for <netdev@vger.kernel.org>; Tue, 02 Jul 2013 07:29:31 -0700 (PDT)
In-Reply-To: <1372747174-23580-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/2013 02:39 AM, Fan Du wrote:
> When sctp sits on IPv6, sctp_transport_dst_check pass cookie as ZERO,
> as a result ip6_dst_check always fail out. This behaviour makes
> transport->dst useless, because every sctp_packet_transmit must look
> for valid dst(Is this what supposed to be?)
>
> One aggressive way is to call rt_genid_bump which invalid all dst to
> make new dst for transport, apparently it also hurts others.
> I'm sure this may not be the best for all, so any commnets?
>
> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
>   include/net/sctp/sctp.h |   18 ++++++++++++------
>   net/sctp/ipv6.c         |    2 ++
>   2 files changed, 14 insertions(+), 6 deletions(-)
>
> diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> index cd89510..f05af01 100644
> --- a/include/net/sctp/sctp.h
> +++ b/include/net/sctp/sctp.h
> @@ -719,14 +719,20 @@ static inline void sctp_v4_map_v6(union sctp_addr *addr)
>   	addr->v6.sin6_addr.s6_addr32[2] = htonl(0x0000ffff);
>   }
>
> -/* The cookie is always 0 since this is how it's used in the
> - * pmtu code.
> - */
> +/* Set cookie with the right one for IPv6 and zero for others */
>   static inline struct dst_entry *sctp_transport_dst_check(struct sctp_transport *t)
>   {
> -	if (t->dst && !dst_check(t->dst, 0)) {
> -		dst_release(t->dst);
> -		t->dst = NULL;
> +
> +	if (t->dst) {
> +		struct rt6_info *rt = (struct rt6_info *)t->dst;
> +		u32 cookie = 0;
> +
> +		if ((t->af_specific->sa_family == AF_INET6) && rt->rt6i_node)	
> +			cookie = rt->rt6i_node->fn_sernum;	
> +		if (!dst_check(t->dst, cookie)) {
> +			dst_release(t->dst);
> +			t->dst = NULL;
> +		}
>   	}

I think it would be better if we stored the dst_cookie in the transport 
structure and initialized it at lookup time.   If you do that, then if 
the route table changes, we'd correctly detect it without artificially 
bumping rt_genid (and hurting ipv4).

-vlad

>
>   	return t->dst;
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index 8ee553b..cfae77e 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -137,6 +137,8 @@ static int sctp_inet6addr_event(struct notifier_block *this, unsigned long ev,
>   		break;
>   	}
>
> +	/* invalid all transport dst forcing to look up new dst */
> +	rt_genid_bump(net);
>   	return NOTIFY_DONE;
>   }
>
>
