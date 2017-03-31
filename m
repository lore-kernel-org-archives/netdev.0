From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 1/2] rds: tcp: allow progress of rds_conn_shutdown if the rds_connection is marked ERROR by an intervening FIN
Date: Fri, 31 Mar 2017 15:56:30 -0700
Message-ID: <4b20bf8cbe541a263b12eb54b2e504e33b8a6a52.1490814967.git.sowmini.varadhan@oracle.com>
References: <cover.1490814967.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, santosh.shilimkar@oracle.com,
        sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23996 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751957AbdDASSn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 14:18:43 -0400
In-Reply-To: <cover.1490814967.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1490814967.git.sowmini.varadhan@oracle.com>
References: <cover.1490814967.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rds_conn_shutdown() runs in workq context, and marks the rds_connection
as DISCONNECTING before quiescing Tx/Rx paths. However, after all I/O
has quiesced, we may still find the rds_connection state to be
RDS_CONN_ERROR if an intervening FIN was processed in softirq context.

This is not a fatal error: rds_conn_shutdown() should continue the
shutdown, and there is no need to log noisy messages about this event.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/connection.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index 1fa75ab..6a5ebde 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -333,11 +333,19 @@ void rds_conn_shutdown(struct rds_conn_path *cp)
 		rds_conn_path_reset(cp);
 
 		if (!rds_conn_path_transition(cp, RDS_CONN_DISCONNECTING,
+					      RDS_CONN_DOWN) &&
+		    !rds_conn_path_transition(cp, RDS_CONN_ERROR,
 					      RDS_CONN_DOWN)) {
 			/* This can happen - eg when we're in the middle of tearing
 			 * down the connection, and someone unloads the rds module.
-			 * Quite reproduceable with loopback connections.
+			 * Quite reproducible with loopback connections.
 			 * Mostly harmless.
+			 *
+			 * Note that this also happens with rds-tcp because
+			 * we could have triggered rds_conn_path_drop in irq
+			 * mode from rds_tcp_state change on the receipt of
+			 * a FIN, thus we need to recheck for RDS_CONN_ERROR
+			 * here.
 			 */
 			rds_conn_path_error(cp, "%s: failed to transition "
 					    "to state DOWN, current state "
-- 
1.7.1
