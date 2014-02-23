From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: reduce the bloat caused by tcp_is_cwnd_limited()
Date: Sat, 22 Feb 2014 22:40:45 -0500
Message-ID: <CADVnQykpLKz2HJ168YNGXQDzcfHc4j-Tx04SArLQ24+n7_js3A@mail.gmail.com>
References: <1393105959.2316.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Van Jacobson <vanj@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:64871 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089AbaBWDkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 22:40:46 -0500
Received: by mail-ee0-f52.google.com with SMTP id c41so1498069eek.25
        for <netdev@vger.kernel.org>; Sat, 22 Feb 2014 19:40:45 -0800 (PST)
In-Reply-To: <1393105959.2316.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 22, 2014 at 4:52 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
...
> diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
> index ad37bf18ae4b..d74ebfb64e2b 100644
> --- a/net/ipv4/tcp_cong.c
> +++ b/net/ipv4/tcp_cong.c
> @@ -277,7 +277,6 @@ int tcp_set_congestion_control(struct sock *sk, const char *name)
>  }
>
>  /* RFC2861 Check whether we are limited by application or congestion window
> - * This is the inverse of cwnd check in tcp_tso_should_defer
>   */
>  bool tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight)
>  {
> @@ -288,10 +287,7 @@ bool tcp_is_cwnd_limited(const struct sock *sk, u32 in_flight)
>                 return true;
>
>         left = tp->snd_cwnd - in_flight;
> -       if (sk_can_gso(sk) &&
> -           left * sysctl_tcp_tso_win_divisor < tp->snd_cwnd &&
> -           left * tp->mss_cache < sk->sk_gso_max_size &&
> -           left < sk->sk_gso_max_segs)
> +       if (sk_can_gso(sk) && left < tp->xmit_size_goal_segs)
>                 return true;
>         return left <= tcp_max_tso_deferred_mss(tp);
>  }

Nice catch!

AFAICT we should keep the expression in there pertaining to
sysctl_tcp_tso_win_divisor. AFAICT tcp_is_cwnd_limited() is supposed
to be saying, "are we cwnd limited? that is, is the available cwnd we
have left at zero, or so small that it is probably only non-zero
because tcp_tso_should_defer() is trying to accumulate permission to
send a bigger TSO skb?"

To implement this, it seems we need to keep the code that checks for
possible deferral from both the sysctl_tcp_tso_win_divisor code path
and the tcp_max_tso_deferred_mss() code paths.

So, to me, the comment "This is the inverse of cwnd check in
tcp_tso_should_defer" is still relevant (though not very clear).

So AFAICT we want the patch to be something like:

--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -290,8 +290,7 @@ bool tcp_is_cwnd_limited(const struct sock *sk,
u32 in_flight)
        left = tp->snd_cwnd - in_flight;
        if (sk_can_gso(sk) &&
            left * sysctl_tcp_tso_win_divisor < tp->snd_cwnd &&
-           left * tp->mss_cache < sk->sk_gso_max_size &&
-           left < sk->sk_gso_max_segs)
+           left < sk->xmit_size_goal_segs)
                return true;
        return left <= tcp_max_tso_deferred_mss(tp);
 }

neal
