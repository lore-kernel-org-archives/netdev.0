From: Jason Baron <jbaron@akamai.com>
Subject: strange Mac OSX RST behavior
Date: Fri,  1 Jul 2016 11:10:15 -0400
Message-ID: <1467385815-6357-1-git-send-email-jbaron@akamai.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm wondering if anybody else has run into this...

On Mac OSX 10.11.5 (latest version), we have found that when tcp
connections are abruptly terminated (via ^C), a FIN is sent followed
by an RST packet. The RST is sent with the same sequence number as the
FIN, and thus dropped since the stack only accepts RST packets matching
rcv_nxt (RFC 5961). This could also be resolved if Mac OSX replied with
an RST on the closed socket, but it appears that it does not.

The workaround here is then to reset the connection, if the RST is
is equal to rcv_nxt - 1, if we have already received a FIN.

The RST attack surface is limited b/c we only accept the RST after we've
accepted a FIN and have not previously sent a FIN and received back the
corresponding ACK. In other words RST is only accepted in the tcp
states: TCP_CLOSE_WAIT, TCP_LAST_ACK, and TCP_CLOSING.

I'm interested if anybody else has run into this issue. Its problematic
since it takes up server resources for sockets sitting in TCP_CLOSE_WAIT.
We are also in the process of contacting Apple to see what can be done
here...workaround patch is below.


Here is the sequence from wireshark, mac osx is client sending the
fin:

84581  14.752908 <mac ip> -> <linux server ip> TCP 66 49896 > http [FIN, ACK] Seq=673257230 Ack=924722210 Win=131072 Len=0 TSval=622455547 TSecr=346246436
84984  14.788056 <mac ip> -> <linux server ip> TCP 60 49896 > http [RST] Seq=673257230 Win=0 Len=0
84985  14.788061 <linux server ip> -> <mac ip> TCP 66 http > 49896 [ACK] 
Seq=924739994 Ack=673257231 Win=28960 Len=0 TSval=346246723 TSecr=622455547

followed by a bunch of retransmits from server:

85138  14.994217 <linux server ip> -> <mac ip> TCP 1054 [TCP segment of a reassembled PDU]
85237  15.348217 <linux server ip> -> <mac ip> TCP 1054 [TCP Retransmission] [TCP segment of a reassembled PDU]
85337  16.056224 <linux server ip> -> <mac ip> TCP 1054 [TCP Retransmission] [TCP segment of a reassembled PDU]
85436  17.472225 <linux server ip> -> <mac ip> TCP 1054 [TCP Retransmission] [TCP segment of a reassembled PDU]
85540  20.304222 <linux server ip> -> <mac ip> TCP 1054 [TCP Retransmission] [TCP segment of a reassembled PDU]
85644  25.968218 <linux server ip> -> <mac ip> TCP 1054 [TCP Retransmission] [TCP segment of a reassembled PDU]
85745  37.280230 <linux server ip> -> <mac ip> TCP 1054 [TCP Retransmission] [TCP segment of a reassembled PDU]
85845  59.904235 <linux server ip> -> <mac ip> TCP 1054 [TCP Retransmission] [TCP segment of a reassembled PDU]

Thanks,

-Jason

---
 net/ipv4/tcp_input.c | 25 +++++++++++++++++++++++--
 1 file changed, 23 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 94d4aff97523..b3c55b91140c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5155,6 +5155,25 @@ static int tcp_copy_to_iovec(struct sock *sk, struct sk_buff *skb, int hlen)
 	return err;
 }
 
+/*
+ * Mac OSX 10.11.5 can send a FIN followed by a RST where the RST
+ * has the same sequence number as the FIN. This is not compliant
+ * with RFC 5961, but ends up in a number of sockets tied up mostly
+ * in TCP_CLOSE_WAIT. The rst attack surface is limited b/c we only
+ * accept the RST after we've accepted a FIN and have not previously
+ * sent a FIN and received back the corresponding ACK.
+ */
+static bool tcp_fin_rst_check(struct sock *sk, struct sk_buff *skb)
+{
+       struct tcp_sock *tp = tcp_sk(sk);
+
+       return unlikely((TCP_SKB_CB(skb)->seq == (tp->rcv_nxt - 1)) &&
+                       (TCP_SKB_CB(skb)->end_seq == (tp->rcv_nxt - 1)) &&
+                       (sk->sk_state == TCP_CLOSE_WAIT ||
+                        sk->sk_state == TCP_LAST_ACK ||
+                        sk->sk_state == TCP_CLOSING));
+}
+
 /* Does PAWS and seqno based validation of an incoming segment, flags will
  * play significant role here.
  */
@@ -5193,7 +5212,8 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
 						  LINUX_MIB_TCPACKSKIPPEDSEQ,
 						  &tp->last_oow_ack_time))
 				tcp_send_dupack(sk, skb);
-		}
+		} else if (tcp_fin_rst_check(sk, skb))
+			tcp_reset(sk);
 		goto discard;
 	}
 
@@ -5206,7 +5226,8 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
 		 * else
 		 *     Send a challenge ACK
 		 */
-		if (TCP_SKB_CB(skb)->seq == tp->rcv_nxt) {
+		if (TCP_SKB_CB(skb)->seq == tp->rcv_nxt ||
+		    tcp_fin_rst_check(sk, skb)) {
 			rst_seq_match = true;
 		} else if (tcp_is_sack(tp) && tp->rx_opt.num_sacks > 0) {
 			struct tcp_sack_block *sp = &tp->selective_acks[0];
-- 
2.6.1
