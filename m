From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: do not forget FIN in tcp_shifted_skb()
Date: Fri, 4 Oct 2013 21:03:53 +0300 (EEST)
Message-ID: <alpine.DEB.2.02.1310042101040.32153@melkinpaasi.cs.helsinki.fi>
References: <1380907901.3564.24.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696250871-236338788-1380909833=:32153"
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53648 "EHLO
	courier.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043Ab3JDSJO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 14:09:14 -0400
In-Reply-To: <1380907901.3564.24.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696250871-236338788-1380909833=:32153
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Fri, 4 Oct 2013, Eric Dumazet wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Yuchung found following problem :
> 
>  There are bugs in the SACK processing code, merging part in
>  tcp_shift_skb_data(), that incorrectly resets or ignores the sacked
>  skbs FIN flag. When a receiver first SACK the FIN sequence, and later
>  throw away ofo queue (e.g., sack-reneging), the sender will stop
>  retransmitting the FIN flag, and hangs forever.
> 
> Following packetdrill test can be used to reproduce the bug.
> 
> [...snip...]
> 
> First, a typo inverted left/right of one OR operation, then
> code forgot to advance end_seq if the merged skb carried FIN.
> 
> Bug was added in 2.6.29 by commit 832d11c5cd076ab
> ("tcp: Try to restore large SKBs while SACK processing")
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Acked-by: Neal Cardwell <ncardwell@google.com>
> Cc: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> ---
>  net/ipv4/tcp_input.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 25a89ea..113dc5f 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -1284,7 +1284,10 @@ static bool tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
>  		tp->lost_cnt_hint -= tcp_skb_pcount(prev);
>  	}
>  
> -	TCP_SKB_CB(skb)->tcp_flags |= TCP_SKB_CB(prev)->tcp_flags;
> +	TCP_SKB_CB(prev)->tcp_flags |= TCP_SKB_CB(skb)->tcp_flags;
> +	if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
> +		TCP_SKB_CB(prev)->end_seq++;
> +
>  	if (skb == tcp_highest_sack(sk))
>  		tcp_advance_highest_sack(sk, skb);

Nice that it was finally found. For some reason my memory tries to say 
that it wouldn't have not even tried to merge skbs with FIN but either
I changed that at some point while deving or I just remember wrong.

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

-- 
 i.
---696250871-236338788-1380909833=:32153--
