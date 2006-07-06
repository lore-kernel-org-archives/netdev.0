From: Wei Yongjun <yjwei@nanjing-fnst.com>
Subject: [PATCH] SNMPv2 tcpOutSegs counter error
Date: Thu, 06 Jul 2006 04:01:18 -0400
Message-ID: <1152172878.4695.2.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:42127 "EHLO
	localmail.nanjing-fnst.com") by vger.kernel.org with ESMTP
	id S964985AbWGFINS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jul 2006 04:13:18 -0400
Received: from proxy.fnst.com.cn ([192.168.10.4])
	by localmail.nanjing-fnst.com (8.12.11/8.12.11) with ESMTP id k6685v1B002711
	for <netdev@vger.kernel.org>; Thu, 6 Jul 2006 16:05:57 +0800
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RFC2012 saied that tcpOutSegs should excluding those containing only
retransmitted octets. But in my test, linux kernel increased the
tcpOutSegs even if only retransmitted octets is send out.
So I think this is a bug of kernel.

Refer to RFC2012, tcpOutSegs is defined as following:

   tcpOutSegs OBJECT-TYPE
       SYNTAX      Counter32
       MAX-ACCESS  read-only
       STATUS      current
       DESCRIPTION
               "The total number of segments sent, including those on
               current connections but excluding those containing only
               retransmitted octets."
       ::= { tcp 11 }

Following is my patch:

--- a/net/ipv4/tcp_output.c	2006-06-30 13:37:38.000000000 -0400
+++ b/net/ipv4/tcp_output.c	2006-07-05 04:49:56.000000000 -0400
@@ -462,7 +462,8 @@ static int tcp_transmit_skb(struct sock 
 	if (skb->len != tcp_header_size)
 		tcp_event_data_sent(tp, skb, sk);
 
-	TCP_INC_STATS(TCP_MIB_OUTSEGS);
+	if (!(tcb->sacked & TCPCB_LOST))
+		TCP_INC_STATS(TCP_MIB_OUTSEGS);
 
 	err = icsk->icsk_af_ops->queue_xmit(skb, 0);
 	if (likely(err <= 0))

Signed-off-by: Wei Yongjun <yjwei@nanjing-fnst.com>


