From: Pavel Fedin <p.fedin@samsung.com>
Subject: [PATCH] net: smsc911x: Reset PHY during initialization
Date: Fri, 30 Oct 2015 10:06:19 +0300
Message-ID: <1446188779-4184-1-git-send-email-p.fedin@samsung.com>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On certain hardware after software reboot the chip may get stuck and fail
to reinitialize during reset. This can be fixed by ensuring that PHY is
reset too.

Old PHY resetting method required operational MDIO interface, therefore
the chip should have been already set up. In order to be able to function
during probe, it is changed to use PMT_CTRL register.

The problem could be observed on SMDK5410 board.

Signed-off-by: Pavel Fedin <p.fedin@samsung.com>
---
 drivers/net/ethernet/smsc/smsc911x.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index c860c90..219a99b 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -809,22 +809,17 @@ static int smsc911x_phy_check_loopbackpkt(struct smsc911x_data *pdata)
 
 static int smsc911x_phy_reset(struct smsc911x_data *pdata)
 {
-	struct phy_device *phy_dev = pdata->phy_dev;
 	unsigned int temp;
 	unsigned int i = 100000;
 
-	BUG_ON(!phy_dev);
-	BUG_ON(!phy_dev->bus);
-
-	SMSC_TRACE(pdata, hw, "Performing PHY BCR Reset");
-	smsc911x_mii_write(phy_dev->bus, phy_dev->addr, MII_BMCR, BMCR_RESET);
+	temp = smsc911x_reg_read(pdata, PMT_CTRL);
+	smsc911x_reg_write(pdata, PMT_CTRL, temp | PMT_CTRL_PHY_RST_);
 	do {
 		msleep(1);
-		temp = smsc911x_mii_read(phy_dev->bus, phy_dev->addr,
-			MII_BMCR);
-	} while ((i--) && (temp & BMCR_RESET));
+		temp = smsc911x_reg_read(pdata, PMT_CTRL);
+	} while ((i--) && (temp & PMT_CTRL_PHY_RST_));
 
-	if (temp & BMCR_RESET) {
+	if (unlikely(temp & PMT_CTRL_PHY_RST_)) {
 		SMSC_WARN(pdata, hw, "PHY reset failed to complete");
 		return -EIO;
 	}
@@ -2296,7 +2291,7 @@ static int smsc911x_init(struct net_device *dev)
 	}
 
 	/* Reset the LAN911x */
-	if (smsc911x_soft_reset(pdata))
+	if (smsc911x_phy_reset(pdata) || smsc911x_soft_reset(pdata))
 		return -ENODEV;
 
 	dev->flags |= IFF_MULTICAST;
-- 
2.4.4
