From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/3] net: dsa: b53: Implement software reset for 58xx devices
Date: Mon, 24 Apr 2017 14:27:22 -0700
Message-ID: <20170424212723.15407-3-f.fainelli@gmail.com>
References: <20170424212723.15407-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoifairelinux.com,
        eric@anholt.net, jon.mason@broadcom.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34690 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S978271AbdDXV1k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 17:27:40 -0400
Received: by mail-wr0-f195.google.com with SMTP id 6so8524829wrb.1
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 14:27:34 -0700 (PDT)
In-Reply-To: <20170424212723.15407-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the correct software reset sequence for 58xx devices by
setting all 3 reset bits and polling for the SW_RST bit to clear itself
without a given timeout. We cannot use is58xx() here because that would
also include the 7445/7278 Starfighter 2 which have their own driver
doing the reset earlier on due to the HW specific integration.

Fixes: 991a36bb4645 ("net: dsa: b53: Add support for BCM585xx/586xx/88312 integrated switch")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 25 ++++++++++++++++++++++++-
 drivers/net/dsa/b53/b53_regs.h   |  1 +
 2 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index ca7f3b005a29..b66ee18cbe49 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -608,7 +608,8 @@ static void b53_switch_reset_gpio(struct b53_device *dev)
 
 static int b53_switch_reset(struct b53_device *dev)
 {
-	u8 mgmt;
+	unsigned int timeout = 1000;
+	u8 mgmt, reg;
 
 	b53_switch_reset_gpio(dev);
 
@@ -617,6 +618,28 @@ static int b53_switch_reset(struct b53_device *dev)
 		b53_write8(dev, B53_CTRL_PAGE, B53_SOFTRESET, 0x00);
 	}
 
+	/* This is specific to 58xx devices here, do not use is58xx() which
+	 * covers the larger Starfigther 2 family, including 7445/7278 which
+	 * still use this driver as a library and need to perform the reset
+	 * earlier.
+	 */
+	if (dev->chip_id == BCM58XX_DEVICE_ID) {
+		b53_read8(dev, B53_CTRL_PAGE, B53_SOFTRESET, &reg);
+		reg |= SW_RST | EN_SW_RST | EN_CH_RST;
+		b53_write8(dev, B53_CTRL_PAGE, B53_SOFTRESET, reg);
+
+		do {
+			b53_read8(dev, B53_CTRL_PAGE, B53_SOFTRESET, &reg);
+			if (!(reg & SW_RST))
+				break;
+
+			usleep_range(1000, 2000);
+		} while (timeout-- > 0);
+
+		if (timeout == 0)
+			return -ETIMEDOUT;
+	}
+
 	b53_read8(dev, B53_CTRL_PAGE, B53_SWITCH_MODE, &mgmt);
 
 	if (!(mgmt & SM_SW_FWD_EN)) {
diff --git a/drivers/net/dsa/b53/b53_regs.h b/drivers/net/dsa/b53/b53_regs.h
index f2a060e7a637..e5c86d44667a 100644
--- a/drivers/net/dsa/b53/b53_regs.h
+++ b/drivers/net/dsa/b53/b53_regs.h
@@ -143,6 +143,7 @@
 /* Software reset register (8 bit) */
 #define B53_SOFTRESET			0x79
 #define   SW_RST			BIT(7)
+#define   EN_CH_RST			BIT(6)
 #define   EN_SW_RST			BIT(4)
 
 /* Fast Aging Control register (8 bit) */
-- 
2.9.3
