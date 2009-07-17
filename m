From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 02/15] RDS/IB: Improve RDS protocol version checking
Date: Fri, 17 Jul 2009 16:13:23 -0700
Message-ID: <1247872416-17834-3-git-send-email-andy.grover@oracle.com>
References: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:25904 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758098AbZGRAO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 20:14:56 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by rgminet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n6I0GVfR024970
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Sat, 18 Jul 2009 00:16:32 GMT
In-Reply-To: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RDS on IB uses privdata to do protocol version negotiation. Apparently
the IB stack will return a larger privdata buffer than the struct we were
expecting. Just to be extra-sure, this patch adds some checks in this area.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib_cm.c |   25 +++++++++++++++++++------
 1 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 605c032..0964ac5 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -98,7 +98,7 @@ void rds_ib_cm_connect_complete(struct rds_connection *conn, struct rdma_cm_even
 	struct ib_qp_attr qp_attr;
 	int err;
 
-	if (event->param.conn.private_data_len) {
+	if (event->param.conn.private_data_len >= sizeof(*dp)) {
 		dp = event->param.conn.private_data;
 
 		rds_ib_set_protocol(conn,
@@ -344,19 +344,32 @@ out:
 	return ret;
 }
 
-static u32 rds_ib_protocol_compatible(const struct rds_ib_connect_private *dp)
+static u32 rds_ib_protocol_compatible(struct rdma_cm_event *event)
 {
+	const struct rds_ib_connect_private *dp = event->param.conn.private_data;
 	u16 common;
 	u32 version = 0;
 
-	/* rdma_cm private data is odd - when there is any private data in the
+	/*
+	 * rdma_cm private data is odd - when there is any private data in the
 	 * request, we will be given a pretty large buffer without telling us the
 	 * original size. The only way to tell the difference is by looking at
 	 * the contents, which are initialized to zero.
 	 * If the protocol version fields aren't set, this is a connection attempt
 	 * from an older version. This could could be 3.0 or 2.0 - we can't tell.
-	 * We really should have changed this for OFED 1.3 :-( */
-	if (dp->dp_protocol_major == 0)
+	 * We really should have changed this for OFED 1.3 :-(
+	 */
+
+	/* Be paranoid. RDS always has privdata */
+	if (!event->param.conn.private_data_len) {
+		printk(KERN_NOTICE "RDS incoming connection has no private data, "
+			"rejecting\n");
+		return 0;
+	}
+
+	/* Even if len is crap *now* I still want to check it. -ASG */
+	if (event->param.conn.private_data_len < sizeof (*dp)
+	    || dp->dp_protocol_major == 0)
 		return RDS_PROTOCOL_3_0;
 
 	common = be16_to_cpu(dp->dp_protocol_minor_mask) & RDS_IB_SUPPORTED_PROTOCOLS;
@@ -388,7 +401,7 @@ int rds_ib_cm_handle_connect(struct rdma_cm_id *cm_id,
 	int err, destroy = 1;
 
 	/* Check whether the remote protocol version matches ours. */
-	version = rds_ib_protocol_compatible(dp);
+	version = rds_ib_protocol_compatible(event);
 	if (!version)
 		goto out;
 
-- 
1.6.0.4

