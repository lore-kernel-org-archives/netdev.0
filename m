From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 07/10] net/mlx4_core: Add resource alloc/dealloc debugging
Date: Sun, 27 Nov 2016 17:51:14 +0200
Message-ID: <1480261877-19720-8-git-send-email-tariqt@mellanox.com>
References: <1480261877-19720-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:50466 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753171AbcK0Pvk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 10:51:40 -0500
In-Reply-To: <1480261877-19720-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

In order to aid debugging of functions that take a resource but
don't put it, add the last function name that successfully grabbed
this resource.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  | 49 ++++++++++++++++++++--
 1 file changed, 45 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index 05ba270c4862..f59efe59ce58 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -77,6 +77,7 @@ struct res_common {
 	int			from_state;
 	int			to_state;
 	int			removing;
+	const char		*func_name;
 };
 
 enum {
@@ -837,6 +838,36 @@ static int mpt_mask(struct mlx4_dev *dev)
 	return dev->caps.num_mpts - 1;
 }
 
+static const char *mlx4_resource_type_to_str(enum mlx4_resource t)
+{
+	switch (t) {
+	case RES_QP:
+		return "QP";
+	case RES_CQ:
+		return "CQ";
+	case RES_SRQ:
+		return "SRQ";
+	case RES_XRCD:
+		return "XRCD";
+	case RES_MPT:
+		return "MPT";
+	case RES_MTT:
+		return "MTT";
+	case RES_MAC:
+		return "MAC";
+	case RES_VLAN:
+		return "VLAN";
+	case RES_COUNTER:
+		return "COUNTER";
+	case RES_FS_RULE:
+		return "FS_RULE";
+	case RES_EQ:
+		return "EQ";
+	default:
+		return "INVALID RESOURCE";
+	}
+}
+
 static void *find_res(struct mlx4_dev *dev, u64 res_id,
 		      enum mlx4_resource type)
 {
@@ -846,9 +877,9 @@ static void *find_res(struct mlx4_dev *dev, u64 res_id,
 				  res_id);
 }
 
-static int get_res(struct mlx4_dev *dev, int slave, u64 res_id,
-		   enum mlx4_resource type,
-		   void *res)
+static int _get_res(struct mlx4_dev *dev, int slave, u64 res_id,
+		    enum mlx4_resource type,
+		    void *res, const char *func_name)
 {
 	struct res_common *r;
 	int err = 0;
@@ -861,6 +892,10 @@ static int get_res(struct mlx4_dev *dev, int slave, u64 res_id,
 	}
 
 	if (r->state == RES_ANY_BUSY) {
+		mlx4_warn(dev,
+			  "%s(%d) trying to get resource %llx of type %s, but it's already taken by %s\n",
+			  func_name, slave, res_id, mlx4_resource_type_to_str(type),
+			  r->func_name);
 		err = -EBUSY;
 		goto exit;
 	}
@@ -872,6 +907,7 @@ static int get_res(struct mlx4_dev *dev, int slave, u64 res_id,
 
 	r->from_state = r->state;
 	r->state = RES_ANY_BUSY;
+	r->func_name = func_name;
 
 	if (res)
 		*((struct res_common **)res) = r;
@@ -881,6 +917,9 @@ static int get_res(struct mlx4_dev *dev, int slave, u64 res_id,
 	return err;
 }
 
+#define get_res(dev, slave, res_id, type, res) \
+	_get_res((dev), (slave), (res_id), (type), (res), __func__)
+
 int mlx4_get_slave_from_resource_id(struct mlx4_dev *dev,
 				    enum mlx4_resource type,
 				    u64 res_id, int *slave)
@@ -911,8 +950,10 @@ static void put_res(struct mlx4_dev *dev, int slave, u64 res_id,
 
 	spin_lock_irq(mlx4_tlock(dev));
 	r = find_res(dev, res_id, type);
-	if (r)
+	if (r) {
 		r->state = r->from_state;
+		r->func_name = "";
+	}
 	spin_unlock_irq(mlx4_tlock(dev));
 }
 
-- 
1.8.3.1
