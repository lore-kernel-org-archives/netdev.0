From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 5/7] sctp: Allow only 1 listening socket with SO_REUSEADDR
Date: Sat, 19 Jul 2008 00:26:50 -0400
Message-ID: <12164416183890-git-send-email-vladislav.yasevich@hp.com>
References: <12164416121552-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:34563 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752618AbYGSE20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 00:28:26 -0400
In-Reply-To: <12164416121552-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When multiple socket bind to the same port with SO_REUSEADDR,
only 1 can be listining.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/socket.c |   25 ++++++++++++++++---------
 1 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index fd7ed9d..79bece1 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -377,18 +377,19 @@ SCTP_STATIC int sctp_do_bind(struct sock *sk, union sctp_addr *addr, int len)
 	if (snum && snum < PROT_SOCK && !capable(CAP_NET_BIND_SERVICE))
 		return -EACCES;
 
+	/* See if the address matches any of the addresses we may have
+	 * already bound before checking against other endpoints.
+	 */
+	if (sctp_bind_addr_match(bp, addr, sp))
+		return -EINVAL;
+
 	/* Make sure we are allowed to bind here.
 	 * The function sctp_get_port_local() does duplicate address
 	 * detection.
 	 */
 	addr->v4.sin_port = htons(snum);
 	if ((ret = sctp_get_port_local(sk, addr))) {
-		if (ret == (long) sk) {
-			/* This endpoint has a conflicting address. */
-			return -EINVAL;
-		} else {
-			return -EADDRINUSE;
-		}
+		return -EADDRINUSE;
 	}
 
 	/* Refresh ephemeral port.  */
@@ -5584,8 +5585,9 @@ pp_found:
 			struct sctp_endpoint *ep2;
 			ep2 = sctp_sk(sk2)->ep;
 
-			if (reuse && sk2->sk_reuse &&
-			    sk2->sk_state != SCTP_SS_LISTENING)
+			if (sk == sk2 ||
+			    (reuse && sk2->sk_reuse &&
+			     sk2->sk_state != SCTP_SS_LISTENING))
 				continue;
 
 			if (sctp_bind_addr_conflict(&ep2->base.bind_addr, addr,
@@ -5702,8 +5704,13 @@ SCTP_STATIC int sctp_seqpacket_listen(struct sock *sk, int backlog)
 	if (!ep->base.bind_addr.port) {
 		if (sctp_autobind(sk))
 			return -EAGAIN;
-	} else
+	} else {
+		if (sctp_get_port(sk, inet_sk(sk)->num)) {
+			sk->sk_state = SCTP_SS_CLOSED;
+			return -EADDRINUSE;
+		}
 		sctp_sk(sk)->bind_hash->fastreuse = 0;
+	}
 
 	sctp_hash_endpoint(ep);
 	return 0;
-- 
1.5.2.5

