From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH 1/2] net: phy: broadcom: support new device flag for setting master mode
Date: Thu, 12 Oct 2017 10:21:25 +0200
Message-ID: <20171012082126.30660-2-zajec5@gmail.com>
References: <20171012082126.30660-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Hauke Mehrtens <hauke@hauke-m.de>,
        Jon Mason <jon.mason@broadcom.com>,
        Steve Lin <steven.lin1@broadcom.com>,
        Tobias Klauser <tklauser@distanz.ch>,
        bcm-kernel-feedback-list@broadcom.com,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:38560 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753246AbdJLIW3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 04:22:29 -0400
Received: by mail-lf0-f68.google.com with SMTP id m7so1581633lfe.5
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 01:22:28 -0700 (PDT)
In-Reply-To: <20171012082126.30660-1-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafał Miłecki <rafal@milecki.pl>

Some of Broadcom's PHYs run by default in slave mode with Automatic
Slave/Master configuration disabled. It stops them from working properly
with some devices.

So far it has been verified for BCM54210E and BCM50212E which don't
work well with Intel's I217-LM and I218-LM:
http://ark.intel.com/products/60019/Intel-Ethernet-Connection-I217-LM
http://ark.intel.com/products/71307/Intel-Ethernet-Connection-I218-LM
I was told there is massive ping loss.

This commit adds support for a new flag which can be set by an ethernet
driver to fixup PHY setup.

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
---
 drivers/net/phy/broadcom.c | 6 ++++++
 include/linux/brcmphy.h    | 1 +
 2 files changed, 7 insertions(+)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 1e9ad30a35c8..d7ed69deabfb 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -43,6 +43,12 @@ static int bcm54210e_config_init(struct phy_device *phydev)
 	val &= ~BCM54810_SHD_CLK_CTL_GTXCLK_EN;
 	bcm_phy_write_shadow(phydev, BCM54810_SHD_CLK_CTL, val);
 
+	if (phydev->dev_flags & PHY_BRCM_EN_MASTER_MODE) {
+		val = phy_read(phydev, MII_CTRL1000);
+		val |= CTL1000_AS_MASTER | CTL1000_ENABLE_MASTER;
+		phy_write(phydev, MII_CTRL1000, val);
+	}
+
 	return 0;
 }
 
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index abcda9b458ab..9ac9e3e3d1e5 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -63,6 +63,7 @@
 #define PHY_BRCM_EXT_IBND_TX_ENABLE	0x00002000
 #define PHY_BRCM_CLEAR_RGMII_MODE	0x00004000
 #define PHY_BRCM_DIS_TXCRXC_NOENRGY	0x00008000
+#define PHY_BRCM_EN_MASTER_MODE		0x00010000
 
 /* Broadcom BCM7xxx specific workarounds */
 #define PHY_BRCM_7XXX_REV(x)		(((x) >> 8) & 0xff)
-- 
2.11.0
