From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v5 1/3] PCI: Add new PCIe Fabric End Node flag, PCI_DEV_FLAGS_NO_RELAXED_ORDERING
Date: Mon, 19 Jun 2017 14:53:57 +0800
Message-ID: <1497855239-18560-2-git-send-email-dingtianhong@huawei.com>
References: <1497855239-18560-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ding Tianhong <dingtianhong@huawei.com>
To: <leedom@chelsio.com>, <ashok.raj@intel.com>, <helgaas@kernel.org>,
        <werner@chelsio.com>, <ganeshgr@chelsio.com>,
        <asit.k.mallick@intel.com>, <patrick.j.cramer@intel.com>,
        <Suravee.Suthikulpanit@amd.com>, <Bob.Shaw@amd.com>,
        <l.stach@pengutronix.de>, <amira@mellanox.com>,
        <gabriele.paoloni@huawei.com>, <David.Laight@aculab.com>,
        <jeffrey.t.kirsher@intel.com>, <catalin.marinas@arm.com>,
        <will.deacon@arm.com>, <mark.rutland@arm.com>,
        <robin.murphy@arm.com>, <davem@davemloft.net>,
        <alexander.duyck@gmail.com>,
        <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([45.249.212.189]:7890 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753324AbdFSGyt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 02:54:49 -0400
In-Reply-To: <1497855239-18560-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Leedom <leedom@chelsio.com>

The new flag PCI_DEV_FLAGS_NO_RELAXED_ORDERING indicates that the Relaxed
Ordering Attribute should not be used on Transaction Layer Packets destined
for the PCIe End Node so flagged.  Initially flagged this way are Intel
E5-26xx Root Complex Ports which suffer from a Flow Control Credit
Performance Problem and AMD A1100 ARM ("SEATTLE") Root Complex Ports which
don't obey PCIe 3.0 ordering rules which can lead to Data Corruption.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/pci/quirks.c | 38 ++++++++++++++++++++++++++++++++++++++
 include/linux/pci.h  |  2 ++
 2 files changed, 40 insertions(+)

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index 085fb78..58bdd23 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -3999,6 +3999,44 @@ static void quirk_tw686x_class(struct pci_dev *pdev)
 			      quirk_tw686x_class);
 
 /*
+ * Some devices have problems with Transaction Layer Packets with the Relaxed
+ * Ordering Attribute set.  Such devices should mark themselves and other
+ * Device Drivers should check before sending TLPs with RO set.
+ */
+static void quirk_relaxedordering_disable(struct pci_dev *dev)
+{
+	dev->dev_flags |= PCI_DEV_FLAGS_NO_RELAXED_ORDERING;
+}
+
+/*
+ * Intel E5-26xx Root Complex has a Flow Control Credit issue which can
+ * cause performance problems with Upstream Transaction Layer Packets with
+ * Relaxed Ordering set.
+ */
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f02, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f04, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_INTEL, 0x6f08, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+
+/*
+ * The AMD ARM A1100 (AKA "SEATTLE") SoC has a bug in its PCIe Root Complex
+ * where Upstream Transaction Layer Packets with the Relaxed Ordering
+ * Attribute clear are allowed to bypass earlier TLPs with Relaxed Ordering
+ * set.  This is a violation of the PCIe 3.0 Transaction Ordering Rules
+ * outlined in Section 2.4.1 (PCI Express(r) Base Specification Revision 3.0
+ * November 10, 2010).  As a result, on this platform we can't use Relaxed
+ * Ordering for Upstream TLPs.
+ */
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_AMD, 0x1a00, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_AMD, 0x1a01, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+DECLARE_PCI_FIXUP_CLASS_EARLY(PCI_VENDOR_ID_AMD, 0x1a02, PCI_CLASS_NOT_DEFINED, 8,
+			      quirk_relaxedordering_disable);
+
+/*
  * Per PCIe r3.0, sec 2.2.9, "Completion headers must supply the same
  * values for the Attribute as were supplied in the header of the
  * corresponding Request, except as explicitly allowed when IDO is used."
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 8039f9f..ce77690 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -188,6 +188,8 @@ enum pci_dev_flags {
 	 * the direct_complete optimization.
 	 */
 	PCI_DEV_FLAGS_NEEDS_RESUME = (__force pci_dev_flags_t) (1 << 11),
+	/* Don't use Relaxed Ordering for TLPs directed at this device */
+	PCI_DEV_FLAGS_NO_RELAXED_ORDERING = (__force pci_dev_flags_t) (1 << 12),
 };
 
 enum pci_irq_reroute_variant {
-- 
1.9.0
