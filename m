From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 03/16] mdio: Add generic MDIO (clause 45) support functions
Date: Wed, 29 Apr 2009 19:04:46 +0100
Message-ID: <1241028286.3246.36.camel@achroite>
References: <1241028086.3246.30.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:43750 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753691AbZD2SEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 14:04:47 -0400
In-Reply-To: <1241028086.3246.30.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These roughly mirror many of the MII library functions and are based
on code from the sfc driver.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/Kconfig  |    3 +
 drivers/net/Makefile |    1 +
 drivers/net/mdio.c   |  359 ++++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/mdio.h |   66 +++++++++
 4 files changed, 429 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/mdio.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index bc7eef1..2f81db5 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2443,6 +2443,9 @@ menuconfig NETDEV_10000
 
 if NETDEV_10000
 
+config MDIO
+	tristate
+
 config CHELSIO_T1
         tristate "Chelsio 10Gb Ethernet support"
         depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 80420f6..dcd5f15 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -95,6 +95,7 @@ obj-$(CONFIG_SH_ETH) += sh_eth.o
 #
 
 obj-$(CONFIG_MII) += mii.o
+obj-$(CONFIG_MDIO) += mdio.o
 obj-$(CONFIG_PHYLIB) += phy/
 
 obj-$(CONFIG_SUNDANCE) += sundance.o
diff --git a/drivers/net/mdio.c b/drivers/net/mdio.c
new file mode 100644
index 0000000..0604a25
--- /dev/null
+++ b/drivers/net/mdio.c
@@ -0,0 +1,359 @@
+/*
+ * mdio.c: Generic support for MDIO-compatible transceivers
+ * Copyright 2006-2009 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#include <linux/kernel.h>
+#include <linux/capability.h>
+#include <linux/errno.h>
+#include <linux/ethtool.h>
+#include <linux/mdio.h>
+#include <linux/module.h>
+
+/**
+ * mdio45_probe - probe for an MDIO (clause 45) device
+ * @mdio: MDIO interface
+ * @prtad: Expected PHY address
+ *
+ * This sets @prtad and @mmds in the MDIO interface if successful.
+ * Returns 0 on success, negative on error.
+ */
+int mdio45_probe(struct mdio_if_info *mdio, int prtad)
+{
+	int mmd, stat2, devs1, devs2;
+
+	/* Assume PHY must have at least one of PMA/PMD, WIS, PCS, PHY
+	 * XS or DTE XS; give up if none is present. */
+	for (mmd = 1; mmd <= 5; mmd++) {
+		/* Is this MMD present? */
+		stat2 = mdio->mdio_read(mdio->dev, prtad, mmd, MDIO_STAT2);
+		if (stat2 < 0 ||
+		    (stat2 & MDIO_STAT2_DEVPRST) != MDIO_STAT2_DEVPRST_VAL)
+			continue;
+
+		/* It should tell us about all the other MMDs */
+		devs1 = mdio->mdio_read(mdio->dev, prtad, mmd, MDIO_DEVS1);
+		devs2 = mdio->mdio_read(mdio->dev, prtad, mmd, MDIO_DEVS2);
+		if (devs1 < 0 || devs2 < 0)
+			continue;
+
+		mdio->prtad = prtad;
+		mdio->mmds = devs1 | (devs2 << 16);
+		return 0;
+	}
+
+	return -ENODEV;
+}
+EXPORT_SYMBOL(mdio45_probe);
+
+/**
+ * mdio_set_flag - set or clear flag in an MDIO register
+ * @mdio: MDIO interface
+ * @prtad: PHY address
+ * @devad: MMD address
+ * @addr: Register address
+ * @mask: Mask for flag (single bit set)
+ * @sense: New value of flag
+ *
+ * This debounces changes: it does not write the register if the flag
+ * already has the proper value.  Returns 0 on success, negative on error.
+ */
+int mdio_set_flag(const struct mdio_if_info *mdio,
+		  int prtad, int devad, u16 addr, int mask,
+		  bool sense)
+{
+	int old_val = mdio->mdio_read(mdio->dev, prtad, devad, addr);
+	int new_val;
+
+	if (old_val < 0)
+		return old_val;
+	if (sense)
+		new_val = old_val | mask;
+	else
+		new_val = old_val & ~mask;
+	if (old_val == new_val)
+		return 0;
+	return mdio->mdio_write(mdio->dev, prtad, devad, addr, new_val);
+}
+EXPORT_SYMBOL(mdio_set_flag);
+
+/**
+ * mdio_link_ok - is link status up/OK
+ * @mdio: MDIO interface
+ * @mmd_mask: Mask for MMDs to check
+ *
+ * Returns 1 if the PHY reports link status up/OK, 0 otherwise.
+ * @mmd_mask is normally @mdio->mmds, but if loopback is enabled
+ * the MMDs being bypassed should be excluded from the mask.
+ */
+int mdio45_links_ok(const struct mdio_if_info *mdio, u32 mmd_mask)
+{
+	int devad, reg;
+
+	if (!mmd_mask) {
+		/* Use absence of XGMII faults in lieu of link state */
+		reg = mdio->mdio_read(mdio->dev, mdio->prtad,
+				      MDIO_MMD_PHYXS, MDIO_STAT2);
+		return reg >= 0 && !(reg & MDIO_STAT2_RXFAULT);
+	}
+
+	for (devad = 0; mmd_mask; devad++) {
+		if (mmd_mask & (1 << devad)) {
+			mmd_mask &= ~(1 << devad);
+
+			/* Read twice because link state is latched and a
+			 * read moves the current state into the register */
+			mdio->mdio_read(mdio->dev, mdio->prtad,
+					devad, MDIO_STAT1);
+			reg = mdio->mdio_read(mdio->dev, mdio->prtad,
+					      devad, MDIO_STAT1);
+			if (reg < 0 || !(reg & MDIO_STAT1_LSTATUS))
+				return false;
+		}
+	}
+
+	return true;
+}
+EXPORT_SYMBOL(mdio45_links_ok);
+
+/**
+ * mdio45_nway_restart - restart auto-negotiation for this interface
+ * @mdio: MDIO interface
+ *
+ * Returns 0 on success, negative on error.
+ */
+int mdio45_nway_restart(const struct mdio_if_info *mdio)
+{
+	if (!(mdio->mmds & MDIO_DEVS_AN))
+		return -EOPNOTSUPP;
+
+	mdio_set_flag(mdio, mdio->prtad, MDIO_MMD_AN, MDIO_CTRL1,
+		      MDIO_AN_CTRL1_RESTART, true);
+	return 0;
+}
+EXPORT_SYMBOL(mdio45_nway_restart);
+
+static u32 mdio45_get_an(const struct mdio_if_info *mdio, u16 addr)
+{
+	u32 result = 0;
+	int reg;
+
+	reg = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_AN, addr);
+	if (reg & ADVERTISE_10HALF)
+		result |= ADVERTISED_10baseT_Half;
+	if (reg & ADVERTISE_10FULL)
+		result |= ADVERTISED_10baseT_Full;
+	if (reg & ADVERTISE_100HALF)
+		result |= ADVERTISED_100baseT_Half;
+	if (reg & ADVERTISE_100FULL)
+		result |= ADVERTISED_100baseT_Full;
+	return result;
+}
+
+/**
+ * mdio45_ethtool_gset_npage - get settings for ETHTOOL_GSET
+ * @mdio: MDIO interface
+ * @ecmd: Ethtool request structure
+ * @npage_adv: Modes currently advertised on next pages
+ * @npage_lpa: Modes advertised by link partner on next pages
+ *
+ * Since the CSRs for auto-negotiation using next pages are not fully
+ * standardised, this function does not attempt to decode them.  The
+ * caller must pass them in.
+ */
+void mdio45_ethtool_gset_npage(const struct mdio_if_info *mdio,
+			       struct ethtool_cmd *ecmd,
+			       u32 npage_adv, u32 npage_lpa)
+{
+	int reg;
+
+	ecmd->transceiver = XCVR_INTERNAL;
+	ecmd->phy_address = mdio->prtad;
+
+	reg = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_PMAPMD,
+			      MDIO_CTRL2);
+	switch (reg & MDIO_PMA_CTRL2_TYPE) {
+	case MDIO_PMA_CTRL2_10GBT:
+	case MDIO_PMA_CTRL2_1000BT:
+	case MDIO_PMA_CTRL2_100BTX:
+	case MDIO_PMA_CTRL2_10BT:
+		ecmd->port = PORT_TP;
+		ecmd->supported = SUPPORTED_TP;
+		reg = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_PMAPMD,
+				      MDIO_SPEED);
+		if (reg & MDIO_SPEED_10G)
+			ecmd->supported |= SUPPORTED_10000baseT_Full;
+		if (reg & MDIO_PMA_SPEED_1000)
+			ecmd->supported |= (SUPPORTED_1000baseT_Full |
+					    SUPPORTED_1000baseT_Half);
+		if (reg & MDIO_PMA_SPEED_100)
+			ecmd->supported |= (SUPPORTED_100baseT_Full |
+					    SUPPORTED_100baseT_Half);
+		if (reg & MDIO_PMA_SPEED_10)
+			ecmd->supported |= (SUPPORTED_10baseT_Full |
+					    SUPPORTED_10baseT_Half);
+		ecmd->advertising = ADVERTISED_TP;
+		break;
+
+	case MDIO_PMA_CTRL2_10GBCX4:
+	case MDIO_PMA_CTRL2_10GBKX4:
+	case MDIO_PMA_CTRL2_10GBKR:
+	case MDIO_PMA_CTRL2_1000BKX:
+		ecmd->port = PORT_OTHER;
+		ecmd->supported = 0;
+		ecmd->advertising = 0;
+		break;
+
+	/* All the other defined modes are flavours of optical */
+	default:
+		ecmd->port = PORT_FIBRE;
+		ecmd->supported = SUPPORTED_FIBRE;
+		ecmd->advertising = ADVERTISED_FIBRE;
+		break;
+	}
+
+	if (mdio->mmds & MDIO_DEVS_AN) {
+		ecmd->supported |= SUPPORTED_Autoneg;
+		reg = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_AN,
+				      MDIO_CTRL1);
+		if (reg & MDIO_AN_CTRL1_ENABLE) {
+			ecmd->autoneg = AUTONEG_ENABLE;
+			ecmd->advertising |=
+				ADVERTISED_Autoneg |
+				mdio45_get_an(mdio, MDIO_AN_ADVERTISE) |
+				npage_adv;
+		} else {
+			ecmd->autoneg = AUTONEG_DISABLE;
+		}
+	} else {
+		ecmd->autoneg = AUTONEG_DISABLE;
+	}
+
+	if (ecmd->autoneg) {
+		u32 modes = 0;
+
+		/* If AN is complete and successful, report best common
+		 * mode, otherwise report best advertised mode. */
+		if (mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_AN,
+				    MDIO_STAT1) &
+		    MDIO_AN_STAT1_COMPLETE)
+			modes = (ecmd->advertising &
+				 (mdio45_get_an(mdio, MDIO_AN_LPA) |
+				  npage_lpa));
+		if (modes == 0)
+			modes = ecmd->advertising;
+
+		if (modes & ADVERTISED_10000baseT_Full) {
+			ecmd->speed = SPEED_10000;
+			ecmd->duplex = DUPLEX_FULL;
+		} else if (modes & (ADVERTISED_1000baseT_Full |
+				    ADVERTISED_1000baseT_Half)) {
+			ecmd->speed = SPEED_1000;
+			ecmd->duplex = !!(modes & ADVERTISED_1000baseT_Full);
+		} else if (modes & (ADVERTISED_100baseT_Full |
+				    ADVERTISED_100baseT_Half)) {
+			ecmd->speed = SPEED_100;
+			ecmd->duplex = !!(modes & ADVERTISED_100baseT_Full);
+		} else {
+			ecmd->speed = SPEED_10;
+			ecmd->duplex = !!(modes & ADVERTISED_10baseT_Full);
+		}
+	} else {
+		/* Report forced settings */
+		reg = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_PMAPMD,
+				      MDIO_CTRL1);
+		ecmd->speed = (((reg & MDIO_PMA_CTRL1_SPEED1000) ? 100 : 1) *
+			       ((reg & MDIO_PMA_CTRL1_SPEED100) ? 100 : 10));
+		ecmd->duplex = (reg & MDIO_CTRL1_FULLDPLX ||
+				ecmd->speed == SPEED_10000);
+	}
+}
+EXPORT_SYMBOL(mdio45_ethtool_gset_npage);
+
+/**
+ * mdio_mii_ioctl - MII ioctl interface for MDIO (clause 22 or 45) PHYs
+ * @mdio: MDIO interface
+ * @mii_data: MII ioctl data structure
+ * @cmd: MII ioctl command
+ *
+ * Returns 0 on success, negative on error.
+ */
+int mdio_mii_ioctl(const struct mdio_if_info *mdio,
+		   struct mii_ioctl_data *mii_data, int cmd)
+{
+	int prtad, devad;
+	u16 addr = mii_data->reg_num;
+
+	/* Validate/convert cmd to one of SIOC{G,S}MIIREG */
+	switch (cmd) {
+	case SIOCGMIIPHY:
+		if (mdio->prtad == MDIO_PRTAD_NONE)
+			return -EOPNOTSUPP;
+		mii_data->phy_id = mdio->prtad;
+		cmd = SIOCGMIIREG;
+		break;
+	case SIOCGMIIREG:
+		break;
+	case SIOCSMIIREG:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	/* Validate/convert phy_id */
+	if ((mdio->mode_support & MDIO_SUPPORTS_C45) &&
+	    mdio_phy_id_is_c45(mii_data->phy_id)) {
+		prtad = mdio_phy_id_prtad(mii_data->phy_id);
+		devad = mdio_phy_id_devad(mii_data->phy_id);
+	} else if ((mdio->mode_support & MDIO_SUPPORTS_C22) &&
+		   mii_data->phy_id < 0x20) {
+		prtad = mii_data->phy_id;
+		devad = MDIO_DEVAD_NONE;
+		addr &= 0x1f;
+	} else if ((mdio->mode_support & MDIO_EMULATE_C22) &&
+		   mdio->prtad != MDIO_PRTAD_NONE &&
+		   mii_data->phy_id == mdio->prtad) {
+		/* Remap commonly-used MII registers. */
+		prtad = mdio->prtad;
+		switch (addr) {
+		case MII_BMCR:
+		case MII_BMSR:
+		case MII_PHYSID1:
+		case MII_PHYSID2:
+			devad = __ffs(mdio->mmds);
+			break;
+		case MII_ADVERTISE:
+		case MII_LPA:
+			if (!(mdio->mmds & MDIO_DEVS_AN))
+				return -EINVAL;
+			devad = MDIO_MMD_AN;
+			if (addr == MII_ADVERTISE)
+				addr = MDIO_AN_ADVERTISE;
+			else
+				addr = MDIO_AN_LPA;
+			break;
+		default:
+			return -EINVAL;
+		}
+	} else {
+		return -EINVAL;
+	}
+
+	if (cmd == SIOCGMIIREG) {
+		int rc = mdio->mdio_read(mdio->dev, prtad, devad, addr);
+		if (rc < 0)
+			return rc;
+		mii_data->val_out = rc;
+		return 0;
+	} else {
+		return mdio->mdio_write(mdio->dev, prtad, devad, addr,
+					mii_data->val_in);
+	}
+}
+EXPORT_SYMBOL(mdio_mii_ioctl);
diff --git a/include/linux/mdio.h b/include/linux/mdio.h
index d57ddb0..ba41537 100644
--- a/include/linux/mdio.h
+++ b/include/linux/mdio.h
@@ -234,4 +234,70 @@ static inline __u16 mdio_phy_id_devad(int phy_id)
 	return phy_id & MDIO_PHY_ID_DEVAD;
 }
 
+#ifdef __KERNEL__ 
+
+/**
+ * struct mdio_if_info - Ethernet controller MDIO interface
+ * @prtad: PRTAD of the PHY (%MDIO_PRTAD_NONE if not present/unknown)
+ * @mmds: Mask of MMDs expected to be present in the PHY.  This must be
+ *	non-zero unless @prtad = %MDIO_PRTAD_NONE.
+ * @mode_support: MDIO modes supported.  If %MDIO_SUPPORTS_C22 is set then
+ *	MII register access will be passed through with @devad =
+ *	%MDIO_DEVAD_NONE.  If %MDIO_EMULATE_C22 is set then access to
+ *	commonly used clause 22 registers will be translated into
+ *	clause 45 registers.
+ * @dev: Net device structure
+ * @mdio_read: Register read function; returns value or negative error code
+ * @mdio_write: Register write function; returns 0 or negative error code
+ */
+struct mdio_if_info {
+	int prtad;
+	u32 __bitwise mmds;
+	unsigned mode_support;
+
+	struct net_device *dev;
+	int (*mdio_read)(struct net_device *dev, int prtad, int devad,
+			 u16 addr);
+	int (*mdio_write)(struct net_device *dev, int prtad, int devad,
+			  u16 addr, u16 val);
+};
+
+#define MDIO_PRTAD_NONE			(-1)
+#define MDIO_DEVAD_NONE			(-1)
+#define MDIO_SUPPORTS_C22		1
+#define MDIO_SUPPORTS_C45		2
+#define MDIO_EMULATE_C22		4
+
+struct ethtool_cmd;
+struct ethtool_pauseparam;
+extern int mdio45_probe(struct mdio_if_info *mdio, int prtad);
+extern int mdio_set_flag(const struct mdio_if_info *mdio,
+			 int prtad, int devad, u16 addr, int mask,
+			 bool sense);
+extern int mdio45_links_ok(const struct mdio_if_info *mdio, u32 mmds);
+extern int mdio45_nway_restart(const struct mdio_if_info *mdio);
+extern void mdio45_ethtool_gset_npage(const struct mdio_if_info *mdio,
+				      struct ethtool_cmd *ecmd,
+				      u32 npage_adv, u32 npage_lpa);
+
+/**
+ * mdio45_ethtool_gset - get settings for ETHTOOL_GSET
+ * @mdio: MDIO interface
+ * @ecmd: Ethtool request structure
+ *
+ * Since the CSRs for auto-negotiation using next pages are not fully
+ * standardised, this function does not attempt to decode them.  Use
+ * mdio45_ethtool_gset_npage() to specify advertisement bits from next
+ * pages.
+ */
+static inline void mdio45_ethtool_gset(const struct mdio_if_info *mdio,
+				       struct ethtool_cmd *ecmd)
+{
+	mdio45_ethtool_gset_npage(mdio, ecmd, 0, 0);
+}
+
+extern int mdio_mii_ioctl(const struct mdio_if_info *mdio,
+			  struct mii_ioctl_data *mii_data, int cmd);
+
+#endif /* __KERNEL__ */
 #endif /* __LINUX_MDIO_H__ */

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

