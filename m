From: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Subject: Re: [PATCH/RFC] [v3] TCP: use non-delayed ACK for congestion	control
 RTT
Date: Sun, 30 Dec 2007 01:25:49 +0000
Message-ID: <20071230012549.GB30997@nuim.ie>
References: <Pine.LNX.4.64.0712191241450.11908@kivilampi-30.cs.helsinki.fi>
 <20071219113125.GF31508@nuim.ie>
 <Pine.LNX.4.64.0712191511120.14629@kivilampi-30.cs.helsinki.fi>
 <20071221.031400.194877955.davem@davemloft.net>
 <20071221133106.GA7995@nuim.ie>
 <Pine.LNX.4.64.0712211545580.7301@kivilampi-30.cs.helsinki.fi>
 <20071230011500.GA30997@nuim.ie>
Reply-To: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from banyan.nuim.ie ([149.157.1.4]:49064 "EHLO mango.nuim.ie"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750960AbXL3BZp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Dec 2007 20:25:45 -0500
Content-disposition: inline
Received: from boing.hamilton.local ([149.157.192.252])
 by mango.nuim.ie (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3
 2007; 32bit)) with ESMTP id <0JTU0058X9AT3320@mango.nuim.ie> for
 netdev@vger.kernel.org; Sun, 30 Dec 2007 01:25:41 +0000 (GMT)
In-reply-to: <20071230011500.GA30997@nuim.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When a delayed ACK representing two packets arrives, there are two RTT
samples available, one for each packet.  The first (in order of seq number)
will be artificially long due to the delay waiting for the second packet,
the second will trigger the ACK and so will not itself be delayed.

According to rfc1323, the SRTT used for RTO calculation should use the
first rtt, so receivers echo the timestamp from the first packet in the
delayed ack.  For congestion control however, it seems measuring delayed
ack delay is not desirable as it varies independently of congestion.

The patch below causes seq_rtt and last_ackt to be updated with any
available later packet rtts which should have less (and hopefully zero)
delack delay.  The rtt value then gets passed to ca_ops->pkts_acked().

Where TCP_CONG_RTT_STAMP was set, effort was made to supress RTTs from
within a TSO chunk (!fully_acked), using only the final ACK (which includes
any TSO delay) to generate RTTs.   This patch removes these checks so RTTs
are passed for each ACK to ca_ops->pkts_acked().

For non-delay based congestion control (cubic, h-tcp), rtt is sometimes
used for rtt-scaling.  In shortening the RTT, this may make them a little
less aggressive.  Delay-based schemes (eg vegas, veno, illinois) should get
a cleaner, more accurate congestion signal, particularly for small cwnds.
The congestion control module can potentially also filter out bad RTTs due
to the delayed ack alarm by looking at the associated cnt which (where
delayed acking is in use) should probably be 1 if the alarm went off or
greater if the ACK was triggered by a packet.


Signed-off-by: Gavin McCullagh <gavin.mccullagh@nuim.ie>


diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 889c893..cbba288 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2651,6 +2651,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
 	u32 cnt = 0;
 	u32 reord = tp->packets_out;
 	s32 seq_rtt = -1;
+	s32 ca_seq_rtt = -1;
 	ktime_t last_ackt = net_invalid_timestamp();
 
 	while ((skb = tcp_write_queue_head(sk)) && skb != tcp_send_head(sk)) {
@@ -2659,6 +2660,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
 		u32 packets_acked;
 		u8 sacked = scb->sacked;
 
+		/* Determine how many packets and what bytes were acked, tso and else */ 
 		if (after(scb->end_seq, tp->snd_una)) {
 			if (tcp_skb_pcount(skb) == 1 ||
 			    !after(tp->snd_una, scb->seq))
@@ -2686,15 +2688,16 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
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
+				last_ackt = skb->tstamp;
 				if (seq_rtt < 0) {
-					seq_rtt = now - scb->when;
-					if (fully_acked)
-						last_ackt = skb->tstamp;
+					seq_rtt = ca_seq_rtt;
 				}
 				if (!(sacked & TCPCB_SACKED_ACKED))
 					reord = min(cnt, reord);
@@ -2709,10 +2712,10 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
 			    !before(end_seq, tp->snd_up))
 				tp->urg_mode = 0;
 		} else {
+			ca_seq_rtt = now - scb->when;
+			last_ackt = skb->tstamp;
 			if (seq_rtt < 0) {
-				seq_rtt = now - scb->when;
-				if (fully_acked)
-					last_ackt = skb->tstamp;
+				seq_rtt = ca_seq_rtt;
 			}
 			reord = min(cnt, reord);
 		}
@@ -2772,8 +2775,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
 						 net_invalid_timestamp()))
 					rtt_us = ktime_us_delta(ktime_get_real(),
 								last_ackt);
-				else if (seq_rtt > 0)
-					rtt_us = jiffies_to_usecs(seq_rtt);
+				else if (ca_seq_rtt > 0)
+					rtt_us = jiffies_to_usecs(ca_seq_rtt);
 			}
 
 			ca_ops->pkts_acked(sk, pkts_acked, rtt_us);
