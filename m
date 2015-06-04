From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 05/13] net/mlx5_core: Make the vport helpers available for the IB driver too
Date: Thu,  4 Jun 2015 19:30:40 +0300
Message-ID: <1433435448-4937-6-git-send-email-ogerlitz@mellanox.com>
References: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Majd Dibbiny <majd@mellanox.com>,
	Haggai Abramonvsky <hagaya@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:47759 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932134AbbFDQbf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 12:31:35 -0400
In-Reply-To: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Majd Dibbiny <majd@mellanox.com>

Move the vport header file to be under include/linux/mlx5, such that
the mlx5 IB can use it as well.

Also add nic_ prefix to the vport NIC commands to differeniate between
HCA vport commands and NIC vport commands.

Signed-off-by: Majd Dibbiny <majd@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/vport.c   |    6 ++-
 drivers/net/ethernet/mellanox/mlx5/core/vport.h   |   41 ---------------------
 include/linux/mlx5/vport.h                        |   41 +++++++++++++++++++++
 5 files changed, 47 insertions(+), 45 deletions(-)
 delete mode 100644 drivers/net/ethernet/mellanox/mlx5/core/vport.h
 create mode 100644 include/linux/mlx5/vport.h

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 4df3774..4042381 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -35,7 +35,7 @@
 #include <linux/mlx5/driver.h>
 #include <linux/mlx5/qp.h>
 #include <linux/mlx5/cq.h>
-#include "vport.h"
+#include <linux/mlx5/vport.h>
 #include "wq.h"
 #include "transobj.h"
 #include "mlx5_core.h"
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index e86bfd7..f71f947 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1696,7 +1696,7 @@ static void mlx5e_set_netdev_dev_addr(struct net_device *netdev)
 {
 	struct mlx5e_priv *priv = netdev_priv(netdev);
 
-	mlx5_query_vport_mac_address(priv->mdev, netdev->dev_addr);
+	mlx5_query_nic_vport_mac_address(priv->mdev, netdev->dev_addr);
 }
 
 static void mlx5e_build_netdev(struct net_device *netdev)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vport.c b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
index ba374b9..32c4e03 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/vport.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/vport.c
@@ -33,7 +33,7 @@
 #include <linux/export.h>
 #include <linux/etherdevice.h>
 #include <linux/mlx5/driver.h>
-#include "vport.h"
+#include <linux/mlx5/vport.h>
 #include "mlx5_core.h"
 
 u8 mlx5_query_vport_state(struct mlx5_core_dev *mdev, u8 opmod)
@@ -55,8 +55,9 @@ u8 mlx5_query_vport_state(struct mlx5_core_dev *mdev, u8 opmod)
 
 	return MLX5_GET(query_vport_state_out, out, state);
 }
+EXPORT_SYMBOL(mlx5_query_vport_state);
 
-void mlx5_query_vport_mac_address(struct mlx5_core_dev *mdev, u8 *addr)
+void mlx5_query_nic_vport_mac_address(struct mlx5_core_dev *mdev, u8 *addr)
 {
 	u32  in[MLX5_ST_SZ_DW(query_nic_vport_context_in)];
 	u32 *out;
@@ -82,3 +83,4 @@ void mlx5_query_vport_mac_address(struct mlx5_core_dev *mdev, u8 *addr)
 
 	kvfree(out);
 }
+EXPORT_SYMBOL(mlx5_query_nic_vport_mac_address);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/vport.h b/drivers/net/ethernet/mellanox/mlx5/core/vport.h
deleted file mode 100644
index c05ca2c..0000000
--- a/drivers/net/ethernet/mellanox/mlx5/core/vport.h
+++ /dev/null
@@ -1,41 +0,0 @@
-/*
- * Copyright (c) 2013-2015, Mellanox Technologies, Ltd.  All rights reserved.
- *
- * This software is available to you under a choice of one of two
- * licenses.  You may choose to be licensed under the terms of the GNU
- * General Public License (GPL) Version 2, available from the file
- * COPYING in the main directory of this source tree, or the
- * OpenIB.org BSD license below:
- *
- *     Redistribution and use in source and binary forms, with or
- *     without modification, are permitted provided that the following
- *     conditions are met:
- *
- *      - Redistributions of source code must retain the above
- *        copyright notice, this list of conditions and the following
- *        disclaimer.
- *
- *      - Redistributions in binary form must reproduce the above
- *        copyright notice, this list of conditions and the following
- *        disclaimer in the documentation and/or other materials
- *        provided with the distribution.
- *
- * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
- * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
- * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
- * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
- * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
- * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
- * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
- * SOFTWARE.
- */
-
-#ifndef __MLX5_VPORT_H__
-#define __MLX5_VPORT_H__
-
-#include <linux/mlx5/driver.h>
-
-u8 mlx5_query_vport_state(struct mlx5_core_dev *mdev, u8 opmod);
-void mlx5_query_vport_mac_address(struct mlx5_core_dev *mdev, u8 *addr);
-
-#endif /* __MLX5_VPORT_H__ */
diff --git a/include/linux/mlx5/vport.h b/include/linux/mlx5/vport.h
new file mode 100644
index 0000000..99d0e9f
--- /dev/null
+++ b/include/linux/mlx5/vport.h
@@ -0,0 +1,41 @@
+/*
+ * Copyright (c) 2013-2015, Mellanox Technologies, Ltd.  All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#ifndef __MLX5_VPORT_H__
+#define __MLX5_VPORT_H__
+
+#include <linux/mlx5/driver.h>
+
+u8 mlx5_query_vport_state(struct mlx5_core_dev *mdev, u8 opmod);
+void mlx5_query_nic_vport_mac_address(struct mlx5_core_dev *mdev, u8 *addr);
+
+#endif /* __MLX5_VPORT_H__ */
-- 
1.7.1
