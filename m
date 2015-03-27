From: Stas Sergeev <stsp@list.ru>
Subject: [PATCH 6/6] mvneta: port marvell's official in-band status enabling
 procedure
Date: Fri, 27 Mar 2015 16:40:52 +0300
Message-ID: <55155DE4.5060701@list.ru>
References: <55155AFC.4050800@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55155AFC.4050800@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is a back-port of official marvell's patch.
It changes nothing visible for me but looks reasonable.
Hope people with access to marvell's specs can review and
justify this patch better.

CC: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
CC: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org

Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvneta.c |   13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 2d1c689..5dc7416 100644
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
@@ -185,6 +188,7 @@
 #define      MVNETA_GMAC_CONFIG_MII_SPEED        BIT(5)
 #define      MVNETA_GMAC_CONFIG_GMII_SPEED       BIT(6)
 #define      MVNETA_GMAC_AN_SPEED_EN             BIT(7)
+#define      MVNETA_GMAC_AN_FLOW_CTRL_EN         BIT(11)
 #define      MVNETA_GMAC_CONFIG_FULL_DUPLEX      BIT(12)
 #define      MVNETA_GMAC_AN_DUPLEX_EN            BIT(13)
 #define MVNETA_MIB_COUNTERS_BASE                 0x3080
@@ -1000,11 +1004,15 @@ static void mvneta_defaults_set(struct mvneta_port *pp)
 	if (pp->inband_status) {
 		val = mvreg_read(pp, MVNETA_GMAC_AUTONEG_CONFIG);
 		val &= ~(MVNETA_GMAC_FORCE_LINK_PASS |
-			 MVNETA_GMAC_FORCE_LINK_DOWN);
+			 MVNETA_GMAC_FORCE_LINK_DOWN |
+			 MVNETA_GMAC_AN_FLOW_CTRL_EN);
 		val |= MVNETA_GMAC_INBAND_AN_ENABLE |
 		       MVNETA_GMAC_AN_SPEED_EN |
 		       MVNETA_GMAC_AN_DUPLEX_EN;
 		mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG, val);
+		val = mvreg_read(pp, MVNETA_GMAC_CLOCK_DIVIDER);
+		val |= MVNETA_GMAC_1MS_CLOCK_ENABLE;
+		mvreg_write(pp, MVNETA_GMAC_CLOCK_DIVIDER, val);
 	}

 	mvneta_set_ucast_table(pp, -1);
@@ -2977,6 +2985,9 @@ static int mvneta_port_power_up(struct mvneta_port *pp, int phy_mode)
 		return -EINVAL;
 	}

+	if (pp->inband_status)
+		ctrl |= MVNETA_GMAC2_INBAND_AN_ENABLE;
+
 	/* Cancel Port Reset */
 	ctrl &= ~MVNETA_GMAC2_PORT_RESET;
 	mvreg_write(pp, MVNETA_GMAC_CTRL_2, ctrl);
-- 
1.7.9.5
