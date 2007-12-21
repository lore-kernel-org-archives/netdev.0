From: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Subject: Re: [PATCH/RFC] [v2] TCP: use non-delayed ACK for congestion	control
 RTT
Date: Fri, 21 Dec 2007 13:31:06 +0000
Message-ID: <20071221133106.GA7995@nuim.ie>
References: <Pine.LNX.4.64.0712191241450.11908@kivilampi-30.cs.helsinki.fi>
 <20071219113125.GF31508@nuim.ie>
 <Pine.LNX.4.64.0712191511120.14629@kivilampi-30.cs.helsinki.fi>
 <20071221.031400.194877955.davem@davemloft.net>
Reply-To: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from banyan.nuim.ie ([149.157.1.4]:50537 "EHLO mango.nuim.ie"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754561AbXLUNbD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 08:31:03 -0500
Content-disposition: inline
Received: from boing.hamilton.local ([149.157.192.252])
 by mango.nuim.ie (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3
 2007; 32bit)) with ESMTP id <0JTE00O9TIVMFI30@mango.nuim.ie> for
 netdev@vger.kernel.org; Fri, 21 Dec 2007 13:30:58 +0000 (GMT)
In-reply-to: <20071221.031400.194877955.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Dec 2007, David Miller wrote:

> When Gavin respins the patch I'll look at in the context of submitting
> it as a bug fix.  So Gavin please generate the patch against Linus's
> vanilla GIT tree or net-2.6, your choise.

The existing patch was against Linus' linux-2.6.git from a few days ago so
I've updated my tree and regenerated the patch (below).  Is that the right
one?

I'm just checking through the existing CA modules.  I don't see the rtt
used for RTO anywhere.  This is what I gather they're each using rtt for.

tcp_highspeed.c doesn't implement .pkts_acked
tcp_hybla.c     doesn't implement .pkts_acked
tcp_scalable.c  doesn't implement .pkts_acked
tcp_bic.c       ignores rtt value from .pkts_acked

tcp_lp.c        seems to ignore rtt value from .pkts_acked (despite setting
		TCP_CONG_RTT_STAMP for high res rtts -- why?)
tcp_vegas.c     uses high res rtt to measure congestion signal, increase,
		backoff -- TCP_CONG_RTT_STAMP set so doesn't use seq_rtt
tcp_veno.c      uses high res rtt to measure congestion signal, increase,
		backoff -- TCP_CONG_RTT_STAMP set so doesn't use seq_rtt
tcp_yeah.c      uses high res rtt to measure congestion signal, increase,
		backoff -- TCP_CONG_RTT_STAMP set so doesn't use seq_rtt
tcp_illinois.c  uses rtt to scale increase, backoff 
		-- TCP_CONG_RTT_STAMP set so doesn't use seq_rtt

tcp_htcp.c      uses rtt to scale increase, backoff 
tcp_cubic.c     uses rtt to scale increase, backoff
tcp_westwood.c  scales backoff using rtt

So as far as I can tell, timeout stuff is not ever altered using
pkts_acked() so I guess this fix only affects westwood, htcp and cubic just
now.

I need to re-read properly, but I think the same problem affects the
microsecond values where TCP_CONG_RTT_STAMP is set (used by vegas, veno,
yeah, illinois).  I might follow up with another patch which changes the
behaviour where TCP_CONG_RTT_STAMP when I'm more sure of that.

Thanks,
Gavin


Signed-off-by: Gavin McCullagh <gavin.mccullagh@nuim.ie>

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 889c893..6fb7989 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2651,6 +2651,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
 	u32 cnt = 0;
 	u32 reord = tp->packets_out;
 	s32 seq_rtt = -1;
+	s32 ca_seq_rtt = -1;
 	ktime_t last_ackt = net_invalid_timestamp();
 
 	while ((skb = tcp_write_queue_head(sk)) && skb != tcp_send_head(sk)) {
@@ -2686,13 +2687,15 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
 				if (sacked & TCPCB_SACKED_RETRANS)
 					tp->retrans_out -= packets_acked;
 				flag |= FLAG_RETRANS_DATA_ACKED;
+				ca_seq_rtt = -1;
 				seq_rtt = -1;
 				if ((flag & FLAG_DATA_ACKED) ||
 				    (packets_acked > 1))
 					flag |= FLAG_NONHEAD_RETRANS_ACKED;
 			} else {
+				ca_seq_rtt = now - scb->when;
 				if (seq_rtt < 0) {
-					seq_rtt = now - scb->when;
+					seq_rtt = ca_seq_rtt;
 					if (fully_acked)
 						last_ackt = skb->tstamp;
 				}
@@ -2709,8 +2712,9 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
 			    !before(end_seq, tp->snd_up))
 				tp->urg_mode = 0;
 		} else {
+			ca_seq_rtt = now - scb->when;
 			if (seq_rtt < 0) {
-				seq_rtt = now - scb->when;
+				seq_rtt = ca_seq_rtt;
 				if (fully_acked)
 					last_ackt = skb->tstamp;
 			}
@@ -2772,8 +2776,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
 						 net_invalid_timestamp()))
 					rtt_us = ktime_us_delta(ktime_get_real(),
 								last_ackt);
-				else if (seq_rtt > 0)
-					rtt_us = jiffies_to_usecs(seq_rtt);
+				else if (ca_seq_rtt > 0)
+					rtt_us = jiffies_to_usecs(ca_seq_rtt);
 			}
 
 			ca_ops->pkts_acked(sk, pkts_acked, rtt_us);
