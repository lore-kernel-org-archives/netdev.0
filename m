From: John Heffner <jheffner@psc.edu>
Subject: Re: simplify microsecond rtt sampling
Date: Wed, 27 Sep 2006 16:13:29 +0100
Message-ID: <451A9519.6000504@psc.edu>
References: <451A5EC9.6090001@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:40702 "EHLO mailer2.psc.edu")
	by vger.kernel.org with ESMTP id S964902AbWI0PNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 11:13:46 -0400
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <451A5EC9.6090001@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Okay, this patch is junk (never trust compile-tested code).  Will send 
something better soon.

   -John


John Heffner wrote:
> About commit 2d2abbab63f6726a147ae61ada39bf2c9ee0db9a:
> 
> It looks like this patch bypassed the enforcement of Karn's algorithm in 
> tcp_ack_no_tstamp() for the purposes of usec RTT sampling used by 
> congestion control modules.  This will give them bad RTT data when there 
> are retransmits.  I haven't actually observed this, but it seems like it 
> would be the case. ;)  Please correct me if I'm wrong.
> 
> Here's a patch that should be a fix.
> 
> 
> 
> Signed-off-by: John Heffner <jheffner@psc.edu>
> 
> 
> ------------------------------------------------------------------------
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 159fa3f..725c868 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -2306,8 +2306,6 @@ static int tcp_clean_rtx_queue(struct so
>  				seq_rtt = -1;
>  			} else if (seq_rtt < 0) {
>  				seq_rtt = now - scb->when;
> -				if (rtt_sample)
> -					(*rtt_sample)(sk, tcp_usrtt(skb));
>  			}
>  			if (sacked & TCPCB_SACKED_ACKED)
>  				tp->sacked_out -= tcp_skb_pcount(skb);
> @@ -2320,8 +2318,6 @@ static int tcp_clean_rtx_queue(struct so
>  			}
>  		} else if (seq_rtt < 0) {
>  			seq_rtt = now - scb->when;
> -			if (rtt_sample)
> -				(*rtt_sample)(sk, tcp_usrtt(skb));
>  		}
>  		tcp_dec_pcount_approx(&tp->fackets_out, skb);
>  		tcp_packets_out_dec(tp, skb);
> @@ -2333,6 +2329,8 @@ static int tcp_clean_rtx_queue(struct so
>  	if (acked&FLAG_ACKED) {
>  		tcp_ack_update_rtt(sk, acked, seq_rtt);
>  		tcp_ack_packets_out(sk, tp);
> +		if (rtt_sample && !(acked & FLAG_RETRANS_DATA_ACKED))
> +			(*rtt_sample)(sk, tcp_usrtt(skb));
>  
>  		if (icsk->icsk_ca_ops->pkts_acked)
>  			icsk->icsk_ca_ops->pkts_acked(sk, pkts_acked);

