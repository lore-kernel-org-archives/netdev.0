From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH/RFC] [v2] TCP: use non-delayed ACK for congestion	control
 RTT
Date: Wed, 19 Dec 2007 13:08:35 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712191241450.11908@kivilampi-30.cs.helsinki.fi>
References: <20071217134425.GD7409@nuim.ie> <20071218204022.GA8936@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36295 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874AbXLSLIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 06:08:38 -0500
In-Reply-To: <20071218204022.GA8936@nuim.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Dec 2007, Gavin McCullagh wrote:

> The last attempt didn't take account of the situation where a timestamp
> wasn't available and tcp_clean_rtx_queue() has to feed both the RTO and the
> congestion avoidance.  This updated patch stores both RTTs, making the
> delayed one available for the RTO and the other (ca_seq_rtt) available for
> congestion control.
> 
> 
> Signed-off-by: Gavin McCullagh <gavin.mccullagh@nuim.ie> 
> 
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 889c893..6fb7989 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -2686,13 +2687,15 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
>  				if (sacked & TCPCB_SACKED_RETRANS)
>  					tp->retrans_out -= packets_acked;
>  				flag |= FLAG_RETRANS_DATA_ACKED;
> +				ca_seq_rtt = -1;
>  				seq_rtt = -1;
>  				if ((flag & FLAG_DATA_ACKED) ||
>  				    (packets_acked > 1))
>  					flag |= FLAG_NONHEAD_RETRANS_ACKED;
>  			} else {
> +				ca_seq_rtt = now - scb->when;

Isn't it also much better this way in a case where ACK losses happened,
taking the longest RTT in that case is clearly questionable as it
may over-estimate considerably.

However, another thing to consider is the possibility of this value being 
used in "timeout-like" fashion in ca modules (I haven't read enough ca 
modules code to know if any of them does that), on contrary to 
determinating just rtt or packet's delay in which case this change seems 
appropriate (most modules do the latter). Therefore, if timeout-like 
module exists one should also add TCP_CONG_RTT_STAMP_LONGEST for that 
particular module and keep using seq_rtt for it like previously and use 
ca_seq_rtt only for others.

>  				if (seq_rtt < 0) {
> -					seq_rtt = now - scb->when;
> +					seq_rtt = ca_seq_rtt;
>  					if (fully_acked)
>  						last_ackt = skb->tstamp;
>  				}
> @@ -2709,8 +2712,9 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
>  			    !before(end_seq, tp->snd_up))
>  				tp->urg_mode = 0;
>  		} else {
> +			ca_seq_rtt = now - scb->when;
>  			if (seq_rtt < 0) {
> -				seq_rtt = now - scb->when;
> +				seq_rtt = ca_seq_rtt;
>  				if (fully_acked)
>  					last_ackt = skb->tstamp;
>  			}

This part doesn't exists anymore in development tree. Please base this 
patch (and anything in future) you intend to get included to mainline
onto net-2.6.25 unless there's a very good reason to not do so or 
whatever 2.6.xx is the correct net development tree at that time (if
one exists). Thanks.


-- 
 i.
