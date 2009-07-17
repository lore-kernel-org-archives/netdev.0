From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 08/15] RDS/IB: Move tx/rx ring init and refill to later
Date: Fri, 17 Jul 2009 16:13:29 -0700
Message-ID: <1247872416-17834-9-git-send-email-andy.grover@oracle.com>
References: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:21934 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758022AbZGQXOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 19:14:04 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by acsinet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n6HNEAIr023013
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 23:14:11 GMT
In-Reply-To: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since RDS 3.0 and 3.1 have different packet formats,
we need to wait until after protocol negotiation
is complete to layout the rx buffers.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib_cm.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index f621086..0ad749c 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -116,6 +116,16 @@ void rds_ib_cm_connect_complete(struct rds_connection *conn, struct rdma_cm_even
 			RDS_PROTOCOL_MINOR(conn->c_version),
 			ic->i_flowctl ? ", flow control" : "");
 
+	/*
+	 * Init rings and fill recv. this needs to wait until protocol negotiation
+	 * is complete, since ring layout is different from 3.0 to 3.1.
+	 */
+	rds_ib_send_init_ring(ic);
+	rds_ib_recv_init_ring(ic);
+	/* Post receive buffers - as a side effect, this will update
+	 * the posted credit count. */
+	rds_ib_recv_refill(conn, GFP_KERNEL, GFP_HIGHUSER, 1);
+
 	/* Tune RNR behavior */
 	rds_ib_tune_rnr(ic, &qp_attr);
 
@@ -324,7 +334,7 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 		rdsdebug("send allocation failed\n");
 		goto out;
 	}
-	rds_ib_send_init_ring(ic);
+	memset(ic->i_sends, 0, ic->i_send_ring.w_nr * sizeof(struct rds_ib_send_work));
 
 	ic->i_recvs = vmalloc(ic->i_recv_ring.w_nr * sizeof(struct rds_ib_recv_work));
 	if (ic->i_recvs == NULL) {
@@ -332,14 +342,10 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 		rdsdebug("recv allocation failed\n");
 		goto out;
 	}
+	memset(ic->i_recvs, 0, ic->i_recv_ring.w_nr * sizeof(struct rds_ib_recv_work));
 
-	rds_ib_recv_init_ring(ic);
 	rds_ib_recv_init_ack(ic);
 
-	/* Post receive buffers - as a side effect, this will update
-	 * the posted credit count. */
-	rds_ib_recv_refill(conn, GFP_KERNEL, GFP_HIGHUSER, 1);
-
 	rdsdebug("conn %p pd %p mr %p cq %p %p\n", conn, ic->i_pd, ic->i_mr,
 		 ic->i_send_cq, ic->i_recv_cq);
 
-- 
1.6.0.4

