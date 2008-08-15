From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 3/7] tg3: Preserve register settings for DASH
Date: Fri, 15 Aug 2008 13:58:25 -0700
Message-ID: <1218834765.6478@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3923 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751670AbYHOU1d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2008 16:27:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Broadcom's DASH (Desktop and mobile Architecture for System Hardware)
implementation requires that the driver preserve particular register
settings.  If the driver does not preserve them, communication with
the DASH firmware will be lost.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

---
 drivers/net/tg3.c |   26 ++++++++++++++++++++++++--
 drivers/net/tg3.h |    2 ++
 2 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 13640f1..0ebf2ff 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2126,6 +2126,13 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 		     (tp->tg3_flags & TG3_FLAG_WOL_ENABLE))
 			mac_mode |= MAC_MODE_MAGIC_PKT_ENABLE;
 
+		if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) {
+			mac_mode |= tp->mac_mode &
+				    (MAC_MODE_APE_TX_EN | MAC_MODE_APE_RX_EN);
+			if (mac_mode & MAC_MODE_APE_TX_EN)
+				mac_mode |= MAC_MODE_TDE_ENABLE;
+		}
+
 		tw32_f(MAC_MODE, mac_mode);
 		udelay(100);
 
@@ -5912,6 +5919,11 @@ static int tg3_chip_reset(struct tg3 *tp)
 	} else if (tp->tg3_flags2 & TG3_FLG2_MII_SERDES) {
 		tp->mac_mode = MAC_MODE_PORT_MODE_GMII;
 		tw32_f(MAC_MODE, tp->mac_mode);
+	} else if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) {
+		tp->mac_mode &= (MAC_MODE_APE_TX_EN | MAC_MODE_APE_RX_EN);
+		if (tp->mac_mode & MAC_MODE_APE_TX_EN)
+			tp->mac_mode |= MAC_MODE_TDE_ENABLE;
+		tw32_f(MAC_MODE, tp->mac_mode);
 	} else
 		tw32_f(MAC_MODE, 0);
 	udelay(40);
@@ -7412,7 +7424,11 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		udelay(10);
 	}
 
-	tp->mac_mode = MAC_MODE_TXSTAT_ENABLE | MAC_MODE_RXSTAT_ENABLE |
+	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)
+		tp->mac_mode &= MAC_MODE_APE_TX_EN | MAC_MODE_APE_RX_EN;
+	else
+		tp->mac_mode = 0;
+	tp->mac_mode |= MAC_MODE_TXSTAT_ENABLE | MAC_MODE_RXSTAT_ENABLE |
 		MAC_MODE_TDE_ENABLE | MAC_MODE_RDE_ENABLE | MAC_MODE_FHDE_ENABLE;
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) &&
 	    !(tp->tg3_flags2 & TG3_FLG2_PHY_SERDES) &&
@@ -12422,6 +12438,13 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 				       tp->misc_host_ctrl);
 	}
 
+	/* Preserve the APE MAC_MODE bits */
+	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)
+		tp->mac_mode = tr32(MAC_MODE) |
+			       MAC_MODE_APE_TX_EN | MAC_MODE_APE_RX_EN;
+	else
+		tp->mac_mode = TG3_DEF_MAC_MODE;
+
 	/* these are limited to 10/100 only */
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703 &&
 	     (grc_misc_cfg == 0x8000 || grc_misc_cfg == 0x4000)) ||
@@ -13281,7 +13304,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	tp->pdev = pdev;
 	tp->dev = dev;
 	tp->pm_cap = pm_cap;
-	tp->mac_mode = TG3_DEF_MAC_MODE;
 	tp->rx_mode = TG3_DEF_RX_MODE;
 	tp->tx_mode = TG3_DEF_TX_MODE;
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index dd1af50..3772349 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -325,6 +325,8 @@
 #define  MAC_MODE_TDE_ENABLE		 0x00200000
 #define  MAC_MODE_RDE_ENABLE		 0x00400000
 #define  MAC_MODE_FHDE_ENABLE		 0x00800000
+#define  MAC_MODE_APE_RX_EN		 0x08000000
+#define  MAC_MODE_APE_TX_EN		 0x10000000
 #define MAC_STATUS			0x00000404
 #define  MAC_STATUS_PCS_SYNCED		 0x00000001
 #define  MAC_STATUS_SIGNAL_DET		 0x00000002
-- 
1.5.6.4



