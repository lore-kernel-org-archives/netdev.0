From: Sudarsana Kalluru <Sudarsana.Kalluru@cavium.com>
Subject: [PATCH net-next 2/2] qede: Add driver support for PTP.
Date: Fri, 27 Jan 2017 07:30:20 -0800
Message-ID: <1485531020-8905-3-git-send-email-Sudarsana.Kalluru@cavium.com>
References: <1485531020-8905-1-git-send-email-Sudarsana.Kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>,
        "Sudarsana Reddy Kalluru" <sudarsana.kalluru@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0054.outbound.protection.outlook.com ([104.47.37.54]:14515
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932168AbdA0PbB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Jan 2017 10:31:01 -0500
In-Reply-To: <1485531020-8905-1-git-send-email-Sudarsana.Kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>

This patch adds the driver support for,
  - Registering the ptp clock functionality with the OS.
  - Timestamping the Rx/Tx PTP packets.
  - Ethtool callbacks related to PTP.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/Kconfig             |   1 +
 drivers/net/ethernet/qlogic/qede/Makefile       |   2 +-
 drivers/net/ethernet/qlogic/qede/qede.h         |   4 +
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c |  10 +
 drivers/net/ethernet/qlogic/qede/qede_fp.c      |   5 +
 drivers/net/ethernet/qlogic/qede/qede_main.c    |  39 ++
 drivers/net/ethernet/qlogic/qede/qede_ptp.c     | 536 ++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qede/qede_ptp.h     |  65 +++
 8 files changed, 661 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/qlogic/qede/qede_ptp.c
 create mode 100644 drivers/net/ethernet/qlogic/qede/qede_ptp.h

diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
index 3cfd105..aaa1e85 100644
--- a/drivers/net/ethernet/qlogic/Kconfig
+++ b/drivers/net/ethernet/qlogic/Kconfig
@@ -104,6 +104,7 @@ config QED_SRIOV
 config QEDE
 	tristate "QLogic QED 25/40/100Gb Ethernet NIC"
 	depends on QED
+	imply PTP_1588_CLOCK
 	---help---
 	  This enables the support for ...
 
diff --git a/drivers/net/ethernet/qlogic/qede/Makefile b/drivers/net/ethernet/qlogic/qede/Makefile
index 38fbee6..bc5f7c3 100644
--- a/drivers/net/ethernet/qlogic/qede/Makefile
+++ b/drivers/net/ethernet/qlogic/qede/Makefile
@@ -1,5 +1,5 @@
 obj-$(CONFIG_QEDE) := qede.o
 
-qede-y := qede_main.o qede_fp.o qede_filter.o qede_ethtool.o
+qede-y := qede_main.o qede_fp.o qede_filter.o qede_ethtool.o qede_ptp.o
 qede-$(CONFIG_DCB) += qede_dcbnl.o
 qede-$(CONFIG_QED_RDMA) += qede_roce.o
diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index b423406..f2aaef2 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -137,6 +137,8 @@ struct qede_rdma_dev {
 	struct workqueue_struct *roce_wq;
 };
 
+struct qede_ptp;
+
 struct qede_dev {
 	struct qed_dev			*cdev;
 	struct net_device		*ndev;
@@ -148,8 +150,10 @@ struct qede_dev {
 	u32 flags;
 #define QEDE_FLAG_IS_VF	BIT(0)
 #define IS_VF(edev)	(!!((edev)->flags & QEDE_FLAG_IS_VF))
+#define QEDE_TX_TIMESTAMPING_EN		BIT(1)
 
 	const struct qed_eth_ops	*ops;
+	struct qede_ptp			*ptp;
 
 	struct qed_dev_eth_info dev_info;
 #define QEDE_MAX_RSS_CNT(edev)	((edev)->dev_info.num_queues)
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index baf2642..c02754d 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -39,6 +39,7 @@
 #include <linux/capability.h>
 #include <linux/vmalloc.h>
 #include "qede.h"
+#include "qede_ptp.h"
 
 #define QEDE_RQSTAT_OFFSET(stat_name) \
 	 (offsetof(struct qede_rx_queue, stat_name))
@@ -940,6 +941,14 @@ static int qede_set_channels(struct net_device *dev,
 	return 0;
 }
 
+static int qede_get_ts_info(struct net_device *dev,
+			    struct ethtool_ts_info *info)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+
+	return qede_ptp_get_ts_info(edev, info);
+}
+
 static int qede_set_phys_id(struct net_device *dev,
 			    enum ethtool_phys_id_state state)
 {
@@ -1586,6 +1595,7 @@ static int qede_get_tunable(struct net_device *dev,
 	.get_rxfh_key_size = qede_get_rxfh_key_size,
 	.get_rxfh = qede_get_rxfh,
 	.set_rxfh = qede_set_rxfh,
+	.get_ts_info = qede_get_ts_info,
 	.get_channels = qede_get_channels,
 	.set_channels = qede_set_channels,
 	.self_test = qede_self_test,
diff --git a/drivers/net/ethernet/qlogic/qede/qede_fp.c b/drivers/net/ethernet/qlogic/qede/qede_fp.c
index 1a6ca48..8b3a88a 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_fp.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_fp.c
@@ -39,6 +39,7 @@
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
 #include <net/ip6_checksum.h>
+#include "qede_ptp.h"
 
 #include <linux/qed/qed_if.h>
 #include "qede.h"
@@ -1273,6 +1274,7 @@ static int qede_rx_process_cqe(struct qede_dev *edev,
 	qede_get_rxhash(skb, fp_cqe->bitfields, fp_cqe->rss_hash);
 	qede_set_skb_csum(skb, csum_flag);
 	skb_record_rx_queue(skb, rxq->rxq_id);
+	qede_ptp_record_rx_ts(edev, cqe, skb);
 
 	/* SKB is prepared - pass it to stack */
 	qede_skb_receive(edev, fp, rxq, skb, le16_to_cpu(fp_cqe->vlan_tag));
@@ -1447,6 +1449,9 @@ netdev_tx_t qede_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	first_bd->data.bd_flags.bitfields =
 		1 << ETH_TX_1ST_BD_FLAGS_START_BD_SHIFT;
 
+	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP))
+		qede_ptp_tx_ts(edev, skb);
+
 	/* Map skb linear data for DMA and set in the first BD */
 	mapping = dma_map_single(txq->dev, skb->data,
 				 skb_headlen(skb), DMA_TO_DEVICE);
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 40a76a1..d163e72 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -62,6 +62,7 @@
 #include <linux/vmalloc.h>
 #include <linux/qed/qede_roce.h>
 #include "qede.h"
+#include "qede_ptp.h"
 
 static char version[] =
 	"QLogic FastLinQ 4xxxx Ethernet Driver qede " DRV_MODULE_VERSION "\n";
@@ -484,6 +485,25 @@ static int qede_set_vf_trust(struct net_device *dev, int vfidx, bool setting)
 }
 #endif
 
+static int qede_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+
+	if (!netif_running(dev))
+		return -EAGAIN;
+
+	switch (cmd) {
+	case SIOCSHWTSTAMP:
+		return qede_ptp_hw_ts(edev, ifr);
+	default:
+		DP_VERBOSE(edev, QED_MSG_DEBUG,
+			   "default IOCTL cmd 0x%x\n", cmd);
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
 static const struct net_device_ops qede_netdev_ops = {
 	.ndo_open = qede_open,
 	.ndo_stop = qede_close,
@@ -492,6 +512,7 @@ static int qede_set_vf_trust(struct net_device *dev, int vfidx, bool setting)
 	.ndo_set_mac_address = qede_set_mac_addr,
 	.ndo_validate_addr = eth_validate_addr,
 	.ndo_change_mtu = qede_change_mtu,
+	.ndo_do_ioctl = qede_ioctl,
 #ifdef CONFIG_QED_SRIOV
 	.ndo_set_vf_mac = qede_set_vf_mac,
 	.ndo_set_vf_vlan = qede_set_vf_vlan,
@@ -841,6 +862,15 @@ static int __qede_probe(struct pci_dev *pdev, u32 dp_module, u8 dp_level,
 
 	edev->ops->common->set_id(cdev, edev->ndev->name, DRV_MODULE_VERSION);
 
+	/* PTP not supported on VFs */
+	if (!is_vf) {
+		rc = qede_ptp_register_phc(edev);
+		if (rc) {
+			DP_NOTICE(edev, "Cannot register PHC\n");
+			goto err5;
+		}
+	}
+
 	edev->ops->register_ops(cdev, &qede_ll_ops, edev);
 
 #ifdef CONFIG_DCB
@@ -856,6 +886,8 @@ static int __qede_probe(struct pci_dev *pdev, u32 dp_module, u8 dp_level,
 
 	return 0;
 
+err5:
+	unregister_netdev(edev->ndev);
 err4:
 	qede_roce_dev_remove(edev);
 err3:
@@ -907,6 +939,8 @@ static void __qede_remove(struct pci_dev *pdev, enum qede_remove_mode mode)
 
 	unregister_netdev(ndev);
 
+	qede_ptp_remove(edev);
+
 	qede_roce_dev_remove(edev);
 
 	edev->ops->common->set_power_state(cdev, PCI_D0);
@@ -1660,6 +1694,7 @@ static int qede_start_queues(struct qede_dev *edev, bool clear_stats)
 	if (!vport_update_params)
 		return -ENOMEM;
 
+	start.handle_ptp_pkts = !!(edev->ptp);
 	start.gro_enable = !edev->gro_disable;
 	start.mtu = edev->ndev->mtu;
 	start.vport_id = 0;
@@ -1781,6 +1816,8 @@ static void qede_unload(struct qede_dev *edev, enum qede_unload_mode mode,
 	qede_roce_dev_event_close(edev);
 	edev->state = QEDE_STATE_CLOSED;
 
+	qede_ptp_stop(edev);
+
 	/* Close OS Tx */
 	netif_tx_disable(edev->ndev);
 	netif_carrier_off(edev->ndev);
@@ -1882,6 +1919,8 @@ static int qede_load(struct qede_dev *edev, enum qede_load_mode mode,
 	qede_roce_dev_event_open(edev);
 	qede_link_update(edev, &link_output);
 
+	qede_ptp_start(edev, (mode == QEDE_LOAD_NORMAL));
+
 	edev->state = QEDE_STATE_OPEN;
 
 	DP_INFO(edev, "Ending successfully qede load\n");
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ptp.c b/drivers/net/ethernet/qlogic/qede/qede_ptp.c
new file mode 100644
index 0000000..8ab7781
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qede/qede_ptp.c
@@ -0,0 +1,536 @@
+/* QLogic qede NIC Driver
+ * Copyright (c) 2015-2017  QLogic Corporation
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
+ *        disclaimer in the documentation and /or other materials
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
+#include "qede_ptp.h"
+
+struct qede_ptp {
+	const struct qed_eth_ptp_ops	*ops;
+	struct ptp_clock_info		clock_info;
+	struct cyclecounter		cc;
+	struct timecounter		tc;
+	struct ptp_clock		*clock;
+	struct work_struct		work;
+	struct qede_dev			*edev;
+	struct sk_buff			*tx_skb;
+
+	/* ptp spinlock is used for protecting the cycle/time counter fields
+	 * and, also for serializing the qed PTP API invocations.
+	 */
+	spinlock_t			lock;
+	bool				hw_ts_ioctl_called;
+	u16				tx_type;
+	u16				rx_filter;
+};
+
+/**
+ * qede_ptp_adjfreq
+ * @ptp: the ptp clock structure
+ * @ppb: parts per billion adjustment from base
+ *
+ * Adjust the frequency of the ptp cycle counter by the
+ * indicated ppb from the base frequency.
+ */
+static int qede_ptp_adjfreq(struct ptp_clock_info *info, s32 ppb)
+{
+	struct qede_ptp *ptp = container_of(info, struct qede_ptp, clock_info);
+	struct qede_dev *edev = ptp->edev;
+	int rc;
+
+	__qede_lock(edev);
+	if (edev->state == QEDE_STATE_OPEN) {
+		spin_lock_bh(&ptp->lock);
+		rc = ptp->ops->adjfreq(edev->cdev, ppb);
+		spin_unlock_bh(&ptp->lock);
+	} else {
+		DP_ERR(edev, "PTP adjfreq called while interface is down\n");
+		return -EFAULT;
+	}
+	__qede_unlock(edev);
+
+	return rc;
+}
+
+static int qede_ptp_adjtime(struct ptp_clock_info *info, s64 delta)
+{
+	struct qede_dev *edev;
+	struct qede_ptp *ptp;
+
+	ptp = container_of(info, struct qede_ptp, clock_info);
+	edev = ptp->edev;
+
+	DP_VERBOSE(edev, QED_MSG_DEBUG, "PTP adjtime called, delta = %llx\n",
+		   delta);
+
+	spin_lock_bh(&ptp->lock);
+	timecounter_adjtime(&ptp->tc, delta);
+	spin_unlock_bh(&ptp->lock);
+
+	return 0;
+}
+
+static int qede_ptp_gettime(struct ptp_clock_info *info, struct timespec64 *ts)
+{
+	struct qede_dev *edev;
+	struct qede_ptp *ptp;
+	u64 ns;
+
+	ptp = container_of(info, struct qede_ptp, clock_info);
+	edev = ptp->edev;
+
+	spin_lock_bh(&ptp->lock);
+	ns = timecounter_read(&ptp->tc);
+	spin_unlock_bh(&ptp->lock);
+
+	DP_VERBOSE(edev, QED_MSG_DEBUG, "PTP gettime called, ns = %llu\n", ns);
+
+	*ts = ns_to_timespec64(ns);
+
+	return 0;
+}
+
+static int qede_ptp_settime(struct ptp_clock_info *info,
+			    const struct timespec64 *ts)
+{
+	struct qede_dev *edev;
+	struct qede_ptp *ptp;
+	u64 ns;
+
+	ptp = container_of(info, struct qede_ptp, clock_info);
+	edev = ptp->edev;
+
+	ns = timespec64_to_ns(ts);
+
+	DP_VERBOSE(edev, QED_MSG_DEBUG, "PTP settime called, ns = %llu\n", ns);
+
+	/* Re-init the timecounter */
+	spin_lock_bh(&ptp->lock);
+	timecounter_init(&ptp->tc, &ptp->cc, ns);
+	spin_unlock_bh(&ptp->lock);
+
+	return 0;
+}
+
+/* Enable (or disable) ancillary features of the phc subsystem */
+static int qede_ptp_ancillary_feature_enable(struct ptp_clock_info *info,
+					     struct ptp_clock_request *rq,
+					     int on)
+{
+	struct qede_dev *edev;
+	struct qede_ptp *ptp;
+
+	ptp = container_of(info, struct qede_ptp, clock_info);
+	edev = ptp->edev;
+
+	DP_ERR(edev, "PHC ancillary features are not supported\n");
+
+	return -ENOTSUPP;
+}
+
+static void qede_ptp_task(struct work_struct *work)
+{
+	struct skb_shared_hwtstamps shhwtstamps;
+	struct qede_dev *edev;
+	struct qede_ptp *ptp;
+	u64 timestamp, ns;
+	int rc;
+
+	ptp = container_of(work, struct qede_ptp, work);
+	edev = ptp->edev;
+
+	/* Read Tx timestamp registers */
+	spin_lock_bh(&ptp->lock);
+	rc = ptp->ops->read_tx_ts(edev->cdev, &timestamp);
+	spin_unlock_bh(&ptp->lock);
+	if (rc) {
+		/* Reschedule to keep checking for a valid timestamp value */
+		schedule_work(&ptp->work);
+		return;
+	}
+
+	ns = timecounter_cyc2time(&ptp->tc, timestamp);
+	memset(&shhwtstamps, 0, sizeof(shhwtstamps));
+	shhwtstamps.hwtstamp = ns_to_ktime(ns);
+	skb_tstamp_tx(ptp->tx_skb, &shhwtstamps);
+	dev_kfree_skb_any(ptp->tx_skb);
+	ptp->tx_skb = NULL;
+
+	DP_VERBOSE(edev, QED_MSG_DEBUG,
+		   "Tx timestamp, timestamp cycles = %llu, ns = %llu\n",
+		   timestamp, ns);
+}
+
+/* Read the PHC. This API is invoked with ptp_lock held. */
+static u64 qede_ptp_read_cc(const struct cyclecounter *cc)
+{
+	struct qede_dev *edev;
+	struct qede_ptp *ptp;
+	u64 phc_cycles;
+	int rc;
+
+	ptp = container_of(cc, struct qede_ptp, cc);
+	edev = ptp->edev;
+	rc = ptp->ops->read_cc(edev->cdev, &phc_cycles);
+	if (rc)
+		WARN_ONCE(1, "PHC read err %d\n", rc);
+
+	DP_VERBOSE(edev, QED_MSG_DEBUG, "PHC read cycles = %llu\n", phc_cycles);
+
+	return phc_cycles;
+}
+
+static void qede_ptp_init_cc(struct qede_dev *edev)
+{
+	struct qede_ptp *ptp;
+
+	ptp = edev->ptp;
+	if (!ptp)
+		return;
+
+	memset(&ptp->cc, 0, sizeof(ptp->cc));
+	ptp->cc.read = qede_ptp_read_cc;
+	ptp->cc.mask = CYCLECOUNTER_MASK(64);
+	ptp->cc.shift = 0;
+	ptp->cc.mult = 1;
+}
+
+static int qede_ptp_cfg_filters(struct qede_dev *edev)
+{
+	struct qede_ptp *ptp = edev->ptp;
+
+	if (!ptp)
+		return -EIO;
+
+	if (!ptp->hw_ts_ioctl_called) {
+		DP_INFO(edev, "TS IOCTL not called\n");
+		return 0;
+	}
+
+	switch (ptp->tx_type) {
+	case HWTSTAMP_TX_ON:
+		edev->flags |= QEDE_TX_TIMESTAMPING_EN;
+		ptp->ops->hwtstamp_tx_on(edev->cdev);
+		break;
+
+	case HWTSTAMP_TX_ONESTEP_SYNC:
+		DP_ERR(edev, "One-step timestamping is not supported\n");
+		return -ERANGE;
+	}
+
+	spin_lock_bh(&ptp->lock);
+	switch (ptp->rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		break;
+	case HWTSTAMP_FILTER_ALL:
+	case HWTSTAMP_FILTER_SOME:
+		ptp->rx_filter = HWTSTAMP_FILTER_NONE;
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+		ptp->rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_EVENT;
+		/* Initialize PTP detection for UDP/IPv4 events */
+		ptp->ops->cfg_rx_filters(edev->cdev, QED_PTP_FILTER_IPV4);
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+		ptp->rx_filter = HWTSTAMP_FILTER_PTP_V2_L4_EVENT;
+		/* Initialize PTP detection for UDP/IPv4 or UDP/IPv6 events */
+		ptp->ops->cfg_rx_filters(edev->cdev, QED_PTP_FILTER_IPV4_IPV6);
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+		ptp->rx_filter = HWTSTAMP_FILTER_PTP_V2_L2_EVENT;
+		/* Initialize PTP detection L2 events */
+		ptp->ops->cfg_rx_filters(edev->cdev, QED_PTP_FILTER_L2);
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+		ptp->rx_filter = HWTSTAMP_FILTER_PTP_V2_EVENT;
+		/* Initialize PTP detection L2, UDP/IPv4 or UDP/IPv6 events */
+		ptp->ops->cfg_rx_filters(edev->cdev,
+					 QED_PTP_FILTER_L2_IPV4_IPV6);
+		break;
+	}
+
+	spin_unlock_bh(&ptp->lock);
+
+	return 0;
+}
+
+int qede_ptp_hw_ts(struct qede_dev *edev, struct ifreq *ifr)
+{
+	struct hwtstamp_config config;
+	struct qede_ptp *ptp;
+	int rc;
+
+	ptp = edev->ptp;
+	if (!ptp)
+		return -EIO;
+
+	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
+		return -EFAULT;
+
+	DP_VERBOSE(edev, QED_MSG_DEBUG,
+		   "HWTSTAMP IOCTL: Requested tx_type = %d, requested rx_filters = %d\n",
+		   config.tx_type, config.rx_filter);
+
+	if (config.flags) {
+		DP_ERR(edev, "config.flags is reserved for future use\n");
+		return -EINVAL;
+	}
+
+	ptp->hw_ts_ioctl_called = 1;
+	ptp->tx_type = config.tx_type;
+	ptp->rx_filter = config.rx_filter;
+
+	rc = qede_ptp_cfg_filters(edev);
+	if (rc)
+		return rc;
+
+	config.rx_filter = ptp->rx_filter;
+
+	return copy_to_user(ifr->ifr_data, &config,
+			    sizeof(config)) ? -EFAULT : 0;
+}
+
+/* Called during load, to initialize PTP-related stuff */
+static void qede_ptp_init(struct qede_dev *edev, bool init_tc)
+{
+	struct qede_ptp *ptp;
+	int rc;
+
+	ptp = edev->ptp;
+	if (!ptp)
+		return;
+
+	spin_lock_init(&ptp->lock);
+
+	/* Configure PTP in HW */
+	rc = ptp->ops->enable(edev->cdev);
+	if (rc) {
+		DP_ERR(edev, "Stopping PTP initialization\n");
+		return;
+	}
+
+	/* Init work queue for Tx timestamping */
+	INIT_WORK(&ptp->work, qede_ptp_task);
+
+	/* Init cyclecounter and timecounter. This is done only in the first
+	 * load. If done in every load, PTP application will fail when doing
+	 * unload / load (e.g. MTU change) while it is running.
+	 */
+	if (init_tc) {
+		qede_ptp_init_cc(edev);
+		timecounter_init(&ptp->tc, &ptp->cc,
+				 ktime_to_ns(ktime_get_real()));
+	}
+
+	DP_VERBOSE(edev, QED_MSG_DEBUG, "PTP initialization is successful\n");
+}
+
+void qede_ptp_start(struct qede_dev *edev, bool init_tc)
+{
+	qede_ptp_init(edev, init_tc);
+	qede_ptp_cfg_filters(edev);
+}
+
+void qede_ptp_remove(struct qede_dev *edev)
+{
+	struct qede_ptp *ptp;
+
+	ptp = edev->ptp;
+	if (ptp && ptp->clock) {
+		ptp_clock_unregister(ptp->clock);
+		ptp->clock = NULL;
+	}
+
+	kfree(ptp);
+	edev->ptp = NULL;
+}
+
+int qede_ptp_get_ts_info(struct qede_dev *edev, struct ethtool_ts_info *info)
+{
+	struct qede_ptp *ptp = edev->ptp;
+
+	if (!ptp)
+		return -EIO;
+
+	info->so_timestamping = SOF_TIMESTAMPING_TX_SOFTWARE |
+				SOF_TIMESTAMPING_RX_SOFTWARE |
+				SOF_TIMESTAMPING_SOFTWARE |
+				SOF_TIMESTAMPING_TX_HARDWARE |
+				SOF_TIMESTAMPING_RX_HARDWARE |
+				SOF_TIMESTAMPING_RAW_HARDWARE;
+
+	if (ptp->clock)
+		info->phc_index = ptp_clock_index(ptp->clock);
+	else
+		info->phc_index = -1;
+
+	info->rx_filters = BIT(HWTSTAMP_FILTER_NONE) |
+			   BIT(HWTSTAMP_FILTER_PTP_V1_L4_EVENT) |
+			   BIT(HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
+			   BIT(HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
+			   BIT(HWTSTAMP_FILTER_PTP_V2_L4_EVENT) |
+			   BIT(HWTSTAMP_FILTER_PTP_V2_L4_SYNC) |
+			   BIT(HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ) |
+			   BIT(HWTSTAMP_FILTER_PTP_V2_L2_EVENT) |
+			   BIT(HWTSTAMP_FILTER_PTP_V2_L2_SYNC) |
+			   BIT(HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ) |
+			   BIT(HWTSTAMP_FILTER_PTP_V2_EVENT) |
+			   BIT(HWTSTAMP_FILTER_PTP_V2_SYNC) |
+			   BIT(HWTSTAMP_FILTER_PTP_V2_DELAY_REQ);
+
+	info->tx_types = BIT(HWTSTAMP_TX_OFF) | BIT(HWTSTAMP_TX_ON);
+
+	return 0;
+}
+
+/* Called during unload, to stop PTP-related stuff */
+void qede_ptp_stop(struct qede_dev *edev)
+{
+	struct qede_ptp *ptp;
+
+	ptp = edev->ptp;
+	if (!ptp)
+		return;
+
+	/* Cancel PTP work queue. Should be done after the Tx queues are
+	 * drained to prevent additional scheduling.
+	 */
+	cancel_work_sync(&ptp->work);
+	if (ptp->tx_skb) {
+		dev_kfree_skb_any(ptp->tx_skb);
+		ptp->tx_skb = NULL;
+	}
+
+	/* Disable PTP in HW */
+	spin_lock_bh(&ptp->lock);
+	ptp->ops->disable(edev->cdev);
+	spin_unlock_bh(&ptp->lock);
+}
+
+int qede_ptp_register_phc(struct qede_dev *edev)
+{
+	struct qede_ptp *ptp;
+
+	ptp = kzalloc(sizeof(*ptp), GFP_KERNEL);
+	if (!ptp) {
+		DP_INFO(edev, "Failed to allocate struct for PTP\n");
+		return -ENOMEM;
+	}
+
+	ptp->edev = edev;
+	ptp->ops = edev->ops->ptp;
+	if (!ptp->ops) {
+		kfree(ptp);
+		edev->ptp = NULL;
+		DP_ERR(edev, "PTP clock registeration failed\n");
+		return -EIO;
+	}
+
+	edev->ptp = ptp;
+
+	/* Fill the ptp_clock_info struct and register PTP clock */
+	ptp->clock_info.owner = THIS_MODULE;
+	snprintf(ptp->clock_info.name, 16, "%s", edev->ndev->name);
+	ptp->clock_info.max_adj = QED_MAX_PHC_DRIFT_PPB;
+	ptp->clock_info.n_alarm = 0;
+	ptp->clock_info.n_ext_ts = 0;
+	ptp->clock_info.n_per_out = 0;
+	ptp->clock_info.pps = 0;
+	ptp->clock_info.adjfreq = qede_ptp_adjfreq;
+	ptp->clock_info.adjtime = qede_ptp_adjtime;
+	ptp->clock_info.gettime64 = qede_ptp_gettime;
+	ptp->clock_info.settime64 = qede_ptp_settime;
+	ptp->clock_info.enable = qede_ptp_ancillary_feature_enable;
+
+	ptp->clock = ptp_clock_register(&ptp->clock_info, &edev->pdev->dev);
+	if (IS_ERR(ptp->clock)) {
+		ptp->clock = NULL;
+		kfree(ptp);
+		edev->ptp = NULL;
+		DP_ERR(edev, "PTP clock registeration failed\n");
+	}
+
+	return 0;
+}
+
+void qede_ptp_tx_ts(struct qede_dev *edev, struct sk_buff *skb)
+{
+	struct qede_ptp *ptp;
+
+	ptp = edev->ptp;
+	if (!ptp)
+		return;
+
+	if (unlikely(!(edev->flags & QEDE_TX_TIMESTAMPING_EN))) {
+		DP_NOTICE(edev,
+			  "Tx timestamping was not enabled, this packet will not be timestamped\n");
+	} else if (unlikely(ptp->tx_skb)) {
+		DP_NOTICE(edev,
+			  "The device supports only a single outstanding packet to timestamp, this packet will not be timestamped\n");
+	} else {
+		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+		/* schedule check for Tx timestamp */
+		ptp->tx_skb = skb_get(skb);
+		schedule_work(&ptp->work);
+	}
+}
+
+void qede_ptp_rx_ts(struct qede_dev *edev, struct sk_buff *skb)
+{
+	struct qede_ptp *ptp;
+	u64 timestamp, ns;
+	int rc;
+
+	ptp = edev->ptp;
+	if (!ptp)
+		return;
+
+	spin_lock_bh(&ptp->lock);
+	rc = ptp->ops->read_rx_ts(edev->cdev, &timestamp);
+	if (rc) {
+		spin_unlock_bh(&ptp->lock);
+		DP_INFO(edev, "Invalid Rx timestamp\n");
+		return;
+	}
+
+	ns = timecounter_cyc2time(&ptp->tc, timestamp);
+	spin_unlock_bh(&ptp->lock);
+	skb_hwtstamps(skb)->hwtstamp = ns_to_ktime(ns);
+	DP_VERBOSE(edev, QED_MSG_DEBUG,
+		   "Rx timestamp, timestamp cycles = %llu, ns = %llu\n",
+		   timestamp, ns);
+}
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ptp.h b/drivers/net/ethernet/qlogic/qede/qede_ptp.h
new file mode 100644
index 0000000..f328f9b
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qede/qede_ptp.h
@@ -0,0 +1,65 @@
+/* QLogic qede NIC Driver
+ * Copyright (c) 2015-2017  QLogic Corporation
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
+ *        disclaimer in the documentation and /or other materials
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
+#ifndef _QEDE_PTP_H_
+#define _QEDE_PTP_H_
+
+#include <linux/ptp_clock_kernel.h>
+#include <linux/net_tstamp.h>
+#include <linux/timecounter.h>
+#include "qede.h"
+
+void qede_ptp_rx_ts(struct qede_dev *edev, struct sk_buff *skb);
+void qede_ptp_tx_ts(struct qede_dev *edev, struct sk_buff *skb);
+int qede_ptp_hw_ts(struct qede_dev *edev, struct ifreq *req);
+void qede_ptp_start(struct qede_dev *edev, bool init_tc);
+void qede_ptp_stop(struct qede_dev *edev);
+void qede_ptp_remove(struct qede_dev *edev);
+int qede_ptp_register_phc(struct qede_dev *edev);
+int qede_ptp_get_ts_info(struct qede_dev *edev, struct ethtool_ts_info *ts);
+
+static inline void qede_ptp_record_rx_ts(struct qede_dev *edev,
+					 union eth_rx_cqe *cqe,
+					 struct sk_buff *skb)
+{
+	/* Check if this packet was timestamped */
+	if (unlikely(le16_to_cpu(cqe->fast_path_regular.pars_flags.flags) &
+		     (1 << PARSING_AND_ERR_FLAGS_TIMESTAMPRECORDED_SHIFT))) {
+		if (likely(le16_to_cpu(cqe->fast_path_regular.pars_flags.flags)
+		    & (1 << PARSING_AND_ERR_FLAGS_TIMESYNCPKT_SHIFT))) {
+			qede_ptp_rx_ts(edev, skb);
+		} else {
+			DP_INFO(edev,
+				"Timestamp recorded for non PTP packets\n");
+		}
+	}
+}
+#endif /* _QEDE_PTP_H_ */
-- 
1.8.3.1
