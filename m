From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2/2 2.6.26] cxgb3 - fix EEH
Date: Tue, 06 May 2008 19:26:01 -0700
Message-ID: <20080507022601.3154.64317.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:28306 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755317AbYEGCjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 22:39:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Reset the chip when the PCI link goes down.
Preserve the napi structure when a sge qset's resources are freed.
Replay only HW initialization when the chip comes out of reset.

Signed-off-by: Divy Le ray <divy@chelsio.com>
---

 drivers/net/cxgb3/common.h     |    1 +
 drivers/net/cxgb3/cxgb3_main.c |   10 ++++++----
 drivers/net/cxgb3/regs.h       |    8 ++++++++
 drivers/net/cxgb3/sge.c        |   29 +++++++++++++++++++++++++++--
 drivers/net/cxgb3/t3_hw.c      |   28 ++++++++++++++++++++++++++++
 5 files changed, 70 insertions(+), 6 deletions(-)

diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index 91ee727..579bee4 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -698,6 +698,7 @@ void mac_prep(struct cmac *mac, struct adapter *adapter, int index);
 void early_hw_init(struct adapter *adapter, const struct adapter_info *ai);
 int t3_prep_adapter(struct adapter *adapter, const struct adapter_info *ai,
 		    int reset);
+int t3_replay_prep_adapter(struct adapter *adapter);
 void t3_led_ready(struct adapter *adapter);
 void t3_fatal_err(struct adapter *adapter);
 void t3_set_vlan_accel(struct adapter *adapter, unsigned int ports, int on);
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 7354d6a..79efcd3 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2430,9 +2430,6 @@ static pci_ers_result_t t3_io_error_detected(struct pci_dev *pdev,
 	    test_bit(OFFLOAD_DEVMAP_BIT, &adapter->open_device_map))
 		offload_close(&adapter->tdev);
 
-	/* Free sge resources */
-	t3_free_sge_resources(adapter);
-
 	adapter->flags &= ~FULL_INIT_DONE;
 
 	pci_disable_device(pdev);
@@ -2457,8 +2454,12 @@ static pci_ers_result_t t3_io_slot_reset(struct pci_dev *pdev)
 		goto err;
 	}
 	pci_set_master(pdev);
+	pci_restore_state(pdev);
+
+	/* Free sge resources */
+	t3_free_sge_resources(adapter);
 
-	if (t3_prep_adapter(adapter, adapter->params.info, 1))
+	if (t3_replay_prep_adapter(adapter))
 		goto err;
 
 	return PCI_ERS_RESULT_RECOVERED;
@@ -2610,6 +2611,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 	}
 
 	pci_set_master(pdev);
+	pci_save_state(pdev);
 
 	mmio_start = pci_resource_start(pdev, 0);
 	mmio_len = pci_resource_len(pdev, 0);
diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index 02dbbb3..5671788 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -444,6 +444,14 @@
 
 #define A_PCIE_CFG 0x88
 
+#define S_ENABLELINKDWNDRST    21
+#define V_ENABLELINKDWNDRST(x) ((x) << S_ENABLELINKDWNDRST)
+#define F_ENABLELINKDWNDRST    V_ENABLELINKDWNDRST(1U)
+
+#define S_ENABLELINKDOWNRST    20
+#define V_ENABLELINKDOWNRST(x) ((x) << S_ENABLELINKDOWNRST)
+#define F_ENABLELINKDOWNRST    V_ENABLELINKDOWNRST(1U)
+
 #define S_PCIE_CLIDECEN    16
 #define V_PCIE_CLIDECEN(x) ((x) << S_PCIE_CLIDECEN)
 #define F_PCIE_CLIDECEN    V_PCIE_CLIDECEN(1U)
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 98a6bbd..796eb30 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -539,6 +539,31 @@ static void *alloc_ring(struct pci_dev *pdev, size_t nelem, size_t elem_size,
 }
 
 /**
+ *	t3_reset_qset - reset a sge qset
+ *	@q: the queue set
+ *
+ *	Reset the qset structure.
+ *	the NAPI structure is preserved in the event of
+ *	the qset's reincarnation, for example during EEH recovery.
+ */
+static void t3_reset_qset(struct sge_qset *q)
+{
+	if (q->adap &&
+	    !(q->adap->flags & NAPI_INIT)) {
+		memset(q, 0, sizeof(*q));
+		return;
+	}
+
+	q->adap = NULL;
+	memset(&q->rspq, 0, sizeof(q->rspq));
+	memset(q->fl, 0, sizeof(struct sge_fl) * SGE_RXQ_PER_SET);
+	memset(q->txq, 0, sizeof(struct sge_txq) * SGE_TXQ_PER_SET);
+	q->txq_stopped = 0;
+	memset(&q->tx_reclaim_timer, 0, sizeof(q->tx_reclaim_timer));
+}
+
+
+/**
  *	free_qset - free the resources of an SGE queue set
  *	@adapter: the adapter owning the queue set
  *	@q: the queue set
@@ -594,7 +619,7 @@ static void t3_free_qset(struct adapter *adapter, struct sge_qset *q)
 				  q->rspq.desc, q->rspq.phys_addr);
 	}
 
-	memset(q, 0, sizeof(*q));
+	t3_reset_qset(q);
 }
 
 /**
@@ -1365,7 +1390,7 @@ static void restart_ctrlq(unsigned long data)
  */
 int t3_mgmt_tx(struct adapter *adap, struct sk_buff *skb)
 {
-	int ret; 
+	int ret;
 	local_bh_disable();
 	ret = ctrl_xmit(adap, &adap->sge.qs[0].txq[TXQ_CTRL], skb);
 	local_bh_enable();
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index a99496a..d405a93 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -3264,6 +3264,7 @@ static void config_pcie(struct adapter *adap)
 
 	t3_write_reg(adap, A_PCIE_PEX_ERR, 0xffffffff);
 	t3_set_reg_field(adap, A_PCIE_CFG, 0,
+			 F_ENABLELINKDWNDRST | F_ENABLELINKDOWNRST |
 			 F_PCIE_DMASTOPEN | F_PCIE_CLIDECEN);
 }
 
@@ -3655,3 +3656,30 @@ void t3_led_ready(struct adapter *adapter)
 	t3_set_reg_field(adapter, A_T3DBG_GPIO_EN, F_GPIO0_OUT_VAL,
 			 F_GPIO0_OUT_VAL);
 }
+
+int t3_replay_prep_adapter(struct adapter *adapter)
+{
+	const struct adapter_info *ai = adapter->params.info;
+	unsigned int i, j = 0;
+	int ret;
+
+	early_hw_init(adapter, ai);
+	ret = init_parity(adapter);
+	if (ret)
+		return ret;
+
+	for_each_port(adapter, i) {
+		struct port_info *p = adap2pinfo(adapter, i);
+		while (!adapter->params.vpd.port_type[j])
+			++j;
+
+		p->port_type->phy_prep(&p->phy, adapter, ai->phy_base_addr + j,
+					ai->mdio_ops);
+
+		p->phy.ops->power_down(&p->phy, 1);
+		++j;
+	}
+
+return 0;
+}
+
