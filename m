From: akpm@linux-foundation.org
Subject: [patch for 2.6.25? 1/3] forcedeth: mac address fix
Date: Tue, 08 Apr 2008 17:31:48 -0700
Message-ID: <200804090031.m390Vm9g018702@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	aabdulla@nvidia.com, yhlu.kernel@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49692 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751511AbYDIAb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 20:31:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayaz Abdulla <aabdulla@nvidia.com>

This critical patch fixes a mac address issue recently introduced.  If the
device's mac address was in correct order and the flag
NVREG_TRANSMITPOLL_MAC_ADDR_REV was set, during nv_remove the flag would get
cleared.  During next load, the mac address would get reversed because the
flag is missing.

As it has been indicated previously, the flag is cleared across a low power
transition.  Therefore, the driver should set the mac address back into the
reversed order when clearing the flag.

Also, the driver should set back the flag after a low power transition to
protect against kexec command calling nv_probe a second time.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
Cc: "Yinghai Lu" <yhlu.kernel@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/forcedeth.c |   26 ++++++++++++++++++++++++--
 1 file changed, 24 insertions(+), 2 deletions(-)

diff -puN drivers/net/forcedeth.c~forcedeth-mac-address-fix drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c~forcedeth-mac-address-fix
+++ a/drivers/net/forcedeth.c
@@ -5326,8 +5326,7 @@ static int __devinit nv_probe(struct pci
 
 	/* check the workaround bit for correct mac address order */
 	txreg = readl(base + NvRegTransmitPoll);
-	if ((txreg & NVREG_TRANSMITPOLL_MAC_ADDR_REV) ||
-	    (id->driver_data & DEV_HAS_CORRECT_MACADDR)) {
+	if (id->driver_data & DEV_HAS_CORRECT_MACADDR) {
 		/* mac address is already in correct order */
 		dev->dev_addr[0] = (np->orig_mac[0] >>  0) & 0xff;
 		dev->dev_addr[1] = (np->orig_mac[0] >>  8) & 0xff;
@@ -5335,6 +5334,22 @@ static int __devinit nv_probe(struct pci
 		dev->dev_addr[3] = (np->orig_mac[0] >> 24) & 0xff;
 		dev->dev_addr[4] = (np->orig_mac[1] >>  0) & 0xff;
 		dev->dev_addr[5] = (np->orig_mac[1] >>  8) & 0xff;
+	} else if (txreg & NVREG_TRANSMITPOLL_MAC_ADDR_REV) {
+		/* mac address is already in correct order */
+		dev->dev_addr[0] = (np->orig_mac[0] >>  0) & 0xff;
+		dev->dev_addr[1] = (np->orig_mac[0] >>  8) & 0xff;
+		dev->dev_addr[2] = (np->orig_mac[0] >> 16) & 0xff;
+		dev->dev_addr[3] = (np->orig_mac[0] >> 24) & 0xff;
+		dev->dev_addr[4] = (np->orig_mac[1] >>  0) & 0xff;
+		dev->dev_addr[5] = (np->orig_mac[1] >>  8) & 0xff;
+		/*
+		 * Set orig mac address back to the reversed version.
+		 * This flag will be cleared during low power transition.
+		 * Therefore, we should always put back the reversed address.
+		 */
+		np->orig_mac[0] = (dev->dev_addr[5] << 0) + (dev->dev_addr[4] << 8) +
+			(dev->dev_addr[3] << 16) + (dev->dev_addr[2] << 24);
+		np->orig_mac[1] = (dev->dev_addr[1] << 0) + (dev->dev_addr[0] << 8);
 	} else {
 		/* need to reverse mac address to correct order */
 		dev->dev_addr[0] = (np->orig_mac[1] >>  8) & 0xff;
@@ -5605,7 +5620,9 @@ out:
 static int nv_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
+	u8 __iomem *base = get_hwbase(dev);
 	int rc = 0;
+	u32 txreg;
 
 	if (!netif_running(dev))
 		goto out;
@@ -5616,6 +5633,11 @@ static int nv_resume(struct pci_dev *pde
 	pci_restore_state(pdev);
 	pci_enable_wake(pdev, PCI_D0, 0);
 
+	/* restore mac address reverse flag */
+	txreg = readl(base + NvRegTransmitPoll);
+	txreg |= NVREG_TRANSMITPOLL_MAC_ADDR_REV;
+	writel(txreg, base + NvRegTransmitPoll);
+
 	rc = nv_open(dev);
 out:
 	return rc;
_
