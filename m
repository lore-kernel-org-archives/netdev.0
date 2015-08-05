From: Liviu Dudau <Liviu.Dudau@arm.com>
Subject: [PATCH] sky2: Add module parameter for passing the MAC address
Date: Wed,  5 Aug 2015 16:50:54 +0100
Message-ID: <1438789854-29194-1-git-send-email-Liviu.Dudau@arm.com>
Cc: Ryan Harkin <ryan.harkin@linaro.org>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Mirko Lindner <mlindner@marvell.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw-tnat.cambridge.arm.com ([217.140.96.140]:37672 "EHLO
	cam-smtp0.cambridge.arm.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752826AbbHEPvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 11:51:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For designs where EEPROMs are not connected to PCI Yukon2
chips we need to get the MAC address from the firmware.
Add a module parameter called 'mac_address' for this. It
will be used if no DT node can be found and the B2_MAC
register holds an invalid value.

Signed-off-by: Liviu Dudau <Liviu.Dudau@arm.com>
---
 drivers/net/ethernet/marvell/sky2.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index d9f4498..a977d95 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -101,6 +101,10 @@ static int legacy_pme = 0;
 module_param(legacy_pme, int, 0);
 MODULE_PARM_DESC(legacy_pme, "Legacy power management");
 
+/* Ugh!  Let the firmware tell us the hardware address */
+static int mac_address[ETH_ALEN] = { 0, };
+module_param_array(mac_address, int, NULL, 0);
+
 static const struct pci_device_id sky2_id_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9000) }, /* SK-9Sxx */
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E00) }, /* SK-9Exx */
@@ -4811,13 +4815,21 @@ static struct net_device *sky2_init_netdev(struct sky2_hw *hw, unsigned port,
 	/* try to get mac address in the following order:
 	 * 1) from device tree data
 	 * 2) from internal registers set by bootloader
+	 * 3) from the command line parameter
 	 */
 	iap = of_get_mac_address(hw->pdev->dev.of_node);
 	if (iap)
 		memcpy(dev->dev_addr, iap, ETH_ALEN);
-	else
+	else {
 		memcpy_fromio(dev->dev_addr, hw->regs + B2_MAC_1 + port * 8,
 			      ETH_ALEN);
+		if (!is_valid_ether_addr(&dev->dev_addr[0])) {
+			int i;
+
+			for (i = 0; i < ETH_ALEN; i++)
+				dev->dev_addr[i] = mac_address[i];
+		}
+	}
 
 	return dev;
 }
-- 
2.4.6
