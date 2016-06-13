From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next 14/17] RDS: Add rds_conn_path_error()
Date: Mon, 13 Jun 2016 09:44:39 -0700
Message-ID: <5b3b66836a3bfb231e1be01e63246a8b84bcd568.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, santosh.shilimkar@oracle.com,
	sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40974 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965120AbcFMQpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 12:45:17 -0400
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1465829626.git.sowmini.varadhan@oracle.com>
References: <cover.1465829626.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rds_conn_path_error() is the MP-aware analog of rds_conn_error,
to be used by multipath-capable callers.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/connection.c |   12 ++++++++++++
 net/rds/rds.h        |    4 ++++
 net/rds/threads.c    |    3 ++-
 3 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/net/rds/connection.c b/net/rds/connection.c
index 9e0b489..57556e6 100644
--- a/net/rds/connection.c
+++ b/net/rds/connection.c
@@ -655,3 +655,15 @@ __rds_conn_error(struct rds_connection *conn, const char *fmt, ...)
 
 	rds_conn_drop(conn);
 }
+
+void
+__rds_conn_path_error(struct rds_conn_path *cp, const char *fmt, ...)
+{
+	va_list ap;
+
+	va_start(ap, fmt);
+	vprintk(fmt, ap);
+	va_end(ap);
+
+	rds_conn_path_drop(cp);
+}
diff --git a/net/rds/rds.h b/net/rds/rds.h
index 74fcf5a..85f98bd 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -669,6 +669,10 @@ void __rds_conn_error(struct rds_connection *conn, const char *, ...);
 #define rds_conn_error(conn, fmt...) \
 	__rds_conn_error(conn, KERN_WARNING "RDS: " fmt)
 
+void __rds_conn_path_error(struct rds_conn_path *cp, const char *, ...);
+#define rds_conn_path_error(cp, fmt...) \
+	__rds_conn_path_error(cp, KERN_WARNING "RDS: " fmt)
+
 static inline int
 rds_conn_path_transition(struct rds_conn_path *cp, int old, int new)
 {
diff --git a/net/rds/threads.c b/net/rds/threads.c
index 50d2657..94cca66 100644
--- a/net/rds/threads.c
+++ b/net/rds/threads.c
@@ -163,7 +163,8 @@ void rds_connect_worker(struct work_struct *work)
 						     RDS_CONN_DOWN))
 				rds_queue_reconnect(cp);
 			else
-				rds_conn_error(conn, "RDS: connect failed\n");
+				rds_conn_path_error(cp,
+						    "RDS: connect failed\n");
 		}
 	}
 }
-- 
1.7.1
