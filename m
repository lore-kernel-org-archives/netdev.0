From: Wei Yongjun <yjwei@nanjing-fnst.com>
Subject: [PATCH] SNMPv2 tcpAttemptFails counter error
Date: Wed, 05 Jul 2006 05:19:54 -0400
Message-ID: <1152091195.3866.4.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:48775 "EHLO
	localmail.nanjing-fnst.com") by vger.kernel.org with ESMTP
	id S964775AbWGEJKJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 05:10:09 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Refer to RFC2012, tcpAttemptFails is defined as following:
  tcpAttemptFails OBJECT-TYPE
      SYNTAX      Counter32
      MAX-ACCESS  read-only
      STATUS      current
      DESCRIPTION
              "The number of times TCP connections have made a direct
              transition to the CLOSED state from either the SYN-SENT
              state or the SYN-RCVD state, plus the number of times TCP
              connections have made a direct transition to the LISTEN
              state from the SYN-RCVD state."
      ::= { tcp 7 }

When I lookup into RFC793, I found that the state change should occured
under following condition:
  1. SYN-SENT -> CLOSED
     a) Received ACK,RST segment when SYN-SENT state.

  2. SYN-RCVD -> CLOSED
     b) Received SYN segment when SYN-RCVD state(came from LISTEN).
     c) Received RST segment when SYN-RCVD state(came from SYN-SENT).
     d) Received SYN segment when SYN-RCVD state(came from SYN-SENT).

  3. SYN-RCVD -> LISTEN
     e) Received RST segment when SYN-RCVD state(came from LISTEN).

In my test, those direct state transition can not be counted to
tcpAttemptFails. Following is my patch:

Signed-off-by: Wei Yongjun <yjwei@nanjing-fnst.com>

--- a/net/ipv4/tcp_input.c	2006-06-30 13:37:38.000000000 -0400
+++ b/net/ipv4/tcp_input.c	2006-07-05 04:45:04.000000000 -0400
@@ -4089,6 +4089,7 @@ static int tcp_rcv_synsent_state_process
 		 */
 
 		if (th->rst) {
+			TCP_INC_STATS_BH(TCP_MIB_ATTEMPTFAILS);
 			tcp_reset(sk);
 			goto discard;
 		}
@@ -4377,6 +4378,8 @@ int tcp_rcv_state_process(struct sock *s
 
 	/* step 2: check RST bit */
 	if(th->rst) {
+		if(sk->sk_state == TCP_SYN_RECV)
+			TCP_INC_STATS_BH(TCP_MIB_ATTEMPTFAILS);
 		tcp_reset(sk);
 		goto discard;
 	}
@@ -4390,6 +4393,8 @@ int tcp_rcv_state_process(struct sock *s
 	 *	Check for a SYN in window.
 	 */
 	if (th->syn && !before(TCP_SKB_CB(skb)->seq, tp->rcv_nxt)) {
+		if(sk->sk_state == TCP_SYN_RECV)
+			TCP_INC_STATS_BH(TCP_MIB_ATTEMPTFAILS);
 		NET_INC_STATS_BH(LINUX_MIB_TCPABORTONSYN);
 		tcp_reset(sk);
 		return 1;
--- a/net/ipv4/tcp_minisocks.c	2006-06-30 13:37:38.000000000 -0400
+++ b/net/ipv4/tcp_minisocks.c	2006-07-05 04:45:04.000000000 -0400
@@ -592,8 +592,10 @@ struct sock *tcp_check_req(struct sock *
 		/* RFC793: "second check the RST bit" and
 		 *	   "fourth, check the SYN bit"
 		 */
-		if (flg & (TCP_FLAG_RST|TCP_FLAG_SYN))
+		if (flg & (TCP_FLAG_RST|TCP_FLAG_SYN)) {
+			TCP_INC_STATS_BH(TCP_MIB_ATTEMPTFAILS);
 			goto embryonic_reset;
+		}
 
 		/* ACK sequence verified above, just make sure ACK is
 		 * set.  If ACK not set, just silently drop the packet.




