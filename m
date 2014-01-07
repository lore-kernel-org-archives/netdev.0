From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH 1/2] net/mlx4_core: clean up cq_res_start_move_to()
Date: Tue, 07 Jan 2014 14:01:18 +0100
Message-ID: <1389099678.15032.19.camel@x41>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Rony Efraim <ronye@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Building resource_tracker.o triggers a GCC warning:
    drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In function 'mlx4_HW2SW_CQ_wrapper':
    drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:3019:16: warning: 'cq' may be used uninitialized in this function [-Wmaybe-uninitialized]
      atomic_dec(&cq->mtt->ref_count);
                    ^

This is a false positive. But a cleanup of cq_res_start_move_to() can
help GCC here. The code currently uses a switch statement where a plain
if/else would do, since only two of the switch's four cases can ever
occur. Dropping that switch makes the warning go away.

While we're at it, do some coding style cleanups (missing braces), and
drop a test that always evaluates to true.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  | 51 ++++++++--------------
 1 file changed, 19 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 2f3f2bc..a41f01e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -1340,43 +1340,30 @@ static int cq_res_start_move_to(struct mlx4_dev *dev, int slave, int cqn,
 
 	spin_lock_irq(mlx4_tlock(dev));
 	r = res_tracker_lookup(&tracker->res_tree[RES_CQ], cqn);
-	if (!r)
+	if (!r) {
 		err = -ENOENT;
-	else if (r->com.owner != slave)
+	} else if (r->com.owner != slave) {
 		err = -EPERM;
-	else {
-		switch (state) {
-		case RES_CQ_BUSY:
+	} else if (state == RES_CQ_ALLOCATED) {
+		if (r->com.state != RES_CQ_HW)
+			err = -EINVAL;
+		else if (atomic_read(&r->ref_count))
 			err = -EBUSY;
-			break;
-
-		case RES_CQ_ALLOCATED:
-			if (r->com.state != RES_CQ_HW)
-				err = -EINVAL;
-			else if (atomic_read(&r->ref_count))
-				err = -EBUSY;
-			else
-				err = 0;
-			break;
-
-		case RES_CQ_HW:
-			if (r->com.state != RES_CQ_ALLOCATED)
-				err = -EINVAL;
-			else
-				err = 0;
-			break;
-
-		default:
+		else
+			err = 0;
+	} else {
+		/* state == RES_CQ_HW */
+		if (r->com.state != RES_CQ_ALLOCATED)
 			err = -EINVAL;
-		}
+		else
+			err = 0;
+	}
 
-		if (!err) {
-			r->com.from_state = r->com.state;
-			r->com.to_state = state;
-			r->com.state = RES_CQ_BUSY;
-			if (cq)
-				*cq = r;
-		}
+	if (!err) {
+		r->com.from_state = r->com.state;
+		r->com.to_state = state;
+		r->com.state = RES_CQ_BUSY;
+		*cq = r;
 	}
 
 	spin_unlock_irq(mlx4_tlock(dev));
-- 
1.8.4.2
