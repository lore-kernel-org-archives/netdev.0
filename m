From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 08/11] tg3: Pull the phy advertised speed and
 flow control settings on driver load
Date: Tue, 9 Apr 2013 11:48:08 -0700
Message-ID: <1365533291-5672-9-git-send-email-nsujir@broadcom.com>
References: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com,
	"Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2990 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934538Ab3DIStx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 14:49:53 -0400
In-Reply-To: <1365533291-5672-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Normally on driver load, we set the default settings for speed and flow
control. However, if the default setting is not compatible with the current link
state, we would autonegotiate and cause a link flap. To avoid this, we
pull the current advertised settings into the config.

A second scenario is if a user changes the speed/duplex/fc settings when
the interface is down. In this case we must not pull the settings from
the phy and overwrite user settings. We avoid that by checking the
USER_CONFIGURED flag.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 135 ++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/tg3.h |   1 +
 2 files changed, 136 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 594a2f9..face04f 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -1874,6 +1874,20 @@ static void tg3_link_report(struct tg3 *tp)
 	tp->link_up = netif_carrier_ok(tp->dev);
 }
 
+static u32 tg3_decode_flowctrl_1000T(u32 adv)
+{
+	u32 flowctrl = 0;
+
+	if (adv & ADVERTISE_PAUSE_CAP) {
+		flowctrl |= FLOW_CTRL_RX;
+		if (!(adv & ADVERTISE_PAUSE_ASYM))
+			flowctrl |= FLOW_CTRL_TX;
+	} else if (adv & ADVERTISE_PAUSE_ASYM)
+		flowctrl |= FLOW_CTRL_TX;
+
+	return flowctrl;
+}
+
 static u16 tg3_advert_flowctrl_1000X(u8 flow_ctrl)
 {
 	u16 miireg;
@@ -1890,6 +1904,20 @@ static u16 tg3_advert_flowctrl_1000X(u8 flow_ctrl)
 	return miireg;
 }
 
+static u32 tg3_decode_flowctrl_1000X(u32 adv)
+{
+	u32 flowctrl = 0;
+
+	if (adv & ADVERTISE_1000XPAUSE) {
+		flowctrl |= FLOW_CTRL_RX;
+		if (!(adv & ADVERTISE_1000XPSE_ASYM))
+			flowctrl |= FLOW_CTRL_TX;
+	} else if (adv & ADVERTISE_1000XPSE_ASYM)
+		flowctrl |= FLOW_CTRL_TX;
+
+	return flowctrl;
+}
+
 static u8 tg3_resolve_flowctrl_1000X(u16 lcladv, u16 rmtadv)
 {
 	u8 cap = 0;
@@ -4347,6 +4375,103 @@ static void tg3_phy_copper_begin(struct tg3 *tp)
 	}
 }
 
+static int tg3_phy_pull_config(struct tg3 *tp)
+{
+	int err;
+	u32 val;
+
+	err = tg3_readphy(tp, MII_BMCR, &val);
+	if (err)
+		goto done;
+
+	if (!(val & BMCR_ANENABLE)) {
+		tp->link_config.autoneg = AUTONEG_DISABLE;
+		tp->link_config.advertising = 0;
+		tg3_flag_clear(tp, PAUSE_AUTONEG);
+
+		err = -EIO;
+
+		switch (val & (BMCR_SPEED1000 | BMCR_SPEED100)) {
+		case 0:
+			if (tp->phy_flags & TG3_PHYFLG_ANY_SERDES)
+				goto done;
+
+			tp->link_config.speed = SPEED_10;
+			break;
+		case BMCR_SPEED100:
+			if (tp->phy_flags & TG3_PHYFLG_ANY_SERDES)
+				goto done;
+
+			tp->link_config.speed = SPEED_100;
+			break;
+		case BMCR_SPEED1000:
+			if (!(tp->phy_flags & TG3_PHYFLG_10_100_ONLY)) {
+				tp->link_config.speed = SPEED_1000;
+				break;
+			}
+			/* Fall through */
+		default:
+			goto done;
+		}
+
+		if (val & BMCR_FULLDPLX)
+			tp->link_config.duplex = DUPLEX_FULL;
+		else
+			tp->link_config.duplex = DUPLEX_HALF;
+
+		tp->link_config.flowctrl = FLOW_CTRL_RX | FLOW_CTRL_TX;
+
+		err = 0;
+		goto done;
+	}
+
+	tp->link_config.autoneg = AUTONEG_ENABLE;
+	tp->link_config.advertising = ADVERTISED_Autoneg;
+	tg3_flag_set(tp, PAUSE_AUTONEG);
+
+	if (!(tp->phy_flags & TG3_PHYFLG_ANY_SERDES)) {
+		u32 adv;
+
+		err = tg3_readphy(tp, MII_ADVERTISE, &val);
+		if (err)
+			goto done;
+
+		adv = mii_adv_to_ethtool_adv_t(val & ADVERTISE_ALL);
+		tp->link_config.advertising |= adv | ADVERTISED_TP;
+
+		tp->link_config.flowctrl = tg3_decode_flowctrl_1000T(val);
+	} else {
+		tp->link_config.advertising |= ADVERTISED_FIBRE;
+	}
+
+	if (!(tp->phy_flags & TG3_PHYFLG_10_100_ONLY)) {
+		u32 adv;
+
+		if (!(tp->phy_flags & TG3_PHYFLG_ANY_SERDES)) {
+			err = tg3_readphy(tp, MII_CTRL1000, &val);
+			if (err)
+				goto done;
+
+			adv = mii_ctrl1000_to_ethtool_adv_t(val);
+		} else {
+			err = tg3_readphy(tp, MII_ADVERTISE, &val);
+			if (err)
+				goto done;
+
+			adv = tg3_decode_flowctrl_1000X(val);
+			tp->link_config.flowctrl = adv;
+
+			val &= (ADVERTISE_1000XHALF | ADVERTISE_1000XFULL);
+			adv = mii_adv_to_ethtool_adv_x(val);
+		}
+
+		tp->link_config.advertising |= adv;
+	}
+
+done:
+	return err;
+}
+
 static int tg3_init_5401phy_dsp(struct tg3 *tp)
 {
 	int err;
@@ -9313,6 +9438,12 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		       TG3_CPMU_DBTMR2_TXIDXEQ_2047US);
 	}
 
+	if ((tp->phy_flags & TG3_PHYFLG_KEEP_LINK_ON_PWRDN) &&
+	    !(tp->phy_flags & TG3_PHYFLG_USER_CONFIGURED)) {
+		tg3_phy_pull_config(tp);
+		tp->phy_flags |= TG3_PHYFLG_USER_CONFIGURED;
+	}
+
 	if (reset_phy)
 		tg3_phy_reset(tp);
 
@@ -11640,6 +11771,8 @@ static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		tp->link_config.duplex = cmd->duplex;
 	}
 
+	tp->phy_flags |= TG3_PHYFLG_USER_CONFIGURED;
+
 	tg3_warn_mgmt_link_flap(tp);
 
 	if (netif_running(dev))
@@ -11931,6 +12064,8 @@ static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam
 		tg3_full_unlock(tp);
 	}
 
+	tp->phy_flags |= TG3_PHYFLG_USER_CONFIGURED;
+
 	return err;
 }
 
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 150bfc7..9b2d3ac 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -3290,6 +3290,7 @@ struct tg3 {
 #define TG3_PHYFLG_IS_LOW_POWER		0x00000001
 #define TG3_PHYFLG_IS_CONNECTED		0x00000002
 #define TG3_PHYFLG_USE_MI_INTERRUPT	0x00000004
+#define TG3_PHYFLG_USER_CONFIGURED	0x00000008
 #define TG3_PHYFLG_PHY_SERDES		0x00000010
 #define TG3_PHYFLG_MII_SERDES		0x00000020
 #define TG3_PHYFLG_ANY_SERDES		(TG3_PHYFLG_PHY_SERDES |	\
-- 
1.8.1.4
