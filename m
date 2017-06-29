From: Atul Gupta <atul.gupta@chelsio.com>
Subject: [PATCH net-next v2 1/2] cxgb4: Add PTP Hardware Clock (PHC) support
Date: Thu, 29 Jun 2017 17:08:06 +0530
Message-ID: <1498736287-27398-1-git-send-email-atul.gupta@chelsio.com>
Cc: Atul Gupta <atul.gupta@chelsio.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:11555 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752369AbdF2Lid (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 07:38:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add PTP IEEE-1588 support and make it accessible via PHC subsystem.
The functionality is enabled for T5/T6 adapters. Driver interfaces with
Firmware to program and adjust the clock offset.

Cc: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Atul Gupta <atul.gupta@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
V2: Splitting the patch
---
 drivers/net/ethernet/chelsio/cxgb4/Makefile     |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |   9 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  82 +++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c  | 476 ++++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.h  |  74 ++++
 drivers/net/ethernet/chelsio/cxgb4/sge.c        | 166 ++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |  28 ++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |   2 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  50 +++
 9 files changed, 877 insertions(+), 12 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.h

diff --git a/drivers/net/ethernet/chelsio/cxgb4/Makefile b/drivers/net/ethernet/chelsio/cxgb4/Makefile
index c6b71f6..8172127 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/Makefile
+++ b/drivers/net/ethernet/chelsio/cxgb4/Makefile
@@ -4,7 +4,7 @@
 
 obj-$(CONFIG_CHELSIO_T4) += cxgb4.o
 
-cxgb4-objs := cxgb4_main.o l2t.o t4_hw.o sge.o clip_tbl.o cxgb4_ethtool.o cxgb4_uld.o sched.o cxgb4_filter.o cxgb4_tc_u32.o
+cxgb4-objs := cxgb4_main.o l2t.o t4_hw.o sge.o clip_tbl.o cxgb4_ethtool.o cxgb4_uld.o sched.o cxgb4_filter.o cxgb4_tc_u32.o cxgb4_ptp.o
 cxgb4-$(CONFIG_CHELSIO_T4_DCB) +=  cxgb4_dcb.o
 cxgb4-$(CONFIG_CHELSIO_T4_FCOE) +=  cxgb4_fcoe.o
 cxgb4-$(CONFIG_DEBUG_FS) += cxgb4_debugfs.o
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 451c138..dd6e5a3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -48,6 +48,8 @@
 #include <linux/vmalloc.h>
 #include <linux/etherdevice.h>
 #include <linux/net_tstamp.h>
+#include <linux/ptp_clock_kernel.h>
+#include <linux/ptp_classify.h>
 #include <asm/io.h>
 #include "t4_chip_type.h"
 #include "cxgb4_uld.h"
@@ -510,6 +512,7 @@ struct port_info {
 #endif /* CONFIG_CHELSIO_T4_FCOE */
 	bool rxtstamp;  /* Enable TS */
 	struct hwtstamp_config tstamp_config;
+	bool ptp_enable;
 	struct sched_table *sched_tbl;
 };
 
@@ -705,6 +708,7 @@ struct sge_uld_txq_info {
 
 struct sge {
 	struct sge_eth_txq ethtxq[MAX_ETH_QSETS];
+	struct sge_eth_txq ptptxq;
 	struct sge_ctrl_txq ctrlq[MAX_CTRL_QUEUES];
 
 	struct sge_eth_rxq ethrxq[MAX_ETH_QSETS];
@@ -869,6 +873,11 @@ struct adapter {
 			 * used for all 4 filters.
 			 */
 
+	struct ptp_clock *ptp_clock;
+	struct ptp_clock_info ptp_clock_info;
+	struct sk_buff *ptp_tx_skb;
+	/* ptp lock */
+	spinlock_t ptp_lock;
 	spinlock_t stats_lock;
 	spinlock_t win0_lock ____cacheline_aligned_in_smp;
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index f41507e..86f92e3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -79,6 +79,7 @@
 #include "l2t.h"
 #include "sched.h"
 #include "cxgb4_tc_u32.h"
+#include "cxgb4_ptp.h"
 
 char cxgb4_driver_name[] = KBUILD_MODNAME;
 
@@ -872,6 +873,14 @@ static int setup_sge_queues(struct adapter *adap)
 			goto freeout;
 	}
 
+	if (!is_t4(adap->params.chip)) {
+		err = t4_sge_alloc_eth_txq(adap, &s->ptptxq, adap->port[0],
+					   netdev_get_tx_queue(adap->port[0], 0)
+					   , s->fw_evtq.cntxt_id);
+		if (err)
+			goto freeout;
+	}
+
 	t4_write_reg(adap, is_t4(adap->params.chip) ?
 				MPS_TRC_RSS_CONTROL_A :
 				MPS_T5_TRC_RSS_CONTROL_A,
@@ -2438,6 +2447,7 @@ static int cxgb_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 	unsigned int mbox;
 	int ret = 0, prtad, devad;
 	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	struct mii_ioctl_data *data = (struct mii_ioctl_data *)&req->ifr_data;
 
 	switch (cmd) {
@@ -2475,18 +2485,69 @@ static int cxgb_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 				   sizeof(pi->tstamp_config)))
 			return -EFAULT;
 
-		switch (pi->tstamp_config.rx_filter) {
-		case HWTSTAMP_FILTER_NONE:
+		if (!is_t4(adapter->params.chip)) {
+			switch (pi->tstamp_config.tx_type) {
+			case HWTSTAMP_TX_OFF:
+			case HWTSTAMP_TX_ON:
+				break;
+			default:
+				return -ERANGE;
+			}
+
+			switch (pi->tstamp_config.rx_filter) {
+			case HWTSTAMP_FILTER_NONE:
+				pi->rxtstamp = false;
+				break;
+			case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+			case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+				cxgb4_ptprx_timestamping(pi, pi->port_id,
+							 PTP_TS_L4);
+				break;
+			case HWTSTAMP_FILTER_PTP_V2_EVENT:
+				cxgb4_ptprx_timestamping(pi, pi->port_id,
+							 PTP_TS_L2_L4);
+				break;
+			case HWTSTAMP_FILTER_ALL:
+			case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+			case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+			case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+			case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+				pi->rxtstamp = true;
+				break;
+			default:
+				pi->tstamp_config.rx_filter =
+					HWTSTAMP_FILTER_NONE;
+				return -ERANGE;
+			}
+
+			if ((pi->tstamp_config.tx_type == HWTSTAMP_TX_OFF) &&
+			    (pi->tstamp_config.rx_filter ==
+				HWTSTAMP_FILTER_NONE)) {
+				if (cxgb4_ptp_txtype(adapter, pi->port_id) >= 0)
+					pi->ptp_enable = false;
+			}
+
+			if (pi->tstamp_config.rx_filter !=
+				HWTSTAMP_FILTER_NONE) {
+				if (cxgb4_ptp_redirect_rx_packet(adapter,
+								 pi) >= 0)
+					pi->ptp_enable = true;
+			}
+		} else {
+			/* For T4 Adapters */
+			switch (pi->tstamp_config.rx_filter) {
+			case HWTSTAMP_FILTER_NONE:
 			pi->rxtstamp = false;
 			break;
-		case HWTSTAMP_FILTER_ALL:
+			case HWTSTAMP_FILTER_ALL:
 			pi->rxtstamp = true;
 			break;
-		default:
-			pi->tstamp_config.rx_filter = HWTSTAMP_FILTER_NONE;
+			default:
+			pi->tstamp_config.rx_filter =
+			HWTSTAMP_FILTER_NONE;
 			return -ERANGE;
+			}
 		}
-
 		return copy_to_user(req->ifr_data, &pi->tstamp_config,
 				    sizeof(pi->tstamp_config)) ?
 			-EFAULT : 0;
@@ -4240,6 +4301,9 @@ static void cfg_queues(struct adapter *adap)
 	for (i = 0; i < ARRAY_SIZE(s->ctrlq); i++)
 		s->ctrlq[i].q.size = 512;
 
+	if (!is_t4(adap->params.chip))
+		s->ptptxq.q.size = 8;
+
 	init_rspq(adap, &s->fw_evtq, 0, 1, 1024, 64);
 	init_rspq(adap, &s->intrq, 0, 1, 512, 64);
 }
@@ -5138,6 +5202,9 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		mutex_unlock(&uld_mutex);
 	}
 
+	if (!is_t4(adapter->params.chip))
+		cxgb4_ptp_init(adapter);
+
 	print_adapter_info(adapter);
 	setup_fw_sge_queues(adapter);
 	return 0;
@@ -5247,6 +5314,9 @@ static void remove_one(struct pci_dev *pdev)
 
 		debugfs_remove_recursive(adapter->debugfs_root);
 
+		if (!is_t4(adapter->params.chip))
+			cxgb4_ptp_stop(adapter);
+
 		/* If we allocated filters, free up state associated with any
 		 * valid filters ...
 		 */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c
new file mode 100644
index 0000000..b68c7fa
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.c
@@ -0,0 +1,476 @@
+/*
+ * cxgb4_ptp.c:Chelsio PTP support for T5/T6
+ *
+ * Copyright (c) 2003-2017 Chelsio Communications, Inc. All rights reserved.
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
+ * Written by: Atul Gupta (atul.gupta@chelsio.com)
+ */
+
+#include <linux/module.h>
+#include <linux/net_tstamp.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/pps_kernel.h>
+#include <linux/ptp_clock_kernel.h>
+#include <linux/ptp_classify.h>
+#include <linux/udp.h>
+
+#include "cxgb4.h"
+#include "t4_hw.h"
+#include "t4_regs.h"
+#include "t4_msg.h"
+#include "t4fw_api.h"
+#include "cxgb4_ptp.h"
+
+/**
+ * cxgb4_ptp_is_ptp_tx - determine whether TX packet is PTP or not
+ * @skb: skb of outgoing ptp request
+ *
+ */
+bool cxgb4_ptp_is_ptp_tx(struct sk_buff *skb)
+{
+	struct udphdr *uh;
+
+	uh = udp_hdr(skb);
+	return skb->len >= PTP_MIN_LENGTH &&
+		skb->len <= PTP_IN_TRANSMIT_PACKET_MAXNUM &&
+		likely(skb->protocol == htons(ETH_P_IP)) &&
+		ip_hdr(skb)->protocol == IPPROTO_UDP &&
+		uh->dest == htons(PTP_EVENT_PORT);
+}
+
+bool is_ptp_enabled(struct sk_buff *skb, struct net_device *dev)
+{
+	struct port_info *pi;
+
+	pi = netdev_priv(dev);
+	return (pi->ptp_enable && cxgb4_xmit_with_hwtstamp(skb) &&
+		cxgb4_ptp_is_ptp_tx(skb));
+}
+
+/**
+ * cxgb4_ptp_is_ptp_rx - determine whether RX packet is PTP or not
+ * @skb: skb of incoming ptp request
+ *
+ */
+bool cxgb4_ptp_is_ptp_rx(struct sk_buff *skb)
+{
+	struct udphdr *uh = (struct udphdr *)(skb->data + ETH_HLEN +
+					      IPV4_HLEN(skb->data));
+
+	return  uh->dest == htons(PTP_EVENT_PORT) &&
+		uh->source == htons(PTP_EVENT_PORT);
+}
+
+/**
+ * cxgb4_ptp_read_hwstamp - read timestamp for TX event PTP message
+ * @adapter: board private structure
+ * @pi: port private structure
+ *
+ */
+void cxgb4_ptp_read_hwstamp(struct adapter *adapter, struct port_info *pi)
+{
+	struct skb_shared_hwtstamps *skb_ts = NULL;
+	u64 tx_ts;
+
+	skb_ts = skb_hwtstamps(adapter->ptp_tx_skb);
+
+	tx_ts = t4_read_reg(adapter,
+			    T5_PORT_REG(pi->port_id, MAC_PORT_TX_TS_VAL_LO));
+
+	tx_ts |= (u64)t4_read_reg(adapter,
+				  T5_PORT_REG(pi->port_id,
+					      MAC_PORT_TX_TS_VAL_HI)) << 32;
+	skb_ts->hwtstamp = ns_to_ktime(tx_ts);
+	skb_tstamp_tx(adapter->ptp_tx_skb, skb_ts);
+	dev_kfree_skb_any(adapter->ptp_tx_skb);
+	spin_lock(&adapter->ptp_lock);
+	adapter->ptp_tx_skb = NULL;
+	spin_unlock(&adapter->ptp_lock);
+}
+
+static void cxgb4_init_ptp_timer(struct adapter *adapter)
+{
+	struct fw_ptp_cmd c;
+	int err;
+
+	memset(&c, 0, sizeof(c));
+		c.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PTP_CMD) |
+					     FW_CMD_REQUEST_F |
+					     FW_CMD_WRITE_F |
+					     FW_PTP_CMD_PORTID_V(0));
+	c.retval_len16 = cpu_to_be32(FW_CMD_LEN16_V(sizeof(c) / 16));
+	c.u.scmd.sc = FW_PTP_SC_INIT_TIMER;
+
+	err = t4_wr_mbox(adapter, adapter->mbox, &c, sizeof(c), NULL);
+	if (err < 0)
+		dev_err(adapter->pdev_dev,
+			"PTP: %s error %d\n", __func__, -err);
+}
+
+/**
+ * cxgb4_ptprx_timestamping - Enable Timestamp for RX PTP event message
+ * @pi: port private structure
+ * @port: pot number
+ * @mode: RX mode
+ *
+ */
+int cxgb4_ptprx_timestamping(struct port_info *pi, u8 port, u16 mode)
+{
+	struct adapter *adapter = pi->adapter;
+	struct fw_ptp_cmd c;
+	int err;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PTP_CMD) |
+				     FW_CMD_REQUEST_F |
+				     FW_CMD_WRITE_F |
+				     FW_PTP_CMD_PORTID_V(port));
+	c.retval_len16 = cpu_to_be32(FW_CMD_LEN16_V(sizeof(c) / 16));
+	c.u.init.sc = FW_PTP_SC_RXTIME_STAMP;
+	c.u.init.mode = cpu_to_be16(mode);
+
+	err = t4_wr_mbox(adapter, adapter->mbox, &c, sizeof(c), NULL);
+	if (err < 0)
+		dev_err(adapter->pdev_dev,
+			"PTP: %s error %d\n", __func__, -err);
+	return err;
+}
+
+int cxgb4_ptp_txtype(struct adapter *adapter, u8 port)
+{
+	struct fw_ptp_cmd c;
+	int err;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PTP_CMD) |
+				     FW_CMD_REQUEST_F |
+				     FW_CMD_WRITE_F |
+				     FW_PTP_CMD_PORTID_V(port));
+	c.retval_len16 = cpu_to_be32(FW_CMD_LEN16_V(sizeof(c) / 16));
+	c.u.init.sc = FW_PTP_SC_TX_TYPE;
+	c.u.init.mode = cpu_to_be16(PTP_TS_NONE);
+
+	err = t4_wr_mbox(adapter, adapter->mbox, &c, sizeof(c), NULL);
+	if (err < 0)
+		dev_err(adapter->pdev_dev,
+			"PTP: %s error %d\n", __func__, -err);
+
+	return err;
+}
+
+int cxgb4_ptp_redirect_rx_packet(struct adapter *adapter, struct port_info *pi)
+{
+	struct sge *s = &adapter->sge;
+	struct sge_eth_rxq *receive_q =  &s->ethrxq[pi->first_qset];
+	struct fw_ptp_cmd c;
+	int err;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PTP_CMD) |
+				     FW_CMD_REQUEST_F |
+				     FW_CMD_WRITE_F |
+				     FW_PTP_CMD_PORTID_V(pi->port_id));
+
+	c.retval_len16 = cpu_to_be32(FW_CMD_LEN16_V(sizeof(c) / 16));
+	c.u.init.sc = FW_PTP_SC_RDRX_TYPE;
+	c.u.init.txchan = pi->tx_chan;
+	c.u.init.absid = cpu_to_be16(receive_q->rspq.abs_id);
+
+	err = t4_wr_mbox(adapter, adapter->mbox, &c, sizeof(c), NULL);
+	if (err < 0)
+		dev_err(adapter->pdev_dev,
+			"PTP: %s error %d\n", __func__, -err);
+	return err;
+}
+
+/**
+ * cxgb4_ptp_adjfreq - adjust the frequency of the hardware clock
+ * @ptp: ptp clock structure
+ * @ppb: Desired frequency change in parts per billion
+ *
+ * Adjust the frequency of the PHC cycle counter by the indicated ppb from
+ * the base frequency.
+ */
+static int cxgb4_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
+{
+	struct adapter *adapter = (struct adapter *)container_of(ptp,
+				   struct adapter, ptp_clock_info);
+	struct fw_ptp_cmd c;
+	int err;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PTP_CMD) |
+				     FW_CMD_REQUEST_F |
+				     FW_CMD_WRITE_F |
+				     FW_PTP_CMD_PORTID_V(0));
+	c.retval_len16 = cpu_to_be32(FW_CMD_LEN16_V(sizeof(c) / 16));
+	c.u.ts.sc = FW_PTP_SC_ADJ_FREQ;
+	c.u.ts.sign = (ppb < 0) ? 1 : 0;
+	if (ppb < 0)
+		ppb = -ppb;
+	c.u.ts.ppb = cpu_to_be32(ppb);
+
+	err = t4_wr_mbox(adapter, adapter->mbox, &c, sizeof(c), NULL);
+	if (err < 0)
+		dev_err(adapter->pdev_dev,
+			"PTP: %s error %d\n", __func__, -err);
+
+	return err;
+}
+
+/**
+ * cxgb4_ptp_fineadjtime - Shift the time of the hardware clock
+ * @ptp: ptp clock structure
+ * @delta: Desired change in nanoseconds
+ *
+ * Adjust the timer by resetting the timecounter structure.
+ */
+static int  cxgb4_ptp_fineadjtime(struct adapter *adapter, s64 delta)
+{
+	struct fw_ptp_cmd c;
+	int err;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PTP_CMD) |
+				     FW_CMD_REQUEST_F |
+				     FW_CMD_WRITE_F |
+				     FW_PTP_CMD_PORTID_V(0));
+	c.retval_len16 = cpu_to_be32(FW_CMD_LEN16_V(sizeof(c) / 16));
+	c.u.ts.sc = FW_PTP_SC_ADJ_FTIME;
+	c.u.ts.tm = cpu_to_be64(delta);
+
+	err = t4_wr_mbox(adapter, adapter->mbox, &c, sizeof(c), NULL);
+	if (err < 0)
+		dev_err(adapter->pdev_dev,
+			"PTP: %s error %d\n", __func__, -err);
+	return err;
+}
+
+/**
+ * cxgb4_ptp_adjtime - Shift the time of the hardware clock
+ * @ptp: ptp clock structure
+ * @delta: Desired change in nanoseconds
+ *
+ * Adjust the timer by resetting the timecounter structure.
+ */
+static int cxgb4_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
+{
+	struct adapter *adapter =
+		(struct adapter *)container_of(ptp, struct adapter,
+					       ptp_clock_info);
+	struct fw_ptp_cmd c;
+	s64 sign = 1;
+	int err;
+
+	if (delta < 0)
+		sign = -1;
+
+	if (delta * sign > PTP_CLOCK_MAX_ADJTIME) {
+		memset(&c, 0, sizeof(c));
+		c.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PTP_CMD) |
+					     FW_CMD_REQUEST_F |
+					     FW_CMD_WRITE_F |
+					     FW_PTP_CMD_PORTID_V(0));
+		c.retval_len16 = cpu_to_be32(FW_CMD_LEN16_V(sizeof(c) / 16));
+		c.u.ts.sc = FW_PTP_SC_ADJ_TIME;
+		c.u.ts.sign = (delta < 0) ? 1 : 0;
+		if (delta < 0)
+			delta = -delta;
+		c.u.ts.tm = cpu_to_be64(delta);
+
+		err = t4_wr_mbox(adapter, adapter->mbox, &c, sizeof(c), NULL);
+		if (err < 0)
+			dev_err(adapter->pdev_dev,
+				"PTP: %s error %d\n", __func__, -err);
+	} else {
+		err = cxgb4_ptp_fineadjtime(adapter, delta);
+	}
+
+	return err;
+}
+
+/**
+ * cxgb4_ptp_gettime - Reads the current time from the hardware clock
+ * @ptp: ptp clock structure
+ * @ts: timespec structure to hold the current time value
+ *
+ * Read the timecounter and return the correct value in ns after converting
+ * it into a struct timespec.
+ */
+static int cxgb4_ptp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
+{
+	struct adapter *adapter = (struct adapter *)container_of(ptp,
+				   struct adapter, ptp_clock_info);
+	struct fw_ptp_cmd c;
+	u64 ns;
+	int err;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PTP_CMD) |
+				     FW_CMD_REQUEST_F |
+				     FW_CMD_READ_F |
+				     FW_PTP_CMD_PORTID_V(0));
+	c.retval_len16 = cpu_to_be32(FW_CMD_LEN16_V(sizeof(c) / 16));
+	c.u.ts.sc = FW_PTP_SC_GET_TIME;
+
+	err = t4_wr_mbox(adapter, adapter->mbox, &c, sizeof(c), &c);
+	if (err < 0) {
+		dev_err(adapter->pdev_dev,
+			"PTP: %s error %d\n", __func__, -err);
+		return err;
+	}
+
+	/* convert to timespec*/
+	ns = be64_to_cpu(c.u.ts.tm);
+	*ts = ns_to_timespec64(ns);
+
+	return err;
+}
+
+/**
+ *  cxgb4_ptp_settime - Set the current time on the hardware clock
+ *  @ptp: ptp clock structure
+ *  @ts: timespec containing the new time for the cycle counter
+ *
+ *  Reset value to new base value instead of the kernel
+ *  wall timer value.
+ */
+static int cxgb4_ptp_settime(struct ptp_clock_info *ptp,
+			     const struct timespec64 *ts)
+{
+	struct adapter *adapter = (struct adapter *)container_of(ptp,
+				   struct adapter, ptp_clock_info);
+	struct fw_ptp_cmd c;
+	u64 ns;
+	int err;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_portid = cpu_to_be32(FW_CMD_OP_V(FW_PTP_CMD) |
+				     FW_CMD_REQUEST_F |
+				     FW_CMD_WRITE_F |
+				     FW_PTP_CMD_PORTID_V(0));
+	c.retval_len16 = cpu_to_be32(FW_CMD_LEN16_V(sizeof(c) / 16));
+	c.u.ts.sc = FW_PTP_SC_SET_TIME;
+
+	ns = timespec64_to_ns(ts);
+	c.u.ts.tm = cpu_to_be64(ns);
+
+	err =  t4_wr_mbox(adapter, adapter->mbox, &c, sizeof(c), NULL);
+	if (err < 0)
+		dev_err(adapter->pdev_dev,
+			"PTP: %s error %d\n", __func__, -err);
+
+	return err;
+}
+
+/**
+ * cxgb4_ptp_enable - enable or disable an ancillary feature
+ * @ptp: ptp clock structure
+ * @request: Desired resource to enable or disable
+ * @on: Caller passes one to enable or zero to disable
+ *
+ * Enable (or disable) ancillary features of the PHC subsystem.
+ * Currently, no ancillary features are supported.
+ */
+static int cxgb4_ptp_enable(struct ptp_clock_info __always_unused *ptp,
+			    struct ptp_clock_request __always_unused *request,
+			    int __always_unused on)
+{
+	return -ENOTSUPP;
+}
+
+static const struct ptp_clock_info cxgb4_ptp_clock_info = {
+	.owner          = THIS_MODULE,
+	.name           = "cxgb4_clock",
+	.max_adj        = MAX_PTP_FREQ_ADJ,
+	.n_alarm        = 0,
+	.n_ext_ts       = 0,
+	.n_per_out      = 0,
+	.pps            = 0,
+	.adjfreq        = cxgb4_ptp_adjfreq,
+	.adjtime        = cxgb4_ptp_adjtime,
+	.gettime64      = cxgb4_ptp_gettime,
+	.settime64      = cxgb4_ptp_settime,
+	.enable         = cxgb4_ptp_enable,
+};
+
+/**
+ * cxgb4_ptp_init - initialize PTP for devices which support it
+ * @adapter: board private structure
+ *
+ * This function performs the required steps for enabling PTP support.
+ */
+void cxgb4_ptp_init(struct adapter *adapter)
+{
+	struct timespec64 now;
+	 /* no need to create a clock device if we already have one */
+	if (!IS_ERR_OR_NULL(adapter->ptp_clock))
+		return;
+
+	adapter->ptp_tx_skb = NULL;
+	adapter->ptp_clock_info = cxgb4_ptp_clock_info;
+	spin_lock_init(&adapter->ptp_lock);
+
+	adapter->ptp_clock = ptp_clock_register(&adapter->ptp_clock_info,
+						&adapter->pdev->dev);
+	if (!adapter->ptp_clock) {
+		dev_err(adapter->pdev_dev,
+			"PTP %s Clock registration has failed\n", __func__);
+		return;
+	}
+
+	now = ktime_to_timespec64(ktime_get_real());
+	cxgb4_init_ptp_timer(adapter);
+	if (cxgb4_ptp_settime(&adapter->ptp_clock_info, &now) < 0) {
+		ptp_clock_unregister(adapter->ptp_clock);
+		adapter->ptp_clock = NULL;
+	}
+}
+
+/**
+ * cxgb4_ptp_remove - disable PTP device and stop the overflow check
+ * @adapter: board private structure
+ *
+ * Stop the PTP support.
+ */
+void cxgb4_ptp_stop(struct adapter *adapter)
+{
+	if (adapter->ptp_tx_skb) {
+		dev_kfree_skb_any(adapter->ptp_tx_skb);
+		adapter->ptp_tx_skb = NULL;
+	}
+
+	if (adapter->ptp_clock) {
+		ptp_clock_unregister(adapter->ptp_clock);
+		adapter->ptp_clock = NULL;
+	}
+}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.h
new file mode 100644
index 0000000..cccfae8
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ptp.h
@@ -0,0 +1,74 @@
+/*
+ * This file is part of the Chelsio T4 Ethernet driver for Linux.
+ *
+ * Copyright (c) 2003-2017 Chelsio Communications, Inc. All rights reserved.
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
+#ifndef __CXGB4_PTP_H__
+#define __CXGB4_PTP_H__
+
+/* Maximum parts-per-billion adjustment that is acceptable */
+#define MAX_PTP_FREQ_ADJ		1000000
+#define PTP_CLOCK_MAX_ADJTIME		10000000 /* 10 ms */
+
+#define PTP_MIN_LENGTH			63
+#define PTP_IN_TRANSMIT_PACKET_MAXNUM	240
+#define PTP_EVENT_PORT			319
+
+enum ptp_rx_filter_mode {
+	PTP_TS_NONE = 0,
+	PTP_TS_L2,
+	PTP_TS_L4,
+	PTP_TS_L2_L4
+};
+
+struct port_info;
+
+static inline bool cxgb4_xmit_with_hwtstamp(struct sk_buff *skb)
+{
+	return skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP;
+}
+
+static inline void cxgb4_xmit_hwtstamp_pending(struct sk_buff *skb)
+{
+	skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+}
+
+void cxgb4_ptp_init(struct adapter *adap);
+void cxgb4_ptp_stop(struct adapter *adap);
+bool cxgb4_ptp_is_ptp_tx(struct sk_buff *skb);
+bool cxgb4_ptp_is_ptp_rx(struct sk_buff *skb);
+int cxgb4_ptprx_timestamping(struct port_info *pi, u8 port, u16 mode);
+int cxgb4_ptp_redirect_rx_packet(struct adapter *adap, struct port_info *pi);
+int cxgb4_ptp_txtype(struct adapter *adap, u8 port_id);
+void cxgb4_ptp_read_hwstamp(struct adapter *adap, struct port_info *pi);
+bool is_ptp_enabled(struct sk_buff *skb, struct net_device *dev);
+#endif /* __CXGB4_PTP_H__ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index f05f0d4..3f1d187 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -52,6 +52,7 @@
 #include "t4_values.h"
 #include "t4_msg.h"
 #include "t4fw_api.h"
+#include "cxgb4_ptp.h"
 
 /*
  * Rx buffer size.  We use largish buffers if possible but settle for single
@@ -1162,7 +1163,7 @@ static inline void txq_advance(struct sge_txq *q, unsigned int n)
  */
 netdev_tx_t t4_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	u32 wr_mid, ctrl0;
+	u32 wr_mid, ctrl0, op;
 	u64 cntrl, *end;
 	int qidx, credits;
 	unsigned int flits, ndesc;
@@ -1175,6 +1176,7 @@ netdev_tx_t t4_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	dma_addr_t addr[MAX_SKB_FRAGS + 1];
 	bool immediate = false;
 	int len, max_pkt_len;
+	bool ptp_enabled = is_ptp_enabled(skb, dev);
 #ifdef CONFIG_CHELSIO_T4_FCOE
 	int err;
 #endif /* CONFIG_CHELSIO_T4_FCOE */
@@ -1198,7 +1200,20 @@ netdev_tx_t t4_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	pi = netdev_priv(dev);
 	adap = pi->adapter;
 	qidx = skb_get_queue_mapping(skb);
-	q = &adap->sge.ethtxq[qidx + pi->first_qset];
+	if (ptp_enabled) {
+		spin_lock(&adap->ptp_lock);
+		if (!(adap->ptp_tx_skb)) {
+			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+			adap->ptp_tx_skb = skb_get(skb);
+		} else {
+			spin_unlock(&adap->ptp_lock);
+			goto out_free;
+		}
+		q = &adap->sge.ptptxq;
+	} else {
+		q = &adap->sge.ethtxq[qidx + pi->first_qset];
+	}
+	skb_tx_timestamp(skb);
 
 	reclaim_completed_tx(adap, &q->q, true);
 	cntrl = TXPKT_L4CSUM_DIS_F | TXPKT_IPCSUM_DIS_F;
@@ -1227,6 +1242,8 @@ netdev_tx_t t4_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!immediate &&
 	    unlikely(map_skb(adap->pdev_dev, skb, addr) < 0)) {
 		q->mapping_err++;
+		if (ptp_enabled)
+			spin_unlock(&adap->ptp_lock);
 		goto out_free;
 	}
 
@@ -1279,7 +1296,11 @@ netdev_tx_t t4_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		q->tx_cso += ssi->gso_segs;
 	} else {
 		len += sizeof(*cpl);
-		wr->op_immdlen = htonl(FW_WR_OP_V(FW_ETH_TX_PKT_WR) |
+		if (ptp_enabled)
+			op = FW_PTP_TX_PKT_WR;
+		else
+			op = FW_ETH_TX_PKT_WR;
+		wr->op_immdlen = htonl(FW_WR_OP_V(op) |
 				       FW_WR_IMMDLEN_V(len));
 		cpl = (void *)(wr + 1);
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
@@ -1301,6 +1322,8 @@ netdev_tx_t t4_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	ctrl0 = TXPKT_OPCODE_V(CPL_TX_PKT_XT) | TXPKT_INTF_V(pi->tx_chan) |
 		TXPKT_PF_V(adap->pf);
+	if (ptp_enabled)
+		ctrl0 |= TXPKT_TSTAMP_F;
 #ifdef CONFIG_CHELSIO_T4_DCB
 	if (is_t4(adap->params.chip))
 		ctrl0 |= TXPKT_OVLAN_IDX_V(q->dcb_prio);
@@ -1332,6 +1355,8 @@ netdev_tx_t t4_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 	txq_advance(&q->q, ndesc);
 
 	ring_tx_db(adap, &q->q, ndesc);
+	if (ptp_enabled)
+		spin_unlock(&adap->ptp_lock);
 	return NETDEV_TX_OK;
 }
 
@@ -2023,6 +2048,92 @@ static void do_gro(struct sge_eth_rxq *rxq, const struct pkt_gl *gl,
 	rxq->stats.rx_cso++;
 }
 
+enum {
+	RX_NON_PTP_PKT = 0,
+	RX_PTP_PKT_SUC = 1,
+	RX_PTP_PKT_ERR = 2
+};
+
+/**
+ *     t4_systim_to_hwstamp - read hardware time stamp
+ *     @adap: the adapter
+ *     @skb: the packet
+ *
+ *     Read Time Stamp from MPS packet and insert in skb which
+ *     is forwarded to PTP application
+ */
+static noinline int t4_systim_to_hwstamp(struct adapter *adapter,
+					 struct sk_buff *skb)
+{
+	struct skb_shared_hwtstamps *hwtstamps;
+	struct cpl_rx_mps_pkt *cpl = NULL;
+	unsigned char *data;
+	int offset;
+
+	cpl = (struct cpl_rx_mps_pkt *)skb->data;
+	if (!(CPL_RX_MPS_PKT_TYPE_G(ntohl(cpl->op_to_r1_hi)) &
+	     X_CPL_RX_MPS_PKT_TYPE_PTP))
+		return RX_PTP_PKT_ERR;
+
+	data = skb->data + sizeof(*cpl);
+	skb_pull(skb, 2 * sizeof(u64) + sizeof(struct cpl_rx_mps_pkt));
+	offset = ETH_HLEN + IPV4_HLEN(skb->data) + UDP_HLEN;
+	if (skb->len < offset + OFF_PTP_SEQUENCE_ID + sizeof(short))
+		return RX_PTP_PKT_ERR;
+
+	hwtstamps = skb_hwtstamps(skb);
+	memset(hwtstamps, 0, sizeof(*hwtstamps));
+	hwtstamps->hwtstamp = ns_to_ktime(be64_to_cpu(*((u64 *)data)));
+
+	return RX_PTP_PKT_SUC;
+}
+
+/**
+ *     t4_rx_hststamp - Recv PTP Event Message
+ *     @adap: the adapter
+ *     @rsp: the response queue descriptor holding the RX_PKT message
+ *     @skb: the packet
+ *
+ *     PTP enabled and MPS packet, read HW timestamp
+ */
+static int t4_rx_hststamp(struct adapter *adapter, const __be64 *rsp,
+			  struct sge_eth_rxq *rxq, struct sk_buff *skb)
+{
+	int ret;
+
+	if (unlikely((*(u8 *)rsp == CPL_RX_MPS_PKT) &&
+		     !is_t4(adapter->params.chip))) {
+		ret = t4_systim_to_hwstamp(adapter, skb);
+		if (ret == RX_PTP_PKT_ERR) {
+			kfree_skb(skb);
+			rxq->stats.rx_drops++;
+		}
+		return ret;
+	}
+	return RX_NON_PTP_PKT;
+}
+
+/**
+ *      t4_tx_hststamp - Loopback PTP Transmit Event Message
+ *      @adap: the adapter
+ *      @skb: the packet
+ *      @dev: the ingress net device
+ *
+ *      Read hardware timestamp for the loopback PTP Tx event message
+ */
+static int t4_tx_hststamp(struct adapter *adapter, struct sk_buff *skb,
+			  struct net_device *dev)
+{
+	struct port_info *pi = netdev_priv(dev);
+
+	if (!is_t4(adapter->params.chip) && adapter->ptp_tx_skb) {
+		cxgb4_ptp_read_hwstamp(adapter, pi);
+		kfree_skb(skb);
+		return 0;
+	}
+	return 1;
+}
+
 /**
  *	t4_ethrx_handler - process an ingress ethernet packet
  *	@q: the response queue that received the packet
@@ -2038,11 +2149,13 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 	struct sk_buff *skb;
 	const struct cpl_rx_pkt *pkt;
 	struct sge_eth_rxq *rxq = container_of(q, struct sge_eth_rxq, rspq);
+	struct adapter *adapter = q->adap;
 	struct sge *s = &q->adap->sge;
 	int cpl_trace_pkt = is_t4(q->adap->params.chip) ?
 			    CPL_TRACE_PKT : CPL_TRACE_PKT_T5;
 	u16 err_vec;
 	struct port_info *pi;
+	int ret = 0;
 
 	if (unlikely(*(u8 *)rsp == cpl_trace_pkt))
 		return handle_trace_pkt(q->adap, si);
@@ -2068,8 +2181,25 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 		rxq->stats.rx_drops++;
 		return 0;
 	}
+	pi = netdev_priv(q->netdev);
+
+	/* Handle PTP Event Rx packet */
+	if (unlikely(pi->ptp_enable)) {
+		ret = t4_rx_hststamp(adapter, rsp, rxq, skb);
+		if (ret == RX_PTP_PKT_ERR)
+			return 0;
+	}
+	if (likely(!ret))
+		__skb_pull(skb, s->pktshift); /* remove ethernet header pad */
+
+	/* Handle the PTP Event Tx Loopback packet */
+	if (unlikely(pi->ptp_enable && !ret &&
+		     (pkt->l2info & htonl(RXF_UDP_F)) &&
+		     cxgb4_ptp_is_ptp_rx(skb))) {
+		if (!t4_tx_hststamp(adapter, skb, q->netdev))
+			return 0;
+	}
 
-	__skb_pull(skb, s->pktshift);      /* remove ethernet header padding */
 	skb->protocol = eth_type_trans(skb, q->netdev);
 	skb_record_rx_queue(skb, q->idx);
 	if (skb->dev->features & NETIF_F_RXHASH)
@@ -2078,7 +2208,6 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 
 	rxq->stats.pkts++;
 
-	pi = netdev_priv(skb->dev);
 	if (pi->rxtstamp)
 		cxgb4_sgetim_to_hwtstamp(q->adap, skb_hwtstamps(skb),
 					 si->sgetstamp);
@@ -2502,6 +2631,20 @@ static void sge_tx_timer_cb(unsigned long data)
 			tasklet_schedule(&txq->qresume_tsk);
 		}
 
+	if (!is_t4(adap->params.chip)) {
+		struct sge_eth_txq *q = &s->ptptxq;
+		int avail;
+
+		spin_lock(&adap->ptp_lock);
+		avail = reclaimable(&q->q);
+
+		if (avail) {
+			free_tx_desc(adap, &q->q, avail, false);
+			q->q.in_use -= avail;
+		}
+		spin_unlock(&adap->ptp_lock);
+	}
+
 	budget = MAX_TIMER_TX_RECLAIM;
 	i = s->ethtxq_rover;
 	do {
@@ -3068,6 +3211,19 @@ void t4_free_sge_resources(struct adapter *adap)
 	if (adap->sge.intrq.desc)
 		free_rspq_fl(adap, &adap->sge.intrq, NULL);
 
+	if (!is_t4(adap->params.chip)) {
+		etq = &adap->sge.ptptxq;
+		if (etq->q.desc) {
+			t4_eth_eq_free(adap, adap->mbox, adap->pf, 0,
+				       etq->q.cntxt_id);
+			spin_lock_bh(&adap->ptp_lock);
+			free_tx_desc(adap, &etq->q, etq->q.in_use, true);
+			spin_unlock_bh(&adap->ptp_lock);
+			kfree(etq->q.sdesc);
+			free_txq(adap, &etq->q);
+		}
+	}
+
 	/* clear the reverse egress queue map */
 	memset(adap->sge.egr_map, 0,
 	       adap->sge.egr_sz * sizeof(*adap->sge.egr_map));
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index 8098c93..b0ff78d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -92,6 +92,7 @@ enum {
 	CPL_RDMA_TERMINATE    = 0xA2,
 	CPL_RDMA_WRITE        = 0xA4,
 	CPL_SGE_EGR_UPDATE    = 0xA5,
+	CPL_RX_MPS_PKT        = 0xAF,
 
 	CPL_TRACE_PKT         = 0xB0,
 	CPL_ISCSI_DATA	      = 0xB2,
@@ -807,6 +808,10 @@ struct cpl_tx_pkt {
 #define TXPKT_INS_OVLAN_V(x) ((x) << TXPKT_INS_OVLAN_S)
 #define TXPKT_INS_OVLAN_F    TXPKT_INS_OVLAN_V(1U)
 
+#define TXPKT_TSTAMP_S    23
+#define TXPKT_TSTAMP_V(x) ((x) << TXPKT_TSTAMP_S)
+#define TXPKT_TSTAMP_F    TXPKT_TSTAMP_V(1ULL)
+
 #define TXPKT_OPCODE_S    24
 #define TXPKT_OPCODE_V(x) ((x) << TXPKT_OPCODE_S)
 
@@ -1875,4 +1880,27 @@ struct cpl_rx_phys_dsgl {
 	(((x) >> CPL_RX_PHYS_DSGL_NOOFSGENTR_S) & \
 	 CPL_RX_PHYS_DSGL_NOOFSGENTR_M)
 
+struct cpl_rx_mps_pkt {
+	__be32 op_to_r1_hi;
+	__be32 r1_lo_length;
+};
+
+#define CPL_RX_MPS_PKT_OP_S     24
+#define CPL_RX_MPS_PKT_OP_M     0xff
+#define CPL_RX_MPS_PKT_OP_V(x)  ((x) << CPL_RX_MPS_PKT_OP_S)
+#define CPL_RX_MPS_PKT_OP_G(x)  \
+	(((x) >> CPL_RX_MPS_PKT_OP_S) & CPL_RX_MPS_PKT_OP_M)
+
+#define CPL_RX_MPS_PKT_TYPE_S           20
+#define CPL_RX_MPS_PKT_TYPE_M           0xf
+#define CPL_RX_MPS_PKT_TYPE_V(x)        ((x) << CPL_RX_MPS_PKT_TYPE_S)
+#define CPL_RX_MPS_PKT_TYPE_G(x)        \
+	(((x) >> CPL_RX_MPS_PKT_TYPE_S) & CPL_RX_MPS_PKT_TYPE_M)
+
+enum {
+	X_CPL_RX_MPS_PKT_TYPE_PAUSE = 1 << 0,
+	X_CPL_RX_MPS_PKT_TYPE_PPP   = 1 << 1,
+	X_CPL_RX_MPS_PKT_TYPE_QFC   = 1 << 2,
+	X_CPL_RX_MPS_PKT_TYPE_PTP   = 1 << 3
+};
 #endif  /* __T4_MSG_H */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 3884336..dac9083 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1799,6 +1799,8 @@
 #define MPS_PORT_STAT_RX_PORT_LESS_64B_H 0x614
 #define MAC_PORT_MAGIC_MACID_LO 0x824
 #define MAC_PORT_MAGIC_MACID_HI 0x828
+#define MAC_PORT_TX_TS_VAL_LO   0x928
+#define MAC_PORT_TX_TS_VAL_HI   0x92c
 
 #define MAC_PORT_EPIO_DATA0_A 0x8c0
 #define MAC_PORT_EPIO_DATA1_A 0x8c4
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index f2ffc1f..0ebed64 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -103,6 +103,7 @@ enum fw_wr_opcodes {
 	FW_RI_FR_NSMR_TPTE_WR	       = 0x20,
 	FW_RI_INV_LSTAG_WR             = 0x1a,
 	FW_ISCSI_TX_DATA_WR	       = 0x45,
+	FW_PTP_TX_PKT_WR               = 0x46,
 	FW_CRYPTO_LOOKASIDE_WR         = 0X6d,
 	FW_LASTC2E_WR                  = 0x70
 };
@@ -685,6 +686,7 @@ enum fw_cmd_opcodes {
 	FW_SCHED_CMD                   = 0x24,
 	FW_DEVLOG_CMD                  = 0x25,
 	FW_CLIP_CMD                    = 0x28,
+	FW_PTP_CMD                     = 0x3e,
 	FW_LASTC2E_CMD                 = 0x40,
 	FW_ERROR_CMD                   = 0x80,
 	FW_DEBUG_CMD                   = 0x81,
@@ -2802,6 +2804,54 @@ struct fw_port_lb_stats_cmd {
 	} u;
 };
 
+enum fw_ptp_subop {
+	/* none */
+	FW_PTP_SC_INIT_TIMER            = 0x00,
+	FW_PTP_SC_TX_TYPE               = 0x01,
+	/* init */
+	FW_PTP_SC_RXTIME_STAMP          = 0x08,
+	FW_PTP_SC_RDRX_TYPE             = 0x09,
+	/* ts */
+	FW_PTP_SC_ADJ_FREQ              = 0x10,
+	FW_PTP_SC_ADJ_TIME              = 0x11,
+	FW_PTP_SC_ADJ_FTIME             = 0x12,
+	FW_PTP_SC_WALL_CLOCK            = 0x13,
+	FW_PTP_SC_GET_TIME              = 0x14,
+	FW_PTP_SC_SET_TIME              = 0x15,
+};
+
+struct fw_ptp_cmd {
+	__be32 op_to_portid;
+	__be32 retval_len16;
+	union fw_ptp {
+		struct fw_ptp_sc {
+			__u8   sc;
+			__u8   r3[7];
+		} scmd;
+		struct fw_ptp_init {
+			__u8   sc;
+			__u8   txchan;
+			__be16 absid;
+			__be16 mode;
+			__be16 r3;
+		} init;
+		struct fw_ptp_ts {
+			__u8   sc;
+			__u8   sign;
+			__be16 r3;
+			__be32 ppb;
+			__be64 tm;
+		} ts;
+	} u;
+	__be64 r3;
+};
+
+#define FW_PTP_CMD_PORTID_S             0
+#define FW_PTP_CMD_PORTID_M             0xf
+#define FW_PTP_CMD_PORTID_V(x)          ((x) << FW_PTP_CMD_PORTID_S)
+#define FW_PTP_CMD_PORTID_G(x)          \
+	(((x) >> FW_PTP_CMD_PORTID_S) & FW_PTP_CMD_PORTID_M)
+
 struct fw_rss_ind_tbl_cmd {
 	__be32 op_to_viid;
 	__be32 retval_len16;
-- 
1.8.3.1
