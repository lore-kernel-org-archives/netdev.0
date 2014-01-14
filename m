From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH v2 2/2] net/mlx4_core: clean up srq_res_start_move_to()
Date: Tue, 14 Jan 2014 20:46:52 +0100
Message-ID: <1389728812.28068.9.camel@x220>
References: <1389099734.15032.20.camel@x41>
	 <20140114084050.70a612af@jpm-OptiPlex-GX620>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Rony Efraim <ronye@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpsmtpb-ews04.kpnxchange.com ([213.75.39.7]:60312 "EHLO
	cpsmtpb-ews04.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751367AbaANTqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 14:46:55 -0500
In-Reply-To: <20140114084050.70a612af@jpm-OptiPlex-GX620>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Building resource_tracker.o triggers a GCC warning:
    drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In function 'mlx4_HW2SW_SRQ_wrapper':
    drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:3202:17: warning: 'srq' may be used uninitialized in this function [-Wmaybe-uninitialized]
      atomic_dec(&srq->mtt->ref_count);
                     ^

This is a false positive. But a cleanup of srq_res_start_move_to() can
help GCC here. The code currently uses a switch statement where a plain
if/else would do, since only two of the switch's four cases can ever
occur. Dropping that switch makes the warning go away.

While we're at it, add some missing braces, and convert state to the
correct type.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
v2: adjust to Jack's review.

 .../net/ethernet/mellanox/mlx4/resource_tracker.c  | 46 ++++++++--------------
 1 file changed, 16 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 15cd659..4acd84c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -1371,7 +1371,7 @@ static int cq_res_start_move_to(struct mlx4_dev *dev, int slave, int cqn,
 }
 
 static int srq_res_start_move_to(struct mlx4_dev *dev, int slave, int index,
-				 enum res_cq_states state, struct res_srq **srq)
+				 enum res_srq_states state, struct res_srq **srq)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_resource_tracker *tracker = &priv->mfunc.master.res_tracker;
@@ -1380,39 +1380,25 @@ static int srq_res_start_move_to(struct mlx4_dev *dev, int slave, int index,
 
 	spin_lock_irq(mlx4_tlock(dev));
 	r = res_tracker_lookup(&tracker->res_tree[RES_SRQ], index);
-	if (!r)
+	if (!r) {
 		err = -ENOENT;
-	else if (r->com.owner != slave)
+	} else if (r->com.owner != slave) {
 		err = -EPERM;
-	else {
-		switch (state) {
-		case RES_SRQ_BUSY:
-			err = -EINVAL;
-			break;
-
-		case RES_SRQ_ALLOCATED:
-			if (r->com.state != RES_SRQ_HW)
-				err = -EINVAL;
-			else if (atomic_read(&r->ref_count))
-				err = -EBUSY;
-			break;
-
-		case RES_SRQ_HW:
-			if (r->com.state != RES_SRQ_ALLOCATED)
-				err = -EINVAL;
-			break;
-
-		default:
+	} else if (state == RES_SRQ_ALLOCATED) {
+		if (r->com.state != RES_SRQ_HW)
 			err = -EINVAL;
-		}
+		else if (atomic_read(&r->ref_count))
+			err = -EBUSY;
+	} else if (state != RES_SRQ_HW || r->com.state != RES_SRQ_ALLOCATED) {
+		err = -EINVAL;
+	}
 
-		if (!err) {
-			r->com.from_state = r->com.state;
-			r->com.to_state = state;
-			r->com.state = RES_SRQ_BUSY;
-			if (srq)
-				*srq = r;
-		}
+	if (!err) {
+		r->com.from_state = r->com.state;
+		r->com.to_state = state;
+		r->com.state = RES_SRQ_BUSY;
+		if (srq)
+			*srq = r;
 	}
 
 	spin_unlock_irq(mlx4_tlock(dev));
-- 
1.8.4.2
