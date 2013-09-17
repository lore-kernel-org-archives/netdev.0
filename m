From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Why we discard all rtt samples when only some of the acked skbs
 have been retransmited in processing ack?
Date: Mon, 16 Sep 2013 22:11:22 -0700
Message-ID: <1379394682.29845.2.camel@edumazet-glaptop>
References: <CAAA3+BpsxtyM2uAvX6B4ys73ZC6fX5K1ib3Acsk0fp5cQBNgWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: LovelyLich <lovelylich@gmail.com>,
	Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:44950 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739Ab3IQFLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 01:11:24 -0400
Received: by mail-pd0-f172.google.com with SMTP id z10so5089924pdj.3
        for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 22:11:24 -0700 (PDT)
In-Reply-To: <CAAA3+BpsxtyM2uAvX6B4ys73ZC6fX5K1ib3Acsk0fp5cQBNgWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-17 at 12:01 +0800, LovelyLich wrote:
> Hi Eric,
> 
> In tcp_clean_rtx_queue(), we set the flag FLAG_RETRANS_DATA_ACKED when we
> 
> encounter one ever retransmited skb A. But if there is one( or more) skb B
> 
> after this retransmited skb, and we calculate the rtt for skb B. The question
> 
> is because we have set the flag FLAG_RETRANS_DATA_ACKED, and we will just
> 
> return in tcp_ack_no_tstamp() !
> 
> Two questions:
> 
> 1. if we will just ignore all packets in this ack, we do not need to calculate
> 
> skb B's rtt sample.
> 
> 2. what I want to know, even if A's rtt sample is not reliable, but B's rtt
> 
> sample can be trusted. Why we discard it ?
> 
> 
> 
> Thanks in advanced.
> 

Good point !

Yuchung, what do you think of following patch ?

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 25a89ea..7f12b96 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2971,7 +2971,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 	struct sk_buff *skb;
 	u32 now = tcp_time_stamp;
 	int fully_acked = true;
-	int flag = 0;
+	int flag = FLAG_RETRANS_DATA_ACKED;
 	u32 pkts_acked = 0;
 	u32 reord = tp->packets_out;
 	u32 prior_sacked = tp->sacked_out;
@@ -3002,7 +3002,6 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 		if (sacked & TCPCB_RETRANS) {
 			if (sacked & TCPCB_SACKED_RETRANS)
 				tp->retrans_out -= acked_pcount;
-			flag |= FLAG_RETRANS_DATA_ACKED;
 		} else {
 			ca_seq_rtt = now - scb->when;
 			last_ackt = skb->tstamp;
@@ -3013,6 +3012,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 				reord = min(pkts_acked, reord);
 			if (!after(scb->end_seq, tp->high_seq))
 				flag |= FLAG_ORIG_SACK_ACKED;
+			flag &= ~FLAG_RETRANS_DATA_ACKED;
 		}
 
 		if (sacked & TCPCB_SACKED_ACKED)
