From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] net: phy: broadcom: force master mode for BCM54210E and B50212E
Date: Fri,  1 Sep 2017 11:21:21 +0200
Message-ID: <20170901092121.4596-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Hauke Mehrtens <hauke@hauke-m.de>,
        bcm-kernel-feedback-list@broadcom.com,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:33170 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751457AbdIAJVm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 05:21:42 -0400
Received: by mail-lf0-f65.google.com with SMTP id y15so1144715lfd.0
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 02:21:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafał Miłecki <rafal@milecki.pl>

First of all let me explain that the code we use for BCM54210E is also
executed for the B50212E. They are very similar so it probably makes
sense but it may be worth noting. The IDs are:
0x600d84a1: BCM54210E (rev B0)
0x600d84a2: BCM54210E (rev B1)
0x600d84a5: B50212E (rev B0)
0x600d84a6: B50212E (rev B1)

I got a report that a board with BCM47189 SoC and B50212E B1 PHY doesn't
work well with Intel's I217-LM and I218-LM:
http://ark.intel.com/products/60019/Intel-Ethernet-Connection-I217-LM
http://ark.intel.com/products/71307/Intel-Ethernet-Connection-I218-LM
I was told there are massive ping loss.

A solution to this problem is setting master mode in the 1000BASE-T
register. I noticed a similar fix is present in the tg3 driver. One
thing I'm not sure if this is needed for BCM54210E. It shouldn't hurt
however since both are so similar.

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
---
David: I'm not 100% sure if this is the best fix, so let's give others
(Florian?) a moment to look at it / review it, please.
---
 drivers/net/phy/broadcom.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 1e9ad30a35c8..2569db0923b0 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -43,6 +43,10 @@ static int bcm54210e_config_init(struct phy_device *phydev)
 	val &= ~BCM54810_SHD_CLK_CTL_GTXCLK_EN;
 	bcm_phy_write_shadow(phydev, BCM54810_SHD_CLK_CTL, val);
 
+	val = phy_read(phydev, MII_CTRL1000);
+	val |= CTL1000_AS_MASTER | CTL1000_ENABLE_MASTER;
+	phy_write(phydev, MII_CTRL1000, val);
+
 	return 0;
 }
 
-- 
2.11.0
