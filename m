From: Daniele Venzano <venza@brownhat.org>
Subject: [PATCH] sis900: print warning if MAC address is not available
Date: Wed, 30 Dec 2009 19:22:43 +0100
Message-ID: <20091230182243.GA26340@milesteg.arr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Qxx1br4bt0+wmkIi"
Cc: erik.andren@gmail.com
To: netdev@vger.kernel.org, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.infomaniak.ch ([84.16.68.90]:40193 "EHLO
	smtp2.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbZL3Sbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2009 13:31:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Qxx1br4bt0+wmkIi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The attached patch prints a warning if the MAC address is all 0s in the
sis900 driver.

The patch prints a warning whenever the MAC address read from the
hardware is composed of all zeros.
If the address cannot be read at all for some reason, the driver is
already doing the right thing and bails out.
In reference to bug 11649 from bugzilla.

Please test this patch, it is trivial, but I only test-compiled it since
I no longer have the hardware.

Signed-off-by: Daniele Venzano <linux@brownhat.org>


--Qxx1br4bt0+wmkIi
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="sis900_check_mac.diff"

--- a/drivers/net/sis900.c	2008-12-31 09:15:17.000000000 +0100
+++ b/drivers/net/sis900.c	2008-12-31 09:24:47.000000000 +0100
@@ -382,6 +382,25 @@ static int __devinit sis96x_get_mac_addr
 }
 
 /**
+ *      sis900_check_mac_addr - Check the MAc adress for validity
+ *	@net_dev: the net device that has the address to check
+ *
+ * 	Return false (0) if the mac address read from the hardware is
+ * 	composed of all zeros.
+ */
+
+static int __devinit sis900_check_mac_addr(struct net_device *net_dev)
+{
+	int i;
+
+	for (i = 0; i < 6; i++)
+		if (net_dev->dev_addr[i] != 0)
+			return 1;
+
+	return 0;
+}
+
+/**
  *	sis900_probe - Probe for sis900 device
  *	@pci_dev: the sis900 pci device
  *	@pci_id: the pci device ID
@@ -504,6 +523,9 @@ static int __devinit sis900_probe(struct
 	else
 		ret = sis900_get_mac_addr(pci_dev, net_dev);
 
+	if (sis900_check_mac_addr(net_dev) == 0)
+		printk(KERN_WARNING "%s: Read an invalid MAC address, remember to set one manually\n", dev_name);
+
 	if (ret == 0) {
 		printk(KERN_WARNING "%s: Cannot read MAC address.\n", dev_name);
 		ret = -ENODEV;

--Qxx1br4bt0+wmkIi--
