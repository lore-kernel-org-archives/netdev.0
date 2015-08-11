From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH 1/6] dlm: fix connection stealing if using SCTP
Date: Tue, 11 Aug 2015 19:22:20 -0300
Message-ID: <593a77d6d0f48930916231e552b037160c4ced5b.1439330654.git.marcelo.leitner@gmail.com>
References: <cover.1439330654.git.marcelo.leitner@gmail.com>
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Teigland <teigland@redhat.com>, tan.hu@zte.com.cn
To: cluster-devel@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46671 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932675AbbHKWWl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Aug 2015 18:22:41 -0400
In-Reply-To: <cover.1439330654.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using SCTP and accepting a new connection, DLM currently validates
if the peer trying to connect to it is one of the cluster nodes, but it
doesn't check if it already has a connection to it or not.

If it already had a connection, it will be overwritten, and the new one
will be used for writes, possibly causing the node to leave the cluster
due to communication breakage.

Still, one could DoS the node by attempting N connections and keeping
them open.

As said, but being explicit, both situations are only triggerable from
other cluster nodes, but are doable with only user-level perms.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 fs/dlm/lowcomms.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index 754fd6c0b7470bab272b071e6ca6e4969e4e4209..bc04f5e3af7ac5fe107a7a26555777364de8bc15 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -535,7 +535,9 @@ static void close_connection(struct connection *con, bool and_other)
 	mutex_unlock(&con->sock_mutex);
 }
 
-/* We only send shutdown messages to nodes that are not part of the cluster */
+/* We only send shutdown messages to nodes that are not part of the cluster
+ * or if we get multiple connections from a node.
+ */
 static void sctp_send_shutdown(sctp_assoc_t associd)
 {
 	static char outcmsg[CMSG_SPACE(sizeof(struct sctp_sndrcvinfo))];
@@ -718,6 +720,14 @@ static void process_sctp_notification(struct connection *con,
 			if (!new_con)
 				return;
 
+			if (new_con->sock) {
+				log_print("reject connect from node %d: "
+					  "already has a connection.",
+					  nodeid);
+				sctp_send_shutdown(prim.ssp_assoc_id);
+				return;
+			}
+
 			/* Peel off a new sock */
 			lock_sock(con->sock->sk);
 			ret = sctp_do_peeloff(con->sock->sk,
-- 
2.4.3
