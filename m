From: Mike Marciniszyn <mike.marciniszyn@intel.com>
Subject: [PATCH 1/2] IB/rds: Correct ib_api use with gs_dma_address/sg_dma_len
Date: Fri, 21 Dec 2012 13:01:49 -0500
Message-ID: <20121221180149.23716.54707.stgit@phlsvslse11.ph.intel.com>
References: <20121221175857.23716.46975.stgit@phlsvslse11.ph.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, roland@kernel.org,
	rds-devel@oss.oracle.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: venkat.x.venkatsubra@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:35831 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751393Ab2LUSBw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2012 13:01:52 -0500
In-Reply-To: <20121221175857.23716.46975.stgit@phlsvslse11.ph.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

0b088e00 ("RDS: Use page_remainder_alloc() for recv bufs")
added uses of sg_dma_len() and sg_dma_address(). This makes
RDS DOA with the qib driver.

IB ulps should use ib_sg_dma_len() and ib_sg_dma_address
respectively since some HCAs overload ib_sg_dma* operations.

Signed-off-by: Mike Marciniszyn <mike.marciniszyn@intel.com>
---
 net/rds/ib_recv.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index 8c5bc85..8eb9501 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -339,8 +339,8 @@ static int rds_ib_recv_refill_one(struct rds_connection *conn,
 	sge->length = sizeof(struct rds_header);
 
 	sge = &recv->r_sge[1];
-	sge->addr = sg_dma_address(&recv->r_frag->f_sg);
-	sge->length = sg_dma_len(&recv->r_frag->f_sg);
+	sge->addr = ib_sg_dma_address(ic->i_cm_id->device, &recv->r_frag->f_sg);
+	sge->length = ib_sg_dma_len(ic->i_cm_id->device, &recv->r_frag->f_sg);
 
 	ret = 0;
 out:
@@ -381,7 +381,10 @@ void rds_ib_recv_refill(struct rds_connection *conn, int prefill)
 		ret = ib_post_recv(ic->i_cm_id->qp, &recv->r_wr, &failed_wr);
 		rdsdebug("recv %p ibinc %p page %p addr %lu ret %d\n", recv,
 			 recv->r_ibinc, sg_page(&recv->r_frag->f_sg),
-			 (long) sg_dma_address(&recv->r_frag->f_sg), ret);
+			 (long) ib_sg_dma_address(
+				ic->i_cm_id->device,
+				&recv->r_frag->f_sg),
+			ret);
 		if (ret) {
 			rds_ib_conn_error(conn, "recv post on "
 			       "%pI4 returned %d, disconnecting and "
