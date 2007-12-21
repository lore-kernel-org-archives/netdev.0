From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH/RFC] [v2] TCP: use non-delayed ACK for congestion	control
 RTT
Date: Fri, 21 Dec 2007 16:07:29 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712211545580.7301@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0712191241450.11908@kivilampi-30.cs.helsinki.fi>
 <20071219113125.GF31508@nuim.ie> <Pine.LNX.4.64.0712191511120.14629@kivilampi-30.cs.helsinki.fi>
 <20071221.031400.194877955.davem@davemloft.net> <20071221133106.GA7995@nuim.ie>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1085451526-1198246049=:7301"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57354 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754550AbXLUOHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 09:07:34 -0500
In-Reply-To: <20071221133106.GA7995@nuim.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1085451526-1198246049=:7301
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 21 Dec 2007, Gavin McCullagh wrote:

> On Fri, 21 Dec 2007, David Miller wrote:
> 
> > When Gavin respins the patch I'll look at in the context of submitting
> > it as a bug fix.  So Gavin please generate the patch against Linus's
> > vanilla GIT tree or net-2.6, your choise.
> 
> The existing patch was against Linus' linux-2.6.git from a few days ago so
> I've updated my tree and regenerated the patch (below).  Is that the right
> one?
> 
> I'm just checking through the existing CA modules.  I don't see the rtt
> used for RTO anywhere.  This is what I gather they're each using rtt for.

I meant more timeout like fashion (e.g., to "timeout" some internal 
phase but I don't find that too likely)...

Thanks for checking them.

> So as far as I can tell, timeout stuff is not ever altered using
> pkts_acked() so I guess this fix only affects westwood, htcp and cubic just
> now.
> 
> I need to re-read properly, but I think the same problem affects the
> microsecond values where TCP_CONG_RTT_STAMP is set (used by vegas, veno,
> yeah, illinois).  I might follow up with another patch which changes the
> behaviour where TCP_CONG_RTT_STAMP when I'm more sure of that.

Please do, you might have to remove fully_acked checks to do that right 
though so it won't be as straight-forward change as this one and requires 
some amount of thinking to result in a right thing.

> Signed-off-by: Gavin McCullagh <gavin.mccullagh@nuim.ie>
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 889c893..6fb7989 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -2651,6 +2651,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
>  	u32 cnt = 0;
>  	u32 reord = tp->packets_out;
>  	s32 seq_rtt = -1;
> +	s32 ca_seq_rtt = -1;
>  	ktime_t last_ackt = net_invalid_timestamp();
>  
>  	while ((skb = tcp_write_queue_head(sk)) && skb != tcp_send_head(sk)) {
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
> @@ -2772,8 +2776,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
>  						 net_invalid_timestamp()))
>  					rtt_us = ktime_us_delta(ktime_get_real(),
>  								last_ackt);
> -				else if (seq_rtt > 0)
> -					rtt_us = jiffies_to_usecs(seq_rtt);
> +				else if (ca_seq_rtt > 0)
> +					rtt_us = jiffies_to_usecs(ca_seq_rtt);
>  			}
>  
>  			ca_ops->pkts_acked(sk, pkts_acked, rtt_us);
> 

Acked-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

/ Reviewed-by... whatever, I don't know if they really started to use it
or not... :-)

-- 
 i.
---696243703-1085451526-1198246049=:7301--
