From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH 2/3] drivers/net/forcedeth.c: Add workaround for BCM50610
Date: Sat, 10 Oct 2009 17:58:13 +0200
Message-ID: <1255190294-4121-3-git-send-email-manfred@colorfullife.com>
References: <1255190294-4121-1-git-send-email-manfred@colorfullife.com>
 <1255190294-4121-2-git-send-email-manfred@colorfullife.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Manfred Spraul <manfred@colorfullife.com>
To: aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:44101 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761902AbZJJP6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2009 11:58:34 -0400
Received: by fxm27 with SMTP id 27so7279393fxm.17
        for <netdev@vger.kernel.org>; Sat, 10 Oct 2009 08:57:57 -0700 (PDT)
In-Reply-To: <1255190294-4121-2-git-send-email-manfred@colorfullife.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch adds an errata/workaround for the BCM50610 PHY. It was written
by Ayaz Abdulla, I added meaningful names from drivers/net/phy/broadcom.c

Ayaz: The change appears to be identical to bcm50610_a0_workaround(),
except that the workaround is shorter, that fewer registers are modified.
Could you double check that?

--
	Manfred
---
 drivers/net/forcedeth.c |   34 ++++++++++++++++++++++++++++++++++
 1 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 0e48e25..ccb9543 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -586,6 +586,18 @@ union ring_type {
 /* set 2 bits (function unknown) */
 #define PHY_MV_E1XXX_REG_PHY_CTRL_SET	0x0300
 
+/* Broadcom: from drivers/net/phy/broadcom.c */
+#define PHY_BCM54XX_EXP_SEL_REG     0x17    /* Expansion register select */
+#define PHY_BCM54XX_EXP_DATA_REG    0x15    /* Expansion register data */
+
+#define PHY_BCM54XX_EXP_EXP08		0xf08	/* a Shadow register */
+#define PHY_BCM54XX_EXP_DEFAULT		0xf00	/* default register */
+#define PHY_BCM54XX_EXP_EXP08_RJCT_2MHZ        0x0001
+
+#define PHY_BCM54XX_SHD         0x1c    /* 0x1c shadow registers */
+#define PHY_BCM54XX_SHD_WRITE   0x8000
+#define PHY_BCM54XX_SHD_REG3	0x0c00  /* shadow reg 3 - unknown */
+
 #define PHY_GIGABIT	0x0100
 
 #define PHY_TIMEOUT	0x1
@@ -1402,6 +1414,28 @@ static int phy_init(struct net_device *dev)
 		}
 	}
 
+	if (np->phy_oui == PHY_OUI_BROADCOM) {
+		if (np->phy_model == PHY_MODEL_BROADCOM_50610) {
+			if (mii_rw(dev, np->phyaddr, PHY_BCM54XX_SHD, PHY_BCM54XX_SHD_WRITE||
+						PHY_BCM54XX_SHD_REG3|0)) {
+ 				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+ 				return PHY_ERROR;
+ 			}
+			if (mii_rw(dev, np->phyaddr, PHY_BCM54XX_EXP_SEL_REG, PHY_BCM54XX_EXP_EXP08)) {
+ 				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+ 				return PHY_ERROR;
+   			}
+			if (mii_rw(dev, np->phyaddr, PHY_BCM54XX_EXP_DATA_REG, PHY_BCM54XX_EXP_EXP08_RJCT_2MHZ)) {
+ 				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+ 				return PHY_ERROR;
+ 			}
+			if (mii_rw(dev, np->phyaddr, PHY_BCM54XX_EXP_SEL_REG, PHY_BCM54XX_EXP_DEFAULT)) {
+ 				printk(KERN_INFO "%s: phy init failed.\n", pci_name(np->pci_dev));
+ 				return PHY_ERROR;
+ 			}
+		}
+	}
+
 	if ((np->phy_oui == PHY_OUI_CICADA) && (phyinterface & PHY_RGMII) ) {
 		phy_reserved = mii_rw(dev, np->phyaddr, MII_RESV1, MII_READ);
 		phy_reserved &= ~(PHY_CICADA_INIT1 | PHY_CICADA_INIT2);
-- 
1.6.2.5

