From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCH net-next] tcp: fix ABC in tcp_slow_start()
Date: Fri, 20 Jul 2012 10:41:07 -0400
Message-ID: <CABrhC0kdw7Uv-67t7fFcfh-Pve1LsNAQ3HGnUmCOJVB7b0dUVQ@mail.gmail.com>
References: <1342762841.2626.5633.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:48708 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752766Ab2GTOlI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 10:41:08 -0400
Received: by yhmm54 with SMTP id m54so4025722yhm.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 07:41:08 -0700 (PDT)
In-Reply-To: <1342762841.2626.5633.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It might be clearer to instead introduce a temporary variable to
calculate the snd_cwnd change in the while loop.  That is:

        unsigned int snd_cwnd_delta = 0;
...
        tp->snd_cwnd_cnt += cnt;
        while (tp->snd_cwnd_cnt >= tp->snd_cwnd) {
                tp->snd_cwnd_cnt -= tp->snd_cwnd;
                snd_cwnd_delta++;
        }
        tp->snd_cwnd = min(tp->snd_cwnd + snd_cwnd_delta, tp->snd_cwnd_clamp);



On Fri, Jul 20, 2012 at 1:40 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> When/if sysctl_tcp_abc > 1, we expect to increase cwnd by 2 if the
> received ACK acknowledges more than 2*MSS bytes, in tcp_slow_start()
>
> Problem is this RFC 3465 statement is not correctly coded, as
> the while () loop increases snd_cwnd one by one.
>
> So to reach the "cwnd += 2" goal, we need to use "cnt = 2*cnt + 1"
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Nandita Dukkipati <nanditad@google.com>
> Cc: John Heffner <johnwheffner@gmail.com>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> ---
>  net/ipv4/tcp_cong.c |   13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)
>
> diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
> index 04dbd7a..486379a 100644
> --- a/net/ipv4/tcp_cong.c
> +++ b/net/ipv4/tcp_cong.c
> @@ -306,7 +306,7 @@ EXPORT_SYMBOL_GPL(tcp_is_cwnd_limited);
>   */
>  void tcp_slow_start(struct tcp_sock *tp)
>  {
> -       int cnt; /* increase in packets */
> +       unsigned int cnt; /* increase in packets */
>
>         /* RFC3465: ABC Slow start
>          * Increase only after a full MSS of bytes is acked
> @@ -318,16 +318,19 @@ void tcp_slow_start(struct tcp_sock *tp)
>         if (sysctl_tcp_abc && tp->bytes_acked < tp->mss_cache)
>                 return;
>
> -       if (sysctl_tcp_max_ssthresh > 0 && tp->snd_cwnd > sysctl_tcp_max_ssthresh)
> +       cnt = tp->snd_cwnd;                     /* exponential increase */
> +       if (sysctl_tcp_max_ssthresh > 0 &&
> +           tp->snd_cwnd > sysctl_tcp_max_ssthresh)
>                 cnt = sysctl_tcp_max_ssthresh >> 1;     /* limited slow start */
> -       else
> -               cnt = tp->snd_cwnd;                     /* exponential increase */
>
>         /* RFC3465: ABC
>          * We MAY increase by 2 if discovered delayed ack
> +        * The "+ 1" in the expression is needed if we want to increase
> +        * cwnd by 2, because the way is coded the following loop.
>          */
>         if (sysctl_tcp_abc > 1 && tp->bytes_acked >= 2*tp->mss_cache)
> -               cnt <<= 1;
> +               cnt = 2*cnt + 1;
> +
>         tp->bytes_acked = 0;
>
>         tp->snd_cwnd_cnt += cnt;
>
>
