From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH] forcedeth: mac address fix
Date: Mon, 31 Mar 2008 16:10:34 -0500
Message-ID: <47F1534A.7020402@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090608020300090500070101"
Cc: Ayaz Abdulla <aabdulla@nvidia.com>, B.Steinbrink@gmx.de
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:19633 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbYCaXMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 19:12:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090608020300090500070101
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This critical patch fixes a mac address issue recently introduced. If 
the device's mac address was in correct order and the flag 
NVREG_TRANSMITPOLL_MAC_ADDR_REV was set, during nv_remove the flag would 
get cleared. During next load, the mac address would get reversed 
because the flag is missing.

As it has been indicated previously, the flag is cleared across a low 
power transition. Therefore, the driver should set the mac address back 
into the reversed order when clearing the flag.

Also, the driver should set back the flag after a low power transition 
to protect against kexec command calling nv_probe a second time.

Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>


--------------090608020300090500070101
Content-Type: text/plain;
 name="patch-forcedeth-macaddrfix"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-forcedeth-macaddrfix"

--- old/drivers/net/forcedeth.c	2008-03-31 15:25:05.000000000 -0700
+++ new/drivers/net/forcedeth.c	2008-03-31 15:41:51.000000000 -0700
@@ -5317,8 +5317,7 @@
 
 	/* check the workaround bit for correct mac address order */
 	txreg = readl(base + NvRegTransmitPoll);
-	if ((txreg & NVREG_TRANSMITPOLL_MAC_ADDR_REV) ||
-	    (id->driver_data & DEV_HAS_CORRECT_MACADDR)) {
+	if (id->driver_data & DEV_HAS_CORRECT_MACADDR) {
 		/* mac address is already in correct order */
 		dev->dev_addr[0] = (np->orig_mac[0] >>  0) & 0xff;
 		dev->dev_addr[1] = (np->orig_mac[0] >>  8) & 0xff;
@@ -5326,6 +5325,22 @@
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
@@ -5596,7 +5611,9 @@
 static int nv_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
+	u8 __iomem *base = get_hwbase(dev);
 	int rc = 0;
+	u32 txreg;
 
 	if (!netif_running(dev))
 		goto out;
@@ -5607,6 +5624,11 @@
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

--------------090608020300090500070101--
