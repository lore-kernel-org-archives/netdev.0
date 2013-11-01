From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next 5/6] qlcnic: Enable multiple Tx queue support for 83xx/84xx Series adapters.
Date: Fri, 1 Nov 2013 16:51:28 -0400
Message-ID: <28090690f9d7a16629808c8ea0e200354c7b175f.1383358893.git.himanshu.madhani@qlogic.com>
References: <cover.1383358893.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:19088 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753833Ab3KAVWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 17:22:48 -0400
In-Reply-To: <cover.1383358893.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

o 83xx and 84xx firmware is capable of multiple Tx queues.
  This patch will enable multiple Tx queues for 83xx/84xx
  series adapters. Max number of Tx queues supported will be 8.

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c   |  4 ++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c | 18 +++++++++++-------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c   |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c        |  5 +----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c      |  6 +-----
 5 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 75c09ff..18cb401 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -1654,6 +1654,7 @@ int qlcnic_83xx_loopback_test(struct net_device *netdev, u8 mode)
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	u8 drv_sds_rings = adapter->drv_sds_rings;
+	u8 drv_tx_rings = adapter->drv_tx_rings;
 	int ret = 0, loop = 0;
 
 	if (ahw->op_mode == QLCNIC_NON_PRIV_FUNC) {
@@ -1718,6 +1719,7 @@ free_diag_res:
 
 fail_diag_alloc:
 	adapter->drv_sds_rings = drv_sds_rings;
+	adapter->drv_tx_rings = drv_tx_rings;
 	qlcnic_release_diag_lock(adapter);
 	return ret;
 }
@@ -3303,6 +3305,7 @@ int qlcnic_83xx_interrupt_test(struct net_device *netdev)
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	struct qlcnic_cmd_args cmd;
 	u8 val, drv_sds_rings = adapter->drv_sds_rings;
+	u8 drv_tx_rings = adapter->drv_tx_rings;
 	u32 data;
 	u16 intrpt_id, id;
 	int ret;
@@ -3359,6 +3362,7 @@ done:
 
 fail_diag_irq:
 	adapter->drv_sds_rings = drv_sds_rings;
+	adapter->drv_tx_rings = drv_tx_rings;
 	qlcnic_release_diag_lock(adapter);
 	return ret;
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index 1d97c0f..068c4b4 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -2068,13 +2068,13 @@ int qlcnic_83xx_configure_opmode(struct qlcnic_adapter *adapter)
 			return -EIO;
 
 		adapter->max_sds_rings = QLCNIC_MAX_VNIC_SDS_RINGS;
-		adapter->max_tx_rings = QLCNIC_SINGLE_RING;
+		adapter->max_tx_rings = QLCNIC_MAX_VNIC_TX_RINGS;
 	} else if (ret == QLC_83XX_DEFAULT_OPMODE) {
 		ahw->nic_mode = QLCNIC_DEFAULT_MODE;
 		adapter->nic_ops->init_driver = qlcnic_83xx_init_default_driver;
 		ahw->idc.state_entry = qlcnic_83xx_idc_ready_state_entry;
 		adapter->max_sds_rings = ahw->max_rx_ques;
-		adapter->max_tx_rings = QLCNIC_SINGLE_RING;
+		adapter->max_tx_rings = ahw->max_tx_ques;
 	} else {
 		return -EIO;
 	}
@@ -2179,16 +2179,20 @@ static int qlcnic_83xx_get_fw_info(struct qlcnic_adapter *adapter)
 
 static void qlcnic_83xx_init_rings(struct qlcnic_adapter *adapter)
 {
+	u8 rx_cnt = QLCNIC_DEF_SDS_RINGS;
+	u8 tx_cnt = QLCNIC_DEF_TX_RINGS;
+
 	adapter->max_tx_rings = QLCNIC_MAX_TX_RINGS;
 	adapter->max_sds_rings = QLCNIC_MAX_SDS_RINGS;
 
-	qlcnic_set_tx_ring_count(adapter, QLCNIC_SINGLE_RING);
+	if (!adapter->ahw->msix_supported) {
+		rx_cnt = QLCNIC_SINGLE_RING;
+		tx_cnt = QLCNIC_SINGLE_RING;
+	}
 
 	/* compute and set drv sds rings */
-	if (adapter->ahw->msix_supported)
-		qlcnic_set_sds_ring_count(adapter, QLCNIC_DEF_SDS_RINGS);
-	else
-		qlcnic_set_sds_ring_count(adapter, QLCNIC_SINGLE_RING);
+	qlcnic_set_tx_ring_count(adapter, tx_cnt);
+	qlcnic_set_sds_ring_count(adapter, rx_cnt);
 }
 
 int qlcnic_83xx_init(struct qlcnic_adapter *adapter, int pci_using_dac)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 225743c..b36c02f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -731,7 +731,7 @@ static int qlcnic_set_channels(struct net_device *dev,
 		}
 	}
 
-	if (qlcnic_82xx_check(adapter) && channel->tx_count) {
+	if (channel->tx_count) {
 		err = qlcnic_validate_rings(adapter, channel->tx_count,
 					    QLCNIC_TX_QUEUE);
 		if (err) {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 1c07ec2..0149c94 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -581,10 +581,7 @@ netdev_tx_t qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			goto drop_packet;
 	}
 
-	if (qlcnic_check_multi_tx(adapter))
-		tx_ring = &adapter->tx_ring[skb_get_queue_mapping(skb)];
-	else
-		tx_ring = &adapter->tx_ring[0];
+	tx_ring = &adapter->tx_ring[skb_get_queue_mapping(skb)];
 	num_txd = tx_ring->num_desc;
 
 	frag_count = skb_shinfo(skb)->nr_frags + 1;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 1b59f1d..8a2e4b2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -3707,11 +3707,7 @@ int qlcnic_validate_rings(struct qlcnic_adapter *adapter, __u32 ring_cnt,
 		cur_rings = adapter->drv_sds_rings;
 		strcpy(buf, "SDS");
 	} else if (queue_type == QLCNIC_TX_QUEUE) {
-		if (qlcnic_83xx_check(adapter))
-			max_hw_rings = QLCNIC_SINGLE_RING;
-		else
-			max_hw_rings = adapter->max_tx_rings;
-
+		max_hw_rings = adapter->max_tx_rings;
 		cur_rings = adapter->drv_tx_rings;
 		strcpy(buf, "Tx");
 	}
-- 
1.8.1.4
