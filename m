From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 5/5] net/mlx4: Adapt num_vfs/probed_vf params for single port VF
Date: Wed, 19 Mar 2014 18:11:53 +0200
Message-ID: <1395245513-8139-6-git-send-email-ogerlitz@mellanox.com>
References: <1395245513-8139-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, roland@kernel.org,
	jackm@dev.mellanox.co.il, amirv@mellanox.com, matanb@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:37105 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933574AbaCSQMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Mar 2014 12:12:18 -0400
In-Reply-To: <1395245513-8139-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

A new syntax is added for the module parameters num_vfs and probe_vf.

  num_vfs=p1,p2,p1+p2
  probe_bf=p1,p2,p1+p2

Where p1(2) is the number of VFs on / probed VFs for physical
port1(2) and p1+p2 is the number of dual port VFs.

Single port VFs are currently supported only when the link type
for both ports of the device is Ethernet.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |   47 +++++++++++++++++++++--------
 1 files changed, 34 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 4729254..61d7bcf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -77,13 +77,17 @@ MODULE_PARM_DESC(msi_x, "attempt to use MSI-X if nonzero");
 
 #endif /* CONFIG_PCI_MSI */
 
-static int num_vfs;
-module_param(num_vfs, int, 0444);
-MODULE_PARM_DESC(num_vfs, "enable #num_vfs functions if num_vfs > 0");
-
-static int probe_vf;
-module_param(probe_vf, int, 0644);
-MODULE_PARM_DESC(probe_vf, "number of vfs to probe by pf driver (num_vfs > 0)");
+static uint8_t num_vfs[3] = {0, 0, 0};
+static int num_vfs_argc = 3;
+module_param_array(num_vfs, byte , &num_vfs_argc, 0444);
+MODULE_PARM_DESC(num_vfs, "enable #num_vfs functions if num_vfs > 0\n"
+			  "num_vfs=port1,port2,port1+2");
+
+static uint8_t probe_vf[3] = {0, 0, 0};
+static int probe_vfs_argc = 3;
+module_param_array(probe_vf, byte, &probe_vfs_argc, 0444);
+MODULE_PARM_DESC(probe_vf, "number of vfs to probe by pf driver (num_vfs > 0)\n"
+			   "probe_vf=port1,port2,port1+2");
 
 int mlx4_log_num_mgm_entry_size = MLX4_DEFAULT_MGM_LOG_ENTRY_SIZE;
 module_param_named(log_num_mgm_entry_size,
@@ -2193,7 +2197,10 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
 	struct mlx4_dev *dev;
 	int err;
 	int port;
-	int nvfs[MLX4_MAX_PORTS + 1], prb_vf[MLX4_MAX_PORTS + 1];
+	int nvfs[MLX4_MAX_PORTS + 1] = {0, 0, 0};
+	int prb_vf[MLX4_MAX_PORTS + 1] = {0, 0, 0};
+	const int param_map[MLX4_MAX_PORTS + 1][MLX4_MAX_PORTS + 1] = {
+		{2, 0, 0}, {0, 1, 2}, {0, 1, 2} };
 	unsigned total_vfs = 0;
 	int sriov_initialized = 0;
 	unsigned int i;
@@ -2211,16 +2218,17 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
 	 * per port, we must limit the number of VFs to 63 (since their are
 	 * 128 MACs)
 	 */
-	for (i = 0; i < sizeof(nvfs)/sizeof(nvfs[0]);
-	     total_vfs += nvfs[i], i++) {
-		nvfs[i] = i == MLX4_MAX_PORTS ? num_vfs : 0;
+	for (i = 0; i < sizeof(nvfs)/sizeof(nvfs[0]) && i < num_vfs_argc;
+	     total_vfs += nvfs[param_map[num_vfs_argc - 1][i]], i++) {
+		nvfs[param_map[num_vfs_argc - 1][i]] = num_vfs[i];
 		if (nvfs[i] < 0) {
 			dev_err(&pdev->dev, "num_vfs module parameter cannot be negative\n");
 			return -EINVAL;
 		}
 	}
-	for (i = 0; i < sizeof(prb_vf)/sizeof(prb_vf[0]); i++) {
-		prb_vf[i] = i == MLX4_MAX_PORTS ? probe_vf : 0;
+	for (i = 0; i < sizeof(prb_vf)/sizeof(prb_vf[0]) && i < probe_vfs_argc;
+	     i++) {
+		prb_vf[param_map[probe_vfs_argc - 1][i]] = probe_vf[i];
 		if (prb_vf[i] < 0 || prb_vf[i] > nvfs[i]) {
 			dev_err(&pdev->dev, "probe_vf module parameter cannot be negative or greater than num_vfs\n");
 			return -EINVAL;
@@ -2450,6 +2458,19 @@ slave_start:
 			goto err_close;
 		}
 		if (sriov_initialized) {
+			int ib_ports = 0;
+			mlx4_foreach_port(i, dev, MLX4_PORT_TYPE_IB)
+				ib_ports++;
+
+			if (ib_ports &&
+			    (num_vfs_argc > 1 || probe_vfs_argc > 1)) {
+				mlx4_err(dev,
+					 "Invalid syntax of num_vfs/probe_vfs "
+					 "with IB port. Single port VFs syntax"
+					 " is only supported when all ports "
+					 "are configured as ethernet\n");
+				goto err_close;
+			}
 			for (i = 0; i < sizeof(nvfs)/sizeof(nvfs[0]); i++) {
 				unsigned j;
 				for (j = 0; j < nvfs[i]; ++sum, ++j) {
-- 
1.7.1
