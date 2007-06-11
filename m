From: Mark Zhan <rongkai.zhan@windriver.com>
Subject: [PATCH] MII bitbang driver should generate MII bus phy_mask
	dynamically
Date: Mon, 11 Jun 2007 15:53:37 +0800
Message-ID: <1181548417.5217.13.camel@mark>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>,
	Vitaly Bordug <vbordug@ru.mvista.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54077 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751274AbXFKHyr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 03:54:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Current MII bitbang bus driver hard-codes the phy mask of mii_bus to
~0x09, which is actually specific to the FSL boards. This patch will
make the bitbang driver to generate MII bus phy_mask dynamically, by the
PHY irq info provided by the platform.

Signed-off-by: Mark Zhan <rongkai.zhan@windriver.com>
---
 b/drivers/net/fs_enet/mii-bitbang.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/fs_enet/mii-bitbang.c
b/drivers/net/fs_enet/mii-bitbang.c
index d384010..3732d69 100644
--- a/drivers/net/fs_enet/mii-bitbang.c
+++ b/drivers/net/fs_enet/mii-bitbang.c
@@ -315,7 +315,7 @@ static int __devinit fs_enet_mdio_probe(
 	struct fs_mii_bb_platform_info *pdata;
 	struct mii_bus *new_bus;
 	struct bb_info *bitbang;
-	int err = 0;
+	int i, err = 0;
 
 	if (NULL == dev)
 		return -EINVAL;
@@ -336,14 +336,17 @@ static int __devinit fs_enet_mdio_probe(
 	new_bus->reset = &fs_enet_mii_bb_reset,
 	new_bus->id = pdev->id;
 
-	new_bus->phy_mask = ~0x9;
 	pdata = (struct fs_mii_bb_platform_info *)pdev->dev.platform_data;
-
 	if (NULL == pdata) {
 		printk(KERN_ERR "gfar mdio %d: Missing platform data!\n", pdev->id);
 		return -ENODEV;
 	}
 
+	new_bus->phy_mask = 0xFFFFFFFF;
+	for (i = 0; i < PHY_MAX_ADDR; i++)
+		if (pdata->irq[i] != -1)
+			new_bus->phy_mask &= ~(1 << i);
+
 	/*set up workspace*/
 	fs_mii_bitbang_init(bitbang, pdata);
 

