From: Stas Sergeev <stsp@list.ru>
Subject: [PATCH 6/6] mvneta: port marvell's official in-band status enabling
 procedure
Date: Thu, 26 Mar 2015 19:04:43 +0300
Message-ID: <55142E1B.1000305@list.ru>
References: <55142C31.5050504@list.ru> <55142CB1.1080107@list.ru> <55142D01.3090601@list.ru> <55142D3C.4040902@list.ru> <55142D91.6010006@list.ru> <55142DD4.9060004@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Rami Rosen <rosenr@marvell.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback7.mail.ru ([94.100.181.128]:37199 "EHLO
	fallback7.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752481AbbCZQYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 12:24:11 -0400
Received: from smtp52.i.mail.ru (smtp52.i.mail.ru [94.100.177.112])
	by fallback7.mail.ru (mPOP.Fallback_MX) with ESMTP id C07AE135BD461
	for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 19:04:47 +0300 (MSK)
In-Reply-To: <55142DD4.9060004@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-=-=-=-=-=-=-=-=-=# Don't remove this line #=-=-=-=-=-=-=-=-=-
This is a back-port of official marvell's patch.
It changes nothing visible for me but looks reasonable.

Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvneta.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c
b/drivers/net/ethernet/marvell/mvneta.c
index 44d2655..5dc7416 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -100,6 +100,8 @@
 #define MVNETA_TXQ_CMD                           0x2448
 #define      MVNETA_TXQ_DISABLE_SHIFT            8
 #define      MVNETA_TXQ_ENABLE_MASK              0x000000ff
+#define MVNETA_GMAC_CLOCK_DIVIDER                0x24f4
+#define      MVNETA_GMAC_1MS_CLOCK_ENABLE        BIT(31)
 #define MVNETA_ACC_MODE                          0x2500
 #define MVNETA_CPU_MAP(cpu)                      (0x2540 + ((cpu) << 2))
 #define      MVNETA_CPU_RXQ_ACCESS_ALL_MASK      0x000000ff
@@ -166,6 +168,7 @@
 #define      MVNETA_GMAC_MAX_RX_SIZE_MASK        0x7ffc
 #define      MVNETA_GMAC0_PORT_ENABLE            BIT(0)
 #define MVNETA_GMAC_CTRL_2                       0x2c08
+#define      MVNETA_GMAC2_INBAND_AN_ENABLE       BIT(0)
 #define      MVNETA_GMAC2_PCS_ENABLE             BIT(3)
 #define      MVNETA_GMAC2_PORT_RGMII             BIT(4)
 #define      MVNETA_GMAC2_PORT_RESET             BIT(6)
@@ -1001,12 +1004,15 @@ static void mvneta_defaults_set(struct
mvneta_port *pp)
     if (pp->inband_status) {
         val = mvreg_read(pp, MVNETA_GMAC_AUTONEG_CONFIG);
         val &= ~(MVNETA_GMAC_FORCE_LINK_PASS |
-             MVNETA_GMAC_FORCE_LINK_DOWN);
+             MVNETA_GMAC_FORCE_LINK_DOWN |
+             MVNETA_GMAC_AN_FLOW_CTRL_EN);
         val |= MVNETA_GMAC_INBAND_AN_ENABLE |
                MVNETA_GMAC_AN_SPEED_EN |
-               MVNETA_GMAC_AN_FLOW_CTRL_EN |
                MVNETA_GMAC_AN_DUPLEX_EN;
         mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG, val);
+        val = mvreg_read(pp, MVNETA_GMAC_CLOCK_DIVIDER);
+        val |= MVNETA_GMAC_1MS_CLOCK_ENABLE;
+        mvreg_write(pp, MVNETA_GMAC_CLOCK_DIVIDER, val);
     }
 
     mvneta_set_ucast_table(pp, -1);
@@ -2979,6 +2985,9 @@ static int mvneta_port_power_up(struct mvneta_port
*pp, int phy_mode)
         return -EINVAL;
     }
 
+    if (pp->inband_status)
+        ctrl |= MVNETA_GMAC2_INBAND_AN_ENABLE;
+
     /* Cancel Port Reset */
     ctrl &= ~MVNETA_GMAC2_PORT_RESET;
     mvreg_write(pp, MVNETA_GMAC_CTRL_2, ctrl);
-- 
1.7.9.5
