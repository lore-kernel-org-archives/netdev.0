From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 6/7] tg3: Move tg3_init_link_config to tg3_phy_probe
Date: Wed, 9 Mar 2011 18:58:24 -0800
Message-ID: <1299725905-8498-7-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, stable@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2002 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752215Ab1CJC6q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 21:58:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the function that initializes the link configuration
closer to the place where the rest of the phy code is initialized.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   69 +++++++++++++++++++++++++++--------------------------
 1 files changed, 35 insertions(+), 34 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 159eb23..2c67cc9 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12557,12 +12557,45 @@ static u32 __devinit tg3_read_otp_phycfg(struct tg3 *tp)
 	return ((thalf_otp & 0x0000ffff) << 16) | (bhalf_otp >> 16);
 }
 
+static void __devinit tg3_phy_init_link_config(struct tg3 *tp)
+{
+	u32 adv = ADVERTISED_Autoneg |
+		  ADVERTISED_Pause;
+
+	if (!(tp->phy_flags & TG3_PHYFLG_10_100_ONLY))
+		adv |= ADVERTISED_1000baseT_Half |
+		       ADVERTISED_1000baseT_Full;
+
+	if (!(tp->phy_flags & TG3_PHYFLG_ANY_SERDES))
+		adv |= ADVERTISED_100baseT_Half |
+		       ADVERTISED_100baseT_Full |
+		       ADVERTISED_10baseT_Half |
+		       ADVERTISED_10baseT_Full |
+		       ADVERTISED_TP;
+	else
+		adv |= ADVERTISED_FIBRE;
+
+	tp->link_config.advertising = adv;
+	tp->link_config.speed = SPEED_INVALID;
+	tp->link_config.duplex = DUPLEX_INVALID;
+	tp->link_config.autoneg = AUTONEG_ENABLE;
+	tp->link_config.active_speed = SPEED_INVALID;
+	tp->link_config.active_duplex = DUPLEX_INVALID;
+	tp->link_config.orig_speed = SPEED_INVALID;
+	tp->link_config.orig_duplex = DUPLEX_INVALID;
+	tp->link_config.orig_autoneg = AUTONEG_INVALID;
+}
+
 static int __devinit tg3_phy_probe(struct tg3 *tp)
 {
 	u32 hw_phy_id_1, hw_phy_id_2;
 	u32 hw_phy_id, hw_phy_id_masked;
 	int err;
 
+	/* flow control autonegotiation is default behavior */
+	tp->tg3_flags |= TG3_FLAG_PAUSE_AUTONEG;
+	tp->link_config.flowctrl = FLOW_CTRL_TX | FLOW_CTRL_RX;
+
 	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB)
 		return tg3_phy_init(tp);
 
@@ -12624,6 +12657,8 @@ static int __devinit tg3_phy_probe(struct tg3 *tp)
 	      tp->pci_chip_rev_id != CHIPREV_ID_57765_A0)))
 		tp->phy_flags |= TG3_PHYFLG_EEE_CAP;
 
+	tg3_phy_init_link_config(tp);
+
 	if (!(tp->phy_flags & TG3_PHYFLG_ANY_SERDES) &&
 	    !(tp->tg3_flags3 & TG3_FLG3_ENABLE_APE) &&
 	    !(tp->tg3_flags & TG3_FLAG_ENABLE_ASF)) {
@@ -12679,17 +12714,6 @@ skip_phy_reset:
 		err = tg3_init_5401phy_dsp(tp);
 	}
 
-	if (tp->phy_flags & TG3_PHYFLG_ANY_SERDES)
-		tp->link_config.advertising =
-			(ADVERTISED_1000baseT_Half |
-			 ADVERTISED_1000baseT_Full |
-			 ADVERTISED_Autoneg |
-			 ADVERTISED_FIBRE);
-	if (tp->phy_flags & TG3_PHYFLG_10_100_ONLY)
-		tp->link_config.advertising &=
-			~(ADVERTISED_1000baseT_Half |
-			  ADVERTISED_1000baseT_Full);
-
 	return err;
 }
 
@@ -14422,23 +14446,6 @@ out_nofree:
 	return ret;
 }
 
-static void __devinit tg3_init_link_config(struct tg3 *tp)
-{
-	tp->link_config.advertising =
-		(ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full |
-		 ADVERTISED_100baseT_Half | ADVERTISED_100baseT_Full |
-		 ADVERTISED_1000baseT_Half | ADVERTISED_1000baseT_Full |
-		 ADVERTISED_Autoneg | ADVERTISED_MII);
-	tp->link_config.speed = SPEED_INVALID;
-	tp->link_config.duplex = DUPLEX_INVALID;
-	tp->link_config.autoneg = AUTONEG_ENABLE;
-	tp->link_config.active_speed = SPEED_INVALID;
-	tp->link_config.active_duplex = DUPLEX_INVALID;
-	tp->link_config.orig_speed = SPEED_INVALID;
-	tp->link_config.orig_duplex = DUPLEX_INVALID;
-	tp->link_config.orig_autoneg = AUTONEG_INVALID;
-}
-
 static void __devinit tg3_init_bufmgr_config(struct tg3 *tp)
 {
 	if (tp->tg3_flags3 & TG3_FLG3_5717_PLUS) {
@@ -14742,8 +14749,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		goto err_out_free_dev;
 	}
 
-	tg3_init_link_config(tp);
-
 	tp->rx_pending = TG3_DEF_RX_RING_PENDING;
 	tp->rx_jumbo_pending = TG3_DEF_RX_JUMBO_RING_PENDING;
 
@@ -14891,10 +14896,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		goto err_out_apeunmap;
 	}
 
-	/* flow control autonegotiation is default behavior */
-	tp->tg3_flags |= TG3_FLAG_PAUSE_AUTONEG;
-	tp->link_config.flowctrl = FLOW_CTRL_TX | FLOW_CTRL_RX;
-
 	intmbx = MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW;
 	rcvmbx = MAILBOX_RCVRET_CON_IDX_0 + TG3_64BIT_REG_LOW;
 	sndmbx = MAILBOX_SNDHOST_PROD_IDX_0 + TG3_64BIT_REG_LOW;
-- 
1.7.3.4


