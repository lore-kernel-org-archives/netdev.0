From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next 3/3] tcp: invoke pkts_acked hook on every ACK
Date: Thu, 30 Apr 2015 10:25:20 -0700
Message-ID: <CAK6E8=c1S5kmdZ8mjAf4+5otH8CeVjRD6VyGaS-U1tEMaGLgag@mail.gmail.com>
References: <1430411012-4939-1-git-send-email-kennetkl@ifi.uio.no> <1430411012-4939-3-git-send-email-kennetkl@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:35547 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbbD3R0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 13:26:02 -0400
Received: by igbyr2 with SMTP id yr2so20055200igb.0
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 10:26:01 -0700 (PDT)
In-Reply-To: <1430411012-4939-3-git-send-email-kennetkl@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 30, 2015 at 9:23 AM, Kenneth Klette Jonassen
<kennetkl@ifi.uio.no> wrote:
>
> Invoking pkts_acked is currently conditioned on FLAG_ACKED: receiving a
> cumulative ACK of new data, or ACK with SYN flag set.
>
> Remove this condition so that CC may get RTT measurements from all SACKs.
>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
> ---
>  net/ipv4/tcp_input.c | 9 +++------
>  1 file changed, 3 insertions(+), 6 deletions(-)
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 32bac6a..e5089c5 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -3161,9 +3161,6 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
>         rtt_update = tcp_ack_update_rtt(sk, flag, seq_rtt_us, sack_rtt_us);
>
>         if (flag & FLAG_ACKED) {
> -               const struct tcp_congestion_ops *ca_ops
> -                       = inet_csk(sk)->icsk_ca_ops;
> -
>                 tcp_rearm_rto(sk);
>                 if (unlikely(icsk->icsk_mtup.probe_size &&
>                              !after(tp->mtu_probe.probe_seq_end, tp->snd_una))) {
> @@ -3186,9 +3183,6 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
>
>                 tp->fackets_out -= min(pkts_acked, tp->fackets_out);
>
> -               if (ca_ops->pkts_acked)
> -                       ca_ops->pkts_acked(sk, pkts_acked, ca_rtt_us);
> -
>         } else if (skb && rtt_update && sack_rtt_us >= 0 &&
>                    sack_rtt_us > skb_mstamp_us_delta(&now, &skb->skb_mstamp)) {
>                 /* Do not re-arm RTO if the sack RTT is measured from data sent
> @@ -3198,6 +3192,9 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
>                 tcp_rearm_rto(sk);
>         }
>
> +       if (icsk->icsk_ca_ops->pkts_acked)
> +               icsk->icsk_ca_ops->pkts_acked(sk, pkts_acked, ca_rtt_us);
> +
There might be congestion control that assumes pkts_acked > 0 or data
is cumulatively when this is called. Did you audit that?


>  #if FASTRETRANS_DEBUG > 0
>         WARN_ON((int)tp->sacked_out < 0);
>         WARN_ON((int)tp->lost_out < 0);
> --
> 2.1.0
>
