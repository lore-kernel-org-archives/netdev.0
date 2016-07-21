From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH] cxgb4/cxgb4vf: Add link mode mask API to cxgb4 and cxgb4vf
Date: Thu, 21 Jul 2016 20:19:18 +0530
Message-ID: <1469112558-8850-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <leedom@chelsio.com>,
	<nirranjan@chelsio.com>, <hariprasad@chelsio.com>,
	<linteam@chelsio.com>, Ganesh Goudar <ganeshgr@chelsio.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.32.117.8] ([12.32.117.8]:49173 "EHLO stargate.chelsio.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752618AbcGUOuJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jul 2016 10:50:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 375 ++++++++++++++-------
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |   2 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |  24 +-
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    | 276 +++++++++------
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |   1 +
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |   3 +
 7 files changed, 446 insertions(+), 236 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index b4fceb9..2e2aa9f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -418,6 +418,7 @@ struct trace_params {
 struct link_config {
 	unsigned short supported;        /* link capabilities */
 	unsigned short advertising;      /* advertised capabilities */
+	unsigned short lp_advertising;   /* peer advertised capabilities */
 	unsigned short requested_speed;  /* speed user has requested */
 	unsigned short speed;            /* actual link speed */
 	unsigned char  requested_fc;     /* flow control user has requested */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
index 7a0b92b..02f80fe 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
@@ -480,178 +480,293 @@ static int identify_port(struct net_device *dev,
 	return t4_identify_port(adap, adap->pf, netdev2pinfo(dev)->viid, val);
 }
 
-static unsigned int from_fw_linkcaps(enum fw_port_type type, unsigned int caps)
+/**
+ *	from_fw_port_mod_type - translate Firmware Port/Module type to Ethtool
+ *	@port_type: Firmware Port Type
+ *	@mod_type: Firmware Module Type
+ *
+ *	Translate Firmware Port/Module type to Ethtool Port Type.
+ */
+static int from_fw_port_mod_type(enum fw_port_type port_type,
+				 enum fw_port_module_type mod_type)
 {
-	unsigned int v = 0;
-
-	if (type == FW_PORT_TYPE_BT_SGMII || type == FW_PORT_TYPE_BT_XFI ||
-	    type == FW_PORT_TYPE_BT_XAUI) {
-		v |= SUPPORTED_TP;
-		if (caps & FW_PORT_CAP_SPEED_100M)
-			v |= SUPPORTED_100baseT_Full;
-		if (caps & FW_PORT_CAP_SPEED_1G)
-			v |= SUPPORTED_1000baseT_Full;
-		if (caps & FW_PORT_CAP_SPEED_10G)
-			v |= SUPPORTED_10000baseT_Full;
-	} else if (type == FW_PORT_TYPE_KX4 || type == FW_PORT_TYPE_KX) {
-		v |= SUPPORTED_Backplane;
-		if (caps & FW_PORT_CAP_SPEED_1G)
-			v |= SUPPORTED_1000baseKX_Full;
-		if (caps & FW_PORT_CAP_SPEED_10G)
-			v |= SUPPORTED_10000baseKX4_Full;
-	} else if (type == FW_PORT_TYPE_KR) {
-		v |= SUPPORTED_Backplane | SUPPORTED_10000baseKR_Full;
-	} else if (type == FW_PORT_TYPE_BP_AP) {
-		v |= SUPPORTED_Backplane | SUPPORTED_10000baseR_FEC |
-		     SUPPORTED_10000baseKR_Full | SUPPORTED_1000baseKX_Full;
-	} else if (type == FW_PORT_TYPE_BP4_AP) {
-		v |= SUPPORTED_Backplane | SUPPORTED_10000baseR_FEC |
-		     SUPPORTED_10000baseKR_Full | SUPPORTED_1000baseKX_Full |
-		     SUPPORTED_10000baseKX4_Full;
-	} else if (type == FW_PORT_TYPE_FIBER_XFI ||
-		   type == FW_PORT_TYPE_FIBER_XAUI ||
-		   type == FW_PORT_TYPE_SFP ||
-		   type == FW_PORT_TYPE_QSFP_10G ||
-		   type == FW_PORT_TYPE_QSA) {
-		v |= SUPPORTED_FIBRE;
-		if (caps & FW_PORT_CAP_SPEED_1G)
-			v |= SUPPORTED_1000baseT_Full;
-		if (caps & FW_PORT_CAP_SPEED_10G)
-			v |= SUPPORTED_10000baseT_Full;
-	} else if (type == FW_PORT_TYPE_BP40_BA ||
-		   type == FW_PORT_TYPE_QSFP) {
-		v |= SUPPORTED_40000baseSR4_Full;
-		v |= SUPPORTED_FIBRE;
+	if (port_type == FW_PORT_TYPE_BT_SGMII ||
+	    port_type == FW_PORT_TYPE_BT_XFI ||
+	    port_type == FW_PORT_TYPE_BT_XAUI) {
+		return PORT_TP;
+	} else if (port_type == FW_PORT_TYPE_FIBER_XFI ||
+		   port_type == FW_PORT_TYPE_FIBER_XAUI) {
+		return PORT_FIBRE;
+	} else if (port_type == FW_PORT_TYPE_SFP ||
+		   port_type == FW_PORT_TYPE_QSFP_10G ||
+		   port_type == FW_PORT_TYPE_QSA ||
+		   port_type == FW_PORT_TYPE_QSFP) {
+		if (mod_type == FW_PORT_MOD_TYPE_LR ||
+		    mod_type == FW_PORT_MOD_TYPE_SR ||
+		    mod_type == FW_PORT_MOD_TYPE_ER ||
+		    mod_type == FW_PORT_MOD_TYPE_LRM)
+			return PORT_FIBRE;
+		else if (mod_type == FW_PORT_MOD_TYPE_TWINAX_PASSIVE ||
+			 mod_type == FW_PORT_MOD_TYPE_TWINAX_ACTIVE)
+			return PORT_DA;
+		else
+			return PORT_OTHER;
 	}
 
-	if (caps & FW_PORT_CAP_ANEG)
-		v |= SUPPORTED_Autoneg;
-	return v;
+	return PORT_OTHER;
 }
 
-static unsigned int to_fw_linkcaps(unsigned int caps)
+/**
+ *	speed_to_fw_caps - translate Port Speed to Firmware Port Capabilities
+ *	@speed: speed in Kb/s
+ *
+ *	Translates a specific Port Speed into a Firmware Port Capabilities
+ *	value.
+ */
+static unsigned int speed_to_fw_caps(int speed)
 {
-	unsigned int v = 0;
-
-	if (caps & ADVERTISED_100baseT_Full)
-		v |= FW_PORT_CAP_SPEED_100M;
-	if (caps & ADVERTISED_1000baseT_Full)
-		v |= FW_PORT_CAP_SPEED_1G;
-	if (caps & ADVERTISED_10000baseT_Full)
-		v |= FW_PORT_CAP_SPEED_10G;
-	if (caps & ADVERTISED_40000baseSR4_Full)
-		v |= FW_PORT_CAP_SPEED_40G;
-	return v;
+	if (speed == 100)
+		return FW_PORT_CAP_SPEED_100M;
+	if (speed == 1000)
+		return FW_PORT_CAP_SPEED_1G;
+	if (speed == 10000)
+		return FW_PORT_CAP_SPEED_10G;
+	if (speed == 25000)
+		return FW_PORT_CAP_SPEED_25G;
+	if (speed == 40000)
+		return FW_PORT_CAP_SPEED_40G;
+	if (speed == 100000)
+		return FW_PORT_CAP_SPEED_100G;
+	return 0;
 }
 
-static int get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+/**
+ *	fw_caps_to_lmm - translate Firmware to ethtool Link Mode Mask
+ *	@port_type: Firmware Port Type
+ *	@fw_caps: Firmware Port Capabilities
+ *	@link_mode_mask: ethtool Link Mode Mask
+ *
+ *	Translate a Firmware Port Capabilities specification to an ethtool
+ *	Link Mode Mask.
+ */
+static void fw_caps_to_lmm(enum fw_port_type port_type,
+			   unsigned int fw_caps,
+			   unsigned long *link_mode_mask)
 {
-	const struct port_info *p = netdev_priv(dev);
-
-	if (p->port_type == FW_PORT_TYPE_BT_SGMII ||
-	    p->port_type == FW_PORT_TYPE_BT_XFI ||
-	    p->port_type == FW_PORT_TYPE_BT_XAUI) {
-		cmd->port = PORT_TP;
-	} else if (p->port_type == FW_PORT_TYPE_FIBER_XFI ||
-		   p->port_type == FW_PORT_TYPE_FIBER_XAUI) {
-		cmd->port = PORT_FIBRE;
-	} else if (p->port_type == FW_PORT_TYPE_SFP ||
-		   p->port_type == FW_PORT_TYPE_QSFP_10G ||
-		   p->port_type == FW_PORT_TYPE_QSA ||
-		   p->port_type == FW_PORT_TYPE_QSFP) {
-		if (p->mod_type == FW_PORT_MOD_TYPE_LR ||
-		    p->mod_type == FW_PORT_MOD_TYPE_SR ||
-		    p->mod_type == FW_PORT_MOD_TYPE_ER ||
-		    p->mod_type == FW_PORT_MOD_TYPE_LRM)
-			cmd->port = PORT_FIBRE;
-		else if (p->mod_type == FW_PORT_MOD_TYPE_TWINAX_PASSIVE ||
-			 p->mod_type == FW_PORT_MOD_TYPE_TWINAX_ACTIVE)
-			cmd->port = PORT_DA;
-		else
-			cmd->port = PORT_OTHER;
+	#define SET_LMM(__lmm_name) __set_bit(ETHTOOL_LINK_MODE_ ## __lmm_name \
+					## _BIT, link_mode_mask)
+
+	#define FW_CAPS_TO_LMM(__fw_name, __lmm_name) \
+		do { \
+			if (fw_caps & FW_PORT_CAP_ ## __fw_name) \
+				SET_LMM(__lmm_name); \
+		} while (0)
+
+	switch (port_type) {
+	case FW_PORT_TYPE_BT_SGMII:
+	case FW_PORT_TYPE_BT_XFI:
+	case FW_PORT_TYPE_BT_XAUI:
+		SET_LMM(TP);
+		FW_CAPS_TO_LMM(SPEED_100M, 100baseT_Full);
+		FW_CAPS_TO_LMM(SPEED_1G, 1000baseT_Full);
+		FW_CAPS_TO_LMM(SPEED_10G, 10000baseT_Full);
+		break;
+
+	case FW_PORT_TYPE_KX4:
+	case FW_PORT_TYPE_KX:
+		SET_LMM(Backplane);
+		FW_CAPS_TO_LMM(SPEED_1G, 1000baseKX_Full);
+		FW_CAPS_TO_LMM(SPEED_10G, 10000baseKX4_Full);
+		break;
+
+	case FW_PORT_TYPE_KR:
+		SET_LMM(Backplane);
+		SET_LMM(10000baseKR_Full);
+		break;
+
+	case FW_PORT_TYPE_BP_AP:
+		SET_LMM(Backplane);
+		SET_LMM(10000baseR_FEC);
+		SET_LMM(10000baseKR_Full);
+		SET_LMM(1000baseKX_Full);
+		break;
+
+	case FW_PORT_TYPE_BP4_AP:
+		SET_LMM(Backplane);
+		SET_LMM(10000baseR_FEC);
+		SET_LMM(10000baseKR_Full);
+		SET_LMM(1000baseKX_Full);
+		SET_LMM(10000baseKX4_Full);
+		break;
+
+	case FW_PORT_TYPE_FIBER_XFI:
+	case FW_PORT_TYPE_FIBER_XAUI:
+	case FW_PORT_TYPE_SFP:
+	case FW_PORT_TYPE_QSFP_10G:
+	case FW_PORT_TYPE_QSA:
+		SET_LMM(FIBRE);
+		FW_CAPS_TO_LMM(SPEED_1G, 1000baseT_Full);
+		FW_CAPS_TO_LMM(SPEED_10G, 10000baseT_Full);
+		break;
+
+	case FW_PORT_TYPE_BP40_BA:
+	case FW_PORT_TYPE_QSFP:
+		SET_LMM(FIBRE);
+		SET_LMM(40000baseSR4_Full);
+		break;
+
+	case FW_PORT_TYPE_CR_QSFP:
+	case FW_PORT_TYPE_SFP28:
+		SET_LMM(FIBRE);
+		SET_LMM(25000baseCR_Full);
+		break;
+
+	case FW_PORT_TYPE_KR4_100G:
+	case FW_PORT_TYPE_CR4_QSFP:
+		SET_LMM(FIBRE);
+		SET_LMM(100000baseCR4_Full);
+		break;
+
+	default:
+		break;
+	}
+
+	FW_CAPS_TO_LMM(ANEG, Autoneg);
+	FW_CAPS_TO_LMM(802_3_PAUSE, Pause);
+	FW_CAPS_TO_LMM(802_3_ASM_DIR, Asym_Pause);
+
+	#undef FW_CAPS_TO_LMM
+	#undef SET_LMM
+}
+
+/**
+ *	lmm_to_fw_caps - translate ethtool Link Mode Mask to Firmware
+ *	capabilities
+ *
+ *	@link_mode_mask: ethtool Link Mode Mask
+ *
+ *	Translate ethtool Link Mode Mask into a Firmware Port capabilities
+ *	value.
+ */
+static unsigned int lmm_to_fw_caps(const unsigned long *link_mode_mask)
+{
+	unsigned int fw_caps = 0;
+
+	#define LMM_TO_FW_CAPS(__lmm_name, __fw_name) \
+		do { \
+			if (test_bit(ETHTOOL_LINK_MODE_ ## __lmm_name ## _BIT, \
+				     link_mode_mask)) \
+				fw_caps |= FW_PORT_CAP_ ## __fw_name; \
+		} while (0)
+
+	LMM_TO_FW_CAPS(100baseT_Full, SPEED_100M);
+	LMM_TO_FW_CAPS(1000baseT_Full, SPEED_1G);
+	LMM_TO_FW_CAPS(10000baseT_Full, SPEED_10G);
+	LMM_TO_FW_CAPS(40000baseSR4_Full, SPEED_40G);
+	LMM_TO_FW_CAPS(25000baseCR_Full, SPEED_25G);
+	LMM_TO_FW_CAPS(100000baseCR4_Full, SPEED_100G);
+
+	#undef LMM_TO_FW_CAPS
+
+	return fw_caps;
+}
+
+static int get_link_ksettings(struct net_device *dev,
+			      struct ethtool_link_ksettings *link_ksettings)
+{
+	const struct port_info *pi = netdev_priv(dev);
+	struct ethtool_link_settings *base = &link_ksettings->base;
+
+	ethtool_link_ksettings_zero_link_mode(link_ksettings, supported);
+	ethtool_link_ksettings_zero_link_mode(link_ksettings, advertising);
+	ethtool_link_ksettings_zero_link_mode(link_ksettings, lp_advertising);
+
+	base->port = from_fw_port_mod_type(pi->port_type, pi->mod_type);
+
+	if (pi->mdio_addr >= 0) {
+		base->phy_address = pi->mdio_addr;
+		base->mdio_support = (pi->port_type == FW_PORT_TYPE_BT_SGMII
+				      ? ETH_MDIO_SUPPORTS_C22
+				      : ETH_MDIO_SUPPORTS_C45);
 	} else {
-		cmd->port = PORT_OTHER;
+		base->phy_address = 255;
+		base->mdio_support = 0;
 	}
 
-	if (p->mdio_addr >= 0) {
-		cmd->phy_address = p->mdio_addr;
-		cmd->transceiver = XCVR_EXTERNAL;
-		cmd->mdio_support = p->port_type == FW_PORT_TYPE_BT_SGMII ?
-			MDIO_SUPPORTS_C22 : MDIO_SUPPORTS_C45;
+	fw_caps_to_lmm(pi->port_type, pi->link_cfg.supported,
+		       link_ksettings->link_modes.supported);
+	fw_caps_to_lmm(pi->port_type, pi->link_cfg.advertising,
+		       link_ksettings->link_modes.advertising);
+	fw_caps_to_lmm(pi->port_type, pi->link_cfg.lp_advertising,
+		       link_ksettings->link_modes.lp_advertising);
+
+	if (netif_carrier_ok(dev)) {
+		base->speed = pi->link_cfg.speed;
+		base->duplex = DUPLEX_FULL;
 	} else {
-		cmd->phy_address = 0;  /* not really, but no better option */
-		cmd->transceiver = XCVR_INTERNAL;
-		cmd->mdio_support = 0;
+		base->speed = SPEED_UNKNOWN;
+		base->duplex = DUPLEX_UNKNOWN;
 	}
 
-	cmd->supported = from_fw_linkcaps(p->port_type, p->link_cfg.supported);
-	cmd->advertising = from_fw_linkcaps(p->port_type,
-					    p->link_cfg.advertising);
-	ethtool_cmd_speed_set(cmd,
-			      netif_carrier_ok(dev) ? p->link_cfg.speed : 0);
-	cmd->duplex = DUPLEX_FULL;
-	cmd->autoneg = p->link_cfg.autoneg;
-	cmd->maxtxpkt = 0;
-	cmd->maxrxpkt = 0;
-	return 0;
-}
+	base->autoneg = pi->link_cfg.autoneg;
+	if (pi->link_cfg.supported & FW_PORT_CAP_ANEG)
+		ethtool_link_ksettings_add_link_mode(link_ksettings,
+						     supported, Autoneg);
+	if (pi->link_cfg.autoneg)
+		ethtool_link_ksettings_add_link_mode(link_ksettings,
+						     advertising, Autoneg);
 
-static unsigned int speed_to_caps(int speed)
-{
-	if (speed == 100)
-		return FW_PORT_CAP_SPEED_100M;
-	if (speed == 1000)
-		return FW_PORT_CAP_SPEED_1G;
-	if (speed == 10000)
-		return FW_PORT_CAP_SPEED_10G;
-	if (speed == 40000)
-		return FW_PORT_CAP_SPEED_40G;
 	return 0;
 }
 
-static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int set_link_ksettings(struct net_device *dev,
+			      const struct ethtool_link_ksettings
+						*link_ksettings)
 {
-	unsigned int cap;
-	struct port_info *p = netdev_priv(dev);
-	struct link_config *lc = &p->link_cfg;
-	u32 speed = ethtool_cmd_speed(cmd);
+	struct port_info *pi = netdev_priv(dev);
+	struct link_config *lc = &pi->link_cfg;
+	const struct ethtool_link_settings *base = &link_ksettings->base;
 	struct link_config old_lc;
-	int ret;
+	unsigned int fw_caps;
+	int ret = 0;
 
-	if (cmd->duplex != DUPLEX_FULL)     /* only full-duplex supported */
+	/* only full-duplex supported */
+	if (base->duplex != DUPLEX_FULL)
 		return -EINVAL;
 
 	if (!(lc->supported & FW_PORT_CAP_ANEG)) {
 		/* PHY offers a single speed.  See if that's what's
 		 * being requested.
 		 */
-		if (cmd->autoneg == AUTONEG_DISABLE &&
-		    (lc->supported & speed_to_caps(speed)))
+		if (base->autoneg == AUTONEG_DISABLE &&
+		    (lc->supported & speed_to_fw_caps(base->speed)))
 			return 0;
 		return -EINVAL;
 	}
 
 	old_lc = *lc;
-	if (cmd->autoneg == AUTONEG_DISABLE) {
-		cap = speed_to_caps(speed);
+	if (base->autoneg == AUTONEG_DISABLE) {
+		fw_caps = speed_to_fw_caps(base->speed);
 
-		if (!(lc->supported & cap))
+		if (!(lc->supported & fw_caps))
 			return -EINVAL;
-		lc->requested_speed = cap;
+		lc->requested_speed = fw_caps;
 		lc->advertising = 0;
 	} else {
-		cap = to_fw_linkcaps(cmd->advertising);
-		if (!(lc->supported & cap))
+		fw_caps =
+			lmm_to_fw_caps(link_ksettings->link_modes.advertising);
+
+		if (!(lc->supported & fw_caps))
 			return -EINVAL;
 		lc->requested_speed = 0;
-		lc->advertising = cap | FW_PORT_CAP_ANEG;
+		lc->advertising = fw_caps | FW_PORT_CAP_ANEG;
 	}
-	lc->autoneg = cmd->autoneg;
+	lc->autoneg = base->autoneg;
 
 	/* If the firmware rejects the Link Configuration request, back out
 	 * the changes and report the error.
 	 */
-	ret = t4_link_l1cfg(p->adapter, p->adapter->mbox, p->tx_chan, lc);
+	ret = t4_link_l1cfg(pi->adapter, pi->adapter->mbox, pi->tx_chan, lc);
 	if (ret)
 		*lc = old_lc;
 
@@ -1093,8 +1208,8 @@ static int get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
 }
 
 static const struct ethtool_ops cxgb_ethtool_ops = {
-	.get_settings      = get_settings,
-	.set_settings      = set_settings,
+	.get_link_ksettings = get_link_ksettings,
+	.set_link_ksettings = set_link_ksettings,
 	.get_drvinfo       = get_drvinfo,
 	.get_msglevel      = get_msglevel,
 	.set_msglevel      = set_msglevel,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index a63addb..dc92c80 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -7219,6 +7219,7 @@ void t4_handle_get_port_info(struct port_info *pi, const __be64 *rpl)
 		lc->speed = speed;
 		lc->fc = fc;
 		lc->supported = be16_to_cpu(p->u.info.pcap);
+		lc->lp_advertising = be16_to_cpu(p->u.info.lpacap);
 		t4_os_link_changed(adap, pi->port_id, link_ok);
 	}
 }
@@ -7284,6 +7285,7 @@ static void get_pci_mode(struct adapter *adapter, struct pci_params *p)
 static void init_link_config(struct link_config *lc, unsigned int caps)
 {
 	lc->supported = caps;
+	lc->lp_advertising = 0;
 	lc->requested_speed = 0;
 	lc->speed = 0;
 	lc->requested_fc = lc->fc = PAUSE_RX | PAUSE_TX;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 392d664..a89b307 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -2249,20 +2249,20 @@ struct fw_acl_vlan_cmd {
 enum fw_port_cap {
 	FW_PORT_CAP_SPEED_100M		= 0x0001,
 	FW_PORT_CAP_SPEED_1G		= 0x0002,
-	FW_PORT_CAP_SPEED_2_5G		= 0x0004,
+	FW_PORT_CAP_SPEED_25G		= 0x0004,
 	FW_PORT_CAP_SPEED_10G		= 0x0008,
 	FW_PORT_CAP_SPEED_40G		= 0x0010,
 	FW_PORT_CAP_SPEED_100G		= 0x0020,
 	FW_PORT_CAP_FC_RX		= 0x0040,
 	FW_PORT_CAP_FC_TX		= 0x0080,
 	FW_PORT_CAP_ANEG		= 0x0100,
-	FW_PORT_CAP_MDI_0		= 0x0200,
-	FW_PORT_CAP_MDI_1		= 0x0400,
-	FW_PORT_CAP_BEAN		= 0x0800,
-	FW_PORT_CAP_PMA_LPBK		= 0x1000,
-	FW_PORT_CAP_PCS_LPBK		= 0x2000,
-	FW_PORT_CAP_PHYXS_LPBK		= 0x4000,
-	FW_PORT_CAP_FAR_END_LPBK	= 0x8000,
+	FW_PORT_CAP_MDIX		= 0x0200,
+	FW_PORT_CAP_MDIAUTO		= 0x0400,
+	FW_PORT_CAP_FEC			= 0x0800,
+	FW_PORT_CAP_TECHKR		= 0x1000,
+	FW_PORT_CAP_TECHKX4		= 0x2000,
+	FW_PORT_CAP_802_3_PAUSE		= 0x4000,
+	FW_PORT_CAP_802_3_ASM_DIR	= 0x8000,
 };
 
 enum fw_port_mdi {
@@ -2376,7 +2376,8 @@ struct fw_port_cmd {
 			__u8   cbllen;
 			__u8   auxlinfo;
 			__u8   dcbxdis_pkd;
-			__u8   r8_lo[3];
+			__u8   r8_lo;
+			__be16 lpacap;
 			__be64 r9;
 		} info;
 		struct fw_port_diags {
@@ -2555,6 +2556,11 @@ enum fw_port_type {
 	FW_PORT_TYPE_QSA,
 	FW_PORT_TYPE_QSFP,
 	FW_PORT_TYPE_BP40_BA,
+	FW_PORT_TYPE_KR4_100G,
+	FW_PORT_TYPE_CR4_QSFP,
+	FW_PORT_TYPE_CR_QSFP,
+	FW_PORT_TYPE_CR2_QSFP,
+	FW_PORT_TYPE_SFP28,
 
 	FW_PORT_TYPE_NONE = FW_PORT_CMD_PTYPE_M
 };
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 9f55264..e116bb8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -1201,105 +1201,187 @@ static void cxgb4vf_poll_controller(struct net_device *dev)
  * state of the port to which we're linked.
  */
 
-static unsigned int t4vf_from_fw_linkcaps(enum fw_port_type type,
-					  unsigned int caps)
-{
-	unsigned int v = 0;
-
-	if (type == FW_PORT_TYPE_BT_SGMII || type == FW_PORT_TYPE_BT_XFI ||
-	    type == FW_PORT_TYPE_BT_XAUI) {
-		v |= SUPPORTED_TP;
-		if (caps & FW_PORT_CAP_SPEED_100M)
-			v |= SUPPORTED_100baseT_Full;
-		if (caps & FW_PORT_CAP_SPEED_1G)
-			v |= SUPPORTED_1000baseT_Full;
-		if (caps & FW_PORT_CAP_SPEED_10G)
-			v |= SUPPORTED_10000baseT_Full;
-	} else if (type == FW_PORT_TYPE_KX4 || type == FW_PORT_TYPE_KX) {
-		v |= SUPPORTED_Backplane;
-		if (caps & FW_PORT_CAP_SPEED_1G)
-			v |= SUPPORTED_1000baseKX_Full;
-		if (caps & FW_PORT_CAP_SPEED_10G)
-			v |= SUPPORTED_10000baseKX4_Full;
-	} else if (type == FW_PORT_TYPE_KR)
-		v |= SUPPORTED_Backplane | SUPPORTED_10000baseKR_Full;
-	else if (type == FW_PORT_TYPE_BP_AP)
-		v |= SUPPORTED_Backplane | SUPPORTED_10000baseR_FEC |
-		     SUPPORTED_10000baseKR_Full | SUPPORTED_1000baseKX_Full;
-	else if (type == FW_PORT_TYPE_BP4_AP)
-		v |= SUPPORTED_Backplane | SUPPORTED_10000baseR_FEC |
-		     SUPPORTED_10000baseKR_Full | SUPPORTED_1000baseKX_Full |
-		     SUPPORTED_10000baseKX4_Full;
-	else if (type == FW_PORT_TYPE_FIBER_XFI ||
-		 type == FW_PORT_TYPE_FIBER_XAUI ||
-		 type == FW_PORT_TYPE_SFP ||
-		 type == FW_PORT_TYPE_QSFP_10G ||
-		 type == FW_PORT_TYPE_QSA) {
-		v |= SUPPORTED_FIBRE;
-		if (caps & FW_PORT_CAP_SPEED_1G)
-			v |= SUPPORTED_1000baseT_Full;
-		if (caps & FW_PORT_CAP_SPEED_10G)
-			v |= SUPPORTED_10000baseT_Full;
-	} else if (type == FW_PORT_TYPE_BP40_BA ||
-		   type == FW_PORT_TYPE_QSFP) {
-		v |= SUPPORTED_40000baseSR4_Full;
-		v |= SUPPORTED_FIBRE;
-	}
-
-	if (caps & FW_PORT_CAP_ANEG)
-		v |= SUPPORTED_Autoneg;
-	return v;
-}
-
-static int cxgb4vf_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	const struct port_info *p = netdev_priv(dev);
-
-	if (p->port_type == FW_PORT_TYPE_BT_SGMII ||
-	    p->port_type == FW_PORT_TYPE_BT_XFI ||
-	    p->port_type == FW_PORT_TYPE_BT_XAUI)
-		cmd->port = PORT_TP;
-	else if (p->port_type == FW_PORT_TYPE_FIBER_XFI ||
-		 p->port_type == FW_PORT_TYPE_FIBER_XAUI)
-		cmd->port = PORT_FIBRE;
-	else if (p->port_type == FW_PORT_TYPE_SFP ||
-		 p->port_type == FW_PORT_TYPE_QSFP_10G ||
-		 p->port_type == FW_PORT_TYPE_QSA ||
-		 p->port_type == FW_PORT_TYPE_QSFP) {
-		if (p->mod_type == FW_PORT_MOD_TYPE_LR ||
-		    p->mod_type == FW_PORT_MOD_TYPE_SR ||
-		    p->mod_type == FW_PORT_MOD_TYPE_ER ||
-		    p->mod_type == FW_PORT_MOD_TYPE_LRM)
-			cmd->port = PORT_FIBRE;
-		else if (p->mod_type == FW_PORT_MOD_TYPE_TWINAX_PASSIVE ||
-			 p->mod_type == FW_PORT_MOD_TYPE_TWINAX_ACTIVE)
-			cmd->port = PORT_DA;
+/**
+ *	from_fw_port_mod_type - translate Firmware Port/Module type to Ethtool
+ *	@port_type: Firmware Port Type
+ *	@mod_type: Firmware Module Type
+ *
+ *	Translate Firmware Port/Module type to Ethtool Port Type.
+ */
+static int from_fw_port_mod_type(enum fw_port_type port_type,
+				 enum fw_port_module_type mod_type)
+{
+	if (port_type == FW_PORT_TYPE_BT_SGMII ||
+	    port_type == FW_PORT_TYPE_BT_XFI ||
+	    port_type == FW_PORT_TYPE_BT_XAUI) {
+		return PORT_TP;
+	} else if (port_type == FW_PORT_TYPE_FIBER_XFI ||
+		   port_type == FW_PORT_TYPE_FIBER_XAUI) {
+		return PORT_FIBRE;
+	} else if (port_type == FW_PORT_TYPE_SFP ||
+		   port_type == FW_PORT_TYPE_QSFP_10G ||
+		   port_type == FW_PORT_TYPE_QSA ||
+		   port_type == FW_PORT_TYPE_QSFP) {
+		if (mod_type == FW_PORT_MOD_TYPE_LR ||
+		    mod_type == FW_PORT_MOD_TYPE_SR ||
+		    mod_type == FW_PORT_MOD_TYPE_ER ||
+		    mod_type == FW_PORT_MOD_TYPE_LRM)
+			return PORT_FIBRE;
+		else if (mod_type == FW_PORT_MOD_TYPE_TWINAX_PASSIVE ||
+			 mod_type == FW_PORT_MOD_TYPE_TWINAX_ACTIVE)
+			return PORT_DA;
 		else
-			cmd->port = PORT_OTHER;
-	} else
-		cmd->port = PORT_OTHER;
+			return PORT_OTHER;
+	}
+
+	return PORT_OTHER;
+}
+
+/**
+ *	fw_caps_to_lmm - translate Firmware to ethtool Link Mode Mask
+ *	@port_type: Firmware Port Type
+ *	@fw_caps: Firmware Port Capabilities
+ *	@link_mode_mask: ethtool Link Mode Mask
+ *
+ *	Translate a Firmware Port Capabilities specification to an ethtool
+ *	Link Mode Mask.
+ */
+static void fw_caps_to_lmm(enum fw_port_type port_type,
+			   unsigned int fw_caps,
+			   unsigned long *link_mode_mask)
+{
+	#define SET_LMM(__lmm_name) __set_bit(ETHTOOL_LINK_MODE_ ## __lmm_name\
+			 ## _BIT, link_mode_mask)
+
+	#define FW_CAPS_TO_LMM(__fw_name, __lmm_name) \
+		do { \
+			if (fw_caps & FW_PORT_CAP_ ## __fw_name) \
+				SET_LMM(__lmm_name); \
+		} while (0)
+
+	switch (port_type) {
+	case FW_PORT_TYPE_BT_SGMII:
+	case FW_PORT_TYPE_BT_XFI:
+	case FW_PORT_TYPE_BT_XAUI:
+		SET_LMM(TP);
+		FW_CAPS_TO_LMM(SPEED_100M, 100baseT_Full);
+		FW_CAPS_TO_LMM(SPEED_1G, 1000baseT_Full);
+		FW_CAPS_TO_LMM(SPEED_10G, 10000baseT_Full);
+		break;
+
+	case FW_PORT_TYPE_KX4:
+	case FW_PORT_TYPE_KX:
+		SET_LMM(Backplane);
+		FW_CAPS_TO_LMM(SPEED_1G, 1000baseKX_Full);
+		FW_CAPS_TO_LMM(SPEED_10G, 10000baseKX4_Full);
+		break;
+
+	case FW_PORT_TYPE_KR:
+		SET_LMM(Backplane);
+		SET_LMM(10000baseKR_Full);
+		break;
+
+	case FW_PORT_TYPE_BP_AP:
+		SET_LMM(Backplane);
+		SET_LMM(10000baseR_FEC);
+		SET_LMM(10000baseKR_Full);
+		SET_LMM(1000baseKX_Full);
+		break;
+
+	case FW_PORT_TYPE_BP4_AP:
+		SET_LMM(Backplane);
+		SET_LMM(10000baseR_FEC);
+		SET_LMM(10000baseKR_Full);
+		SET_LMM(1000baseKX_Full);
+		SET_LMM(10000baseKX4_Full);
+		break;
+
+	case FW_PORT_TYPE_FIBER_XFI:
+	case FW_PORT_TYPE_FIBER_XAUI:
+	case FW_PORT_TYPE_SFP:
+	case FW_PORT_TYPE_QSFP_10G:
+	case FW_PORT_TYPE_QSA:
+		SET_LMM(FIBRE);
+		FW_CAPS_TO_LMM(SPEED_1G, 1000baseT_Full);
+		FW_CAPS_TO_LMM(SPEED_10G, 10000baseT_Full);
+		break;
 
-	if (p->mdio_addr >= 0) {
-		cmd->phy_address = p->mdio_addr;
-		cmd->transceiver = XCVR_EXTERNAL;
-		cmd->mdio_support = p->port_type == FW_PORT_TYPE_BT_SGMII ?
-			MDIO_SUPPORTS_C22 : MDIO_SUPPORTS_C45;
+	case FW_PORT_TYPE_BP40_BA:
+	case FW_PORT_TYPE_QSFP:
+		SET_LMM(FIBRE);
+		SET_LMM(40000baseSR4_Full);
+		break;
+
+	case FW_PORT_TYPE_CR_QSFP:
+	case FW_PORT_TYPE_SFP28:
+		SET_LMM(FIBRE);
+		SET_LMM(25000baseCR_Full);
+		break;
+
+	case FW_PORT_TYPE_KR4_100G:
+	case FW_PORT_TYPE_CR4_QSFP:
+		SET_LMM(FIBRE);
+		SET_LMM(100000baseCR4_Full);
+		break;
+
+	default:
+		break;
+	}
+
+	FW_CAPS_TO_LMM(ANEG, Autoneg);
+	FW_CAPS_TO_LMM(802_3_PAUSE, Pause);
+	FW_CAPS_TO_LMM(802_3_ASM_DIR, Asym_Pause);
+
+	#undef FW_CAPS_TO_LMM
+	#undef SET_LMM
+}
+
+static int cxgb4vf_get_link_ksettings(struct net_device *dev,
+				      struct ethtool_link_ksettings
+							*link_ksettings)
+{
+	const struct port_info *pi = netdev_priv(dev);
+	struct ethtool_link_settings *base = &link_ksettings->base;
+
+	ethtool_link_ksettings_zero_link_mode(link_ksettings, supported);
+	ethtool_link_ksettings_zero_link_mode(link_ksettings, advertising);
+	ethtool_link_ksettings_zero_link_mode(link_ksettings, lp_advertising);
+
+	base->port = from_fw_port_mod_type(pi->port_type, pi->mod_type);
+
+	if (pi->mdio_addr >= 0) {
+		base->phy_address = pi->mdio_addr;
+		base->mdio_support = (pi->port_type == FW_PORT_TYPE_BT_SGMII
+				      ? ETH_MDIO_SUPPORTS_C22
+				      : ETH_MDIO_SUPPORTS_C45);
+	} else {
+		base->phy_address = 255;
+		base->mdio_support = 0;
+	}
+
+	fw_caps_to_lmm(pi->port_type, pi->link_cfg.supported,
+		       link_ksettings->link_modes.supported);
+	fw_caps_to_lmm(pi->port_type, pi->link_cfg.advertising,
+		       link_ksettings->link_modes.advertising);
+	fw_caps_to_lmm(pi->port_type, pi->link_cfg.lp_advertising,
+		       link_ksettings->link_modes.lp_advertising);
+
+	if (netif_carrier_ok(dev)) {
+		base->speed = pi->link_cfg.speed;
+		base->duplex = DUPLEX_FULL;
 	} else {
-		cmd->phy_address = 0;  /* not really, but no better option */
-		cmd->transceiver = XCVR_INTERNAL;
-		cmd->mdio_support = 0;
-	}
-
-	cmd->supported = t4vf_from_fw_linkcaps(p->port_type,
-					       p->link_cfg.supported);
-	cmd->advertising = t4vf_from_fw_linkcaps(p->port_type,
-					    p->link_cfg.advertising);
-	ethtool_cmd_speed_set(cmd,
-			      netif_carrier_ok(dev) ? p->link_cfg.speed : 0);
-	cmd->duplex = DUPLEX_FULL;
-	cmd->autoneg = p->link_cfg.autoneg;
-	cmd->maxtxpkt = 0;
-	cmd->maxrxpkt = 0;
+		base->speed = SPEED_UNKNOWN;
+		base->duplex = DUPLEX_UNKNOWN;
+	}
+
+	base->autoneg = pi->link_cfg.autoneg;
+	if (pi->link_cfg.supported & FW_PORT_CAP_ANEG)
+		ethtool_link_ksettings_add_link_mode(link_ksettings,
+						     supported, Autoneg);
+	if (pi->link_cfg.autoneg)
+		ethtool_link_ksettings_add_link_mode(link_ksettings,
+						     advertising, Autoneg);
+
 	return 0;
 }
 
@@ -1675,7 +1757,7 @@ static void cxgb4vf_get_wol(struct net_device *dev,
 #define TSO_FLAGS (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
 
 static const struct ethtool_ops cxgb4vf_ethtool_ops = {
-	.get_settings		= cxgb4vf_get_settings,
+	.get_link_ksettings	= cxgb4vf_get_link_ksettings,
 	.get_drvinfo		= cxgb4vf_get_drvinfo,
 	.get_msglevel		= cxgb4vf_get_msglevel,
 	.set_msglevel		= cxgb4vf_set_msglevel,
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
index 438374a..8ee5414 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
@@ -107,6 +107,7 @@ struct t4vf_port_stats {
 struct link_config {
 	unsigned int   supported;        /* link capabilities */
 	unsigned int   advertising;      /* advertised capabilities */
+	unsigned short lp_advertising;   /* peer advertised capabilities */
 	unsigned short requested_speed;  /* speed user has requested */
 	unsigned short speed;            /* actual link speed */
 	unsigned char  requested_fc;     /* flow control user has requested */
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 61bfe86..427bfa7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -328,6 +328,7 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 static void init_link_config(struct link_config *lc, unsigned int caps)
 {
 	lc->supported = caps;
+	lc->lp_advertising = 0;
 	lc->requested_speed = 0;
 	lc->speed = 0;
 	lc->requested_fc = lc->fc = PAUSE_RX | PAUSE_TX;
@@ -1743,6 +1744,8 @@ int t4vf_handle_fw_rpl(struct adapter *adapter, const __be64 *rpl)
 				lc->fc = fc;
 				lc->supported =
 					be16_to_cpu(port_cmd->u.info.pcap);
+				lc->lp_advertising =
+					be16_to_cpu(port_cmd->u.info.lpacap);
 				t4vf_os_link_changed(adapter, pidx, link_ok);
 			}
 		}
-- 
2.7.4
