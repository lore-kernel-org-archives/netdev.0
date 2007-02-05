From: John Heffner <jheffner@psc.edu>
Subject: [PATCH] apply cwnd rules to FIN packets with data
Date: Mon, 05 Feb 2007 16:58:18 -0500
Message-ID: <45C7A87A.5050200@psc.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080507080807020102020509"
Cc: David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:53146 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964972AbXBEWPK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 17:15:10 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080507080807020102020509
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This is especially important with TSO enabled.  Currently, it will send 
a burst of up to 64k at the end of a connection, even when cwnd is much 
smaller than 64k.  This patch still lets out empty FIN packets, but does 
not apply the special case to FINs carrying data.

   -John


--------------080507080807020102020509
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="fin_cwnd.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fin_cwnd.patch"

Apply cwnd rules to FIN packets that contain data.

---
commit af319609eee705e0791a1a58c33b216e8d0254bf
tree 5a1afcc506e09f5adfd74efb7e0cbbc82ec4d5b0
parent c0d4d573feed199b16094c072e7cb07afb01c598
author John Heffner <jheffner@psc.edu> Mon, 05 Feb 2007 16:25:46 -0500
committer John Heffner <jheffner@psc.edu> Mon, 05 Feb 2007 16:25:46 -0500

 net/ipv4/tcp_output.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 975f447..215c99d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -965,7 +965,7 @@ static inline unsigned int tcp_cwnd_test
 	u32 in_flight, cwnd;
 
 	/* Don't be strict about the congestion window for the final FIN.  */
-	if (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN)
+	if ((TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN) && skb->len == 0)
 		return 1;
 
 	in_flight = tcp_packets_in_flight(tp);
@@ -1034,7 +1034,7 @@ static inline int tcp_nagle_test(struct 
 
 	/* Don't use the nagle rule for urgent data (or for the final FIN).  */
 	if (tp->urg_mode ||
-	    (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN))
+	    ((TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN) && skb->len == 0))
 		return 1;
 
 	if (!tcp_nagle_check(tp, skb, cur_mss, nonagle))
@@ -1156,9 +1156,6 @@ static int tcp_tso_should_defer(struct s
 	const struct inet_connection_sock *icsk = inet_csk(sk);
 	u32 send_win, cong_win, limit, in_flight;
 
-	if (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN)
-		goto send_now;
-
 	if (icsk->icsk_ca_state != TCP_CA_Open)
 		goto send_now;
 

--------------080507080807020102020509--
