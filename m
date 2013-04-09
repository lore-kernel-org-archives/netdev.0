From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 07/11] tg3: Add support for link flap avoidance
Date: Tue, 9 Apr 2013 11:48:07 -0700
Message-ID: <1365533291-5672-8-git-send-email-nsujir@broadcom.com>
References: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2274 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935016Ab3DISsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 14:48:53 -0400
In-Reply-To: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch and the following two patches add support for link flap avoidance
by maintaining the link on power down. This feature is required for
management capable devices to have the management connection
uninterrupted on driver reload, reboot and interface up/down.

The other pros of this feature are
 - It speeds up boot up time by several seconds as DHCP addresses can be
   acquired faster.
 - It avoids lengthy Spanning Tree delay.

On powerup the hardware brings up the phy with default settings. If the
link is not up, the management software configures the phy to gigabit
and starts autonegotiate. Subsequently, as long as the link is up, the
driver and management refrain from resetting and/or changing any
configuration that the link depends on.

The LNK_FLAP_AVOID setting is an NVRAM user configurable bit and is
disabled by default.  If this setting is enabled, we skip powering down
the phy and resetting it.

A second NVRAM setting is 1G_ON_VAUX_OK (off by default). This adds
support for gigabit link speed when device is on auxiliary power.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 63 +++++++++++++++++++++++++++++++------
 drivers/net/ethernet/broadcom/tg3.h |  4 +++
 2 files changed, 58 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index f53e309..594a2f9 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -2933,6 +2933,9 @@ static void tg3_power_down_phy(struct tg3 *tp, bool do_low_power)
 {
 	u32 val;
 
+	if (tp->phy_flags & TG3_PHYFLG_KEEP_LINK_ON_PWRDN)
+		return;
+
 	if (tp->phy_flags & TG3_PHYFLG_PHY_SERDES) {
 		if (tg3_asic_rev(tp) == ASIC_REV_5704) {
 			u32 sg_dig_ctrl = tr32(SG_DIG_CTRL);
@@ -3996,7 +3999,13 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 
 			if (tp->phy_flags & TG3_PHYFLG_MII_SERDES)
 				mac_mode = MAC_MODE_PORT_MODE_GMII;
-			else
+			else if (tp->phy_flags &
+				 TG3_PHYFLG_KEEP_LINK_ON_PWRDN) {
+				if (tp->link_config.active_speed == SPEED_1000)
+					mac_mode = MAC_MODE_PORT_MODE_GMII;
+				else
+					mac_mode = MAC_MODE_PORT_MODE_MII;
+			} else
 				mac_mode = MAC_MODE_PORT_MODE_MII;
 
 			mac_mode |= tp->mac_mode & MAC_MODE_LINK_POLARITY;
@@ -4250,12 +4259,16 @@ static void tg3_phy_copper_begin(struct tg3 *tp)
 	    (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER)) {
 		u32 adv, fc;
 
-		if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER) {
+		if ((tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER) &&
+		    !(tp->phy_flags & TG3_PHYFLG_KEEP_LINK_ON_PWRDN)) {
 			adv = ADVERTISED_10baseT_Half |
 			      ADVERTISED_10baseT_Full;
 			if (tg3_flag(tp, WOL_SPEED_100MB))
 				adv |= ADVERTISED_100baseT_Half |
 				       ADVERTISED_100baseT_Full;
+			if (tp->phy_flags & TG3_PHYFLG_1G_ON_VAUX_OK)
+				adv |= ADVERTISED_1000baseT_Half |
+				       ADVERTISED_1000baseT_Full;
 
 			fc = FLOW_CTRL_TX | FLOW_CTRL_RX;
 		} else {
@@ -4269,6 +4282,15 @@ static void tg3_phy_copper_begin(struct tg3 *tp)
 
 		tg3_phy_autoneg_cfg(tp, adv, fc);
 
+		if ((tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER) &&
+		    (tp->phy_flags & TG3_PHYFLG_KEEP_LINK_ON_PWRDN)) {
+			/* Normally during power down we want to autonegotiate
+			 * the lowest possible speed for WOL. However, to avoid
+			 * link flap, we leave it untouched.
+			 */
+			return;
+		}
+
 		tg3_writephy(tp, MII_BMCR,
 			     BMCR_ANENABLE | BMCR_ANRESTART);
 	} else {
@@ -8737,6 +8759,9 @@ static int tg3_chip_reset(struct tg3 *tp)
 
 	/* Reprobe ASF enable state.  */
 	tg3_flag_clear(tp, ENABLE_ASF);
+	tp->phy_flags &= ~(TG3_PHYFLG_1G_ON_VAUX_OK |
+			   TG3_PHYFLG_KEEP_LINK_ON_PWRDN);
+
 	tg3_flag_clear(tp, ASF_NEW_HANDSHAKE);
 	tg3_read_mem(tp, NIC_SRAM_DATA_SIG, &val);
 	if (val == NIC_SRAM_DATA_SIG_MAGIC) {
@@ -8748,6 +8773,12 @@ static int tg3_chip_reset(struct tg3 *tp)
 			tp->last_event_jiffies = jiffies;
 			if (tg3_flag(tp, 5750_PLUS))
 				tg3_flag_set(tp, ASF_NEW_HANDSHAKE);
+
+			tg3_read_mem(tp, NIC_SRAM_DATA_CFG_3, &nic_cfg);
+			if (nic_cfg & NIC_SRAM_1G_ON_VAUX_OK)
+				tp->phy_flags |= TG3_PHYFLG_1G_ON_VAUX_OK;
+			if (nic_cfg & NIC_SRAM_LNK_FLAP_AVOID)
+				tp->phy_flags |= TG3_PHYFLG_KEEP_LINK_ON_PWRDN;
 		}
 	}
 
@@ -11101,7 +11132,9 @@ static int tg3_open(struct net_device *dev)
 
 	tg3_full_unlock(tp);
 
-	err = tg3_start(tp, true, true, true);
+	err = tg3_start(tp,
+			!(tp->phy_flags & TG3_PHYFLG_KEEP_LINK_ON_PWRDN),
+			true, true);
 	if (err) {
 		tg3_frob_aux_power(tp, false);
 		pci_set_power_state(tp->pdev, PCI_D3hot);
@@ -14493,14 +14526,18 @@ static void tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 		    (cfg2 & NIC_SRAM_DATA_CFG_2_APD_EN))
 			tp->phy_flags |= TG3_PHYFLG_ENABLE_APD;
 
-		if (tg3_flag(tp, PCI_EXPRESS) &&
-		    tg3_asic_rev(tp) != ASIC_REV_5785 &&
-		    !tg3_flag(tp, 57765_PLUS)) {
+		if (tg3_flag(tp, PCI_EXPRESS)) {
 			u32 cfg3;
 
 			tg3_read_mem(tp, NIC_SRAM_DATA_CFG_3, &cfg3);
-			if (cfg3 & NIC_SRAM_ASPM_DEBOUNCE)
+			if (tg3_asic_rev(tp) != ASIC_REV_5785 &&
+			    !tg3_flag(tp, 57765_PLUS) &&
+			    (cfg3 & NIC_SRAM_ASPM_DEBOUNCE))
 				tg3_flag_set(tp, ASPM_WORKAROUND);
+			if (cfg3 & NIC_SRAM_LNK_FLAP_AVOID)
+				tp->phy_flags |= TG3_PHYFLG_KEEP_LINK_ON_PWRDN;
+			if (cfg3 & NIC_SRAM_1G_ON_VAUX_OK)
+				tp->phy_flags |= TG3_PHYFLG_1G_ON_VAUX_OK;
 		}
 
 		if (cfg4 & NIC_SRAM_RGMII_INBAND_DISABLE)
@@ -14654,6 +14691,12 @@ static int tg3_phy_probe(struct tg3 *tp)
 		}
 	}
 
+	if (!tg3_flag(tp, ENABLE_ASF) &&
+	    !(tp->phy_flags & TG3_PHYFLG_ANY_SERDES) &&
+	    !(tp->phy_flags & TG3_PHYFLG_10_100_ONLY))
+		tp->phy_flags &= ~(TG3_PHYFLG_1G_ON_VAUX_OK |
+				   TG3_PHYFLG_KEEP_LINK_ON_PWRDN);
+
 	if (tg3_flag(tp, USE_PHYLIB))
 		return tg3_phy_init(tp);
 
@@ -14729,7 +14772,8 @@ static int tg3_phy_probe(struct tg3 *tp)
 
 	tg3_phy_init_link_config(tp);
 
-	if (!(tp->phy_flags & TG3_PHYFLG_ANY_SERDES) &&
+	if (!(tp->phy_flags & TG3_PHYFLG_KEEP_LINK_ON_PWRDN) &&
+	    !(tp->phy_flags & TG3_PHYFLG_ANY_SERDES) &&
 	    !tg3_flag(tp, ENABLE_APE) &&
 	    !tg3_flag(tp, ENABLE_ASF)) {
 		u32 bmsr, dummy;
@@ -17296,7 +17340,8 @@ static int tg3_resume(struct device *device)
 	tg3_full_lock(tp, 0);
 
 	tg3_flag_set(tp, INIT_COMPLETE);
-	err = tg3_restart_hw(tp, 1);
+	err = tg3_restart_hw(tp,
+			     !(tp->phy_flags & TG3_PHYFLG_KEEP_LINK_ON_PWRDN));
 	if (err)
 		goto out;
 
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index fd00a38..150bfc7 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2198,6 +2198,8 @@
 
 #define NIC_SRAM_DATA_CFG_3		0x00000d3c
 #define  NIC_SRAM_ASPM_DEBOUNCE		 0x00000002
+#define  NIC_SRAM_LNK_FLAP_AVOID	 0x00400000
+#define  NIC_SRAM_1G_ON_VAUX_OK		 0x00800000
 
 #define NIC_SRAM_DATA_CFG_4		0x00000d60
 #define  NIC_SRAM_GMII_MODE		 0x00000002
@@ -3305,6 +3307,8 @@ struct tg3 {
 #define TG3_PHYFLG_SERDES_PREEMPHASIS	0x00010000
 #define TG3_PHYFLG_PARALLEL_DETECT	0x00020000
 #define TG3_PHYFLG_EEE_CAP		0x00040000
+#define TG3_PHYFLG_1G_ON_VAUX_OK	0x00080000
+#define TG3_PHYFLG_KEEP_LINK_ON_PWRDN	0x00100000
 #define TG3_PHYFLG_MDIX_STATE		0x00200000
 
 	u32				led_ctrl;
-- 
1.8.1.4
