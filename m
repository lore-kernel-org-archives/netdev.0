From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 4/4] sctp: Fix another socket race during accept/peeloff
Date: Thu, 22 Jan 2009 17:36:08 -0500
Message-ID: <1232663768-4028-5-git-send-email-vladislav.yasevich@hp.com>
References: <1232663768-4028-1-git-send-email-vladislav.yasevich@hp.com>
Cc: linux-sctp@vger.kernel.org, davem@davemloft.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:2112 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759161AbZAVWgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 17:36:13 -0500
In-Reply-To: <1232663768-4028-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a race between sctp_rcv() and sctp_accept() where we
have moved the association from the listening socket to the
accepted socket, but sctp_rcv() processing cached the old
socket and continues to use it.

The easy solution is to check for the socket mismatch once we've
grabed the socket lock.  If we hit a mis-match, that means
that were are currently holding the lock on the listening socket,
but the association is refrencing a newly accepted socket.  We need
to drop the lock on the old socket and grab the lock on the new one.

A more proper solution might be to create accepted sockets when
the new association is established, similar to TCP.  That would
eliminate the race for 1-to-1 style sockets, but it would still
existing for 1-to-many sockets where a user wished to peeloff an
association.  For now, we'll live with this easy solution as
it addresses the problem.

Reported-by: Michal Hocko <mhocko@suse.cz>
Reported-by: Karsten Keil <kkeil@suse.de>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/input.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index bf612d9..2e4a864 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -249,6 +249,19 @@ int sctp_rcv(struct sk_buff *skb)
 	 */
 	sctp_bh_lock_sock(sk);
 
+	if (sk != rcvr->sk) {
+		/* Our cached sk is different from the rcvr->sk.  This is
+		 * because migrate()/accept() may have moved the association
+		 * to a new socket and released all the sockets.  So now we
+		 * are holding a lock on the old socket while the user may
+		 * be doing something with the new socket.  Switch our veiw
+		 * of the current sk.
+		 */
+		sctp_bh_unlock_sock(sk);
+		sk = rcvr->sk;
+		sctp_bh_lock_sock(sk);
+	}
+
 	if (sock_owned_by_user(sk)) {
 		SCTP_INC_STATS_BH(SCTP_MIB_IN_PKT_BACKLOG);
 		sctp_add_backlog(sk, skb);
-- 
1.5.3.5

