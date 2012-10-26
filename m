From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH net-next 1/1] tcp: Prevent needless syn-ack rexmt during TWHS
Date: Thu, 25 Oct 2012 17:45:56 -0700
Message-ID: <1351212356-11964-1-git-send-email-subramanian.vijay@gmail.com>
Cc: davem@davemloft.net,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Elliot Hughes <enh@google.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:62775 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755375Ab2JZA21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 20:28:27 -0400
Received: by mail-pb0-f46.google.com with SMTP id rr4so2385603pbb.19
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 17:28:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If server socket is slow to accept() connections, request_socks can represent
connections for which the three-way handshake is already done.  From client's
point of view, the connection is in ESTABLISHED state but on server side, socket
is not in accept_queue or ESTABLISHED state.  When the syn-ack timer expires,
because of the order in which tests are performed, server can retransmit the
synack repeatedly. Following patch prevents the server from retransmitting the
synack needlessly (and prevents client from replying with ack).  This reduces
traffic when server is slow to accept() connections.

If the server socket has received the third ack during connection establishment,
this is remembered in inet_rsk(req)->acked.  The request_sock will expire in
around 30 seconds and will be dropped if it does not move into accept_queue.

With help from Eric Dumazet.

Reported-by: Elliot Hughes <enh@google.com>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
Ignoring "WARNING: line over 80 characters" in the interest of readability.

Eric,
What about your earlier patch that modified sk_acceptq_is_full()?

 net/ipv4/inet_connection_sock.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index d34ce29..4e8e52e 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -598,9 +598,8 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 					       &expire, &resend);
 				req->rsk_ops->syn_ack_timeout(parent, req);
 				if (!expire &&
-				    (!resend ||
-				     !req->rsk_ops->rtx_syn_ack(parent, req, NULL) ||
-				     inet_rsk(req)->acked)) {
+				    (!resend || inet_rsk(req)->acked ||
+				     !req->rsk_ops->rtx_syn_ack(parent, req, NULL))) {
 					unsigned long timeo;
 
 					if (req->retrans++ == 0)
-- 
1.7.0.4
