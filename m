From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v3 10/17] RDS: IB: track and log active side endpoint in connection
Date: Mon,  2 Jan 2017 14:45:45 -0800
Message-ID: <1483397152-8307-11-git-send-email-santosh.shilimkar@oracle.com>
References: <1483397152-8307-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483397152-8307-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Useful to know the active and passive end points in a
RDS IB connection.

Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib.h    |  3 +++
 net/rds/ib_cm.c | 11 +++++++----
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/rds/ib.h b/net/rds/ib.h
index f14c26d..5f02b4d 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -181,6 +181,9 @@ struct rds_ib_connection {
 
 	/* Batched completions */
 	unsigned int		i_unsignaled_wrs;
+
+	/* Endpoint role in connection */
+	bool			i_active_side;
 };
 
 /* This assumes that atomic_t is at least 32 bits */
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 3002acf..4d1bf04 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -120,16 +120,17 @@ void rds_ib_cm_connect_complete(struct rds_connection *conn, struct rdma_cm_even
 		rds_conn_destroy(conn);
 		return;
 	} else {
-		pr_notice("RDS/IB: connected <%pI4,%pI4> version %u.%u%s\n",
+		pr_notice("RDS/IB: %s conn connected <%pI4,%pI4> version %u.%u%s\n",
+			  ic->i_active_side ? "Active" : "Passive",
 			  &conn->c_laddr, &conn->c_faddr,
 			  RDS_PROTOCOL_MAJOR(conn->c_version),
 			  RDS_PROTOCOL_MINOR(conn->c_version),
 			  ic->i_flowctl ? ", flow control" : "");
 	}
 
-	/*
-	 * Init rings and fill recv. this needs to wait until protocol negotiation
-	 * is complete, since ring layout is different from 3.0 to 3.1.
+	/* Init rings and fill recv. this needs to wait until protocol
+	 * negotiation is complete, since ring layout is different
+	 * from 3.1 to 4.1.
 	 */
 	rds_ib_send_init_ring(ic);
 	rds_ib_recv_init_ring(ic);
@@ -685,6 +686,7 @@ int rds_ib_cm_initiate_connect(struct rdma_cm_id *cm_id)
 		if (ic->i_cm_id == cm_id)
 			ret = 0;
 	}
+	ic->i_active_side = true;
 	return ret;
 }
 
@@ -859,6 +861,7 @@ void rds_ib_conn_path_shutdown(struct rds_conn_path *cp)
 	ic->i_sends = NULL;
 	vfree(ic->i_recvs);
 	ic->i_recvs = NULL;
+	ic->i_active_side = false;
 }
 
 int rds_ib_conn_alloc(struct rds_connection *conn, gfp_t gfp)
-- 
1.9.1
