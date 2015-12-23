From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 1/4] cxgb4: Warn if device doesn't have enough PCI bandwidth
Date: Wed, 23 Dec 2015 11:29:53 +0530
Message-ID: <1450850396-24141-2-git-send-email-hariprasad@chelsio.com>
References: <1450850396-24141-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:38640 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751095AbbLWF6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 00:58:34 -0500
In-Reply-To: <1450850396-24141-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check if the device get enough bandwidth from the entire PCI chain to
satisfy its capabilities. This patch determines the PCIe device's
bandwidth capabilities by reading its PCIe Link Capabilities registers
and then call the pcie_get_minimum_link function to ensure that the
adapter is hooked into a slot which is capable of providing the
necessary bandwidth capabilities.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 80 ++++++++++++++++++++++++-
 1 file changed, 78 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 8490c84..8326a776 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4532,6 +4532,79 @@ static int init_rss(struct adapter *adap)
 	return 0;
 }
 
+static int cxgb4_get_pcie_dev_link_caps(struct adapter *adap,
+					enum pci_bus_speed *speed,
+					enum pcie_link_width *width)
+{
+	u32 lnkcap1, lnkcap2;
+	int err1, err2;
+
+#define  PCIE_MLW_CAP_SHIFT 4   /* start of MLW mask in link capabilities */
+
+	*speed = PCI_SPEED_UNKNOWN;
+	*width = PCIE_LNK_WIDTH_UNKNOWN;
+
+	err1 = pcie_capability_read_dword(adap->pdev, PCI_EXP_LNKCAP,
+					  &lnkcap1);
+	err2 = pcie_capability_read_dword(adap->pdev, PCI_EXP_LNKCAP2,
+					  &lnkcap2);
+	if (!err2 && lnkcap2) { /* PCIe r3.0-compliant */
+		if (lnkcap2 & PCI_EXP_LNKCAP2_SLS_8_0GB)
+			*speed = PCIE_SPEED_8_0GT;
+		else if (lnkcap2 & PCI_EXP_LNKCAP2_SLS_5_0GB)
+			*speed = PCIE_SPEED_5_0GT;
+		else if (lnkcap2 & PCI_EXP_LNKCAP2_SLS_2_5GB)
+			*speed = PCIE_SPEED_2_5GT;
+	}
+	if (!err1) {
+		*width = (lnkcap1 & PCI_EXP_LNKCAP_MLW) >> PCIE_MLW_CAP_SHIFT;
+		if (!lnkcap2) { /* pre-r3.0 */
+			if (lnkcap1 & PCI_EXP_LNKCAP_SLS_5_0GB)
+				*speed = PCIE_SPEED_5_0GT;
+			else if (lnkcap1 & PCI_EXP_LNKCAP_SLS_2_5GB)
+				*speed = PCIE_SPEED_2_5GT;
+		}
+	}
+
+	if (*speed == PCI_SPEED_UNKNOWN || *width == PCIE_LNK_WIDTH_UNKNOWN)
+		return err1 ? err1 : err2 ? err2 : -EINVAL;
+	return 0;
+}
+
+static void cxgb4_check_pcie_caps(struct adapter *adap)
+{
+	enum pcie_link_width width, width_cap;
+	enum pci_bus_speed speed, speed_cap;
+
+#define PCIE_SPEED_STR(speed) \
+	(speed == PCIE_SPEED_8_0GT ? "8.0GT/s" : \
+	 speed == PCIE_SPEED_5_0GT ? "5.0GT/s" : \
+	 speed == PCIE_SPEED_2_5GT ? "2.5GT/s" : \
+	 "Unknown")
+
+	if (cxgb4_get_pcie_dev_link_caps(adap, &speed_cap, &width_cap)) {
+		dev_warn(adap->pdev_dev,
+			 "Unable to determine PCIe device BW capabilities\n");
+		return;
+	}
+
+	if (pcie_get_minimum_link(adap->pdev, &speed, &width) ||
+	    speed == PCI_SPEED_UNKNOWN || width == PCIE_LNK_WIDTH_UNKNOWN) {
+		dev_warn(adap->pdev_dev,
+			 "Unable to determine PCI Express bandwidth.\n");
+		return;
+	}
+
+	dev_info(adap->pdev_dev, "PCIe link speed is %s, device supports %s\n",
+		 PCIE_SPEED_STR(speed), PCIE_SPEED_STR(speed_cap));
+	dev_info(adap->pdev_dev, "PCIe link width is x%d, device supports x%d\n",
+		 width, width_cap);
+	if (speed < speed_cap || width < width_cap)
+		dev_info(adap->pdev_dev,
+			 "A slot with more lanes and/or higher speed is "
+			 "suggested for optimal performance.\n");
+}
+
 static void print_port_info(const struct net_device *dev)
 {
 	char buf[80];
@@ -4559,10 +4632,10 @@ static void print_port_info(const struct net_device *dev)
 		--bufp;
 	sprintf(bufp, "BASE-%s", t4_get_port_type_description(pi->port_type));
 
-	netdev_info(dev, "Chelsio %s rev %d %s %sNIC PCIe x%d%s%s\n",
+	netdev_info(dev, "Chelsio %s rev %d %s %sNIC %s\n",
 		    adap->params.vpd.id,
 		    CHELSIO_CHIP_RELEASE(adap->params.chip), buf,
-		    is_offload(adap) ? "R" : "", adap->params.pci.width, spd,
+		    is_offload(adap) ? "R" : "",
 		    (adap->flags & USING_MSIX) ? " MSI-X" :
 		    (adap->flags & USING_MSI) ? " MSI" : "");
 	netdev_info(dev, "S/N: %s, P/N: %s\n",
@@ -4908,6 +4981,9 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	else if (msi > 0 && pci_enable_msi(pdev) == 0)
 		adapter->flags |= USING_MSI;
 
+	/* check for PCI Express bandwidth capabiltites */
+	cxgb4_check_pcie_caps(adapter);
+
 	err = init_rss(adapter);
 	if (err)
 		goto out_free_dev;
-- 
2.3.4
