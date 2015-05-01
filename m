From: David Ahern <david.ahern@oracle.com>
Subject: [PATCH v2] net/rds: fix unaligned memory access
Date: Thu, 30 Apr 2015 20:58:07 -0400
Message-ID: <1430441887-37808-1-git-send-email-david.ahern@oracle.com>
Cc: shamir rabinovitch <shamir.rabinovitch@oracle.com>,
	David Ahern <david.ahern@oracle.com>
To: rds-devel@oss.oracle.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:38753 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbbEAA6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 20:58:23 -0400
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t410wMOI029156
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 1 May 2015 00:58:22 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: shamir rabinovitch <shamir.rabinovitch@oracle.com>

rdma_conn_param private data is copied using memcpy after headers such
as cma_hdr (see cma_resolve_ib_udp as example). so the start of the
private data is aligned to the end of the structure that come before. if
this structure end with u32 the meaning is that the start of the private
data will be 4 bytes aligned. structures that use u8/u16/u32/u64 are
naturally aligned but in case the structure start is not 8 bytes aligned,
all u64 members of this structure will not be aligned. to solve this issue
we must use special macros that allow unaligned access to those
unaligned members.

Addresses the following kernel log seen when attempting to use RDMA:

Kernel unaligned access at TPC[10507a88] rds_ib_cm_connect_complete+0x1bc/0x1e0 [rds_rdma]

Acked-by: Chien Yen <chien.yen@oracle.com>
Signed-off-by: shamir rabinovitch <shamir.rabinovitch@oracle.com>
[Minor tweaks for top of tree by:]
Signed-off-by: David Ahern <david.ahern@oracle.com>
---
v2
- remove references to sparc from code comment

 net/rds/ib_cm.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 31b74f5e61ad..29144a60019f 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -183,8 +183,17 @@ void rds_ib_cm_connect_complete(struct rds_connection *conn, struct rdma_cm_even
 
 	/* If the peer gave us the last packet it saw, process this as if
 	 * we had received a regular ACK. */
-	if (dp && dp->dp_ack_seq)
-		rds_send_drop_acked(conn, be64_to_cpu(dp->dp_ack_seq), NULL);
+	if (dp) {
+		/* dp structure start is not guaranteed to be 8 bytes aligned.
+		 * Since dp_ack_seq is 64-bit extended load operations can be
+		 * used so go through get_unaligned to avoid unaligned errors.
+		 */
+		u64 dp_ack_seq = get_unaligned(&dp->dp_ack_seq);
+
+		if (dp_ack_seq)
+			rds_send_drop_acked(conn, be64_to_cpu(dp_ack_seq),
+					    NULL);
+	}
 
 	rds_connect_complete(conn);
 }
-- 
2.3.0
