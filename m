From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: add support for OVS offload
Date: Sat, 27 May 2017 08:56:33 -0700
Message-ID: <20170527155633.GA2358@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, veerasenareddy.burru@cavium.com,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0069.outbound.protection.outlook.com ([104.47.38.69]:51648
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750909AbdE0P4h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 27 May 2017 11:56:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: VSR Burru <veerasenareddy.burru@cavium.com>

Add support for OVS offload.  By default PF driver runs in basic NIC mode
as usual.  To run in OVS mode, use the insmod parameter "fw_type=ovs".

For OVS mode, create a management interface for communication with NIC
firmware.  This communication channel uses PF0's I/O rings.

Bump up driver version to 1.6.0 to match newer firmware.

Signed-off-by: VSR Burru <veerasenareddy.burru@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/Makefile      |   1 +
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  27 +-
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  23 +-
 .../net/ethernet/cavium/liquidio/liquidio_image.h  |   1 +
 .../net/ethernet/cavium/liquidio/liquidio_mgmt.c   | 439 +++++++++++++++++++++
 .../net/ethernet/cavium/liquidio/octeon_console.c  |  27 +-
 drivers/net/ethernet/cavium/liquidio/octeon_main.h |   9 +
 7 files changed, 516 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/Makefile b/drivers/net/ethernet/cavium/liquidio/Makefile
index c4d411d..2064157 100644
--- a/drivers/net/ethernet/cavium/liquidio/Makefile
+++ b/drivers/net/ethernet/cavium/liquidio/Makefile
@@ -15,6 +15,7 @@ liquidio-$(CONFIG_LIQUIDIO) += lio_ethtool.o \
 			octeon_mailbox.o   \
 			octeon_mem_ops.o   \
 			octeon_droq.o      \
+			liquidio_mgmt.o      \
 			octeon_nic.o
 
 liquidio-objs := lio_main.o octeon_console.o $(liquidio-y)
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index ba01242..b22eb74 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -43,6 +43,8 @@ MODULE_FIRMWARE(LIO_FW_DIR LIO_FW_BASE_NAME LIO_210SV_NAME LIO_FW_NAME_SUFFIX);
 MODULE_FIRMWARE(LIO_FW_DIR LIO_FW_BASE_NAME LIO_210NV_NAME LIO_FW_NAME_SUFFIX);
 MODULE_FIRMWARE(LIO_FW_DIR LIO_FW_BASE_NAME LIO_410NV_NAME LIO_FW_NAME_SUFFIX);
 MODULE_FIRMWARE(LIO_FW_DIR LIO_FW_BASE_NAME LIO_23XX_NAME LIO_FW_NAME_SUFFIX);
+MODULE_FIRMWARE(LIO_FW_DIR LIO_FW_BASE_NAME LIO_23XX_NAME "_"
+		 LIO_FW_NAME_TYPE_OVS LIO_FW_NAME_SUFFIX);
 
 static int ddr_timeout = 10000;
 module_param(ddr_timeout, int, 0644);
@@ -57,7 +59,7 @@ MODULE_PARM_DESC(debug, "NETIF_MSG debug bits");
 
 static char fw_type[LIO_MAX_FW_TYPE_LEN];
 module_param_string(fw_type, fw_type, sizeof(fw_type), 0000);
-MODULE_PARM_DESC(fw_type, "Type of firmware to be loaded. Default \"nic\"");
+MODULE_PARM_DESC(fw_type, "Type of firmware to be loaded (nic,ovs,none). Default \"nic\".  Use \"none\" to load firmware from flash on LiquidIO adapter.");
 
 static int ptp_enable = 1;
 
@@ -1414,6 +1416,12 @@ static bool fw_type_is_none(void)
 		       sizeof(LIO_FW_NAME_TYPE_NONE)) == 0;
 }
 
+static bool is_fw_type_ovs(void)
+{
+	return strncmp(fw_type, LIO_FW_NAME_TYPE_OVS,
+		       sizeof(LIO_FW_NAME_TYPE_OVS)) == 0;
+}
+
 /**
  *\brief Destroy resources associated with octeon device
  * @param pdev PCI device structure
@@ -1776,6 +1784,9 @@ static void liquidio_remove(struct pci_dev *pdev)
 
 	dev_dbg(&oct_dev->pci_dev->dev, "Stopping device\n");
 
+	if (is_fw_type_ovs())
+		lio_mgmt_exit();
+
 	if (oct_dev->watchdog_task)
 		kthread_stop(oct_dev->watchdog_task);
 
@@ -3933,6 +3944,8 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 	u32 resp_size, ctx_size, data_size;
 	u32 ifidx_or_pfnum;
 	struct lio_version *vdata;
+	union oct_nic_vf_info vf_info;
+
 
 	/* This is to handle link status changes */
 	octeon_register_dispatch_fn(octeon_dev, OPCODE_NIC,
@@ -4001,9 +4014,16 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 
 		sc->iq_no = 0;
 
+		/* Populate VF info for OVS firmware */
+		vf_info.u64 = 0;
+
+		vf_info.s.bus_num = octeon_dev->pci_dev->bus->number;
+		vf_info.s.dev_fn = octeon_dev->pci_dev->devfn;
+		vf_info.s.max_vfs = octeon_dev->sriov_info.max_vfs;
+
 		octeon_prepare_soft_command(octeon_dev, sc, OPCODE_NIC,
 					    OPCODE_NIC_IF_CFG, 0,
-					    if_cfg.u64, 0);
+					    if_cfg.u64, vf_info.u64);
 
 		sc->callback = if_cfg_callback;
 		sc->callback_arg = sc;
@@ -4382,6 +4402,9 @@ static int liquidio_init_nic_module(struct octeon_device *oct)
 		goto octnet_init_failure;
 	}
 
+	if (is_fw_type_ovs())
+		lio_mgmt_init(oct);
+
 	liquidio_ptp_init(oct);
 
 	dev_dbg(&oct->pci_dev->dev, "Network interfaces ready\n");
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 8ea2323..d8a1a1d 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -27,8 +27,8 @@
 
 #define LIQUIDIO_PACKAGE ""
 #define LIQUIDIO_BASE_MAJOR_VERSION 1
-#define LIQUIDIO_BASE_MINOR_VERSION 5
-#define LIQUIDIO_BASE_MICRO_VERSION 1
+#define LIQUIDIO_BASE_MINOR_VERSION 6
+#define LIQUIDIO_BASE_MICRO_VERSION 0
 #define LIQUIDIO_BASE_VERSION   __stringify(LIQUIDIO_BASE_MAJOR_VERSION) "." \
 				__stringify(LIQUIDIO_BASE_MINOR_VERSION)
 #define LIQUIDIO_MICRO_VERSION  "." __stringify(LIQUIDIO_BASE_MICRO_VERSION)
@@ -63,6 +63,8 @@ enum octeon_tag_type {
  */
 #define OPCODE_CORE 0           /* used for generic core operations */
 #define OPCODE_NIC  1           /* used for NIC operations */
+#define OPCODE_OVS  2           /* used for OVS operations */
+
 /* Subcodes are used by host driver/apps to identify the sub-operation
  * for the core. They only need to by unique for a given subsystem.
  */
@@ -890,4 +892,21 @@ union oct_nic_if_cfg {
 	} s;
 };
 
+union oct_nic_vf_info {
+	u64 u64;
+	struct {
+#ifdef __BIG_ENDIAN_BITFIELD
+		u64 max_vfs:32;
+		u64 bus_num:8;
+		u64 dev_fn:8;
+		u64 reserved:16;
+#else
+		u64 reserved:16;
+		u64 dev_fn:8;
+		u64 bus_num:8;
+		u64 max_vfs:32;
+#endif
+	} s;
+};
+
 #endif
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_image.h b/drivers/net/ethernet/cavium/liquidio/liquidio_image.h
index 78a3685..cbd03f5 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_image.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_image.h
@@ -24,6 +24,7 @@
 #define LIO_FW_BASE_NAME        "lio_"
 #define LIO_FW_NAME_SUFFIX      ".bin"
 #define LIO_FW_NAME_TYPE_NIC    "nic"
+#define LIO_FW_NAME_TYPE_OVS    "ovs"
 #define LIO_FW_NAME_TYPE_NONE   "none"
 #define LIO_MAX_FIRMWARE_VERSION_LEN 16
 
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_mgmt.c b/drivers/net/ethernet/cavium/liquidio/liquidio_mgmt.c
new file mode 100644
index 0000000..1fd7497
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_mgmt.c
@@ -0,0 +1,439 @@
+/**********************************************************************
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2017 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/crc32.h>
+#include <linux/dma-mapping.h>
+#include <linux/pci.h>
+#include <linux/pci_ids.h>
+#include <linux/ip.h>
+#include <net/ip.h>
+#include <linux/ipv6.h>
+#include <linux/net_tstamp.h>
+#include <linux/if_vlan.h>
+#include <linux/firmware.h>
+#include <linux/ethtool.h>
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/workqueue.h>
+#include <linux/interrupt.h>
+#include "octeon_config.h"
+#include "liquidio_common.h"
+#include "octeon_droq.h"
+#include "octeon_iq.h"
+#include "response_manager.h"
+#include "octeon_device.h"
+#include "octeon_nic.h"
+#include "octeon_main.h"
+#include "octeon_network.h"
+
+/* VSW specific opcodes. these should match with those in cvmcs-vsw-msg.h */
+#define OPCODE_VSW_HOST_COMM_PKT_DATA   0x10
+
+static struct net_device *netdev;
+struct lio_mgmt {
+	atomic_t ifstate;
+	struct tasklet_struct rx_tasklet;
+	struct list_head rx_pkts_list;
+	struct net_device *parent_netdev;
+	struct octeon_device *oct_dev;
+	struct net_device *netdev;
+	u64 dev_capability;
+	u64 enc_dev_capability;
+	struct oct_link_info linfo;
+	u32 intf_open;
+};
+
+struct lio_mgmt_rx_pkt {
+	struct list_head list;
+	struct sk_buff *skb;
+};
+
+#define LIO_MGMT_SIZE (sizeof(struct lio_mgmt))
+#define GET_LIO_MGMT(netdev)  ((struct lio_mgmt *)netdev_priv(netdev))
+
+/**
+ * \brief Stop Tx queues
+ * @param netdev network device
+ */
+static inline void txqs_stop(struct net_device *netdev)
+{
+	if (netif_is_multiqueue(netdev)) {
+		int i;
+
+		for (i = 0; i < netdev->num_tx_queues; i++)
+			netif_stop_subqueue(netdev, i);
+	} else {
+		netif_stop_queue(netdev);
+	}
+}
+
+/**
+ * \brief Start Tx queues
+ * @param netdev network device
+ */
+static inline void txqs_start(struct net_device *netdev)
+{
+	if (netif_is_multiqueue(netdev)) {
+		int i;
+
+		for (i = 0; i < netdev->num_tx_queues; i++)
+			netif_start_subqueue(netdev, i);
+	} else {
+		netif_start_queue(netdev);
+	}
+}
+
+/**
+ * \brief Stop Tx queue
+ * @param netdev network device
+ */
+static void stop_txq(struct net_device *netdev)
+{
+	txqs_stop(netdev);
+}
+
+/**
+ * \brief Start Tx queue
+ * @param netdev network device
+ */
+static void start_txq(struct net_device *netdev)
+{
+	txqs_start(netdev);
+}
+
+static int lio_mgmt_open(struct net_device *netdev)
+{
+	struct lio_mgmt *lio_mgmt = GET_LIO_MGMT(netdev);
+
+	ifstate_set((struct lio *)lio_mgmt, LIO_IFSTATE_RUNNING);
+	netif_carrier_on(netdev);
+
+	start_txq(netdev);
+
+	/* Ready for link status updates */
+	lio_mgmt->intf_open = 1;
+
+	return 0;
+}
+
+/**
+ * \brief Net device stop for LiquidIO
+ * @param netdev network device
+ */
+static int lio_mgmt_stop(struct net_device *netdev)
+{
+	struct lio_mgmt *lio_mgmt = GET_LIO_MGMT(netdev);
+
+	ifstate_reset((struct lio *)lio_mgmt, LIO_IFSTATE_RUNNING);
+
+	netif_tx_disable(netdev);
+
+	/* Inform that netif carrier is down */
+	netif_carrier_off(netdev);
+	lio_mgmt->intf_open = 0;
+
+	return 0;
+}
+
+static void packet_sent_callback(struct octeon_device *oct,
+				 u32 status, void *buf)
+{
+	struct octeon_soft_command *sc = (struct octeon_soft_command *)buf;
+	struct sk_buff *skb = sc->ctxptr;
+
+	dma_unmap_single(&oct->pci_dev->dev, sc->dmadptr,
+			 sc->datasize, DMA_TO_DEVICE);
+	dev_kfree_skb_any(skb);
+	kfree(sc);
+}
+
+/** \brief Transmit networks packets to the Octeon interface
+ * @param skbuff   skbuff struct to be passed to network layer.
+ * @param netdev    pointer to network device
+ * @returns whether the packet was transmitted to the device okay or not
+ *             (NETDEV_TX_OK or NETDEV_TX_BUSY)
+ */
+static int lio_mgmt_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct lio_mgmt *lio_mgmt;
+	struct lio *parent_lio;
+	struct octeon_soft_command *sc;
+	int status;
+	struct octeon_instr_pki_ih3 *pki_ih3;
+
+	lio_mgmt = GET_LIO_MGMT(netdev);
+	parent_lio = GET_LIO(lio_mgmt->parent_netdev);
+
+	/* Check for all conditions in which the current packet cannot be
+	 * transmitted.
+	 */
+	if (!(atomic_read(&lio_mgmt->ifstate) & LIO_IFSTATE_RUNNING) ||
+	    (skb->len <= 0)) {
+		goto lio_xmit_failed;
+	}
+
+	if (octnet_iq_is_full(lio_mgmt->oct_dev, parent_lio->txq)) {
+		/* defer sending if queue is full */
+		return NETDEV_TX_BUSY;
+	}
+
+	sc = kzalloc(sizeof(*sc), GFP_ATOMIC);
+	if (!sc)
+		goto lio_xmit_failed;
+
+	if (skb_shinfo(skb)->nr_frags == 0) {
+		sc->dmadptr = dma_map_single(&lio_mgmt->oct_dev->pci_dev->dev,
+					     skb->data,
+					     skb->len, DMA_TO_DEVICE);
+		if (dma_mapping_error
+		    (&lio_mgmt->oct_dev->pci_dev->dev, sc->dmadptr)) {
+			return NETDEV_TX_BUSY;
+		}
+		sc->virtdptr = skb->data;
+		sc->datasize = skb->len;
+		sc->ctxptr = skb;	/* to be freed in sent callback */
+		sc->dmarptr = 0;
+		sc->rdatasize = 0;
+		sc->iq_no = parent_lio->txq;	/* default input queue */
+		octeon_prepare_soft_command(lio_mgmt->oct_dev, sc, OPCODE_OVS,
+					    OPCODE_VSW_HOST_COMM_PKT_DATA, 0, 0,
+					    0);
+
+		/*prepare softcommand uses ATOMIC TAG, change it to ORDERED */
+		pki_ih3 = (struct octeon_instr_pki_ih3 *)&sc->cmd.cmd3.pki_ih3;
+		pki_ih3->tag = LIO_DATA((lio_mgmt->oct_dev->instr_queue
+					[sc->iq_no]->txpciq.s.port));
+		pki_ih3->tagtype = ORDERED_TAG;
+
+		sc->callback = packet_sent_callback;
+		sc->callback_arg = sc;
+		status = octeon_send_soft_command(lio_mgmt->oct_dev, sc);
+		if (status == IQ_SEND_FAILED) {
+			dma_unmap_single(&lio_mgmt->oct_dev->pci_dev->dev,
+					 sc->dmadptr, sc->datasize,
+					 DMA_TO_DEVICE);
+			goto lio_xmit_failed;
+		}
+
+		if (status == IQ_SEND_STOP)
+			stop_txq(netdev);
+	} else {
+		goto lio_xmit_failed;
+	}
+
+	netdev->stats.tx_packets++;
+	netdev->stats.tx_bytes += skb->len;
+
+	return NETDEV_TX_OK;
+
+lio_xmit_failed:
+	netdev->stats.tx_dropped++;
+	dev_kfree_skb_any(skb);
+	return NETDEV_TX_OK;
+}
+
+static void rx_tasklet(unsigned long data)
+{
+	struct net_device *netdev = (struct net_device *)(data);
+	struct lio_mgmt *lio_mgmt = GET_LIO_MGMT(netdev);
+	struct lio_mgmt_rx_pkt *rxpkt, *tmp;
+
+	list_for_each_entry_safe(rxpkt, tmp, &lio_mgmt->rx_pkts_list, list) {
+		netif_rx(rxpkt->skb);
+		list_del(&rxpkt->list);
+		kfree(rxpkt);
+	}
+}
+
+static int lio_mgmt_rx(struct octeon_recv_info *recv_info, void *buf)
+{
+	struct octeon_recv_pkt *recv_pkt = recv_info->recv_pkt;
+	struct sk_buff *skb;
+	struct lio_mgmt *lio_mgmt = GET_LIO_MGMT(netdev);
+	unsigned int pkt_size = 0;
+	unsigned char *pkt_ptr;
+	struct lio_mgmt_rx_pkt *rxpkt;
+	int i;
+
+	/* Do not proceed if the interface is not in RUNNING state. */
+	if (!ifstate_check((struct lio *)lio_mgmt, LIO_IFSTATE_RUNNING)) {
+		for (i = 0; i < recv_pkt->buffer_count; i++)
+			recv_buffer_free(recv_pkt->buffer_ptr[i]);
+
+		octeon_free_recv_info(recv_info);
+		return 0;
+	}
+
+	pkt_size = recv_pkt->buffer_size[0];
+	pkt_ptr = get_rbd(recv_pkt->buffer_ptr[0]);
+
+	skb = netdev_alloc_skb_ip_align(netdev, pkt_size);
+	if (likely(skb))
+		skb_copy_to_linear_data(skb, pkt_ptr, pkt_size);
+
+	skb_put(skb, pkt_size);
+	netdev->stats.rx_packets++;
+	netdev->stats.rx_bytes += skb->len;
+
+	skb->dev = netdev;
+	skb->protocol = eth_type_trans(skb, skb->dev);
+	/* checksum has already been verified */
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+	rxpkt = kmalloc(sizeof(*rxpkt), GFP_ATOMIC);
+	if (rxpkt) {
+		INIT_LIST_HEAD(&rxpkt->list);
+		rxpkt->skb = skb;
+		list_add_tail(&rxpkt->list, &lio_mgmt->rx_pkts_list);
+	}
+
+	tasklet_schedule(&lio_mgmt->rx_tasklet);
+
+	for (i = 0; i < recv_pkt->buffer_count; i++)
+		recv_buffer_free(recv_pkt->buffer_ptr[i]);
+
+	octeon_free_recv_info(recv_info);
+	return 0;
+}
+
+const struct net_device_ops liocomdevops = {
+	.ndo_open = lio_mgmt_open,
+	.ndo_stop = lio_mgmt_stop,
+	.ndo_start_xmit = lio_mgmt_xmit,
+};
+
+static int __lio_mgmt_init(struct octeon_device *octdev)
+{
+	struct lio_mgmt *lio_mgmt = NULL;
+	struct lio *parent_lio;
+
+	/* Register netdev only for pf 0 */
+	if (octdev->pf_num == 0) {
+		netdev = alloc_etherdev(LIO_MGMT_SIZE);
+		if (!netdev) {
+			dev_err(&octdev->pci_dev->dev, "Mgmt: Device allocation failed\n");
+			goto nic_dev_fail;
+		}
+
+		/* SET_NETDEV_DEV(netdev, &octdev->pci_dev->dev); */
+		netdev->netdev_ops = &liocomdevops;
+
+		lio_mgmt = GET_LIO_MGMT(netdev);
+		memset(lio_mgmt, 0, LIO_MGMT_SIZE);
+		lio_mgmt->oct_dev = octdev;
+
+		/*use ifidx zero of pf */
+		lio_mgmt->parent_netdev = octdev->props[0].netdev;
+		parent_lio = GET_LIO(lio_mgmt->parent_netdev);
+
+		lio_mgmt->dev_capability = NETIF_F_HIGHDMA
+		    | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_RXCSUM;
+		lio_mgmt->enc_dev_capability = NETIF_F_IP_CSUM
+		    | NETIF_F_IPV6_CSUM | NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
+
+		netdev->vlan_features = lio_mgmt->dev_capability;
+		netdev->features = lio_mgmt->dev_capability;
+		netdev->hw_features = lio_mgmt->dev_capability;
+
+		lio_mgmt->linfo = parent_lio->linfo;
+
+		eth_hw_addr_random(netdev);
+	}
+	if (octdev->pf_num == 0) {
+		char name[IFNAMSIZ];
+		int dev_id, fn;
+
+		tasklet_init(&lio_mgmt->rx_tasklet, rx_tasklet, (u64)netdev);
+		INIT_LIST_HEAD(&lio_mgmt->rx_pkts_list);
+
+		dev_id = (octdev->pci_dev->devfn & 0xff) >> 3;
+		fn = octdev->pci_dev->devfn & 0x7;
+
+		if (fn) {
+			snprintf(name, IFNAMSIZ, "lio-p%ds%df%d-mgmt",
+				 octdev->pci_dev->bus->number, dev_id, fn);
+		} else {
+			snprintf(name, IFNAMSIZ, "lio-p%ds%d-mgmt",
+				 octdev->pci_dev->bus->number, dev_id);
+		}
+
+		strncpy(netdev->name, name, sizeof(netdev->name) - 1);
+
+		/* Register the network device with the OS */
+		if (register_netdev(netdev)) {
+			dev_err(&octdev->pci_dev->dev, "Mgmt: Device registration failed\n");
+			goto nic_dev_fail;
+		}
+
+		netif_carrier_on(netdev);
+		ifstate_set((struct lio *)lio_mgmt, LIO_IFSTATE_REGISTERED);
+		/*  Register RX dispatch function */
+		if (octeon_register_dispatch_fn(octdev, OPCODE_OVS,
+						OPCODE_VSW_HOST_COMM_PKT_DATA,
+						lio_mgmt_rx, octdev)) {
+			goto nic_dev_fail;
+		}
+	}
+
+	return 0;
+
+nic_dev_fail:
+	if (netdev) {
+		struct lio_mgmt *lio_mgmt = GET_LIO_MGMT(netdev);
+
+		if (atomic_read(&lio_mgmt->ifstate) &
+		    LIO_IFSTATE_REGISTERED)
+			unregister_netdev(netdev);
+
+		free_netdev(netdev);
+		netdev = NULL;
+	}
+
+	netdev = NULL;
+	return -ENOMEM;
+}
+
+static void __lio_mgmt_exit(void)
+{
+	pr_info("LiquidIO Communication module is now unloaded\n");
+
+	if (netdev) {
+		struct lio_mgmt *lio_mgmt = GET_LIO_MGMT(netdev);
+
+		if (atomic_read(&lio_mgmt->ifstate) & LIO_IFSTATE_RUNNING)
+			txqs_stop(netdev);
+
+		if (atomic_read(&lio_mgmt->ifstate) &
+		    LIO_IFSTATE_REGISTERED)
+			unregister_netdev(netdev);
+
+		free_netdev(netdev);
+		netdev = NULL;
+	}
+}
+
+int lio_mgmt_init(struct octeon_device *octdev)
+{
+	return __lio_mgmt_init(octdev);
+}
+
+void lio_mgmt_exit(void)
+{
+	__lio_mgmt_exit();
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
index 53f38d0..c7b05b7 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_console.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
@@ -724,18 +724,22 @@ static int octeon_console_read(struct octeon_device *oct, u32 console_num,
 }
 
 #define FBUF_SIZE	(4 * 1024 * 1024)
-u8 fbuf[FBUF_SIZE];
 
 int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
 			     size_t size)
 {
 	int ret = 0;
-	u8 *p = fbuf;
 	u32 crc32_result;
 	u64 load_addr;
 	u32 image_len;
 	struct octeon_firmware_file_header *h;
 	u32 i, rem;
+	char *bootcmd;
+	char date[30];
+	struct timeval time;
+	struct tm tm;
+	size_t cmdlen;
+
 
 	if (size < sizeof(struct octeon_firmware_file_header)) {
 		dev_err(&oct->pci_dev->dev, "Firmware file too small (%d < %d).\n",
@@ -805,10 +809,9 @@ int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
 			else
 				size = FBUF_SIZE;
 
-			memcpy(p, data, size);
-
 			/* download the image */
-			octeon_pci_write_core_mem(oct, load_addr, p, (u32)size);
+			octeon_pci_write_core_mem(
+					oct, load_addr, (u8 *)data, (u32)size);
 
 			data += size;
 			rem -= (u32)size;
@@ -818,8 +821,18 @@ int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
 	dev_info(&oct->pci_dev->dev, "Writing boot command: %s\n",
 		 h->bootcmd);
 
-	/* Invoke the bootcmd */
-	ret = octeon_console_send_cmd(oct, h->bootcmd, 50);
+	/*Get time of the day*/
+	do_gettimeofday(&time);
+	time_to_tm(time.tv_sec, (-sys_tz.tz_minuteswest) * 60,  &tm);
+	snprintf(date, 30, " date=%04ld.%02d.%02d-%02d:%02d:%02d",
+		 tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday,
+		 tm.tm_hour, tm.tm_min, tm.tm_sec);
+	cmdlen = strlen(h->bootcmd) + sizeof(date) + 1;
+	bootcmd = kmalloc(cmdlen, GFP_KERNEL);
+	strncpy(bootcmd, h->bootcmd, cmdlen);
+	strcat(bootcmd, date);
+	ret = octeon_console_send_cmd(oct, bootcmd, 50);
+	kfree(bootcmd);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_main.h b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
index bed9ef1..3a36105 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_main.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
@@ -198,4 +198,13 @@ sleep_timeout_cond(wait_queue_head_t *wait_queue,
 #define ROUNDUP128(val) (((val) + 127) & 0xffffff80)
 #endif
 
+/* Initializes the LiquidIO management interface module
+ * @param octdev - octeon device pointer
+ * @returns 0 if init is success, -1 otherwise
+ */
+int lio_mgmt_init(struct octeon_device *octdev);
+
+/* De-initializes the LiquidIO management interface module */
+void lio_mgmt_exit(void);
+
 #endif /* _OCTEON_MAIN_H_ */
