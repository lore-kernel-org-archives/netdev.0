From: Mark Brown <broonie@kernel.org>
Subject: [PATCH] net: rds: Don't allocate rds_sock on stack
Date: Sun, 24 Aug 2014 19:32:35 -0500
Message-ID: <1408926755-12277-1-git-send-email-broonie@kernel.org>
Cc: rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	linaro-kernel@lists.linaro.org, Mark Brown <broonie@linaro.org>
To: Chien Yen <chien.yen@oracle.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:60184 "EHLO
	mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753344AbaHYKCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 06:02:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@linaro.org>

struct rds_sock is rather large ausing the following warning in an ARM
allmodconfig:

net/rds/iw_rdma.c:200:1: warning: the frame size of 1056 bytes is larger than 1024 bytes [-Wframe-larger-than=]

Fix this by dynamically allocating struct rds_sock in rds_iw_update_cm_id
instead of allocating it on the stack.

Signed-off-by: Mark Brown <broonie@linaro.org>
---
 net/rds/iw_rdma.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/net/rds/iw_rdma.c b/net/rds/iw_rdma.c
index a817705..cee5daa 100644
--- a/net/rds/iw_rdma.c
+++ b/net/rds/iw_rdma.c
@@ -180,22 +180,28 @@ int rds_iw_update_cm_id(struct rds_iw_device *rds_iwdev, struct rdma_cm_id *cm_i
 {
 	struct sockaddr_in *src_addr, *dst_addr;
 	struct rds_iw_device *rds_iwdev_old;
-	struct rds_sock rs;
+	struct rds_sock *rs;
 	struct rdma_cm_id *pcm_id;
 	int rc;
 
+	rs = kzalloc(sizeof(*rs), GFP_KERNEL);
+	if (!rs)
+		return -ENOMEM;
+
 	src_addr = (struct sockaddr_in *)&cm_id->route.addr.src_addr;
 	dst_addr = (struct sockaddr_in *)&cm_id->route.addr.dst_addr;
 
-	rs.rs_bound_addr = src_addr->sin_addr.s_addr;
-	rs.rs_bound_port = src_addr->sin_port;
-	rs.rs_conn_addr = dst_addr->sin_addr.s_addr;
-	rs.rs_conn_port = dst_addr->sin_port;
+	rs->rs_bound_addr = src_addr->sin_addr.s_addr;
+	rs->rs_bound_port = src_addr->sin_port;
+	rs->rs_conn_addr = dst_addr->sin_addr.s_addr;
+	rs->rs_conn_port = dst_addr->sin_port;
 
-	rc = rds_iw_get_device(&rs, &rds_iwdev_old, &pcm_id);
+	rc = rds_iw_get_device(rs, &rds_iwdev_old, &pcm_id);
 	if (rc)
 		rds_iw_remove_cm_id(rds_iwdev, cm_id);
 
+	kfree(rs);
+
 	return rds_iw_add_cm_id(rds_iwdev, cm_id);
 }
 
-- 
2.1.0.rc1
