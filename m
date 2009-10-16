From: Rasesh Mody <rmody@brocade.com>
Subject: Subject: [PATCH 2/6] bna: Brocade 10Gb Ethernet device driver
Date: Fri, 16 Oct 2009 11:24:56 -0700
Message-ID: <200910161824.n9GIOubY010138@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: amathur@brocade.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:36259 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752958AbZJPSaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 14:30:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 2/6 which contains linux driver source for
Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.

We wish this patch to be considered for inclusion in 2.6.32

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 bfa_timer.c    |   97 ++
 bfad_fwimg.c   |  102 ++
 bna_fn.c       | 1991 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 bna_queue.c    |  496 ++++++++++++++
 bnad_ethtool.c | 1101 +++++++++++++++++++++++++++++++
 5 files changed, 3787 insertions(+)

diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bfad_fwimg.c linux-2.6.32-rc4-mod/drivers/net/bna/bfad_fwimg.c
--- linux-2.6.32-rc4-orig/drivers/net/bna/bfad_fwimg.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bfad_fwimg.c	2009-10-16 10:30:53.222438000 -0700
@@ -0,0 +1,102 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+/**
+ *  bfad_fwimg.c Linux driver PCI interface module.
+ */
+#include <bfa_os_inc.h>
+#include <defs/bfa_defs_version.h>
+#include <defs/bfa_defs_pci.h>
+#include <linux/errno.h>
+#include <linux/sched.h>
+#include <linux/init.h>
+#include <linux/fs.h>
+#include <asm/uaccess.h>
+#include <asm/fcntl.h>
+#include <linux/pci.h>
+#include <linux/firmware.h>
+#include <bfa_fwimg_priv.h>
+
+u32 bfi_image_ct_size;
+u32 bfi_image_cb_size;
+u32 *bfi_image_ct;
+u32 *bfi_image_cb;
+
+
+#define	BFAD_FW_FILE_CT	"ctfw.bin"
+#define	BFAD_FW_FILE_CB	"cbfw.bin"
+
+u32 *
+bfad_read_firmware(struct pci_dev *pdev, u32 **bfi_image,
+			u32 *bfi_image_size, char *fw_name)
+{
+	const struct firmware *fw;
+
+	if (request_firmware(&fw, fw_name, &pdev->dev)) {
+		printk(KERN_ALERT "Can't locate firmware %s\n", fw_name);
+		goto error;
+	}
+
+	*bfi_image = vmalloc(fw->size);
+	if (NULL == *bfi_image) {
+		printk(KERN_ALERT "Fail to allocate buffer for fw image "
+			"size=%x!\n", (u32) fw->size);
+		goto error;
+	}
+
+	memcpy(*bfi_image, fw->data, fw->size);
+	*bfi_image_size = fw->size/sizeof(u32);
+
+	return *bfi_image;
+
+error:
+	return NULL;
+}
+
+u32 *
+bfad_get_firmware_buf(struct pci_dev *pdev)
+{
+	if (pdev->device == BFA_PCI_DEVICE_ID_CT) {
+		if (bfi_image_ct_size == 0)
+			bfad_read_firmware(pdev, &bfi_image_ct,
+				&bfi_image_ct_size, BFAD_FW_FILE_CT);
+		return bfi_image_ct;
+	} else {
+		if (bfi_image_cb_size == 0)
+			bfad_read_firmware(pdev, &bfi_image_cb,
+				&bfi_image_cb_size, BFAD_FW_FILE_CB);
+		return bfi_image_cb;
+	}
+}
+
+u32 *
+bfi_image_ct_get_chunk(u32 off)
+{ return (u32 *)(bfi_image_ct + off); }
+
+u32 *
+bfi_image_cb_get_chunk(u32 off)
+{ return (u32 *)(bfi_image_cb + off); }
+
+
+char bfa_version[BFA_VERSION_LEN] = "rmody_pvt_bld 08/26/2009 11.26.03";
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bfa_timer.c linux-2.6.32-rc4-mod/drivers/net/bna/bfa_timer.c
--- linux-2.6.32-rc4-orig/drivers/net/bna/bfa_timer.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bfa_timer.c	2009-10-16 10:30:53.206436000 -0700
@@ -0,0 +1,97 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * See LICENSE.bna for copyright and licensing details.
+ */
+
+#include <bfa_timer.h>
+#include <cs/bfa_debug.h>
+
+void
+bfa_timer_init(struct bfa_timer_mod_s *mod)
+{
+	INIT_LIST_HEAD(&mod->timer_q);
+}
+
+void
+bfa_timer_beat(struct bfa_timer_mod_s *mod)
+{
+	struct list_head        *qh = &mod->timer_q;
+	struct list_head        *qe, *qe_next;
+	struct bfa_timer_s *elem;
+	struct list_head         timedout_q;
+
+	INIT_LIST_HEAD(&timedout_q);
+
+	qe = bfa_q_next(qh);
+
+	while (qe != qh) {
+		qe_next = bfa_q_next(qe);
+
+		elem = (struct bfa_timer_s *) qe;
+		if (elem->timeout <= BFA_TIMER_FREQ) {
+			elem->timeout = 0;
+			list_del(&elem->qe);
+			list_add_tail(&elem->qe, &timedout_q);
+		} else {
+			elem->timeout -= BFA_TIMER_FREQ;
+		}
+
+		qe = qe_next;	/* go to next elem */
+	}
+
+	/*
+	 * Pop all the timeout entries
+	 */
+	while (!list_empty(&timedout_q)) {
+		bfa_q_deq(&timedout_q, &elem);
+		elem->timercb(elem->arg);
+	}
+}
+
+/**
+ * Should be called with lock protection
+ */
+void
+bfa_timer_begin(struct bfa_timer_mod_s *mod, struct bfa_timer_s *timer,
+		    void (*timercb) (void *), void *arg, unsigned int timeout)
+{
+
+	bfa_assert(timercb != NULL);
+	bfa_assert(!bfa_q_is_on_q(&mod->timer_q, timer));
+
+	timer->timeout = timeout;
+	timer->timercb = timercb;
+	timer->arg = arg;
+
+	list_add_tail(&timer->qe, &mod->timer_q);
+}
+
+/**
+ * Should be called with lock protection
+ */
+void
+bfa_timer_stop(struct bfa_timer_s *timer)
+{
+	bfa_assert(!list_empty(&timer->qe));
+
+	list_del(&timer->qe);
+}
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bnad_ethtool.c linux-2.6.32-rc4-mod/drivers/net/bna/bnad_ethtool.c
--- linux-2.6.32-rc4-orig/drivers/net/bna/bnad_ethtool.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bnad_ethtool.c	2009-10-16 10:30:53.269441000 -0700
@@ -0,0 +1,1101 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved.
+ */
+
+/**
+ *  bna_ethtool.c  Brocade 10G PCIe Ethernet driver.
+ */
+
+#include <linux/types.h>
+#include <linux/ethtool.h>
+#include <linux/netdevice.h>
+#include <linux/pci.h>
+#include <linux/interrupt.h>
+#include <linux/skbuff.h>
+#include <linux/if_ether.h>
+#include <linux/rtnetlink.h>
+
+#include "bnad.h"
+#include "bna_os.h"
+#include "bna_hwreg.h"
+#include "bna_iocll.h"
+#include "bnad_defs.h"
+#include "phyport_defs.h"
+
+#define BNAD_ETHTOOL_STATS_NUM						\
+    (sizeof(struct net_device_stats) / sizeof(unsigned long) +	\
+    sizeof(struct bnad_drv_stats) / sizeof(u64) +		\
+     (offsetof(struct bna_stats, rxf_stats[0]) +			\
+    sizeof(struct bna_stats_txf)) / sizeof(u64))
+
+static char *bnad_net_stats_strings[BNAD_ETHTOOL_STATS_NUM] = {
+	"rx_packets",
+	"tx_packets",
+	"rx_bytes",
+	"tx_bytes",
+	"rx_errors",
+	"tx_errors",
+	"rx_dropped",
+	"tx_dropped",
+	"multicast",
+	"collisions",
+
+	"rx_length_errors",
+	"rx_over_errors",
+	"rx_crc_errors",
+	"rx_frame_errors",
+	"rx_fifo_errors",
+	"rx_missed_errors",
+
+	"tx_aborted_errors",
+	"tx_carrier_errors",
+	"tx_fifo_errors",
+	"tx_heartbeat_errors",
+	"tx_window_errors",
+
+	"rx_compressed",
+	"tx_compressed",
+
+	"netif_queue_stop",
+	"netif_queue_wakeup",
+	"tso4",
+	"tso6",
+	"tso_err",
+	"tcpcsum_offload",
+	"udpcsum_offload",
+	"csum_help",
+	"csum_help_err",
+	"hw_stats_updates",
+	"netif_rx_schedule",
+	"netif_rx_complete",
+	"netif_rx_dropped",
+
+	"mac_frame_64",
+	"mac_frame_65_127",
+	"mac_frame_128_255",
+	"mac_frame_256_511",
+	"mac_frame_512_1023",
+	"mac_frame_1024_1518",
+	"mac_frame_1518_1522",
+	"mac_rx_bytes",
+	"mac_rx_packets",
+	"mac_rx_fcs_error",
+	"mac_rx_multicast",
+	"mac_rx_broadcast",
+	"mac_rx_control_frames",
+	"mac_rx_pause",
+	"mac_rx_unknown_opcode",
+	"mac_rx_alignment_error",
+	"mac_rx_frame_length_error",
+	"mac_rx_code_error",
+	"mac_rx_carrier_sense_error",
+	"mac_rx_undersize",
+	"mac_rx_oversize",
+	"mac_rx_fragments",
+	"mac_rx_jabber",
+	"mac_rx_drop",
+
+	"bpc_rx_pause_0",
+	"bpc_rx_pause_1",
+	"bpc_rx_pause_2",
+	"bpc_rx_pause_3",
+	"bpc_rx_pause_4",
+	"bpc_rx_pause_5",
+	"bpc_rx_pause_6",
+	"bpc_rx_pause_7",
+	"bpc_rx_zero_pause_0",
+	"bpc_rx_zero_pause_1",
+	"bpc_rx_zero_pause_2",
+	"bpc_rx_zero_pause_3",
+	"bpc_rx_zero_pause_4",
+	"bpc_rx_zero_pause_5",
+	"bpc_rx_zero_pause_6",
+	"bpc_rx_zero_pause_7",
+	"bpc_rx_first_pause_0",
+	"bpc_rx_first_pause_1",
+	"bpc_rx_first_pause_2",
+	"bpc_rx_first_pause_3",
+	"bpc_rx_first_pause_4",
+	"bpc_rx_first_pause_5",
+	"bpc_rx_first_pause_6",
+	"bpc_rx_first_pause_7",
+
+	"rad_rx_frames",
+	"rad_rx_octets",
+	"rad_rx_vlan_frames",
+	"rad_rx_ucast",
+	"rad_rx_ucast_octets",
+	"rad_rx_ucast_vlan",
+	"rad_rx_mcast",
+	"rad_rx_mcast_octets",
+	"rad_rx_mcast_vlan",
+	"rad_rx_bcast",
+	"rad_rx_bcast_octets",
+	"rad_rx_bcast_vlan",
+	"rad_rx_drops",
+
+	"fc_rx_ucast_octets",
+	"fc_rx_ucast",
+	"fc_rx_ucast_vlan",
+	"fc_rx_mcast_octets",
+	"fc_rx_mcast",
+	"fc_rx_mcast_vlan",
+	"fc_rx_bcast_octets",
+	"fc_rx_bcast",
+	"fc_rx_bcast_vlan",
+
+	"mac_tx_bytes",
+	"mac_tx_packets",
+	"mac_tx_multicast",
+	"mac_tx_broadcast",
+	"mac_tx_pause",
+	"mac_tx_deferral",
+	"mac_tx_excessive_deferral",
+	"mac_tx_single_collision",
+	"mac_tx_muliple_collision",
+	"mac_tx_late_collision",
+	"mac_tx_excessive_collision",
+	"mac_tx_total_collision",
+	"mac_tx_pause_honored",
+	"mac_tx_drop",
+	"mac_tx_jabber",
+	"mac_tx_fcs_error",
+	"mac_tx_control_frame",
+	"mac_tx_oversize",
+	"mac_tx_undersize",
+	"mac_tx_fragments",
+
+	"bpc_tx_pause_0",
+	"bpc_tx_pause_1",
+	"bpc_tx_pause_2",
+	"bpc_tx_pause_3",
+	"bpc_tx_pause_4",
+	"bpc_tx_pause_5",
+	"bpc_tx_pause_6",
+	"bpc_tx_pause_7",
+	"bpc_tx_zero_pause_0",
+	"bpc_tx_zero_pause_1",
+	"bpc_tx_zero_pause_2",
+	"bpc_tx_zero_pause_3",
+	"bpc_tx_zero_pause_4",
+	"bpc_tx_zero_pause_5",
+	"bpc_tx_zero_pause_6",
+	"bpc_tx_zero_pause_7",
+	"bpc_tx_first_pause_0",
+	"bpc_tx_first_pause_1",
+	"bpc_tx_first_pause_2",
+	"bpc_tx_first_pause_3",
+	"bpc_tx_first_pause_4",
+	"bpc_tx_first_pause_5",
+	"bpc_tx_first_pause_6",
+	"bpc_tx_first_pause_7",
+
+	"fc_tx_ucast_octets",
+	"fc_tx_ucast",
+	"fc_tx_ucast_vlan",
+	"fc_tx_mcast_octets",
+	"fc_tx_mcast",
+	"fc_tx_mcast_vlan",
+	"fc_tx_bcast_octets",
+	"fc_tx_bcast",
+	"fc_tx_bcast_vlan",
+	"fc_tx_parity_errors",
+	"fc_tx_timeout",
+	"fc_tx_fid_parity_errors",
+
+	"txf0_ucast_octets",
+	"txf0_ucast",
+	"txf0_ucast_vlan",
+	"txf0_mcast_octets",
+	"txf0_mcast",
+	"txf0_mcast_vlan",
+	"txf0_bcast_octets",
+	"txf0_bcast",
+	"txf0_bcast_vlan",
+	"txf0_errors",
+	"txf0_filter_vlan",
+	"txf0_filter_mac_sa"
+};
+
+static int bnad_get_regs_len(struct net_device *netdev);
+static int bnad_get_stats_count(struct net_device *netdev);
+
+static int bnad_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	struct bna_port_param port_param;
+
+	bnad_lock();
+	spin_lock_irq(&bnad->priv_lock);
+	bna_port_param_get(bnad->priv, &port_param);
+	spin_unlock_irq(&bnad->priv_lock);
+
+	if (port_param.speed == BNA_LINK_SPEED_10Gbps) {
+		cmd->supported = SUPPORTED_10000baseT_Full;
+		cmd->advertising = ADVERTISED_10000baseT_Full;
+	}
+
+	if (port_param.autoneg) {
+		cmd->supported |= SUPPORTED_Autoneg;
+		cmd->advertising |= ADVERTISED_Autoneg;
+		cmd->autoneg = AUTONEG_ENABLE;
+	} else
+		cmd->autoneg = AUTONEG_DISABLE;
+	cmd->supported |= SUPPORTED_FIBRE;
+	cmd->advertising |= ADVERTISED_FIBRE;
+	cmd->port = PORT_FIBRE;
+	cmd->phy_address = 0;
+
+	if (netif_carrier_ok(netdev)) {
+		cmd->speed = SPEED_10000;
+		cmd->duplex = DUPLEX_FULL;
+	} else {
+		cmd->speed = -1;
+		cmd->duplex = -1;
+	}
+	cmd->transceiver = XCVR_EXTERNAL;
+	cmd->maxtxpkt = 0;
+	cmd->maxrxpkt = 0;
+	bnad_unlock();
+	return 0;
+}
+
+static int bnad_set_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
+{
+	/* 10G full duplex setting supported only */
+	if (cmd->autoneg == AUTONEG_ENABLE) {
+		return -EOPNOTSUPP;
+	} else {
+		if ((cmd->speed == SPEED_10000) && (cmd->duplex == DUPLEX_FULL))
+			return 0;
+	}
+
+	return -EOPNOTSUPP;
+}
+
+static void
+bnad_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	struct bfa_ioc_attr_s *ioc_attr;
+
+	strcpy(drvinfo->driver, BNAD_NAME);
+	strcpy(drvinfo->version, BNAD_VERSION);
+
+	ioc_attr = kzalloc(sizeof(*ioc_attr), GFP_KERNEL);
+	if (ioc_attr) {
+		memset(ioc_attr, 0, sizeof(*ioc_attr));
+		spin_lock_irq(&bnad->priv_lock);
+		bna_iocll_getattr(bnad->priv, ioc_attr);
+		spin_unlock_irq(&bnad->priv_lock);
+
+		strncpy(drvinfo->fw_version, ioc_attr->adapter_attr.fw_ver,
+		    sizeof(drvinfo->fw_version) - 1);
+		kfree(ioc_attr);
+	}
+
+	strncpy(drvinfo->bus_info, pci_name(bnad->pcidev),
+	    ETHTOOL_BUSINFO_LEN);
+}
+
+static int get_regs(struct bnad *bnad, u32 *regs)
+{
+	int num = 0, i;
+	u32 reg_addr;
+
+#define BNAD_GET_REG(addr) 					\
+do {								\
+	if (regs)						\
+		regs[num++] = readl(bnad->bar0 + (addr));      \
+	else							\
+		num++;						\
+} while (0)
+
+	/* DMA Block Internal Registers */
+	BNAD_GET_REG(DMA_CTRL_REG0);
+	BNAD_GET_REG(DMA_CTRL_REG1);
+	BNAD_GET_REG(DMA_ERR_INT_STATUS);
+	BNAD_GET_REG(DMA_ERR_INT_ENABLE);
+	BNAD_GET_REG(DMA_ERR_INT_STATUS_SET);
+
+	/* APP Block Register Address Offset from BAR0 */
+	BNAD_GET_REG(HOSTFN0_INT_STATUS);
+	BNAD_GET_REG(HOSTFN0_INT_MASK);
+	BNAD_GET_REG(HOST_PAGE_NUM_FN0);
+	BNAD_GET_REG(HOST_MSIX_ERR_INDEX_FN0);
+	BNAD_GET_REG(FN0_PCIE_ERR_REG);
+	BNAD_GET_REG(FN0_ERR_TYPE_STATUS_REG);
+	BNAD_GET_REG(FN0_ERR_TYPE_MSK_STATUS_REG);
+
+	BNAD_GET_REG(HOSTFN1_INT_STATUS);
+	BNAD_GET_REG(HOSTFN1_INT_MASK);
+	BNAD_GET_REG(HOST_PAGE_NUM_FN1);
+	BNAD_GET_REG(HOST_MSIX_ERR_INDEX_FN1);
+	BNAD_GET_REG(FN1_PCIE_ERR_REG);
+	BNAD_GET_REG(FN1_ERR_TYPE_STATUS_REG);
+	BNAD_GET_REG(FN1_ERR_TYPE_MSK_STATUS_REG);
+
+	BNAD_GET_REG(PCIE_MISC_REG);
+
+	BNAD_GET_REG(HOST_SEM0_REG);
+	BNAD_GET_REG(HOST_SEM1_REG);
+	BNAD_GET_REG(HOST_SEM2_REG);
+	BNAD_GET_REG(HOST_SEM3_REG);
+	BNAD_GET_REG(HOST_SEM0_INFO_REG);
+	BNAD_GET_REG(HOST_SEM1_INFO_REG);
+	BNAD_GET_REG(HOST_SEM2_INFO_REG);
+	BNAD_GET_REG(HOST_SEM3_INFO_REG);
+
+	BNAD_GET_REG(TEMPSENSE_CNTL_REG);
+	BNAD_GET_REG(TEMPSENSE_STAT_REG);
+
+	BNAD_GET_REG(APP_LOCAL_ERR_STAT);
+	BNAD_GET_REG(APP_LOCAL_ERR_MSK);
+
+	BNAD_GET_REG(PCIE_LNK_ERR_STAT);
+	BNAD_GET_REG(PCIE_LNK_ERR_MSK);
+
+	BNAD_GET_REG(FCOE_FIP_ETH_TYPE);
+	BNAD_GET_REG(RESV_ETH_TYPE);
+
+	BNAD_GET_REG(HOSTFN2_INT_STATUS);
+	BNAD_GET_REG(HOSTFN2_INT_MASK);
+	BNAD_GET_REG(HOST_PAGE_NUM_FN2);
+	BNAD_GET_REG(HOST_MSIX_ERR_INDEX_FN2);
+	BNAD_GET_REG(FN2_PCIE_ERR_REG);
+	BNAD_GET_REG(FN2_ERR_TYPE_STATUS_REG);
+	BNAD_GET_REG(FN2_ERR_TYPE_MSK_STATUS_REG);
+
+	BNAD_GET_REG(HOSTFN3_INT_STATUS);
+	BNAD_GET_REG(HOSTFN3_INT_MASK);
+	BNAD_GET_REG(HOST_PAGE_NUM_FN3);
+	BNAD_GET_REG(HOST_MSIX_ERR_INDEX_FN3);
+	BNAD_GET_REG(FN3_PCIE_ERR_REG);
+	BNAD_GET_REG(FN3_ERR_TYPE_STATUS_REG);
+	BNAD_GET_REG(FN3_ERR_TYPE_MSK_STATUS_REG);
+
+	/* Host Command Status Registers */
+	reg_addr = HOST_CMDSTS0_CLR_REG;
+	for (i = 0; i < 16; i++) {
+		BNAD_GET_REG(reg_addr);
+		BNAD_GET_REG(reg_addr + 4);
+		BNAD_GET_REG(reg_addr + 8);
+		reg_addr += 0x10;
+	}
+
+	/* Function ID register */
+	BNAD_GET_REG(FNC_ID_REG);
+
+	/* Function personality register */
+	BNAD_GET_REG(FNC_PERS_REG);
+
+	/* Operation mode register */
+	BNAD_GET_REG(OP_MODE);
+
+	/* LPU0 Registers */
+	BNAD_GET_REG(LPU0_MBOX_CTL_REG);
+	BNAD_GET_REG(LPU0_MBOX_CMD_REG);
+	BNAD_GET_REG(LPU0_MBOX_LINK_0REG);
+	BNAD_GET_REG(LPU1_MBOX_LINK_0REG);
+	BNAD_GET_REG(LPU0_MBOX_STATUS_0REG);
+	BNAD_GET_REG(LPU1_MBOX_STATUS_0REG);
+	BNAD_GET_REG(LPU0_ERR_STATUS_REG);
+	BNAD_GET_REG(LPU0_ERR_SET_REG);
+
+	/* LPU1 Registers */
+	BNAD_GET_REG(LPU1_MBOX_CTL_REG);
+	BNAD_GET_REG(LPU1_MBOX_CMD_REG);
+	BNAD_GET_REG(LPU0_MBOX_LINK_1REG);
+	BNAD_GET_REG(LPU1_MBOX_LINK_1REG);
+	BNAD_GET_REG(LPU0_MBOX_STATUS_1REG);
+	BNAD_GET_REG(LPU1_MBOX_STATUS_1REG);
+	BNAD_GET_REG(LPU1_ERR_STATUS_REG);
+	BNAD_GET_REG(LPU1_ERR_SET_REG);
+
+	/* PSS Registers */
+	BNAD_GET_REG(PSS_CTL_REG);
+	BNAD_GET_REG(PSS_ERR_STATUS_REG);
+	BNAD_GET_REG(ERR_STATUS_SET);
+	BNAD_GET_REG(PSS_RAM_ERR_STATUS_REG);
+
+	/* Catapult CPQ Registers */
+	BNAD_GET_REG(HOSTFN0_LPU0_MBOX0_CMD_STAT);
+	BNAD_GET_REG(HOSTFN0_LPU1_MBOX0_CMD_STAT);
+	BNAD_GET_REG(LPU0_HOSTFN0_MBOX0_CMD_STAT);
+	BNAD_GET_REG(LPU1_HOSTFN0_MBOX0_CMD_STAT);
+
+	BNAD_GET_REG(HOSTFN0_LPU0_MBOX1_CMD_STAT);
+	BNAD_GET_REG(HOSTFN0_LPU1_MBOX1_CMD_STAT);
+	BNAD_GET_REG(LPU0_HOSTFN0_MBOX1_CMD_STAT);
+	BNAD_GET_REG(LPU1_HOSTFN0_MBOX1_CMD_STAT);
+
+	BNAD_GET_REG(HOSTFN1_LPU0_MBOX0_CMD_STAT);
+	BNAD_GET_REG(HOSTFN1_LPU1_MBOX0_CMD_STAT);
+	BNAD_GET_REG(LPU0_HOSTFN1_MBOX0_CMD_STAT);
+	BNAD_GET_REG(LPU1_HOSTFN1_MBOX0_CMD_STAT);
+
+	BNAD_GET_REG(HOSTFN1_LPU0_MBOX1_CMD_STAT);
+	BNAD_GET_REG(HOSTFN1_LPU1_MBOX1_CMD_STAT);
+	BNAD_GET_REG(LPU0_HOSTFN1_MBOX1_CMD_STAT);
+	BNAD_GET_REG(LPU1_HOSTFN1_MBOX1_CMD_STAT);
+
+	BNAD_GET_REG(HOSTFN2_LPU0_MBOX0_CMD_STAT);
+	BNAD_GET_REG(HOSTFN2_LPU1_MBOX0_CMD_STAT);
+	BNAD_GET_REG(LPU0_HOSTFN2_MBOX0_CMD_STAT);
+	BNAD_GET_REG(LPU1_HOSTFN2_MBOX0_CMD_STAT);
+
+	BNAD_GET_REG(HOSTFN2_LPU0_MBOX1_CMD_STAT);
+	BNAD_GET_REG(HOSTFN2_LPU1_MBOX1_CMD_STAT);
+	BNAD_GET_REG(LPU0_HOSTFN2_MBOX1_CMD_STAT);
+	BNAD_GET_REG(LPU1_HOSTFN2_MBOX1_CMD_STAT);
+
+	BNAD_GET_REG(HOSTFN3_LPU0_MBOX0_CMD_STAT);
+	BNAD_GET_REG(HOSTFN3_LPU1_MBOX0_CMD_STAT);
+	BNAD_GET_REG(LPU0_HOSTFN3_MBOX0_CMD_STAT);
+	BNAD_GET_REG(LPU1_HOSTFN3_MBOX0_CMD_STAT);
+
+	BNAD_GET_REG(HOSTFN3_LPU0_MBOX1_CMD_STAT);
+	BNAD_GET_REG(HOSTFN3_LPU1_MBOX1_CMD_STAT);
+	BNAD_GET_REG(LPU0_HOSTFN3_MBOX1_CMD_STAT);
+	BNAD_GET_REG(LPU1_HOSTFN3_MBOX1_CMD_STAT);
+
+	/* Host Function Force Parity Error Registers */
+	BNAD_GET_REG(HOSTFN0_LPU_FORCE_PERR);
+	BNAD_GET_REG(HOSTFN1_LPU_FORCE_PERR);
+	BNAD_GET_REG(HOSTFN2_LPU_FORCE_PERR);
+	BNAD_GET_REG(HOSTFN3_LPU_FORCE_PERR);
+
+	/* LL Port[0|1] Halt Mask Registers */
+	BNAD_GET_REG(LL_HALT_MSK_P0);
+	BNAD_GET_REG(LL_HALT_MSK_P1);
+
+	/* LL Port[0|1] Error Mask Registers */
+	BNAD_GET_REG(LL_ERR_MSK_P0);
+	BNAD_GET_REG(LL_ERR_MSK_P1);
+
+	/* EMC FLI Registers */
+	BNAD_GET_REG(FLI_CMD_REG);
+	BNAD_GET_REG(FLI_ADDR_REG);
+	BNAD_GET_REG(FLI_CTL_REG);
+	BNAD_GET_REG(FLI_WRDATA_REG);
+	BNAD_GET_REG(FLI_RDDATA_REG);
+	BNAD_GET_REG(FLI_DEV_STATUS_REG);
+	BNAD_GET_REG(FLI_SIG_WD_REG);
+
+	BNAD_GET_REG(FLI_DEV_VENDOR_REG);
+	BNAD_GET_REG(FLI_ERR_STATUS_REG);
+
+	/* RxAdm 0 Registers */
+	BNAD_GET_REG(RAD0_CTL_REG);
+	BNAD_GET_REG(RAD0_PE_PARM_REG);
+	BNAD_GET_REG(RAD0_BCN_REG);
+	BNAD_GET_REG(RAD0_DEFAULT_REG);
+	BNAD_GET_REG(RAD0_PROMISC_REG);
+	BNAD_GET_REG(RAD0_BCNQ_REG);
+	BNAD_GET_REG(RAD0_DEFAULTQ_REG);
+
+	BNAD_GET_REG(RAD0_ERR_STS);
+	BNAD_GET_REG(RAD0_SET_ERR_STS);
+	BNAD_GET_REG(RAD0_ERR_INT_EN);
+	BNAD_GET_REG(RAD0_FIRST_ERR);
+	BNAD_GET_REG(RAD0_FORCE_ERR);
+
+	BNAD_GET_REG(RAD0_MAC_MAN_1H);
+	BNAD_GET_REG(RAD0_MAC_MAN_1L);
+	BNAD_GET_REG(RAD0_MAC_MAN_2H);
+	BNAD_GET_REG(RAD0_MAC_MAN_2L);
+	BNAD_GET_REG(RAD0_MAC_MAN_3H);
+	BNAD_GET_REG(RAD0_MAC_MAN_3L);
+	BNAD_GET_REG(RAD0_MAC_MAN_4H);
+	BNAD_GET_REG(RAD0_MAC_MAN_4L);
+
+	BNAD_GET_REG(RAD0_LAST4_IP);
+
+	/* RxAdm 1 Registers */
+	BNAD_GET_REG(RAD1_CTL_REG);
+	BNAD_GET_REG(RAD1_PE_PARM_REG);
+	BNAD_GET_REG(RAD1_BCN_REG);
+	BNAD_GET_REG(RAD1_DEFAULT_REG);
+	BNAD_GET_REG(RAD1_PROMISC_REG);
+	BNAD_GET_REG(RAD1_BCNQ_REG);
+	BNAD_GET_REG(RAD1_DEFAULTQ_REG);
+
+	BNAD_GET_REG(RAD1_ERR_STS);
+	BNAD_GET_REG(RAD1_SET_ERR_STS);
+	BNAD_GET_REG(RAD1_ERR_INT_EN);
+
+	/* TxA0 Registers */
+	BNAD_GET_REG(TXA0_CTRL_REG);
+	/* TxA0 TSO Sequence # Registers (RO) */
+	for (i = 0; i < 8; i++) {
+		BNAD_GET_REG(TXA0_TSO_TCP_SEQ_REG(i));
+		BNAD_GET_REG(TXA0_TSO_IP_INFO_REG(i));
+	}
+
+	/* TxA1 Registers */
+	BNAD_GET_REG(TXA1_CTRL_REG);
+	/* TxA1 TSO Sequence # Registers (RO) */
+	for (i = 0; i < 8; i++) {
+		BNAD_GET_REG(TXA1_TSO_TCP_SEQ_REG(i));
+		BNAD_GET_REG(TXA1_TSO_IP_INFO_REG(i));
+	}
+
+	/* RxA Registers */
+	BNAD_GET_REG(RXA0_CTL_REG);
+	BNAD_GET_REG(RXA1_CTL_REG);
+
+	/* PLB0 Registers */
+	BNAD_GET_REG(PLB0_ECM_TIMER_REG);
+	BNAD_GET_REG(PLB0_RL_CTL);
+	for (i = 0; i < 8; i++)
+		BNAD_GET_REG(PLB0_RL_MAX_BC(i));
+	BNAD_GET_REG(PLB0_RL_TU_PRIO);
+	for (i = 0; i < 8; i++)
+		BNAD_GET_REG(PLB0_RL_BYTE_CNT(i));
+	BNAD_GET_REG(PLB0_RL_MIN_REG);
+	BNAD_GET_REG(PLB0_RL_MAX_REG);
+	BNAD_GET_REG(PLB0_EMS_ADD_REG);
+
+	/* PLB1 Registers */
+	BNAD_GET_REG(PLB1_ECM_TIMER_REG);
+	BNAD_GET_REG(PLB1_RL_CTL);
+	for (i = 0; i < 8; i++)
+		BNAD_GET_REG(PLB1_RL_MAX_BC(i));
+	BNAD_GET_REG(PLB1_RL_TU_PRIO);
+	for (i = 0; i < 8; i++)
+		BNAD_GET_REG(PLB1_RL_BYTE_CNT(i));
+	BNAD_GET_REG(PLB1_RL_MIN_REG);
+	BNAD_GET_REG(PLB1_RL_MAX_REG);
+	BNAD_GET_REG(PLB1_EMS_ADD_REG);
+
+	/* HQM Control Register */
+	BNAD_GET_REG(HQM0_CTL_REG);
+	BNAD_GET_REG(HQM0_RXQ_STOP_SEM);
+	BNAD_GET_REG(HQM0_TXQ_STOP_SEM);
+	BNAD_GET_REG(HQM1_CTL_REG);
+	BNAD_GET_REG(HQM1_RXQ_STOP_SEM);
+	BNAD_GET_REG(HQM1_TXQ_STOP_SEM);
+
+	/* LUT Registers */
+	BNAD_GET_REG(LUT0_ERR_STS);
+	BNAD_GET_REG(LUT0_SET_ERR_STS);
+	BNAD_GET_REG(LUT1_ERR_STS);
+	BNAD_GET_REG(LUT1_SET_ERR_STS);      \
+
+	/* TRC Registers */
+	BNAD_GET_REG(TRC_CTL_REG);
+	BNAD_GET_REG(TRC_MODS_REG);
+	BNAD_GET_REG(TRC_TRGC_REG);
+	BNAD_GET_REG(TRC_CNT1_REG);
+	BNAD_GET_REG(TRC_CNT2_REG);
+	BNAD_GET_REG(TRC_NXTS_REG);
+	BNAD_GET_REG(TRC_DIRR_REG);
+	for (i = 0; i < 10; i++)
+		BNAD_GET_REG(TRC_TRGM_REG(i));
+	for (i = 0; i < 10; i++)
+		BNAD_GET_REG(TRC_NXTM_REG(i));
+	for (i = 0; i < 10; i++)
+		BNAD_GET_REG(TRC_STRM_REG(i));
+
+#undef BNAD_GET_REG
+	return num;
+}
+
+static int bnad_get_regs_len(struct net_device *netdev)
+{
+	return get_regs(netdev_priv(netdev), NULL) * sizeof(u32);
+}
+
+static void
+bnad_get_regs(struct net_device *netdev, struct ethtool_regs *regs, void *buf)
+{
+	memset(buf, 0, bnad_get_regs_len(netdev));
+	get_regs(netdev_priv(netdev), buf);
+}
+
+static void
+bnad_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wolinfo)
+{
+	wolinfo->supported = 0;
+	wolinfo->wolopts = 0;
+}
+
+
+static int
+bnad_get_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+
+	bnad_lock();
+	coalesce->rx_coalesce_usecs = bnad->rx_coalescing_timeo *
+	    BNAD_COALESCING_TIMER_UNIT;
+	coalesce->rx_max_coalesced_frames = bnad->rx_interpkt_count;
+	coalesce->rx_coalesce_usecs_irq = bnad->rx_interpkt_timeo;
+	coalesce->tx_coalesce_usecs = bnad->tx_coalescing_timeo *
+	    BNAD_COALESCING_TIMER_UNIT;
+	coalesce->tx_max_coalesced_frames = bnad->tx_interpkt_count;
+
+	coalesce->use_adaptive_rx_coalesce = bnad->rx_dyn_coalesce_on;
+	bnad_unlock();
+	return 0;
+}
+
+static int
+bnad_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *coalesce)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	int i, err = 0, reset = 0;
+	u16 ib_id;
+
+	if (coalesce->rx_coalesce_usecs == 0 || coalesce->rx_coalesce_usecs >
+	    BNAD_MAX_COALESCING_TIMEO * BNAD_COALESCING_TIMER_UNIT)
+		return -EINVAL;
+	if (coalesce->rx_max_coalesced_frames > BNAD_MAX_INTERPKT_COUNT)
+		return -EINVAL;
+	if (coalesce->rx_coalesce_usecs_irq == 0 ||
+	    coalesce->rx_coalesce_usecs_irq > BNAD_MAX_INTERPKT_TIMEO)
+		return -EINVAL;
+
+	if (coalesce->tx_coalesce_usecs == 0 || coalesce->tx_coalesce_usecs >
+	    BNAD_MAX_COALESCING_TIMEO * BNAD_COALESCING_TIMER_UNIT)
+		return -EINVAL;
+	if (coalesce->tx_max_coalesced_frames > BNAD_MAX_INTERPKT_COUNT)
+		return -EINVAL;
+
+	bnad_lock();
+
+	bnad->rx_dyn_coalesce_on = coalesce->use_adaptive_rx_coalesce;
+
+	bnad->rx_coalescing_timeo = coalesce->rx_coalesce_usecs /
+	    BNAD_COALESCING_TIMER_UNIT;
+	if (bnad->rx_coalescing_timeo == 0)
+		bnad->rx_coalescing_timeo = 1;
+	if (!test_bit(BNAD_DISABLED, &bnad->state)) {
+		for (i = 0; i < bnad->cq_num; i++) {
+			ib_id = bnad->cq_table[i].cq_config.ib_id;
+			bnad->ib_table[ib_id].ib_config.coalescing_timer =
+			    bnad->rx_coalescing_timeo;
+			if (!bnad->rx_dyn_coalesce_on) {
+				bnad->cq_table[i].rx_coalescing_timeo =
+					bnad->rx_coalescing_timeo;
+			}
+		}
+	}
+	if (coalesce->rx_max_coalesced_frames != bnad->rx_interpkt_count) {
+		bnad->rx_interpkt_count = coalesce->rx_max_coalesced_frames;
+		reset++;
+	}
+	if (coalesce->rx_coalesce_usecs_irq != bnad->rx_interpkt_timeo) {
+		bnad->rx_interpkt_timeo = coalesce->rx_coalesce_usecs_irq;
+		reset++;
+	}
+
+	bnad->tx_coalescing_timeo = coalesce->tx_coalesce_usecs /
+	    BNAD_COALESCING_TIMER_UNIT;
+	if (bnad->tx_coalescing_timeo == 0)
+		bnad->tx_coalescing_timeo = 1;
+	if (!test_bit(BNAD_DISABLED, &bnad->state)) {
+		for (i = 0; i < bnad->txq_num; i++) {
+			ib_id = bnad->txq_table[i].txq_config.ib_id;
+			bnad->ib_table[ib_id].ib_config.coalescing_timer =
+			    bnad->tx_coalescing_timeo;
+		}
+	}
+	if (coalesce->tx_max_coalesced_frames != bnad->tx_interpkt_count) {
+		bnad->tx_interpkt_count = coalesce->tx_max_coalesced_frames;
+		reset++;
+	}
+
+	if (reset)
+		err = bnad_sw_reset(netdev);
+
+	bnad_unlock();
+
+	return err;
+}
+
+static void bnad_get_ringparam(struct net_device *netdev,
+    struct ethtool_ringparam *ringparam)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+
+	bnad_lock();
+	ringparam->rx_max_pending = BNAD_MAX_Q_DEPTH / bnad_rxqs_per_cq;
+	ringparam->rx_mini_max_pending = 0;
+	ringparam->rx_jumbo_max_pending = 0;
+	ringparam->tx_max_pending = BNAD_MAX_Q_DEPTH;
+
+	ringparam->rx_pending = bnad->rxq_depth;
+	ringparam->rx_mini_max_pending = 0;
+	ringparam->rx_jumbo_max_pending = 0;
+	ringparam->tx_pending = bnad->txq_depth;
+	bnad_unlock();
+}
+
+static int bnad_set_ringparam(struct net_device *netdev,
+    struct ethtool_ringparam *ringparam)
+{
+	int err = 0;
+	struct bnad *bnad = netdev_priv(netdev);
+	bnad_lock();
+	if (ringparam->rx_pending == bnad->rxq_depth &&
+	    ringparam->tx_pending == bnad->txq_depth) {
+		bnad_unlock();
+		return 0;
+	}
+
+	if (ringparam->rx_pending < BNAD_MIN_Q_DEPTH ||
+	    ringparam->rx_pending > BNAD_MAX_Q_DEPTH / bnad_rxqs_per_cq ||
+	    !BNA_POWER_OF_2(ringparam->rx_pending)) {
+		bnad_unlock();
+		return -EINVAL;
+	}
+	if (ringparam->tx_pending < BNAD_MIN_Q_DEPTH ||
+	    ringparam->tx_pending > BNAD_MAX_Q_DEPTH ||
+	    !BNA_POWER_OF_2(ringparam->tx_pending)) {
+		bnad_unlock();
+		return -EINVAL;
+	}
+
+	if (ringparam->rx_pending != bnad->rxq_depth) {
+		bnad->rxq_depth = ringparam->rx_pending;
+		bnad->flags |= BNAD_F_RXQ_DEPTH;
+	}
+	if (ringparam->tx_pending != bnad->txq_depth) {
+		bnad->txq_depth = ringparam->tx_pending;
+		bnad->flags |= BNAD_F_TXQ_DEPTH;
+	}
+
+	err =  bnad_sw_reset(netdev);
+	bnad_unlock();
+	return err;
+}
+
+static void bnad_get_pauseparam(struct net_device *netdev,
+    struct ethtool_pauseparam *pauseparam)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	bnad_lock();
+	pauseparam->autoneg = 0;
+	pauseparam->rx_pause = bnad->pause_config.rx_pause;
+	pauseparam->tx_pause = bnad->pause_config.tx_pause;
+	bnad_unlock();
+}
+
+static int bnad_set_pauseparam(struct net_device *netdev,
+    struct ethtool_pauseparam *pauseparam)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	int err;
+
+	if (pauseparam->autoneg == AUTONEG_ENABLE)
+		return -EINVAL;
+	bnad_lock();
+	if (pauseparam->rx_pause != bnad->pause_config.rx_pause ||
+	    pauseparam->tx_pause != bnad->pause_config.tx_pause) {
+		bnad->pause_config.rx_pause = pauseparam->rx_pause;
+		bnad->pause_config.tx_pause = pauseparam->tx_pause;
+		spin_lock_irq(&bnad->priv_lock);
+		err = bna_set_pause_config(bnad->priv,
+			&bnad->pause_config, bnad);
+		BNA_ASSERT(!err);
+		spin_unlock_irq(&bnad->priv_lock);
+	}
+	bnad_unlock();
+	return 0;
+}
+
+static u32 bnad_get_rx_csum(struct net_device *netdev)
+{
+	u32 rx_csum;
+	struct bnad *bnad = netdev_priv(netdev);
+
+	bnad_lock();
+	rx_csum = bnad->rx_csum;
+	bnad_unlock();
+	return rx_csum;
+}
+
+static int bnad_set_rx_csum(struct net_device *netdev, u32 rx_csum)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+
+	bnad_lock();
+	bnad->rx_csum = rx_csum;
+	bnad_unlock();
+	return 0;
+}
+
+static int bnad_set_tx_csum(struct net_device *netdev, u32 tx_csum)
+{
+	if (tx_csum) {
+		netdev->features |= NETIF_F_IP_CSUM;
+#ifdef NETIF_F_IPV6_CSUM
+		netdev->features |= NETIF_F_IPV6_CSUM;
+#endif
+	} else {
+		netdev->features &= ~NETIF_F_IP_CSUM;
+#ifdef NETIF_F_IPV6_CSUM
+		netdev->features &= ~NETIF_F_IPV6_CSUM;
+#endif
+	}
+	return 0;
+}
+
+#ifdef NETIF_F_TSO
+static int bnad_set_tso(struct net_device *netdev, u32 tso)
+{
+	if (tso) {
+		netdev->features |= NETIF_F_TSO;
+#ifdef NETIF_F_TSO6
+		netdev->features |= NETIF_F_TSO6;
+#endif
+	} else {
+		netdev->features &= ~NETIF_F_TSO;
+#ifdef NETIF_F_TSO6
+		netdev->features &= ~NETIF_F_TSO6;
+#endif
+	}
+	return 0;
+}
+#endif
+
+
+static void bnad_get_strings(struct net_device *netdev, u32 stringset,
+							 u8 *string)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	int i;
+	bnad_lock();
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < BNAD_ETHTOOL_STATS_NUM; i++) {
+			BNA_ASSERT(strlen(bnad_net_stats_strings[i]) <
+				ETH_GSTRING_LEN);
+			memcpy(string, bnad_net_stats_strings[i],
+				ETH_GSTRING_LEN);
+			string += ETH_GSTRING_LEN;
+		}
+
+			i = 0;
+			sprintf(string, "rxf%d_ucast_octets", i);
+			string += ETH_GSTRING_LEN;
+			sprintf(string, "rxf%d_ucast", i);
+			string += ETH_GSTRING_LEN;
+			sprintf(string, "rxf%d_ucast_vlan", i);
+			string += ETH_GSTRING_LEN;
+			sprintf(string, "rxf%d_mcast_octets", i);
+			string += ETH_GSTRING_LEN;
+			sprintf(string, "rxf%d_mcast", i);
+			string += ETH_GSTRING_LEN;
+			sprintf(string, "rxf%d_mcast_vlan", i);
+			string += ETH_GSTRING_LEN;
+			sprintf(string, "rxf%d_bcast_octets", i);
+			string += ETH_GSTRING_LEN;
+			sprintf(string, "rxf%d_bcast", i);
+			string += ETH_GSTRING_LEN;
+			sprintf(string, "rxf%d_bcast_vlan", i);
+			string += ETH_GSTRING_LEN;
+			sprintf(string, "rxf%d_frame_drops", i);
+			string += ETH_GSTRING_LEN;
+
+		sprintf(string, "netif_queue_stopped");
+		string += ETH_GSTRING_LEN;
+		sprintf(string, "bna_state");
+		string += ETH_GSTRING_LEN;
+
+		for (i = 0; i < bnad->cq_num; i++) {
+			sprintf(string, "cq%d_producer_index", i);
+			string += ETH_GSTRING_LEN;
+			sprintf(string, "cq%d_consumer_index", i);
+			string += ETH_GSTRING_LEN;
+		}
+
+		for (i = 0; i < bnad->rxq_num; i++) {
+			sprintf(string, "rxq%d_packets", i);
+			string += ETH_GSTRING_LEN;
+			sprintf(string, "rxq%d_bytes", i);
+			string += ETH_GSTRING_LEN;
+			sprintf(string, "rxq%d_packets_with_error", i);
+			string += ETH_GSTRING_LEN;
+			sprintf(string, "rxq%d_allocbuf_failed", i);
+			string += ETH_GSTRING_LEN;
+
+			sprintf(string, "rxq%d_producer_index", i);
+			string += ETH_GSTRING_LEN;
+			sprintf(string, "rxq%d_consumer_index", i);
+			string += ETH_GSTRING_LEN;
+
+		}
+
+		for (i = 0; i < bnad->txq_num; i++) {
+			sprintf(string, "txq%d_packets", i);
+			string += ETH_GSTRING_LEN;
+			sprintf(string, "txq%d_bytes", i);
+			string += ETH_GSTRING_LEN;
+
+			sprintf(string, "txq%d_producer_index", i);
+			string += ETH_GSTRING_LEN;
+			sprintf(string, "txq%d_consumer_index", i);
+			string += ETH_GSTRING_LEN;
+			sprintf(string, "txq%d_hw_consumer_index", i);
+			string += ETH_GSTRING_LEN;
+		}
+		break;
+
+	default:
+		break;
+	}
+	bnad_unlock();
+}
+
+
+static void bnad_get_ethtool_stats(struct net_device *netdev,
+	struct ethtool_stats *stats, u64 *buf)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	int i, bi, j;
+	unsigned long *net_stats;
+	u64 *stats64;
+
+	bi = 0;
+	memset(buf, 0, bnad_get_stats_count(netdev) * sizeof(u64));
+	bnad_get_stats(netdev);
+
+	net_stats = (unsigned long *)&bnad->net_stats;
+	for (i = 0; i < sizeof(struct net_device_stats) /
+	    sizeof(unsigned long); i++)
+		buf[bi++] = net_stats[i];
+
+	stats64 = (u64 *)&bnad->stats;
+	for (i = 0; i < sizeof(struct bnad_drv_stats) / sizeof(u64);
+	    i++)
+		buf[bi++] = stats64[i];
+
+	stats64 = (u64 *)bnad->hw_stats;
+	for (i = 0; i < offsetof(struct bna_stats, rxf_stats[0]) /
+	    sizeof(u64); i++)
+		buf[bi++] = stats64[i];
+
+	stats64 = (u64 *)&bnad->hw_stats->txf_stats[0];
+	for (i = 0; i < sizeof(struct bna_stats_txf) / sizeof(u64); i++)
+		buf[bi++] = stats64[i];
+
+		j = 0;
+		stats64 = (u64 *)&bnad->hw_stats->rxf_stats[j];
+		for (i = 0; i < sizeof(struct bna_stats_rxf) /
+		      sizeof(u64); i++)
+			buf[bi++] = stats64[i];
+
+	buf[bi++] = netif_queue_stopped(netdev);
+	buf[bi++] = bnad->state;
+
+	if (bnad->cq_table && bnad->rxq_table && bnad->txq_table) {
+		for (i = 0; i < bnad->cq_num; i++) {
+			buf[bi++] = bnad->cq_table[i].cq.q.producer_index;
+			buf[bi++] = bnad->cq_table[i].cq.q.consumer_index;
+		}
+
+		for (i = 0; i < bnad->rxq_num; i++) {
+			buf[bi++] = bnad->rxq_table[i].rx_packets;
+			buf[bi++] = bnad->rxq_table[i].rx_bytes;
+			buf[bi++] = bnad->rxq_table[i].rx_packets_with_error;
+			buf[bi++] = bnad->rxq_table[i].rxbuf_alloc_failed;
+
+			buf[bi++] = bnad->rxq_table[i].rxq.q.producer_index;
+			buf[bi++] = bnad->rxq_table[i].rxq.q.consumer_index;
+		}
+		for (i = 0; i < bnad->txq_num; i++) {
+			buf[bi++] = bnad->txq_table[i].tx_packets;
+			buf[bi++] = bnad->txq_table[i].tx_bytes;
+
+			buf[bi++] = bnad->txq_table[i].txq.q.producer_index;
+			buf[bi++] = bnad->txq_table[i].txq.q.consumer_index;
+			buf[bi++] = *(bnad->txq_table[i].hw_consumer_index);
+		}
+	}
+}
+
+
+/* XXX use get_sset_count */
+static int bnad_get_stats_count(struct net_device *netdev)
+{
+	struct bnad *bnad = netdev_priv(netdev);
+	int count;
+
+	bnad_lock();
+	count = BNAD_ETHTOOL_STATS_NUM + 10 + bnad->rxq_num * 4
+		+ bnad->txq_num * 2;
+
+	/* netif_queue_stopped, state */
+	count += 2;
+
+	/* CQ producer_index, consumer_index */
+	count += bnad->cq_num * 2;
+
+	/* RxQ producer_index, consumer_index */
+	count += bnad->rxq_num * 2;
+
+	/* TxQ producer_index, consumer_index, hw_consumer_index */
+	count += bnad->txq_num * 3;
+	bnad_unlock();
+	return count;
+}
+
+static struct ethtool_ops bnad_ethtool_ops = {
+	.get_settings           = bnad_get_settings,
+	.set_settings           = bnad_set_settings,
+	.get_drvinfo            = bnad_get_drvinfo,
+	.get_regs_len           = bnad_get_regs_len,
+	.get_regs               = bnad_get_regs,
+	.get_wol                = bnad_get_wol,
+	.get_msglevel		= bnad_get_msglevel,
+	.set_msglevel		= bnad_set_msglevel,
+	.get_link               = ethtool_op_get_link,
+	.get_coalesce           = bnad_get_coalesce,
+	.set_coalesce           = bnad_set_coalesce,
+	.get_ringparam          = bnad_get_ringparam,
+	.set_ringparam          = bnad_set_ringparam,
+	.get_pauseparam         = bnad_get_pauseparam,
+	.set_pauseparam         = bnad_set_pauseparam,
+	.get_rx_csum            = bnad_get_rx_csum,
+	.set_rx_csum            = bnad_set_rx_csum,
+	.get_tx_csum		= ethtool_op_get_tx_csum,
+	.set_tx_csum            = bnad_set_tx_csum,
+	.get_sg                 = ethtool_op_get_sg,
+	.set_sg                 = ethtool_op_set_sg,
+#ifdef NETIF_F_TSO
+	.get_tso                = ethtool_op_get_tso,
+	.set_tso                = bnad_set_tso,
+#endif
+#ifdef NETIF_F_LRO
+	.get_flags              = ethtool_op_get_flags,
+	.set_flags              = ethtool_op_set_flags,
+#endif
+	.get_strings            = bnad_get_strings,
+	.get_ethtool_stats      = bnad_get_ethtool_stats,
+	.get_stats_count        = bnad_get_stats_count
+};
+
+void bnad_set_ethtool_ops(struct net_device *netdev)
+{
+	SET_ETHTOOL_OPS(netdev, &bnad_ethtool_ops);
+}
+
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bna_fn.c linux-2.6.32-rc4-mod/drivers/net/bna/bna_fn.c
--- linux-2.6.32-rc4-orig/drivers/net/bna/bna_fn.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bna_fn.c	2009-10-16 10:30:53.239443000 -0700
@@ -0,0 +1,1991 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ *    Copyright (c) 2007-2008 Brocade Communications Systems, Inc.
+ *    All rights reserved.
+ *
+ *    @file bna_fn.c BNA Rx and Tx Function Management
+ */
+
+#include <bna_os.h>
+#include "bna.h"
+#include "bna_hwreg.h"
+#include "bna_priv.h"
+#include <bfi/bfi_ll.h>
+#include <bfi/bfi_cee.h>
+
+
+/*
+ * 12 bit Max VLAN Id mask used to
+ * wrap overflowing VLANs wraps around the
+ * max value of 4095
+ */
+#define BNA_MAX_VLAN_ID_MASK	0x00000fff
+
+const struct bna_chip_regs_offset reg_offset[] =
+	{ {HOST_PAGE_NUM_FN0, HOSTFN0_INT_STATUS,
+		HOSTFN0_INT_MASK, HOST_MSIX_ERR_INDEX_FN0},
+	  {HOST_PAGE_NUM_FN1, HOSTFN1_INT_STATUS,
+		HOSTFN1_INT_MASK, HOST_MSIX_ERR_INDEX_FN1},
+	  {HOST_PAGE_NUM_FN2, HOSTFN2_INT_STATUS,
+		HOSTFN2_INT_MASK, HOST_MSIX_ERR_INDEX_FN2},
+	  {HOST_PAGE_NUM_FN3, HOSTFN3_INT_STATUS,
+		HOSTFN3_INT_MASK, HOST_MSIX_ERR_INDEX_FN3},
+	};
+/**
+ * bna_init()
+ *
+ *   Called by the driver during initialization. The driver is
+ *   expected to allocate bna_dev_s structure for the BNA layer.
+ *
+ * @param[in]  bar0        - BAR0 value
+ * @param[in]  bna_handle  - pointer to BNA device structure
+ *      		     allocated by the calling driver
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void
+bna_init(struct bna_dev_s *dev, void *bar0, void *stats,
+	 struct bna_dma_addr stats_dma, struct bfa_trc_mod_s *trcmod)
+{
+	u32 pcifn;
+
+	memset(dev, 0, sizeof(struct bna_dev_s));
+
+	dev->trcmod = trcmod;
+
+	dev->bar0 = (u8 *)bar0;
+	dev->hw_stats = (struct bfi_ll_stats *)stats;
+	dev->hw_stats_dma.msb = stats_dma.msb;
+	dev->hw_stats_dma.lsb = stats_dma.lsb;
+
+	dev->rxf_promiscuous_id = BNA_RXF_ID_NONE;
+	dev->rxf_default_id = BNA_RXF_ID_NONE;
+
+	pcifn = bna_reg_read(dev->bar0 + FNC_ID_REG);
+	pcifn = bna_reg_read(dev->bar0 + FNC_ID_REG);
+	BNA_ASSERT(pcifn <= 3);
+
+	dev->regs.page_addr = dev->bar0 + reg_offset[pcifn].page_addr;
+	dev->regs.fn_int_status = dev->bar0 + reg_offset[pcifn].fn_int_status;
+	dev->regs.fn_int_mask = dev->bar0 + reg_offset[pcifn].fn_int_mask;
+
+	if (pcifn < 3)
+		dev->port = 0;
+	else
+		dev->port = 1;
+
+	dev->pci_fn = pcifn;
+	DPRINTK(DEBUG, "LL Driver Using PCI fn (%d)\n", dev->pci_fn);
+
+	dev->ioc_disable_pending = 0;
+}
+
+/**
+ * bna_uninit()
+ *
+ *   Called by the driver during removal/unload.
+ *
+ * @param[in]  bna_handle  - pointer to BNA device structure
+ *      		     allocated by the calling driver
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_uninit(void *bna_handle)
+{
+	return BNA_OK;
+}
+
+/**
+ *  bna_rit_config_set()
+ *
+ *  Loads RIT entries "rit" into RIT starting from RIT index "rit_id".
+ *  Care must be taken not to overlap regions within the RIT.
+ *
+ * @param[in]  dev          - pointer to BNA device structure
+ * @param[in]  rit_offset   - offset into the RIT
+ * @param[in]  rit          - RIT entry
+ * @param[in]  rit_size     - size of RIT entry
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void
+bna_rit_config_set(struct bna_dev_s *dev, unsigned int rit_offset,
+		    const struct bna_rit_entry rit[], unsigned int rit_size)
+{
+	int i;
+
+	struct bna_rit_mem *rit_mem;
+
+	BNA_ASSERT(BNA_POWER_OF_2(rit_size));
+	BNA_ASSERT((rit_offset + rit_size) < BNA_RIT_SIZE);
+
+	rit_mem = (struct bna_rit_mem *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, FUNCTION_TO_RXQ_TRANSLATE);
+
+	dev->rit_size[rit_offset] = rit_size;
+
+	bna_reg_write(dev->regs.page_addr,
+		BNA_GET_PAGE_NUM(RXA0_MEM_BLK_BASE_PG_NUM + dev->port,
+		FUNCTION_TO_RXQ_TRANSLATE));
+
+	for (i = 0;  i < rit_size;  i++) {
+		bna_mem_writew(&rit_mem[i + rit_offset],
+		    rit[i].large_rxq_id << 6 | rit[i].small_rxq_id);
+	}
+}
+
+/**
+ * bna_rxf_config_set()
+ *
+ *   For RxF "rxf_id", it configures RxF based on "cfg_ptr", and indicates
+ *   to the statistics collector to collect statistics for this Rx-Function.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  cfg_ptr - pointer to rx-function configuration.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_config_set(struct bna_dev_s *dev, unsigned int rxf_id,
+				 const struct bna_rxf_config *cfg_ptr)
+{
+	u32 i;
+
+	struct bna_rss_mem *rss_mem;
+	struct bna_rx_fndb_ram *rx_fndb_ram;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	rss_mem = (struct bna_rss_mem *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, RSS_TABLE_BASE_OFFSET);
+	rx_fndb_ram = (struct bna_rx_fndb_ram *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, RX_FNDB_RAM_BASE_OFFSET);
+
+	/* Need to revisit, don't do this check */
+	if (((cfg_ptr->flags & BNA_RXF_CF_SM_LG_RXQ)) &&
+	    (cfg_ptr->hds.type == 1)) {
+		/* HDS and small-large RxQs are mutually exclusive */
+		DPRINTK(ERR,
+			"Small/Large & HDS cannot be set simultaneously\n");
+		return BNA_FAIL;
+	}
+
+	if (cfg_ptr->flags & BNA_RXF_CF_RSS_ENABLE) {
+		BNA_ASSERT(cfg_ptr->rss.hash_mask ==
+		    dev->rit_size[cfg_ptr->rit_offset] - 1);
+
+		/* configure RSS Table */
+		bna_reg_write(dev->regs.page_addr, BNA_GET_PAGE_NUM(
+			RAD0_MEM_BLK_BASE_PG_NUM + dev->port,
+			RSS_TABLE_BASE_OFFSET));
+
+		/* temporarily disable RSS, while hash value is being written */
+		bna_mem_writew(&rss_mem[0].type_n_hash, 0);
+
+		for (i = 0; i < BNA_RSS_HASH_KEY_LEN; i++) {
+			bna_mem_writew(
+				&rss_mem[0].hash_key[(
+				BNA_RSS_HASH_KEY_LEN - 1) - i],
+			    bna_os_htonl(cfg_ptr->rss.toeplitz_hash_key[i]));
+		}
+
+		bna_mem_writew(&rss_mem[0].type_n_hash, cfg_ptr->rss.type |
+				cfg_ptr->rss.hash_mask);
+
+	}
+	/* configure RxF based on "cfg_ptr" */
+	bna_reg_write(dev->regs.page_addr, BNA_GET_PAGE_NUM(
+		LUT0_MEM_BLK_BASE_PG_NUM + (dev->port * 2),
+			RX_FNDB_RAM_BASE_OFFSET));
+
+	/* we always use RSS table 0 */
+	bna_mem_writew(&rx_fndb_ram[rxf_id].rss_prop,
+		       cfg_ptr->flags & BNA_RXF_CF_RSS_ENABLE);
+
+	/* small large buffer enable/disable */
+	bna_mem_writew(&rx_fndb_ram[rxf_id].size_routing_props,
+		      (cfg_ptr->flags & BNA_RXF_CF_SM_LG_RXQ) | 0x80);
+
+	/* RIT offset, HDS forced offset, multicast RxQ Id*/
+	bna_mem_writew(&rx_fndb_ram[rxf_id].rit_hds_mcastq,
+			(cfg_ptr->rit_offset << 16) |
+			(cfg_ptr->hds.forced_offset << 8) |
+			(cfg_ptr->hds.type & BNA_HDS_FORCED) |
+			cfg_ptr->mcast_rxq_id);
+
+	/* default vlan tag, default function enable, strip vlan bytes,
+	   HDS type, header size */
+	bna_mem_writew(&rx_fndb_ram[rxf_id].control_flags,
+		      (cfg_ptr->default_vlan << 16) | (cfg_ptr->flags &
+			(BNA_RXF_CF_DEFAULT_VLAN |
+			BNA_RXF_CF_DEFAULT_FUNCTION_ENABLE |
+			 BNA_RXF_CF_VLAN_STRIP)) |
+			(cfg_ptr->hds.type & ~BNA_HDS_FORCED) |
+			cfg_ptr->hds.header_size);
+
+	/* turn on statistics collection for this RxF */
+	dev->rxf_active |= ((u64)1 << rxf_id);
+	return BNA_OK;
+}
+
+/**
+ * bna_rxf_config_clear()
+ *
+ *   For RxF "rxf_id", it clear its configuration and indicates to the
+ *   statistics collector to stop collecting statistics for this
+ *   Rx-Function.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void
+bna_rxf_config_clear(struct bna_dev_s *dev, unsigned int rxf_id)
+{
+	struct bna_rx_fndb_ram *rx_fndb_ram;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	rx_fndb_ram = (struct bna_rx_fndb_ram *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, RX_FNDB_RAM_BASE_OFFSET);
+
+	/* clear configuration of RxF base */
+	bna_reg_write(dev->regs.page_addr,
+	    BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM +
+	    (dev->port * 2), RX_FNDB_RAM_BASE_OFFSET));
+
+	/* we always use RSS table 0 */
+	bna_mem_writew(&rx_fndb_ram[rxf_id].rss_prop, 0);
+
+	/* small large buffer enable/disable */
+	bna_mem_writew(&rx_fndb_ram[rxf_id].size_routing_props, 0x80);
+
+	/* RIT offset, HDS forced offset, multicast RxQ Id*/
+	bna_mem_writew(&rx_fndb_ram[rxf_id].rit_hds_mcastq, 0);
+
+	/* default vlan tag, default function enable, strip vlan bytes,
+	   HDS type, header size */
+	bna_mem_writew(&rx_fndb_ram[rxf_id].control_flags, 0);
+
+	/* turn off statistics collection for this RxF */
+	dev->rxf_active &= ~((u64)1 << rxf_id);
+}
+
+/**
+ * bna_rxf_disable()
+ *
+ *  Disables the Rx Function without clearing the configuration
+ *  Also disables collection of statistics.
+ *
+ * @param[in] dev   	- Pointer to BNA device handle
+ * @param[in] rxf_id    - Id of the Rx Function to be disabled
+ *
+ * @return    BNA_OK if mbox command succeeded, else BNA_FAIL
+ */
+enum bna_status_e
+bna_rxf_disable(struct bna_dev_s *dev, unsigned int rxf_id)
+{
+	struct bfi_ll_rxf_multi_req ll_req;
+	u64 bit_mask = 1 << rxf_id;
+	enum bna_status_e status;
+
+	bfi_h2i_set(ll_req.mh, BFI_MC_LL, BFI_LL_H2I_RX_REQ, 0);
+	ll_req.rxf_id_mask[0] = bna_os_htonl((u32)bit_mask);
+	ll_req.rxf_id_mask[1] = bna_os_htonl((u32)(bit_mask >> 32));
+	ll_req.enable = 0;
+
+	status = bna_mbox_send(dev, &ll_req, sizeof(ll_req), dev->cbarg);
+	if (!status)
+		dev->rxf_active &= ~bit_mask;
+	return status;
+}
+
+
+/* TODO : Delete when Windows migration is complete */
+void
+bna_rxf_disable_old(struct bna_dev_s *dev, unsigned int rxf_id)
+{
+	struct bna_rx_fndb_ram *rx_fndb_ram;
+	u32 ctl_flags;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	/* Clear the vlan table first, before writing to the Rx Fn DB */
+	bna_rxf_vlan_del_all(dev, rxf_id);
+
+	rx_fndb_ram = (struct bna_rx_fndb_ram *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, RX_FNDB_RAM_BASE_OFFSET);
+
+	bna_reg_write(dev->regs.page_addr,
+		BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM + (dev->port * 2),
+		RX_FNDB_RAM_BASE_OFFSET));
+
+	ctl_flags = bna_mem_readw(&rx_fndb_ram[rxf_id].control_flags);
+
+	/* Enable setting of the default vlan tag for untagged packets */
+	/* Don't need to store these already there in the BNA config */
+	ctl_flags |= BNA_RXF_CF_DEFAULT_VLAN;
+
+	bna_mem_writew(&rx_fndb_ram[rxf_id].control_flags, ctl_flags);
+
+	/* turn off statistics collection for this RxF */
+	dev->rxf_active &= ~((u64)1 << rxf_id);
+}
+
+/**
+ * bna_rxf_enable()
+ *
+ *  Enables the Rx Function
+ *
+ * @param[in] dev   	- Pointer to BNA device handle
+ * @param[in] rxf_id    - Id of the Rx Function to be disabled
+ *
+ * @return    BNA_OK if mbox command succeeded, else BNA_FAIL
+ */
+enum bna_status_e
+bna_rxf_enable(struct bna_dev_s *dev, unsigned int rxf_id)
+{
+	struct bfi_ll_rxf_multi_req ll_req;
+	u64 bit_mask = 1 << rxf_id;
+	enum bna_status_e status;
+
+	bfi_h2i_set(ll_req.mh, BFI_MC_LL, BFI_LL_H2I_RX_REQ, 0);
+	ll_req.rxf_id_mask[0] = bna_os_htonl((u32)bit_mask);
+	ll_req.rxf_id_mask[1] = bna_os_htonl((u32)(bit_mask >> 32));
+	ll_req.enable = 1;
+
+	status = bna_mbox_send(dev, &ll_req, sizeof(ll_req), dev->cbarg);
+	if (!status)
+		dev->rxf_active |= bit_mask;
+	return status;
+}
+
+
+enum bna_status_e
+bna_multi_rxf_active(struct bna_dev_s *dev, u64 rxf_id_mask, u8 enable)
+{
+	struct bfi_ll_rxf_multi_req ll_req;
+	enum bna_status_e status;
+
+	bfi_h2i_set(ll_req.mh, BFI_MC_LL, BFI_LL_H2I_RX_REQ, 0);
+	ll_req.rxf_id_mask[0] = bna_os_htonl((u32)rxf_id_mask);
+	ll_req.rxf_id_mask[1] = bna_os_htonl((u32)(rxf_id_mask >> 32));
+	ll_req.enable = enable;
+
+	status = bna_mbox_send(dev, &ll_req, sizeof(ll_req), dev->cbarg);
+	if (!status) {
+		if (enable)
+			dev->rxf_active |= rxf_id_mask;
+		else
+			dev->rxf_active &= ~rxf_id_mask;
+	}
+	return status;
+}
+
+/**
+ * bna_rxf_ucast_mac_set()
+ *
+ *  For RxF "rxf_id", it overwrites the burnt-in unicast MAC with
+ *  the one specified by "mac_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_addr_ptr - pointer to mac adddress to set
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_ucast_mac_set(struct bna_dev_s *dev, unsigned int rxf_id,
+		       const u8 *mac_addr_ptr)
+{
+	struct bfi_ll_mac_addr_req cmd;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	/* we are supposed to set MAC adresses for default RxF only */
+	if (dev->rxf_default_id == BNA_RXF_ID_NONE) {
+		if (rxf_id != BNA_DEFAULT_RXF_ID) {
+			DPRINTK(ERR,
+				"RxF Id [%d] Not Default RxF Id\n", rxf_id);
+			return BNA_FAIL;
+		}
+	} else {
+		if (rxf_id != dev->rxf_default_id) {
+			DPRINTK(ERR,
+			"RxF Id[%d] Not current Default RxF Id" "[%d]\n",
+				rxf_id, dev->rxf_default_id);
+			return BNA_FAIL;
+		}
+	}
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_MAC_UCAST_SET_REQ, 0);
+	cmd.rxf_id = rxf_id;
+	bna_os_memcpy(&cmd.mac_addr, mac_addr_ptr, sizeof(cmd.mac_addr));
+
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ * bna_rxf_ucast_mac_add()
+ *
+ *  For RxF "rxf_id", it adds the unicast MAC specified by "mac_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_addr_ptr - pointer to mac adddress to add
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_ucast_mac_add(struct bna_dev_s *dev, unsigned int rxf_id,
+		       const u8 *mac_addr_ptr)
+{
+	struct bfi_ll_mac_addr_req cmd;
+
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+	/* we are not supposed to add MAC adresses to default RxF */
+	if (rxf_id == dev->rxf_default_id) {
+		DPRINTK(ERR,
+			"Cannot add MAC address for default RxF[%d]\n", rxf_id);
+		return BNA_FAIL;
+	}
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_MAC_UCAST_ADD_REQ, 0);
+
+	cmd.rxf_id = rxf_id;
+	bna_os_memcpy(&cmd.mac_addr, mac_addr_ptr, sizeof(cmd.mac_addr));
+
+	/* send command to firmware */
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ * bna_rxf_ucast_mac_del()
+ *
+ *  For RxF "rxf_id", it deletes the unicast MAC specified by "mac_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_addr_ptr - pointer to mac adddress to add
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_ucast_mac_del(struct bna_dev_s *dev, unsigned int rxf_id,
+		       const u8 *mac_addr_ptr)
+{
+	struct bfi_ll_mac_addr_req cmd;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	/* we are not supposed to delete MAC adresses from default RxF */
+	if (rxf_id == dev->rxf_default_id) {
+		DPRINTK(ERR,
+			"Cannot del MAC address for default RxF[%d]\n", rxf_id);
+		return BNA_FAIL;
+	}
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_MAC_UCAST_DEL_REQ, 0);
+
+	cmd.rxf_id = rxf_id;
+	bna_os_memcpy(&cmd.mac_addr, mac_addr_ptr, sizeof(cmd.mac_addr));
+
+	/* send command to firmware */
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ * bna_rxf_mcast_mac_add()
+ *
+ *  For RxF "rxf_id", it adds the multicast MAC specified by
+ *  "mac_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_addr_ptr - pointer to mac adddress to add
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_mcast_mac_add(struct bna_dev_s *dev, unsigned int rxf_id,
+		       const u8 *mac_addr_ptr)
+{
+	u32 mac_47_32, mac_31_0, i;
+	u8 *mac_ptr = (u8 *)mac_addr_ptr;
+	struct bfi_ll_mac_addr_req cmd;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	mac_47_32 = (mac_ptr[0] << 8) | mac_ptr[1];
+	mac_31_0  = (mac_ptr[2] << 24) | (mac_ptr[3] << 16) |
+		    (mac_ptr[4] << 8) | mac_ptr[5];
+
+	for (i = 0; i < BNA_MCAST_TABLE_SIZE; i++) {
+		if ((mac_47_32 == dev->mcast_47_32[i]) &&
+		   (mac_31_0 == dev->mcast_31_0[i])) {
+			/* existing entry found, stop and use it */
+			break;
+		}
+	}
+
+	if (i == BNA_MCAST_TABLE_SIZE) {
+		/* no existing entry found we need to find the
+		first unused entry */
+		for (i = 0; i < BNA_MCAST_TABLE_SIZE; i++) {
+			if ((dev->mcast_47_32[i] == 0) &&
+			   (dev->mcast_31_0[i] == 0)) {
+				/* unused entry found, stop and use it */
+				break;
+			}
+		}
+	}
+
+	if (i == BNA_MCAST_TABLE_SIZE) {
+		/* no entry available, table full */
+		DPRINTK(ERR, "Multicast MAC table is full\n");
+		return BNA_FAIL;
+	}
+
+	dev->mcast_47_32[i] = mac_47_32;
+	dev->mcast_31_0[i] = mac_31_0;
+
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_MAC_MCAST_ADD_REQ, 0);
+
+	cmd.rxf_id = rxf_id;
+	bna_os_memcpy(&cmd.mac_addr, mac_addr_ptr, sizeof(cmd.mac_addr));
+
+	/* send command to firmware */
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ * bna_rxf_mcast_mac_del()
+ *
+ *  For RxF "rxf_id", it deletes the multicast MAC specified by
+ *  "mac_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_addr_ptr - pointer to mac adddress to add
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_mcast_mac_del(struct bna_dev_s *dev, unsigned int rxf_id,
+		       const u8 *mac_addr_ptr)
+{
+	u32 mac_47_32, mac_31_0, i;
+	u8 *mac_ptr = (u8 *)mac_addr_ptr;
+	struct bfi_ll_mac_addr_req cmd;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	mac_47_32 = (mac_ptr[0] << 8) | mac_ptr[1];
+	mac_31_0  = (mac_ptr[2] << 24) | (mac_ptr[3] << 16) |
+		    (mac_ptr[4] << 8) | mac_ptr[5];
+
+	for (i = 0; i < BNA_MCAST_TABLE_SIZE; i++) {
+		if ((mac_47_32 == dev->mcast_47_32[i]) &&
+		   (mac_31_0 == dev->mcast_31_0[i])) {
+			/* existing entry found, stop and use it */
+			break;
+		}
+	}
+
+	if (i == BNA_MCAST_TABLE_SIZE) {
+		/* no existing entry found */
+		DPRINTK(ERR, "MAC 0x%x:%x not found\n", mac_47_32, mac_31_0);
+		return BNA_FAIL;
+	}
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_MAC_MCAST_DEL_REQ, 0);
+
+	cmd.rxf_id = rxf_id;
+	bna_os_memcpy(&cmd.mac_addr, mac_addr_ptr, sizeof(cmd.mac_addr));
+
+
+	dev->mcast_47_32[i] = 0;
+	dev->mcast_31_0[i] = 0;
+
+	/* send command to firmware */
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+static void
+bna_mac_addr_to_string(u32 mac_47_32, u32 mac_31_0, u8 *mac)
+{
+	u8 *mac_ptr = (u8 *)mac;
+	int i;
+
+	for (i = 1; i >= 0; i--)
+		mac_ptr[1-i] = ((mac_47_32) & (0xff << (i*8))) >> (i * 8);
+
+	mac_ptr = &mac_ptr[2];
+	for (i = 3; i >= 0; i--)
+		mac_ptr[3-i] = ((mac_31_0) & (0xff << (i*8))) >> (i * 8);
+}
+
+/**
+ * bna_rxf_mcast_mac_set_list()
+ *
+ *  For RxF "rxf_id", it sets the multicast MAC addresses
+ *  specified by "mac_addr_ptr". The function first deletes the MAC addresses in
+ *  the existing list that is not found in the new list. It then adds the new
+ *  addresses that are in the new list but not in the old list. It then replaces
+ *  the old list with the new list in the bna_dev structure.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_addr_ptr - pointer to the list of mac
+ *       adddresses to set
+ * @param[in]  mac_addr_num - number of mac addresses in the
+ *       list
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_mcast_mac_set_list(struct bna_dev_s *dev, unsigned int rxf_id,
+			    const u8 *mac_addr_ptr ,
+			    unsigned int mac_addr_num)
+{
+	u32 *mcast_47_32 = &dev->tmp_mc_47_32[0];
+	u32 *mcast_31_0 = &dev->tmp_mc_31_0[0];
+	u32 i, j;
+	u8 *mac_ptr = (u8 *)mac_addr_ptr;
+	int found;
+	struct bfi_ll_mac_addr_req cmd;
+	u8 tmp_mac[ETH_ALEN];
+
+	bna_os_memset(mcast_47_32, 0, sizeof(u32) * BNA_MCAST_TABLE_SIZE);
+	bna_os_memset(mcast_31_0, 0, sizeof(u32) * BNA_MCAST_TABLE_SIZE);
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+	if (mac_addr_num > BNA_MCAST_TABLE_SIZE) {
+		DPRINTK(ERR,
+			"Too many Multicast Addresses [%d]\n", mac_addr_num);
+		return BNA_FAIL;
+	}
+
+	for (i = 0; i < mac_addr_num; i++) {
+		if (!BNA_MAC_IS_MULTICAST(mac_ptr[i * 6]))
+			return BNA_FAIL;
+		mcast_47_32[i] = (mac_ptr[i * 6] << 8) | mac_ptr[i * 6 + 1];
+		mcast_31_0[i] = (mac_ptr[i * 6 + 2] << 24) |
+				(mac_ptr[i * 6 + 3] << 16) |
+				(mac_ptr[i * 6 + 4] << 8) |
+				mac_ptr[i * 6 + 5];
+		if ((mcast_47_32[i] == 0) && (mcast_31_0[i] == 0))
+			return BNA_FAIL;
+		DPRINTK(DEBUG, "Multicast Addr %d : 0x%x:0x%x\n",
+			i, mcast_47_32[i], mcast_31_0[i]);
+	}
+
+	/* find MAC addresses to delete */
+	for (i = 0; i < BNA_MCAST_TABLE_SIZE; i++) {
+		if ((dev->mcast_47_32[i] == 0) && (dev->mcast_31_0[i] == 0))
+			continue;
+
+		found = 0;
+		for (j = 0; j < mac_addr_num; j++) {
+			if ((mcast_47_32[j] == dev->mcast_47_32[i]) &&
+			   (mcast_31_0[j] == dev->mcast_31_0[i])) {
+				found = 1;
+				break;
+			}
+		}
+		if (!found) {
+			bfi_h2i_set(cmd.mh, BFI_MC_LL,
+			     BFI_LL_H2I_MAC_MCAST_DEL_REQ, 0);
+			cmd.rxf_id = rxf_id;
+				bna_mac_addr_to_string(dev->mcast_47_32[i],
+						       dev->mcast_31_0[i],
+						       &tmp_mac[0]);
+				bna_os_memcpy(&cmd.mac_addr, &tmp_mac,
+					      sizeof(cmd.mac_addr));
+
+			DPRINTK(INFO,
+			"Deleting MCAST MAC 0x%x:0x%x on port %u RxF %u\n",
+				dev->mcast_47_32[i], dev->mcast_31_0[i],
+				dev->port, rxf_id);
+
+
+			if (BNA_FAIL == bna_mbox_send(dev, &cmd, sizeof(cmd),
+			    dev->cbarg)) {
+				DPRINTK(ERR,
+					"Failed to add to cmd [%d/%d] "
+					"for RxF %d to Q.. Aborting\n",
+					cmd.mh.msg_class, cmd.mh.msg_id,
+					cmd.rxf_id);
+				return BNA_FAIL;
+			}
+		}
+	}
+
+	/* find MAC addresses to add */
+	for (i = 0; i < mac_addr_num; i++) {
+		found = 0;
+
+		for (j = 0; j < BNA_MCAST_TABLE_SIZE; j++) {
+			if ((mcast_47_32[i] == dev->mcast_47_32[j]) &&
+			   (mcast_31_0[i] == dev->mcast_31_0[j])) {
+				found = 1;
+				break;
+			}
+		}
+		if (!found) {
+			bfi_h2i_set(cmd.mh, BFI_MC_LL,
+			     BFI_LL_H2I_MAC_MCAST_ADD_REQ, 0);
+			cmd.rxf_id = rxf_id;
+			bna_mac_addr_to_string(mcast_47_32[i],
+				mcast_31_0[i], &tmp_mac[0]);
+			bna_os_memcpy(&cmd.mac_addr, &tmp_mac,
+					      sizeof(cmd.mac_addr));
+
+			DPRINTK(INFO,
+			"Adding MCAST MAC 0x%x:0x%x on port %u RxF %u\n",
+				mcast_47_32[i], mcast_31_0[i],
+				dev->port, rxf_id);
+
+
+			if (BNA_FAIL == bna_mbox_send(dev, &cmd, sizeof(cmd),
+			    dev->cbarg)) {
+				DPRINTK(ERR,
+					"Failed to add to cmd [%d/%d] "
+					"for RxF %d to Q.. Aborting\n",
+					cmd.mh.msg_class, cmd.mh.msg_id,
+					cmd.rxf_id);
+				return BNA_FAIL;
+			}
+		}
+	}
+
+	bna_os_memset(&dev->mcast_47_32[0], 0, sizeof(u32) *
+		      BNA_MCAST_TABLE_SIZE);
+	bna_os_memset(&dev->mcast_31_0[0], 0, sizeof(u32) *
+		      BNA_MCAST_TABLE_SIZE);
+
+	bna_os_memcpy(&dev->mcast_47_32[0], &mcast_47_32[0],
+		      sizeof(u32) * mac_addr_num);
+	bna_os_memcpy(&dev->mcast_31_0[0],  &mcast_31_0[0],
+		      sizeof(u32) * mac_addr_num);
+
+	return BNA_OK;
+}
+
+/**
+ * bna_mcast_mac_reset_list()
+ *
+ *  Resets the multicast MAC address list kept by driver.
+ *  Called when the hw gets reset.
+ *
+ * @param[in]  dev  - pointer to BNA device structure
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void
+bna_mcast_mac_reset_list(struct bna_dev_s *dev)
+{
+
+	bna_os_memset(&dev->mcast_47_32[0], 0, sizeof(u32) *
+	    BNA_MCAST_TABLE_SIZE);
+	bna_os_memset(&dev->mcast_31_0[0], 0, sizeof(u32) *
+	    BNA_MCAST_TABLE_SIZE);
+}
+
+/**
+ *  bna_rxf_broadcast()
+ *
+ *  For RxF "rxf_id", it enables/disables the broadcast address.
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  enable - enable/disable broadcast address
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_broadcast(struct bna_dev_s *dev, unsigned int rxf_id,
+	enum bna_enable_e enable)
+{
+	const u8 broadcast_addr[ETH_ALEN] =
+		{0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
+
+	if (enable)
+		return bna_rxf_mcast_mac_add(dev, rxf_id, &broadcast_addr[0]);
+
+	return bna_rxf_mcast_mac_del(dev, rxf_id, &broadcast_addr[0]);
+}
+
+/**
+ *  bna_rxf_vlan_add()
+ *
+ *  For RxF "rxf_id", it adds this function as a member of the
+ *  specified "vlan_id".
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  vlan_id - VLAN id to be added
+ *
+ * @return void
+ */
+void bna_rxf_vlan_add(struct bna_dev_s *dev, unsigned int rxf_id,
+	unsigned int vlan_id)
+{
+
+	u32 new_vlan_id;
+
+	BNA_ASSERT((rxf_id <= BNA_RXF_ID_MAX));
+	/*
+	 * wrap the vlan_id around in case it
+	 * overflows the max limit
+	 */
+	new_vlan_id = vlan_id & BNA_VLAN_ID_MAX;
+	BNA_BIT_TABLE_SET(dev->vlan_table[rxf_id], new_vlan_id);
+
+	if (dev->vlan_filter_enable[rxf_id] &&
+	   (dev->rxf_active & ((u64)1 << rxf_id))) {
+		/* add VLAN ID on this function */
+		bna_reg_write(dev->regs.page_addr,
+			BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM +
+						    (dev->port * 2),
+						    VLAN_RAM_BASE_OFFSET));
+		bna_mem_writew(BNA_GET_VLAN_MEM_ENTRY_ADDR(dev->bar0, rxf_id ,
+		    new_vlan_id), dev->vlan_table[rxf_id][new_vlan_id/32]);
+	}
+}
+
+/**
+ *  bna_rxf_vlan_del()
+ *
+ *  For RxF "rxf_id", it removes this function as a member of the
+ *  specified "vlan_id".
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  vlan_id - VLAN id to be removed
+ *
+ * @return void
+ */
+void bna_rxf_vlan_del(struct bna_dev_s *dev, unsigned int rxf_id,
+	unsigned int vlan_id)
+{
+
+	u32 new_vlan_id;
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	new_vlan_id = vlan_id & BNA_VLAN_ID_MAX;
+	BNA_BIT_TABLE_CLEAR(dev->vlan_table[rxf_id], new_vlan_id);
+
+	if (dev->vlan_filter_enable[rxf_id] &&
+		(dev->rxf_active & ((u64)1 << rxf_id))) {
+		bna_reg_write(dev->regs.page_addr,
+		BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM +
+		    (dev->port * 2), VLAN_RAM_BASE_OFFSET));
+		bna_mem_writew(BNA_GET_VLAN_MEM_ENTRY_ADDR(dev->bar0, rxf_id ,
+		    new_vlan_id), dev->vlan_table[rxf_id][new_vlan_id/32]);
+	}
+}
+
+/**
+ *  bna_rxf_vlan_filter()
+ *
+ *   For RxF "rxf_id", it enables/disables the VLAN filter.
+ *   Disabling the VLAN Filter allows reception of any VLAN-tagged frame.
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  enable - enable/disable VLAN Filtering.
+ *
+ * @return void
+ */
+void bna_rxf_vlan_filter(struct bna_dev_s *dev, unsigned int rxf_id,
+	enum bna_enable_e enable)
+{
+	u32 i;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	dev->vlan_filter_enable[rxf_id] = enable;
+
+	bna_reg_write(dev->regs.page_addr,
+		  BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM + (dev->port * 2),
+				VLAN_RAM_BASE_OFFSET));
+
+	if (enable) {
+		/* enable VLAN filtering on this function */
+		for (i = 0; i <= BNA_VLAN_ID_MAX/32; i++) {
+			bna_mem_writew(BNA_GET_VLAN_MEM_ENTRY_ADDR(dev->bar0,
+			    rxf_id, i * 32), dev->vlan_table[rxf_id][i]);
+		}
+	} else {
+		/* disable VLAN filtering on this function */
+		for (i = 0; i <= BNA_VLAN_ID_MAX/32; i++) {
+			bna_mem_writew(BNA_GET_VLAN_MEM_ENTRY_ADDR(dev->bar0,
+					rxf_id, i * 32), 0xffffffff);
+		}
+	}
+}
+
+/**
+ * bna_rxf_vlan_del_all()
+ *
+ *   For RxF "rxf_id", it clears all the VLANs.
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ *
+ * @return void
+ */
+void
+bna_rxf_vlan_del_all(struct bna_dev_s *dev, unsigned int rxf_id)
+{
+	u32 i;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	bna_reg_write(dev->regs.page_addr,
+		  BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM + (dev->port * 2),
+				    VLAN_RAM_BASE_OFFSET));
+
+	/* clear all VLANs for this function */
+	for (i = 0; i <= BNA_VLAN_ID_MAX/32; i++) {
+		bna_mem_writew(BNA_GET_VLAN_MEM_ENTRY_ADDR(dev->bar0, rxf_id,
+		    i * 32), 0);
+	}
+}
+
+
+/**
+ *  bna_rxf_mcast_filter()
+ *
+ *   For RxF "rxf_id", it enables/disables the multicast filter.
+ *   Disabling the multicast filter allows reception of any
+ *   multicast frame.
+ *
+ * @param[in]  dev      - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  enable - enable/disable multicast Filtering.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_mcast_filter(struct bna_dev_s *dev,
+	unsigned int rxf_id, enum bna_enable_e enable)
+{
+
+	struct bfi_ll_mcast_filter_req cmd;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_MAC_MCAST_FILTER_REQ, 0);
+
+	cmd.rxf_id = rxf_id;
+	cmd.enable = enable;
+
+	/* send command to firmware*/
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ * bna_rxf_mcast_del_all()
+ *
+ *   For RxF "rxf_id", it clears the MCAST cam and MVT.
+ *   This functionality is required by some of the drivers.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_mcast_del_all(struct bna_dev_s *dev, unsigned int rxf_id)
+{
+	struct bfi_ll_mcast_del_all_req cmd;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_MAC_MCAST_DEL_ALL_REQ, 0);
+
+	cmd.rxf_id = rxf_id;
+
+	 /* send command to firmware*/
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ *  bna_rxf_promiscuous()
+ *
+ *  For RxF "rxf_id", it enables/disables promiscuous mode.
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  enable - enable/disable promiscious mode
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_promiscuous(struct bna_dev_s *dev,
+	unsigned int rxf_id, enum bna_enable_e enable)
+{
+	struct bfi_ll_rxf_req cmd;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_RXF_PROMISCUOUS_SET_REQ, 0);
+
+	cmd.rxf_id = rxf_id;
+	cmd.enable = enable;
+
+
+	/*
+	 * Need to revisit.
+	 * Can the second check be an ASSERT ?
+	 */
+	if (enable && (dev->rxf_promiscuous_id == BNA_RXF_ID_NONE)) {
+		dev->rxf_promiscuous_id = rxf_id;
+
+		/* allow all VLANs*/
+		bna_rxf_vlan_filter(dev, rxf_id, BNA_DISABLE);
+
+		return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+	} else if (!enable && (dev->rxf_promiscuous_id == rxf_id)) {
+		dev->rxf_promiscuous_id = BNA_RXF_ID_NONE;
+
+		/* Revert VLAN filtering */
+		bna_rxf_vlan_filter(dev, rxf_id,
+			dev->vlan_filter_enable[rxf_id]);
+
+		return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+	}
+
+	return BNA_FAIL;
+}
+
+/**
+ *  bna_rxf_default_mode()
+ *
+ *  For RxF "rxf_id", it enables/disables default mode.
+ *  Must be called after the RxF has been configured.
+ *  Must remove all unicast MAC associated to this RxF.
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  enable - enable/disable default mode
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_default_mode(struct bna_dev_s *dev,
+	unsigned int rxf_id, enum bna_enable_e enable)
+{
+	struct bna_rx_fndb_ram *rx_fndb_ram;
+	u32 i, ctl_flags;
+	struct bfi_ll_rxf_req cmd;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+
+	rx_fndb_ram = (struct bna_rx_fndb_ram *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, RX_FNDB_RAM_BASE_OFFSET);
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_RXF_DEFAULT_SET_REQ, 0);
+
+	cmd.rxf_id = rxf_id;
+	cmd.enable = enable;
+
+	/*
+	 * Need to revisit.
+	 * Can the second check be an ASSERT ?
+	 */
+	if (enable && (dev->rxf_default_id == BNA_RXF_ID_NONE)) {
+		dev->rxf_default_id = rxf_id;
+
+		/* allow all VLANs*/
+		bna_rxf_vlan_filter(dev, rxf_id, BNA_DISABLE);
+
+		bna_reg_write(dev->regs.page_addr,
+			BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM +
+					  (dev->port * 2),
+					  RX_FNDB_RAM_BASE_OFFSET));
+
+		for (i = 0; i < BNA_RXF_ID_MAX; i++) {
+			if (i == rxf_id)
+				continue;
+
+			ctl_flags =
+				bna_mem_readw(&rx_fndb_ram[i].control_flags);
+			ctl_flags |= BNA_RXF_CF_DEFAULT_FUNCTION_ENABLE;
+			bna_mem_writew(&rx_fndb_ram[i].control_flags,
+				ctl_flags);
+		}
+		return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+	} else if (!enable && (dev->rxf_default_id == rxf_id)) {
+		dev->rxf_default_id = BNA_RXF_ID_NONE;
+
+		/* Revert  VLAN filtering */
+		bna_rxf_vlan_filter(dev, rxf_id,
+			dev->vlan_filter_enable[rxf_id]);
+
+		bna_reg_write(dev->regs.page_addr,
+			BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM +
+					  (dev->port * 2),
+					  RX_FNDB_RAM_BASE_OFFSET));
+
+		for (i = 0; i < BNA_RXF_ID_MAX; i++) {
+			ctl_flags =
+				bna_mem_readw(&rx_fndb_ram[i].control_flags);
+			ctl_flags &= ~BNA_RXF_CF_DEFAULT_FUNCTION_ENABLE;
+			bna_mem_writew(&rx_fndb_ram[i].control_flags,
+				ctl_flags);
+		}
+		return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+	}
+
+	return BNA_FAIL;
+}
+
+/**
+ *  bna_rxf_frame_stats_get()
+ *
+ *  For RxF "rxf_id", it loads frame statistics into "stats_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[out]  stats_ptr - pointer to stats structure to fill
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void
+bna_rxf_frame_stats_get(struct bna_dev_s *dev, unsigned int rxf_id,
+				  struct bna_stats_rxf **stats_ptr)
+{
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	*stats_ptr =  &dev->stats.rxf_stats[rxf_id];
+}
+
+/**
+ * bna_txf_frame_stats_get()
+ *
+ *   For TxF "txf_id", it loads frame statistics into "stats_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  txf_id    - tx-function ID.
+ * @param[out] stats_ptr - pointer to tx-function statistics.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void
+bna_txf_frame_stats_get(struct bna_dev_s *dev, unsigned int txf_id,
+				  struct bna_stats_txf **stats_ptr)
+{
+
+	BNA_ASSERT(txf_id < BNA_TXF_ID_MAX);
+
+	*stats_ptr = &dev->stats.txf_stats[txf_id];
+}
+
+/**
+ *  bna_mac_rx_stats_get()
+ *
+ *  Loads MAC Rx statistics into "stats_ptr".
+ *
+ * @param[in]  dev       - pointer to BNA device structure
+
+ * @param[out]  stats_ptr - pointer to stats structure to fill
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void
+bna_mac_rx_stats_get(struct bna_dev_s *dev, struct cna_stats_mac_rx **stats_ptr)
+{
+	*stats_ptr = &dev->stats.mac_rx_stats;
+}
+
+/**
+ *  bna_mac_tx_stats_get()
+ *
+ *  Loads MAC Tx statistics into "stats_ptr".
+ *
+ * @param[in]  dev       - pointer to BNA device structure
+
+ * @param[out]  stats_ptr - pointer to stats structure to fill
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void
+bna_mac_tx_stats_get(struct bna_dev_s *dev, struct cna_stats_mac_tx **stats_ptr)
+{
+	*stats_ptr = &dev->stats.mac_tx_stats;
+}
+
+/**
+ *  bna_all_stats_get()
+ *
+ *  Loads all statistics into "stats_ptr".
+ *
+ * @param[in]  dev       - pointer to BNA device structure
+
+ * @param[out]  stats_ptr - pointer to stats structure
+ *
+ * @return void
+ */
+void
+bna_all_stats_get(struct bna_dev_s *dev, struct bna_stats **stats_ptr)
+{
+	*stats_ptr = &dev->stats;
+}
+
+/**
+ * bna_stats_get()
+ *
+ *   Get the statistics from the device. This function needs to
+ *   be scheduled every second to get periodic update of the
+ *   statistics data from hardware.
+ *
+ * @param[in]   dev       - pointer to BNA device structure.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_stats_get(struct bna_dev_s *dev)
+{
+	struct bfi_ll_stats_req cmd;
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_STATS_GET_REQ, 0);
+
+	cmd.stats_mask    = bna_os_htons(BFI_LL_STATS_ALL);
+	cmd.rxf_id_mask[0]  = bna_os_htonl(
+				(u32)(dev->rxf_active & 0xffffffff));
+	cmd.rxf_id_mask[1]  = bna_os_htonl(
+				(u32)(dev->rxf_active >> 32));
+
+	cmd.txf_id_mask[0]  = bna_os_htonl(
+				(u32)(dev->txf_active & 0xffffffff));
+	cmd.txf_id_mask[1]  = bna_os_htonl((u32)(dev->txf_active >> 32));
+
+	cmd.host_buffer.a32.addr_hi = dev->hw_stats_dma.msb;
+	cmd.host_buffer.a32.addr_lo = dev->hw_stats_dma.lsb;
+
+	dev->rxf_active_last = dev->rxf_active;
+	dev->txf_active_last = dev->txf_active;
+
+	/* send command to firmware */
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ * bna_stats_clear()
+ *
+ *   Clear the statistics in the device.
+ *
+ * @param[in]   dev       - pointer to BNA device structure.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_stats_clear(struct bna_dev_s *dev)
+{
+	struct bfi_ll_stats_req cmd;
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_STATS_CLEAR_REQ, 0);
+
+	cmd.stats_mask = bna_os_htons(BFI_LL_STATS_ALL);
+	cmd.rxf_id_mask[0] = bna_os_htonl(
+				(u32)(dev->rxf_active & 0xffffffff));
+	cmd.rxf_id_mask[1] = bna_os_htonl((u32)(dev->rxf_active >> 32));
+
+	cmd.txf_id_mask[0] = bna_os_htonl(
+				(u32)(dev->txf_active & 0xffffffff));
+	cmd.txf_id_mask[1] = bna_os_htonl((u32)(dev->txf_active >> 32));
+
+	/* send command to firmware */
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+/**
+ * bna_rxf_stats_clear()
+ *
+ *   Clear the statistics for specified txf.
+ *
+ * @param[in]   dev        - pointer to BNA device structure.
+ * @param[in]  rxf_id      - rx-function ID.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_stats_clear(struct bna_dev_s *dev, unsigned int rxf_id)
+{
+	struct bfi_ll_stats_req cmd;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_STATS_CLEAR_REQ, 0);
+
+	cmd.stats_mask = 0;
+
+	if (rxf_id < 32) {
+		cmd.rxf_id_mask[0] = bna_os_htonl((u32)(1 << rxf_id));
+		cmd.rxf_id_mask[1] = 0;
+	} else {
+		cmd.rxf_id_mask[0] = 0;
+		cmd.rxf_id_mask[1] = bna_os_htonl(
+					(u32)(1 << (rxf_id - 32)));
+	}
+
+	cmd.txf_id_mask[0] = 0;
+	cmd.txf_id_mask[1] = 0;
+
+	/* send command to firmware */
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ * bna_lldp_stats_clear()
+ *
+ *   Clear the DCBCX-LLDP statistics in the f/w.
+ *
+ * @param[in]   dev       - pointer to BNA device structure.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_lldp_stats_clear(struct bna_dev_s *dev)
+{
+	struct bfi_lldp_reset_stats_s cmd;
+
+	bfi_h2i_set(cmd.mh, BFI_MC_CEE, BFI_CEE_H2I_RESET_STATS, 0);
+
+	/* send command to firmware */
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ * bna_get_cfg_req()
+ *
+ *   Request to get the LLDP-DCBCX Config.
+ *
+ * @param[in]   dev       - pointer to BNA device structure.
+ * @param[in]   dma_ddr   - dma address in "bna_dma_addr_t" format.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_get_cfg_req(struct bna_dev_s *dev, struct bna_dma_addr *dma_addr)
+{
+	struct bfi_cee_get_req_s cmd;
+
+	bfi_h2i_set(cmd.mh, BFI_MC_CEE, BFI_CEE_H2I_GET_CFG_REQ, 0);
+	cmd.dma_addr.a32.addr_lo = dma_addr->lsb;
+	cmd.dma_addr.a32.addr_hi = dma_addr->msb;
+	/* send command to firmware */
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ * bna_get_cee_stats_req()
+ *
+ *   Request to get the LLDP-DCBCX stats.
+ *
+ * @param[in]   dev       - pointer to BNA device structure.
+ * @param[in]   dma_ddr   - dma address in "bna_dma_addr_t" format.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_get_cee_stats_req(struct bna_dev_s *dev, struct bna_dma_addr *dma_addr)
+{
+	struct bfi_cee_get_req_s cmd;
+
+	bfi_h2i_set(cmd.mh, BFI_MC_CEE, BFI_CEE_H2I_GET_STATS_REQ, 0);
+	cmd.dma_addr.a32.addr_lo = dma_addr->lsb;
+	cmd.dma_addr.a32.addr_hi = dma_addr->msb;
+	/* send command to firmware */
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ * bna_stats_process()
+ *
+ *   Process the statistics data DMAed from the device. This
+ *   function needs to be scheduled upon getting an asynchronous
+ *   notification from the firmware.
+ *
+ * @param[in]   dev       - pointer to BNA device structure.
+ *
+ * @return void
+ */
+void
+bna_stats_process(struct bna_dev_s *dev)
+{
+#if 1
+	u32 i, j;
+	struct bna_stats_rxf *rxf_hw_stats;
+	struct bna_stats_txf *txf_hw_stats;
+
+	dev->stats.fc_tx_stats.txf_ucast_octets = bna_hw_stats_to_stats(
+		dev->hw_stats->fc_tx_stats.txf_ucast_octets);
+	dev->stats.fc_tx_stats.txf_ucast	= bna_hw_stats_to_stats(
+		dev->hw_stats->fc_tx_stats.txf_ucast);
+	dev->stats.fc_tx_stats.txf_ucast_vlan   = bna_hw_stats_to_stats(
+		dev->hw_stats->fc_tx_stats.txf_ucast_vlan);
+
+	dev->stats.fc_tx_stats.txf_mcast_octets = bna_hw_stats_to_stats(
+		dev->hw_stats->fc_tx_stats.txf_mcast_octets);
+	dev->stats.fc_tx_stats.txf_mcast	= bna_hw_stats_to_stats(
+		dev->hw_stats->fc_tx_stats.txf_mcast);
+	dev->stats.fc_tx_stats.txf_mcast_vlan = bna_hw_stats_to_stats(
+		dev->hw_stats->fc_tx_stats.txf_mcast_vlan);
+
+	dev->stats.fc_tx_stats.txf_bcast_octets = bna_hw_stats_to_stats(
+		dev->hw_stats->fc_tx_stats.txf_bcast_octets);
+	dev->stats.fc_tx_stats.txf_bcast = bna_hw_stats_to_stats(
+		dev->hw_stats->fc_tx_stats.txf_bcast);
+	dev->stats.fc_tx_stats.txf_bcast_vlan = bna_hw_stats_to_stats(
+		dev->hw_stats->fc_tx_stats.txf_bcast_vlan);
+
+	dev->stats.fc_tx_stats.txf_parity_errors = bna_hw_stats_to_stats(
+		dev->hw_stats->fc_tx_stats.txf_parity_errors);
+	dev->stats.fc_tx_stats.txf_timeout = bna_hw_stats_to_stats(
+		dev->hw_stats->fc_tx_stats.txf_timeout);
+	dev->stats.fc_tx_stats.txf_fid_parity_errors = bna_hw_stats_to_stats(
+		dev->hw_stats->fc_tx_stats.txf_fid_parity_errors);
+
+	for (i = 0; i < 8; i++) {
+		dev->stats.bpc_tx_stats.tx_pause[i] = bna_hw_stats_to_stats(
+			dev->hw_stats->bpc_stats.tx_pause[i]);
+		dev->stats.bpc_tx_stats.tx_zero_pause[i] =
+			bna_hw_stats_to_stats(
+			dev->hw_stats->bpc_stats.tx_zero_pause[i]);
+		dev->stats.bpc_tx_stats.tx_first_pause[i] =
+			bna_hw_stats_to_stats(
+			dev->hw_stats->bpc_stats.tx_first_pause[i]);
+	}
+
+	dev->stats.mac_tx_stats.tx_bytes = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.tx_bytes);
+	dev->stats.mac_tx_stats.tx_packets = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.tx_packets);
+	dev->stats.mac_tx_stats.tx_multicast = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.tx_multicast);
+	dev->stats.mac_tx_stats.tx_broadcast = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.tx_broadcast);
+	dev->stats.mac_tx_stats.tx_pause = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.tx_pause);
+	dev->stats.mac_tx_stats.tx_deferral = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.tx_deferral);
+	dev->stats.mac_tx_stats.tx_excessive_deferral = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.tx_excessive_deferral);
+	dev->stats.mac_tx_stats.tx_single_collision = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.tx_single_collision);
+	dev->stats.mac_tx_stats.tx_muliple_collision = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.tx_muliple_collision);
+	dev->stats.mac_tx_stats.tx_late_collision = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.tx_late_collision);
+	dev->stats.mac_tx_stats.tx_excessive_collision = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.tx_excessive_collision);
+	dev->stats.mac_tx_stats.tx_total_collision = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.tx_total_collision);
+	dev->stats.mac_tx_stats.tx_pause_honored = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.tx_pause_honored);
+	dev->stats.mac_tx_stats.tx_drop	= bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.tx_drop);
+	dev->stats.mac_tx_stats.tx_jabber = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.tx_jabber);
+	dev->stats.mac_tx_stats.tx_fcs_error = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.tx_fcs_error);
+	dev->stats.mac_tx_stats.tx_control_frame = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.tx_control_frame);
+	dev->stats.mac_tx_stats.tx_oversize = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.tx_oversize);
+	dev->stats.mac_tx_stats.tx_undersize = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.tx_undersize);
+	dev->stats.mac_tx_stats.tx_fragments = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.tx_fragments);
+
+	dev->stats.fc_rx_stats.rxf_ucast_octets = bna_hw_stats_to_stats(
+		dev->hw_stats->fc_rx_stats.rxf_ucast_octets);
+	dev->stats.fc_rx_stats.rxf_ucast = bna_hw_stats_to_stats(
+		dev->hw_stats->fc_rx_stats.rxf_ucast);
+	dev->stats.fc_rx_stats.rxf_ucast_vlan = bna_hw_stats_to_stats(
+		dev->hw_stats->fc_rx_stats.rxf_ucast_vlan);
+
+	dev->stats.fc_rx_stats.rxf_mcast_octets = bna_hw_stats_to_stats(
+		dev->hw_stats->fc_rx_stats.rxf_mcast_octets);
+	dev->stats.fc_rx_stats.rxf_mcast = bna_hw_stats_to_stats(
+		dev->hw_stats->fc_rx_stats.rxf_mcast);
+	dev->stats.fc_rx_stats.rxf_mcast_vlan = bna_hw_stats_to_stats(
+		dev->hw_stats->fc_rx_stats.rxf_mcast_vlan);
+
+	dev->stats.fc_rx_stats.rxf_bcast_octets = bna_hw_stats_to_stats(
+		dev->hw_stats->fc_rx_stats.rxf_bcast_octets);
+	dev->stats.fc_rx_stats.rxf_bcast = bna_hw_stats_to_stats(
+		dev->hw_stats->fc_rx_stats.rxf_bcast);
+	dev->stats.fc_rx_stats.rxf_bcast_vlan = bna_hw_stats_to_stats(
+		dev->hw_stats->fc_rx_stats.rxf_bcast_vlan);
+
+	for (i = 0; i < 8; i++) {
+		dev->stats.bpc_rx_stats.rx_pause[i] = bna_hw_stats_to_stats(
+			dev->hw_stats->bpc_stats.rx_pause[i]);
+		dev->stats.bpc_rx_stats.rx_zero_pause[i] =
+			bna_hw_stats_to_stats(
+			dev->hw_stats->bpc_stats.rx_zero_pause[i]);
+		dev->stats.bpc_rx_stats.rx_first_pause[i] =
+			bna_hw_stats_to_stats(
+			dev->hw_stats->bpc_stats.rx_first_pause[i]);
+	}
+
+	dev->stats.rad_stats.rx_frames = bna_hw_stats_to_stats(
+		dev->hw_stats->rad_stats.rx_frames);
+	dev->stats.rad_stats.rx_octets = bna_hw_stats_to_stats(
+		dev->hw_stats->rad_stats.rx_octets);
+	dev->stats.rad_stats.rx_vlan_frames = bna_hw_stats_to_stats(
+		dev->hw_stats->rad_stats.rx_vlan_frames);
+
+	dev->stats.rad_stats.rx_ucast = bna_hw_stats_to_stats(
+		dev->hw_stats->rad_stats.rx_ucast);
+	dev->stats.rad_stats.rx_ucast_octets = bna_hw_stats_to_stats(
+		dev->hw_stats->rad_stats.rx_ucast_octets);
+	dev->stats.rad_stats.rx_ucast_vlan = bna_hw_stats_to_stats(
+		dev->hw_stats->rad_stats.rx_ucast_vlan);
+
+	dev->stats.rad_stats.rx_mcast = bna_hw_stats_to_stats(
+		dev->hw_stats->rad_stats.rx_mcast);
+	dev->stats.rad_stats.rx_mcast_octets = bna_hw_stats_to_stats(
+		dev->hw_stats->rad_stats.rx_mcast_octets);
+	dev->stats.rad_stats.rx_mcast_vlan = bna_hw_stats_to_stats(
+		dev->hw_stats->rad_stats.rx_mcast_vlan);
+
+	dev->stats.rad_stats.rx_bcast = bna_hw_stats_to_stats(
+		dev->hw_stats->rad_stats.rx_bcast);
+	dev->stats.rad_stats.rx_bcast_octets = bna_hw_stats_to_stats(
+		dev->hw_stats->rad_stats.rx_bcast_octets);
+	dev->stats.rad_stats.rx_bcast_vlan      = bna_hw_stats_to_stats(
+		dev->hw_stats->rad_stats.rx_bcast_vlan);
+
+	dev->stats.rad_stats.rx_drops = bna_hw_stats_to_stats(
+		dev->hw_stats->rad_stats.rx_drops);
+
+	dev->stats.mac_rx_stats.frame_64 = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.frame_64);
+	dev->stats.mac_rx_stats.frame_65_127 = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.frame_65_127);
+	dev->stats.mac_rx_stats.frame_128_255 = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.frame_128_255);
+	dev->stats.mac_rx_stats.frame_256_511 = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.frame_256_511);
+	dev->stats.mac_rx_stats.frame_512_1023 = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.frame_512_1023);
+	dev->stats.mac_rx_stats.frame_1024_1518 = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.frame_1024_1518);
+	dev->stats.mac_rx_stats.frame_1518_1522 = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.frame_1519_1522);
+	dev->stats.mac_rx_stats.rx_bytes = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.rx_bytes);
+	dev->stats.mac_rx_stats.rx_packets = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.rx_packets);
+	dev->stats.mac_rx_stats.rx_fcs_error = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.rx_fcs_error);
+	dev->stats.mac_rx_stats.rx_multicast = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.rx_multicast);
+	dev->stats.mac_rx_stats.rx_broadcast = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.rx_broadcast);
+	dev->stats.mac_rx_stats.rx_control_frames = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.rx_control_frames);
+	dev->stats.mac_rx_stats.rx_pause = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.rx_pause);
+	dev->stats.mac_rx_stats.rx_unknown_opcode = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.rx_unknown_opcode);
+	dev->stats.mac_rx_stats.rx_alignment_error = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.rx_alignment_error);
+	dev->stats.mac_rx_stats.rx_frame_length_error = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.rx_frame_length_error);
+	dev->stats.mac_rx_stats.rx_code_error = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.rx_code_error);
+	dev->stats.mac_rx_stats.rx_carrier_sense_error = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.rx_carrier_sense_error);
+	dev->stats.mac_rx_stats.rx_undersize = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.rx_undersize);
+	dev->stats.mac_rx_stats.rx_oversize = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.rx_oversize);
+	dev->stats.mac_rx_stats.rx_fragments = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.rx_jabber);
+	dev->stats.mac_rx_stats.rx_jabber = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.rx_jabber);
+	dev->stats.mac_rx_stats.rx_drop = bna_hw_stats_to_stats(
+		dev->hw_stats->mac_stats.rx_drop);
+
+	rxf_hw_stats = (struct bna_stats_rxf *)&dev->hw_stats->rxf_stats[0];
+	j = 0;
+
+	for (i = 0; i < BNA_RXF_ID_MAX; i++) {
+		if (dev->rxf_active_last & ((u64)1 << i)) {
+			dev->stats.rxf_stats[i].ucast_octets =
+				bna_hw_stats_to_stats(
+				rxf_hw_stats[j].ucast_octets);
+		dev->stats.rxf_stats[i].ucast = bna_hw_stats_to_stats(
+			rxf_hw_stats[j].ucast);
+		dev->stats.rxf_stats[i].ucast_vlan = bna_hw_stats_to_stats(
+			rxf_hw_stats[j].ucast_vlan);
+
+		dev->stats.rxf_stats[i].mcast_octets = bna_hw_stats_to_stats(
+			rxf_hw_stats[j].mcast_octets);
+		dev->stats.rxf_stats[i].mcast = bna_hw_stats_to_stats(
+			rxf_hw_stats[j].mcast);
+		dev->stats.rxf_stats[i].mcast_vlan = bna_hw_stats_to_stats(
+			rxf_hw_stats[j].mcast_vlan);
+
+		dev->stats.rxf_stats[i].bcast_octets = bna_hw_stats_to_stats(
+			rxf_hw_stats[j].bcast_octets);
+		dev->stats.rxf_stats[i].bcast = bna_hw_stats_to_stats(
+			rxf_hw_stats[j].bcast);
+		dev->stats.rxf_stats[i].bcast_vlan = bna_hw_stats_to_stats(
+			rxf_hw_stats[j].bcast_vlan);
+
+		dev->stats.rxf_stats[i].frame_drops = bna_hw_stats_to_stats(
+			rxf_hw_stats[j].frame_drops);
+
+		j++;
+		}
+	}
+
+	txf_hw_stats = (struct bna_stats_txf *)&rxf_hw_stats[j];
+	j = 0;
+
+	for (i = 0; i < BNA_TXF_ID_MAX; i++) {
+		if (dev->txf_active_last & ((u64)1 << i)) {
+			dev->stats.txf_stats[i].ucast_octets =
+				bna_hw_stats_to_stats(
+				txf_hw_stats[j].ucast_octets);
+		dev->stats.txf_stats[i].ucast = bna_hw_stats_to_stats(
+			txf_hw_stats[j].ucast);
+		dev->stats.txf_stats[i].ucast_vlan = bna_hw_stats_to_stats(
+			txf_hw_stats[j].ucast_vlan);
+
+		dev->stats.txf_stats[i].mcast_octets = bna_hw_stats_to_stats(
+			txf_hw_stats[j].mcast_octets);
+		dev->stats.txf_stats[i].mcast = bna_hw_stats_to_stats(
+			txf_hw_stats[j].mcast);
+		dev->stats.txf_stats[i].mcast_vlan = bna_hw_stats_to_stats(
+			txf_hw_stats[j].mcast_vlan);
+
+		dev->stats.txf_stats[i].bcast_octets = bna_hw_stats_to_stats(
+			txf_hw_stats[j].bcast_octets);
+		dev->stats.txf_stats[i].bcast = bna_hw_stats_to_stats(
+			txf_hw_stats[j].bcast);
+		dev->stats.txf_stats[i].bcast_vlan = bna_hw_stats_to_stats(
+			txf_hw_stats[j].bcast_vlan);
+
+		dev->stats.txf_stats[i].errors = bna_hw_stats_to_stats(
+			txf_hw_stats[j].errors);
+		dev->stats.txf_stats[i].filter_vlan = bna_hw_stats_to_stats(
+			txf_hw_stats[j].filter_vlan);
+		dev->stats.txf_stats[i].filter_mac_sa = bna_hw_stats_to_stats(
+			txf_hw_stats[j].filter_mac_sa);
+
+		j++;
+		}
+    }
+#else
+	u64 *p_stats = (u64 *)&dev->stats;
+	u64 *p_hw_stats = (u64 *)&dev->hw_stats;
+	int i;
+
+	for (i = 0; i < sizeof(dev->stats)/sizeof(u64); i++)
+		p_stats[i] = bna_hw_stats_to_stats(p_hw_stats[i]);
+#endif
+}
+
+/**
+ * bna_txf_config_set()
+ *
+ *   For TxF "txf_id", it configures the TxF specified by "cfg_ptr" and
+ *   indicates to the statistics collector to collect statistics for this
+ *   Tx-Function.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  txf_id  - tx-function ID.
+ * @param[in]  cfg_ptr - pointer to tx-function configuration.
+ *
+ * @return void
+ */
+void
+bna_txf_config_set(struct bna_dev_s *dev, unsigned int txf_id,
+		    const struct bna_txf_config *cfg_ptr)
+{
+
+	struct bna_tx_fndb_ram *tx_fndb;
+
+	BNA_ASSERT(txf_id < BNA_TXF_ID_MAX);
+
+	tx_fndb = (struct bna_tx_fndb_ram *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, TX_FNDB_RAM_BASE_OFFSET);
+
+	bna_reg_write(dev->regs.page_addr, BNA_GET_PAGE_NUM(
+		LUT0_MEM_BLK_BASE_PG_NUM + (dev->port * 2),
+		TX_FNDB_RAM_BASE_OFFSET));
+
+	bna_mem_writew(&tx_fndb[txf_id],
+		       (cfg_ptr->vlan << 16) | cfg_ptr->flags);
+
+	/* turn on statistics collection */
+	dev->txf_active |= ((u64)1 << txf_id);
+}
+
+/**
+ * bna_txf_config_clear()
+ *
+ *   For TxF "txf_id", it clears its configuration and indicates to the
+ *   statistics collector to stop collecting statistics for this
+ *   Tx-Function.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  txf_id  - tx-function ID.
+ *
+ * @return void
+ */
+void
+bna_txf_config_clear(struct bna_dev_s *dev, unsigned int txf_id)
+{
+
+	struct bna_tx_fndb_ram *tx_fndb;
+
+	BNA_ASSERT(txf_id < BNA_TXF_ID_MAX);
+
+	tx_fndb = (struct bna_tx_fndb_ram *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, TX_FNDB_RAM_BASE_OFFSET);
+
+	bna_reg_write(dev->regs.page_addr,
+		BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM + (dev->port * 2),
+				  TX_FNDB_RAM_BASE_OFFSET));
+
+	bna_mem_writew(&tx_fndb[txf_id], 0);
+
+	/* turn off statistics collection */
+	dev->txf_active &= ~((u64)1 << txf_id);
+}
+
+/**
+ * bna_txf_disable()
+ *
+ *  Disables the Tx Function without clearing the configuration
+ *  Also disables collection of statistics.
+ *
+ * @param[in] bna_dev   - Pointer to BNA device handle
+ * @param[in] txf_id    - Id of the Tx Function to be disabled
+ *
+ * @return void
+ */
+void
+bna_txf_disable(struct bna_dev_s *dev, unsigned int txf_id)
+{
+	struct bna_tx_fndb_ram *tx_fndb;
+	u32 page_num, ctl_flags;
+
+	BNA_ASSERT(txf_id < BNA_TXF_ID_MAX);
+
+	tx_fndb = (struct bna_tx_fndb_ram *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, TX_FNDB_RAM_BASE_OFFSET);
+
+	/* Write the page number register */
+	page_num =
+	    BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM + (dev->port * 2),
+	    TX_FNDB_RAM_BASE_OFFSET);
+	bna_reg_write(dev->regs.page_addr, page_num);
+
+	ctl_flags = bna_mem_readw(&tx_fndb[txf_id].vlan_n_ctrl_flags);
+
+	ctl_flags &= ~BNA_TXF_CF_ENABLE;
+
+	bna_mem_writew(&tx_fndb[txf_id].vlan_n_ctrl_flags, ctl_flags);
+
+	/* turn off statistics collection */
+	dev->txf_active &= ~((u64)1 << txf_id);
+}
+
+/**
+ * bna_txf_enable()
+ *
+ *  Enables the Tx Function without reconfiguring.
+ *  Also disables collection of statistics.
+ *
+ * @param[in] bna_dev   - Pointer to BNA device handle
+ * @param[in] txf_id    - Id of the Tx Function to be disabled
+ *
+ * @return void
+ */
+void
+bna_txf_enable(struct bna_dev_s *dev, unsigned int txf_id)
+{
+	struct bna_tx_fndb_ram *tx_fndb;
+	u32 page_num, ctl_flags;
+
+	BNA_ASSERT(txf_id < BNA_TXF_ID_MAX);
+
+	tx_fndb = (struct bna_tx_fndb_ram *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, TX_FNDB_RAM_BASE_OFFSET);
+
+	/* Write the page number register */
+	page_num = BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM +
+	    (dev->port * 2), TX_FNDB_RAM_BASE_OFFSET);
+	bna_reg_write(dev->regs.page_addr, page_num);
+
+	ctl_flags = bna_mem_readw(&tx_fndb[txf_id].vlan_n_ctrl_flags);
+
+	ctl_flags |= BNA_TXF_CF_ENABLE;
+
+	bna_mem_writew(&tx_fndb[txf_id].vlan_n_ctrl_flags, ctl_flags);
+
+	/* turn on statistics collection */
+	dev->txf_active |= ((u64)1 << txf_id);
+}
+
+/**
+ * bna_set_pause_config()
+ *
+ *   Enable/disable Tx/Rx pause through F/W
+ *
+ * @param[in]   dev 	  - pointer to BNA device structure
+ * @param[in]   pause 	  - pointer to struct bna_pause_config
+ *
+ * @return BNA_OK in case of success BNA_FAIL otherwise.
+ */
+enum bna_status_e
+bna_set_pause_config(struct bna_dev_s *dev, struct bna_pause_config *pause,
+    void *cbarg)
+{
+	struct bfi_ll_set_pause_req ll_req;
+
+	bfi_h2i_set(ll_req.mh, BFI_MC_LL, BFI_LL_H2I_SET_PAUSE_REQ, 0);
+
+	ll_req.tx_pause = pause->tx_pause;
+	ll_req.rx_pause = pause->rx_pause;
+
+	DPRINTK(INFO, "Port %d tx_pause %d rx_pause %d\n",
+		dev->port, ll_req.tx_pause, ll_req.rx_pause);
+
+	/* send to f/w */
+	return bna_mbox_send(dev, &ll_req, sizeof(ll_req), cbarg);
+}
+
+/**
+ * bna_mtu_info()
+ *
+ *   Send MTU information to F/W.
+ *   This is required to do PAUSE efficiently.
+ *
+ * @param[in]   dev 	  - pointer to BNA device structure
+ * @param[in]   mtu	  - current mtu size
+ * @param[in]   cbarg	  - argument for the callback function
+ *
+ * @return BNA_OK in case of success BNA_FAIL otherwise.
+ */
+enum bna_status_e
+bna_mtu_info(struct bna_dev_s *dev, u16 mtu, void *cbarg)
+{
+	struct bfi_ll_mtu_info_req ll_req;
+
+	bfi_h2i_set(ll_req.mh, BFI_MC_LL, BFI_LL_H2I_MTU_INFO_REQ, 0);
+	ll_req.mtu      = bna_os_htons(mtu);
+
+	DPRINTK(INFO, "Port %d MTU %d\n", dev->port, mtu);
+
+	/* send to f/w */
+	return bna_mbox_send(dev, &ll_req, sizeof(ll_req), cbarg);
+}
+
+/* Currently we assume just 2 columns, col 0 = small, col 1 = large */
+u32 intr_mod_vector[BNA_LOAD_TYPES + 1][BNA_BIAS_TYPES] = {
+		{ 12,  12 },
+		{  6,  10 },
+		{  5,  10 },
+		{  4,   8 },
+		{  3,   6 },
+		{  3,   6 },
+		{  2,   4 },
+		{  1,   2 },
+	};
+
+/**
+ * Returns the coalescing timer value
+ */
+u8
+bna_calc_coalescing_timer(struct bna_dev_s *dev, struct bna_pkt_rate *pkt)
+{
+	u32 load, bias;
+	u32 pkt_rt = 0, small_rt, large_rt;
+
+
+	small_rt = pkt->small_pkt_cnt;
+	large_rt = pkt->large_pkt_cnt;
+
+	pkt_rt = small_rt + large_rt;
+
+	if (pkt_rt < BNA_10K_PKT_RATE)
+		load = BNA_LOW_LOAD_4;
+	else if (pkt_rt < BNA_20K_PKT_RATE)
+		load = BNA_LOW_LOAD_3;
+	else if (pkt_rt < BNA_30K_PKT_RATE)
+		load = BNA_LOW_LOAD_2;
+	else if (pkt_rt < BNA_40K_PKT_RATE)
+		load = BNA_LOW_LOAD_1;
+	else if (pkt_rt < BNA_50K_PKT_RATE)
+		load = BNA_HIGH_LOAD_1;
+	else if (pkt_rt < BNA_60K_PKT_RATE)
+		load = BNA_HIGH_LOAD_2;
+	else if (pkt_rt < BNA_80K_PKT_RATE)
+		load = BNA_HIGH_LOAD_3;
+	else
+		load = BNA_HIGH_LOAD_4;
+
+
+	if (small_rt > (large_rt << 1))
+		bias = 0;
+	else
+		bias = 1;
+
+	pkt->small_pkt_cnt = pkt->large_pkt_cnt = 0;
+	return intr_mod_vector[load][bias];
+}
diff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bna_queue.c linux-2.6.32-rc4-mod/drivers/net/bna/bna_queue.c
--- linux-2.6.32-rc4-orig/drivers/net/bna/bna_queue.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.32-rc4-mod/drivers/net/bna/bna_queue.c	2009-10-16 10:30:53.254436000 -0700
@@ -0,0 +1,496 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ *    Copyright (c) 2007-2008 Brocade Communications Systems, Inc.
+ *    All rights reserved.
+ *
+ *    @file bna_queue.c BNA Queues
+ */
+
+#include <bna_os.h>
+#include "bna.h"
+#include "bna_hwreg.h"
+#include "bna_priv.h"
+#include <bfi/bfi_ll.h>
+
+
+#define BNA_Q_IDLE_STATE	0x00008001
+/*
+ *-----------------------------------------------------------------------------
+ *  bna_txq_config()
+ *
+ *  For TxQ "txq_id", it configures the Tx-Queue as specified by "cfg_ptr".
+ *-----------------------------------------------------------------------------
+ */
+void bna_txq_config(struct bna_dev_s *dev, struct bna_txq *q_ptr,
+	unsigned int txq_id, const struct bna_txq_config *cfg_ptr)
+{
+	struct bna_rxtx_q_mem *q_mem;
+	struct bna_txq_mem txq_cfg, *txq_mem;
+	const struct bna_qpt *qpt = &cfg_ptr->qpt;
+	struct bna_dma_addr cur_q_addr;
+	struct bna_doorbell_qset *qset;
+	u32 pg_num;
+
+	BNA_ASSERT(txq_id < BNA_TXQ_ID_MAX);
+	/* Check if the depth is a power of 2 */
+	BNA_ASSERT(BNA_POWER_OF_2(q_ptr->q.q_depth));
+
+
+	cur_q_addr = *((struct bna_dma_addr *)(qpt->kv_qpt_ptr));
+
+	/*
+	 * Fill out structure, to be subsequently written
+	 * to hardware
+	 */
+	txq_cfg.pg_tbl_addr_lo = qpt->hw_qpt_ptr.lsb;
+	txq_cfg.pg_tbl_addr_hi = qpt->hw_qpt_ptr.msb;
+
+	/* FIXME */
+	txq_cfg.cur_q_entry_lo = cur_q_addr.lsb;
+	txq_cfg.cur_q_entry_hi = cur_q_addr.msb;
+
+	txq_cfg.pg_cnt_n_prd_ptr = (qpt->page_count << 16) | 0x0;
+
+	/* Is the entry size in words ? Check */
+	txq_cfg.entry_n_pg_size = ((BNA_TXQ_ENTRY_SIZE >> 2) << 16) |
+		(qpt->page_size >> 2);
+	txq_cfg.int_blk_n_cns_ptr =
+		((((u8)cfg_ptr->ib_seg_index) << 24) |
+		(((u8)cfg_ptr->ib_id) << 16) | 0x0);
+	txq_cfg.cns_ptr2_n_q_state = BNA_Q_IDLE_STATE;
+	txq_cfg.nxt_qid_n_fid_n_pri = (((cfg_ptr->txf_id
+		& 0x3f) << 3) | (cfg_ptr->priority & 0x3));
+	txq_cfg.wvc_n_cquota_n_rquota = (((cfg_ptr->wrr_quota & 0xfff) << 12) |
+		(cfg_ptr->wrr_quota & 0xfff));
+
+	pg_num = BNA_GET_PAGE_NUM(HQM0_BLK_PG_NUM + dev->port,
+		HQM_RXTX_Q_RAM_BASE_OFFSET);
+
+	bna_reg_write(dev->regs.page_addr, pg_num);
+	/* Write to h/w */
+	q_mem = (struct bna_rxtx_q_mem *)
+	BNA_GET_MEM_BASE_ADDR(dev->bar0, HQM_RXTX_Q_RAM_BASE_OFFSET);
+
+	txq_mem = &q_mem[txq_id].txq;
+
+	/*
+	 * The following 4 lines, is a hack b'cos the H/W needs to read
+	 * these DMA addresses as little endian
+	 */
+	bna_mem_writew(&txq_mem->pg_tbl_addr_lo,
+					bna_os_htonl(txq_cfg.pg_tbl_addr_lo));
+	bna_mem_writew(&txq_mem->pg_tbl_addr_hi,
+					bna_os_htonl(txq_cfg.pg_tbl_addr_hi));
+	bna_mem_writew(&txq_mem->cur_q_entry_lo,
+					 bna_os_htonl(txq_cfg.cur_q_entry_lo));
+	bna_mem_writew(&txq_mem->cur_q_entry_hi,
+					 bna_os_htonl(txq_cfg.cur_q_entry_hi));
+
+	bna_mem_writew(&txq_mem->pg_cnt_n_prd_ptr, txq_cfg.pg_cnt_n_prd_ptr);
+	bna_mem_writew(&txq_mem->entry_n_pg_size, txq_cfg.entry_n_pg_size);
+	bna_mem_writew(&txq_mem->int_blk_n_cns_ptr,
+	txq_cfg.int_blk_n_cns_ptr);
+	bna_mem_writew(&txq_mem->cns_ptr2_n_q_state,
+	txq_cfg.cns_ptr2_n_q_state);
+	bna_mem_writew(&txq_mem->nxt_qid_n_fid_n_pri,
+	txq_cfg.nxt_qid_n_fid_n_pri);
+	bna_mem_writew(&txq_mem->wvc_n_cquota_n_rquota,
+	txq_cfg.wvc_n_cquota_n_rquota);
+
+	DPRINTK(DEBUG, "TxQ %u\n", txq_id);
+	DPRINTK(DEBUG, "TxQ pg_tbl_addr_lo 0x%x\n",
+		bna_os_ntohl(txq_cfg.pg_tbl_addr_lo));
+	DPRINTK(DEBUG, "TxQ cur_q_entry_lo 0x%x\n",
+		bna_os_ntohl(txq_cfg.cur_q_entry_lo));
+	DPRINTK(DEBUG, "TxQ pg_cnt_n_prd_ptr 0x%x\n",
+		txq_cfg.pg_cnt_n_prd_ptr);
+	DPRINTK(DEBUG, "TxQ entry_n_pg_size 0x%x\n",
+		txq_cfg.entry_n_pg_size);
+	DPRINTK(DEBUG, "TxQ int_blk_n_cns_ptr 0x%x\n",
+		txq_cfg.int_blk_n_cns_ptr);
+	DPRINTK(DEBUG, "TxQ cns_ptr2_n_q_state 0x%x\n",
+		txq_cfg.cns_ptr2_n_q_state);
+	DPRINTK(DEBUG, "TxQ nxt_qid_n_fid_n_pri 0x%x\n",
+		txq_cfg.nxt_qid_n_fid_n_pri);
+	DPRINTK(DEBUG, "TxQ wvc_n_cquota_n_rquota 0x%x\n",
+		txq_cfg.wvc_n_cquota_n_rquota);
+
+	qset = (struct bna_doorbell_qset *)
+		BNA_GET_DOORBELL_BASE_ADDR(dev->bar0);
+	q_ptr->doorbell =  &qset[txq_id].txq[0];
+
+	q_ptr->q.producer_index = 0;
+	q_ptr->q.consumer_index = 0;
+}
+
+
+/**
+ * bna_txq_stop()
+ *
+ * 	Stops the TxQ identified by the TxQ Id.
+ *	Should be called with a lock held
+ *	The driver should wait for the response to
+ *	conclude if the Q stop is successful or not.
+ *
+ * @param[in] q_id	- Id of the TxQ
+ *
+ * @return    BNA_OK in case of success, else BNA_FAIL
+ */
+enum bna_status_e
+bna_txq_stop(struct bna_dev_s *dev, u32 txq_id)
+{
+	struct bfi_ll_q_stop_req ll_req;
+	u64 bit_mask = 1 << txq_id;
+
+	ll_req.mh.msg_class = BFI_MC_LL;
+	ll_req.mh.msg_id = BFI_LL_H2I_TXQ_STOP_REQ;
+	ll_req.mh.mtag.i2htok = 0;
+
+	ll_req.q_id_mask[0] = bna_os_htonl((u32)bit_mask);
+	ll_req.q_id_mask[1] = bna_os_htonl((u32)(bit_mask >> 32));
+
+	/* send to f/w */
+	return bna_mbox_send(dev, &ll_req, sizeof(ll_req), dev->cbarg);
+}
+
+/*
+ *-----------------------------------------------------------------------------
+ *  bna_rxq_config()
+ *
+ *  For RxQ "rxq_id", it configures the Rx-Queue as specified by "cfg_ptr".
+ *-----------------------------------------------------------------------------
+ */
+void
+bna_rxq_config(struct bna_dev_s *dev, struct bna_rxq *q_ptr,
+    unsigned int rxq_id, const struct bna_rxq_config *cfg_ptr)
+{
+	struct bna_rxtx_q_mem *q_mem;
+	struct bna_rxq_mem rxq_cfg, *rxq_mem;
+	const struct bna_qpt *qpt = &cfg_ptr->qpt;
+	struct bna_dma_addr cur_q_addr;
+	struct bna_doorbell_qset *qset;
+	u32 pg_num;
+
+	BNA_ASSERT(rxq_id < BNA_RXQ_ID_MAX);
+
+	/* Check if the depth is a power of 2 */
+	BNA_ASSERT(BNA_POWER_OF_2(q_ptr->q.q_depth));
+
+
+	cur_q_addr = *((struct bna_dma_addr *)(qpt->kv_qpt_ptr));
+	/*
+	 * Fill out structure, to be subsequently written
+	 * to hardware
+	 */
+	rxq_cfg.pg_tbl_addr_lo = qpt->hw_qpt_ptr.lsb;
+	rxq_cfg.pg_tbl_addr_hi = qpt->hw_qpt_ptr.msb;
+	rxq_cfg.cur_q_entry_lo = cur_q_addr.lsb;
+	rxq_cfg.cur_q_entry_hi = cur_q_addr.msb;
+
+	rxq_cfg.pg_cnt_n_prd_ptr = (qpt->page_count << 16) | 0x0;
+	rxq_cfg.entry_n_pg_size =  ((BNA_RXQ_ENTRY_SIZE >> 2) << 16) |
+	(qpt->page_size >> 2);
+	rxq_cfg.sg_n_cq_n_cns_ptr = (((u8)cfg_ptr->cq_id) << 16) | 0x0;
+	rxq_cfg.buf_sz_n_q_state =
+		(cfg_ptr->buffer_size << 16) | BNA_Q_IDLE_STATE;
+	rxq_cfg.next_qid = 0x0 | (0x3 << 8);
+
+	/* Write the page number register */
+	pg_num = BNA_GET_PAGE_NUM(HQM0_BLK_PG_NUM + dev->port,
+		HQM_RXTX_Q_RAM_BASE_OFFSET);
+	bna_reg_write(dev->regs.page_addr, pg_num);
+
+	/* Write to h/w */
+	q_mem = (struct bna_rxtx_q_mem *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0,
+			HQM_RXTX_Q_RAM_BASE_OFFSET);
+		rxq_mem = &q_mem[rxq_id].rxq;
+
+	bna_mem_writew(&rxq_mem->pg_tbl_addr_lo,
+					bna_os_htonl(rxq_cfg.pg_tbl_addr_lo));
+	bna_mem_writew(&rxq_mem->pg_tbl_addr_hi,
+					bna_os_htonl(rxq_cfg.pg_tbl_addr_hi));
+	bna_mem_writew(&rxq_mem->cur_q_entry_lo,
+					bna_os_htonl(rxq_cfg.cur_q_entry_lo));
+	bna_mem_writew(&rxq_mem->cur_q_entry_hi,
+					bna_os_htonl(rxq_cfg.cur_q_entry_hi));
+
+	bna_mem_writew(&rxq_mem->pg_cnt_n_prd_ptr, rxq_cfg.pg_cnt_n_prd_ptr);
+	bna_mem_writew(&rxq_mem->entry_n_pg_size, rxq_cfg.entry_n_pg_size);
+	bna_mem_writew(&rxq_mem->sg_n_cq_n_cns_ptr,
+			rxq_cfg.sg_n_cq_n_cns_ptr);
+	bna_mem_writew(&rxq_mem->buf_sz_n_q_state,
+			rxq_cfg.buf_sz_n_q_state);
+	bna_mem_writew(&rxq_mem->next_qid, rxq_cfg.next_qid);
+
+	DPRINTK(DEBUG, "RxQ %u\n", rxq_id);
+	DPRINTK(DEBUG, "RxQ pg_tbl_addr_lo 0x%x\n",
+		bna_os_ntohl(rxq_cfg.pg_tbl_addr_lo));
+	DPRINTK(DEBUG, "RxQ cur_q_entry_lo 0x%x\n",
+		bna_os_ntohl(rxq_cfg.cur_q_entry_lo));
+	DPRINTK(DEBUG, "RxQ pg_cnt_n_prd_ptr 0x%x\n", rxq_cfg.pg_cnt_n_prd_ptr);
+	DPRINTK(DEBUG, "RxQ entry_n_pg_size 0x%x\n", rxq_cfg.entry_n_pg_size);
+	DPRINTK(DEBUG, "RxQ sg_n_cq_n_cns_ptr 0x%x\n",
+		rxq_cfg.sg_n_cq_n_cns_ptr);
+	DPRINTK(DEBUG, "RxQ buf_sz_n_q_state 0x%x\n", rxq_cfg.buf_sz_n_q_state);
+	DPRINTK(DEBUG, "RxQ next_qid %u\n", rxq_cfg.next_qid);
+
+	qset = (struct bna_doorbell_qset *)
+			BNA_GET_DOORBELL_BASE_ADDR(dev->bar0);
+	q_ptr->doorbell = &qset[rxq_id].rxq[0];
+
+	q_ptr->q.producer_index = 0;
+	q_ptr->q.consumer_index = 0;
+}
+
+
+/**
+ * bna_rxq_stop()
+ *
+ * 	Stops the RxQ identified by the RxQ Id.
+ *	Should be called with a lock held
+ *	The driver should wait for the response to
+ *	conclude if the Q stop is successful or not.
+ *
+ * @param[in] q_id	- Id of the RxQ
+ *
+ * @return    BNA_OK in case of success, else BNA_FAIL
+ */
+enum bna_status_e
+bna_rxq_stop(struct bna_dev_s *dev, u32 rxq_id)
+{
+	struct bfi_ll_q_stop_req ll_req;
+	u64 bit_mask = 1 << rxq_id;
+
+	ll_req.mh.msg_class = BFI_MC_LL;
+	ll_req.mh.msg_id = BFI_LL_H2I_RXQ_STOP_REQ;
+	ll_req.mh.mtag.i2htok = 0;
+
+	ll_req.q_id_mask[0] = bna_os_htonl((u32)bit_mask);
+	ll_req.q_id_mask[1] = bna_os_htonl((u32)(bit_mask >> 32));
+
+	/* send to f/w */
+	return bna_mbox_send(dev, &ll_req, sizeof(ll_req), dev->cbarg);
+}
+
+enum bna_status_e
+bna_multi_rxq_stop(struct bna_dev_s *dev, u64 rxq_id_mask)
+{
+	struct bfi_ll_q_stop_req ll_req;
+
+	bfi_h2i_set(ll_req.mh, BFI_MC_LL, BFI_LL_H2I_RXQ_STOP_REQ, 0);
+
+	ll_req.q_id_mask[0] = bna_os_htonl((u32)rxq_id_mask);
+	ll_req.q_id_mask[1] = bna_os_htonl((u32)(rxq_id_mask >> 32));
+
+	/* send to f/w */
+	return bna_mbox_send(dev, &ll_req, sizeof(ll_req), dev->cbarg);
+}
+
+/*
+ *-----------------------------------------------------------------------------
+ *  bna_cq_config()
+ *
+ *  For CQ "cq_id", it configures the Rx-Completion Queue as specified by
+ *  "cfg_ptr".
+ *-----------------------------------------------------------------------------
+ */
+void
+bna_cq_config(struct bna_dev_s *dev, struct bna_cq *q_ptr,
+     unsigned int cq_id, const struct bna_cq_config *cfg_ptr)
+{
+	struct bna_cq_mem cq_cfg, *cq_mem;
+	const struct bna_qpt *qpt = &cfg_ptr->qpt;
+	struct bna_dma_addr cur_q_addr;
+	u32 pg_num;
+
+	BNA_ASSERT(cq_id < BNA_CQ_ID_MAX);
+
+	/* Check if the depth is a power of 2 */
+	/* How do we ensure this ? */
+	BNA_ASSERT(BNA_POWER_OF_2(q_ptr->q.q_depth));
+
+
+	cur_q_addr = *((struct bna_dma_addr *)(qpt->kv_qpt_ptr));
+
+	/*
+	 * Fill out structure, to be subsequently written
+	 * to hardware
+	 */
+	cq_cfg.pg_tbl_addr_lo = qpt->hw_qpt_ptr.lsb;
+	cq_cfg.pg_tbl_addr_hi = qpt->hw_qpt_ptr.msb;
+	cq_cfg.cur_q_entry_lo = cur_q_addr.lsb;
+	cq_cfg.cur_q_entry_hi = cur_q_addr.msb;
+
+	cq_cfg.pg_cnt_n_prd_ptr = (qpt->page_count << 16) | 0x0;
+	cq_cfg.entry_n_pg_size = ((BNA_CQ_ENTRY_SIZE >> 2) << 16) |
+	(qpt->page_size >> 2);
+	cq_cfg.int_blk_n_cns_ptr = ((((u8)cfg_ptr->ib_seg_index) << 24) |
+			(((u8)cfg_ptr->ib_id) << 16) | 0x0);
+	cq_cfg.q_state = BNA_Q_IDLE_STATE;
+
+	/* Write the page number register */
+	pg_num = BNA_GET_PAGE_NUM(HQM0_BLK_PG_NUM + dev->port,
+			HQM_CQ_RAM_BASE_OFFSET);
+
+	bna_reg_write(dev->regs.page_addr, pg_num);
+	/* H/W write */
+	cq_mem = (struct bna_cq_mem *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, HQM_CQ_RAM_BASE_OFFSET);
+	bna_mem_writew(&cq_mem[cq_id].pg_tbl_addr_lo,
+					bna_os_htonl(cq_cfg.pg_tbl_addr_lo));
+	bna_mem_writew(&cq_mem[cq_id].pg_tbl_addr_hi,
+					bna_os_htonl(cq_cfg.pg_tbl_addr_hi));
+	bna_mem_writew(&cq_mem[cq_id].cur_q_entry_lo,
+					bna_os_htonl(cq_cfg.cur_q_entry_lo));
+	bna_mem_writew(&cq_mem[cq_id].cur_q_entry_hi,
+					bna_os_htonl(cq_cfg.cur_q_entry_hi));
+
+	bna_mem_writew(&cq_mem[cq_id].pg_cnt_n_prd_ptr,
+					cq_cfg.pg_cnt_n_prd_ptr);
+	bna_mem_writew(&cq_mem[cq_id].entry_n_pg_size, cq_cfg.entry_n_pg_size);
+	bna_mem_writew(&cq_mem[cq_id].int_blk_n_cns_ptr,
+					cq_cfg.int_blk_n_cns_ptr);
+	bna_mem_writew(&cq_mem[cq_id].q_state, cq_cfg.q_state);
+
+	DPRINTK(DEBUG, "CQ %u\n", cq_id);
+	DPRINTK(DEBUG, "CQ pg_tbl_addr_lo 0x%x\n",
+		bna_os_ntohl(cq_cfg.pg_tbl_addr_lo));
+	DPRINTK(DEBUG, "CQ cur_q_entry_lo 0x%x\n",
+		bna_os_ntohl(cq_cfg.cur_q_entry_lo));
+	DPRINTK(DEBUG, "CQ pg_cnt_n_prd_ptr 0x%x\n", cq_cfg.pg_cnt_n_prd_ptr);
+	DPRINTK(DEBUG, "CQ entry_n_pg_size 0x%x\n", cq_cfg.entry_n_pg_size);
+	DPRINTK(DEBUG, "CQ int_blk_n_cns_ptr 0x%x\n", cq_cfg.int_blk_n_cns_ptr);
+	DPRINTK(DEBUG, "CQ q_state 0x%x\n", cq_cfg.q_state);
+
+	q_ptr->q.producer_index = 0;
+	q_ptr->q.consumer_index = 0;
+
+}
+
+/*
+ * bna_ib_idx_reset()
+ *
+ *   For the specified IB, it clears the IB index
+ *
+ * @param[in] cfg_ptr - pointer to IB Configuration Structure.
+ *
+ * @return none
+ */
+void
+bna_ib_idx_reset(struct bna_dev_s *dev, const struct bna_ib_config *cfg_ptr)
+{
+	u32 i, pg_num, *ib_idx;
+
+	pg_num = BNA_GET_PAGE_NUM(HQM0_BLK_PG_NUM + dev->port,
+		HQM_INDX_TBL_RAM_BASE_OFFSET);
+	bna_reg_write(dev->regs.page_addr, pg_num);
+
+	ib_idx = (u32 *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, HQM_INDX_TBL_RAM_BASE_OFFSET);
+	ib_idx += cfg_ptr->index_table_offset;
+	for (i = 0; i < cfg_ptr->seg_size; i++)
+		*ib_idx++ = 0;
+}
+
+/*
+ * bna_ib_config_set()
+ *
+ *   For IB "ib_id", it configures the Interrupt Block specified by "cfg_ptr".
+ *
+ * @param[in] ib_ptr  - pointer to IB Data Structure.
+ * @param[in] ib_id   - interrupt-block ID
+ * @param[in] cfg_ptr - pointer to IB Configuration Structure.
+ *
+ * @return BNA_OK or BNA_FAIL
+ */
+void
+bna_ib_config_set(struct bna_dev_s *dev, struct bna_ib *ib_ptr,
+    unsigned int ib_id, const struct bna_ib_config *cfg_ptr)
+{
+	struct bna_ib_blk_mem ib_cfg, *ib_mem;
+	u32 pg_num;
+	struct bna_doorbell_qset *qset;
+
+	BNA_ASSERT(ib_id < BNA_IB_ID_MAX);
+
+
+	ib_cfg.host_addr_lo =
+			(u32)(cfg_ptr->ib_seg_addr.lsb);
+	ib_cfg.host_addr_hi =
+			(u32)(cfg_ptr->ib_seg_addr.msb);
+
+	ib_cfg.clsc_n_ctrl_n_msix = ((cfg_ptr->coalescing_timer << 16) |
+			(cfg_ptr->control_flags << 8) | (cfg_ptr->msix_vector));
+	ib_cfg.ipkt_n_ent_n_idxof = ((cfg_ptr->interpkt_timer & 0xf) << 16) |
+			(cfg_ptr->seg_size << 8) |
+			(cfg_ptr->index_table_offset);
+	ib_cfg.ipkt_cnt_cfg_n_unacked = (cfg_ptr->interpkt_count << 24);
+
+	/* Write the page number register */
+	pg_num = BNA_GET_PAGE_NUM(HQM0_BLK_PG_NUM + dev->port,
+			HQM_IB_RAM_BASE_OFFSET);
+	bna_reg_write(dev->regs.page_addr, pg_num);
+
+	ib_mem = (struct bna_ib_blk_mem *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0,
+			HQM_IB_RAM_BASE_OFFSET);
+
+	bna_mem_writew(&ib_mem[ib_id].host_addr_lo,
+					bna_os_htonl(ib_cfg.host_addr_lo));
+	bna_mem_writew(&ib_mem[ib_id].host_addr_hi,
+					bna_os_htonl(ib_cfg.host_addr_hi));
+
+	bna_mem_writew(&ib_mem[ib_id].clsc_n_ctrl_n_msix,
+			ib_cfg.clsc_n_ctrl_n_msix);
+	bna_mem_writew(&ib_mem[ib_id].ipkt_n_ent_n_idxof,
+			ib_cfg.ipkt_n_ent_n_idxof);
+	bna_mem_writew(&ib_mem[ib_id].ipkt_cnt_cfg_n_unacked,
+			ib_cfg.ipkt_cnt_cfg_n_unacked);
+
+	DPRINTK(DEBUG, "IB %d: host addr 0x%x clsc_n_ctrl_n_msix 0x%x\n",
+		ib_id, bna_os_htonl(ib_cfg.host_addr_lo),
+		ib_cfg.clsc_n_ctrl_n_msix);
+	DPRINTK(DEBUG, "ipkt_n_ent_n_idxof 0x%x ipkt_cnt_cfg_n_unacked 0x%x\n",
+		ib_cfg.ipkt_n_ent_n_idxof, ib_cfg.ipkt_cnt_cfg_n_unacked);
+
+	qset = (struct bna_doorbell_qset *)
+			BNA_GET_DOORBELL_BASE_ADDR(dev->bar0);
+	ib_ptr->doorbell_addr =
+		(&qset[ib_id >> 1].ib0[(ib_id & 0x1) * (0x20 >> 2)]);
+
+	ib_ptr->doorbell_ack  = BNA_DOORBELL_IB_INT_ACK(
+			cfg_ptr->coalescing_timer, 0);
+
+	bna_ib_idx_reset(dev, cfg_ptr);
+}
+
+/*
+ * bna_ib_disable()
+ *
+ *   Disables the Interrupt Block "ib_id".
+ *
+ * @param[in] ib_ptr  - pointer to IB Data Structure.
+ *
+ * @return None
+ */
+void
+bna_ib_disable(struct bna_dev_s *bna_dev, const struct bna_ib *ib_ptr)
+{
+	bna_reg_write(ib_ptr->doorbell_addr, BNA_DOORBELL_IB_INT_DISABLE);
+}
