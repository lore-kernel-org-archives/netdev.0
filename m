From: John Crispin <john@phrozen.org>
Subject: [PATCH] net: dsa: mediatek: add adjust link support for user ports
Date: Mon,  7 Aug 2017 16:20:49 +0200
Message-ID: <20170807142049.4144-1-john@phrozen.org>
Cc: sean Wang <sean.wang@mediatek.com>,
        Ryder Lee <Ryder.Lee@mediatek.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
        John Crispin <john@phrozen.org>,
        Shashidhar Lakkavalli <shashidhar.lakkavalli@openmesh.com>,
        Muciri Gatimu <muciri@openmesh.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Manually adjust the port settings of user ports once PHY polling has
completed. This patch extends the adjust_link callback to configure the
per port PMCR register, applying the proper values polled from the PHY.
Without this patch flow control was not always getting setup properly.

Signed-off-by: Shashidhar Lakkavalli <shashidhar.lakkavalli@openmesh.com>
Signed-off-by: Muciri Gatimu <muciri@openmesh.com>
Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/dsa/mt7530.c | 38 ++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mt7530.h |  1 +
 2 files changed, 39 insertions(+)

diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index 1e46418a3b74..264b281eb86b 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -625,6 +625,44 @@ static void mt7530_adjust_link(struct dsa_switch *ds, int port,
 		 * all finished.
 		 */
 		mt7623_pad_clk_setup(ds);
+	} else {
+		u16 lcl_adv = 0, rmt_adv = 0;
+		u8 flowctrl;
+		u32 mcr = PMCR_USERP_LINK | PMCR_FORCE_MODE;
+
+		switch (phydev->speed) {
+		case SPEED_1000:
+			mcr |= PMCR_FORCE_SPEED_1000;
+			break;
+		case SPEED_100:
+			mcr |= PMCR_FORCE_SPEED_100;
+			break;
+		};
+
+		if (phydev->link)
+			mcr |= PMCR_FORCE_LNK;
+
+		if (phydev->duplex) {
+			mcr |= PMCR_FORCE_FDX;
+
+			if (phydev->pause)
+				rmt_adv = LPA_PAUSE_CAP;
+			if (phydev->asym_pause)
+				rmt_adv |= LPA_PAUSE_ASYM;
+
+			if (phydev->advertising & ADVERTISED_Pause)
+				lcl_adv |= ADVERTISE_PAUSE_CAP;
+			if (phydev->advertising & ADVERTISED_Asym_Pause)
+				lcl_adv |= ADVERTISE_PAUSE_ASYM;
+
+			flowctrl = mii_resolve_flowctrl_fdx(lcl_adv, rmt_adv);
+
+			if (flowctrl & FLOW_CTRL_TX)
+				mcr |= PMCR_TX_FC_EN;
+			if (flowctrl & FLOW_CTRL_RX)
+				mcr |= PMCR_RX_FC_EN;
+		}
+		mt7530_write(priv, MT7530_PMCR_P(port), mcr);
 	}
 }
 
diff --git a/drivers/net/dsa/mt7530.h b/drivers/net/dsa/mt7530.h
index b83d76b99802..74db9822eb40 100644
--- a/drivers/net/dsa/mt7530.h
+++ b/drivers/net/dsa/mt7530.h
@@ -151,6 +151,7 @@ enum mt7530_stp_state {
 #define  PMCR_TX_FC_EN			BIT(5)
 #define  PMCR_RX_FC_EN			BIT(4)
 #define  PMCR_FORCE_SPEED_1000		BIT(3)
+#define  PMCR_FORCE_SPEED_100		BIT(2)
 #define  PMCR_FORCE_FDX			BIT(1)
 #define  PMCR_FORCE_LNK			BIT(0)
 #define  PMCR_COMMON_LINK		(PMCR_IFG_XMIT(1) | PMCR_MAC_MODE | \
-- 
2.11.0
