From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH v2 14/16] mlx4_core: reserve UARs for userspace consumers
Date: Wed, 23 Mar 2011 10:38:48 +0200
Message-ID: <4D89B198.9050303@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eli@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:58140 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755882Ab1CWIiv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2011 04:38:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.co.il>

Do not allow a kernel consumer to allocate a UAR to serve for blue flame if the
number of available UARs gets below MLX4_NUM_RESERVED_UARS (currently 8). This
will allow userspace apps to open a device file and run things like
ibv_devinfo.

Signed-off-by: Eli Cohen <eli@mellanox.co.il>
---
 drivers/net/mlx4/pd.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/pd.c b/drivers/net/mlx4/pd.c
index 5210a0f..1286b88 100644
--- a/drivers/net/mlx4/pd.c
+++ b/drivers/net/mlx4/pd.c
@@ -39,6 +39,10 @@
 #include "mlx4.h"
 #include "icm.h"
 
+enum {
+	MLX4_NUM_RESERVED_UARS = 8
+};
+
 int mlx4_pd_alloc(struct mlx4_dev *dev, u32 *pdn)
 {
 	struct mlx4_priv *priv = mlx4_priv(dev);
@@ -104,6 +108,10 @@ int mlx4_bf_alloc(struct mlx4_dev *dev, struct mlx4_bf *bf)
 	if (!list_empty(&priv->bf_list))
 		uar = list_entry(priv->bf_list.next, struct mlx4_uar, bf_list);
 	else {
+		if (mlx4_bitmap_avail(&priv->uar_table.bitmap) < MLX4_NUM_RESERVED_UARS) {
+			err = -ENOMEM;
+			goto out;
+		}
 		uar = kmalloc(sizeof *uar, GFP_KERNEL);
 		if (!uar) {
 			err = -ENOMEM;
-- 
1.6.0.2





