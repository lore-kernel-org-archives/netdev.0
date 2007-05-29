From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH-2.4] Fix divide by 0 in vegas_cong_avoid()
Date: Tue, 29 May 2007 08:05:34 -0700
Message-ID: <20070529080534.5692bad8@freepuppy>
References: <a5bf86a80705290218t5e8605d3m9750d9dae6d96112@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Lior Dotan" <liodot@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:37791 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750788AbXE2PKT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2007 11:10:19 -0400
In-Reply-To: <a5bf86a80705290218t5e8605d3m9750d9dae6d96112@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 May 2007 12:18:19 +0300
"Lior Dotan" <liodot@gmail.com> wrote:

> Hi,
> 
> I had a divide by zero on kernel 2.4.33 running with Vegas enabled.
> The KDB back trace is:
> kdb> bt
> Stack traceback for pid 0
> 0x403a6000        0        0  1    0   R  0x403a6370 *swapper
> EBP        EIP        Function (args)
> 0x403a7d48 0x4026ae51 vegas_cong_avoid+0x111 (0x5f3bb638, 0x73c92cbb, 0xffffffff
> , 0x73c92cbb, 0xf28d0275)
>                                kernel .text 0x40100000 0x4026ad40 0x4026aef0
> 0x403a7d8c 0x4026bb67 tcp_ack+0x307 (0x5f3bb560, 0x581985c0, 0x18e, 0x4023e765,
> 0x5c369044)
>                                kernel .text 0x40100000 0x4026b860 0x4026be20
> 0x403a7ddc 0x4026e771 tcp_rcv_established+0x461 (0x5f3bb560, 0x581985c0, 0x5c369
> 044, 0x2c, 0x5f3bb638)
>                                kernel .text 0x40100000 0x4026e310 0x4026ed80
> 0x403a7e00 0x40277c2f tcp_v4_do_rcv+0x14f (0x5f3bb560, 0x581985c0, 0x0, 0x403a7e
> 50, 0x4024bb42)
>                                kernel .text 0x40100000 0x40277ae0 0x40277c40
> <Rest was cut for readability>
> What happens is that vegas_rtt_calc() gets rtt as -1, so when it adds
> 1 the rtt is set to zero.
> It seems that the -1 came from tcp_clean_rtx_queue() so I made this
> small patch to fix the problem. I think it is also relevant to 2.6.


Seems like fixing the -1 would be better.  Perhaps NTP reset
the clock?

> 
> Don't perform congestion avoidance on packets that we didn't calculate
> there RTT, as this may result in a divide by zero later on.
> 
> Signed-off-by: Lior Dotan <liodot@gmail.com>
> ---
> 
> diff -up net/ipv4/tcp_input.c.orig net/ipv4/tcp_input.c
> --- net/ipv4/tcp_input.c.orig   2007-05-29 11:43:37.000000000 +0300
> +++ net/ipv4/tcp_input.c        2007-05-29 11:20:21.000000000 +0300
> @@ -2425,6 +2424,7 @@ static int tcp_clean_rtx_queue(struct so
>                                         tp->retrans_out--;
>                                 acked |= FLAG_RETRANS_DATA_ACKED;
>                                 seq_rtt = -1;
> +                               acked &= ~FLAG_DATA_ACKED;
>                         } else if (seq_rtt < 0)
>                                 seq_rtt = now - scb->when;
>                         if(sacked & TCPCB_SACKED_ACKED)
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
