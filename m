From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net] tcp: fix RTO calculated from cached RTT
Date: Tue, 17 Sep 2013 07:32:38 -0700
Message-ID: <CAK6E8=f5uMe6LQ5StCtaWt7D7PfaM2it0muxiW+gAZ4ngQwVbw@mail.gmail.com>
References: <1379382260-29303-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:59028 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752270Ab3IQOc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 10:32:58 -0400
Received: by mail-ie0-f179.google.com with SMTP id e14so10583046iej.10
        for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 07:32:58 -0700 (PDT)
In-Reply-To: <1379382260-29303-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 16, 2013 at 6:44 PM, Neal Cardwell <ncardwell@google.com> wrote:
> Commit 1b7fdd2ab5852 ("tcp: do not use cached RTT for RTT estimation")
> did not correctly account for the fact that crtt is the RTT shifted
> left 3 bits. Fix the calculation to consistently reflect this fact.
>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> ---
>  net/ipv4/tcp_metrics.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
Acked-By: Yuchung Cheng <ycheng@google.com>

Thanks for discovering and fixing it!

>
> diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
> index 4a22f3e..52f3c6b 100644
> --- a/net/ipv4/tcp_metrics.c
> +++ b/net/ipv4/tcp_metrics.c
> @@ -502,7 +502,9 @@ reset:
>          * ACKs, wait for troubles.
>          */
>         if (crtt > tp->srtt) {
> -               inet_csk(sk)->icsk_rto = crtt + max(crtt >> 2, tcp_rto_min(sk));
> +               /* Set RTO like tcp_rtt_estimator(), but from cached RTT. */
> +               crtt >>= 3;
> +               inet_csk(sk)->icsk_rto = crtt + max(2 * crtt, tcp_rto_min(sk));
>         } else if (tp->srtt == 0) {
>                 /* RFC6298: 5.7 We've failed to get a valid RTT sample from
>                  * 3WHS. This is most likely due to retransmission,
> --
> 1.8.4
>
