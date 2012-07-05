From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 02/10] net/mlx4_core: Change resource tracking ID to be 64 bit
Date: Thu,  5 Jul 2012 17:03:42 +0300
Message-ID: <1341497030-1818-3-git-send-email-ogerlitz@mellanox.com>
References: <1341497030-1818-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, yevgenyp@mellanox.com, oren@mellanox.com,
	netdev@vger.kernel.org, amirv@mellanox.com,
	Hadar Hen Zion <hadarh@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:59688 "HELO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751604Ab2GEOGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 10:06:32 -0400
In-Reply-To: <1341497030-1818-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.co.il>

Currently the IDs used by the resource tracker are of type u32, so far this was
ok since all the different resources we were tracking could be encoded in 32bit.

As a preparation step for tracking of resources whose IDs need > 32 bits such
as network flow steering rules, who are 64 bit in size, move to use 64 bit
based resource IDs.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    2 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   26 ++++++++++----------
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 1a2f372..a425a98 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -1033,7 +1033,7 @@ int mlx4_SET_PORT(struct mlx4_dev *dev, u8 port);
 /* resource tracker functions*/
 int mlx4_get_slave_from_resource_id(struct mlx4_dev *dev,
 				    enum mlx4_resource resource_type,
-				    int resource_id, int *slave);
+				    u64 resource_id, int *slave);
 void mlx4_delete_all_resources_for_slave(struct mlx4_dev *dev, int slave_id);
 int mlx4_init_resource_tracker(struct mlx4_dev *dev);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 80c03c8..6bdac29 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -58,7 +58,7 @@ struct mac_res {
 struct res_common {
 	struct list_head	list;
 	struct rb_node		node;
-	u32		        res_id;
+	u64		        res_id;
 	int			owner;
 	int			state;
 	int			from_state;
@@ -324,7 +324,7 @@ static void *find_res(struct mlx4_dev *dev, int res_id,
 				  res_id);
 }
 
-static int get_res(struct mlx4_dev *dev, int slave, int res_id,
+static int get_res(struct mlx4_dev *dev, int slave, u64 res_id,
 		   enum mlx4_resource type,
 		   void *res)
 {
@@ -350,7 +350,7 @@ static int get_res(struct mlx4_dev *dev, int slave, int res_id,
 
 	r->from_state = r->state;
 	r->state = RES_ANY_BUSY;
-	mlx4_dbg(dev, "res %s id 0x%x to busy\n",
+	mlx4_dbg(dev, "res %s id 0x%llx to busy\n",
 		 ResourceType(type), r->res_id);
 
 	if (res)
@@ -363,7 +363,7 @@ exit:
 
 int mlx4_get_slave_from_resource_id(struct mlx4_dev *dev,
 				    enum mlx4_resource type,
-				    int res_id, int *slave)
+				    u64 res_id, int *slave)
 {
 
 	struct res_common *r;
@@ -384,7 +384,7 @@ int mlx4_get_slave_from_resource_id(struct mlx4_dev *dev,
 	return err;
 }
 
-static void put_res(struct mlx4_dev *dev, int slave, int res_id,
+static void put_res(struct mlx4_dev *dev, int slave, u64 res_id,
 		    enum mlx4_resource type)
 {
 	struct res_common *r;
@@ -516,7 +516,7 @@ static struct res_common *alloc_xrcdn_tr(int id)
 	return &ret->com;
 }
 
-static struct res_common *alloc_tr(int id, enum mlx4_resource type, int slave,
+static struct res_common *alloc_tr(u64 id, enum mlx4_resource type, int slave,
 				   int extra)
 {
 	struct res_common *ret;
@@ -558,7 +558,7 @@ static struct res_common *alloc_tr(int id, enum mlx4_resource type, int slave,
 	return ret;
 }
 
-static int add_res_range(struct mlx4_dev *dev, int slave, int base, int count,
+static int add_res_range(struct mlx4_dev *dev, int slave, u64 base, int count,
 			 enum mlx4_resource type, int extra)
 {
 	int i;
@@ -727,10 +727,10 @@ static int remove_ok(struct res_common *res, enum mlx4_resource type, int extra)
 	}
 }
 
-static int rem_res_range(struct mlx4_dev *dev, int slave, int base, int count,
+static int rem_res_range(struct mlx4_dev *dev, int slave, u64 base, int count,
 			 enum mlx4_resource type, int extra)
 {
-	int i;
+	u64 i;
 	int err;
 	struct mlx4_priv *priv = mlx4_priv(dev);
 	struct mlx4_resource_tracker *tracker = &priv->mfunc.master.res_tracker;
@@ -784,7 +784,7 @@ static int qp_res_start_move_to(struct mlx4_dev *dev, int slave, int qpn,
 	else {
 		switch (state) {
 		case RES_QP_BUSY:
-			mlx4_dbg(dev, "%s: failed RES_QP, 0x%x\n",
+			mlx4_dbg(dev, "%s: failed RES_QP, 0x%llx\n",
 				 __func__, r->com.res_id);
 			err = -EBUSY;
 			break;
@@ -793,7 +793,7 @@ static int qp_res_start_move_to(struct mlx4_dev *dev, int slave, int qpn,
 			if (r->com.state == RES_QP_MAPPED && !alloc)
 				break;
 
-			mlx4_dbg(dev, "failed RES_QP, 0x%x\n", r->com.res_id);
+			mlx4_dbg(dev, "failed RES_QP, 0x%llx\n", r->com.res_id);
 			err = -EINVAL;
 			break;
 
@@ -802,7 +802,7 @@ static int qp_res_start_move_to(struct mlx4_dev *dev, int slave, int qpn,
 			    r->com.state == RES_QP_HW)
 				break;
 			else {
-				mlx4_dbg(dev, "failed RES_QP, 0x%x\n",
+				mlx4_dbg(dev, "failed RES_QP, 0x%llx\n",
 					  r->com.res_id);
 				err = -EINVAL;
 			}
@@ -2794,7 +2794,7 @@ static int _move_all_busy(struct mlx4_dev *dev, int slave,
 				if (r->state == RES_ANY_BUSY) {
 					if (print)
 						mlx4_dbg(dev,
-							 "%s id 0x%x is busy\n",
+							 "%s id 0x%llx is busy\n",
 							  ResourceType(type),
 							  r->res_id);
 					++busy;
-- 
1.7.1
