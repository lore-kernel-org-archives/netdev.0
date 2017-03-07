From: Radoslaw Biernacki <rad@semihalf.com>
Subject: [PATCH] PCI: Add pci reset quirk for Cavium VNIC
Date: Tue,  7 Mar 2017 16:04:48 +0100
Message-ID: <1488899088-10194-1-git-send-email-rad@semihalf.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        Radoslaw Biernacki <rad@semihalf.com>,
        Tomasz Nowicki <tn@semihalf.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Maciej Czekaj <mjc@semihalf.com>, Linu.Cherian@cavium.com,
        Radoslaw Biernacki <rbiernacki@caviumnetworks.com>
To: Bjorn Helgaas <bhelgaas@google.com>, Sunil.Goutham@cavium.com,
        Robert Richter <robert.richter@cavium.com>,
        David Daney <ddaney@caviumnetworks.com>,
        Robert Richter <rric@kernel.org>,
        David Miller <davem@davemloft.net>
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Radoslaw Biernacki <rbiernacki@caviumnetworks.com>

PCI reset quirk is needed for Cavium Function NIC since it does not
handle a function level reset.
This cause problems when VNIC is used from userspace by vfio.
If application (or VM) does not stop the VNIC queues, HW may cause
overwrite of memory locations when next application that use it will
establish new SMMU mappings. More likely HW it will cause SMMU exception,
when network packet will came before new SMMU mappings will be made.

Signed-off-by: Radoslaw Biernacki <rbiernacki@caviumnetworks.com>
Reviewed-by: Sunil Goutham <Sunil.Goutham@cavium.com>
---
 drivers/pci/quirks.c | 90 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 90 insertions(+)

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index f754453..f7cdbe5 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -3783,10 +3783,98 @@ static int reset_chelsio_generic_dev(struct pci_dev *dev, int probe)
 	return 0;
 }
 
+#define CAVIUM_VNIC_QSET_RQ_0_7_CFG		(0x010600)
+#define CAVIUM_VNIC_QSET_CQ_0_7_CFG		(0x010400)
+#define CAVIUM_VNIC_QSET_CQ_0_7_CFG2		(0x010408)
+#define CAVIUM_VNIC_QSET_SQ_0_7_CFG		(0x010800)
+#define CAVIUM_VNIC_QSET_SQ_0_7_STATUS		(0x010840)
+#define CAVIUM_VNIC_QSET_RBDR_0_1_CFG		(0x010C00)
+#define CAVIUM_VNIC_QSET_RBDR_0_1_STATUS0	(0x010C40)
+
+#define CAVIUM_VNIC_Q_SHIFT		(18)
+#define CAVIUM_VNIC_CQ_RESET		(1ULL << 41)
+#define CAVIUM_VNIC_SQ_RESET		(1ULL << 17)
+#define CAVIUM_VNIC_RBDR_RESET		(1ULL << 43)
+#define CAVIUM_VNIC_RBDR_FIFO_STATE_SHIFT (62)
+
+/* Poll a register for a specific value */
+static int cavium_vnic_poll(struct pci_dev *pdev,
+			    void __iomem *addr, size_t bit_pos,
+			    size_t bits, u64 val)
+{
+	u64 bit_mask;
+	u64 reg_val;
+	size_t timeout = 10;
+
+	bit_mask = (1ULL << bits) - 1;
+	bit_mask = (bit_mask << bit_pos);
+
+	while (timeout) {
+		reg_val = readq(addr);
+		if (((reg_val & bit_mask) >> bit_pos) == val)
+			return 0;
+		usleep_range(1000, 2000);
+		timeout--;
+	}
+	dev_err(&pdev->dev, "Poll on addr %p failed\n", addr);
+	return -1;
+}
+
+static int cavium_vnic_reset(struct pci_dev *pdev, int probe)
+{
+	size_t qidx;
+	void __iomem *bar_base;
+	void __iomem *qset_base;
+
+	bar_base = pci_iomap(pdev, 0, 0);
+	if (!bar_base)
+		return -ENOMEM;
+
+	/* For each of 8 RQ/CQ/SQ (queues) in VF */
+	for (qidx = 0; qidx < 8; qidx++) {
+		/* Disable receive queue */
+		qset_base = bar_base + (qidx << CAVIUM_VNIC_Q_SHIFT);
+		writeq(0, qset_base + CAVIUM_VNIC_QSET_RQ_0_7_CFG);
+
+		/* Disable timer threshold (doesn't get reset upon CQ reset */
+		writeq(0, qset_base + CAVIUM_VNIC_QSET_CQ_0_7_CFG2);
+		/* Disable completion queue */
+		writeq(0, qset_base + CAVIUM_VNIC_QSET_CQ_0_7_CFG);
+		/* Reset completion queue */
+		writeq(CAVIUM_VNIC_CQ_RESET,
+			  qset_base + CAVIUM_VNIC_QSET_CQ_0_7_CFG);
+
+		/* Disable send queue */
+		writeq(0, qset_base + CAVIUM_VNIC_QSET_SQ_0_7_CFG);
+		/* Reset send queue */
+		writeq(CAVIUM_VNIC_SQ_RESET,
+		       qset_base + CAVIUM_VNIC_QSET_SQ_0_7_CFG);
+	}
+
+	/* Reset and disable both RBDR's */
+	for (qidx = 0; qidx < 2; qidx++) {
+		qset_base = bar_base +
+			(qidx << CAVIUM_VNIC_Q_SHIFT);
+		writeq(CAVIUM_VNIC_RBDR_RESET,
+		       qset_base + CAVIUM_VNIC_QSET_RBDR_0_1_CFG);
+		writeq(0, qset_base + CAVIUM_VNIC_QSET_RBDR_0_1_CFG);
+		if (cavium_vnic_poll(pdev, qset_base +
+				     CAVIUM_VNIC_QSET_RBDR_0_1_STATUS0,
+				     CAVIUM_VNIC_RBDR_FIFO_STATE_SHIFT,
+				     2, 0x00))
+			dev_err(&pdev->dev, "Timeout on RBDR reset sequence");
+	}
+
+	pci_iounmap(pdev, bar_base);
+	return 0;
+}
+
 #define PCI_DEVICE_ID_INTEL_82599_SFP_VF   0x10ed
 #define PCI_DEVICE_ID_INTEL_IVB_M_VGA      0x0156
 #define PCI_DEVICE_ID_INTEL_IVB_M2_VGA     0x0166
 
+#define PCI_DEVICE_ID_CAVIUM_NIC_VF        0xA034
+
 static const struct pci_dev_reset_methods pci_dev_reset_methods[] = {
 	{ PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_82599_SFP_VF,
 		 reset_intel_82599_sfp_virtfn },
@@ -3796,6 +3884,8 @@ static int reset_chelsio_generic_dev(struct pci_dev *dev, int probe)
 		reset_ivb_igd },
 	{ PCI_VENDOR_ID_CHELSIO, PCI_ANY_ID,
 		reset_chelsio_generic_dev },
+	{ PCI_VENDOR_ID_CAVIUM, PCI_DEVICE_ID_CAVIUM_NIC_VF,
+		cavium_vnic_reset },
 	{ 0 }
 };
 
-- 
1.9.1
