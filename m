From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 3/3] rds: tcp: Set linger when rejecting an incoming conn in rds_tcp_accept_one
Date: Thu, 15 Jun 2017 11:28:55 -0700
Message-ID: <5fc58ee53a4fe55f7b484e7f75e4ab22daf45846.1497547381.git.sowmini.varadhan@oracle.com>
References: <cover.1497547381.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, sowmini.varadhan@oracle.com,
        santosh.shilimkar@oracle.com, imanti.mendez@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:45485 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751906AbdFOSbe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 14:31:34 -0400
In-Reply-To: <cover.1497547381.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1497547381.git.sowmini.varadhan@oracle.com>
References: <cover.1497547381.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each time we get an incoming SYN to the RDS_TCP_PORT, the TCP
layer accepts the connection and then the rds_tcp_accept_one()
callback is invoked to process the incoming connection.

rds_tcp_accept_one() may reject the incoming syn for a number of
reasons, e.g., commit 1a0e100fb2c9 ("RDS: TCP: Force every connection
to be initiated by numerically smaller IP address"), or because
we are getting spammed by a malicious node that is triggering
a flood of connection attempts to RDS_TCP_PORT. If the incoming
syn is rejected, no data would have been sent on the TCP socket,
and we do not need to be in TIME_WAIT state, so we set linger on
the TCP socket before closing, thereby closing the socket efficiently
with a RST.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Tested-by: Imanti Mendez <imanti.mendez@oracle.com>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/tcp_listen.c |   19 ++++++++++++++++++-
 1 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index f9c6312..df291ac 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -112,6 +112,17 @@ struct rds_tcp_connection *rds_tcp_accept_one_path(struct rds_connection *conn)
 	return NULL;
 }
 
+static void rds_tcp_set_linger(struct socket *sock)
+{
+	struct linger no_linger = {
+		.l_onoff = 1,
+		.l_linger = 0,
+	};
+
+	kernel_setsockopt(sock, SOL_SOCKET, SO_LINGER,
+			  (char *)&no_linger, sizeof(no_linger));
+}
+
 int rds_tcp_accept_one(struct socket *sock)
 {
 	struct socket *new_sock = NULL;
@@ -183,7 +194,13 @@ int rds_tcp_accept_one(struct socket *sock)
 	ret = 0;
 	goto out;
 rst_nsk:
-	/* reset the newly returned accept sock and bail */
+	/* reset the newly returned accept sock and bail.
+	 * It is safe to set linger on new_sock because the RDS connection
+	 * has not been brought up on new_sock, so no RDS-level data could
+	 * be pending on it. By setting linger, we achieve the side-effect
+	 * of avoiding TIME_WAIT state on new_sock.
+	 */
+	rds_tcp_set_linger(new_sock);
 	kernel_sock_shutdown(new_sock, SHUT_RDWR);
 	ret = 0;
 out:
-- 
1.7.1
