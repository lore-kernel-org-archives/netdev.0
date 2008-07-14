From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH RFC 02/10] mlx4_en: Device initialization
Date: Mon, 14 Jul 2008 17:40:49 +0300
Message-ID: <487B6571.8000602@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Liran Liss <liranl@mellanox.co.il>,
	tziporet@mellanox.co.il, Roland Dreier <rdreier@cisco.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:45390 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754135AbYGNOsa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2008 10:48:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH] mlx4_en: en_main.c

This file is responsible for device initialization and its
registration with PCI driver (mlx4_core).
It is responsible to query for number of network devices to be
created and sets the parameters for those devices (such as number
of tx/rx rings)

Signed-off-by: Liran Liss <liranl@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_main.c |  244 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 244 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/mlx4/en_main.c

diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
new file mode 100644
index 0000000..bda273e
--- /dev/null
+++ b/drivers/net/mlx4/en_main.c
@@ -0,0 +1,244 @@
+/*
+ * Copyright (c) 2007 Mellanox Technologies. All rights reserved.
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
+ *
+ */
+
+#include <linux/cpumask.h>
+#include <linux/module.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/cpumask.h>
+
+#include <linux/mlx4/driver.h>
+#include <linux/mlx4/device.h>
+#include <linux/mlx4/cmd.h>
+
+#include "mlx4_en.h"
+
+MODULE_AUTHOR("Liran Liss, Yevgeny Petrilin");
+MODULE_DESCRIPTION("Mellanox ConnectX HCA Ethernet driver");
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_VERSION(DRV_VERSION " ("DRV_RELDATE")");
+
+static const char mlx4_en_version[] __devinitdata =
+	DRV_NAME ": Mellanox ConnectX HCA Ethernet driver v"
+	DRV_VERSION " (" DRV_RELDATE ")\n";
+
+static void mlx4_en_event(struct mlx4_dev *dev, void *endev_ptr,
+			  enum mlx4_dev_event event, int port)
+{
+	struct mlx4_en_dev *mdev = (struct mlx4_en_dev *) endev_ptr;
+	struct mlx4_en_priv *priv;
+
+	if (!mdev->pndev[port])
+		return;
+
+	priv = netdev_priv(mdev->pndev[port]);
+	switch (event) {
+	case MLX4_DEV_EVENT_PORT_UP:
+	case MLX4_DEV_EVENT_PORT_DOWN:
+		/* To prevent races, we poll the link state in a separate
+		   task rather than changing it here */
+		priv->link_state = event;
+		queue_work(mdev->workqueue, &priv->linkstate_task);
+		break;
+
+	case MLX4_DEV_EVENT_CATASTROPHIC_ERROR:
+		mlx4_err(mdev, "Internal error detected, restarting device\n");
+		break;
+
+	default:
+		mlx4_warn(mdev, "Unhandled event: %d\n", event);
+	}
+}
+
+static void mlx4_en_remove(struct mlx4_dev *dev, void *endev_ptr)
+{
+	struct mlx4_en_dev *mdev = endev_ptr;
+	int p;
+
+	down(&mdev->state_sem);
+	mdev->state = DEVICE_DOWN;
+	up(&mdev->state_sem);
+
+	for (p = 1; p <= MLX4_MAX_PORTS; ++p)
+		if (mdev->pndev[p])
+			mlx4_en_destroy_netdev(mdev->pndev[p]);
+
+	flush_workqueue(mdev->workqueue);
+	destroy_workqueue(mdev->workqueue);
+	mlx4_mr_free(dev, &mdev->mr);
+	mlx4_uar_free(dev, &mdev->priv_uar);
+	mlx4_pd_free(dev, mdev->priv_pdn);
+	kfree(mdev);
+}
+
+static void *mlx4_en_add(struct mlx4_dev *dev)
+{
+	static int mlx4_en_version_printed;
+	struct mlx4_en_dev *mdev;
+	int i;
+	int err;
+
+	if (!mlx4_en_version_printed) {
+		printk(KERN_INFO "%s", mlx4_en_version);
+		mlx4_en_version_printed++;
+	}
+
+	mdev = kzalloc(sizeof *mdev, GFP_KERNEL);
+	if (!mdev) {
+		dev_err(&dev->pdev->dev, "Device struct alloc failed, "
+			"aborting.\n");
+		err = -ENOMEM;
+		goto err_free_res;
+	}
+
+	if (mlx4_pd_alloc(dev, &mdev->priv_pdn))
+		goto err_free_dev;
+
+	if (mlx4_uar_alloc(dev, &mdev->priv_uar))
+		goto err_pd;
+
+	mdev->uar_map = ioremap(mdev->priv_uar.pfn << PAGE_SHIFT, PAGE_SIZE);
+	if (!mdev->uar_map)
+		goto err_uar;
+	spin_lock_init(&mdev->uar_lock);
+
+	mdev->dev = dev;
+	mdev->dma_device = &(dev->pdev->dev);
+	mdev->pdev = dev->pdev;
+	mdev->state = DEVICE_DOWN;
+
+	if (mlx4_en_get_dma_mr(mdev, MLX4_EN_ACCESS_LOCAL_WRITE)) {
+		mlx4_err(mdev, "Failed getting dma memory region.\n");
+		goto err_uar;
+	}
+
+	/* Build device profile according to supplied module parameters */
+	err = mlx4_en_get_profile(mdev);
+	if (err) {
+		mlx4_err(mdev, "Bad module parameters, aborting.\n");
+		goto err_mr;
+	}
+
+	/* Configure wich ports to start according to module parameters */
+	mdev->ports_map = mlx4_get_ports_of_type(mdev->dev, MLX4_PORT_TYPE_ETH);
+	mdev->port_cnt = 0;
+	mlx4_foreach_port(i, mdev->ports_map)
+		mdev->port_cnt++;
+
+	/* If we did not receive an explicit number of Rx rings, default to
+	 * the number of completion vectors populated by the mlx4_core */
+	mlx4_foreach_port(i, mdev->ports_map) {
+		mlx4_info(mdev, "Using %d tx rings for port:%d\n",
+			  mdev->profile.prof[i].tx_ring_num, i);
+		if (!mdev->profile.prof[i].rx_ring_num) {
+			mdev->profile.prof[i].rx_ring_num = dev->caps.num_comp_vectors;
+			mlx4_info(mdev, "Defaulting to %d rx rings for port:%d\n",
+				  dev->caps.num_comp_vectors, i);
+		} else
+			mlx4_info(mdev, "Using %d rx rings for port:%d\n",
+				  mdev->profile.prof[i].rx_ring_num, i);
+	}
+
+	/* Create our own workqueue for reset/multicast tasks
+	 * Note: we cannot use the shared workqueue because of deadlocks caused
+	 *       by the rtnl lock */
+	mdev->workqueue = create_singlethread_workqueue("mlx4_en");
+	if (!mdev->workqueue) {
+		err = -ENOMEM;
+		goto err_close_nic;
+	}
+
+	/* At this stage all non-port specific tasks are complete:
+	 * mark the card state as up */
+	sema_init(&mdev->state_sem, 1);
+	mdev->state = DEVICE_UP;
+
+	/* Setup ports */
+
+	/* Create a netdev for each port */
+	mlx4_foreach_port(i, mdev->ports_map) {
+		mlx4_info(mdev, "Activating port:%d\n", i);
+		if (mlx4_en_init_netdev(mdev, i, &mdev->profile.prof[i])) {
+			mdev->pndev[i] = NULL;
+			goto err_free_netdev;
+		}
+	}
+	return mdev;
+
+
+err_free_netdev:
+	for (i = 0; i < dev->caps.num_ports; i++) {
+		if (mdev->pndev[i])
+			mlx4_en_destroy_netdev(mdev->pndev[i]);
+	}
+
+	down(&mdev->state_sem);
+	mdev->state = DEVICE_DOWN;
+	up(&mdev->state_sem);
+	flush_workqueue(mdev->workqueue);
+
+	/* Stop event queue before we drop down to release shared SW state */
+
+err_close_nic:
+	destroy_workqueue(mdev->workqueue);
+err_mr:
+	mlx4_mr_free(dev, &mdev->mr);
+err_uar:
+	mlx4_uar_free(dev, &mdev->priv_uar);
+err_pd:
+	mlx4_pd_free(dev, mdev->priv_pdn);
+err_free_dev:
+	kfree(mdev);
+err_free_res:
+	return NULL;
+}
+
+static struct mlx4_interface mlx4_en_interface = {
+	.add	= mlx4_en_add,
+	.remove	= mlx4_en_remove,
+	.event	= mlx4_en_event
+};
+
+static int __init mlx4_en_init(void)
+{
+	return mlx4_register_interface(&mlx4_en_interface);
+}
+
+static void __exit mlx4_en_cleanup(void)
+{
+	mlx4_unregister_interface(&mlx4_en_interface);
+}
+
+module_init(mlx4_en_init);
+module_exit(mlx4_en_cleanup);
+
-- 
1.5.3.7




