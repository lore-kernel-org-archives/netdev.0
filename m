From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next] sctp: recvmsg should be able to run even if sock is in closing state
Date: Fri, 15 Jul 2016 16:38:19 -0300
Message-ID: <0250eb38e3e6f219ac353fa64dc8438d91740a31.1468609937.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	linux-sctp@vger.kernel.org, Xin Long <lucien.xin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53654 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751327AbcGOTij (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2016 15:38:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit d46e416c11c8 missed to update some other places which checked for
the socket being TCP-style AND Established state, as Closing state has
some overlapping with the previous understanding of Established.

Without this fix, one of the effects is that some already queued rx
messages may not be readable anymore depending on how the association
teared down, and sending may also not be possible if peer initiated the
shutdown.

Also merge two if() blocks into one condition on sctp_sendmsg().

Cc: Xin Long <lucien.xin@gmail.com>
Fixes: d46e416c11c8 ("sctp: sctp should change socket state when shutdown is received")
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/socket.c | 32 +++++++++++++++++---------------
 1 file changed, 17 insertions(+), 15 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 52fdd540a9ef153336e0c6df725ce47c9ebab11b..d2681cb1dd30044d62b443311923a94659ce9395 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -202,7 +202,7 @@ struct sctp_association *sctp_id2assoc(struct sock *sk, sctp_assoc_t id)
 		 * could be a TCP-style listening socket or a socket which
 		 * hasn't yet called connect() to establish an association.
 		 */
-		if (!sctp_sstate(sk, ESTABLISHED))
+		if (!sctp_sstate(sk, ESTABLISHED) && !sctp_sstate(sk, CLOSING))
 			return NULL;
 
 		/* Get the first and the only association from the list. */
@@ -1068,7 +1068,7 @@ static int __sctp_connect(struct sock *sk,
 	 * is already connected.
 	 * It cannot be done even on a TCP-style listening socket.
 	 */
-	if (sctp_sstate(sk, ESTABLISHED) ||
+	if (sctp_sstate(sk, ESTABLISHED) || sctp_sstate(sk, CLOSING) ||
 	    (sctp_style(sk, TCP) && sctp_sstate(sk, LISTENING))) {
 		err = -EISCONN;
 		goto out_free;
@@ -1705,18 +1705,19 @@ static int sctp_sendmsg(struct sock *sk, struct msghdr *msg, size_t msg_len)
 	if (msg_name) {
 		/* Look for a matching association on the endpoint. */
 		asoc = sctp_endpoint_lookup_assoc(ep, &to, &transport);
-		if (!asoc) {
-			/* If we could not find a matching association on the
-			 * endpoint, make sure that it is not a TCP-style
-			 * socket that already has an association or there is
-			 * no peeled-off association on another socket.
-			 */
-			if ((sctp_style(sk, TCP) &&
-			     sctp_sstate(sk, ESTABLISHED)) ||
-			    sctp_endpoint_is_peeled_off(ep, &to)) {
-				err = -EADDRNOTAVAIL;
-				goto out_unlock;
-			}
+
+		/* If we could not find a matching association on the
+		 * endpoint, make sure that it is not a TCP-style
+		 * socket that already has an association or there is
+		 * no peeled-off association on another socket.
+		 */
+		if (!asoc &&
+		    ((sctp_style(sk, TCP) &&
+		      (sctp_sstate(sk, ESTABLISHED) ||
+		       sctp_sstate(sk, CLOSING))) ||
+		     sctp_endpoint_is_peeled_off(ep, &to))) {
+			err = -EADDRNOTAVAIL;
+			goto out_unlock;
 		}
 	} else {
 		asoc = sctp_id2assoc(sk, associd);
@@ -2077,7 +2078,8 @@ static int sctp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 
 	lock_sock(sk);
 
-	if (sctp_style(sk, TCP) && !sctp_sstate(sk, ESTABLISHED)) {
+	if (sctp_style(sk, TCP) && !sctp_sstate(sk, ESTABLISHED) &&
+	    !sctp_sstate(sk, CLOSING)) {
 		err = -ENOTCONN;
 		goto out;
 	}
-- 
2.7.4
