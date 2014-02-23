From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: reduce the bloat caused by tcp_is_cwnd_limited()
Date: Sat, 22 Feb 2014 22:19:50 -0800
Message-ID: <1393136390.2316.37.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393105959.2316.30.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CADVnQykpLKz2HJ168YNGXQDzcfHc4j-Tx04SArLQ24+n7_js3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Van Jacobson <vanj@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:53467 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbaBWGTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Feb 2014 01:19:52 -0500
Received: by mail-pa0-f42.google.com with SMTP id kl14so5219027pab.1
        for <netdev@vger.kernel.org>; Sat, 22 Feb 2014 22:19:52 -0800 (PST)
In-Reply-To: <CADVnQykpLKz2HJ168YNGXQDzcfHc4j-Tx04SArLQ24+n7_js3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-02-22 at 22:40 -0500, Neal Cardwell wrote:

> 
> AFAICT we should keep the expression in there pertaining to
> sysctl_tcp_tso_win_divisor. AFAICT tcp_is_cwnd_limited() is supposed
> to be saying, "are we cwnd limited? that is, is the available cwnd we
> have left at zero, or so small that it is probably only non-zero
> because tcp_tso_should_defer() is trying to accumulate permission to
> send a bigger TSO skb?"
> 
> To implement this, it seems we need to keep the code that checks for
> possible deferral from both the sysctl_tcp_tso_win_divisor code path
> and the tcp_max_tso_deferred_mss() code paths.
> 
> So, to me, the comment "This is the inverse of cwnd check in
> tcp_tso_should_defer" is still relevant (though not very clear).
> 
> So AFAICT we want the patch to be something like:
> 
> --- a/net/ipv4/tcp_cong.c
> +++ b/net/ipv4/tcp_cong.c
> @@ -290,8 +290,7 @@ bool tcp_is_cwnd_limited(const struct sock *sk,
> u32 in_flight)
>         left = tp->snd_cwnd - in_flight;
>         if (sk_can_gso(sk) &&
>             left * sysctl_tcp_tso_win_divisor < tp->snd_cwnd &&
> -           left * tp->mss_cache < sk->sk_gso_max_size &&
> -           left < sk->sk_gso_max_segs)
> +           left < sk->xmit_size_goal_segs)
>                 return true;
>         return left <= tcp_max_tso_deferred_mss(tp);
>  }
> 

Sure, I'll send a v2, thanks !
