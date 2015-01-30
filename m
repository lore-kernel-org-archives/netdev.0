From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next] tcp: use SACK RTTs for CC
Date: Fri, 30 Jan 2015 09:21:45 -0800
Message-ID: <CAK6E8=c6uAeAMvRfdxYNcqBLWmFTywbpvaqmzf7XmajkGSNqeg@mail.gmail.com>
References: <1422558483-6168-1-git-send-email-kennetkl@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>
To: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:50179 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759704AbbA3RW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 12:22:26 -0500
Received: by mail-ig0-f173.google.com with SMTP id a13so4805743igq.0
        for <netdev@vger.kernel.org>; Fri, 30 Jan 2015 09:22:25 -0800 (PST)
In-Reply-To: <1422558483-6168-1-git-send-email-kennetkl@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 29, 2015 at 11:08 AM, Kenneth Klette Jonassen
<kennetkl@ifi.uio.no> wrote:
> Current behavior only passes RTTs from sequentially acked data to CC.
>
> If sender gets a combined ACK for segment 1 and SACK for segment 3, then the
> computed RTT for CC is the time between sending segment 1 and receiving SACK
> for segment 3.
since segment 3 is sent after segment 1, sack_rtt_us <= ca_seq_rtt so
taking a min is not necessary?

>
> Pass the minimum computed RTT from any acked data to CC, i.e. time between
> sending segment 3 and receiving SACK for segment 3.
>
> Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
> ---
>  net/ipv4/tcp_input.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 71fb37c..ed11931 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -3183,8 +3183,10 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
>
>                 tp->fackets_out -= min(pkts_acked, tp->fackets_out);
>
> -               if (ca_ops->pkts_acked)
> -                       ca_ops->pkts_acked(sk, pkts_acked, ca_seq_rtt_us);
> +               if (ca_ops->pkts_acked) {
> +                       long rtt_us = min_t(ulong, ca_seq_rtt_us, sack_rtt_us);
> +                       ca_ops->pkts_acked(sk, pkts_acked, rtt_us);
> +               }
>
>         } else if (skb && rtt_update && sack_rtt_us >= 0 &&
>                    sack_rtt_us > skb_mstamp_us_delta(&now, &skb->skb_mstamp)) {
> --
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
