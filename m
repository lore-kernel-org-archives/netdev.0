From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RFC] [v3] TCP: use non-delayed ACK for congestion
 control RTT
Date: Sat, 29 Dec 2007 19:09:17 -0800 (PST)
Message-ID: <20071229.190917.130399687.davem@davemloft.net>
References: <Pine.LNX.4.64.0712211545580.7301@kivilampi-30.cs.helsinki.fi>
	<20071230011500.GA30997@nuim.ie>
	<20071230012549.GB30997@nuim.ie>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: Gavin.McCullagh@nuim.ie
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48913
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752791AbXL3DJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2007 22:09:23 -0500
In-Reply-To: <20071230012549.GB30997@nuim.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Never mind about making the relative patch, I didn't want to have
to wait for you to send me that and have it block my merge of
fixes with Linus this evening.

The following is what I applied on top of your other patch:

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 6fb7989..cbba288 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2660,6 +2660,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
 		u32 packets_acked;
 		u8 sacked = scb->sacked;
 
+		/* Determine how many packets and what bytes were acked, tso and else */ 
 		if (after(scb->end_seq, tp->snd_una)) {
 			if (tcp_skb_pcount(skb) == 1 ||
 			    !after(tp->snd_una, scb->seq))
@@ -2694,10 +2695,9 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
 					flag |= FLAG_NONHEAD_RETRANS_ACKED;
 			} else {
 				ca_seq_rtt = now - scb->when;
+				last_ackt = skb->tstamp;
 				if (seq_rtt < 0) {
 					seq_rtt = ca_seq_rtt;
-					if (fully_acked)
-						last_ackt = skb->tstamp;
 				}
 				if (!(sacked & TCPCB_SACKED_ACKED))
 					reord = min(cnt, reord);
@@ -2713,10 +2713,9 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
 				tp->urg_mode = 0;
 		} else {
 			ca_seq_rtt = now - scb->when;
+			last_ackt = skb->tstamp;
 			if (seq_rtt < 0) {
 				seq_rtt = ca_seq_rtt;
-				if (fully_acked)
-					last_ackt = skb->tstamp;
 			}
 			reord = min(cnt, reord);
 		}
