From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Proportional Rate Reduction for TCP.
Date: Fri, 19 Aug 2011 03:26:51 -0700 (PDT)
Message-ID: <20110819.032651.405436165608502880.davem@davemloft.net>
References: <1313134197-5082-1-git-send-email-nanditad@google.com>
	<1313739212-2315-1-git-send-email-nanditad@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, mattmathis@google.com,
	ycheng@google.com
To: nanditad@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59764 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752846Ab1HSK0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 06:26:54 -0400
In-Reply-To: <1313739212-2315-1-git-send-email-nanditad@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nandita Dukkipati <nanditad@google.com>
Date: Fri, 19 Aug 2011 00:33:32 -0700

> @@ -2830,9 +2830,14 @@ static int tcp_try_undo_loss(struct sock *sk)
>  static inline void tcp_complete_cwr(struct sock *sk)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
> -	/* Do not moderate cwnd if it's already undone in cwr or recovery */
> -	if (tp->undo_marker && tp->snd_cwnd > tp->snd_ssthresh) {
> -		tp->snd_cwnd = tp->snd_ssthresh;
> +
> +	/* Do not moderate cwnd if it's already undone in cwr or recovery. */
> +	if (tp->undo_marker) {
> +
> +		if (inet_csk(sk)->icsk_ca_state == TCP_CA_CWR)

Please get rid of that empty line before the TCP_CA_CWR case.

> +		sndcnt = DIV_ROUND_UP((u64)(tp->prr_delivered *
> +					    tp->snd_ssthresh),
> +				      (u64)tp->prior_cwnd) - tp->prr_out;

This won't link on 32-bit unless __divdi3 libgcc routine is provided
by the architecture.  To portably do 64-bit division you need to use
do_div() or something based upon it.  Perhaps DIV_ROUND_UP_LL() will
work best in this case.


