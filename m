From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] net_sched: restore "overhead xxx" handling
Date: Mon, 3 Jun 2013 15:56:21 +0200
Message-ID: <20130603155621.0cb53b1b@redhat.com>
References: <1370217305.24311.104.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Vimalkumar <j.vimal@gmail.com>, Jiri Pirko <jpirko@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19942 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754306Ab3FCN42 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 09:56:28 -0400
In-Reply-To: <1370217305.24311.104.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 02 Jun 2013 16:55:05 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> commit 56b765b79 ("htb: improved accuracy at high rates")
> broke the "overhead xxx" handling, as well as the "linklayer atm"
> attribute.
> 
> tc class add ... htb rate X ceil Y linklayer atm overhead 10
> 
> This patch restores the "overhead xxx" handling, for htb, tbf
> and act_police
> 
> The "linklayer atm" thing needs a separate fix.
> 
[...]
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index f10818f..e7f4e21 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -679,22 +679,26 @@ static inline struct sk_buff
> *skb_act_clone(struct sk_buff *skb, gfp_t gfp_mask, #endif
>  
>  struct psched_ratecfg {
> -	u64 rate_bps;
> -	u32 mult;
> -	u32 shift;
> +	u64	rate_bps;
> +	u32	mult;
> +	u16	overhead;
> +	u8	shift;
>  };
>  
>  static inline u64 psched_l2t_ns(const struct psched_ratecfg *r,
>  				unsigned int len)
>  {
> -	return ((u64)len * r->mult) >> r->shift;
> +	return ((u64)(len + r->overhead) * r->mult) >> r->shift;
>  }


Would it make sense to add the "overhead" in qdisc_pkt_len_init() or
qdisc_calculate_pkt_len(), thus updating qdisc_skb_cb(skb)->pkt_len
instead?  (And perhaps also address the per GSO issue).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
