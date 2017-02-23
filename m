From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net] sctp: deny peeloff operation on asocs with threads sleeping on it
Date: Thu, 23 Feb 2017 09:31:18 -0300
Message-ID: <e3adb3f22270407764cfbeb1adb7e4c95cf42cbb.1487800862.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Xin Long <lucien.xin@gmail.com>,
        Alexander Popov <alex.popov@linux.com>,
        Ben Hutchings <ben@decadent.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36711 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751070AbdBWMba (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 07:31:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 2dcab5984841 ("sctp: avoid BUG_ON on sctp_wait_for_sndbuf")
attempted to avoid a BUG_ON call when the association being used for a
sendmsg() is blocked waiting for more sndbuf and another thread did a
peeloff operation on such asoc, moving it to another socket.

As Ben Hutchings noticed, then in such case it would return without
locking back the socket and would cause two unlocks in a row.

Further analysis also revealed that it could allow a double free if the
application managed to peeloff the asoc that is created during the
sendmsg call, because then sctp_sendmsg() would try to free the asoc
that was created only for that call.

This patch takes another approach. It will deny the peeloff operation
if there is a thread sleeping on the asoc, so this situation doesn't
exist anymore. This avoids the issues described above and also honors
the syscalls that are already being handled (it can be multiple sendmsg
calls).

Joint work with Xin Long.

Fixes: 2dcab5984841 ("sctp: avoid BUG_ON on sctp_wait_for_sndbuf")
Cc: Alexander Popov <alex.popov@linux.com>
Cc: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
Hi, please consider this one for -stable too. Thanks

 net/sctp/socket.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 1b5d669e30292a57ed57dd920d81be2a57f97b22..d04a8b66098c8a574642b026bff990ac64c21468 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4734,6 +4734,12 @@ int sctp_do_peeloff(struct sock *sk, sctp_assoc_t id, struct socket **sockp)
 	if (!asoc)
 		return -EINVAL;
 
+	/* If there is a thread waiting on more sndbuf space for
+	 * sending on this asoc, it cannot be peeled.
+	 */
+	if (waitqueue_active(&asoc->wait))
+		return -EBUSY;
+
 	/* An association cannot be branched off from an already peeled-off
 	 * socket, nor is this supported for tcp style sockets.
 	 */
@@ -7426,8 +7432,6 @@ static int sctp_wait_for_sndbuf(struct sctp_association *asoc, long *timeo_p,
 		 */
 		release_sock(sk);
 		current_timeo = schedule_timeout(current_timeo);
-		if (sk != asoc->base.sk)
-			goto do_error;
 		lock_sock(sk);
 
 		*timeo_p = current_timeo;
-- 
2.9.3
