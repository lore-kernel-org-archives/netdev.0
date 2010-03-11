From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 08/13] RDS: Turn down alarming reconnect messages
Date: Thu, 11 Mar 2010 15:50:02 -0800
Message-ID: <1268351407-7394-9-git-send-email-andy.grover@oracle.com>
References: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:56763 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754541Ab0CKXu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 18:50:59 -0500
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by rcsinet12.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id o2BNovEv001379
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 23:50:58 GMT
In-Reply-To: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RDS's error messages when a connection goes down are a little
extreme. A connection may go down, and it will be re-established,
and everything is fine. This patch links these messages through
rdsdebug(), instead of to printk directly.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/ib_cm.c          |    3 ++-
 net/rds/iw_cm.c          |    4 +++-
 net/rds/rdma_transport.c |    2 +-
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 647cb8f..e1f124b 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -203,9 +203,10 @@ static void rds_ib_qp_event_handler(struct ib_event *event, void *data)
 		rdma_notify(ic->i_cm_id, IB_EVENT_COMM_EST);
 		break;
 	default:
-		rds_ib_conn_error(conn, "RDS/IB: Fatal QP Event %u "
+		rdsdebug("Fatal QP Event %u "
 			"- connection %pI4->%pI4, reconnecting\n",
 			event->event, &conn->c_laddr, &conn->c_faddr);
+		rds_conn_drop(conn);
 		break;
 	}
 }
diff --git a/net/rds/iw_cm.c b/net/rds/iw_cm.c
index 394cf6b..6bc638f 100644
--- a/net/rds/iw_cm.c
+++ b/net/rds/iw_cm.c
@@ -156,9 +156,11 @@ static void rds_iw_qp_event_handler(struct ib_event *event, void *data)
 	case IB_EVENT_QP_REQ_ERR:
 	case IB_EVENT_QP_FATAL:
 	default:
-		rds_iw_conn_error(conn, "RDS/IW: Fatal QP Event %u - connection %pI4->%pI4...reconnecting\n",
+		rdsdebug("Fatal QP Event %u "
+			"- connection %pI4->%pI4, reconnecting\n",
 			event->event, &conn->c_laddr,
 			&conn->c_faddr);
+		rds_conn_drop(conn);
 		break;
 	}
 }
diff --git a/net/rds/rdma_transport.c b/net/rds/rdma_transport.c
index 31f9c72..5ea82fc 100644
--- a/net/rds/rdma_transport.c
+++ b/net/rds/rdma_transport.c
@@ -101,7 +101,7 @@ int rds_rdma_cm_event_handler(struct rdma_cm_id *cm_id,
 		break;
 
 	case RDMA_CM_EVENT_DISCONNECTED:
-		printk(KERN_WARNING "RDS/RDMA: DISCONNECT event - dropping connection "
+		rdsdebug("DISCONNECT event - dropping connection "
 			"%pI4->%pI4\n", &conn->c_laddr,
 			 &conn->c_faddr);
 		rds_conn_drop(conn);
-- 
1.6.3.3

