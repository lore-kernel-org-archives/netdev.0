From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] inet: race in wait for connect.
Date: Mon, 29 Oct 2007 13:52:22 -0700
Message-ID: <20071029135222.2ad073ff@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:37042 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752225AbXJ2UxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 16:53:22 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix possible race while waiting for connections in accept. I don't
know of a test case that could reproduce this directly.

The state of the socket should be checked before checking the queue.
If the socket has left the TCP_LISTEN state, then the accept queue
is no longer valid.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/net/ipv4/inet_connection_sock.c	2007-10-26 11:54:41.000000000 -0700
+++ b/net/ipv4/inet_connection_sock.c	2007-10-29 08:34:03.000000000 -0700
@@ -203,12 +203,12 @@ static int inet_csk_wait_for_connect(str
 		if (reqsk_queue_empty(&icsk->icsk_accept_queue))
 			timeo = schedule_timeout(timeo);
 		lock_sock(sk);
-		err = 0;
-		if (!reqsk_queue_empty(&icsk->icsk_accept_queue))
-			break;
 		err = -EINVAL;
 		if (sk->sk_state != TCP_LISTEN)
 			break;
+		err = 0;
+		if (!reqsk_queue_empty(&icsk->icsk_accept_queue))
+			break;
 		err = sock_intr_errno(timeo);
 		if (signal_pending(current))
 			break;
