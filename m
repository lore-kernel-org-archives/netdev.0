From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] rds: avoid potential stack overflow
Date: Mon, 09 Mar 2015 13:06:52 +0100
Message-ID: <17806664.ym3oszzFIH@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Roland Dreier <roland@purestorage.com>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	linux-arm-kernel@lists.infradead.org
To: Chien Yen <chien.yen@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The rds_iw_add_conn function stores a large 'struct rds_sock'
object on the stack in order to pass a pair of addresses. This
happens to just fit withint the 1024 byte stack size warning
limit on x86, but just exceed that limit on ARM, which gives
us this warning:

net/rds/iw_rdma.c:200:1: warning: the frame size of 1056 bytes is larger than 1024 bytes [-Wframe-larger-than=]

The warning is correct in principle, though unlikely to be
related to a serious problem.

As the use of this large variable is basically bogus, we can
rearrange the code to not do that. Instead of passing an
rds socket into rds_iw_get_device, we now just pass the two
addresses that we have available in rds_iw_update_cm_id, and
we change rds_iw_get_mr accordingly, to create two address
structures on the stack there.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/net/rds/iw_rdma.c b/net/rds/iw_rdma.c
index a817705ce2d0..dba8d0864f18 100644
--- a/net/rds/iw_rdma.c
+++ b/net/rds/iw_rdma.c
@@ -88,7 +88,9 @@ static unsigned int rds_iw_unmap_fastreg_list(struct rds_iw_mr_pool *pool,
 			int *unpinned);
 static void rds_iw_destroy_fastreg(struct rds_iw_mr_pool *pool, struct rds_iw_mr *ibmr);
 
-static int rds_iw_get_device(struct rds_sock *rs, struct rds_iw_device **rds_iwdev, struct rdma_cm_id **cm_id)
+static int rds_iw_get_device(struct sockaddr_in *src, struct sockaddr_in *dst,
+			     struct rds_iw_device **rds_iwdev,
+			     struct rdma_cm_id **cm_id)
 {
 	struct rds_iw_device *iwdev;
 	struct rds_iw_cm_id *i_cm_id;
@@ -112,15 +114,15 @@ static int rds_iw_get_device(struct rds_sock *rs, struct rds_iw_device **rds_iwd
 				src_addr->sin_port,
 				dst_addr->sin_addr.s_addr,
 				dst_addr->sin_port,
-				rs->rs_bound_addr,
-				rs->rs_bound_port,
-				rs->rs_conn_addr,
-				rs->rs_conn_port);
+				src->sin_addr.s_addr,
+				src->sin_port,
+				dst->sin_addr.s_addr,
+				dst->sin_port);
 #ifdef WORKING_TUPLE_DETECTION
-			if (src_addr->sin_addr.s_addr == rs->rs_bound_addr &&
-			    src_addr->sin_port == rs->rs_bound_port &&
-			    dst_addr->sin_addr.s_addr == rs->rs_conn_addr &&
-			    dst_addr->sin_port == rs->rs_conn_port) {
+			if (src_addr->sin_addr.s_addr == src->sin_addr.s_addr &&
+			    src_addr->sin_port == src->sin_port &&
+			    dst_addr->sin_addr.s_addr == dst->sin_addr.s_addr &&
+			    dst_addr->sin_port == dst->sin_port) {
 #else
 			/* FIXME - needs to compare the local and remote
 			 * ipaddr/port tuple, but the ipaddr is the only
@@ -128,7 +130,7 @@ static int rds_iw_get_device(struct rds_sock *rs, struct rds_iw_device **rds_iwd
 			 * zero'ed.  It doesn't appear to be properly populated
 			 * during connection setup...
 			 */
-			if (src_addr->sin_addr.s_addr == rs->rs_bound_addr) {
+			if (src_addr->sin_addr.s_addr == src->sin_addr.s_addr) {
 #endif
 				spin_unlock_irq(&iwdev->spinlock);
 				*rds_iwdev = iwdev;
@@ -180,19 +182,13 @@ int rds_iw_update_cm_id(struct rds_iw_device *rds_iwdev, struct rdma_cm_id *cm_i
 {
 	struct sockaddr_in *src_addr, *dst_addr;
 	struct rds_iw_device *rds_iwdev_old;
-	struct rds_sock rs;
 	struct rdma_cm_id *pcm_id;
 	int rc;
 
 	src_addr = (struct sockaddr_in *)&cm_id->route.addr.src_addr;
 	dst_addr = (struct sockaddr_in *)&cm_id->route.addr.dst_addr;
 
-	rs.rs_bound_addr = src_addr->sin_addr.s_addr;
-	rs.rs_bound_port = src_addr->sin_port;
-	rs.rs_conn_addr = dst_addr->sin_addr.s_addr;
-	rs.rs_conn_port = dst_addr->sin_port;
-
-	rc = rds_iw_get_device(&rs, &rds_iwdev_old, &pcm_id);
+	rc = rds_iw_get_device(src_addr, dst_addr, &rds_iwdev_old, &pcm_id);
 	if (rc)
 		rds_iw_remove_cm_id(rds_iwdev, cm_id);
 
@@ -598,9 +594,17 @@ void *rds_iw_get_mr(struct scatterlist *sg, unsigned long nents,
 	struct rds_iw_device *rds_iwdev;
 	struct rds_iw_mr *ibmr = NULL;
 	struct rdma_cm_id *cm_id;
+	struct sockaddr_in src = {
+		.sin_addr.s_addr = rs->rs_bound_addr,
+		.sin_port = rs->rs_bound_port,
+	};
+	struct sockaddr_in dst = {
+		.sin_addr.s_addr = rs->rs_conn_addr,
+		.sin_port = rs->rs_conn_port,
+	};
 	int ret;
 
-	ret = rds_iw_get_device(rs, &rds_iwdev, &cm_id);
+	ret = rds_iw_get_device(&src, &dst, &rds_iwdev, &cm_id);
 	if (ret || !cm_id) {
 		ret = -ENODEV;
 		goto out;
