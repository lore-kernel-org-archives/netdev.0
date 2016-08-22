From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V3 01/18] liquidio: Consolidate common functionality
Date: Sun, 21 Aug 2016 17:12:28 -0700
Message-ID: <1471824765-26473-2-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1471824765-26473-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0062.outbound.protection.outlook.com ([104.47.33.62]:61266
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753164AbcHVA2A (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 21 Aug 2016 20:28:00 -0400
In-Reply-To: <1471824765-26473-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consolidate common functionality of various devices
from different files into lio_core.c/octeon_console.c.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/Makefile      |  23 +-
 drivers/net/ethernet/cavium/liquidio/lio_core.c    | 261 +++++++++++++++++++
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c |  16 +-
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 279 +--------------------
 .../net/ethernet/cavium/liquidio/octeon_console.c  | 116 ++++++++-
 .../net/ethernet/cavium/liquidio/octeon_device.c   | 104 --------
 drivers/net/ethernet/cavium/liquidio/octeon_main.h |  24 +-
 .../net/ethernet/cavium/liquidio/octeon_mem_ops.c  |   1 -
 .../net/ethernet/cavium/liquidio/octeon_network.h  |   2 -
 drivers/net/ethernet/cavium/liquidio/octeon_nic.c  |   8 +-
 drivers/net/ethernet/cavium/liquidio/octeon_nic.h  |   2 +-
 11 files changed, 426 insertions(+), 410 deletions(-)
 create mode 100644 drivers/net/ethernet/cavium/liquidio/lio_core.c

diff --git a/drivers/net/ethernet/cavium/liquidio/Makefile b/drivers/net/ethernet/cavium/liquidio/Makefile
index 2f36680..d44111d 100644
--- a/drivers/net/ethernet/cavium/liquidio/Makefile
+++ b/drivers/net/ethernet/cavium/liquidio/Makefile
@@ -3,14 +3,15 @@
 #
 obj-$(CONFIG_LIQUIDIO) += liquidio.o
 
-liquidio-objs := lio_main.o  \
-	      lio_ethtool.o      \
-	      request_manager.o  \
-	      response_manager.o \
-	      octeon_device.o    \
-	      cn66xx_device.o    \
-	      cn68xx_device.o    \
-	      octeon_mem_ops.o   \
-	      octeon_droq.o      \
-	      octeon_console.o   \
-	      octeon_nic.o
+liquidio-$(CONFIG_LIQUIDIO) += lio_ethtool.o \
+			lio_core.o         \
+			request_manager.o  \
+			response_manager.o \
+			octeon_device.o    \
+			cn66xx_device.o    \
+			cn68xx_device.o    \
+			octeon_mem_ops.o   \
+			octeon_droq.o      \
+			octeon_nic.o
+
+liquidio-objs := lio_main.o octeon_console.o $(liquidio-y)
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
new file mode 100644
index 0000000..809179c
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -0,0 +1,261 @@
+/**********************************************************************
+* Author: Cavium, Inc.
+*
+* Contact: support@cavium.com
+*          Please include "LiquidIO" in the subject.
+*
+* Copyright (c) 2003-2015 Cavium, Inc.
+*
+* This file is free software; you can redistribute it and/or modify
+* it under the terms of the GNU General Public License, Version 2, as
+* published by the Free Software Foundation.
+*
+* This file is distributed in the hope that it will be useful, but
+* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+* NONINFRINGEMENT.  See the GNU General Public License for more
+* details.
+*
+* This file may also be available under a different license from Cavium.
+* Contact Cavium, Inc. for more information
+**********************************************************************/
+#include <linux/pci.h>
+#include <linux/if_vlan.h>
+#include "liquidio_common.h"
+#include "octeon_droq.h"
+#include "octeon_iq.h"
+#include "response_manager.h"
+#include "octeon_device.h"
+#include "octeon_nic.h"
+#include "octeon_main.h"
+#include "octeon_network.h"
+
+int liquidio_set_feature(struct net_device *netdev, int cmd, u16 param1)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+	int ret = 0;
+
+	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
+
+	nctrl.ncmd.u64 = 0;
+	nctrl.ncmd.s.cmd = cmd;
+	nctrl.ncmd.s.param1 = param1;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
+	nctrl.wait_time = 100;
+	nctrl.netpndev = (u64)netdev;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
+	if (ret < 0) {
+		dev_err(&oct->pci_dev->dev, "Feature change failed in core (ret: 0x%x)\n",
+			ret);
+	}
+	return ret;
+}
+
+void octeon_report_tx_completion_to_bql(void *txq, unsigned int pkts_compl,
+					unsigned int bytes_compl)
+{
+	struct netdev_queue *netdev_queue = txq;
+
+	netdev_tx_completed_queue(netdev_queue, pkts_compl, bytes_compl);
+}
+
+void octeon_update_tx_completion_counters(void *buf, int reqtype,
+					  unsigned int *pkts_compl,
+					  unsigned int *bytes_compl)
+{
+	struct octnet_buf_free_info *finfo;
+	struct sk_buff *skb = NULL;
+	struct octeon_soft_command *sc;
+
+	switch (reqtype) {
+	case REQTYPE_NORESP_NET:
+	case REQTYPE_NORESP_NET_SG:
+		finfo = buf;
+		skb = finfo->skb;
+		break;
+
+	case REQTYPE_RESP_NET_SG:
+	case REQTYPE_RESP_NET:
+		sc = buf;
+		skb = sc->callback_arg;
+		break;
+
+	default:
+		return;
+	}
+
+	(*pkts_compl)++;
+/*TODO, Use some other pound define to suggest
+ * the fact that iqs are not tied to netdevs
+ * and can take traffic from different netdevs
+ * hence bql reporting is done per packet
+ * than in bulk. Usage of NO_NAPI in txq completion is
+ * a little confusing
+ */
+	*bytes_compl += skb->len;
+}
+
+void octeon_report_sent_bytes_to_bql(void *buf, int reqtype)
+{
+	struct octnet_buf_free_info *finfo;
+	struct sk_buff *skb;
+	struct octeon_soft_command *sc;
+	struct netdev_queue *txq;
+
+	switch (reqtype) {
+	case REQTYPE_NORESP_NET:
+	case REQTYPE_NORESP_NET_SG:
+		finfo = buf;
+		skb = finfo->skb;
+		break;
+
+	case REQTYPE_RESP_NET_SG:
+	case REQTYPE_RESP_NET:
+		sc = buf;
+		skb = sc->callback_arg;
+		break;
+
+	default:
+		return;
+	}
+
+	txq = netdev_get_tx_queue(skb->dev, skb_get_queue_mapping(skb));
+	netdev_tx_sent_queue(txq, skb->len);
+}
+
+void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
+{
+	struct octnic_ctrl_pkt *nctrl = (struct octnic_ctrl_pkt *)nctrl_ptr;
+	struct net_device *netdev = (struct net_device *)nctrl->netpndev;
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	u8 *mac;
+
+	switch (nctrl->ncmd.s.cmd) {
+	case OCTNET_CMD_CHANGE_DEVFLAGS:
+	case OCTNET_CMD_SET_MULTI_LIST:
+		break;
+
+	case OCTNET_CMD_CHANGE_MACADDR:
+		mac = ((u8 *)&nctrl->udd[0]) + 2;
+		netif_info(lio, probe, lio->netdev,
+			   "MACAddr changed to %2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x\n",
+			   mac[0], mac[1],
+			   mac[2], mac[3],
+			   mac[4], mac[5]);
+		break;
+
+	case OCTNET_CMD_CHANGE_MTU:
+		/* If command is successful, change the MTU. */
+		netif_info(lio, probe, lio->netdev, "MTU Changed from %d to %d\n",
+			   netdev->mtu, nctrl->ncmd.s.param1);
+		dev_info(&oct->pci_dev->dev, "%s MTU Changed from %d to %d\n",
+			 netdev->name, netdev->mtu,
+			 nctrl->ncmd.s.param1);
+		rtnl_lock();
+		netdev->mtu = nctrl->ncmd.s.param1;
+		call_netdevice_notifiers(NETDEV_CHANGEMTU, netdev);
+		rtnl_unlock();
+		break;
+
+	case OCTNET_CMD_GPIO_ACCESS:
+		netif_info(lio, probe, lio->netdev, "LED Flashing visual identification\n");
+		break;
+
+	case OCTNET_CMD_LRO_ENABLE:
+		dev_info(&oct->pci_dev->dev, "%s LRO Enabled\n", netdev->name);
+		break;
+
+	case OCTNET_CMD_LRO_DISABLE:
+		dev_info(&oct->pci_dev->dev, "%s LRO Disabled\n",
+			 netdev->name);
+		break;
+
+	case OCTNET_CMD_VERBOSE_ENABLE:
+		dev_info(&oct->pci_dev->dev, "%s Firmware debug enabled\n",
+			 netdev->name);
+		break;
+
+	case OCTNET_CMD_VERBOSE_DISABLE:
+		dev_info(&oct->pci_dev->dev, "%s Firmware debug disabled\n",
+			 netdev->name);
+		break;
+
+	case OCTNET_CMD_ENABLE_VLAN_FILTER:
+		dev_info(&oct->pci_dev->dev, "%s VLAN filter enabled\n",
+			 netdev->name);
+		break;
+
+	case OCTNET_CMD_ADD_VLAN_FILTER:
+		dev_info(&oct->pci_dev->dev, "%s VLAN filter %d added\n",
+			 netdev->name, nctrl->ncmd.s.param1);
+		break;
+
+	case OCTNET_CMD_DEL_VLAN_FILTER:
+		dev_info(&oct->pci_dev->dev, "%s VLAN filter %d removed\n",
+			 netdev->name, nctrl->ncmd.s.param1);
+		break;
+
+	case OCTNET_CMD_SET_SETTINGS:
+		dev_info(&oct->pci_dev->dev, "%s settings changed\n",
+			 netdev->name);
+
+		break;
+
+	/* Case to handle "OCTNET_CMD_TNL_RX_CSUM_CTL"
+	 * Command passed by NIC driver
+	 */
+	case OCTNET_CMD_TNL_RX_CSUM_CTL:
+		if (nctrl->ncmd.s.param1 == OCTNET_CMD_RXCSUM_ENABLE) {
+			netif_info(lio, probe, lio->netdev,
+				   "RX Checksum Offload Enabled\n");
+		} else if (nctrl->ncmd.s.param1 ==
+			   OCTNET_CMD_RXCSUM_DISABLE) {
+			netif_info(lio, probe, lio->netdev,
+				   "RX Checksum Offload Disabled\n");
+		}
+		break;
+
+		/* Case to handle "OCTNET_CMD_TNL_TX_CSUM_CTL"
+		 * Command passed by NIC driver
+		 */
+	case OCTNET_CMD_TNL_TX_CSUM_CTL:
+		if (nctrl->ncmd.s.param1 == OCTNET_CMD_TXCSUM_ENABLE) {
+			netif_info(lio, probe, lio->netdev,
+				   "TX Checksum Offload Enabled\n");
+		} else if (nctrl->ncmd.s.param1 ==
+			   OCTNET_CMD_TXCSUM_DISABLE) {
+			netif_info(lio, probe, lio->netdev,
+				   "TX Checksum Offload Disabled\n");
+		}
+		break;
+
+		/* Case to handle "OCTNET_CMD_VXLAN_PORT_CONFIG"
+		 * Command passed by NIC driver
+		 */
+	case OCTNET_CMD_VXLAN_PORT_CONFIG:
+		if (nctrl->ncmd.s.more == OCTNET_CMD_VXLAN_PORT_ADD) {
+			netif_info(lio, probe, lio->netdev,
+				   "VxLAN Destination UDP PORT:%d ADDED\n",
+				   nctrl->ncmd.s.param1);
+		} else if (nctrl->ncmd.s.more ==
+			   OCTNET_CMD_VXLAN_PORT_DEL) {
+			netif_info(lio, probe, lio->netdev,
+				   "VxLAN Destination UDP PORT:%d DELETED\n",
+				   nctrl->ncmd.s.param1);
+		}
+		break;
+
+	case OCTNET_CMD_SET_FLOW_CTL:
+		netif_info(lio, probe, lio->netdev, "Set RX/TX flow control parameters\n");
+		break;
+
+	default:
+		dev_err(&oct->pci_dev->dev, "%s Unknown cmd %d\n", __func__,
+			nctrl->ncmd.s.cmd);
+	}
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 289eb89..dc4879d 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -290,18 +290,16 @@ lio_get_eeprom(struct net_device *netdev, struct ethtool_eeprom *eeprom,
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct_dev = lio->oct_dev;
 	struct octeon_board_info *board_info;
-	int len;
 
 	if (eeprom->offset != 0)
 		return -EINVAL;
 
 	eeprom->magic = oct_dev->pci_dev->vendor;
 	board_info = (struct octeon_board_info *)(&oct_dev->boardinfo);
-	len =
-		sprintf((char *)bytes,
-			"boardname:%s serialnum:%s maj:%lld min:%lld\n",
-			board_info->name, board_info->serial_number,
-			board_info->major, board_info->minor);
+	sprintf((char *)bytes,
+		"boardname:%s serialnum:%s maj:%lld min:%lld\n",
+		board_info->name, board_info->serial_number,
+		board_info->major, board_info->minor);
 
 	return 0;
 }
@@ -406,7 +404,7 @@ octnet_mdio45_access(struct lio *lio, int op, int loc, int *value)
 		dev_err(&oct_dev->pci_dev->dev,
 			"octnet_mdio45_access instruction failed status: %x\n",
 			retval);
-		retval =  -EBUSY;
+		retval = -EBUSY;
 	} else {
 		/* Sleep on a wait queue till the cond flag indicates that the
 		 * response arrived
@@ -1320,8 +1318,8 @@ oct_cfg_rx_intrcnt(struct lio *lio, struct ethtool_coalesce *intr_coal)
 	return 0;
 }
 
-static int oct_cfg_rx_intrtime(struct lio *lio, struct ethtool_coalesce
-			       *intr_coal)
+static int oct_cfg_rx_intrtime(struct lio *lio,
+			       struct ethtool_coalesce *intr_coal)
 {
 	struct octeon_device *oct = lio->oct_dev;
 	u32 time_threshold, rx_coalesce_usecs;
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 20d6942..2ce19e4 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -21,8 +21,6 @@
 **********************************************************************/
 #include <linux/version.h>
 #include <linux/pci.h>
-#include <linux/net_tstamp.h>
-#include <linux/if_vlan.h>
 #include <linux/firmware.h>
 #include <linux/ptp_clock_kernel.h>
 #include <net/vxlan.h>
@@ -52,11 +50,6 @@ module_param(ddr_timeout, int, 0644);
 MODULE_PARM_DESC(ddr_timeout,
 		 "Number of milliseconds to wait for DDR initialization. 0 waits for ddr_timeout to be set to non-zero value before starting to check");
 
-static u32 console_bitmask;
-module_param(console_bitmask, int, 0644);
-MODULE_PARM_DESC(console_bitmask,
-		 "Bitmask indicating which consoles have debug output redirected to syslog.");
-
 #define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK)
 
 #define INCR_INSTRQUEUE_PKT_COUNT(octeon_dev_ptr, iq_no, field, count)  \
@@ -162,27 +155,6 @@ struct octnic_gather {
 	u64 sg_dma_ptr;
 };
 
-/** This structure is used by NIC driver to store information required
- * to free the sk_buff when the packet has been fetched by Octeon.
- * Bytes offset below assume worst-case of a 64-bit system.
- */
-struct octnet_buf_free_info {
-	/** Bytes 1-8.  Pointer to network device private structure. */
-	struct lio *lio;
-
-	/** Bytes 9-16.  Pointer to sk_buff. */
-	struct sk_buff *skb;
-
-	/** Bytes 17-24.  Pointer to gather list. */
-	struct octnic_gather *g;
-
-	/** Bytes 25-32. Physical address of skb->data or gather list. */
-	u64 dptr;
-
-	/** Bytes 33-47. Piggybacked soft command, if any */
-	struct octeon_soft_command *sc;
-};
-
 struct handshake {
 	struct completion init;
 	struct completion started;
@@ -198,6 +170,7 @@ struct octeon_device_priv {
 };
 
 static int octeon_device_init(struct octeon_device *);
+static int liquidio_stop(struct net_device *netdev);
 static void liquidio_remove(struct pci_dev *pdev);
 static int liquidio_probe(struct pci_dev *pdev,
 			  const struct pci_device_id *ent);
@@ -252,76 +225,6 @@ static int lio_wait_for_oq_pkts(struct octeon_device *oct)
 	return pkt_cnt;
 }
 
-void octeon_report_tx_completion_to_bql(void *txq, unsigned int pkts_compl,
-					unsigned int bytes_compl)
-{
-	struct netdev_queue *netdev_queue = txq;
-
-	netdev_tx_completed_queue(netdev_queue, pkts_compl, bytes_compl);
-}
-
-void octeon_update_tx_completion_counters(void *buf, int reqtype,
-					  unsigned int *pkts_compl,
-					  unsigned int *bytes_compl)
-{
-	struct octnet_buf_free_info *finfo;
-	struct sk_buff *skb = NULL;
-	struct octeon_soft_command *sc;
-
-	switch (reqtype) {
-	case REQTYPE_NORESP_NET:
-	case REQTYPE_NORESP_NET_SG:
-		finfo = buf;
-		skb = finfo->skb;
-		break;
-
-	case REQTYPE_RESP_NET_SG:
-	case REQTYPE_RESP_NET:
-		sc = buf;
-		skb = sc->callback_arg;
-		break;
-
-	default:
-		return;
-	}
-
-	(*pkts_compl)++;
-	*bytes_compl += skb->len;
-}
-
-void octeon_report_sent_bytes_to_bql(void *buf, int reqtype)
-{
-	struct octnet_buf_free_info *finfo;
-	struct sk_buff *skb;
-	struct octeon_soft_command *sc;
-	struct netdev_queue *txq;
-
-	switch (reqtype) {
-	case REQTYPE_NORESP_NET:
-	case REQTYPE_NORESP_NET_SG:
-		finfo = buf;
-		skb = finfo->skb;
-		break;
-
-	case REQTYPE_RESP_NET_SG:
-	case REQTYPE_RESP_NET:
-		sc = buf;
-		skb = sc->callback_arg;
-		break;
-
-	default:
-		return;
-	}
-
-	txq = netdev_get_tx_queue(skb->dev, skb_get_queue_mapping(skb));
-	netdev_tx_sent_queue(txq, skb->len);
-}
-
-int octeon_console_debug_enabled(u32 console)
-{
-	return (console_bitmask >> (console)) & 0x1;
-}
-
 /**
  * \brief Forces all IO queues off on a given device
  * @param oct Pointer to Octeon device
@@ -2173,7 +2076,7 @@ static inline int setup_io_queues(struct octeon_device *octeon_dev,
 						   lio->ifidx), NULL);
 		if (retval) {
 			dev_err(&octeon_dev->pci_dev->dev,
-				" %s : Runtime DROQ(RxQ) creation failed.\n",
+				"%s : Runtime DROQ(RxQ) creation failed.\n",
 				__func__);
 			return 1;
 		}
@@ -2340,142 +2243,6 @@ static int liquidio_stop(struct net_device *netdev)
 	return 0;
 }
 
-void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
-{
-	struct octnic_ctrl_pkt *nctrl = (struct octnic_ctrl_pkt *)nctrl_ptr;
-	struct net_device *netdev = (struct net_device *)nctrl->netpndev;
-	struct lio *lio = GET_LIO(netdev);
-	struct octeon_device *oct = lio->oct_dev;
-	u8 *mac;
-
-	switch (nctrl->ncmd.s.cmd) {
-	case OCTNET_CMD_CHANGE_DEVFLAGS:
-	case OCTNET_CMD_SET_MULTI_LIST:
-		break;
-
-	case OCTNET_CMD_CHANGE_MACADDR:
-		mac = ((u8 *)&nctrl->udd[0]) + 2;
-		netif_info(lio, probe, lio->netdev,
-			   "%s %2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x\n",
-			   "MACAddr changed to", mac[0], mac[1],
-			   mac[2], mac[3], mac[4], mac[5]);
-		break;
-
-	case OCTNET_CMD_CHANGE_MTU:
-		/* If command is successful, change the MTU. */
-		netif_info(lio, probe, lio->netdev, " MTU Changed from %d to %d\n",
-			   netdev->mtu, nctrl->ncmd.s.param1);
-		dev_info(&oct->pci_dev->dev, "%s MTU Changed from %d to %d\n",
-			 netdev->name, netdev->mtu,
-			 nctrl->ncmd.s.param1);
-		rtnl_lock();
-		netdev->mtu = nctrl->ncmd.s.param1;
-		call_netdevice_notifiers(NETDEV_CHANGEMTU, netdev);
-		rtnl_unlock();
-		break;
-
-	case OCTNET_CMD_GPIO_ACCESS:
-		netif_info(lio, probe, lio->netdev, "LED Flashing visual identification\n");
-
-		break;
-
-	case OCTNET_CMD_LRO_ENABLE:
-		dev_info(&oct->pci_dev->dev, "%s LRO Enabled\n", netdev->name);
-		break;
-
-	case OCTNET_CMD_LRO_DISABLE:
-		dev_info(&oct->pci_dev->dev, "%s LRO Disabled\n",
-			 netdev->name);
-		break;
-
-	case OCTNET_CMD_VERBOSE_ENABLE:
-		dev_info(&oct->pci_dev->dev, "%s LRO Enabled\n", netdev->name);
-		break;
-
-	case OCTNET_CMD_VERBOSE_DISABLE:
-		dev_info(&oct->pci_dev->dev, "%s LRO Disabled\n",
-			 netdev->name);
-		break;
-
-	case OCTNET_CMD_ENABLE_VLAN_FILTER:
-		dev_info(&oct->pci_dev->dev, "%s VLAN filter enabled\n",
-			 netdev->name);
-		break;
-
-	case OCTNET_CMD_ADD_VLAN_FILTER:
-		dev_info(&oct->pci_dev->dev, "%s VLAN filter %d added\n",
-			 netdev->name, nctrl->ncmd.s.param1);
-		break;
-
-	case OCTNET_CMD_DEL_VLAN_FILTER:
-		dev_info(&oct->pci_dev->dev, "%s VLAN filter %d removed\n",
-			 netdev->name, nctrl->ncmd.s.param1);
-		break;
-
-	case OCTNET_CMD_SET_SETTINGS:
-		dev_info(&oct->pci_dev->dev, "%s settings changed\n",
-			 netdev->name);
-
-		break;
-		/* Case to handle "OCTNET_CMD_TNL_RX_CSUM_CTL"
-		 * Command passed by NIC driver
-		 */
-	case OCTNET_CMD_TNL_RX_CSUM_CTL:
-		if (nctrl->ncmd.s.param1 == OCTNET_CMD_RXCSUM_ENABLE) {
-			netif_info(lio, probe, lio->netdev,
-				   "%s RX Checksum Offload Enabled\n",
-				   netdev->name);
-		} else if (nctrl->ncmd.s.param1 ==
-			   OCTNET_CMD_RXCSUM_DISABLE) {
-			netif_info(lio, probe, lio->netdev,
-				   "%s RX Checksum Offload Disabled\n",
-				   netdev->name);
-		}
-		break;
-
-		/* Case to handle "OCTNET_CMD_TNL_TX_CSUM_CTL"
-		 * Command passed by NIC driver
-		 */
-	case OCTNET_CMD_TNL_TX_CSUM_CTL:
-		if (nctrl->ncmd.s.param1 == OCTNET_CMD_TXCSUM_ENABLE) {
-			netif_info(lio, probe, lio->netdev,
-				   "%s TX Checksum Offload Enabled\n",
-				   netdev->name);
-		} else if (nctrl->ncmd.s.param1 ==
-			   OCTNET_CMD_TXCSUM_DISABLE) {
-			netif_info(lio, probe, lio->netdev,
-				   "%s TX Checksum Offload Disabled\n",
-				   netdev->name);
-		}
-		break;
-
-		/* Case to handle "OCTNET_CMD_VXLAN_PORT_CONFIG"
-		 * Command passed by NIC driver
-		 */
-	case OCTNET_CMD_VXLAN_PORT_CONFIG:
-		if (nctrl->ncmd.s.more == OCTNET_CMD_VXLAN_PORT_ADD) {
-			netif_info(lio, probe, lio->netdev,
-				   "%s VxLAN Destination UDP PORT:%d ADDED\n",
-				   netdev->name,
-				   nctrl->ncmd.s.param1);
-		} else if (nctrl->ncmd.s.more ==
-			   OCTNET_CMD_VXLAN_PORT_DEL) {
-			netif_info(lio, probe, lio->netdev,
-				   "%s VxLAN Destination UDP PORT:%d DELETED\n",
-				   netdev->name,
-				   nctrl->ncmd.s.param1);
-		}
-		break;
-
-	case OCTNET_CMD_SET_FLOW_CTL:
-		netif_info(lio, probe, lio->netdev, "Set RX/TX flow control parameters\n");
-		break;
-
-	default:
-		dev_err(&oct->pci_dev->dev, "%s Unknown cmd %d\n", __func__,
-			nctrl->ncmd.s.cmd);
-	}
-}
 
 /**
  * \brief Converts a mask based on net device flags
@@ -2817,8 +2584,7 @@ static void handle_timestamp(struct octeon_device *oct,
  */
 static inline int send_nic_timestamp_pkt(struct octeon_device *oct,
 					 struct octnic_data_pkt *ndata,
-					 struct octnet_buf_free_info *finfo,
-					 int xmit_more)
+					 struct octnet_buf_free_info *finfo)
 {
 	int retval;
 	struct octeon_soft_command *sc;
@@ -2848,7 +2614,7 @@ static inline int send_nic_timestamp_pkt(struct octeon_device *oct,
 
 	len = (u32)((struct octeon_instr_ih2 *)(&sc->cmd.cmd2.ih2))->dlengsz;
 
-	ring_doorbell = !xmit_more;
+	ring_doorbell = 1;
 	retval = octeon_send_command(oct, sc->iq_no, ring_doorbell, &sc->cmd,
 				     sc, len, ndata->reqtype);
 
@@ -2881,7 +2647,7 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 	union tx_info *tx_info;
 	int status = 0;
 	int q_idx = 0, iq_no = 0;
-	int xmit_more, j;
+	int j;
 	u64 dptr = 0;
 	u32 tag = 0;
 
@@ -3077,12 +2843,10 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 		irh->vlan = skb_vlan_tag_get(skb) & 0xfff;
 	}
 
-	xmit_more = skb->xmit_more;
-
 	if (unlikely(cmdsetup.s.timestamp))
-		status = send_nic_timestamp_pkt(oct, &ndata, finfo, xmit_more);
+		status = send_nic_timestamp_pkt(oct, &ndata, finfo);
 	else
-		status = octnet_send_nic_data_pkt(oct, &ndata, xmit_more);
+		status = octnet_send_nic_data_pkt(oct, &ndata);
 	if (status == IQ_SEND_FAILED)
 		goto lio_xmit_failed;
 
@@ -3190,8 +2954,8 @@ static int liquidio_vlan_rx_kill_vid(struct net_device *netdev,
  *                              OCTNET_CMD_RXCSUM_DISABLE
  * @returns                     SUCCESS or FAILURE
  */
-int liquidio_set_rxcsum_command(struct net_device *netdev, int command,
-				u8 rx_cmd)
+static int liquidio_set_rxcsum_command(struct net_device *netdev, int command,
+				       u8 rx_cmd)
 {
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
@@ -3249,31 +3013,6 @@ static int liquidio_vxlan_port_command(struct net_device *netdev, int command,
 	return ret;
 }
 
-int liquidio_set_feature(struct net_device *netdev, int cmd, u16 param1)
-{
-	struct lio *lio = GET_LIO(netdev);
-	struct octeon_device *oct = lio->oct_dev;
-	struct octnic_ctrl_pkt nctrl;
-	int ret = 0;
-
-	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
-
-	nctrl.ncmd.u64 = 0;
-	nctrl.ncmd.s.cmd = cmd;
-	nctrl.ncmd.s.param1 = param1;
-	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
-	nctrl.wait_time = 100;
-	nctrl.netpndev = (u64)netdev;
-	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
-
-	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
-	if (ret < 0) {
-		dev_err(&oct->pci_dev->dev, "Feature change failed in core (ret: 0x%x)\n",
-			ret);
-	}
-	return ret;
-}
-
 /** \brief Net device fix features
  * @param netdev  pointer to network device
  * @param request features requested
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
index bbb50ea..93dac02 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_console.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
@@ -25,12 +25,13 @@
  */
 #include <linux/pci.h>
 #include <linux/netdevice.h>
+#include <linux/crc32.h>
 #include "liquidio_common.h"
 #include "octeon_droq.h"
 #include "octeon_iq.h"
 #include "response_manager.h"
 #include "octeon_device.h"
-#include "octeon_main.h"
+#include "liquidio_image.h"
 #include "octeon_mem_ops.h"
 
 static void octeon_remote_lock(void);
@@ -40,6 +41,10 @@ static u64 cvmx_bootmem_phy_named_block_find(struct octeon_device *oct,
 					     u32 flags);
 static int octeon_console_read(struct octeon_device *oct, u32 console_num,
 			       char *buffer, u32 buf_size);
+static u32 console_bitmask;
+module_param(console_bitmask, int, 0644);
+MODULE_PARM_DESC(console_bitmask,
+		 "Bitmask indicating which consoles have debug output redirected to syslog.");
 
 #define MIN(a, b) min((a), (b))
 #define CAST_ULL(v) ((u64)(v))
@@ -177,6 +182,15 @@ struct octeon_pci_console_desc {
 	__cvmx_bootmem_desc_get(oct, addr,                               \
 		offsetof(struct cvmx_bootmem_named_block_desc, field),   \
 		SIZEOF_FIELD(struct cvmx_bootmem_named_block_desc, field))
+/**
+ * \brief determines if a given console has debug enabled.
+ * @param console console to check
+ * @returns  1 = enabled. 0 otherwise
+ */
+static int octeon_console_debug_enabled(u32 console)
+{
+	return (console_bitmask >> (console)) & 0x1;
+}
 
 /**
  * This function is the implementation of the get macros defined
@@ -709,3 +723,103 @@ static int octeon_console_read(struct octeon_device *oct, u32 console_num,
 
 	return bytes_to_read;
 }
+
+u8 fbuf[4 * 1024 * 1024];
+
+int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
+			     size_t size)
+{
+	int ret = 0;
+	u8 *p = fbuf;
+	u32 crc32_result;
+	u64 load_addr;
+	u32 image_len;
+	struct octeon_firmware_file_header *h;
+	u32 i, rem;
+
+	if (size < sizeof(struct octeon_firmware_file_header)) {
+		dev_err(&oct->pci_dev->dev, "Firmware file too small (%d < %d).\n",
+			(u32)size,
+			(u32)sizeof(struct octeon_firmware_file_header));
+		return -EINVAL;
+	}
+
+	h = (struct octeon_firmware_file_header *)data;
+
+	if (be32_to_cpu(h->magic) != LIO_NIC_MAGIC) {
+		dev_err(&oct->pci_dev->dev, "Unrecognized firmware file.\n");
+		return -EINVAL;
+	}
+
+	crc32_result = crc32((unsigned int)~0, data,
+			     sizeof(struct octeon_firmware_file_header) -
+			     sizeof(u32)) ^ ~0U;
+	if (crc32_result != be32_to_cpu(h->crc32)) {
+		dev_err(&oct->pci_dev->dev, "Firmware CRC mismatch (0x%08x != 0x%08x).\n",
+			crc32_result, be32_to_cpu(h->crc32));
+		return -EINVAL;
+	}
+
+	if (strncmp(LIQUIDIO_PACKAGE, h->version, strlen(LIQUIDIO_PACKAGE))) {
+		dev_err(&oct->pci_dev->dev, "Unmatched firmware package type. Expected %s, got %s.\n",
+			LIQUIDIO_PACKAGE, h->version);
+		return -EINVAL;
+	}
+
+	if (memcmp(LIQUIDIO_BASE_VERSION, h->version + strlen(LIQUIDIO_PACKAGE),
+		   strlen(LIQUIDIO_BASE_VERSION))) {
+		dev_err(&oct->pci_dev->dev, "Unmatched firmware version. Expected %s.x, got %s.\n",
+			LIQUIDIO_BASE_VERSION,
+			h->version + strlen(LIQUIDIO_PACKAGE));
+		return -EINVAL;
+	}
+
+	if (be32_to_cpu(h->num_images) > LIO_MAX_IMAGES) {
+		dev_err(&oct->pci_dev->dev, "Too many images in firmware file (%d).\n",
+			be32_to_cpu(h->num_images));
+		return -EINVAL;
+	}
+
+	dev_info(&oct->pci_dev->dev, "Firmware version: %s\n", h->version);
+	snprintf(oct->fw_info.liquidio_firmware_version, 32, "LIQUIDIO: %s",
+		 h->version);
+
+	data += sizeof(struct octeon_firmware_file_header);
+
+	dev_info(&oct->pci_dev->dev, "%s: Loading %d images\n", __func__,
+		 be32_to_cpu(h->num_images));
+	/* load all images */
+	for (i = 0; i < be32_to_cpu(h->num_images); i++) {
+		load_addr = be64_to_cpu(h->desc[i].addr);
+		image_len = be32_to_cpu(h->desc[i].len);
+
+		dev_info(&oct->pci_dev->dev, "Loading firmware %d at %llx\n",
+			 image_len, load_addr);
+
+		/* Write in 4MB chunks*/
+		rem = image_len;
+
+		while (rem) {
+			if (rem < (4 * 1024 * 1024))
+				size = rem;
+			else
+				size = 4 * 1024 * 1024;
+
+			memcpy(p, data, size);
+
+			/* download the image */
+			octeon_pci_write_core_mem(oct, load_addr, p, (u32)size);
+
+			data += size;
+			rem -= (u32)size;
+			load_addr += size;
+		}
+	}
+	dev_info(&oct->pci_dev->dev, "Writing boot command: %s\n",
+		 h->bootcmd);
+
+	/* Invoke the bootcmd */
+	ret = octeon_console_send_cmd(oct, h->bootcmd, 50);
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 0eb504a..cff845c 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -20,7 +20,6 @@
 * Contact Cavium, Inc. for more information
 **********************************************************************/
 #include <linux/pci.h>
-#include <linux/crc32.h>
 #include <linux/netdevice.h>
 #include <linux/vmalloc.h>
 #include "liquidio_common.h"
@@ -32,8 +31,6 @@
 #include "octeon_network.h"
 #include "cn66xx_regs.h"
 #include "cn66xx_device.h"
-#include "liquidio_image.h"
-#include "octeon_mem_ops.h"
 
 /** Default configuration
  *  for CN66XX OCTEON Models.
@@ -541,107 +538,6 @@ static char *get_oct_app_string(u32 app_mode)
 	return oct_dev_app_str[CVM_DRV_INVALID_APP - CVM_DRV_APP_START];
 }
 
-u8 fbuf[4 * 1024 * 1024];
-
-int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
-			     size_t size)
-{
-	int ret = 0;
-	u8 *p = fbuf;
-	u32 crc32_result;
-	u64 load_addr;
-	u32 image_len;
-	struct octeon_firmware_file_header *h;
-	u32 i, rem, base_len = strlen(LIQUIDIO_BASE_VERSION);
-	char *base;
-
-	if (size < sizeof(struct octeon_firmware_file_header)) {
-		dev_err(&oct->pci_dev->dev, "Firmware file too small (%d < %d).\n",
-			(u32)size,
-			(u32)sizeof(struct octeon_firmware_file_header));
-		return -EINVAL;
-	}
-
-	h = (struct octeon_firmware_file_header *)data;
-
-	if (be32_to_cpu(h->magic) != LIO_NIC_MAGIC) {
-		dev_err(&oct->pci_dev->dev, "Unrecognized firmware file.\n");
-		return -EINVAL;
-	}
-
-	crc32_result = crc32((unsigned int)~0, data,
-			     sizeof(struct octeon_firmware_file_header) -
-			     sizeof(u32)) ^ ~0U;
-	if (crc32_result != be32_to_cpu(h->crc32)) {
-		dev_err(&oct->pci_dev->dev, "Firmware CRC mismatch (0x%08x != 0x%08x).\n",
-			crc32_result, be32_to_cpu(h->crc32));
-		return -EINVAL;
-	}
-
-	if (strncmp(LIQUIDIO_PACKAGE, h->version, strlen(LIQUIDIO_PACKAGE))) {
-		dev_err(&oct->pci_dev->dev, "Unmatched firmware package type. Expected %s, got %s.\n",
-			LIQUIDIO_PACKAGE, h->version);
-		return -EINVAL;
-	}
-
-	base = h->version + strlen(LIQUIDIO_PACKAGE);
-	ret = memcmp(LIQUIDIO_BASE_VERSION, base, base_len);
-	if (ret) {
-		dev_err(&oct->pci_dev->dev, "Unmatched firmware version. Expected %s.x, got %s.\n",
-			LIQUIDIO_BASE_VERSION, base);
-		return -EINVAL;
-	}
-
-	if (be32_to_cpu(h->num_images) > LIO_MAX_IMAGES) {
-		dev_err(&oct->pci_dev->dev, "Too many images in firmware file (%d).\n",
-			be32_to_cpu(h->num_images));
-		return -EINVAL;
-	}
-
-	dev_info(&oct->pci_dev->dev, "Firmware version: %s\n", h->version);
-	snprintf(oct->fw_info.liquidio_firmware_version, 32, "LIQUIDIO: %s",
-		 h->version);
-
-	data += sizeof(struct octeon_firmware_file_header);
-
-	dev_info(&oct->pci_dev->dev, "%s: Loading %d images\n", __func__,
-		 be32_to_cpu(h->num_images));
-	/* load all images */
-	for (i = 0; i < be32_to_cpu(h->num_images); i++) {
-		load_addr = be64_to_cpu(h->desc[i].addr);
-		image_len = be32_to_cpu(h->desc[i].len);
-
-		dev_info(&oct->pci_dev->dev, "Loading firmware %d at %llx\n",
-			 image_len, load_addr);
-
-		/* Write in 4MB chunks*/
-		rem = image_len;
-
-		while (rem) {
-			if (rem < (4 * 1024 * 1024))
-				size = rem;
-			else
-				size = 4 * 1024 * 1024;
-
-			memcpy(p, data, size);
-
-			/* download the image */
-			octeon_pci_write_core_mem(oct, load_addr, p, (u32)size);
-
-			data += size;
-			rem -= (u32)size;
-			load_addr += size;
-		}
-	}
-	dev_info(&oct->pci_dev->dev, "Writing boot command: %s\n",
-		 h->bootcmd);
-
-	/* Invoke the bootcmd */
-	ret = octeon_console_send_cmd(oct, h->bootcmd, 50);
-
-	return 0;
-}
-
 void octeon_free_device_mem(struct octeon_device *oct)
 {
 	int i;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_main.h b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
index bc14e4c..ebeef95 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_main.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
@@ -38,12 +38,26 @@
 
 #define DRV_NAME "LiquidIO"
 
-/**
- * \brief determines if a given console has debug enabled.
- * @param console console to check
- * @returns  1 = enabled. 0 otherwise
+/** This structure is used by NIC driver to store information required
+ * to free the sk_buff when the packet has been fetched by Octeon.
+ * Bytes offset below assume worst-case of a 64-bit system.
  */
-int octeon_console_debug_enabled(u32 console);
+struct octnet_buf_free_info {
+	/** Bytes 1-8.  Pointer to network device private structure. */
+	struct lio *lio;
+
+	/** Bytes 9-16.  Pointer to sk_buff. */
+	struct sk_buff *skb;
+
+	/** Bytes 17-24.  Pointer to gather list. */
+	struct octnic_gather *g;
+
+	/** Bytes 25-32. Physical address of skb->data or gather list. */
+	u64 dptr;
+
+	/** Bytes 33-47. Piggybacked soft command, if any */
+	struct octeon_soft_command *sc;
+};
 
 /* BQL-related functions */
 void octeon_report_sent_bytes_to_bql(void *buf, int reqtype);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
index 95a4bbe..0dc081a 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
@@ -19,7 +19,6 @@
  * This file may also be available under a different license from Cavium.
  * Contact Cavium, Inc. for more information
  **********************************************************************/
-#include <linux/pci.h>
 #include <linux/netdevice.h>
 #include "liquidio_common.h"
 #include "octeon_droq.h"
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index fb820dc..7cfbdf9 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -26,8 +26,6 @@
 
 #ifndef __OCTEON_NETWORK_H__
 #define __OCTEON_NETWORK_H__
-#include <linux/version.h>
-#include <linux/dma-mapping.h>
 #include <linux/ptp_clock_kernel.h>
 
 #define LIO_MAX_MTU_SIZE (OCTNET_MAX_FRM_SIZE - OCTNET_FRM_HEADER_SIZE)
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
index 166727b..0c4013d 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
@@ -19,7 +19,6 @@
  * This file may also be available under a different license from Cavium.
  * Contact Cavium, Inc. for more information
  **********************************************************************/
-#include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include "liquidio_common.h"
@@ -73,12 +72,9 @@ octeon_alloc_soft_command_resp(struct octeon_device    *oct,
 }
 
 int octnet_send_nic_data_pkt(struct octeon_device *oct,
-			     struct octnic_data_pkt *ndata,
-			     u32 xmit_more)
+			     struct octnic_data_pkt *ndata)
 {
-	int ring_doorbell;
-
-	ring_doorbell = !xmit_more;
+	int ring_doorbell = 1;
 
 	return octeon_send_command(oct, ndata->q_no, ring_doorbell, &ndata->cmd,
 				   ndata->buf, ndata->datasize,
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
index b71a2bb..e55400c 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
@@ -278,7 +278,7 @@ octeon_alloc_soft_command_resp(struct octeon_device    *oct,
  * queue should be stopped, and IQ_SEND_OK if it sent okay.
  */
 int octnet_send_nic_data_pkt(struct octeon_device *oct,
-			     struct octnic_data_pkt *ndata, u32 xmit_more);
+			     struct octnic_data_pkt *ndata);
 
 /** Send a NIC control packet to the device
  * @param oct - octeon device pointer
-- 
1.8.3.1
