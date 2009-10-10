From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH 3/3] drivers/net/forcedeth.c: add support for Broadcom AC131
Date: Sat, 10 Oct 2009 17:58:14 +0200
Message-ID: <1255190294-4121-4-git-send-email-manfred@colorfullife.com>
References: <1255190294-4121-1-git-send-email-manfred@colorfullife.com>
 <1255190294-4121-2-git-send-email-manfred@colorfullife.com>
 <1255190294-4121-3-git-send-email-manfred@colorfullife.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Manfred Spraul <manfred@colorfullife.com>
To: aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:44125 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761897AbZJJP6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2009 11:58:35 -0400
Received: by fxm27 with SMTP id 27so7279425fxm.17
        for <netdev@vger.kernel.org>; Sat, 10 Oct 2009 08:57:58 -0700 (PDT)
In-Reply-To: <1255190294-4121-3-git-send-email-manfred@colorfullife.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds an errata/update for the Broadcom AC131 PHY to forcedeth.c
The changes where written by Ayaz, I added meaningful names from
drivers/net/phy/broadcom.c.
Ayaz: The change is similar to brcm_fet_config_init(), except that you only
enable auto power down.
Is that sufficient? Please double check that.

--
	Manfred

---
 drivers/net/forcedeth.c |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index ccb9543..1595b2c 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -598,6 +598,12 @@ union ring_type {
 #define PHY_BCM54XX_SHD_WRITE   0x8000
 #define PHY_BCM54XX_SHD_REG3	0x0c00  /* shadow reg 3 - unknown */
 
+/* AC131: */
+#define PHY_BCM_AC131_BRCMTEST		0x1f	/* Brcm test register */
+#define PHY_BCM_AC131_BRCMTEST_SRE	0x0080	/* Shadow register enable */
+#define PHY_BCM_AC131_SHDW_AUXSTAT2		0x1b	/* Auxiliary status 2 */
+#define PHY_BCM_AC131_SHDW_AUXSTAT2_APDE	0x0020	/* Auto power down enable */
+
 #define PHY_GIGABIT	0x0100
 
 #define PHY_TIMEOUT	0x1
@@ -1415,6 +1421,23 @@ static int phy_init(struct net_device *dev)
 	}
 
 	if (np->phy_oui == PHY_OUI_BROADCOM) {
+		if (np->driver_data & DEV_NEED_PHY_INIT_FIX) {
+			if (np->phy_model == PHY_MODEL_BROADCOM_AC131) {
+				phy_reserved = mii_rw(dev, np->phyaddr, PHY_BCM_AC131_BRCMTEST, MII_READ);
+				phy_reserved |= PHY_BCM_AC131_BRCMTEST_SRE;
+				if (mii_rw(dev, np->phyaddr, PHY_BCM_AC131_BRCMTEST,phy_reserved)) {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					return PHY_ERROR;
+				}
+
+				phy_reserved = mii_rw(dev, np->phyaddr, PHY_BCM_AC131_SHDW_AUXSTAT2, MII_READ);
+				phy_reserved |= PHY_BCM_AC131_SHDW_AUXSTAT2_APDE;
+				if (mii_rw(dev, np->phyaddr, PHY_BCM_AC131_SHDW_AUXSTAT2,phy_reserved)) {
+					printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+					return PHY_ERROR;
+				}
+			}
+		}
 		if (np->phy_model == PHY_MODEL_BROADCOM_50610) {
 			if (mii_rw(dev, np->phyaddr, PHY_BCM54XX_SHD, PHY_BCM54XX_SHD_WRITE||
 						PHY_BCM54XX_SHD_REG3|0)) {
-- 
1.6.2.5

