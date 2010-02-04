From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 14/23 v3] mlx4_core: Determine primary physical function
Date: Thu, 04 Feb 2010 17:56:15 +0200
Message-ID: <4B6AEE1F.5050506@mellanox.co.il>
References: <49BFC313.1030901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49784 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933222Ab0BDP4S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 10:56:18 -0500
In-Reply-To: <49BFC313.1030901@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In multifunctional devices, only the primary function would succeed
to execute QUERY_FW command, all other would fail with _EACCES error.
A physical function that is not primary would behave as slave.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/fw.c       |    4 ++++
 drivers/net/mlx4/fw.h       |    1 +
 drivers/net/mlx4/main.c     |   18 +++++++++++++++---
 include/linux/mlx4/device.h |    2 ++
 4 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index 066db0e..3c6601a 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -313,6 +313,10 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev_cap->max_rdma_global = 1 << (field & 0x3f);
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_ACK_DELAY_OFFSET);
 	dev_cap->local_ca_ack_delay = field & 0x1f;
+	MLX4_GET(field, outbox, QUERY_DEV_CAP_MTU_WIDTH_OFFSET);
+	dev_cap->pf_num = field;
+	if (dev_cap->pf_num > 1)
+		dev->flags |= MLX4_FLAG_MASTER;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_VL_PORT_OFFSET);
 	dev_cap->num_ports = field & 0xf;
 	MLX4_GET(field, outbox, QUERY_DEV_CAP_MAX_MSG_SZ_OFFSET);
diff --git a/drivers/net/mlx4/fw.h b/drivers/net/mlx4/fw.h
index f0d4f1c..59acfd0 100644
--- a/drivers/net/mlx4/fw.h
+++ b/drivers/net/mlx4/fw.h
@@ -64,6 +64,7 @@ struct mlx4_dev_cap {
 	int max_responder_per_qp;
 	int max_rdma_global;
 	int local_ca_ack_delay;
+	int pf_num;
 	int num_ports;
 	u32 max_msg_sz;
 	int ib_mtu[MLX4_MAX_PORTS + 1];
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index 37293ca..9f9292a 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -191,6 +191,7 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		return -ENODEV;
 	}
 
+	dev->caps.pf_num = dev_cap->pf_num;
 	dev->caps.num_ports	     = dev_cap->num_ports;
 	for (i = 1; i <= dev->caps.num_ports; ++i) {
 		dev->caps.vl_cap[i]	    = dev_cap->max_vl[i];
@@ -867,7 +868,8 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 		err = mlx4_QUERY_FW(dev); /* TODO: verify FW version in slaves as well */
 		if (err) {
 			if (err == -EACCES)
-				mlx4_info(dev, "non-primary physical function, skipping.\n");
+				mlx4_info(dev, "Non-primary physical function, "
+					       "Running in slave mode.\n");
 			else {
 				mlx4_err(dev, "QUERY_FW command failed, aborting.\n");
 				if (mlx4_is_master(dev))
@@ -1320,6 +1322,7 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 		}
 	}
 
+slave_start:
 	if (mlx4_cmd_init(dev)) {
 		mlx4_err(dev, "Failed to init command interface, aborting.\n");
 		goto err_sriov;
@@ -1335,8 +1338,17 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	}
 
 	err = mlx4_init_hca(dev);
-	if (err)
-		goto err_cmd;
+	if (err) {
+		if (err == -EACCES) {
+			/* Not primary Physical function
+			 * Running in slave mode */
+			mlx4_cmd_cleanup(dev);
+			dev->flags |= MLX4_FLAG_SLAVE;
+			dev->flags &= ~MLX4_FLAG_MASTER;
+			goto slave_start;
+		} else
+			goto err_cmd;
+	}
 
 	/* In master functions, the communication channel must be initialized after obtaining
 	 * its address from fw */
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 73a1856..38de006 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -45,6 +45,7 @@ enum {
 	MLX4_FLAG_MASTER	= 1 << 2,
 	MLX4_FLAG_SLAVE		= 1 << 3,
 	MLX4_FLAG_SRIOV		= 1 << 4,
+	MLX4_FLAG_PF		= 1 << 5,
 };
 
 enum {
@@ -183,6 +184,7 @@ static inline u64 mlx4_fw_ver(u64 major, u64 minor, u64 subminor)
 
 struct mlx4_caps {
 	u64			fw_ver;
+	int			pf_num;
 	int			num_ports;
 	int			vl_cap[MLX4_MAX_PORTS + 1];
 	int			ib_mtu_cap[MLX4_MAX_PORTS + 1];
-- 
1.6.1.3


