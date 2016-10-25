From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git)] net: phy: at803x: disable by default the hibernation feature
Date: Tue, 25 Oct 2016 10:31:22 +0200
Message-ID: <1477384282-17878-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Matus Ujhelyi <ujhelyi.m@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:11473 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1758522AbcJYIhb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 04:37:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These PHY chips, by default, enable the hibernation feature
so, if the cable is unplugged the device enters in hibernation
mode after some time. This can generate problems on some cases.
It has been noticed, on some platforms that, if the phy enters
in hibernation, the missing of the rx clock signal can force
a mac to fail when setup some parts that need to be properly
clocked.
For example, while booting a Kernel the SYNP MAC (stmmac) fails
to initialize own DMA engine if the phy entered in hibernation
before.

So, the patch just disables this feature by default when init
the PHY driver.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Matus Ujhelyi <ujhelyi.m@gmail.com>
---
 drivers/net/phy/at803x.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index f279a89..d60953e 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -52,6 +52,9 @@
 #define AT803X_DEBUG_REG_5			0x05
 #define AT803X_DEBUG_TX_CLK_DLY_EN		BIT(8)
 
+#define	AT803X_DEBUG_REG_B			0x0B
+#define	AT803X_DEBUG_PS_HIB_EN			BIT(15)
+
 #define AT803X_REG_CHIP_CONFIG			0x1f
 #define AT803X_BT_BX_REG_SEL			0x8000
 
@@ -117,6 +120,12 @@ static inline int at803x_enable_tx_delay(struct phy_device *phydev)
 					AT803X_DEBUG_TX_CLK_DLY_EN);
 }
 
+static inline int at803x_disable_hibernation(struct phy_device *phydev)
+{
+	return at803x_debug_reg_mask(phydev, AT803X_DEBUG_REG_B,
+				     AT803X_DEBUG_PS_HIB_EN, 0);
+}
+
 /* save relevant PHY registers to private copy */
 static void at803x_context_save(struct phy_device *phydev,
 				struct at803x_context *context)
@@ -314,6 +323,9 @@ static int at803x_config_init(struct phy_device *phydev)
 			return ret;
 	}
 
+	/* By default disable the Power Hibernation feature */
+	at803x_disable_hibernation(phydev);
+
 	return 0;
 }
 
-- 
2.7.4
