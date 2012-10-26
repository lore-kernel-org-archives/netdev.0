From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH net-next V2 1/1] tcp: Prevent needless syn-ack rexmt during TWHS
Date: Fri, 26 Oct 2012 01:05:50 -0700
Message-ID: <1351238750-13611-1-git-send-email-subramanian.vijay@gmail.com>
Cc: davem@davemloft.net, edumazet@google.com, ncardwell@google.com,
	Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	Elliott Hughes <enh@google.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:47227 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756912Ab2JZHr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 03:47:57 -0400
Received: by mail-pa0-f46.google.com with SMTP id hz1so1756776pad.19
        for <netdev@vger.kernel.org>; Fri, 26 Oct 2012 00:47:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Elliott Hughes <enh@google.com> saw strange behavior when server socket was not
calling accept(). Client was receiving SYN-ACK back even when socket on server
side was not yet available. Eric noted server sockets kept resending SYN_ACKS
and further investigation revealed the following problem.

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

Reported-by: Eric Dumazet <edumazet@google.com>
Acked-by: Neal Cardwell <ncardwell@google.com>
Tested-by: Neal Cardwell <ncardwell@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
Changes from V1: Changed Reported-by tag and commit message. Added Acked-by and
Tested-by tags.

Ignoring "WARNING: line over 80 characters" in the interest of readability.

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
