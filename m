From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2/2] tcp: Remove 2 indentation levels in
 tcp_rcv_state_process
Date: Fri, 24 May 2013 21:06:58 -0700
Message-ID: <1369454818.2080.6.camel@joe-AO722>
References: <1366341367.3205.85.camel@edumazet-glaptop>
	 <1369324525.3301.384.camel@edumazet-glaptop>
	 <1369443834.3301.464.camel@edumazet-glaptop>
	 <1369454556.2080.4.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:57771 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750747Ab3EYEG7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 May 2013 00:06:59 -0400
In-Reply-To: <1369454556.2080.4.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

case TCP_FIN_WAIT1 can also be simplified by reversing tests
and adding breaks;

Add braces after case and move automatic definitions.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv4/tcp_input.c | 76 +++++++++++++++++++++++++++-------------------------
 1 file changed, 39 insertions(+), 37 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 71bd87d..34da5a5 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5671,7 +5671,10 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 		tcp_fast_path_on(tp);
 		break;
 
-	case TCP_FIN_WAIT1:
+	case TCP_FIN_WAIT1: {
+		struct dst_entry *dst;
+		int tmo;
+
 		/* If we enter the TCP_FIN_WAIT1 state and we are a
 		 * Fast Open socket and this is the first acceptable
 		 * ACK we have received, this would have acknowledged
@@ -5690,48 +5693,47 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 			reqsk_fastopen_remove(sk, req, false);
 			tcp_rearm_rto(sk);
 		}
-		if (tp->snd_una == tp->write_seq) {
-			struct dst_entry *dst;
+		if (tp->snd_una != tp->write_seq)
+			break;
 
-			tcp_set_state(sk, TCP_FIN_WAIT2);
-			sk->sk_shutdown |= SEND_SHUTDOWN;
+		tcp_set_state(sk, TCP_FIN_WAIT2);
+		sk->sk_shutdown |= SEND_SHUTDOWN;
 
-			dst = __sk_dst_get(sk);
-			if (dst)
-				dst_confirm(dst);
+		dst = __sk_dst_get(sk);
+		if (dst)
+			dst_confirm(dst);
 
-			if (!sock_flag(sk, SOCK_DEAD)) {
-				/* Wake up lingering close() */
-				sk->sk_state_change(sk);
-			} else {
-				int tmo;
-
-				if (tp->linger2 < 0 ||
-				    (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq &&
-				     after(TCP_SKB_CB(skb)->end_seq - th->fin, tp->rcv_nxt))) {
-					tcp_done(sk);
-					NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPABORTONDATA);
-					return 1;
-				}
+		if (!sock_flag(sk, SOCK_DEAD)) {
+			/* Wake up lingering close() */
+			sk->sk_state_change(sk);
+			break;
+		}
 
-				tmo = tcp_fin_time(sk);
-				if (tmo > TCP_TIMEWAIT_LEN) {
-					inet_csk_reset_keepalive_timer(sk, tmo - TCP_TIMEWAIT_LEN);
-				} else if (th->fin || sock_owned_by_user(sk)) {
-					/* Bad case. We could lose such FIN otherwise.
-					 * It is not a big problem, but it looks confusing
-					 * and not so rare event. We still can lose it now,
-					 * if it spins in bh_lock_sock(), but it is really
-					 * marginal case.
-					 */
-					inet_csk_reset_keepalive_timer(sk, tmo);
-				} else {
-					tcp_time_wait(sk, TCP_FIN_WAIT2, tmo);
-					goto discard;
-				}
-			}
+		if (tp->linger2 < 0 ||
+		    (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq &&
+		     after(TCP_SKB_CB(skb)->end_seq - th->fin, tp->rcv_nxt))) {
+			tcp_done(sk);
+			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPABORTONDATA);
+			return 1;
+		}
+
+		tmo = tcp_fin_time(sk);
+		if (tmo > TCP_TIMEWAIT_LEN) {
+			inet_csk_reset_keepalive_timer(sk, tmo - TCP_TIMEWAIT_LEN);
+		} else if (th->fin || sock_owned_by_user(sk)) {
+			/* Bad case. We could lose such FIN otherwise.
+			 * It is not a big problem, but it looks confusing
+			 * and not so rare event. We still can lose it now,
+			 * if it spins in bh_lock_sock(), but it is really
+			 * marginal case.
+			 */
+			inet_csk_reset_keepalive_timer(sk, tmo);
+		} else {
+			tcp_time_wait(sk, TCP_FIN_WAIT2, tmo);
+			goto discard;
 		}
 		break;
+	}
 
 	case TCP_CLOSING:
 		if (tp->snd_una == tp->write_seq) {
-- 
1.8.1.2.459.gbcd45b4.dirty
