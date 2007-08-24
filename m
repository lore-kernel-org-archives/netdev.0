From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/2] myri10ge: use pcie_get/set_readrq
Date: Fri, 24 Aug 2007 08:57:17 +0200
Message-ID: <46CE814D.2060704@myri.com>
References: <46CE8103.10109@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1998 "EHLO myri.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758843AbXHXGz7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2007 02:55:59 -0400
In-Reply-To: <46CE8103.10109@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Based on a patch from Peter Oruba, convert myri10ge to use pcie_get_readrq()
and pcie_set_readrq() instead of our own PCI calls and arithmetics.

These driver changes incorporate the proposed PCI-X / PCI-Express read byte
count interface.  Reading and setting those values doesn't take place
"manually", instead wrapping functions are called to allow quirks for some
PCI bridges.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off by: Peter Oruba <peter.oruba@amd.com>
Based on work by Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 drivers/net/myri10ge/myri10ge.c |   32 ++++++--------------------------
 1 file changed, 6 insertions(+), 26 deletions(-)

Index: linux-2.6.git/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.git.orig/drivers/net/myri10ge/myri10ge.c	2007-08-24 08:43:01.000000000 +0200
+++ linux-2.6.git/drivers/net/myri10ge/myri10ge.c	2007-08-24 08:45:29.000000000 +0200
@@ -2514,26 +2514,20 @@
 {
 	struct pci_dev *pdev = mgp->pdev;
 	struct device *dev = &pdev->dev;
-	int cap, status;
-	u16 val;
+	int status;
 
 	mgp->tx.boundary = 4096;
 	/*
 	 * Verify the max read request size was set to 4KB
 	 * before trying the test with 4KB.
 	 */
-	cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
-	if (cap < 64) {
-		dev_err(dev, "Bad PCI_CAP_ID_EXP location %d\n", cap);
-		goto abort;
-	}
-	status = pci_read_config_word(pdev, cap + PCI_EXP_DEVCTL, &val);
-	if (status != 0) {
+	status = pcie_get_readrq(pdev);
+	if (status < 0) {
 		dev_err(dev, "Couldn't read max read req size: %d\n", status);
 		goto abort;
 	}
-	if ((val & (5 << 12)) != (5 << 12)) {
-		dev_warn(dev, "Max Read Request size != 4096 (0x%x)\n", val);
+	if (status != 4096) {
+		dev_warn(dev, "Max Read Request size != 4096 (%d)\n", status);
 		mgp->tx.boundary = 2048;
 	}
 	/*
@@ -2850,9 +2844,7 @@
 	size_t bytes;
 	int i;
 	int status = -ENXIO;
-	int cap;
 	int dac_enabled;
-	u16 val;
 
 	netdev = alloc_etherdev(sizeof(*mgp));
 	if (netdev == NULL) {
@@ -2884,19 +2876,7 @@
 	    = pci_find_capability(pdev, PCI_CAP_ID_VNDR);
 
 	/* Set our max read request to 4KB */
-	cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
-	if (cap < 64) {
-		dev_err(&pdev->dev, "Bad PCI_CAP_ID_EXP location %d\n", cap);
-		goto abort_with_netdev;
-	}
-	status = pci_read_config_word(pdev, cap + PCI_EXP_DEVCTL, &val);
-	if (status != 0) {
-		dev_err(&pdev->dev, "Error %d reading PCI_EXP_DEVCTL\n",
-			status);
-		goto abort_with_netdev;
-	}
-	val = (val & ~PCI_EXP_DEVCTL_READRQ) | (5 << 12);
-	status = pci_write_config_word(pdev, cap + PCI_EXP_DEVCTL, val);
+	status = pcie_set_readrq(pdev, 4096);
 	if (status != 0) {
 		dev_err(&pdev->dev, "Error %d writing PCI_EXP_DEVCTL\n",
 			status);


