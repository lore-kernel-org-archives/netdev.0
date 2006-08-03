From: Wei Yongjun <yjwei@nanjing-fnst.com>
Subject: Re: [PATCH] SNMPv2 tcpOutSegs counter error
Date: Thu, 03 Aug 2006 11:46:58 -0400
Message-ID: <1154620019.9095.5.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:9385 "EHLO
	localmail.nanjing-fnst.com") by vger.kernel.org with ESMTP
	id S932468AbWHCLE6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 07:04:58 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I modified my patch by add a flag to sacked when retransmit, and it work
well.


On Monday 24 July 2006 17:44, David Miller wrote:
> From: Wei Yongjun <yjwei@nanjing-fnst.com>
> Date: Thu, 06 Jul 2006 04:01:18 -0400
>
> This test is not accurate enough.  For example, timer based
> retransmits will not set the TCPCB_LOST bit.
>
> I'm tempted to say to pass a flag to tcp_transmit_skb()
> which says whether it is a retransmit or not, but that
> function already takes way too many arguments.

Signed-off-by: Wei Yongjun <yjwei@nanjing-fnst.com>

--- a/include/net/tcp.h	2006-07-28 16:19:14.000000000 -0400
+++ b/include/net/tcp.h	2006-08-03 17:56:35.686158424 -0400
@@ -550,6 +550,8 @@ struct tcp_skb_cb {
 
 #define TCPCB_URG		0x20	/* Urgent pointer advanced here	*/
 
+#define TCPCB_TRANS		0x40
+
 #define TCPCB_AT_TAIL		(TCPCB_URG)
 
 	__u16		urg_ptr;	/* Valid w/URG flags is set.	*/
 
--- a/net/ipv4/tcp_output.c	2006-08-03 18:05:22.425081936 -0400
+++ b/net/ipv4/tcp_output.c	2006-08-03 17:59:16.462716672 -0400
@@ -462,7 +462,8 @@ static int tcp_transmit_skb(struct sock 
 	if (skb->len != tcp_header_size)
 		tcp_event_data_sent(tp, skb, sk);
 
-	TCP_INC_STATS(TCP_MIB_OUTSEGS);
+	if(!(tcb->sacked & TCPCB_TRANS))
+		TCP_INC_STATS(TCP_MIB_OUTSEGS);
 
 	err = icsk->icsk_af_ops->queue_xmit(skb, 0);
 	if (likely(err <= 0))
@@ -1732,6 +1733,8 @@ int tcp_retransmit_skb(struct sock *sk, 
 	 */
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
 
+	TCP_SKB_CB(skb)->sacked |= TCPCB_TRANS;
+
 	err = tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
 
 	if (err == 0) {


