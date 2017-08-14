From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v10 5/5] net/cxgb4vf: Use new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Mon, 14 Aug 2017 23:44:59 +0800
Message-ID: <1502725499-11276-6-git-send-email-dingtianhong@huawei.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([45.249.212.190]:3517 "EHLO
        szxga04-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752499AbdHNPpd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 11:45:33 -0400
In-Reply-To: <1502725499-11276-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Leedom <leedom@chelsio.com>

cxgb4vf Ethernet driver now queries PCIe configuration space to
determine if it can send TLPs to it with the Relaxed Ordering
Attribute set, just like the pf did.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Reviewed-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h      |  1 +
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c | 18 ++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c          |  3 +++
 3 files changed, 22 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h b/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
index 109bc63..08c6ddb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
@@ -408,6 +408,7 @@ enum { /* adapter flags */
 	USING_MSI          = (1UL << 1),
 	USING_MSIX         = (1UL << 2),
 	QUEUES_BOUND       = (1UL << 3),
+	ROOT_NO_RELAXED_ORDERING = (1UL << 4),
 };
 
 /*
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index ac7a150..2b85b87 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2888,6 +2888,24 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 	 */
 	adapter->name = pci_name(pdev);
 	adapter->msg_enable = DFLT_MSG_ENABLE;
+
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
 	err = adap_init0(adapter);
 	if (err)
 		goto err_unmap_bar;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index e37dde2..05498e7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -2205,6 +2205,7 @@ int t4vf_sge_alloc_rxq(struct adapter *adapter, struct sge_rspq *rspq,
 	struct port_info *pi = netdev_priv(dev);
 	struct fw_iq_cmd cmd, rpl;
 	int ret, iqandst, flsz = 0;
+	int relaxed = !(adapter->flags & ROOT_NO_RELAXED_ORDERING);
 
 	/*
 	 * If we're using MSI interrupts and we're not initializing the
@@ -2300,6 +2301,8 @@ int t4vf_sge_alloc_rxq(struct adapter *adapter, struct sge_rspq *rspq,
 			cpu_to_be32(
 				FW_IQ_CMD_FL0HOSTFCMODE_V(SGE_HOSTFCMODE_NONE) |
 				FW_IQ_CMD_FL0PACKEN_F |
+				FW_IQ_CMD_FL0FETCHRO_V(relaxed) |
+				FW_IQ_CMD_FL0DATARO_V(relaxed) |
 				FW_IQ_CMD_FL0PADEN_F);
 
 		/* In T6, for egress queue type FL there is internal overhead
-- 
1.8.3.1
