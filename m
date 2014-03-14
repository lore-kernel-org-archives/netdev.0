From: clsoto@linux.vnet.ibm.com
Subject: [PATCH v2 1/2] IB/mlx5: Implementation of PCI error handler
Date: Fri, 14 Mar 2014 12:14:57 -0500
Message-ID: <20140314171659.508052123@linux.vnet.ibm.com>
References: <20140314171456.181059236@linux.vnet.ibm.com>
Cc: brking@linux.vnet.ibm.com, clsoto@linux.vnet.ibm.com
To: eli@mellanox.com, roland@kernel.org, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [32.97.110.57] ([32.97.110.57]:60593 "HELO
	jupiter1-lp2.austin.ibm.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with SMTP id S1755970AbaCNRUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 13:20:04 -0400
Content-Disposition: inline; filename=ib_mlx5_add_pci_error.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add PCI error handler function support for mlx5.
Created the functions for error_detected and slot_rest, plus will
send a port down event to users when the driver error_detected
function is invoked. This is to prevent a hang seeing in
mcast_remove_one at the time ib_unregister_device is called for the
ib_sa module. It will fail hardware commands while the driver is
handling a PCI error. 

Signed-off-by: Carol Soto <clsoto@linux.vnet.ibm.com>
---
 drivers/infiniband/hw/mlx5/main.c             |   32 +++++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c |    7 +++++
 2 files changed, 38 insertions(+), 1 deletion(-)

Index: b/drivers/infiniband/hw/mlx5/main.c
===================================================================
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1508,11 +1508,41 @@ static DEFINE_PCI_DEVICE_TABLE(mlx5_ib_p
 
 MODULE_DEVICE_TABLE(pci, mlx5_ib_pci_table);
 
+static pci_ers_result_t mlx5_pci_err_detected(struct pci_dev *pdev,
+					      pci_channel_state_t state)
+{
+	struct mlx5_ib_dev *dev = mlx5_pci2ibdev(pdev);
+	struct mlx5_core_dev *mdev = &dev->mdev;
+	u8 port;
+
+	/* To avoid the mcast hang with ipoib up */
+	for (port = 1; port <= dev->mdev.caps.num_ports; port++)
+		mlx5_ib_event(mdev, MLX5_DEV_EVENT_PORT_DOWN, &port);
+
+	remove_one(pdev);
+
+	return state == pci_channel_io_perm_failure ?
+		PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_NEED_RESET;
+}
+
+static pci_ers_result_t mlx5_pci_slot_reset(struct pci_dev *pdev)
+{
+	int ret = init_one(pdev, 0);
+
+	return ret ? PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_RECOVERED;
+}
+
+static const struct pci_error_handlers mlx5_err_handler = {
+	.error_detected = mlx5_pci_err_detected,
+	.slot_reset     = mlx5_pci_slot_reset,
+};
+
 static struct pci_driver mlx5_ib_driver = {
 	.name		= DRIVER_NAME,
 	.id_table	= mlx5_ib_pci_table,
 	.probe		= init_one,
-	.remove		= remove_one
+	.remove		= remove_one,
+	.err_handler	= &mlx5_err_handler,
 };
 
 static int __init mlx5_ib_init(void)
Index: b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
===================================================================
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -646,6 +646,13 @@ static int mlx5_cmd_invoke(struct mlx5_c
 	if (callback && page_queue)
 		return -EINVAL;
 
+	if (pci_channel_offline(dev->pdev)) {
+		/* Device is going through error recovery
+		 * and cannot accept commands.
+		 */
+		return -EIO;
+	}
+
 	ent = alloc_cmd(cmd, in, out, uout, uout_size, callback, context,
 			page_queue);
 	if (IS_ERR(ent))

-- 
