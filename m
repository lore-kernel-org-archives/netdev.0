From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/20] igb: add function to set I210 transmit mode
Date: Tue, 23 Feb 2016 20:26:10 -0800
Message-ID: <1456287984-10459-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Gangfeng Huang <gangfeng.huang@ni.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57891 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757353AbcBXE0a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 23:26:30 -0500
In-Reply-To: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gangfeng Huang <gangfeng.huang@ni.com>

I210 supports two transmit modes, legacy and QAV. The transmit mode is
configured in TQAVCTRL.QavMode register. Before this patch igb driver
only support legacy mode. This patch makes it possible to configure the
transmit mode.

Example:
Get the transmit mode:
$ echo /sys/class/net/eth0/qav_mode
0
Set transmit mode to qav mode
$ echo 1 > /sys/class/net/eth0/qav_mode

Tested:
Setting /sys/class/net/eth0/qav_mode to Qav mode,
 1) Switch back and forth between Qav mode and legacy mode
 2) Send/recv packets in both mode.

Signed-off-by: Gangfeng Huang <gangfeng.huang@ni.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_defines.h |  21 +++
 drivers/net/ethernet/intel/igb/e1000_regs.h    |   7 +
 drivers/net/ethernet/intel/igb/igb.h           |   5 +
 drivers/net/ethernet/intel/igb/igb_main.c      | 182 ++++++++++++++++++++++++-
 4 files changed, 213 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index e9f23ee..c8b10d2 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -360,6 +360,7 @@
 #define MAX_JUMBO_FRAME_SIZE	0x2600
 
 /* PBA constants */
+#define E1000_PBA_32K 0x0020
 #define E1000_PBA_34K 0x0022
 #define E1000_PBA_64K 0x0040    /* 64KB */
 
@@ -1024,4 +1025,24 @@
 #define E1000_RTTBCNRC_RF_INT_MASK	\
 	(E1000_RTTBCNRC_RF_DEC_MASK << E1000_RTTBCNRC_RF_INT_SHIFT)
 
+/* Queue mode, 0=strict, 1=SR mode */
+#define E1000_TQAVCC_QUEUEMODE		0x80000000
+/* Transmit mode, 0=legacy, 1=QAV */
+#define E1000_TQAVCTRL_TXMODE		0x00000001
+/* Report DMA time of tx packets */
+#define E1000_TQAVCTRL_1588_STAT_EN	0x00000004
+#define E1000_TQAVCTRL_DATA_FETCH_ARB	0x00000010 /* Data fetch arbitration */
+#define E1000_TQAVCTRL_DATA_TRAN_ARB	0x00000100 /* Data tx arbitration */
+#define E1000_TQAVCTRL_DATA_TRAN_TIM	0x00000200 /* Data launch time valid */
+/* Stall SP to guarantee SR */
+#define E1000_TQAVCTRL_SP_WAIT_SR	0x00000400
+#define E1000_TQAVCTRL_FETCH_TM_SHIFT	(16)
+
+#define E1000_TXPBSIZE_TX0PB_SHIFT	0
+#define E1000_TXPBSIZE_TX1PB_SHIFT	6
+#define E1000_TXPBSIZE_TX2PB_SHIFT	12
+#define E1000_TXPBSIZE_TX3PB_SHIFT	18
+
+#define E1000_DTXMXPKTSZ_DEFAULT	0x00000098
+
 #endif
diff --git a/drivers/net/ethernet/intel/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
index 21d9d02..bb5ed14 100644
--- a/drivers/net/ethernet/intel/igb/e1000_regs.h
+++ b/drivers/net/ethernet/intel/igb/e1000_regs.h
@@ -138,6 +138,12 @@
 #define E1000_FCRTC	0x02170 /* Flow Control Rx high watermark */
 #define E1000_PCIEMISC	0x05BB8 /* PCIE misc config register */
 
+/* High credit registers where _n can be 0 or 1. */
+#define E1000_TQAVHC(_n)	(0x300C + 0x40 * (_n))
+/* QAV Tx mode control registers where _n can be 0 or 1. */
+#define E1000_TQAVCC(_n)	(0x3004 + 0x40 * (_n))
+#define E1000_TQAVCTRL	0x3570 /* Tx Qav Control registers */
+
 /* TX Rate Limit Registers */
 #define E1000_RTTDQSEL	0x3604 /* Tx Desc Plane Queue Select - WO */
 #define E1000_RTTBCNRM	0x3690 /* Tx BCN Rate-scheduler MMW */
@@ -204,6 +210,7 @@
 #define E1000_TDFT     0x03418  /* TX Data FIFO Tail - RW */
 #define E1000_TDFHS    0x03420  /* TX Data FIFO Head Saved - RW */
 #define E1000_TDFPC    0x03430  /* TX Data FIFO Packet Count - RW */
+#define E1000_DTXMXPKT 0x0355C  /* DMA TX Maximum Packet Size */
 #define E1000_DTXCTL   0x03590  /* DMA TX Control - RW */
 #define E1000_CRCERRS  0x04000  /* CRC Error Count - R/clr */
 #define E1000_ALGNERRC 0x04004  /* Alignment Error Count - R/clr */
diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 707ae5c..3ad5517 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -131,6 +131,9 @@ struct vf_data_storage {
 /* this is the size past which hardware will drop packets when setting LPE=0 */
 #define MAXIMUM_ETHERNET_VLAN_SIZE 1522
 
+/* In qav mode, the maximum frame size is 1536 */
+#define IGB_MAX_QAV_FRAME_SIZE	1536
+
 /* Supported Rx Buffer Sizes */
 #define IGB_RXBUFFER_256	256
 #define IGB_RXBUFFER_2048	2048
@@ -464,6 +467,8 @@ struct igb_adapter {
 	int copper_tries;
 	struct e1000_info ei;
 	u16 eee_advert;
+
+	bool qav_mode;
 };
 
 #define IGB_FLAG_HAS_MSI		(1 << 0)
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index af46fcf..362d579 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -176,6 +176,17 @@ static int igb_ndo_get_vf_config(struct net_device *netdev, int vf,
 				 struct ifla_vf_info *ivi);
 static void igb_check_vf_rate_limit(struct igb_adapter *);
 
+/* Switch qav mode and legacy mode by sysfs*/
+static void igb_setup_qav_mode(struct igb_adapter *adapter);
+static void igb_setup_normal_mode(struct igb_adapter *adapter);
+static ssize_t igb_get_qav_mode(struct device *dev,
+				struct device_attribute *attr, char *buf);
+static ssize_t igb_set_qav_mode(struct device *dev,
+				struct device_attribute *attr,
+				const char *buf, size_t count);
+static DEVICE_ATTR(qav_mode, S_IRUGO | S_IWUSR,
+		   igb_get_qav_mode, igb_set_qav_mode);
+
 #ifdef CONFIG_PCI_IOV
 static int igb_vf_configure(struct igb_adapter *adapter, int vf);
 static int igb_pci_enable_sriov(struct pci_dev *dev, int num_vfs);
@@ -1606,6 +1617,11 @@ static void igb_configure(struct igb_adapter *adapter)
 
 	igb_restore_vlan(adapter);
 
+	if (adapter->qav_mode)
+		igb_setup_qav_mode(adapter);
+	else
+		igb_setup_normal_mode(adapter);
+
 	igb_setup_tctl(adapter);
 	igb_setup_mrqc(adapter);
 	igb_setup_rctl(adapter);
@@ -1883,8 +1899,10 @@ void igb_reset(struct igb_adapter *adapter)
 		pba = rd32(E1000_RXPBS);
 		pba &= E1000_RXPBS_SIZE_MASK_82576;
 		break;
-	case e1000_82575:
 	case e1000_i210:
+		pba = (adapter->qav_mode) ? E1000_PBA_32K : E1000_PBA_34K;
+		break;
+	case e1000_82575:
 	case e1000_i211:
 	default:
 		pba = E1000_PBA_34K;
@@ -2314,6 +2332,7 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	hw = &adapter->hw;
 	hw->back = adapter;
 	adapter->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
+	adapter->qav_mode = false;
 
 	err = -EIO;
 	adapter->io_addr = pci_iomap(pdev, 0, 0);
@@ -2561,6 +2580,15 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto err_register;
 
+	if (hw->mac.type == e1000_i210) {
+		err = sysfs_create_file(&netdev->dev.kobj,
+					&dev_attr_qav_mode.attr);
+		if (err) {
+			netdev_err(netdev, "error creating sysfs file\n");
+			goto err_register;
+		}
+	}
+
 	/* carrier off reporting is important to ethtool even BEFORE open */
 	netif_carrier_off(netdev);
 
@@ -2843,6 +2871,9 @@ static void igb_remove(struct pci_dev *pdev)
 	igb_disable_sriov(pdev);
 #endif
 
+	if (hw->mac.type == e1000_i210)
+		sysfs_remove_file(&netdev->dev.kobj, &dev_attr_qav_mode.attr);
+
 	unregister_netdev(netdev);
 
 	igb_clear_interrupt_scheme(adapter);
@@ -2927,7 +2958,12 @@ static void igb_init_queue_configuration(struct igb_adapter *adapter)
 		break;
 	}
 
-	adapter->rss_queues = min_t(u32, max_rss_queues, num_online_cpus());
+	/* For QAV mode, always enable all queues */
+	if (adapter->qav_mode)
+		adapter->rss_queues = max_rss_queues;
+	else
+		adapter->rss_queues = min_t(u32, max_rss_queues,
+					    num_online_cpus());
 
 	igb_set_flag_queue_pairs(adapter, max_rss_queues);
 }
@@ -5293,6 +5329,10 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
 		return -EINVAL;
 	}
 
+	/* For i210 Qav mode, the max frame is 1536 */
+	if (adapter->qav_mode && max_frame > IGB_MAX_QAV_FRAME_SIZE)
+		return -EINVAL;
+
 #define MAX_STD_JUMBO_FRAME_SIZE 9238
 	if (max_frame > MAX_STD_JUMBO_FRAME_SIZE) {
 		dev_err(&pdev->dev, "MTU > 9216 not supported.\n");
@@ -8192,4 +8232,142 @@ int igb_reinit_queues(struct igb_adapter *adapter)
 
 	return err;
 }
+
+static void igb_setup_qav_mode(struct igb_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32	tqavctrl;
+	u32	tqavcc0, tqavcc1;
+	u32	tqavhc0, tqavhc1;
+	u32	txpbsize;
+
+	/* reconfigure the tx packet buffer allocation */
+	txpbsize = (8);
+	txpbsize |= (8) << E1000_TXPBSIZE_TX1PB_SHIFT;
+	txpbsize |= (4) << E1000_TXPBSIZE_TX2PB_SHIFT;
+	txpbsize |= (4) << E1000_TXPBSIZE_TX3PB_SHIFT;
+
+	wr32(E1000_TXPBS, txpbsize);
+
+	/* In Qav mode, the maximum sized frames of 1536 bytes */
+	wr32(E1000_DTXMXPKT, IGB_MAX_QAV_FRAME_SIZE / 64);
+
+	/* The I210 implements 4 queues, up to two queues are dedicated
+	 * for stream reservation or priority, strict priority queuing
+	 * while SR queue are subjected to launch time policy
+	 */
+
+	tqavcc0 = E1000_TQAVCC_QUEUEMODE; /* no idle slope */
+	tqavcc1 = E1000_TQAVCC_QUEUEMODE; /* no idle slope */
+	tqavhc0 = 0xFFFFFFFF; /* unlimited credits */
+	tqavhc1 = 0xFFFFFFFF; /* unlimited credits */
+
+	wr32(E1000_TQAVCC(0), tqavcc0);
+	wr32(E1000_TQAVCC(1), tqavcc1);
+	wr32(E1000_TQAVHC(0), tqavhc0);
+	wr32(E1000_TQAVHC(1), tqavhc1);
+
+	tqavctrl = E1000_TQAVCTRL_TXMODE |
+		   E1000_TQAVCTRL_DATA_FETCH_ARB |
+		   E1000_TQAVCTRL_DATA_TRAN_TIM |
+		   E1000_TQAVCTRL_SP_WAIT_SR;
+
+	/* Default to a 10 usec prefetch delta from launch time - time for
+	 * a 1500 byte rx frame to be received over the PCIe Gen1 x1 link.
+	 */
+	tqavctrl |= (10 << 5) << E1000_TQAVCTRL_FETCH_TM_SHIFT;
+
+	wr32(E1000_TQAVCTRL, tqavctrl);
+}
+
+static void igb_setup_normal_mode(struct igb_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+
+	wr32(E1000_TXPBS, I210_TXPBSIZE_DEFAULT);
+	wr32(E1000_DTXMXPKT, E1000_DTXMXPKTSZ_DEFAULT);
+	wr32(E1000_TQAVCTRL, 0);
+}
+
+static int igb_change_mode(struct igb_adapter *adapter, int request_mode)
+{
+	struct net_device *netdev;
+	int err = 0;
+	int current_mode;
+
+	if (NULL == adapter) {
+		dev_err(&adapter->pdev->dev, "map to unbound device!\n");
+		return -ENOENT;
+	}
+
+	current_mode = adapter->qav_mode;
+
+	if (request_mode == current_mode)
+		return 0;
+
+	netdev = adapter->netdev;
+
+	rtnl_lock();
+
+	if (netif_running(netdev))
+		igb_close(netdev);
+	else
+		igb_reset(adapter);
+
+	igb_clear_interrupt_scheme(adapter);
+
+	adapter->qav_mode = request_mode;
+
+	igb_init_queue_configuration(adapter);
+
+	if (igb_init_interrupt_scheme(adapter, true)) {
+		dev_err(&adapter->pdev->dev,
+			"Unable to allocate memory for queues\n");
+		err = -ENOMEM;
+		goto err_out;
+	}
+
+	if (netif_running(netdev))
+		igb_open(netdev);
+
+	rtnl_unlock();
+
+	return err;
+err_out:
+	rtnl_unlock();
+	return err;
+}
+
+static ssize_t igb_get_qav_mode(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct net_device *netdev = to_net_dev(dev);
+	struct igb_adapter *adapter = netdev_priv(netdev);
+
+	return scnprintf(buf, PAGE_SIZE, "%d\n", adapter->qav_mode);
+}
+
+static ssize_t igb_set_qav_mode(struct device *dev,
+				struct device_attribute *attr,
+				const char *buf, size_t len)
+{
+	struct net_device *netdev = to_net_dev(dev);
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	int request_mode, err;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (0 > kstrtoint(buf, 0, &request_mode))
+		return -EINVAL;
+
+	if (request_mode != 0 && request_mode != 1)
+		return -EINVAL;
+
+	err = igb_change_mode(adapter, request_mode);
+	if (err)
+		return err;
+
+	return len;
+}
 /* igb_main.c */
-- 
2.5.0
