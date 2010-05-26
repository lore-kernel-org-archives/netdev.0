From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 1/17] net/rds: Add missing mutex_unlock
Date: Wed, 26 May 2010 17:54:21 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005261754030.23743@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Andy Grover <andy.grover@oracle.com>,
	"David S. Miller" <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

Add a mutex_unlock missing on the error path.  In each case, whenever the
label out is reached from elsewhere in the function, mutex is not locked.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression E1;
@@

* mutex_lock(E1);
  <+... when != E1
  if (...) {
    ... when != E1
*   return ...;
  }
  ...+>
* mutex_unlock(E1);
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 net/rds/ib_cm.c |    1 +
 net/rds/iw_cm.c |    1 +
 2 files changed, 2 insertions(+)

diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 10ed0d5..f688327 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -475,6 +475,7 @@ int rds_ib_cm_handle_connect(struct rdma_cm_id *cm_id,
 	err = rds_ib_setup_qp(conn);
 	if (err) {
 		rds_ib_conn_error(conn, "rds_ib_setup_qp failed (%d)\n", err);
+		mutex_unlock(&conn->c_cm_lock);
 		goto out;
 	}
 
diff --git a/net/rds/iw_cm.c b/net/rds/iw_cm.c
index a9d951b..b5dd6ac 100644
--- a/net/rds/iw_cm.c
+++ b/net/rds/iw_cm.c
@@ -452,6 +452,7 @@ int rds_iw_cm_handle_connect(struct rdma_cm_id *cm_id,
 	err = rds_iw_setup_qp(conn);
 	if (err) {
 		rds_iw_conn_error(conn, "rds_iw_setup_qp failed (%d)\n", err);
+		mutex_unlock(&conn->c_cm_lock);
 		goto out;
 	}
 
