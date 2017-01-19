From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Subject: [PATCH v6 05/13] net: ethernet: aquantia: Support for NIC-specific code
Date: Wed, 18 Jan 2017 17:07:56 -0800
Message-ID: <f7bb4fb637954df95e5a926e25bc9235ab4c6b71.1484788010.git.vomlehn@texas.net>
References: <cover.1484788010.git.vomlehn@texas.net>
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda6.aus1.datafoundry.com ([209.99.124.137]:53291 "EHLO
        milter.aus.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751421AbdASBKY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 20:10:24 -0500
In-Reply-To: <cover.1484788010.git.vomlehn@texas.net>
In-Reply-To: <cover.1484788010.git.vomlehn@texas.net>
References: <cover.1484788010.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David VomLehn <vomlehn@texas.net>

Add support for code specific to the Atlantic NIC.

Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
Signed-off-by: Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
Signed-off-by: David M. VomLehn <vomlehn@texas.net>
---
 drivers/net/ethernet/aquantia/atlantic/aq_main.c   | 273 ++++++
 drivers/net/ethernet/aquantia/atlantic/aq_main.h   |  17 +
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c    | 935 +++++++++++++++++++++
 drivers/net/ethernet/aquantia/atlantic/aq_nic.h    | 108 +++
 .../ethernet/aquantia/atlantic/aq_nic_internal.h   |  46 +
 5 files changed, 1379 insertions(+)
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_main.c
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_main.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_nic.c
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_nic.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_nic_internal.h

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_main.c b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
new file mode 100644
index 0000000..c17c70a
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
@@ -0,0 +1,273 @@
+/*
+ * aQuantia Corporation Network Driver
+ * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/* File aq_main.c: Main file for aQuantia Linux driver. */
+
+#include "aq_main.h"
+#include "aq_nic.h"
+#include "aq_pci_func.h"
+#include "aq_ethtool.h"
+#include "hw_atl/hw_atl_a0.h"
+#include "hw_atl/hw_atl_b0.h"
+
+#include <linux/netdevice.h>
+#include <linux/module.h>
+
+static const struct pci_device_id aq_pci_tbl[] = {
+	{ PCI_VDEVICE(AQUANTIA, HW_ATL_DEVICE_ID_0001), },
+	{ PCI_VDEVICE(AQUANTIA, HW_ATL_DEVICE_ID_D100), },
+	{ PCI_VDEVICE(AQUANTIA, HW_ATL_DEVICE_ID_D107), },
+	{ PCI_VDEVICE(AQUANTIA, HW_ATL_DEVICE_ID_D108), },
+	{ PCI_VDEVICE(AQUANTIA, HW_ATL_DEVICE_ID_D109), },
+	{}
+};
+
+MODULE_DEVICE_TABLE(pci, aq_pci_tbl);
+
+MODULE_LICENSE("GPL v2");
+MODULE_VERSION(AQ_CFG_DRV_VERSION);
+MODULE_AUTHOR(AQ_CFG_DRV_AUTHOR);
+MODULE_DESCRIPTION(AQ_CFG_DRV_DESC);
+
+static struct aq_hw_ops *aq_pci_probe_get_hw_ops_by_id(struct pci_dev *pdev)
+{
+	struct aq_hw_ops *ops = NULL;
+
+	ops = hw_atl_a0_get_ops_by_id(pdev);
+	if (!ops)
+		ops = hw_atl_b0_get_ops_by_id(pdev);
+
+	return ops;
+}
+
+static int aq_ndev_open(struct net_device *ndev)
+{
+	struct aq_nic_s *aq_nic = NULL;
+	int err = 0;
+
+	aq_nic = aq_nic_alloc_hot(ndev);
+	if (!aq_nic) {
+		err = -ENOMEM;
+		goto err_exit;
+	}
+	err = aq_nic_init(aq_nic);
+	if (err < 0)
+		goto err_exit;
+	err = aq_nic_start(aq_nic);
+	if (err < 0)
+		goto err_exit;
+
+err_exit:
+	if (err < 0)
+		aq_nic_deinit(aq_nic);
+	return err;
+}
+
+static int aq_ndev_close(struct net_device *ndev)
+{
+	int err = 0;
+	struct aq_nic_s *aq_nic = netdev_priv(ndev);
+
+	err = aq_nic_stop(aq_nic);
+	if (err < 0)
+		goto err_exit;
+	aq_nic_deinit(aq_nic);
+	aq_nic_free_hot_resources(aq_nic);
+
+err_exit:
+	return err;
+}
+
+static int aq_ndev_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct aq_nic_s *aq_nic = netdev_priv(ndev);
+	int err = 0;
+
+	err = aq_nic_xmit(aq_nic, skb);
+	if (err < 0)
+		goto err_exit;
+
+err_exit:
+	return err;
+}
+
+static int aq_ndev_change_mtu(struct net_device *ndev, int new_mtu)
+{
+	struct aq_nic_s *aq_nic = netdev_priv(ndev);
+	int err = 0;
+
+	if (new_mtu == ndev->mtu) {
+		err = 0;
+		goto err_exit;
+	}
+	if (new_mtu < 68) {
+		err = -EINVAL;
+		goto err_exit;
+	}
+	err = aq_nic_set_mtu(aq_nic, new_mtu + ETH_HLEN);
+	if (err < 0)
+		goto err_exit;
+	ndev->mtu = new_mtu;
+
+	if (netif_running(ndev)) {
+		aq_ndev_close(ndev);
+		aq_ndev_open(ndev);
+	}
+
+err_exit:
+	return err;
+}
+
+static int aq_ndev_set_features(struct net_device *ndev,
+				netdev_features_t features)
+{
+	struct aq_nic_s *aq_nic = netdev_priv(ndev);
+	struct aq_nic_cfg_s *aq_cfg = aq_nic_get_cfg(aq_nic);
+	bool is_lro = false;
+
+	if (aq_cfg->hw_features & NETIF_F_LRO) {
+		is_lro = features & NETIF_F_LRO;
+
+		if (aq_cfg->is_lro != is_lro) {
+			aq_cfg->is_lro = is_lro;
+
+			if (netif_running(ndev)) {
+				aq_ndev_close(ndev);
+				aq_ndev_open(ndev);
+			}
+		}
+	}
+
+	return 0;
+}
+
+static int aq_ndev_set_mac_address(struct net_device *ndev, void *addr)
+{
+	struct aq_nic_s *aq_nic = netdev_priv(ndev);
+	int err = 0;
+
+	err = eth_mac_addr(ndev, addr);
+	if (err < 0)
+		goto err_exit;
+	err = aq_nic_set_mac(aq_nic, ndev);
+	if (err < 0)
+		goto err_exit;
+
+err_exit:
+	return err;
+}
+
+static void aq_ndev_set_multicast_settings(struct net_device *ndev)
+{
+	struct aq_nic_s *aq_nic = netdev_priv(ndev);
+	int err = 0;
+
+	err = aq_nic_set_packet_filter(aq_nic, ndev->flags);
+	if (err < 0)
+		goto err_exit;
+
+	if (netdev_mc_count(ndev)) {
+		err = aq_nic_set_multicast_list(aq_nic, ndev);
+		if (err < 0)
+			goto err_exit;
+	}
+
+err_exit:;
+}
+
+static const struct net_device_ops aq_ndev_ops = {
+	.ndo_open = aq_ndev_open,
+	.ndo_stop = aq_ndev_close,
+	.ndo_start_xmit = aq_ndev_start_xmit,
+	.ndo_set_rx_mode = aq_ndev_set_multicast_settings,
+	.ndo_change_mtu = aq_ndev_change_mtu,
+	.ndo_set_mac_address = aq_ndev_set_mac_address,
+	.ndo_set_features = aq_ndev_set_features
+};
+
+static int aq_pci_probe(struct pci_dev *pdev,
+			const struct pci_device_id *pci_id)
+{
+	struct aq_hw_ops *aq_hw_ops = NULL;
+	struct aq_pci_func_s *aq_pci_func = NULL;
+	int err = 0;
+
+	err = pci_enable_device(pdev);
+	if (err < 0)
+		goto err_exit;
+	aq_hw_ops = aq_pci_probe_get_hw_ops_by_id(pdev);
+	aq_pci_func = aq_pci_func_alloc(aq_hw_ops, pdev,
+					&aq_ndev_ops, &aq_ethtool_ops);
+	if (!aq_pci_func) {
+		err = -ENOMEM;
+		goto err_exit;
+	}
+	err = aq_pci_func_init(aq_pci_func);
+	if (err < 0)
+		goto err_exit;
+
+err_exit:
+	if (err < 0) {
+		if (aq_pci_func)
+			aq_pci_func_free(aq_pci_func);
+	}
+	return err;
+}
+
+static void aq_pci_remove(struct pci_dev *pdev)
+{
+	struct aq_pci_func_s *aq_pci_func = pci_get_drvdata(pdev);
+
+	aq_pci_func_deinit(aq_pci_func);
+	aq_pci_func_free(aq_pci_func);
+}
+
+static int aq_pci_suspend(struct pci_dev *pdev, pm_message_t pm_msg)
+{
+	struct aq_pci_func_s *aq_pci_func = pci_get_drvdata(pdev);
+
+	return aq_pci_func_change_pm_state(aq_pci_func, &pm_msg);
+}
+
+static int aq_pci_resume(struct pci_dev *pdev)
+{
+	struct aq_pci_func_s *aq_pci_func = pci_get_drvdata(pdev);
+	pm_message_t pm_msg = PMSG_RESTORE;
+
+	return aq_pci_func_change_pm_state(aq_pci_func, &pm_msg);
+}
+
+static struct pci_driver aq_pci_ops = {
+	.name = AQ_CFG_DRV_NAME,
+	.id_table = aq_pci_tbl,
+	.probe = aq_pci_probe,
+	.remove = aq_pci_remove,
+	.suspend = aq_pci_suspend,
+	.resume = aq_pci_resume,
+};
+
+static int __init aq_module_init(void)
+{
+	int err = 0;
+
+	err = pci_register_driver(&aq_pci_ops);
+	if (err < 0)
+		goto err_exit;
+
+err_exit:
+	return err;
+}
+
+static void __exit aq_module_exit(void)
+{
+	pci_unregister_driver(&aq_pci_ops);
+}
+
+module_init(aq_module_init);
+module_exit(aq_module_exit);
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_main.h b/drivers/net/ethernet/aquantia/atlantic/aq_main.h
new file mode 100644
index 0000000..9748e7e
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_main.h
@@ -0,0 +1,17 @@
+/*
+ * aQuantia Corporation Network Driver
+ * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/* File aq_main.h: Main file for aQuantia Linux driver. */
+
+#ifndef AQ_MAIN_H
+#define AQ_MAIN_H
+
+#include "aq_common.h"
+
+#endif /* AQ_MAIN_H */
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
new file mode 100644
index 0000000..2ee810f
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -0,0 +1,935 @@
+/*
+ * aQuantia Corporation Network Driver
+ * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/* File aq_nic.c: Definition of common code for NIC. */
+
+#include "aq_nic.h"
+#include "aq_ring.h"
+#include "aq_vec.h"
+#include "aq_hw.h"
+#include "aq_pci_func.h"
+#include "aq_nic_internal.h"
+
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/timer.h>
+#include <linux/cpu.h>
+#include <linux/ip.h>
+#include <linux/tcp.h>
+#include <net/ip.h>
+
+static void aq_nic_rss_init(struct aq_nic_s *self, unsigned int num_rss_queues)
+{
+	struct aq_nic_cfg_s *cfg = &self->aq_nic_cfg;
+	struct aq_rss_parameters *rss_params = &cfg->aq_rss;
+	int i = 0;
+
+	static u8 rss_key[40] = {
+		0x1e, 0xad, 0x71, 0x87, 0x65, 0xfc, 0x26, 0x7d,
+		0x0d, 0x45, 0x67, 0x74, 0xcd, 0x06, 0x1a, 0x18,
+		0xb6, 0xc1, 0xf0, 0xc7, 0xbb, 0x18, 0xbe, 0xf8,
+		0x19, 0x13, 0x4b, 0xa9, 0xd0, 0x3e, 0xfe, 0x70,
+		0x25, 0x03, 0xab, 0x50, 0x6a, 0x8b, 0x82, 0x0c
+	};
+
+	rss_params->hash_secret_key_size = sizeof(rss_key);
+	memcpy(rss_params->hash_secret_key, rss_key, sizeof(rss_key));
+	rss_params->indirection_table_size = AQ_CFG_RSS_INDIRECTION_TABLE_MAX;
+
+	for (i = rss_params->indirection_table_size; i--;)
+		rss_params->indirection_table[i] = i & (num_rss_queues - 1);
+}
+
+/* Fills aq_nic_cfg with valid defaults */
+static void aq_nic_cfg_init_defaults(struct aq_nic_s *self)
+{
+	struct aq_nic_cfg_s *cfg = &self->aq_nic_cfg;
+
+	cfg->aq_hw_caps = &self->aq_hw_caps;
+
+	cfg->vecs = AQ_CFG_VECS_DEF;
+	cfg->tcs = AQ_CFG_TCS_DEF;
+
+	cfg->rxds = AQ_CFG_RXDS_DEF;
+	cfg->txds = AQ_CFG_TXDS_DEF;
+
+	cfg->is_polling = AQ_CFG_IS_POLLING_DEF;
+
+	cfg->is_interrupt_moderation = AQ_CFG_IS_INTERRUPT_MODERATION_DEF;
+	cfg->itr = cfg->is_interrupt_moderation ?
+		AQ_CFG_INTERRUPT_MODERATION_RATE_DEF : 0U;
+
+	cfg->is_rss = AQ_CFG_IS_RSS_DEF;
+	cfg->num_rss_queues = AQ_CFG_NUM_RSS_QUEUES_DEF;
+	cfg->aq_rss.base_cpu_number = AQ_CFG_RSS_BASE_CPU_NUM_DEF;
+	cfg->flow_control = AQ_CFG_FC_MODE;
+
+	cfg->mtu = AQ_CFG_MTU_DEF;
+	cfg->link_speed_msk = AQ_CFG_SPEED_MSK;
+	cfg->is_autoneg = AQ_CFG_IS_AUTONEG_DEF;
+
+	cfg->is_lro = AQ_CFG_IS_LRO_DEF;
+
+	cfg->vlan_id = 0U;
+
+	aq_nic_rss_init(self, cfg->num_rss_queues);
+}
+
+/* Checks hw_caps and 'corrects' aq_nic_cfg in runtime */
+int aq_nic_cfg_start(struct aq_nic_s *self)
+{
+	struct aq_nic_cfg_s *cfg = &self->aq_nic_cfg;
+
+	/*descriptors */
+	cfg->rxds = min(cfg->rxds, cfg->aq_hw_caps->rxds);
+	cfg->txds = min(cfg->txds, cfg->aq_hw_caps->txds);
+
+	/*rss rings */
+	cfg->vecs = min(cfg->vecs, cfg->aq_hw_caps->vecs);
+	cfg->vecs = min(cfg->vecs, num_online_cpus());
+	/* cfg->vecs should be power of 2 for RSS */
+	if (cfg->vecs >= 8U)
+		cfg->vecs = 8U;
+	else if (cfg->vecs >= 4U)
+		cfg->vecs = 4U;
+	else if (cfg->vecs >= 2U)
+		cfg->vecs = 2U;
+	else
+		cfg->vecs = 1U;
+
+	cfg->irq_type = aq_pci_func_get_irq_type(self->aq_pci_func);
+
+	if ((cfg->irq_type == AQ_IRQ_LEGACY) ||
+	    (self->aq_hw_caps.vecs == 1U) ||
+	    (cfg->vecs == 1U)) {
+		cfg->is_rss = 0U;
+		cfg->vecs = 1U;
+	}
+
+	cfg->link_speed_msk &= self->aq_hw_caps.link_speed_msk;
+	cfg->hw_features = self->aq_hw_caps.hw_features;
+	return 0;
+}
+
+static void aq_nic_service_timer_cb(unsigned long param)
+{
+	struct aq_nic_s *self = (struct aq_nic_s *)param;
+	struct net_device *ndev = aq_nic_get_ndev(self);
+	int err = 0;
+	bool is_busy = false;
+	unsigned int i = 0U;
+	struct aq_hw_link_status_s link_status;
+	struct aq_ring_stats_rx_s stats_rx;
+	struct aq_ring_stats_tx_s stats_tx;
+
+	atomic_inc(&self->header.busy_count);
+	is_busy = true;
+	if (aq_utils_obj_test(&self->header.flags, AQ_NIC_FLAGS_IS_NOT_READY))
+		goto err_exit;
+
+	err = self->aq_hw_ops.hw_get_link_status(self->aq_hw, &link_status);
+	if (err < 0)
+		goto err_exit;
+
+	self->aq_hw_ops.hw_interrupt_moderation_set(self->aq_hw,
+			    self->aq_nic_cfg.is_interrupt_moderation);
+
+	if (memcmp(&link_status, &self->link_status, sizeof(link_status))) {
+		if (link_status.mbps) {
+			aq_utils_obj_set(&self->header.flags,
+					 AQ_NIC_FLAG_STARTED);
+			aq_utils_obj_clear(&self->header.flags,
+					   AQ_NIC_LINK_DOWN);
+			netif_carrier_on(self->ndev);
+		} else {
+			netif_carrier_off(self->ndev);
+			aq_utils_obj_set(&self->header.flags, AQ_NIC_LINK_DOWN);
+		}
+
+		self->link_status = link_status;
+	}
+
+	memset(&stats_rx, 0U, sizeof(struct aq_ring_stats_rx_s));
+	memset(&stats_tx, 0U, sizeof(struct aq_ring_stats_tx_s));
+	for (i = AQ_DIMOF(self->aq_vec); i--;) {
+		if (self->aq_vec[i])
+			aq_vec_add_stats(self->aq_vec[i], &stats_rx, &stats_tx);
+	}
+
+	ndev->stats.rx_packets = stats_rx.packets;
+	ndev->stats.rx_bytes = stats_rx.bytes;
+	ndev->stats.rx_errors = stats_rx.errors;
+	ndev->stats.tx_packets = stats_tx.packets;
+	ndev->stats.tx_bytes = stats_tx.bytes;
+	ndev->stats.tx_errors = stats_tx.errors;
+
+err_exit:
+	if (is_busy)
+		atomic_dec(&self->header.busy_count);
+	mod_timer(&self->service_timer,
+		  jiffies + AQ_CFG_SERVICE_TIMER_INTERVAL);
+}
+
+static void aq_nic_polling_timer_cb(unsigned long param)
+{
+	struct aq_nic_s *self = (struct aq_nic_s *)param;
+	struct aq_vec_s *aq_vec = NULL;
+	unsigned int i = 0U;
+
+	for (i = 0U, aq_vec = self->aq_vec[0];
+		self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i])
+		aq_vec_isr(i, (void *)aq_vec);
+
+	mod_timer(&self->polling_timer, jiffies +
+		AQ_CFG_POLLING_TIMER_INTERVAL);
+}
+
+static struct net_device *aq_nic_ndev_alloc(void)
+{
+	return alloc_etherdev_mq(sizeof(struct aq_nic_s), AQ_CFG_VECS_MAX);
+}
+
+struct aq_nic_s *aq_nic_alloc_cold(const struct net_device_ops *ndev_ops,
+				   const struct ethtool_ops *et_ops,
+				   struct device *dev,
+				   struct aq_pci_func_s *aq_pci_func,
+				   unsigned int port,
+				   const struct aq_hw_ops *aq_hw_ops)
+{
+	struct net_device *ndev = NULL;
+	struct aq_nic_s *self = NULL;
+	int err = 0;
+
+	ndev = aq_nic_ndev_alloc();
+	self = netdev_priv(ndev);
+	if (!self) {
+		err = -EINVAL;
+		goto err_exit;
+	}
+
+	ndev->netdev_ops = ndev_ops;
+	ndev->ethtool_ops = et_ops;
+
+	SET_NETDEV_DEV(ndev, dev);
+
+	ndev->if_port = port;
+	self->ndev = ndev;
+
+	self->aq_pci_func = aq_pci_func;
+
+	self->aq_hw_ops = *aq_hw_ops;
+	self->port = (u8)port;
+
+	self->aq_hw = self->aq_hw_ops.create(aq_pci_func, self->port,
+						&self->aq_hw_ops);
+	err = self->aq_hw_ops.get_hw_caps(self->aq_hw, &self->aq_hw_caps);
+	if (err < 0)
+		goto err_exit;
+
+	aq_nic_cfg_init_defaults(self);
+
+err_exit:
+	if (err < 0) {
+		aq_nic_free_hot_resources(self);
+		self = NULL;
+	}
+	return self;
+}
+
+int aq_nic_ndev_register(struct aq_nic_s *self)
+{
+	int err = 0;
+	unsigned int i = 0U;
+
+	if (!self->ndev) {
+		err = -EINVAL;
+		goto err_exit;
+	}
+	err = self->aq_hw_ops.hw_get_mac_permanent(self->aq_hw,
+			    self->aq_nic_cfg.aq_hw_caps,
+			    self->ndev->dev_addr);
+	if (err < 0)
+		goto err_exit;
+
+#if defined(AQ_CFG_MAC_ADDR_PERMANENT)
+	{
+		static u8 mac_addr_permanent[] = AQ_CFG_MAC_ADDR_PERMANENT;
+
+		ether_addr_copy(self->ndev->dev_addr, mac_addr_permanent);
+	}
+#endif
+	err = register_netdev(self->ndev);
+	if (err < 0)
+		goto err_exit;
+
+	self->is_ndev_registered = true;
+	netif_carrier_off(self->ndev);
+
+	for (i = AQ_CFG_VECS_MAX; i--;)
+		aq_nic_ndev_queue_stop(self, i);
+
+err_exit:
+	return err;
+}
+
+int aq_nic_ndev_init(struct aq_nic_s *self)
+{
+	struct aq_hw_caps_s *aq_hw_caps = self->aq_nic_cfg.aq_hw_caps;
+	struct aq_nic_cfg_s *aq_nic_cfg = &self->aq_nic_cfg;
+
+	self->ndev->hw_features |= aq_hw_caps->hw_features;
+	self->ndev->features = aq_hw_caps->hw_features;
+	self->ndev->priv_flags = aq_hw_caps->hw_priv_flags;
+	self->ndev->mtu = aq_nic_cfg->mtu - ETH_HLEN;
+
+	return 0;
+}
+
+void aq_nic_ndev_free(struct aq_nic_s *self)
+{
+	if (!self->ndev)
+		goto err_exit;
+
+	if (self->is_ndev_registered)
+		unregister_netdev(self->ndev);
+
+	if (self->aq_hw)
+		self->aq_hw_ops.destroy(self->aq_hw);
+
+	free_netdev(self->ndev);
+
+err_exit:;
+}
+
+struct aq_nic_s *aq_nic_alloc_hot(struct net_device *ndev)
+{
+	struct aq_nic_s *self = NULL;
+	int err = 0;
+
+	if (!ndev) {
+		err = -EINVAL;
+		goto err_exit;
+	}
+	self = netdev_priv(ndev);
+
+	if (!self) {
+		err = -EINVAL;
+		goto err_exit;
+	}
+	if (netif_running(ndev)) {
+		unsigned int i;
+
+		for (i = AQ_CFG_VECS_MAX; i--;)
+			netif_stop_subqueue(ndev, i);
+	}
+
+	for (self->aq_vecs = 0; self->aq_vecs < self->aq_nic_cfg.vecs;
+		self->aq_vecs++) {
+		self->aq_vec[self->aq_vecs] =
+		    aq_vec_alloc(self, self->aq_vecs, &self->aq_nic_cfg);
+		if (!self->aq_vec[self->aq_vecs]) {
+			err = -ENOMEM;
+			goto err_exit;
+		}
+	}
+
+err_exit:
+	if (err < 0) {
+		aq_nic_free_hot_resources(self);
+		self = NULL;
+	}
+	return self;
+}
+
+void aq_nic_set_tx_ring(struct aq_nic_s *self, unsigned int idx,
+			struct aq_ring_s *ring)
+{
+	self->aq_ring_tx[idx] = ring;
+}
+
+struct device *aq_nic_get_dev(struct aq_nic_s *self)
+{
+	return self->ndev->dev.parent;
+}
+
+struct net_device *aq_nic_get_ndev(struct aq_nic_s *self)
+{
+	return self->ndev;
+}
+
+int aq_nic_init(struct aq_nic_s *self)
+{
+	struct aq_vec_s *aq_vec = NULL;
+	int err = 0;
+	unsigned int i = 0U;
+
+	self->power_state = AQ_HW_POWER_STATE_D0;
+	err = self->aq_hw_ops.hw_reset(self->aq_hw);
+	if (err < 0)
+		goto err_exit;
+
+	err = self->aq_hw_ops.hw_init(self->aq_hw, &self->aq_nic_cfg,
+			    aq_nic_get_ndev(self)->dev_addr);
+	if (err < 0)
+		goto err_exit;
+
+	for (i = 0U, aq_vec = self->aq_vec[0];
+		self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i])
+		aq_vec_init(aq_vec, &self->aq_hw_ops, self->aq_hw);
+
+err_exit:
+	return err;
+}
+
+void aq_nic_ndev_queue_start(struct aq_nic_s *self, unsigned int idx)
+{
+	netif_start_subqueue(self->ndev, idx);
+}
+
+void aq_nic_ndev_queue_stop(struct aq_nic_s *self, unsigned int idx)
+{
+	netif_stop_subqueue(self->ndev, idx);
+}
+
+int aq_nic_start(struct aq_nic_s *self)
+{
+	struct aq_vec_s *aq_vec = NULL;
+	int err = 0;
+	unsigned int i = 0U;
+
+	err = self->aq_hw_ops.hw_multicast_list_set(self->aq_hw,
+						    self->mc_list.ar,
+						    self->mc_list.count);
+	if (err < 0)
+		goto err_exit;
+
+	err = self->aq_hw_ops.hw_packet_filter_set(self->aq_hw,
+						   self->packet_filter);
+	if (err < 0)
+		goto err_exit;
+
+	for (i = 0U, aq_vec = self->aq_vec[0];
+		self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i]) {
+		err = aq_vec_start(aq_vec);
+		if (err < 0)
+			goto err_exit;
+	}
+
+	err = self->aq_hw_ops.hw_start(self->aq_hw);
+	if (err < 0)
+		goto err_exit;
+
+	err = self->aq_hw_ops.hw_interrupt_moderation_set(self->aq_hw,
+			    self->aq_nic_cfg.is_interrupt_moderation);
+	if (err < 0)
+		goto err_exit;
+	setup_timer(&self->service_timer, &aq_nic_service_timer_cb,
+		    (unsigned long)self);
+	mod_timer(&self->service_timer, jiffies +
+			AQ_CFG_SERVICE_TIMER_INTERVAL);
+
+	if (self->aq_nic_cfg.is_polling) {
+		setup_timer(&self->polling_timer, &aq_nic_polling_timer_cb,
+			    (unsigned long)self);
+		mod_timer(&self->polling_timer, jiffies +
+			  AQ_CFG_POLLING_TIMER_INTERVAL);
+	} else {
+		for (i = 0U, aq_vec = self->aq_vec[0];
+			self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i]) {
+			err = aq_pci_func_alloc_irq(self->aq_pci_func, i,
+						    self->ndev->name, aq_vec,
+					aq_vec_get_affinity_mask(aq_vec));
+			if (err < 0)
+				goto err_exit;
+		}
+
+		err = self->aq_hw_ops.hw_irq_enable(self->aq_hw,
+				    AQ_CFG_IRQ_MASK);
+		if (err < 0)
+			goto err_exit;
+	}
+
+	for (i = 0U, aq_vec = self->aq_vec[0];
+		self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i])
+		aq_nic_ndev_queue_start(self, i);
+
+	err = netif_set_real_num_tx_queues(self->ndev, self->aq_vecs);
+	if (err < 0)
+		goto err_exit;
+
+	err = netif_set_real_num_rx_queues(self->ndev, self->aq_vecs);
+	if (err < 0)
+		goto err_exit;
+
+err_exit:
+	return err;
+}
+
+static unsigned int aq_nic_map_skb_frag(struct aq_nic_s *self,
+					struct sk_buff *skb,
+					struct aq_ring_buff_s *dx)
+{
+	unsigned int ret = 0U;
+	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
+	unsigned int frag_count = 0U;
+
+	dx->flags = 0U;
+	dx->len = skb_headlen(skb);
+	dx->pa = dma_map_single(aq_nic_get_dev(self), skb->data, dx->len,
+				DMA_TO_DEVICE);
+	dx->len_pkt = skb->len;
+	dx->is_sop = 1U;
+	dx->is_mapped = 1U;
+
+	++ret;
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		dx->is_ip_cso = (htons(ETH_P_IP) == skb->protocol) ? 1U : 0U;
+		dx->is_tcp_cso =
+			(ip_hdr(skb)->protocol == IPPROTO_TCP) ? 1U : 0U;
+		dx->is_udp_cso =
+			(ip_hdr(skb)->protocol == IPPROTO_UDP) ? 1U : 0U;
+	}
+
+	for (; nr_frags--; ++frag_count) {
+		unsigned int frag_len;
+		dma_addr_t frag_pa;
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[frag_count];
+
+		frag_len = skb_frag_size(frag);
+
+		frag_pa = skb_frag_dma_map(aq_nic_get_dev(self), frag, 0,
+					   frag_len, DMA_TO_DEVICE);
+
+		while (frag_len > AQ_CFG_TX_FRAME_MAX) {
+			++dx;
+			++ret;
+			dx->flags = 0U;
+			dx->len = AQ_CFG_TX_FRAME_MAX;
+			dx->pa = frag_pa;
+			dx->is_mapped = 1U;
+
+			frag_len -= AQ_CFG_TX_FRAME_MAX;
+			frag_pa += AQ_CFG_TX_FRAME_MAX;
+		}
+
+		++dx;
+		++ret;
+
+		dx->flags = 0U;
+		dx->len = frag_len;
+		dx->pa = frag_pa;
+		dx->is_mapped = 1U;
+	}
+
+	dx->is_eop = 1U;
+	dx->skb = skb;
+
+	return ret;
+}
+
+static unsigned int aq_nic_map_skb_lso(struct aq_nic_s *self,
+				       struct sk_buff *skb,
+				       struct aq_ring_buff_s *dx)
+{
+	dx->flags = 0U;
+	dx->len_pkt = skb->len;
+	dx->len_l2 = ETH_HLEN;
+	dx->len_l3 = ip_hdrlen(skb);
+	dx->len_l4 = tcp_hdrlen(skb);
+	dx->mss = skb_shinfo(skb)->gso_size;
+	dx->is_txc = 1U;
+	return 1U;
+}
+
+static unsigned int aq_nic_map_skb(struct aq_nic_s *self, struct sk_buff *skb,
+				   struct aq_ring_buff_s *dx)
+{
+	unsigned int ret = 0U;
+
+	if (unlikely(skb_is_gso(skb))) {
+		ret = aq_nic_map_skb_lso(self, skb, dx);
+		++dx;
+	}
+
+	ret += aq_nic_map_skb_frag(self, skb, dx);
+
+	return ret;
+}
+
+int aq_nic_xmit(struct aq_nic_s *self, struct sk_buff *skb)
+__releases(&ring->lock)
+__acquires(&ring->lock)
+{
+	struct aq_ring_s *ring = NULL;
+	unsigned int frags = 0U;
+	unsigned int vec = skb->queue_mapping % self->aq_nic_cfg.vecs;
+	unsigned int tc = 0U;
+	unsigned int trys = AQ_CFG_LOCK_TRYS;
+	int err = 0;
+	bool is_nic_in_bad_state;
+	bool is_busy = false;
+	struct aq_ring_buff_s buffers[AQ_CFG_SKB_FRAGS_MAX];
+
+	frags = skb_shinfo(skb)->nr_frags + 1;
+
+	ring = self->aq_ring_tx[AQ_NIC_TCVEC2RING(self, tc, vec)];
+
+	atomic_inc(&self->header.busy_count);
+	is_busy = true;
+
+	if (frags > AQ_CFG_SKB_FRAGS_MAX) {
+		dev_kfree_skb_any(skb);
+		goto err_exit;
+	}
+
+	is_nic_in_bad_state = aq_utils_obj_test(&self->header.flags,
+						AQ_NIC_FLAGS_IS_NOT_TX_READY) ||
+						(aq_ring_avail_dx(ring) <
+						AQ_CFG_SKB_FRAGS_MAX);
+
+	if (is_nic_in_bad_state) {
+		aq_nic_ndev_queue_stop(self, ring->idx);
+		err = NETDEV_TX_BUSY;
+		goto err_exit;
+	}
+
+	do {
+		if (spin_trylock(&ring->header.lock)) {
+			frags = aq_nic_map_skb(self, skb, &buffers[0]);
+
+			aq_ring_tx_append_buffs(ring, &buffers[0], frags);
+
+			err = self->aq_hw_ops.hw_ring_tx_xmit(self->aq_hw,
+							      ring, frags);
+			if (err >= 0) {
+				if (aq_ring_avail_dx(ring) <
+				    AQ_CFG_SKB_FRAGS_MAX + 1)
+					aq_nic_ndev_queue_stop(self, ring->idx);
+			}
+			spin_unlock(&ring->header.lock);
+
+			if (err >= 0) {
+				++ring->stats.tx.packets;
+				ring->stats.tx.bytes += skb->len;
+			}
+			break;
+		}
+	} while (--trys);
+
+	if (!trys) {
+		err = NETDEV_TX_BUSY;
+		goto err_exit;
+	}
+
+err_exit:
+	if (is_busy)
+		atomic_dec(&self->header.busy_count);
+	return err;
+}
+
+int aq_nic_set_packet_filter(struct aq_nic_s *self, unsigned int flags)
+{
+	int err = 0;
+
+	err = self->aq_hw_ops.hw_packet_filter_set(self->aq_hw, flags);
+	if (err < 0)
+		goto err_exit;
+
+	self->packet_filter = flags;
+
+err_exit:
+	return err;
+}
+
+int aq_nic_set_multicast_list(struct aq_nic_s *self, struct net_device *ndev)
+{
+	struct netdev_hw_addr *ha = NULL;
+	unsigned int i = 0U;
+
+	self->mc_list.count = 0U;
+
+	netdev_for_each_mc_addr(ha, ndev) {
+		ether_addr_copy(self->mc_list.ar[i++], ha->addr);
+		++self->mc_list.count;
+	}
+
+	return self->aq_hw_ops.hw_multicast_list_set(self->aq_hw,
+						    self->mc_list.ar,
+						    self->mc_list.count);
+}
+
+int aq_nic_set_mtu(struct aq_nic_s *self, int new_mtu)
+{
+	int err = 0;
+
+	if (new_mtu > self->aq_hw_caps.mtu) {
+		err = -EINVAL;
+		goto err_exit;
+	}
+	self->aq_nic_cfg.mtu = new_mtu;
+
+err_exit:
+	return err;
+}
+
+int aq_nic_set_mac(struct aq_nic_s *self, struct net_device *ndev)
+{
+	return self->aq_hw_ops.hw_set_mac_address(self->aq_hw, ndev->dev_addr);
+}
+
+unsigned int aq_nic_get_link_speed(struct aq_nic_s *self)
+{
+	return self->link_status.mbps;
+}
+
+int aq_nic_get_regs(struct aq_nic_s *self, struct ethtool_regs *regs, void *p)
+{
+	u32 *regs_buff = p;
+	int err = 0;
+
+	regs->version = 1;
+
+	err = self->aq_hw_ops.hw_get_regs(self->aq_hw,
+					  &self->aq_hw_caps, regs_buff);
+	if (err < 0)
+		goto err_exit;
+
+err_exit:
+	return err;
+}
+
+int aq_nic_get_regs_count(struct aq_nic_s *self)
+{
+	return self->aq_hw_caps.mac_regs_count;
+}
+
+void aq_nic_get_stats(struct aq_nic_s *self, u64 *data)
+{
+	struct aq_vec_s *aq_vec = NULL;
+	unsigned int i = 0U;
+	unsigned int count = 0U;
+	int err = 0;
+
+	err = self->aq_hw_ops.hw_get_hw_stats(self->aq_hw, data, &count);
+	if (err < 0)
+		goto err_exit;
+
+	data += count;
+	count = 0U;
+
+	for (i = 0U, aq_vec = self->aq_vec[0];
+		self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i]) {
+		data += count;
+		aq_vec_get_sw_stats(aq_vec, data, &count);
+	}
+
+err_exit:;
+	(void)err;
+}
+
+void aq_nic_get_link_settings(struct aq_nic_s *self, struct ethtool_cmd *cmd)
+{
+	cmd->port = PORT_TP;
+	cmd->transceiver = XCVR_EXTERNAL;
+	/* This driver supports only 10G capable adapters, so DUPLEX_FULL */
+	cmd->duplex = DUPLEX_FULL;
+	cmd->autoneg = self->aq_nic_cfg.is_autoneg;
+
+	cmd->supported |= (self->aq_hw_caps.link_speed_msk & AQ_NIC_RATE_10G) ?
+				ADVERTISED_10000baseT_Full : 0U;
+	cmd->supported |= (self->aq_hw_caps.link_speed_msk & AQ_NIC_RATE_1G) ?
+				ADVERTISED_1000baseT_Full : 0U;
+	cmd->supported |= (self->aq_hw_caps.link_speed_msk & AQ_NIC_RATE_100M) ?
+				ADVERTISED_100baseT_Full : 0U;
+	cmd->supported |= self->aq_hw_caps.flow_control ? SUPPORTED_Pause : 0;
+	cmd->supported |= SUPPORTED_Autoneg;
+
+	cmd->advertising = (self->aq_nic_cfg.is_autoneg) ?
+							ADVERTISED_Autoneg : 0U;
+	cmd->advertising |=
+			(self->aq_nic_cfg.link_speed_msk & AQ_NIC_RATE_10G) ?
+			ADVERTISED_10000baseT_Full : 0U;
+	cmd->advertising |=
+			(self->aq_nic_cfg.link_speed_msk & AQ_NIC_RATE_1G) ?
+			ADVERTISED_1000baseT_Full : 0U;
+
+	cmd->advertising |=
+			(self->aq_nic_cfg.link_speed_msk & AQ_NIC_RATE_100M) ?
+			ADVERTISED_100baseT_Full : 0U;
+	cmd->advertising |= (self->aq_nic_cfg.flow_control) ?
+				ADVERTISED_Pause : 0U;
+}
+
+int aq_nic_set_link_settings(struct aq_nic_s *self, struct ethtool_cmd *cmd)
+{
+	u32 speed = 0U;
+	u32 rate = 0U;
+	int err = 0;
+
+	if (cmd->autoneg == AUTONEG_ENABLE) {
+		rate = self->aq_hw_caps.link_speed_msk;
+		self->aq_nic_cfg.is_autoneg = true;
+	} else {
+		speed = ethtool_cmd_speed(cmd);
+
+		switch (speed) {
+		case SPEED_100:
+			rate = AQ_NIC_RATE_100M;
+			break;
+
+		case SPEED_1000:
+			rate = AQ_NIC_RATE_1G;
+			break;
+
+		case SPEED_2500:
+			rate = AQ_NIC_RATE_2GS;
+			break;
+
+		case SPEED_5000:
+			rate = AQ_NIC_RATE_5G;
+			break;
+
+		case SPEED_10000:
+			rate = AQ_NIC_RATE_10G;
+			break;
+
+		default:
+			err = -1;
+			goto err_exit;
+		break;
+		}
+		if (!(self->aq_hw_caps.link_speed_msk & rate)) {
+			err = -1;
+			goto err_exit;
+		}
+
+		self->aq_nic_cfg.is_autoneg = false;
+	}
+
+	err = self->aq_hw_ops.hw_set_link_speed(self->aq_hw, rate);
+	if (err < 0)
+		goto err_exit;
+
+	self->aq_nic_cfg.link_speed_msk = rate;
+
+err_exit:
+	return err;
+}
+
+struct aq_nic_cfg_s *aq_nic_get_cfg(struct aq_nic_s *self)
+{
+	return &self->aq_nic_cfg;
+}
+
+u32 aq_nic_get_fw_version(struct aq_nic_s *self)
+{
+	u32 fw_version = 0U;
+
+	self->aq_hw_ops.hw_get_fw_version(self->aq_hw, &fw_version);
+
+	return fw_version;
+}
+
+int aq_nic_stop(struct aq_nic_s *self)
+{
+	struct aq_vec_s *aq_vec = NULL;
+	unsigned int i = 0U;
+
+	for (i = 0U, aq_vec = self->aq_vec[0];
+		self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i])
+		aq_nic_ndev_queue_stop(self, i);
+
+	del_timer_sync(&self->service_timer);
+
+	self->aq_hw_ops.hw_irq_disable(self->aq_hw, AQ_CFG_IRQ_MASK);
+
+	if (self->aq_nic_cfg.is_polling)
+		del_timer_sync(&self->polling_timer);
+	else
+		aq_pci_func_free_irqs(self->aq_pci_func);
+
+	for (i = 0U, aq_vec = self->aq_vec[0];
+		self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i])
+		aq_vec_stop(aq_vec);
+
+	return self->aq_hw_ops.hw_stop(self->aq_hw);
+}
+
+void aq_nic_deinit(struct aq_nic_s *self)
+{
+	struct aq_vec_s *aq_vec = NULL;
+	unsigned int i = 0U;
+
+	if (!self)
+		goto err_exit;
+
+	for (i = 0U, aq_vec = self->aq_vec[0];
+		self->aq_vecs > i; ++i, aq_vec = self->aq_vec[i])
+		aq_vec_deinit(aq_vec);
+
+	if (self->power_state == AQ_HW_POWER_STATE_D0) {
+		(void)self->aq_hw_ops.hw_deinit(self->aq_hw);
+	} else {
+		(void)self->aq_hw_ops.hw_set_power(self->aq_hw,
+						   self->power_state);
+	}
+
+err_exit:;
+}
+
+void aq_nic_free_hot_resources(struct aq_nic_s *self)
+{
+	unsigned int i = 0U;
+
+	if (!self)
+		goto err_exit;
+
+	for (i = AQ_DIMOF(self->aq_vec); i--;) {
+		if (self->aq_vec[i])
+			aq_vec_free(self->aq_vec[i]);
+	}
+
+err_exit:;
+}
+
+int aq_nic_change_pm_state(struct aq_nic_s *self, pm_message_t *pm_msg)
+{
+	int err = 0;
+
+	if (!netif_running(self->ndev)) {
+		err = 0;
+		goto err_exit;
+	}
+	if (pm_msg->event & PM_EVENT_SLEEP || pm_msg->event & PM_EVENT_FREEZE) {
+		self->power_state = AQ_HW_POWER_STATE_D3;
+		netif_device_detach(self->ndev);
+		netif_tx_stop_all_queues(self->ndev);
+
+		err = aq_nic_stop(self);
+		if (err < 0)
+			goto err_exit;
+
+		aq_nic_deinit(self);
+	} else {
+		err = aq_nic_init(self);
+		if (err < 0)
+			goto err_exit;
+
+		err = aq_nic_start(self);
+		if (err < 0)
+			goto err_exit;
+
+		netif_device_attach(self->ndev);
+		netif_tx_start_all_queues(self->ndev);
+	}
+
+err_exit:
+	return err;
+}
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.h b/drivers/net/ethernet/aquantia/atlantic/aq_nic.h
new file mode 100644
index 0000000..055e2cd
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.h
@@ -0,0 +1,108 @@
+/*
+ * aQuantia Corporation Network Driver
+ * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/* File aq_nic.h: Declaration of common code for NIC. */
+
+#ifndef AQ_NIC_H
+#define AQ_NIC_H
+
+#include "aq_common.h"
+#include "aq_rss.h"
+
+struct aq_ring_s;
+struct aq_pci_func_s;
+struct aq_hw_ops;
+
+#define AQ_NIC_FC_OFF    0U
+#define AQ_NIC_FC_TX     1U
+#define AQ_NIC_FC_RX     2U
+#define AQ_NIC_FC_FULL   3U
+#define AQ_NIC_FC_AUTO   4U
+
+#define AQ_NIC_RATE_10G        BIT(0)
+#define AQ_NIC_RATE_5G         BIT(1)
+#define AQ_NIC_RATE_5GSR       BIT(2)
+#define AQ_NIC_RATE_2GS        BIT(3)
+#define AQ_NIC_RATE_1G         BIT(4)
+#define AQ_NIC_RATE_100M       BIT(5)
+
+struct aq_nic_cfg_s {
+	struct aq_hw_caps_s *aq_hw_caps;
+	u64 hw_features;
+	u32 rxds;		/* rx ring size, descriptors # */
+	u32 txds;		/* tx ring size, descriptors # */
+	u32 vecs;		/* vecs==allocated irqs */
+	u32 irq_type;
+	u32 itr;
+	u32 num_rss_queues;
+	u32 mtu;
+	u32 ucp_0x364;
+	u32 flow_control;
+	u32 link_speed_msk;
+	u32 vlan_id;
+	u16 is_mc_list_enabled;
+	u16 mc_list_count;
+	bool is_autoneg;
+	bool is_interrupt_moderation;
+	bool is_polling;
+	bool is_rss;
+	bool is_lro;
+	u8  tcs;
+	struct aq_rss_parameters aq_rss;
+};
+
+#define AQ_NIC_FLAG_STARTED     0x00000004U
+#define AQ_NIC_FLAG_STOPPING    0x00000008U
+#define AQ_NIC_FLAG_RESETTING   0x00000010U
+#define AQ_NIC_FLAG_CLOSING     0x00000020U
+#define AQ_NIC_LINK_DOWN        0x04000000U
+#define AQ_NIC_FLAG_ERR_UNPLUG  0x40000000U
+#define AQ_NIC_FLAG_ERR_HW      0x80000000U
+
+#define AQ_NIC_TCVEC2RING(_NIC_, _TC_, _VEC_) \
+	((_TC_) * AQ_CFG_TCS_MAX + (_VEC_))
+
+struct aq_nic_s *aq_nic_alloc_cold(const struct net_device_ops *ndev_ops,
+				   const struct ethtool_ops *et_ops,
+				   struct device *dev,
+				   struct aq_pci_func_s *aq_pci_func,
+				   unsigned int port,
+				   const struct aq_hw_ops *aq_hw_ops);
+int aq_nic_ndev_init(struct aq_nic_s *self);
+struct aq_nic_s *aq_nic_alloc_hot(struct net_device *ndev);
+void aq_nic_set_tx_ring(struct aq_nic_s *self, unsigned int idx,
+			struct aq_ring_s *ring);
+struct device *aq_nic_get_dev(struct aq_nic_s *self);
+struct net_device *aq_nic_get_ndev(struct aq_nic_s *self);
+int aq_nic_init(struct aq_nic_s *self);
+int aq_nic_cfg_start(struct aq_nic_s *self);
+int aq_nic_ndev_register(struct aq_nic_s *self);
+void aq_nic_ndev_queue_start(struct aq_nic_s *self, unsigned int idx);
+void aq_nic_ndev_queue_stop(struct aq_nic_s *self, unsigned int idx);
+void aq_nic_ndev_free(struct aq_nic_s *self);
+int aq_nic_start(struct aq_nic_s *self);
+int aq_nic_xmit(struct aq_nic_s *self, struct sk_buff *skb);
+int aq_nic_get_regs(struct aq_nic_s *self, struct ethtool_regs *regs, void *p);
+int aq_nic_get_regs_count(struct aq_nic_s *self);
+void aq_nic_get_stats(struct aq_nic_s *self, u64 *data);
+int aq_nic_stop(struct aq_nic_s *self);
+void aq_nic_deinit(struct aq_nic_s *self);
+void aq_nic_free_hot_resources(struct aq_nic_s *self);
+int aq_nic_set_mtu(struct aq_nic_s *self, int new_mtu);
+int aq_nic_set_mac(struct aq_nic_s *self, struct net_device *ndev);
+int aq_nic_set_packet_filter(struct aq_nic_s *self, unsigned int flags);
+int aq_nic_set_multicast_list(struct aq_nic_s *self, struct net_device *ndev);
+unsigned int aq_nic_get_link_speed(struct aq_nic_s *self);
+void aq_nic_get_link_settings(struct aq_nic_s *self, struct ethtool_cmd *cmd);
+int aq_nic_set_link_settings(struct aq_nic_s *self, struct ethtool_cmd *cmd);
+struct aq_nic_cfg_s *aq_nic_get_cfg(struct aq_nic_s *self);
+u32 aq_nic_get_fw_version(struct aq_nic_s *self);
+int aq_nic_change_pm_state(struct aq_nic_s *self, pm_message_t *pm_msg);
+
+#endif /* AQ_NIC_H */
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic_internal.h b/drivers/net/ethernet/aquantia/atlantic/aq_nic_internal.h
new file mode 100644
index 0000000..f81738a
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic_internal.h
@@ -0,0 +1,46 @@
+/*
+ * aQuantia Corporation Network Driver
+ * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/* File aq_nic_internal.h: Definition of private object structure. */
+
+#ifndef AQ_NIC_INTERNAL_H
+#define AQ_NIC_INTERNAL_H
+
+struct aq_nic_s {
+	struct aq_obj_s header;
+	struct aq_vec_s *aq_vec[AQ_CFG_VECS_MAX];
+	struct aq_ring_s *aq_ring_tx[AQ_CFG_VECS_MAX * AQ_CFG_TCS_MAX];
+	struct aq_hw_s *aq_hw;
+	struct net_device *ndev;
+	struct aq_pci_func_s *aq_pci_func;
+	unsigned int aq_vecs;
+	unsigned int packet_filter;
+	unsigned int power_state;
+	bool is_ndev_registered;
+	u8 port;
+	struct aq_hw_ops aq_hw_ops;
+	struct aq_hw_caps_s aq_hw_caps;
+	struct aq_nic_cfg_s aq_nic_cfg;
+	struct timer_list service_timer;
+	struct timer_list polling_timer;
+	struct aq_hw_link_status_s link_status;
+	struct {
+		u32 count;
+		u8 ar[AQ_CFG_MULTICAST_ADDRESS_MAX][ETH_ALEN];
+	} mc_list;
+};
+
+#define AQ_NIC_FLAGS_IS_NOT_READY (AQ_NIC_FLAG_STOPPING | \
+			AQ_NIC_FLAG_RESETTING | AQ_NIC_FLAG_CLOSING | \
+			AQ_NIC_FLAG_ERR_UNPLUG | AQ_NIC_FLAG_ERR_HW)
+
+#define AQ_NIC_FLAGS_IS_NOT_TX_READY (AQ_NIC_FLAGS_IS_NOT_READY | \
+					AQ_NIC_LINK_DOWN)
+
+#endif /* AQ_NIC_INTERNAL_H */
-- 
2.9.3
