From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH] netxen: avoid using reset_devices as it may become obsolete
Date: Tue, 23 Nov 2010 05:08:27 -0800
Message-ID: <1290517707-8554-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:48285 "EHLO unm84.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751829Ab0KWNI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Nov 2010 08:08:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

In kdump environment do not depend on reset_devices
parameter to reset the device as the parameter may become obsolete.
Instead use an adapter specific mechanism to determine if the device
needs a reset.

Driver maintains a count of number of pci functions probed
and decrements the count when remove handler of that pci function
is called. If the first probe, probe of function 0,
detects the count as non zero then reset the device.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index e1d30d7..ceeaac9 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1277,6 +1277,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	int i = 0, err;
 	int pci_func_id = PCI_FUNC(pdev->devfn);
 	uint8_t revision_id;
+	u32 val;
 
 	if (pdev->revision >= NX_P3_A0 && pdev->revision <= NX_P3_B1) {
 		pr_warning("%s: chip revisions between 0x%x-0x%x "
@@ -1352,8 +1353,9 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		break;
 	}
 
-	if (reset_devices) {
-		if (adapter->portnum == 0) {
+	if (adapter->portnum == 0) {
+		val = NXRD32(adapter, NX_CRB_DEV_REF_COUNT);
+		if (val != 0xffffffff && val != 0) {
 			NXWR32(adapter, NX_CRB_DEV_REF_COUNT, 0);
 			adapter->need_fw_reset = 1;
 		}
-- 
1.7.3.2

