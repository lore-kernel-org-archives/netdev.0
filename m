From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] tcp: accept socket after TCP_DEFER_ACCEPT period
Date: Mon, 19 Oct 2009 23:01:56 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0910192259280.2971@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:59732 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751103AbZJSUAY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2009 16:00:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Willy Tarreau and many other folks in recent years
were concerned what happens when the TCP_DEFER_ACCEPT period
expires for clients which sent ACK packet. They prefer clients
that actively resend ACK on our SYN-ACK retransmissions to be
converted from open requests to sockets and queued to the
listener for accepting after the deferring period is finished.
Then application server can decide to wait longer for data
or to properly terminate the connection with FIN if read()
returns EAGAIN which is an indication for accepting after
the deferring period. This change still can have side effects
for applications that expect always to see data on the accepted
socket. Others can be prepared to work in both modes (with or
without TCP_DEFER_ACCEPT period) and their data processing can
ignore the read=EAGAIN notification and to allocate resources for
clients which proved to have no data to send during the deferring
period. OTOH, servers that use TCP_DEFER_ACCEPT=1 as flag (not
as a timeout) to wait for data will notice clients that didn't
send data for 3 seconds but that still resend ACKs.
Thanks to Willy Tarreau for the initial idea and to
Eric Dumazet for the review and testing the change.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp v2.6.31/linux/net/ipv4/tcp_minisocks.c linux/net/ipv4/tcp_minisocks.c
--- v2.6.31/linux/net/ipv4/tcp_minisocks.c	2009-09-11 10:27:17.000000000 +0300
+++ linux/net/ipv4/tcp_minisocks.c	2009-10-16 10:29:19.000000000 +0300
@@ -641,8 +641,8 @@ struct sock *tcp_check_req(struct sock *
 	if (!(flg & TCP_FLAG_ACK))
 		return NULL;
 
-	/* If TCP_DEFER_ACCEPT is set, drop bare ACK. */
-	if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
+	/* While TCP_DEFER_ACCEPT is active, drop bare ACK. */
+	if (req->retrans < inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
 	    TCP_SKB_CB(skb)->end_seq == tcp_rsk(req)->rcv_isn + 1) {
 		inet_rsk(req)->acked = 1;
 		return NULL;
