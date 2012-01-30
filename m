From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: fix tcp_trim_head() to adjust segment count with
 skb MSS
Date: Mon, 30 Jan 2012 09:08:51 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1201300903040.12992@melkinpaasi.cs.helsinki.fi>
References: <1327807786-27185-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-580479004-1327907331=:12992"
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48118 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753983Ab2A3HIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 02:08:53 -0500
In-Reply-To: <1327807786-27185-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-580479004-1327907331=:12992
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Sat, 28 Jan 2012, Neal Cardwell wrote:

> This commit fixes tcp_trim_head() to recalculate the number of
> segments in the skb with the skb's existing MSS, so trimming the head
> causes the skb segment count to be monotonically non-increasing - it
> should stay the same or go down, but not increase.
> 
> Previously tcp_trim_head() used the current MSS of the connection. But
> if there was a decrease in MSS between original transmission and ACK
> (e.g. due to PMTUD), this could cause tcp_trim_head() to
> counter-intuitively increase the segment count when trimming bytes off
> the head of an skb. This violated assumptions in tcp_tso_acked() that
> tcp_trim_head() only decreases the packet count, so that packets_acked
> in tcp_tso_acked() could underflow, leading tcp_clean_rtx_queue() to
> pass u32 pkts_acked values as large as 0xffffffff to
> ca_ops->pkts_acked().
> 
> As an aside, if tcp_trim_head() had really wanted the skb to reflect
> the current MSS, it should have called tcp_set_skb_tso_segs()
> unconditionally, since a decrease in MSS would mean that a
> single-packet skb should now be sliced into multiple segments.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> ---
>  net/ipv4/tcp_output.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 8c8de27..4ff3b6d 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1141,11 +1141,9 @@ int tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
>  	sk_mem_uncharge(sk, len);
>  	sock_set_flag(sk, SOCK_QUEUE_SHRUNK);
>  
> -	/* Any change of skb->len requires recalculation of tso
> -	 * factor and mss.
> -	 */
> +	/* Any change of skb->len requires recalculation of tso factor. */
>  	if (tcp_skb_pcount(skb) > 1)
> -		tcp_set_skb_tso_segs(sk, skb, tcp_current_mss(sk));
> +		tcp_set_skb_tso_segs(sk, skb, tcp_skb_mss(skb));
>  
>  	return 0;
>  }

Nice catch... this could solve some non-fatal counter inconsistencies too 
that have been occuring very rarely.

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

-- 
 i.
--8323329-580479004-1327907331=:12992--
