From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Shutdown adapter if firmware times out or errors out
Date: Fri, 13 Jan 2017 21:55:26 +0530
Message-ID: <1484324726-29590-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
        ganeshgr@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:49644 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751017AbdAMQUL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 11:20:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Perform an emergency shutdown of the adapter and stop it from
continuing any further communication on the ports or DMA to the
host. This is typically used when the adapter and/or firmware
have crashed and we want to prevent any further accidental
communication with the rest of the world. This will also force
the port Link Status to go down -- if register writes work --
which should help our peers figure out that we're down.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 20 +++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 39 +++++++++++++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |  8 +++++
 4 files changed, 64 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index ad0096e74813..ccb455f14d08 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1501,6 +1501,7 @@ int t4_prep_fw(struct adapter *adap, struct fw_info *fw_info,
 	       const u8 *fw_data, unsigned int fw_size,
 	       struct fw_hdr *card_fw, enum dev_state state, int *reset);
 int t4_prep_adapter(struct adapter *adapter);
+int t4_shutdown_adapter(struct adapter *adapter);
 
 enum t4_bar2_qtype { T4_BAR2_QTYPE_EGRESS, T4_BAR2_QTYPE_INGRESS };
 int t4_bar2_sge_qregs(struct adapter *adapter,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 3349e1f376c3..45ec2374f668 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2782,8 +2782,24 @@ static const struct ethtool_ops cxgb4_mgmt_ethtool_ops = {
 
 void t4_fatal_err(struct adapter *adap)
 {
-	t4_set_reg_field(adap, SGE_CONTROL_A, GLOBALENABLE_F, 0);
-	t4_intr_disable(adap);
+	int port;
+
+	/* Disable the SGE since ULDs are going to free resources that
+	 * could be exposed to the adapter.  RDMA MWs for example...
+	 */
+	t4_shutdown_adapter(adap);
+	for_each_port(adap, port) {
+		struct net_device *dev = adap->port[port];
+
+		/* If we get here in very early initialization the network
+		 * devices may not have been set up yet.
+		 */
+		if (!dev)
+			continue;
+
+		netif_tx_stop_all_queues(dev);
+		netif_carrier_off(dev);
+	}
 	dev_alert(adap->pdev_dev, "encountered fatal error, adapter stopped\n");
 }
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index f113015074b1..093444a220af 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -330,11 +330,12 @@ int t4_wr_mbox_meat_timeout(struct adapter *adap, int mbox, const void *cmd,
 		 * mailbox access list but this is a start.  We very rearely
 		 * contend on access to the mailbox ...
 		 */
-		if (i > FW_CMD_MAX_TIMEOUT) {
+		pcie_fw = t4_read_reg(adap, PCIE_FW_A);
+		if (i > FW_CMD_MAX_TIMEOUT || (pcie_fw & PCIE_FW_ERR_F)) {
 			spin_lock(&adap->mbox_lock);
 			list_del(&entry.list);
 			spin_unlock(&adap->mbox_lock);
-			ret = -EBUSY;
+			ret = (pcie_fw & PCIE_FW_ERR_F) ? -ENXIO : -EBUSY;
 			t4_record_mbox(adap, cmd, size, access, ret);
 			return ret;
 		}
@@ -432,6 +433,7 @@ int t4_wr_mbox_meat_timeout(struct adapter *adap, int mbox, const void *cmd,
 	spin_lock(&adap->mbox_lock);
 	list_del(&entry.list);
 	spin_unlock(&adap->mbox_lock);
+	t4_fatal_err(adap);
 	return ret;
 }
 
@@ -7540,6 +7542,39 @@ int t4_prep_adapter(struct adapter *adapter)
 }
 
 /**
+ *	t4_shutdown_adapter - shut down adapter, host & wire
+ *	@adapter: the adapter
+ *
+ *	Perform an emergency shutdown of the adapter and stop it from
+ *	continuing any further communication on the ports or DMA to the
+ *	host.  This is typically used when the adapter and/or firmware
+ *	have crashed and we want to prevent any further accidental
+ *	communication with the rest of the world.  This will also force
+ *	the port Link Status to go down -- if register writes work --
+ *	which should help our peers figure out that we're down.
+ */
+int t4_shutdown_adapter(struct adapter *adapter)
+{
+	int port;
+
+	t4_intr_disable(adapter);
+	t4_write_reg(adapter, DBG_GPIO_EN_A, 0);
+	for_each_port(adapter, port) {
+		u32 a_port_cfg = PORT_REG(port,
+					  is_t4(adapter->params.chip)
+					  ? XGMAC_PORT_CFG_A
+					  : MAC_PORT_CFG_A);
+
+		t4_write_reg(adapter, a_port_cfg,
+			     t4_read_reg(adapter, a_port_cfg)
+			     & ~SIGNAL_DET_V(1));
+	}
+	t4_set_reg_field(adapter, SGE_CONTROL_A, GLOBALENABLE_F, 0);
+
+	return 0;
+}
+
+/**
  *	t4_bar2_sge_qregs - return BAR2 SGE Queue register information
  *	@adapter: the adapter
  *	@qid: the Queue ID
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index e685163b1357..edb9b97dcc5c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -855,6 +855,14 @@
 #define PERR_INT_CAUSE_V(x) ((x) << PERR_INT_CAUSE_S)
 #define PERR_INT_CAUSE_F    PERR_INT_CAUSE_V(1U)
 
+#define DBG_GPIO_EN_A		0x6010
+#define XGMAC_PORT_CFG_A	0x1000
+#define MAC_PORT_CFG_A		0x800
+
+#define SIGNAL_DET_S    14
+#define SIGNAL_DET_V(x) ((x) << SIGNAL_DET_S)
+#define SIGNAL_DET_F    SIGNAL_DET_V(1U)
+
 #define MC_ECC_STATUS_A		0x751c
 #define MC_P_ECC_STATUS_A	0x4131c
 
-- 
2.3.4
