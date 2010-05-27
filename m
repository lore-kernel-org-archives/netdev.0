From: Dan Carpenter <error27@gmail.com>
Subject: [patch 1/3] rds/iw_rdma: using too much stack space
Date: Thu, 27 May 2010 11:08:33 +0200
Message-ID: <20100527090833.GR22515@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:52185 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580Ab0E0JIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 05:08:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct rds_sock is pretty big, it uses 944 bytes.  The inclusion of 
struct sock is what does it, struct sock uses 700 bytes.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/rds/iw_rdma.c b/net/rds/iw_rdma.c
index 13dc186..742ab6a 100644
--- a/net/rds/iw_rdma.c
+++ b/net/rds/iw_rdma.c
@@ -178,23 +178,29 @@ int rds_iw_update_cm_id(struct rds_iw_device *rds_iwdev, struct rdma_cm_id *cm_i
 {
 	struct sockaddr_in *src_addr, *dst_addr;
 	struct rds_iw_device *rds_iwdev_old;
-	struct rds_sock rs;
+	struct rds_sock *rs;
 	struct rdma_cm_id *pcm_id;
-	int rc;
+	int ret;
+
+	rs = kmalloc(sizeof(*rs), GFP_KERNEL);
+	if (!rs)
+		return -ENOMEM;
 
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
-	if (rc)
+	ret = rds_iw_get_device(rs, &rds_iwdev_old, &pcm_id);
+	if (ret)
 		rds_iw_remove_cm_id(rds_iwdev, cm_id);
 
-	return rds_iw_add_cm_id(rds_iwdev, cm_id);
+	ret = rds_iw_add_cm_id(rds_iwdev, cm_id);
+	kfree(rs);
+	return ret;
 }
 
 void rds_iw_add_conn(struct rds_iw_device *rds_iwdev, struct rds_connection *conn)

