From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net 2/2] RDS: TCP: Avoid rds connection churn from rogue SYNs
Date: Wed, 18 May 2016 10:06:24 -0700
Message-ID: <b768a2aabf58f282e8058cf04dfed5d682cf0110.1463579486.git.sowmini.varadhan@oracle.com>
References: <cover.1463579486.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, sowmini.varadhan@oracle.com,
	santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27368 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932276AbcERRG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 13:06:56 -0400
In-Reply-To: <cover.1463579486.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1463579486.git.sowmini.varadhan@oracle.com>
References: <cover.1463579486.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a rogue SYN is received after the connection arbitration
algorithm has converged, the incoming SYN should not needlessly
quiesce the transmit path, and it should not result in needless
TCP connection resets due to re-execution of the connection
arbitration logic.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/tcp_listen.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
index e10b422..bc387c2 100644
--- a/net/rds/tcp_listen.c
+++ b/net/rds/tcp_listen.c
@@ -132,11 +132,13 @@ int rds_tcp_accept_one(struct socket *sock)
 		 * so we must quiesce any send threads before resetting
 		 * c_transport_data.
 		 */
-		wait_event(conn->c_waitq,
-			   !test_bit(RDS_IN_XMIT, &conn->c_flags));
-		if (ntohl(inet->inet_saddr) < ntohl(inet->inet_daddr)) {
+		if (ntohl(inet->inet_saddr) < ntohl(inet->inet_daddr) ||
+		    !conn->c_outgoing) {
 			goto rst_nsk;
-		} else if (rs_tcp->t_sock) {
+		} else {
+			atomic_set(&conn->c_state, RDS_CONN_CONNECTING);
+			wait_event(conn->c_waitq,
+				   !test_bit(RDS_IN_XMIT, &conn->c_flags));
 			rds_tcp_restore_callbacks(rs_tcp->t_sock, rs_tcp);
 			conn->c_outgoing = 0;
 		}
-- 
1.7.1
