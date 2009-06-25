From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] tcp: missing check ACK flag of received segment in FIN-WAIT-2
 state
Date: Thu, 25 Jun 2009 16:29:31 +0800
Message-ID: <4A43356B.7060005@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61384 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751744AbZFYIaP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2009 04:30:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC0793 defined that in FIN-WAIT-2 state if the ACK bit is off drop
the segment and return[Page 72]. But this check is missing in function
tcp_timewait_state_process(). This cause the segment with FIN flag but
no ACK has two diffent action:

Case 1:
    Node A                      Node B
              <-------------    FIN,ACK
                                (enter FIN-WAIT-1)
    ACK       ------------->
                                (enter FIN-WAIT-2)
    FIN       ------------->    discard
                                (move sk to tw list)

Case 2:
    Node A                      Node B
              <-------------    FIN,ACK
                                (enter FIN-WAIT-1)
    ACK       ------------->
                                (enter FIN-WAIT-2)
                                (move sk to tw list)
    FIN       ------------->

              <-------------    ACK

This patch fixed the problem.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/ipv4/tcp_minisocks.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 43bbba7..f8d67cc 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -128,7 +128,8 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 			goto kill_with_rst;
 
 		/* Dup ACK? */
-		if (!after(TCP_SKB_CB(skb)->end_seq, tcptw->tw_rcv_nxt) ||
+		if (!th->ack ||
+		    !after(TCP_SKB_CB(skb)->end_seq, tcptw->tw_rcv_nxt) ||
 		    TCP_SKB_CB(skb)->end_seq == TCP_SKB_CB(skb)->seq) {
 			inet_twsk_put(tw);
 			return TCP_TW_SUCCESS;
-- 
1.6.2.2




