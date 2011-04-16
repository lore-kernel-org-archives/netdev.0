From: "Alex G." <mr.nuke.me@gmail.com>
Subject: [PATCH] via-rhine: do not freak out due to invalid MAC address
Date: Sun, 17 Apr 2011 01:05:52 +0300
Message-ID: <4DAA12C0.7030106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Roger Luethi <rl@hellgate.ch>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:35922 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755936Ab1DPWVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2011 18:21:40 -0400
Received: by bwz15 with SMTP id 15so2978484bwz.19
        for <netdev@vger.kernel.org>; Sat, 16 Apr 2011 15:21:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

via-rhine drops out of the init code if the hardware provides an invalid
MAC address. Roger Luethi has had several reports of Rhine NICs doing just
that. The hardware still works, though; assigning a random MAC address
allows the NIC to be used as usual. Tested as a standalone interface,
as carrier for ppp, and as bonding slave.

Signed-off-by: Alexandru Gagniuc <mr.nuke.me@gmail.com>

diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 0422a79..e7e0fa9 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -836,13 +836,18 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 
     for (i = 0; i < 6; i++)
         dev->dev_addr[i] = ioread8(ioaddr + StationAddr + i);
-    memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
-    if (!is_valid_ether_addr(dev->perm_addr)) {
-        rc = -EIO;
-        printk(KERN_ERR "Invalid MAC address\n");
-        goto err_out_unmap;
+    if (!is_valid_ether_addr(dev->dev_addr)) {
+        printk(KERN_ERR "via-rhine: Invalid MAC address: %pM. \n",
+                dev->dev_addr);
+        /* The device may still be used normally if a valid MAC is
+         * configured
+         */
+        random_ether_addr(dev->dev_addr);
+        printk(KERN_ERR "via-rhine: Using randomly generated address:"
+                "%pM instead. \n", dev->dev_addr);
     }
+    memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
     /* For Rhine-I/II, phy_id is loaded from EEPROM */
     if (!phy_id)

