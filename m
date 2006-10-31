From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 1/2] [SCTP]: Correctly set IP id for SCTP traffic
Date: Mon, 30 Oct 2006 17:38:37 -0800
Message-ID: <1162258717.22597.39.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:6600 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1161520AbWJaBim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2006 20:38:42 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9V1cfw0016266
	for <netdev@vger.kernel.org>; Mon, 30 Oct 2006 20:38:41 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9V1cdS0063314
	for <netdev@vger.kernel.org>; Mon, 30 Oct 2006 20:38:39 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9V1cchR005936
	for <netdev@vger.kernel.org>; Mon, 30 Oct 2006 20:38:38 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Correctly set IP id for SCTP traffic

Make SCTP 1-1 style and peeled-off associations behave like TCP when
setting IP id. In both cases, we set the inet_sk(sk)->daddr and initialize
inet_sk(sk)->id to a random value.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 net/sctp/protocol.c |    2 +-
 net/sctp/socket.c   |    9 +++++++++
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index fac7674..5b4f82f 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -591,7 +591,7 @@ static struct sock *sctp_v4_create_accep
 	newinet->dport = htons(asoc->peer.port);
 	newinet->daddr = asoc->peer.primary_addr.v4.sin_addr.s_addr;
 	newinet->pmtudisc = inet->pmtudisc;
-      	newinet->id = 0;
+      	newinet->id = asoc->next_tsn ^ jiffies;
 
 	newinet->uc_ttl = -1;
 	newinet->mc_loop = 1;
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 9f34dec..c58fa6d 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3372,6 +3372,7 @@ SCTP_STATIC int sctp_do_peeloff(struct s
 {
 	struct sock *sk = asoc->base.sk;
 	struct socket *sock;
+	struct inet_sock *inetsk;
 	int err = 0;
 
 	/* An association cannot be branched off from an already peeled-off
@@ -3389,6 +3390,14 @@ SCTP_STATIC int sctp_do_peeloff(struct s
 	 * asoc to the newsk.
 	 */
 	sctp_sock_migrate(sk, sock->sk, asoc, SCTP_SOCKET_UDP_HIGH_BANDWIDTH);
+
+	/* Make peeled-off sockets more like 1-1 accepted sockets.
+	 * Set the daddr and initialize id to something more random
+	 */
+	inetsk = inet_sk(sock->sk);
+	inetsk->daddr = asoc->peer.primary_addr.v4.sin_addr.s_addr;
+	inetsk->id = asoc->next_tsn ^ jiffies;
+
 	*sockp = sock;
 
 	return err;


