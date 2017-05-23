From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: better validation of received ack sequences
Date: Tue, 23 May 2017 15:24:46 -0700
Message-ID: <1495578286.6465.90.camel@edumazet-glaptop3.roam.corp.google.com>
References: <fbb92f49-5eca-f411-dcab-253d2a222623@science.ru.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Frits Vaandrager <F.Vaandrager@cs.ru.nl>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Paul Fiterau Brostean <p.fiterau-brostean@science.ru.nl>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36054 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034912AbdEWWYs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 18:24:48 -0400
Received: by mail-pf0-f194.google.com with SMTP id n23so30243650pfb.3
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 15:24:48 -0700 (PDT)
In-Reply-To: <fbb92f49-5eca-f411-dcab-253d2a222623@science.ru.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Paul Fiterau Brostean reported :

<quote>
Linux TCP stack we analyze exhibits behavior that seems odd to me.
The scenario is as follows (all packets have empty payloads, no window
scaling, rcv/snd window size should not be a factor):

       TEST HARNESS (CLIENT)                        LINUX SERVER

   1.  -                                          LISTEN (server listen,
then accepts)

   2.  - --> <SEQ=100><CTL=SYN>               --> SYN-RECEIVED

   3.  - <-- <SEQ=300><ACK=101><CTL=SYN,ACK>  <-- SYN-RECEIVED

   4.  - --> <SEQ=101><ACK=301><CTL=ACK>      --> ESTABLISHED
  
   5.  - <-- <SEQ=301><ACK=101><CTL=FIN,ACK>  <-- FIN WAIT-1 (server
opts to close the data connection calling "close" on the connection
socket)

   6.  - --> <SEQ=101><ACK=99999><CTL=FIN,ACK> --> CLOSING (client sends
FIN,ACK with not yet sent acknowledgement number)

   7.  - <-- <SEQ=302><ACK=102><CTL=ACK>      <-- CLOSING (ACK is 102
instead of 101, why?)
  
... (silence from CLIENT)

   8.  - <-- <SEQ=301><ACK=102><CTL=FIN,ACK>  <-- CLOSING
(retransmission, again ACK is 102)


Now, note that packet 6 while having the expected sequence number, 
acknowledges something that wasn't sent by the server. So I would
expect 
the packet to maybe prompt an ACK response from the server, and then be 
ignored. Yet it is not ignored and actually leads to an increase of the 
acknowledgement number in the server's retransmission of the FIN,ACK 
packet. The explanation I found is that the FIN  in packet 6 was 
processed, despite the acknowledgement number being unacceptable. 
Further experiments indeed show that the server processes this FIN, 
transitioning to CLOSING, then on receiving an ACK for the FIN it had 
send in packet 5, the server (or better said connection) transitions 
from CLOSING to TIME_WAIT (as signaled by netstat).

</quote>

Indeed, tcp_rcv_state_process() calls tcp_ack() but
does not exploit the @acceptable status but for TCP_SYN_RECV
state.

What we want here is to send a challenge ACK, if not in TCP_SYN_RECV
state. TCP_FIN_WAIT1 state is not the only state we should fix.

Add a FLAG_NO_CHALLENGE_ACK so that tcp_rcv_state_process()
can choose to send a challenge ACK and discard the packet instead
of wrongly change socket state.

With help from Neal Cardwell.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Paul Fiterau Brostean <p.fiterau-brostean@science.ru.nl>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Soheil Hassas Yeganeh <soheil@google.com>
---
Note for Googlers : Google-Bug-Id: 37204158

 net/ipv4/tcp_input.c |   24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2fa55f57ac06584bfd9b555799ceb3bbfb7e1b4e..c3bdcbcf544793ba410c618130586bf7d3963da6 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -112,6 +112,7 @@ int sysctl_tcp_invalid_ratelimit __read_mostly = HZ/2;
 #define FLAG_DSACKING_ACK	0x800 /* SACK blocks contained D-SACK info */
 #define FLAG_SACK_RENEGING	0x2000 /* snd_una advanced to a sacked seq */
 #define FLAG_UPDATE_TS_RECENT	0x4000 /* tcp_replace_ts_recent() */
+#define FLAG_NO_CHALLENGE_ACK	0x8000 /* do not call tcp_send_challenge_ack()	*/
 
 #define FLAG_ACKED		(FLAG_DATA_ACKED|FLAG_SYN_ACKED)
 #define FLAG_NOT_DUP		(FLAG_DATA|FLAG_WIN_UPDATE|FLAG_ACKED)
@@ -3568,7 +3569,8 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 	if (before(ack, prior_snd_una)) {
 		/* RFC 5961 5.2 [Blind Data Injection Attack].[Mitigation] */
 		if (before(ack, prior_snd_una - tp->max_window)) {
-			tcp_send_challenge_ack(sk, skb);
+			if (!(flag & FLAG_NO_CHALLENGE_ACK))
+				tcp_send_challenge_ack(sk, skb);
 			return -1;
 		}
 		goto old_ack;
@@ -5951,13 +5953,17 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 
 	/* step 5: check the ACK field */
 	acceptable = tcp_ack(sk, skb, FLAG_SLOWPATH |
-				      FLAG_UPDATE_TS_RECENT) > 0;
+				      FLAG_UPDATE_TS_RECENT |
+				      FLAG_NO_CHALLENGE_ACK) > 0;
 
+	if (!acceptable) {
+		if (sk->sk_state == TCP_SYN_RECV)
+			return 1;	/* send one RST */
+		tcp_send_challenge_ack(sk, skb);
+		goto discard;
+	}
 	switch (sk->sk_state) {
 	case TCP_SYN_RECV:
-		if (!acceptable)
-			return 1;
-
 		if (!tp->srtt_us)
 			tcp_synack_rtt_meas(sk, req);
 
@@ -6026,14 +6032,6 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb)
 		 * our SYNACK so stop the SYNACK timer.
 		 */
 		if (req) {
-			/* Return RST if ack_seq is invalid.
-			 * Note that RFC793 only says to generate a
-			 * DUPACK for it but for TCP Fast Open it seems
-			 * better to treat this case like TCP_SYN_RECV
-			 * above.
-			 */
-			if (!acceptable)
-				return 1;
 			/* We no longer need the request sock. */
 			reqsk_fastopen_remove(sk, req, false);
 			tcp_rearm_rto(sk);
