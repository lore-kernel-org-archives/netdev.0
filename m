From: "Alex G." <mr.nuke.me@gmail.com>
Subject: [PATCH] via-rhine: Work around invalid MAC address error
Date: Wed, 09 Mar 2011 23:34:11 +0200
Message-ID: <4D77F253.5010908@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040505050609010808080307"
Cc: Roger Luethi <rl@hellgate.ch>,
	Florian Fainelli <florian@openwrt.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42038 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753475Ab1CIVjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 16:39:17 -0500
Received: by fxm17 with SMTP id 17so958273fxm.19
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2011 13:39:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040505050609010808080307
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit



--------------040505050609010808080307
Content-Type: text/x-patch;
 name="rhine.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="rhine.patch"

via-rhine drops out of the init code if the hardware provides an invalid
MAC address. Roger Luethi has had several reports of Rhine NICs doing just
that. The hardware still works, though; assigning a random MAC address
allows the NIC to be used as usual. Tested as a standalone interface,
as carrier for ppp, and as bonding slave.

Signed-off-by: Alexandru Gagniuc <mr.nuke.me@gmail.com>

diff --git a/drivers/net/via-rhine.c.orig b/drivers/net/via-rhine.c
index 4930f9d..4c1b9e7 100644
--- a/drivers/net/via-rhine.c.orig
+++ b/drivers/net/via-rhine.c
@@ -762,13 +762,16 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = ioread8(ioaddr + StationAddr + i);
-	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
-	if (!is_valid_ether_addr(dev->perm_addr)) {
-		rc = -EIO;
-		printk(KERN_ERR "Invalid MAC address\n");
-		goto err_out_unmap;
+	if (!is_valid_ether_addr(dev->dev_addr)) {
+		printk(KERN_ERR "via-rhine: Invalid MAC address: %pM. \n",
+				dev->dev_addr);
+		/* The device may still be used normally if a valid MAC is configured */
+		random_ether_addr(dev->dev_addr);
+		printk(KERN_ERR "via-rhine: Using randomly generated address: %pM instead. \n",
+				dev->dev_addr);
 	}
+	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
 	/* For Rhine-I/II, phy_id is loaded from EEPROM */
 	if (!phy_id)

--------------040505050609010808080307--
