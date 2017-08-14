From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v10 4/5] net/cxgb4: Use new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Mon, 14 Aug 2017 23:44:58 +0800
Message-ID: <1502725499-11276-5-git-send-email-dingtianhong@huawei.com>
References: <1502725499-11276-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ding Tianhong <dingtianhong@huawei.com>
To: <leedom@chelsio.com>, <ashok.raj@intel.com>, <bhelgaas@google.com>,
        <helgaas@kernel.org>, <werner@chelsio.com>, <ganeshgr@chelsio.com>,
        <asit.k.mallick@intel.com>, <patrick.j.cramer@intel.com>,
        <Suravee.Suthikulpanit@amd.com>, <Bob.Shaw@amd.com>,
        <l.stach@pengutronix.de>, <amira@mellanox.com>,
        <gabriele.paoloni@huawei.com>, <David.Laight@aculab.com>,
        <jeffrey.t.kirsher@intel.com>, <catalin.marinas@arm.com>,
        <will.deacon@arm.com>, <mark.rutland@arm.com>,
        <robin.murphy@arm.com>, <davem@davemloft.net>,
        <alexander.duyck@gmail.com>,
        <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502725499-11276-1-git-send-email-dingtianhong@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Casey Leedom <leedom@chelsio.com>

cxgb4 Ethernet driver now queries PCIe configuration space to determine
if it can send TLPs to it with the Relaxed Ordering Attribute set.

Remove the enable_pcie_relaxed_ordering() to avoid enable PCIe Capability
Device Control[Relaxed Ordering Enable] at probe routine, to make sure
the driver will not send the Relaxed Ordering TLPs to the Root Complex which
could not deal the Relaxed Ordering TLPs.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Reviewed-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 23 +++++++++++++++++------
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |  5 +++--
 3 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index ef4be78..09ea62e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -529,6 +529,7 @@ enum {                                 /* adapter flags */
 	USING_SOFT_PARAMS  = (1 << 6),
 	MASTER_PF          = (1 << 7),
 	FW_OFLD_CONN       = (1 << 9),
+	ROOT_NO_RELAXED_ORDERING = (1 << 10),
 };
 
 enum {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index e403fa1..33bb867 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4654,11 +4654,6 @@ static void print_port_info(const struct net_device *dev)
 		    dev->name, adap->params.vpd.id, adap->name, buf);
 }
 
-static void enable_pcie_relaxed_ordering(struct pci_dev *dev)
-{
-	pcie_capability_set_word(dev, PCI_EXP_DEVCTL, PCI_EXP_DEVCTL_RELAX_EN);
-}
-
 /*
  * Free the following resources:
  * - memory used for tables
@@ -4908,7 +4903,6 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	pci_enable_pcie_error_reporting(pdev);
-	enable_pcie_relaxed_ordering(pdev);
 	pci_set_master(pdev);
 	pci_save_state(pdev);
 
@@ -4947,6 +4941,23 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->msg_enable = DFLT_MSG_ENABLE;
 	memset(adapter->chan_map, 0xff, sizeof(adapter->chan_map));
 
+	/* If possible, we use PCIe Relaxed Ordering Attribute to deliver
+	 * Ingress Packet Data to Free List Buffers in order to allow for
+	 * chipset performance optimizations between the Root Complex and
+	 * Memory Controllers.  (Messages to the associated Ingress Queue
+	 * notifying new Packet Placement in the Free Lists Buffers will be
+	 * send without the Relaxed Ordering Attribute thus guaranteeing that
+	 * all preceding PCIe Transaction Layer Packets will be processed
+	 * first.)  But some Root Complexes have various issues with Upstream
+	 * Transaction Layer Packets with the Relaxed Ordering Attribute set.
+	 * The PCIe devices which under the Root Complexes will be cleared the
+	 * Relaxed Ordering bit in the configuration space, So we check our
+	 * PCIe configuration space to see if it's flagged with advice against
+	 * using Relaxed Ordering.
+	 */
+	if (!pcie_relaxed_ordering_enabled(pdev))
+		adapter->flags |= ROOT_NO_RELAXED_ORDERING;
+
 	spin_lock_init(&adapter->stats_lock);
 	spin_lock_init(&adapter->tid_release_lock);
 	spin_lock_init(&adapter->win0_lock);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index ede1220..4ef68f6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2719,6 +2719,7 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 	struct fw_iq_cmd c;
 	struct sge *s = &adap->sge;
 	struct port_info *pi = netdev_priv(dev);
+	int relaxed = !(adap->flags & ROOT_NO_RELAXED_ORDERING);
 
 	/* Size needs to be multiple of 16, including status entry. */
 	iq->size = roundup(iq->size, 16);
@@ -2772,8 +2773,8 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 
 		flsz = fl->size / 8 + s->stat_len / sizeof(struct tx_desc);
 		c.iqns_to_fl0congen |= htonl(FW_IQ_CMD_FL0PACKEN_F |
-					     FW_IQ_CMD_FL0FETCHRO_F |
-					     FW_IQ_CMD_FL0DATARO_F |
+					     FW_IQ_CMD_FL0FETCHRO_V(relaxed) |
+					     FW_IQ_CMD_FL0DATARO_V(relaxed) |
 					     FW_IQ_CMD_FL0PADEN_F);
 		if (cong >= 0)
 			c.iqns_to_fl0congen |=
-- 
1.8.3.1
