From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 7/9] RDS: Establish connection before parsing CMSGs
Date: Mon, 30 Mar 2009 11:44:51 -0700
Message-ID: <1238438693-29540-8-git-send-email-andy.grover@oracle.com>
References: <1238438693-29540-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:41956 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757526AbZC3SpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 14:45:18 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by rgminet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n2UImNVr014147
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 30 Mar 2009 18:48:25 GMT
In-Reply-To: <1238438693-29540-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first message to a remote node should prompt a new connection.
Even an RDMA op via CMSG. Therefore move CMSG parsing to after
connection establishment.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/send.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index 104fe03..a4a7f42 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -854,11 +854,6 @@ int rds_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 
 	rm->m_daddr = daddr;
 
-	/* Parse any control messages the user may have included. */
-	ret = rds_cmsg_send(rs, rm, msg, &allocated_mr);
-	if (ret)
-		goto out;
-
 	/* rds_conn_create has a spinlock that runs with IRQ off.
 	 * Caching the conn in the socket helps a lot. */
 	if (rs->rs_conn && rs->rs_conn->c_faddr == daddr)
@@ -874,6 +869,11 @@ int rds_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 		rs->rs_conn = conn;
 	}
 
+	/* Parse any control messages the user may have included. */
+	ret = rds_cmsg_send(rs, rm, msg, &allocated_mr);
+	if (ret)
+		goto out;
+
 	if ((rm->m_rdma_cookie || rm->m_rdma_op)
 	 && conn->c_trans->xmit_rdma == NULL) {
 		if (printk_ratelimit())
-- 
1.5.6.3

