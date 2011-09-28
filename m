From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: properly update lost_cnt_hint during shifting
Date: Wed, 28 Sep 2011 11:17:28 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1109281103410.21709@wel-95.cs.helsinki.fi>
References: <4E82C0DD.6010304@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>
To: "Yan, Zheng" <zheng.z.yan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38767 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454Ab1I1IRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2011 04:17:30 -0400
In-Reply-To: <4E82C0DD.6010304@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Sep 2011, Yan, Zheng wrote:

> lost_skb_hint is used by tcp_mark_head_lost() to mark the first
> unhandled skb. lost_cnt_hint is the number of sacked packets before
> the lost_skb_hint. tcp_shifted_skb() shouldn't increase lost_cnt_hint
> when shifting a sacked skb that is before the lost_skb_hint, because
> packets in it are already counted.
> 
> Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
> ---
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 21fab3e..f712ace 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -1390,9 +1390,14 @@ static int tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
>  	BUG_ON(!pcount);
>  
>  	/* Tweak before seqno plays */
> -	if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_hint &&
> -	    !before(TCP_SKB_CB(tp->lost_skb_hint)->seq, TCP_SKB_CB(skb)->seq))
> -		tp->lost_cnt_hint += pcount;
> +	if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_hint) {
> +		if (skb == tp->lost_skb_hint)
> +			tp->lost_cnt_hint += pcount;
> +		else if (!(TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED) &&
> +			 before(TCP_SKB_CB(skb)->seq,
> +				TCP_SKB_CB(tp->lost_skb_hint)->seq))
> +			tp->lost_cnt_hint += pcount;
> +	}

Ah right, the hole filled case which shifts not only the newly SACKed 
skb but also the next, already SACKed skb?

I fail to see why you needed to change !before into two checks though:
 skb == tp->lost_skb_hint and before(params reversed) ? Shouldn't the 
equality that is provided by the negation cover for the == check (and the 
params reversion isn't necessary in any case)? In fact, isn't the skb == 
tp->lost_skb_hint check strictly wrong without the same TCPCB_SACKED_ACKED 
guard (though I'm not sure, I didn't check, if the hint can ever point to 
such a segment in the first place)?

Added Cc to Nandita as they're hunting (possibly other) bug in 
tcp_mark_head_lost.

-- 
 i.
