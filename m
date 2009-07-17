From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 03/15] RDS/IB: Handle connections using RDS 3.0 wire protocol
Date: Fri, 17 Jul 2009 16:13:24 -0700
Message-ID: <1247872416-17834-4-git-send-email-andy.grover@oracle.com>
References: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:26118 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758065AbZGQXo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 19:44:56 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by acsinet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n6HNj3mH008253
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 23:45:04 GMT
In-Reply-To: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The big differences between RDS 3.0 and 3.1 are protocol-level
flow control, and with 3.1 the header is in front of the data. The header
always ends up in the header buffer, and the data goes in the data page.

In 3.0 our "header" is a trailer, and will end up either in the data
page, the header buffer, or split across the two. Since 3.1 is backwards-
compatible with 3.0, we need to continue to support these cases. This
patch does that -- if using RDS 3.0 wire protocol, it will copy the header
from wherever it ended up into the header buffer.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib.h      |   12 ++++++++++--
 net/rds/ib_cm.c   |    9 ++++++---
 net/rds/ib_recv.c |   43 ++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 58 insertions(+), 6 deletions(-)

diff --git a/net/rds/ib.h b/net/rds/ib.h
index 420afb9..c0de7af 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -358,17 +358,25 @@ extern ctl_table rds_ib_sysctl_table[];
 /*
  * Helper functions for getting/setting the header and data SGEs in
  * RDS packets (not RDMA)
+ *
+ * From version 3.1 onwards, header is in front of data in the sge.
  */
 static inline struct ib_sge *
 rds_ib_header_sge(struct rds_ib_connection *ic, struct ib_sge *sge)
 {
-	return &sge[0];
+	if (ic->conn->c_version > RDS_PROTOCOL_3_0)
+		return &sge[0];
+	else
+		return &sge[1];
 }
 
 static inline struct ib_sge *
 rds_ib_data_sge(struct rds_ib_connection *ic, struct ib_sge *sge)
 {
-	return &sge[1];
+	if (ic->conn->c_version > RDS_PROTOCOL_3_0)
+		return &sge[1];
+	else
+		return &sge[0];
 }
 
 #endif
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 0964ac5..1eb0c29 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -101,10 +101,13 @@ void rds_ib_cm_connect_complete(struct rds_connection *conn, struct rdma_cm_even
 	if (event->param.conn.private_data_len >= sizeof(*dp)) {
 		dp = event->param.conn.private_data;
 
-		rds_ib_set_protocol(conn,
+		/* make sure it isn't empty data */
+		if (dp->dp_protocol_major) {
+			rds_ib_set_protocol(conn,
 				RDS_PROTOCOL(dp->dp_protocol_major,
-					dp->dp_protocol_minor));
-		rds_ib_set_flow_control(conn, be32_to_cpu(dp->dp_credit));
+				dp->dp_protocol_minor));
+			rds_ib_set_flow_control(conn, be32_to_cpu(dp->dp_credit));
+		}
 	}
 
 	printk(KERN_NOTICE "RDS/IB: connected to %pI4 version %u.%u%s\n",
diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index 5709bad..28bdcdc 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -555,6 +555,47 @@ u64 rds_ib_piggyb_ack(struct rds_ib_connection *ic)
 	return rds_ib_get_ack(ic);
 }
 
+static struct rds_header *rds_ib_get_header(struct rds_connection *conn,
+					    struct rds_ib_recv_work *recv,
+					    u32 data_len)
+{
+	struct rds_ib_connection *ic = conn->c_transport_data;
+	void *hdr_buff = &ic->i_recv_hdrs[recv - ic->i_recvs];
+	void *addr;
+	u32 misplaced_hdr_bytes;
+
+	/*
+	 * Support header at the front (RDS 3.1+) as well as header-at-end.
+	 *
+	 * Cases:
+	 * 1) header all in header buff (great!)
+	 * 2) header all in data page (copy all to header buff)
+	 * 3) header split across hdr buf + data page
+	 *    (move bit in hdr buff to end before copying other bit from data page)
+	 */
+	if (conn->c_version > RDS_PROTOCOL_3_0 || data_len == RDS_FRAG_SIZE)
+	        return hdr_buff;
+
+	if (data_len <= (RDS_FRAG_SIZE - sizeof(struct rds_header))) {
+		addr = kmap_atomic(recv->r_frag->f_page, KM_SOFTIRQ0);
+		memcpy(hdr_buff,
+		       addr + recv->r_frag->f_offset + data_len,
+		       sizeof(struct rds_header));
+		kunmap_atomic(addr, KM_SOFTIRQ0);
+		return hdr_buff;
+	}
+
+	misplaced_hdr_bytes = (sizeof(struct rds_header) - (RDS_FRAG_SIZE - data_len));
+
+	memmove(hdr_buff + misplaced_hdr_bytes, hdr_buff, misplaced_hdr_bytes);
+
+	addr = kmap_atomic(recv->r_frag->f_page, KM_SOFTIRQ0);
+	memcpy(hdr_buff, addr + recv->r_frag->f_offset + data_len,
+	       sizeof(struct rds_header) - misplaced_hdr_bytes);
+	kunmap_atomic(addr, KM_SOFTIRQ0);
+	return hdr_buff;
+}
+
 /*
  * It's kind of lame that we're copying from the posted receive pages into
  * long-lived bitmaps.  We could have posted the bitmaps and rdma written into
@@ -667,7 +708,7 @@ static void rds_ib_process_recv(struct rds_connection *conn,
 	}
 	byte_len -= sizeof(struct rds_header);
 
-	ihdr = &ic->i_recv_hdrs[recv - ic->i_recvs];
+	ihdr = rds_ib_get_header(conn, recv, byte_len);
 
 	/* Validate the checksum. */
 	if (!rds_message_verify_checksum(ihdr)) {
-- 
1.6.0.4

