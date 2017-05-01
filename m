From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH 2/2] net/cxgb4: Use new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Mon,  1 May 2017 16:13:51 -0700
Message-ID: <5c0c569f2de6bb0010d6cadc336ca01811950220.1493678834.git.leedom@chelsio.com>
References: <cover.1493678834.git.leedom@chelsio.com>
Cc: Casey Leedom <leedom@chelsio.com>,
        Michael Werner <werner@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        Arjun V <arjun@chelsio.com>,
        David Miller <davem@davemloft.com>,
        Asit K Mallick <asit.k.mallick@intel.com>,
        Patrick J Cramer <patrick.j.cramer@intel.com>,
        Ashok Raj <ashok.raj@intel.com>,
        Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>,
        Bob Shaw <Bob.Shaw@amd.com>, h <l.stach@pengutronix.de>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Ding Tianhong <dingtianhong@huawei.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Amir Ancel <amira@mellanox.com>,
        Gabriele Paoloni <gabriele.paoloni@huawei.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        LinuxArm <linuxarm@huawei.com>,
        David Laight <David.Laight@a
To: Bjorn Helgaas <helgaas@kernel.org>, leedom@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:19228 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750802AbdEAXPF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 19:15:05 -0400
In-Reply-To: <cover.1493678834.git.leedom@chelsio.com>
In-Reply-To: <cover.1493678834.git.leedom@chelsio.com>
References: <cover.1493678834.git.leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cxgb4 Ethernet driver now queries Root Complex Port to determine if it can
send TLPs to it with the Relaxed Ordering Attribute set.
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 17 +++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |  5 +++--
 3 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 163543b..46d61b1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -512,6 +512,7 @@ enum {                                 /* adapter flags */
 	USING_SOFT_PARAMS  = (1 << 6),
 	MASTER_PF          = (1 << 7),
 	FW_OFLD_CONN       = (1 << 9),
+	ROOT_NO_RELAXED_ORDERING = (1 << 10),
 };
 
 enum {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index afb0967..510c020 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4636,6 +4636,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 #ifdef CONFIG_PCI_IOV
 	u32 v, port_vec;
 #endif
+	struct pci_dev *root;
 
 	printk_once(KERN_INFO "%s - version %s\n", DRV_DESC, DRV_VERSION);
 
@@ -4734,6 +4735,22 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->msg_enable = DFLT_MSG_ENABLE;
 	memset(adapter->chan_map, 0xff, sizeof(adapter->chan_map));
 
+	/* If possible, we use PCIe Relaxed Ordering Attribute to deliver
+	 * Ingress Packet Data to Free List Buffers in order to allow for
+	 * chipset performance optimizations between the Root Complex and
+	 * Memory Controllers.  (Messages to the associated Ingress Queue
+	 * notifying new Packet Placement in the Free Lists Buffers will be
+	 * send without the Relaxed Ordering Attribute thus guaranteing that
+	 * all preceding PCIe Transaction Layer Packets will be processed
+	 * first.)  But some Root Complexes have various issues with Upstream
+	 * Transaction Layer Packets with the Relaxed Ordering Attribute set.
+	 * So we check our Root Complex to see if it's flaged with advice
+	 * against using Relaxed Ordering.
+	 */
+	root = pci_find_pcie_root_port(adapter->pdev);
+	if (root && (root->dev_flags & PCI_DEV_FLAGS_NO_RELAXED_ORDERING))
+		adapter->flags |= ROOT_NO_RELAXED_ORDERING;
+
 	spin_lock_init(&adapter->stats_lock);
 	spin_lock_init(&adapter->tid_release_lock);
 	spin_lock_init(&adapter->win0_lock);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index f05f0d4..ac229a3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2571,6 +2571,7 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 	struct fw_iq_cmd c;
 	struct sge *s = &adap->sge;
 	struct port_info *pi = netdev_priv(dev);
+	int relaxed = !(adap->flags & ROOT_NO_RELAXED_ORDERING);
 
 	/* Size needs to be multiple of 16, including status entry. */
 	iq->size = roundup(iq->size, 16);
@@ -2624,8 +2625,8 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 
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
1.9.1
