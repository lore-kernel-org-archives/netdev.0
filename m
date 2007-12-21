From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] [TCP]: Force TSO splits to MSS boundaries
Date: Fri, 21 Dec 2007 22:01:30 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712212157220.5878@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0712201253400.31652@kivilampi-30.cs.helsinki.fi>
 <20071220.040037.48002365.davem@davemloft.net> <20071220140012.GA22495@gondor.apana.org.au>
 <20071220.155518.42408378.davem@davemloft.net>
 <Pine.LNX.4.64.0712211953580.7301@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="-696243703-1380546754-1198263328=:31652"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59847 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753848AbXLUUBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 15:01:33 -0500
In-Reply-To: <Pine.LNX.4.64.0712211953580.7301@kivilampi-30.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0712212157221.5878@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1380546754-1198263328=:31652
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0712212157222.5878@kivilampi-30.cs.helsinki.fi>

On Fri, 21 Dec 2007, Ilpo Järvinen wrote:

> How about this, I had to use another approach due to reasons
> outlined in the commit message:
> 
> --
> [PATCH] [TCP]: Force TSO splits to MSS boundaries
> 
> If snd_wnd - snd_nxt wasn't multiple of MSS, skb was split on
> odd boundary by the callers of tcp_window_allows.
> 
> We try really hard to avoid unnecessary modulos. Therefore the
> old caller side check "if (skb->len < limit)" was too wide as
> well because limit is not bound in any way to skb->len and can
> cause spurious testing for trimming in the middle of the queue
> while we only wanted that to happen at the tail of the queue.
> A simple additional caller side check for tcp_write_queue_tail
> would likely have resulted 2 x modulos because the limit would
> have to be first calculated from window, however, doing that
> unnecessary modulo is not mandatory. After a minor change to
> the algorithm, simply determine first if the modulo is needed
> at all and at that point immediately decide also from which
> value it should be calculated from.
> 
> This approach also kills some duplicated code.
> 
> Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> ---
>  net/ipv4/tcp_output.c |   51 ++++++++++++++++++++++++-------------------------
>  1 files changed, 25 insertions(+), 26 deletions(-)
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 1852698..ea92a1b 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1008,13 +1008,29 @@ static void tcp_cwnd_validate(struct sock *sk)
>  	}
>  }
>  
> -static unsigned int tcp_window_allows(struct tcp_sock *tp, struct sk_buff *skb, unsigned int mss_now, unsigned int cwnd)
> +/* Returns the portion of skb which can be sent right away without
> + * introducing MSS oddities to segment boundaries. In rare cases where
> + * mss_now != mss_cache, we will request caller to create a small skb
> + * per input skb which could be mostly avoided here (if desired).
> + */
> +static unsigned int tcp_mss_split_point(struct sock *sk, struct sk_buff *skb,
> +					unsigned int mss_now,
> +					unsigned int cwnd)
>  {
> -	u32 window, cwnd_len;
> +	struct tcp_sock *tp = tcp_sk(sk);
> +	u32 needed, window, cwnd_len;
>  
>  	window = (tp->snd_una + tp->snd_wnd - TCP_SKB_CB(skb)->seq);
>  	cwnd_len = mss_now * cwnd;
> -	return min(window, cwnd_len);
> +
> +	if (likely(cwnd_len <= window && skb != tcp_write_queue_tail(sk)))
> +		return cwnd_len;
> +
> +	if (skb == tcp_write_queue_tail(sk) && cwnd_len <= skb->len)
> +		return cwnd_len;

...if desired that this won't cause small skbs in the middle of the queue 
(except in case where just the sub-MSS portion is left out above window), 
something like this could be added here (again, avoiding more modulos):

	if (skb != tcp_write_queue_tail(sk) && window > skb->len)
		return skb->len;

> +	needed = min(skb->len, window);
> +	return needed - needed % mss_now;
>  }
>  
>  /* Can at least one segment of SKB be sent right now, according to the

-- 
 i.
---696243703-1380546754-1198263328=:31652--
