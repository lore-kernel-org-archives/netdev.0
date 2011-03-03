From: "Alex G." <mr.nuke.me@gmail.com>
Subject: Re: [PATCH] via-rhine: do not abort due to invalid MAC address
Date: Thu, 03 Mar 2011 23:51:34 +0200
Message-ID: <4D700D66.5090300@gmail.com>
References: <20110302.113610.71137356.davem@davemloft.net>	<20110302195205.GA15190@core.hellgate.ch>	<4D6EA33D.70801@gmail.com> <20110303.134256.68141248.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000809070504080406010905"
Cc: rl@hellgate.ch, florian@openwrt.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:47914 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758926Ab1CCWA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 17:00:28 -0500
Received: by bwz15 with SMTP id 15so1591168bwz.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 14:00:27 -0800 (PST)
In-Reply-To: <20110303.134256.68141248.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000809070504080406010905
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit


--------------000809070504080406010905
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

--- drivers/net/via-rhine.c.orig	2011-02-06 21:04:07.000000000 +0200
+++ drivers/net/via-rhine.c	2011-03-02 22:03:13.000000000 +0200
@@ -762,13 +762,16 @@ static int __devinit rhine_init_one(stru
 
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

--------------000809070504080406010905--
