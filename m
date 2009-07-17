From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 01/15] RDS: Set retry_count to 2 and make modifiable via modparam
Date: Fri, 17 Jul 2009 16:13:22 -0700
Message-ID: <1247872416-17834-2-git-send-email-andy.grover@oracle.com>
References: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:26079 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758036AbZGQXoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 19:44:54 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by acsinet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n6HNiwTU007983
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 17 Jul 2009 23:45:00 GMT
In-Reply-To: <1247872416-17834-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will be default cause IB connections to failover faster,
but allow a longer retry count to be used if desired.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib.c    |    3 +++
 net/rds/ib.h    |    3 +++
 net/rds/ib_cm.c |    2 +-
 3 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/net/rds/ib.c b/net/rds/ib.c
index b9bcd32..27abdd3 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -43,11 +43,14 @@
 
 unsigned int fmr_pool_size = RDS_FMR_POOL_SIZE;
 unsigned int fmr_message_size = RDS_FMR_SIZE + 1; /* +1 allows for unaligned MRs */
+unsigned int rds_ib_retry_count = RDS_IB_DEFAULT_RETRY_COUNT;
 
 module_param(fmr_pool_size, int, 0444);
 MODULE_PARM_DESC(fmr_pool_size, " Max number of fmr per HCA");
 module_param(fmr_message_size, int, 0444);
 MODULE_PARM_DESC(fmr_message_size, " Max size of a RDMA transfer");
+module_param(rds_ib_retry_count, int, 0444);
+MODULE_PARM_DESC(rds_ib_retry_count, " Number of hw retries before reporting an error");
 
 struct list_head rds_ib_devices;
 
diff --git a/net/rds/ib.h b/net/rds/ib.h
index 455ae73..420afb9 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -15,6 +15,8 @@
 #define RDS_IB_DEFAULT_RECV_WR		1024
 #define RDS_IB_DEFAULT_SEND_WR		256
 
+#define RDS_IB_DEFAULT_RETRY_COUNT	2
+
 #define RDS_IB_SUPPORTED_PROTOCOLS	0x00000003	/* minor versions supported */
 
 extern struct list_head rds_ib_devices;
@@ -247,6 +249,7 @@ extern struct ib_client rds_ib_client;
 
 extern unsigned int fmr_pool_size;
 extern unsigned int fmr_message_size;
+extern unsigned int rds_ib_retry_count;
 
 extern spinlock_t ib_nodev_conns_lock;
 extern struct list_head ib_nodev_conns;
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index f8e40e1..605c032 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -145,7 +145,7 @@ static void rds_ib_cm_fill_conn_param(struct rds_connection *conn,
 	/* XXX tune these? */
 	conn_param->responder_resources = 1;
 	conn_param->initiator_depth = 1;
-	conn_param->retry_count = 7;
+	conn_param->retry_count = min_t(unsigned int, rds_ib_retry_count, 7);
 	conn_param->rnr_retry_count = 7;
 
 	if (dp) {
-- 
1.6.0.4

