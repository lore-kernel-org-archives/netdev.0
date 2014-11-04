From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: [PATCH v2 net] tcp: zero retrans_stamp if all retrans were acked
Date: Tue,  4 Nov 2014 17:15:08 -0200
Message-ID: <f58c4b02028e0750e583518608891d20742c0f38.1415128437.git.mleitner@redhat.com>
References: <CADVnQykbFjodAyJomX8E5HZhOrP7kDxDS7vPNiam858B84vqCQ@mail.gmail.com>
Cc: ncardwell@google.com, ycheng@google.com, edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37405 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751197AbaKDTQF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 14:16:05 -0500
In-Reply-To: <CADVnQykbFjodAyJomX8E5HZhOrP7kDxDS7vPNiam858B84vqCQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ueki Kohei reported that when we are using NewReno with connections that
have a very low traffic, we may timeout the connection too early if a
second loss occurs after the first one was successfully acked but no
data was transfered later. Below is his description of it:

When SACK is disabled, and a socket suffers multiple separate TCP
retransmissions, that socket's ETIMEDOUT value is calculated from the
time of the *first* retransmission instead of the *latest*
retransmission.

This happens because the tcp_sock's retrans_stamp is set once then never
cleared.

Take the following connection:

                      Linux                    remote-machine
                        |                           |
         send#1---->(*1)|--------> data#1 --------->|
                  |     |                           |
                 RTO    :                           :
                  |     |                           |
                 ---(*2)|----> data#1(retrans) ---->|
                  | (*3)|<---------- ACK <----------|
                  |     |                           |
                  |     :                           :
                  |     :                           :
                  |     :                           :
                16 minutes (or more)                :
                  |     :                           :
                  |     :                           :
                  |     :                           :
                  |     |                           |
         send#2---->(*4)|--------> data#2 --------->|
                  |     |                           |
                 RTO    :                           :
                  |     |                           |
                 ---(*5)|----> data#2(retrans) ---->|
                  |     |                           |
                  |     |                           |
                RTO*2   :                           :
                  |     |                           |
                  |     |                           |
      ETIMEDOUT<----(*6)|                           |

(*1) One data packet sent.
(*2) Because no ACK packet is received, the packet is retransmitted.
(*3) The ACK packet is received. The transmitted packet is acknowledged.

At this point the first "retransmission event" has passed and been
recovered from. Any future retransmission is a completely new "event".

(*4) After 16 minutes (to correspond with retries2=15), a new data
packet is sent. Note: No data is transmitted between (*3) and (*4).

The socket's timeout SHOULD be calculated from this point in time, but
instead it's calculated from the prior "event" 16 minutes ago.

(*5) Because no ACK packet is received, the packet is retransmitted.
(*6) At the time of the 2nd retransmission, the socket returns
ETIMEDOUT.


Therefore, now we clear retrans_stamp as soon as all data during the
loss window is fully acked.

Reported-by: Ueki Kohei
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
---

Notes:
    v1->v2: fixed compilation issue noticed by Neal

 net/ipv4/tcp_input.c | 60 +++++++++++++++++++++++++++-------------------------
 1 file changed, 31 insertions(+), 29 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a12b455928e52211efdc6b471ef54de6218f5df0..88fa2d1606859de25419d0d45c3095f6d410d42b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2315,6 +2315,35 @@ static inline bool tcp_packet_delayed(const struct tcp_sock *tp)
 
 /* Undo procedures. */
 
+/* We can clear retrans_stamp when there are no retransmissions in the
+ * window. It would seem that it is trivially available for us in
+ * tp->retrans_out, however, that kind of assumptions doesn't consider
+ * what will happen if errors occur when sending retransmission for the
+ * second time. ...It could the that such segment has only
+ * TCPCB_EVER_RETRANS set at the present time. It seems that checking
+ * the head skb is enough except for some reneging corner cases that
+ * are not worth the effort.
+ *
+ * Main reason for all this complexity is the fact that connection dying
+ * time now depends on the validity of the retrans_stamp, in particular,
+ * that successive retransmissions of a segment must not advance
+ * retrans_stamp under any conditions.
+ */
+static bool tcp_any_retrans_done(const struct sock *sk)
+{
+	const struct tcp_sock *tp = tcp_sk(sk);
+	struct sk_buff *skb;
+
+	if (tp->retrans_out)
+		return true;
+
+	skb = tcp_write_queue_head(sk);
+	if (unlikely(skb && TCP_SKB_CB(skb)->sacked & TCPCB_EVER_RETRANS))
+		return true;
+
+	return false;
+}
+
 #if FASTRETRANS_DEBUG > 1
 static void DBGUNDO(struct sock *sk, const char *msg)
 {
@@ -2410,6 +2439,8 @@ static bool tcp_try_undo_recovery(struct sock *sk)
 		 * is ACKed. For Reno it is MUST to prevent false
 		 * fast retransmits (RFC2582). SACK TCP is safe. */
 		tcp_moderate_cwnd(tp);
+		if (!tcp_any_retrans_done(sk))
+			tp->retrans_stamp = 0;
 		return true;
 	}
 	tcp_set_ca_state(sk, TCP_CA_Open);
@@ -2430,35 +2461,6 @@ static bool tcp_try_undo_dsack(struct sock *sk)
 	return false;
 }
 
-/* We can clear retrans_stamp when there are no retransmissions in the
- * window. It would seem that it is trivially available for us in
- * tp->retrans_out, however, that kind of assumptions doesn't consider
- * what will happen if errors occur when sending retransmission for the
- * second time. ...It could the that such segment has only
- * TCPCB_EVER_RETRANS set at the present time. It seems that checking
- * the head skb is enough except for some reneging corner cases that
- * are not worth the effort.
- *
- * Main reason for all this complexity is the fact that connection dying
- * time now depends on the validity of the retrans_stamp, in particular,
- * that successive retransmissions of a segment must not advance
- * retrans_stamp under any conditions.
- */
-static bool tcp_any_retrans_done(const struct sock *sk)
-{
-	const struct tcp_sock *tp = tcp_sk(sk);
-	struct sk_buff *skb;
-
-	if (tp->retrans_out)
-		return true;
-
-	skb = tcp_write_queue_head(sk);
-	if (unlikely(skb && TCP_SKB_CB(skb)->sacked & TCPCB_EVER_RETRANS))
-		return true;
-
-	return false;
-}
-
 /* Undo during loss recovery after partial ACK or using F-RTO. */
 static bool tcp_try_undo_loss(struct sock *sk, bool frto_undo)
 {
-- 
1.9.3
