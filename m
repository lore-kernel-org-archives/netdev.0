From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 14/14] RDS: check for valid cm_id before initiating connection
Date: Sat, 22 Aug 2015 15:45:35 -0700
Message-ID: <1440283535-4800-15-git-send-email-santosh.shilimkar@oracle.com>
References: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Connection could have been dropped while the route is being resolved
so check for valid cm_id before initiating the connection.

Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/rdma_transport.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/net/rds/rdma_transport.c b/net/rds/rdma_transport.c
index 2082408..b9b40af 100644
--- a/net/rds/rdma_transport.c
+++ b/net/rds/rdma_transport.c
@@ -34,6 +34,7 @@
 #include <rdma/rdma_cm.h>
 
 #include "rdma_transport.h"
+#include "ib.h"
 
 static struct rdma_cm_id *rds_rdma_listen_id;
 
@@ -82,8 +83,18 @@ int rds_rdma_cm_event_handler(struct rdma_cm_id *cm_id,
 		break;
 
 	case RDMA_CM_EVENT_ROUTE_RESOLVED:
-		/* XXX worry about racing with listen acceptance */
-		ret = trans->cm_initiate_connect(cm_id);
+		/* Connection could have been dropped so make sure the
+		 * cm_id is valid before proceeding
+		 */
+		if (conn) {
+			struct rds_ib_connection *ibic;
+
+			ibic = conn->c_transport_data;
+			if (ibic && ibic->i_cm_id == cm_id)
+				ret = trans->cm_initiate_connect(cm_id);
+			else
+				rds_conn_drop(conn);
+		}
 		break;
 
 	case RDMA_CM_EVENT_ESTABLISHED:
-- 
1.9.1
