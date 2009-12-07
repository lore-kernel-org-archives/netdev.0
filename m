From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCHv2 2/2] tcp: Stalling connections: Fix timeout calculation
 routine
Date: Mon, 7 Dec 2009 14:08:03 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912071405200.7024@wel-95.cs.helsinki.fi>
References: <4B1C4C25.1070104@tvk.rwth-aachen.de> <4B1C9D94.3070504@gmail.com> <4B1CE45A.9010908@tvk.rwth-aachen.de> <4B1CE9EE.1040903@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1273871006-1260187683=:7024"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	Frederic Leroy <fredo@starox.org>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39582 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754225AbZLGMH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 07:07:57 -0500
In-Reply-To: <4B1CE9EE.1040903@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1273871006-1260187683=:7024
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Content-Transfer-Encoding: 8BIT

On Mon, 7 Dec 2009, Damian Lukowski wrote:

> This patch fixes a problem in the TCP connection timeout calculation.
> Currently, timeout decisions are made on the basis of the current
> tcp_time_stamp and retrans_stamp, which is usually set at the first
> retransmission.
> However, if the retransmission fails in tcp_retransmit_skb(),
> retrans_stamp is not updated and remains zero. This leads to wrong
> decisions in retransmits_timed_out() if tcp_time_stamp is larger than
> the specified timeout, which is very likely.
> In this case, the TCP connection dies after the first attempted
> (and unsuccessful) retransmission.
> 
> With this patch, tcp_skb_cb->when is used instead, when retrans_stamp
> is not available.
> 
> This bug has been introduced together with retransmits_timed_out()
> in 2.6.32, as the number of retransmissions has been used for timeout
> decisions before.
> 
> Thanks to Ilpo Järvinen for code suggestions and Frederic Leroy for
> testing.
> 
> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
> ---
>  net/ipv4/tcp_timer.c |    9 ++++++++-
>  1 files changed, 8 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
> index 5c5f739..a9d2891 100644
> --- a/net/ipv4/tcp_timer.c
> +++ b/net/ipv4/tcp_timer.c
> @@ -140,10 +140,17 @@ static bool retransmits_timed_out(const struct sock *sk,
>  				  unsigned int boundary)
>  {
>  	unsigned int timeout, linear_backoff_thresh;
> +	unsigned int start_ts;
>  
>  	if (!inet_csk(sk)->icsk_retransmits)
>  		return false;
>  
> +	if (unlikely(!tcp_sk(sk)->retrans_stamp))
> +		start_ts = TCP_SKB_CB(tcp_write_queue_head(
> +					(struct sock *)sk))->when;

Grr, a cast.... 

> +	else
> +		start_ts = tcp_sk(sk)->retrans_stamp;
> +
>  	linear_backoff_thresh = ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
>  
>  	if (boundary <= linear_backoff_thresh)
> @@ -152,7 +159,7 @@ static bool retransmits_timed_out(const struct sock *sk,
>  		timeout = ((2 << linear_backoff_thresh) - 1) * TCP_RTO_MIN +
>  			  (boundary - linear_backoff_thresh) * TCP_RTO_MAX;
>  
> -	return (tcp_time_stamp - tcp_sk(sk)->retrans_stamp) >= timeout;
> +	return (tcp_time_stamp - start_ts) >= timeout;
>  }
>  
>  /* A write timeout has occurred. Process the after effects. */
> 

Also, in here it's more useful to provide the fix as the first patch (1/2) 
since it's going to stable and those people don't want the move patch 
there.

-- 
 i.
--8323329-1273871006-1260187683=:7024--
