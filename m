From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] via-rhine: Assign random MAC address if necessary
Date: Sat, 16 Apr 2011 17:15:26 -0700
Message-ID: <c7efaaf6a943f911162261edd7a2186086cda953.1302998994.git.joe@perches.com>
References: <4DAA12C0.7030106@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexandru Gagniuc <mr.nuke.me@gmail.com>,
	Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4761 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753211Ab1DQAPb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Apr 2011 20:15:31 -0400
In-Reply-To: <4DAA12C0.7030106@gmail.com>
In-Reply-To: <cover.1302998994.git.joe@perches.com>
References: <cover.1302998994.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roger Luethi has had several reports of Rhine NICs providing
an invalid MAC address.  If so, assign a random MAC address so
the hardware can still be used.

Tested as a standalone interface, as carrier for ppp, and as a
bonding slave.

Original-patch-by: Alexandru Gagniuc <mr.nuke.me@gmail.com>
Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/via-rhine.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 40f394c..7f23ab9 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -838,13 +838,15 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = ioread8(ioaddr + StationAddr + i);
-	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
-	if (!is_valid_ether_addr(dev->perm_addr)) {
-		rc = -EIO;
-		dev_err(&pdev->dev, "Invalid MAC address\n");
-		goto err_out_unmap;
+	if (!is_valid_ether_addr(dev->dev_addr)) {
+		/* Report it and use a random ethernet address instead */
+		netdev_err(dev, "Invalid MAC address: %pM\n", dev->dev_addr);
+		random_ether_addr(dev->dev_addr);
+		netdev_info(dev, "Using random MAC address: %pM\n",
+			    dev->dev_addr);
 	}
+	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
 	/* For Rhine-I/II, phy_id is loaded from EEPROM */
 	if (!phy_id)
-- 
1.7.4.2.g597a6.dirty

