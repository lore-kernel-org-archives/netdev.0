From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6 3/7] be2net: Add error recovery during load for Lancer
Date: Mon, 7 Mar 2011 18:38:36 +0530
Message-ID: <0fd7e6f6-97aa-4b2d-a8e4-460f5af2a792@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subramanian Seetharaman <subbu.seetharaman@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:52334 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753948Ab1CGNJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 08:09:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add error recovery during load for Lancer

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Subramanian Seetharaman <subbu.seetharaman@emulex.com>
---
 drivers/net/benet/be_hw.h   |   12 +++++++++
 drivers/net/benet/be_main.c |   56 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 68 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_hw.h b/drivers/net/benet/be_hw.h
index 3f459f7..dbe67f3 100644
--- a/drivers/net/benet/be_hw.h
+++ b/drivers/net/benet/be_hw.h
@@ -44,6 +44,18 @@
 #define POST_STAGE_BE_RESET		0x3 /* Host wants to reset chip */
 #define POST_STAGE_ARMFW_RDY		0xc000	/* FW is done with POST */
 
+
+/* Lancer SLIPORT_CONTROL SLIPORT_STATUS registers */
+#define SLIPORT_STATUS_OFFSET		0x404
+#define SLIPORT_CONTROL_OFFSET		0x408
+
+#define SLIPORT_STATUS_ERR_MASK		0x80000000
+#define SLIPORT_STATUS_RN_MASK		0x01000000
+#define SLIPORT_STATUS_RDY_MASK		0x00800000
+
+
+#define SLI_PORT_CONTROL_IP_MASK	0x08000000
+
 /********* Memory BAR register ************/
 #define PCICFG_MEMBAR_CTRL_INT_CTRL_OFFSET 	0xfc
 /* Host Interrupt Enable, if set interrupts are enabled although "PCI Interrupt
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index ac7ae21..665a9b7 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2901,6 +2901,54 @@ static int be_dev_family_check(struct be_adapter *adapter)
 	return 0;
 }
 
+static int lancer_wait_ready(struct be_adapter *adapter)
+{
+#define SLIPORT_READY_TIMEOUT 500
+	u32 sliport_status;
+	int status = 0, i;
+
+	for (i = 0; i < SLIPORT_READY_TIMEOUT; i++) {
+		sliport_status = ioread32(adapter->db + SLIPORT_STATUS_OFFSET);
+		if (sliport_status & SLIPORT_STATUS_RDY_MASK)
+			break;
+
+		msleep(20);
+	}
+
+	if (i == SLIPORT_READY_TIMEOUT)
+		status = -1;
+
+	return status;
+}
+
+static int lancer_test_and_set_rdy_state(struct be_adapter *adapter)
+{
+	int status;
+	u32 sliport_status, err, reset_needed;
+	status = lancer_wait_ready(adapter);
+	if (!status) {
+		sliport_status = ioread32(adapter->db + SLIPORT_STATUS_OFFSET);
+		err = sliport_status & SLIPORT_STATUS_ERR_MASK;
+		reset_needed = sliport_status & SLIPORT_STATUS_RN_MASK;
+		if (err && reset_needed) {
+			iowrite32(SLI_PORT_CONTROL_IP_MASK,
+					adapter->db + SLIPORT_CONTROL_OFFSET);
+
+			/* check adapter has corrected the error */
+			status = lancer_wait_ready(adapter);
+			sliport_status = ioread32(adapter->db +
+							SLIPORT_STATUS_OFFSET);
+			sliport_status &= (SLIPORT_STATUS_ERR_MASK |
+						SLIPORT_STATUS_RN_MASK);
+			if (status || sliport_status)
+				status = -1;
+		} else if (err || reset_needed) {
+			status = -1;
+		}
+	}
+	return status;
+}
+
 static int __devinit be_probe(struct pci_dev *pdev,
 			const struct pci_device_id *pdev_id)
 {
@@ -2950,6 +2998,14 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	if (status)
 		goto free_netdev;
 
+	if (lancer_chip(adapter)) {
+		status = lancer_test_and_set_rdy_state(adapter);
+		if (status) {
+			dev_err(&pdev->dev, "Adapter in non recoverable error\n");
+			goto free_netdev;
+		}
+	}
+
 	/* sync up with fw's ready state */
 	if (be_physfn(adapter)) {
 		status = be_cmd_POST(adapter);
-- 
1.6.0.2

