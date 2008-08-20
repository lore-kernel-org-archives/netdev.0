From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [Patch RFC 02/10 v2] mlx4_en: en_main
Date: Wed, 20 Aug 2008 16:00:12 +0300
Message-ID: <48AC155C.7000709@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Liran Liss <liranl@mellanox.co.il>,
	tziporet@mellanox.co.il, Roland Dreier <rdreier@cisco.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:49043 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754080AbYHTNBO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Aug 2008 09:01:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 18 Aug 2008 11:31:36 +0300
Subject: [PATCH] mlx4_en: en_main

This file is responsible for device initialization and its
registration with PCI driver (mlx4_core).
It is responsible to query for number of network devices to be
created and sets the parameters for those devices (such as number
of tx/rx rings)

Signed-off-by: Liran Liss <liranl@mellanox.co.il>
Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_main.c |  255 ++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 255 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/mlx4/en_main.c

diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
new file mode 100644
index 0000000..01f09e4
--- /dev/null
+++ b/drivers/net/mlx4/en_main.c
@@ -0,0 +1,255 @@
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
+		  task rather than changing it here */
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
+	int i;
+
+	mutex_lock(&mdev->state_lock);
+	mdev->device_up = false;
+	mutex_unlock(&mdev->state_lock);
+
+	mlx4_foreach_port(i, mdev->ports_map)
+		if (mdev->pndev[i])
+			mlx4_en_destroy_netdev(mdev->pndev[i]);
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
+	mdev->device_up = false;
+
+	mdev->LSO_support = !!(dev->caps.flags & (1 << 15));
+	if (!mdev->LSO_support)
+		mlx4_warn(mdev, "LSO not supported, please upgrade to later "
+				"FW version to enable LSO\n");
+
+	if (mlx4_mr_alloc(mdev->dev, mdev->priv_pdn, 0, ~0ull,
+			 MLX4_PERM_LOCAL_WRITE |  MLX4_PERM_LOCAL_READ,
+			 0, 0, &mdev->mr)){
+		mlx4_err(mdev, "Failed allocating memory region\n");
+		goto err_uar;
+	}
+	if (mlx4_mr_enable(mdev->dev, &mdev->mr)) {
+		mlx4_err(mdev, "Failed enabling memory region\n");
+		goto err_mr;
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
+	mutex_init(&mdev->state_lock);
+	mdev->device_up = true;
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
+	mlx4_foreach_port(i, mdev->ports_map) {
+		if (mdev->pndev[i])
+			mlx4_en_destroy_netdev(mdev->pndev[i]);
+	}
+
+	mutex_lock(&mdev->state_lock);
+	mdev->device_up = false;
+	mutex_unlock(&mdev->state_lock);
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
1.5.4





>tx_cq[i],
+					priv->prof->tx_ring_size, i, TX);
+		if (err) {
+			mlx4_err(mdev, "Failed to allocate tx CQ\n");
+			goto out;
+		}
+		err = mlx4_en_create_tx_ring(priv, &priv->tx_ring[i],
+					     prof->tx_ring_size, TXBB_SIZE);
+		if (err) {
+			mlx4_err(mdev, "Failed to create tx ring\n");
+			goto out;
+		}
+	}
+
+	/* Create rx Rings */
+	stride = roundup_pow_of_two(sizeof(struct mlx4_en_rx_desc) +
+				    DS_SIZE * MLX4_EN_MAX_RX_FRAGS);
+	for (i = 0; i < prof->rx_ring_num; i++) {
+		err = mlx4_en_create_cq(priv, &priv->rx_cq[i],
+					priv->prof->rx_ring_size, i, RX);
+		if (err) {
+			mlx4_err(mdev, "Failed to allocate rx CQ\n");
+			goto out;
+		}
+		err = mlx4_en_create_rx_ring(priv, &priv->rx_ring[i],
+					     prof->rx_ring_size, stride);
+		if (err) {
+			mlx4_err(mdev, "Failed to create tx ring\n");
+			goto out;
+		}
+	}
+
+	/* Populate Rx default RSS mappings */
+	mlx4_en_set_default_rss_map(mdev, &priv->rss_map, prof->rx_ring_num *
+						RSS_FACTOR, prof->rx_ring_num);
+	/* Allocate page for receive rings */
+	err = mlx4_alloc_hwq_res(mdev->dev, &priv->res,
+				MLX4_EN_PAGE_SIZE, MLX4_EN_PAGE_SIZE);
+	if (err) {
+		mlx4_err(mdev, "Failed to allocate page for rx qps\n");
+		goto out;
+	}
+	priv->allocated = 1;
+
+	/* Populate Tx priority mappings */
+	mlx4_en_set_prio_map(mdev, priv->tx_prio_map, prof->tx_ring_num);
+
+	/*
+	 * Initialize netdev entry points
+	 */
+
+	dev->open = &mlx4_en_open;
+	dev->stop = &mlx4_en_close;
+	dev->hard_start_xmit = &mlx4_en_xmit;
+	dev->get_stats = &mlx4_en_get_stats;
+	dev->set_multicast_list = &mlx4_en_set_multicast;
+	dev->set_mac_address = &mlx4_en_set_mac;
+	dev->change_mtu = &mlx4_en_change_mtu;
+	dev->tx_timeout = &mlx4_en_tx_timeout;
+	dev->watchdog_timeo = MLX4_EN_WATCHDOG_TIMEOUT;
+	dev->vlan_rx_register = mlx4_en_vlan_rx_register;
+	dev->vlan_rx_add_vid = mlx4_en_vlan_rx_add_vid;
+	dev->vlan_rx_kill_vid = mlx4_en_vlan_rx_kill_vid;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = mlx4_en_netpoll;
+#endif
+	SET_ETHTOOL_OPS(dev, &mlx4_en_ethtool_ops);
+
+	/* Set defualt MAC */
+	dev->addr_len = ETH_ALEN;
+	for (i = 0; i < ETH_ALEN; i++)
+		dev->dev_addr[ETH_ALEN - 1 - i] =
+		(u8) (priv->mac >> (8 * i));
+
+	/*
+	 * Set driver features
+	 */
+	dev->features |= NETIF_F_SG;
+	dev->features |= NETIF_F_HW_CSUM;
+	dev->features |= NETIF_F_HIGHDMA;
+	dev->features |= NETIF_F_HW_VLAN_TX |
+			 NETIF_F_HW_VLAN_RX |
+			 NETIF_F_HW_VLAN_FILTER;
+	if (mdev->profile.num_lro)
+		dev->features |= NETIF_F_LRO;
+	if (mdev->LSO_support) {
+		dev->features |= NETIF_F_TSO;
+		dev->features |= NETIF_F_TSO6;
+	}
+
+	mdev->pndev[port] = dev;
+
+	netif_carrier_off(dev);
+	err = register_netdev(dev);
+	if (err) {
+		mlx4_err(mdev, "Netdev registration failed\n");
+		goto out;
+	}
+	priv->registered = 1;
+	queue_delayed_work(mdev->workqueue, &priv->stats_task, STATS_DELAY);
+	return 0;
+
+out:
+	mlx4_en_destroy_netdev(dev);
+	return err;
+}
+
-- 
1.5.4





	}
+	return done;
+}
+
+
+/* Calculate the last offset position that accomodates a full fragment
+ * (assuming fagment size = stride-align) */
+static int mlx4_en_last_alloc_offset(struct mlx4_en_dev *mdev, u16 stride, u16 align)
+{
+	u16 res = MLX4_EN_ALLOC_SIZE % stride;
+	u16 offset = MLX4_EN_ALLOC_SIZE - stride - res + align;
+
+	mlx4_dbg(mdev, "Calculated last offset for stride:%d align:%d res:%d "
+			"offset:%d\n", stride, align, res, offset);
+	return offset;
+}
+
+
+static int frag_sizes[] = {
+	FRAG_SZ0,
+	FRAG_SZ1,
+	FRAG_SZ2,
+	FRAG_SZ3
+};
+
+void mlx4_en_calc_rx_buf(struct net_device *dev)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	struct mlx4_en_dev *mdev = priv->mdev;
+	int eff_mtu = dev->mtu + ETH_HLEN + VLAN_HLEN + ETH_LLC_SNAP_SIZE;
+	int buf_size = 0;
+	int i = 0;
+
+	while (buf_size < eff_mtu) {
+		priv->frag_info[i].frag_size =
+			(eff_mtu > buf_size + frag_sizes[i]) ?
+				frag_sizes[i] : eff_mtu - buf_size;
+		priv->frag_info[i].frag_prefix_size = buf_size;
+		if (!i)	{
+			priv->frag_info[i].frag_align = NET_IP_ALIGN;
+			priv->frag_info[i].frag_stride =
+				ALIGN(frag_sizes[i] + NET_IP_ALIGN, SMP_CACHE_BYTES);
+		} else {
+			priv->frag_info[i].frag_align = 0;
+			priv->frag_info[i].frag_stride =
+				ALIGN(frag_sizes[i], SMP_CACHE_BYTES);
+		}
+		priv->frag_info[i].last_offset = mlx4_en_last_alloc_offset(
+						mdev, priv->frag_info[i].frag_stride,
+						priv->frag_info[i].frag_align);
+		buf_size += priv->frag_info[i].frag_size;
+		i++;
+	}
+
+	priv->num_frags = i;
+	priv->rx_skb_size = eff_mtu;
+	priv->log_rx_info = ROUNDUP_LOG2(i * sizeof(struct skb_frag_struct));
+
+	mlx4_dbg(mdev, "Rx buffer scatter-list (effective-mtu:%d "
+		  "num_frags:%d):\n", eff_mtu, priv->num_frags);
+	for (i = 0; i < priv->num_frags; i++) {
+		mlx4_dbg(mdev, "  frag:%d - size:%d prefix:%d align:%d "
+				"stride:%d last_offset:%d\n", i,
+				priv->frag_info[i].frag_size,
+				priv->frag_info[i].frag_prefix_size,
+				priv->frag_info[i].frag_align,
+				priv->frag_info[i].frag_stride,
+				priv->frag_info[i].last_offset);
+	}
+}
+
+/* RSS related functions */
+
+/* Calculate rss size and map each entry in rss table to rx ring */
+void mlx4_en_set_default_rss_map(struct mlx4_en_dev *mdev,
+				 struct mlx4_en_rss_map *rss_map,
+				 int num_entries, int num_rings)
+{
+	int i;
+
+	rss_map->size = roundup_pow_of_two(num_entries);
+	mlx4_dbg(mdev, "Setting default RSS map of %d entires\n",
+		 rss_map->size);
+
+	for (i = 0; i < rss_map->size; i++) {
+		rss_map->map[i] = i % num_rings;
+		mlx4_dbg(mdev, "Entry %d ---> ring %d\n", i, rss_map->map[i]);
+	}
+}
+
+static void mlx4_en_sqp_event(struct mlx4_qp *qp, enum mlx4_event event)
+{
+    return;
+}
+
+
+static int mlx4_en_config_rss_qp(struct mlx4_en_priv *priv,
+				 int qpn, int srqn, int cqn,
+				 enum mlx4_qp_state *state,
+				 struct mlx4_qp *qp)
+{
+	struct mlx4_en_dev *mdev = priv->mdev;
+	struct mlx4_qp_context *context;
+	int err = 0;
+
+	context = kmalloc(sizeof *context , GFP_KERNEL);
+	if (!context) {
+		mlx4_err(mdev, "Failed to allocate qp context\n");
+		return -ENOMEM;
+	}
+
+	err = mlx4_qp_alloc(mdev->dev, qpn, qp);
+	if (err) {
+		mlx4_err(mdev, "Failed to allocate qp #%d\n", qpn);
+		goto out;
+		return err;
+	}
+	qp->event = mlx4_en_sqp_event;
+
+	memset(context, 0, sizeof *context);
+	mlx4_en_fill_qp_context(priv, 0, 0, 0, 0, qpn, cqn, srqn, context);
+
+	err = mlx4_qp_to_ready(mdev->dev, &priv->res.mtt, context, qp, state);
+	if (err) {
+		mlx4_qp_remove(mdev->dev, qp);
+		mlx4_qp_free(mdev->dev, qp);
+	}
+out:
+	kfree(context);
+	return err;
+}
+
+/* Allocate rx qp's and configure them according to rss map */
+int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
+{
+	struct mlx4_en_dev *mdev = priv->mdev;
+	struct mlx4_en_rss_map *rss_map = &priv->rss_map;
+	struct mlx4_qp_context context;
+	struct mlx4_en_rss_context *rss_context;
+	void *ptr;
+	int rss_xor = mdev->profile.rss_xor;
+	u8 rss_mask = mdev->profile.rss_mask;
+	int i, srqn, qpn, cqn;
+	int err = 0;
+	int good_qps = 0;
+
+	mlx4_dbg(mdev, "Configuring rss steering for port %u\n", priv->port);
+	err = mlx4_qp_reserve_range(mdev->dev, rss_map->size,
+				    rss_map->size, &rss_map->base_qpn);
+	if (err) {
+		mlx4_err(mdev, "Failed reserving %d qps for port %u\n",
+			 rss_map->size, priv->port);
+		return err;
+	}
+
+	for (i = 0; i < rss_map->size; i++) {
+		cqn = priv->rx_ring[rss_map->map[i]].cqn;
+		srqn = priv->rx_ring[rss_map->map[i]].srq.srqn;
+		qpn = rss_map->base_qpn + i;
+		err = mlx4_en_config_rss_qp(priv, qpn, srqn, cqn,
+					    &rss_map->state[i],
+					    &rss_map->qps[i]);
+		if (err)
+			goto rss_err;
+
+		++good_qps;
+	}
+
+	/* Configure RSS indirection qp */
+	err = mlx4_qp_reserve_range(mdev->dev, 1, 1, &priv->base_qpn);
+	if (err) {
+		mlx4_err(mdev, "Failed to reserve range for RSS "
+			       "indirection qp\n");
+		goto rss_err;
+	}
+	err = mlx4_qp_alloc(mdev->dev, priv->base_qpn, &rss_map->indir_qp);
+	if (err) {
+		mlx4_err(mdev, "Failed to allocate RSS indirection QP\n");
+		goto reserve_err;
+	}
+	rss_map->indir_qp.event = mlx4_en_sqp_event;
+	mlx4_en_fill_qp_context(priv, 0, 0, 0, 1, priv->base_qpn,
+				priv->rx_ring[0].cqn, 0, &context);
+
+	ptr = ((void *) &context) + 0x3c;
+	rss_context = (struct mlx4_en_rss_context *) ptr;
+	rss_context->base_qpn = cpu_to_be32(ilog2(rss_map->size) << 24 |
+					    (rss_map->base_qpn));
+	rss_context->default_qpn = cpu_to_be32(rss_map->base_qpn);
+	rss_context->hash_fn = rss_xor & 0x3;
+	rss_context->flags = rss_mask << 2;
+
+	err = mlx4_qp_to_ready(mdev->dev, &priv->res.mtt, &context,
+			       &rss_map->indir_qp, &rss_map->indir_state);
+	if (err)
+		goto indir_err;
+
+	return 0;
+
+indir_err:
+	mlx4_qp_modify(mdev->dev, NULL, rss_map->indir_state,
+		       MLX4_QP_STATE_RST, NULL, 0, 0, &rss_map->indir_qp);
+	mlx4_qp_remove(mdev->dev, &rss_map->indir_qp);
+	mlx4_qp_free(mdev->dev, &rss_map->indir_qp);
+reserve_err:
+	mlx4_qp_release_range(mdev->dev, priv->base_qpn, 1);
+rss_err:
+	for (i = 0; i < good_qps; i++) {
+		mlx4_qp_modify(mdev->dev, NULL, rss_map->state[i],
+			       MLX4_QP_STATE_RST, NULL, 0, 0, &rss_map->qps[i]);
+		mlx4_qp_remove(mdev->dev, &rss_map->qps[i]);
+		mlx4_qp_free(mdev->dev, &rss_map->qps[i]);
+	}
+	mlx4_qp_release_range(mdev->dev, rss_map->base_qpn, rss_map->size);
+	return err;
+}
+
+void mlx4_en_release_rss_steer(struct mlx4_en_priv *priv)
+{
+	struct mlx4_en_dev *mdev = priv->mdev;
+	struct mlx4_en_rss_map *rss_map = &priv->rss_map;
+	int i;
+
+	mlx4_qp_modify(mdev->dev, NULL, rss_map->indir_state,
+		       MLX4_QP_STATE_RST, NULL, 0, 0, &rss_map->indir_qp);
+	mlx4_qp_remove(mdev->dev, &rss_map->indir_qp);
+	mlx4_qp_free(mdev->dev, &rss_map->indir_qp);
+	mlx4_qp_release_range(mdev->dev, priv->base_qpn, 1);
+
+	for (i = 0; i < rss_map->size; i++) {
+		mlx4_qp_modify(mdev->dev, NULL, rss_map->state[i],
+			       MLX4_QP_STATE_RST, NULL, 0, 0, &rss_map->qps[i]);
+		mlx4_qp_remove(mdev->dev, &rss_map->qps[i]);
+		mlx4_qp_free(mdev->dev, &rss_map->qps[i]);
+	}
+	mlx4_qp_release_range(mdev->dev, rss_map->base_qpn, rss_map->size);
+}
+
+
+
+
+
-- 
1.5.4





