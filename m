From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCHv3 1/2] tcp: Stalling connections: Fix timeout calculation
 routine
Date: Mon, 7 Dec 2009 20:50:11 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912072046500.27565@melkinpaasi.cs.helsinki.fi>
References: <4B1C4C25.1070104@tvk.rwth-aachen.de> <4B1C9D94.3070504@gmail.com> <4B1CE45A.9010908@tvk.rwth-aachen.de> <4B1D27F7.9000502@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696230645-175245638-1260211812=:27565"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	Frederic Leroy <fredo@starox.org>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41838 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758119AbZLGSuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 13:50:09 -0500
In-Reply-To: <4B1D27F7.9000502@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-175245638-1260211812=:27565
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
> decisions before. The corresponding commit was
> 6fa12c85031485dff38ce550c24f10da23b0adaa.
> 
> Thanks to Ilpo Järvinen for code suggestions and Frederic Leroy for
> testing.
> 
> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>
> ---
>  include/net/tcp.h |   10 ++++++++--
>  1 files changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 03a49c7..842ac4d 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -1263,14 +1263,20 @@ static inline struct sk_buff *tcp_write_queue_prev(struct sock *sk, struct sk_bu
>   * TCP connection after "boundary" unsucessful, exponentially backed-off
>   * retransmissions with an initial RTO of TCP_RTO_MIN.
>   */
> -static inline bool retransmits_timed_out(const struct sock *sk,
> +static inline bool retransmits_timed_out(struct sock *sk,
>  					 unsigned int boundary)
>  {
>  	unsigned int timeout, linear_backoff_thresh;
> +	unsigned int start_ts;
>  
>  	if (!inet_csk(sk)->icsk_retransmits)
>  		return false;
>  
> +	if (unlikely(!tcp_sk(sk)->retrans_stamp))
> +		start_ts = TCP_SKB_CB(tcp_write_queue_head(sk))->when;
> +	else
> +		start_ts = tcp_sk(sk)->retrans_stamp;
> +
>  	linear_backoff_thresh = ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
>  
>  	if (boundary <= linear_backoff_thresh)
> @@ -1279,7 +1285,7 @@ static inline bool retransmits_timed_out(const struct sock *sk,
>  		timeout = ((2 << linear_backoff_thresh) - 1) * TCP_RTO_MIN +
>  			  (boundary - linear_backoff_thresh) * TCP_RTO_MAX;
>  
> -	return (tcp_time_stamp - tcp_sk(sk)->retrans_stamp) >= timeout;
> +	return (tcp_time_stamp - start_ts) >= timeout;
>  }
>  
>  static inline struct sk_buff *tcp_send_head(struct sock *sk)

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

Also, this should be added:

Reported-by: Frederic Leroy <fredo@starox.org>

...and I think he has already tested this fix a number of times in 
different forms, so I'd already include his Tested-by: too.

-- 
 i.
---696230645-175245638-1260211812=:27565--
