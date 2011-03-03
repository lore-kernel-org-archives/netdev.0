From: "Alex G." <mr.nuke.me@gmail.com>
Subject: Re: [PATCH] via-rhine: do not abort due to invalid MAC address
Date: Fri, 04 Mar 2011 00:08:56 +0200
Message-ID: <4D701178.8000102@gmail.com>
References: <4D6EA33D.70801@gmail.com>	<20110303.134256.68141248.davem@davemloft.net>	<4D700D66.5090300@gmail.com> <20110303.140134.241924015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040404090501050203020609"
Cc: rl@hellgate.ch, florian@openwrt.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:38991 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751274Ab1CCWNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 17:13:25 -0500
Received: by bwz15 with SMTP id 15so1600537bwz.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 14:13:24 -0800 (PST)
In-Reply-To: <20110303.140134.241924015.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040404090501050203020609
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 03/04/2011 12:01 AM, David Miller wrote:
> 
> Still wrong, the patch needs to be "-p1" not "-p0" rooted.

Documentation/SubmittingPatches seems to be outdated then. I used "git
diff"; I hope the format is correct this time

Alex


--------------040404090501050203020609
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

Signed-off-by Alexandru Gagniuc <mr.nuke.me@gmail.com>

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

--------------040404090501050203020609--
