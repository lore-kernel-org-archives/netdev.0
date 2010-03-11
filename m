From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 11/13] RDS: Properly unmap when getting a remote access error
Date: Thu, 11 Mar 2010 15:50:05 -0800
Message-ID: <1268351407-7394-12-git-send-email-andy.grover@oracle.com>
References: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com, Sherman Pun <sherman.pun@sun.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:38472 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754515Ab0CKXu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 18:50:59 -0500
Received: from rcsinet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by acsinet11.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id o2BNovbB018108
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 23:50:59 GMT
In-Reply-To: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sherman Pun <sherman.pun@sun.com>

If the RDMA op has aborted with a remote access error,
in addition to what we already do (tell userspace it has
completed with an error) also unmap it and put() the rm.

Otherwise, hangs may occur on arches that track maps and
will not exit without proper cleanup.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib_send.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index c18228a..17fa808 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -243,8 +243,12 @@ void rds_ib_send_cq_comp_handler(struct ib_cq *cq, void *context)
 				struct rds_message *rm;
 
 				rm = rds_send_get_message(conn, send->s_op);
-				if (rm)
+				if (rm) {
+					if (rm->m_rdma_op)
+						rds_ib_send_unmap_rdma(ic, rm->m_rdma_op);
 					rds_ib_send_rdma_complete(rm, wc.status);
+					rds_message_put(rm);
+				}
 			}
 
 			oldest = (oldest + 1) % ic->i_send_ring.w_nr;
-- 
1.6.3.3

