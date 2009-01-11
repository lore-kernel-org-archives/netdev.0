From: Daniele Venzano <venza@brownhat.org>
Subject: [PATCH] SIS900 show warning if bogus MAC address
Date: Sun, 11 Jan 2009 09:45:04 +0100
Message-ID: <20090111084504.GB12226@brownhat.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="7AUc2qLy4jB3hD7Z"
Cc: akpm@linux-foundation.org, venza@brownhat.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.infomaniak.ch ([84.16.68.89]:43203 "EHLO
	smtp1.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbZAKIzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 03:55:18 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--7AUc2qLy4jB3hD7Z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The attached patch modifies the sis900 driver to show a warning at boot
or module load time to show a message when a null MAC address
(00:00:00:00:00:00) is read from the the hardware.
This seems to happen with newer usage of the sis900 chipset, since this
never came up before.

Signed-off-by: Daniele Venzano <venza@brownhat.org>

--
Daniele Venzano
http://www.brownhat.org


--7AUc2qLy4jB3hD7Z
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

--7AUc2qLy4jB3hD7Z--
