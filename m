From: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Subject: [PATCH/RFC] TCP: use non-delayed ACK for congestion control RTT
Date: Mon, 17 Dec 2007 13:44:25 +0000
Message-ID: <20071217134425.GD7409@nuim.ie>
Reply-To: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from banyan.nuim.ie ([149.157.1.4]:44107 "EHLO mango.nuim.ie"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755626AbXLQNoW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 08:44:22 -0500
Content-disposition: inline
Received: from boing.hamilton.local ([149.157.192.252])
 by mango.nuim.ie (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3
 2007; 32bit)) with ESMTP id <0JT700FDJ4TUYV50@mango.nuim.ie> for
 netdev@vger.kernel.org; Mon, 17 Dec 2007 13:44:18 +0000 (GMT)
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

The patch below causes seq_rtt to be updated with any available later
packet rtts which should have less (and hopefully zero) delack delay.  The
lower seq_rtt then gets passed to ca_ops->pkts_acked().  

For non-delay based congestion control (cubic, h-tcp), rtt is sometimes
used for rtt-scaling.  In shortening the RTT, this may make them a little
less aggressive.  Delay-based schemes (eg vegas, illinois) should get a
considerably cleaner, more accurate congestion signal, particularly for
small cwnds. The congestion control module can potentially also filter out
bad RTTs due to the delayed ack alarm by looking at the associated cnt
which (where delayed acking is in use) should probably be 1 if the alarm
went off or greater if the ACK was triggered by a packet.

I seem to be undoing a design decision here so perhaps there is some reason
this should not be done?  Comments/explanations appreciated...


Signed-off-by: Gavin McCullagh <gavin.mccullagh@nuim.ie>


--- a/net/ipv4/tcp_input.c	2007-12-15 00:22:23.000000000 +0000
+++ b/net/ipv4/tcp_input.c	2007-12-17 13:35:16.000000000 +0000
@@ -2691,11 +2691,9 @@ static int tcp_clean_rtx_queue(struct so
 				    (packets_acked > 1))
 					flag |= FLAG_NONHEAD_RETRANS_ACKED;
 			} else {
-				if (seq_rtt < 0) {
-					seq_rtt = now - scb->when;
-					if (fully_acked)
-						last_ackt = skb->tstamp;
-				}
+				seq_rtt = now - scb->when;
+				if (fully_acked)
+					last_ackt = skb->tstamp;
 				if (!(sacked & TCPCB_SACKED_ACKED))
 					reord = min(cnt, reord);
 			}
@@ -2709,11 +2707,9 @@ static int tcp_clean_rtx_queue(struct so
 			    !before(end_seq, tp->snd_up))
 				tp->urg_mode = 0;
 		} else {
-			if (seq_rtt < 0) {
-				seq_rtt = now - scb->when;
-				if (fully_acked)
-					last_ackt = skb->tstamp;
-			}
+			seq_rtt = now - scb->when;
+			if (fully_acked)
+				last_ackt = skb->tstamp;
 			reord = min(cnt, reord);
 		}
 		tp->packets_out -= packets_acked;

