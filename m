From: Jason Baron <jbaron@akamai.com>
Subject: [RFC PATCH] tcp: accept RST for rcv_nxt - 1 after receiving a FIN
Date: Thu,  5 Jan 2017 16:33:28 -0500
Message-ID: <1483652008-20255-1-git-send-email-jbaron@akamai.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:17741 "EHLO
        prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751417AbdAEVpC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 16:45:02 -0500
Received: from prod-mail-xrelay05.akamai.com (localhost.localdomain [127.0.0.1])
        by postfix.imss70 (Postfix) with ESMTP id 75CB8433407
        for <netdev@vger.kernel.org>; Thu,  5 Jan 2017 21:33:41 +0000 (GMT)
Received: from prod-mail-relay11.akamai.com (prod-mail-relay11.akamai.com [172.27.118.250])
        by prod-mail-xrelay05.akamai.com (Postfix) with ESMTP id 55E66433401
        for <netdev@vger.kernel.org>; Thu,  5 Jan 2017 21:33:41 +0000 (GMT)
Received: from bos-lpjec.kendall.corp.akamai.com (bos-lpjec.kendall.corp.akamai.com [172.28.12.167])
        by prod-mail-relay11.akamai.com (Postfix) with ESMTP id 373401FC88
        for <netdev@vger.kernel.org>; Thu,  5 Jan 2017 21:33:41 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using a Mac OSX box as a client connecting to a Linux server, we have found
that when certain applications (such as 'ab'), are abruptly terminated
(via ^C), a FIN is sent followed by a RST packet on tcp connections. The
FIN is accepted by the Linux stack but the RST is sent with the same
sequence number as the FIN, and Linux responds with a challenge ACK per
RFC 5961. The OSX client then does not reply with any RST as would be
expected on a closed socket.

This results in sockets accumulating on the Linux server left mostly in
the CLOSE_WAIT state, although LAST_ACK and CLOSING are also possible.
This sequence of events can tie up a lot of resources on the Linux server
since there may be a lot of data in write buffers at the time of the RST.
Accepting a RST equal to rcv_nxt - 1, after we have already successfully
processed a FIN, has made a significant difference for us in practice, by
freeing up unneeded resources in a more expedient fashion.

I also found a posting that the iOS client behaves in a similar manner here
(it will send a FIN followed by a RST for rcv_nxt - 1):
https://www.snellman.net/blog/archive/2016-02-01-tcp-rst/

A packetdrill test demonstrating the behavior.

// testing mac osx rst behavior

// Establish a connection
0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
0.000 bind(3, ..., ...) = 0
0.000 listen(3, 1) = 0

0.100 < S 0:0(0) win 32768 <mss 1460,nop,wscale 10>
0.100 > S. 0:0(0) ack 1 <mss 1460,nop,wscale 5>
0.200 < . 1:1(0) ack 1 win 32768
0.200 accept(3, ..., ...) = 4

// Client closes the connection
0.300 < F. 1:1(0) ack 1 win 32768

// now send rst with same sequence
0.300 < R. 1:1(0) ack 1 win 32768

// make sure we are in TCP_CLOSE
0.400 %{
assert tcpi_state == 7
}%

Signed-off-by: Jason Baron <jbaron@akamai.com>
---
 net/ipv4/tcp_input.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ec6d84363024..373bea05c93b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5249,6 +5249,24 @@ static int tcp_copy_to_iovec(struct sock *sk, struct sk_buff *skb, int hlen)
 	return err;
 }
 
+/* Accept RST for rcv_nxt - 1 after a FIN.
+ * When tcp connections are abruptly terminated from Mac OSX (via ^C), a
+ * FIN is sent followed by a RST packet. The RST is sent with the same
+ * sequence number as the FIN, and thus according to RFC 5961 a challenge
+ * ACK should be sent. However, Mac OSX does not reply to the challenge ACK
+ * with a RST on the closed socket, hence accept this class of RSTs.
+ */
+static bool tcp_reset_check(struct sock *sk, struct sk_buff *skb)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	return unlikely((TCP_SKB_CB(skb)->seq == (tp->rcv_nxt - 1)) &&
+			(TCP_SKB_CB(skb)->end_seq == (tp->rcv_nxt - 1))	&&
+			(sk->sk_state == TCP_CLOSE_WAIT ||
+			 sk->sk_state == TCP_LAST_ACK ||
+			 sk->sk_state == TCP_CLOSING));
+}
+
 /* Does PAWS and seqno based validation of an incoming segment, flags will
  * play significant role here.
  */
@@ -5287,6 +5305,8 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
 						  LINUX_MIB_TCPACKSKIPPEDSEQ,
 						  &tp->last_oow_ack_time))
 				tcp_send_dupack(sk, skb);
+		} else if (tcp_reset_check(sk, skb)) {
+			tcp_reset(sk);
 		}
 		goto discard;
 	}
@@ -5300,7 +5320,8 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
 		 * else
 		 *     Send a challenge ACK
 		 */
-		if (TCP_SKB_CB(skb)->seq == tp->rcv_nxt) {
+		if (TCP_SKB_CB(skb)->seq == tp->rcv_nxt ||
+		    tcp_reset_check(sk, skb)) {
 			rst_seq_match = true;
 		} else if (tcp_is_sack(tp) && tp->rx_opt.num_sacks > 0) {
 			struct tcp_sack_block *sp = &tp->selective_acks[0];
-- 
2.6.1
