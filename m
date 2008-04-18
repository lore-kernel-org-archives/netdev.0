From: Enrico Scholz <enrico.scholz@sigma-chemnitz.de>
Subject: [PATCH] DM9000: platform dependent fill_ether_addr method
Date: Fri, 18 Apr 2008 12:02:14 +0200
Message-ID: <1208512936-5897-1-git-send-email-enrico.scholz@sigma-chemnitz.de>
Cc: Enrico Scholz <enrico.scholz@sigma-chemnitz.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.cvg.de ([62.153.82.30]:58944 "EHLO mail.cvg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754656AbYDRKKS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2008 06:10:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a fill_ether_addr() method to the DM9000 platform data
which can be used to fill in the MAC address in a platform specific manner
(e.g. calculate it out of the serial number).

This method will be called only, when MAC was not set previously (e.g. by
bootloader) or can be read out of the EEPROM.

Having a valid MAC address in early bootstage is necessary e.g. for booting
from network.

Signed-off-by: Enrico Scholz <enrico.scholz@sigma-chemnitz.de>
---
 drivers/net/dm9000.c   |    4 ++++
 include/linux/dm9000.h |    5 +++++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index d63cc93..e668b37 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -702,6 +702,10 @@ dm9000_probe(struct platform_device *pdev)
 			ndev->dev_addr[i] = ior(db, i+DM9000_PAR);
 	}
 
+	if (pdata && pdata->fill_ether_addr &&
+	    !is_valid_ether_addr(ndev->dev_addr))
+		pdata->fill_ether_addr(ndev->dev_addr);
+
 	if (!is_valid_ether_addr(ndev->dev_addr))
 		dev_warn(db->dev, "%s: Invalid ethernet MAC address. Please "
 			 "set using ifconfig\n", ndev->name);
diff --git a/include/linux/dm9000.h b/include/linux/dm9000.h
index a375046..f763507 100644
--- a/include/linux/dm9000.h
+++ b/include/linux/dm9000.h
@@ -32,6 +32,11 @@ struct dm9000_plat_data {
 	void	(*inblk)(void __iomem *reg, void *data, int len);
 	void	(*outblk)(void __iomem *reg, void *data, int len);
 	void	(*dumpblk)(void __iomem *reg, int len);
+
+	/* An optional method which fills in the MAC address when it could not
+	 * be read from EEPROM. The used method should/can be tagged as
+	 * __devinit. */
+	void 	(*fill_ether_addr)(unsigned char mac[6]);
 };
 
 #endif /* __DM9000_PLATFORM_DATA */
-- 
1.5.4.1

