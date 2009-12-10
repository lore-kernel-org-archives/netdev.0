From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 1/3] tcp: Remove check in __tcp_push_pending_frames
Date: Thu, 10 Dec 2009 10:05:59 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912101000450.23376@melkinpaasi.cs.helsinki.fi>
References: <20091209082613.19055.58864.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696230645-2086464068-1260432359=:23376"
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36059 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760709AbZLJIFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 03:05:53 -0500
In-Reply-To: <20091209082613.19055.58864.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-2086464068-1260432359=:23376
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Wed, 9 Dec 2009, Krishna Kumar wrote:

> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> tcp_push checks tcp_send_head and calls __tcp_push_pending_frames,
> which again checks tcp_send_head, and this unnecessary check is
> done for every other caller of __tcp_push_pending_frames.
> 
> Remove tcp_send_head check in __tcp_push_pending_frames and add
> the check to tcp_push_pending_frames. Other functions call
> __tcp_push_pending_frames only when tcp_send_head would evaluate
> to true.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  include/net/tcp.h     |   16 +++++++++-------
>  net/ipv4/tcp_output.c |    5 -----
>  2 files changed, 9 insertions(+), 12 deletions(-)
> 
> diff -ruNp org/include/net/tcp.h new/include/net/tcp.h
> --- org/include/net/tcp.h	2009-12-04 18:15:26.000000000 +0530
> +++ new/include/net/tcp.h	2009-12-09 09:57:39.000000000 +0530
> @@ -857,13 +857,6 @@ static inline void tcp_check_probe_timer
>  					  icsk->icsk_rto, TCP_RTO_MAX);
>  }
>  
> -static inline void tcp_push_pending_frames(struct sock *sk)
> -{
> -	struct tcp_sock *tp = tcp_sk(sk);
> -
> -	__tcp_push_pending_frames(sk, tcp_current_mss(sk), tp->nonagle);
> -}
> -
>  static inline void tcp_init_wl(struct tcp_sock *tp, u32 seq)
>  {
>  	tp->snd_wl1 = seq;
> @@ -1366,6 +1359,15 @@ static inline int tcp_write_queue_empty(
>  	return skb_queue_empty(&sk->sk_write_queue);
>  }
>  
> +static inline void tcp_push_pending_frames(struct sock *sk)
> +{
> +	if (tcp_send_head(sk)) {
> +		struct tcp_sock *tp = tcp_sk(sk);
> +
> +		__tcp_push_pending_frames(sk, tcp_current_mss(sk), tp->nonagle);
> +	}
> +}
> +
>  /* Start sequence of the highest skb with SACKed bit, valid only if
>   * sacked > 0 or when the caller has ensured validity by itself.
>   */
> diff -ruNp org/net/ipv4/tcp_output.c new/net/ipv4/tcp_output.c
> --- org/net/ipv4/tcp_output.c	2009-12-04 18:16:00.000000000 +0530
> +++ new/net/ipv4/tcp_output.c	2009-12-04 18:16:24.000000000 +0530
> @@ -1799,11 +1799,6 @@ static int tcp_write_xmit(struct sock *s
>  void __tcp_push_pending_frames(struct sock *sk, unsigned int cur_mss,
>  			       int nonagle)
>  {
> -	struct sk_buff *skb = tcp_send_head(sk);
> -
> -	if (!skb)
> -		return;
> -
>  	/* If we are closed, the bytes will have to remain here.
>  	 * In time closedown will finish, we empty the write queue and
>  	 * all will be happy.

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>


-- 
 i.
---696230645-2086464068-1260432359=:23376--
