From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next] tcp: syncookies: extend validity range
Date: Thu, 14 May 2015 17:12:54 -0700
Message-ID: <CAK6E8=etM=cDHw5Q9N-o_8JEZppRBfhorinw5D--1OxtGNnasQ@mail.gmail.com>
References: <1431638816.27831.80.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:33576 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423325AbbEOANf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 20:13:35 -0400
Received: by obblk2 with SMTP id lk2so65610948obb.0
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 17:13:35 -0700 (PDT)
In-Reply-To: <1431638816.27831.80.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 14, 2015 at 2:26 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Now we allow storing more request socks per listener, we might
> hit syncookie mode less often and hit following bug in our stack :
>
> When we send a burst of syncookies, then exit this mode,
> tcp_synq_no_recent_overflow() can return false if the ACK packets coming
> from clients are coming three seconds after the end of syncookie
> episode.
>
> This is a way too strong requirement and conflicts with rest of
> syncookie code which allows ACK to be aged up to 2 minutes.
>
> Perfectly valid ACK packets are dropped just because clients might be
> in a crowded wifi environment or on another planet.
>
> So let's fix this, and also change tcp_synq_overflow() to not
> dirty a cache line for every syncookie we send, as we are under attack.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>

Hopefully this reduces phony LINUX_MIB_SYNCOOKIESFAILED counts!

> ---
> As this is an old bug, I chose net-next tree.
>
>  include/net/tcp.h |   38 ++++++++++++++++++++++++--------------
>  1 file changed, 24 insertions(+), 14 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index b8ea12880fd9..7ace6acbf5fd 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -326,18 +326,6 @@ static inline bool tcp_too_many_orphans(struct sock *sk, int shift)
>
>  bool tcp_check_oom(struct sock *sk, int shift);
>
> -/* syncookies: remember time of last synqueue overflow */
> -static inline void tcp_synq_overflow(struct sock *sk)
> -{
> -       tcp_sk(sk)->rx_opt.ts_recent_stamp = jiffies;
> -}
> -
> -/* syncookies: no recent synqueue overflow on this listening socket? */
> -static inline bool tcp_synq_no_recent_overflow(const struct sock *sk)
> -{
> -       unsigned long last_overflow = tcp_sk(sk)->rx_opt.ts_recent_stamp;
> -       return time_after(jiffies, last_overflow + TCP_TIMEOUT_FALLBACK);
> -}
>
>  extern struct proto tcp_prot;
>
> @@ -483,13 +471,35 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb);
>   * i.e. a sent cookie is valid only at most for 2*60 seconds (or less if
>   * the counter advances immediately after a cookie is generated).
>   */
> -#define MAX_SYNCOOKIE_AGE 2
> +#define MAX_SYNCOOKIE_AGE      2
> +#define TCP_SYNCOOKIE_PERIOD   (60 * HZ)
> +#define TCP_SYNCOOKIE_VALID    (MAX_SYNCOOKIE_AGE * TCP_SYNCOOKIE_PERIOD)
> +
> +/* syncookies: remember time of last synqueue overflow
> + * But do not dirty this field too often (once per second is enough)
> + */
> +static inline void tcp_synq_overflow(struct sock *sk)
> +{
> +       unsigned long last_overflow = tcp_sk(sk)->rx_opt.ts_recent_stamp;
> +       unsigned long now = jiffies;
> +
> +       if (time_after(now, last_overflow + HZ))
> +               tcp_sk(sk)->rx_opt.ts_recent_stamp = now;
> +}
> +
> +/* syncookies: no recent synqueue overflow on this listening socket? */
> +static inline bool tcp_synq_no_recent_overflow(const struct sock *sk)
> +{
> +       unsigned long last_overflow = tcp_sk(sk)->rx_opt.ts_recent_stamp;
> +
> +       return time_after(jiffies, last_overflow + TCP_SYNCOOKIE_VALID);
> +}
>
>  static inline u32 tcp_cookie_time(void)
>  {
>         u64 val = get_jiffies_64();
>
> -       do_div(val, 60 * HZ);
> +       do_div(val, TCP_SYNCOOKIE_PERIOD);
>         return val;
>  }
>
>
>
