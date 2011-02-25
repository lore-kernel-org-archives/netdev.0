From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] sch_choke: add choke_skb_cb
Date: Thu, 24 Feb 2011 19:48:12 -0800
Message-ID: <20110224194812.6f96424d@nehalam>
References: <1298605541.2659.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41903 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755910Ab1BYDsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Feb 2011 22:48:15 -0500
In-Reply-To: <1298605541.2659.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Feb 2011 04:45:41 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Better document choke skb->cb[] use, like we did in netem and sfb
> 
> This adds a compile time check to make sure we dont exhaust skb->cb[]
> space.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Stephen Hemminger <shemminger@vyatta.com>
> CC: Patrick McHardy <kaber@trash.net>
> ---
>  net/sched/sch_choke.c |   15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
> index ee1e209..06afbae 100644
> --- a/net/sched/sch_choke.c
> +++ b/net/sched/sch_choke.c
> @@ -219,14 +219,25 @@ static bool choke_match_flow(struct sk_buff *skb1,
>  	return *ports1 == *ports2;
>  }
>  
> +struct choke_skb_cb {
> +	u16 classid;
> +};
> +
> +static inline struct choke_skb_cb *choke_skb_cb(const struct sk_buff *skb)
> +{
> +	BUILD_BUG_ON(sizeof(skb->cb) <
> +		sizeof(struct qdisc_skb_cb) + sizeof(struct choke_skb_cb));
> +	return (struct choke_skb_cb *)qdisc_skb_cb(skb)->data;
> +}
> +
>  static inline void choke_set_classid(struct sk_buff *skb, u16 classid)
>  {
> -	*(unsigned int *)(qdisc_skb_cb(skb)->data) = classid;
> +	choke_skb_cb(skb)->classid = classid;
>  }
>  
>  static u16 choke_get_classid(const struct sk_buff *skb)
>  {
> -	return *(unsigned int *)(qdisc_skb_cb(skb)->data);
> +	return choke_skb_cb(skb)->classid;
>  }
>  

Ideally class id should be u32, but then that would mean changing TC
classifier id and that is hardwired into the API.


-- 
