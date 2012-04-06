From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 2/4 (V3)] phy: add the EEE support and the way to access to the MMD regs
Date: Fri,  6 Apr 2012 11:29:16 +0200
Message-ID: <1333704559-11251-3-git-send-email-peppe.cavallaro@st.com>
References: <1333704559-11251-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, rayagond@vayavyalabs.com,
	davem@davemloft.net, Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:42887 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754781Ab2DFJ3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2012 05:29:45 -0400
In-Reply-To: <1333704559-11251-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the initial support for the Energy-Efficient
Ethernet (EEE). It has been tested on IC+101G device on ST STB.

To support the EEE we have to access to the MMD registers 3.20 and
3.60/61. So I added two new functions to read/write the MMD
registers (clause 45)

The upper-layer will invoke the phy_check_eee to properly check
if the EEE is supported by the PHYs.
The phy_get_eee_err reports the number of time where the PHY
failed to complete its normal wake sequence.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/phy/phy_device.c |  138 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/mdio.h         |    6 ++-
 include/linux/mii.h          |   11 +++
 include/linux/phy.h          |    3 +
 4 files changed, 157 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index e8c42d6..4231baa 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -30,6 +30,7 @@
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/phy.h>
+#include <linux/mdio.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -898,6 +899,143 @@ int genphy_resume(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_resume);
 
+static inline void mmd_phy_indirect(struct mii_bus *bus, int prtad, int devad,
+				    int addr)
+{
+	/* Write the desired MMD Devad */
+	bus->write(bus, addr, MII_MMD_CTRL, devad);
+
+	/* Write the desired MMD register address */
+	bus->write(bus, addr, MII_MMD_DATA, prtad);
+
+	/* Select the Function : DATA with no post increment */
+	bus->write(bus, addr, MII_MMD_CTRL,
+		   (devad | MII_MMD_CTRL_FUNC_DATA_NOINCR));
+}
+
+/**
+ * phy_read_mmd_indirect - reads data from the MMC register (clause 22 to
+ * access to clause 45)
+ * @bus: the target MII bus
+ * @prtad: MMD Address
+ * @devad: MMD DEVAD
+ * @addr: PHY address on the MII bus
+ *
+ * Description: Reads data from the MMD regisetrs of the
+ * phy addr. To read these register we have:
+ * 1) Write reg 13 // DEVAD
+ * 2) Write reg 14 // MMD Address
+ * 3) Write reg 13 // MMD Data Command for MMD DEVAD
+ * 3) Read  reg 14 // Read MMD data
+ */
+static int phy_read_mmd_indirect(struct mii_bus *bus, int prtad, int devad,
+				 int addr)
+{
+	u32 ret;
+
+	mmd_phy_indirect(bus, prtad, devad, addr);
+
+	/* Read the content of the MMD's selected register */
+	ret = bus->read(bus, addr, MII_MMD_DATA);
+	if (ret < 0)
+		return -EIO;
+
+	return ret;
+}
+
+/**
+ * phy_write_mmd_indirect - writes data to the MMC register (clause 22 to
+ * access to clause 45)
+ * @bus: the target MII bus
+ * @prtad: MMD Address
+ * @devad: MMD DEVAD
+ * @addr: PHY address on the MII bus
+ * @data: data to write in the MMD register
+ *
+ * Description: Reads data from the MMD regisetrs of the
+ * phy addr. To read these register we have:
+ * 1) Write reg 13 // DEVAD
+ * 2) Write reg 14 // MMD Address
+ * 3) Write reg 13 // MMD Data Command for MMD DEVAD
+ * 3) Write reg 14 // Write MMD data
+ */
+static void phy_write_mmd_indirect(struct mii_bus *bus, int prtad, int devad,
+				   int addr, u32 data)
+{
+	mmd_phy_indirect(bus, prtad, devad, addr);
+
+	/* Write the data into MMD's selected register */
+	bus->write(bus, addr, MII_MMD_DATA, data);
+}
+
+/* phy_check_eee
+ * @dev: device to probe and init
+ *
+ * Description: check if the Energy-Efficient Ethernet (EEE)
+ * is supported by looking at the MMD registers 3.20 and 3.60/61
+ */
+int phy_check_eee(struct phy_device *phydev)
+{
+	int ret = -EPROTONOSUPPORT;
+
+	/* According to 802.3az,the EEE is supported only in full duplex-mode.
+	 * Also EEE feature is active when core is operating with MII, GMII
+	 * or RGMII */
+	if ((phydev->duplex == DUPLEX_FULL) &&
+	    ((phydev->interface == PHY_INTERFACE_MODE_MII) ||
+	    (phydev->interface == PHY_INTERFACE_MODE_GMII) ||
+	    (phydev->interface == PHY_INTERFACE_MODE_RGMII))) {
+		int eee_cap, eee_link;
+
+		/* EEE ability must be supported in both local and remote
+		 * PHY devices. */
+		eee_cap = phy_read_mmd_indirect(phydev->bus, MDIO_AN_EEE_LPABLE,
+						MDIO_MMD_AN, phydev->addr);
+		if (eee_cap < 0)
+			return eee_cap;
+
+		eee_link = phy_read_mmd_indirect(phydev->bus, MDIO_PCS_EEE_ABLE,
+						 MDIO_MMD_PCS, phydev->addr);
+		if (eee_link < 0)
+			return eee_link;
+
+		if (eee_cap && eee_link) {
+			/* Configure the PHY to stop receiving xMII clock
+			 * while it is signaling LPI */
+			int pcs_ctrl = phy_read_mmd_indirect(phydev->bus,
+							     MDIO_CTRL1,
+							     MDIO_MMD_PCS,
+							     phydev->addr);
+			if (pcs_ctrl < 0)
+				return pcs_ctrl;
+
+			pcs_ctrl |= MDIO_PCS_CTRL1_CLKSTOP_EN;
+			phy_write_mmd_indirect(phydev->bus, MDIO_CTRL1,
+					       MDIO_MMD_PCS,
+					       phydev->addr, pcs_ctrl);
+
+			ret = 0; /* EEE supported */
+		}
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(phy_get_eee_err);
+
+/* phy_get_eee_err
+ * @dev: device to probe and init
+ *
+ * Description: it is to report the number of time where the PHY
+ * failed to complete its normal wake sequence.
+ */
+int phy_get_eee_err(struct phy_device *phydev)
+{
+	return phy_read_mmd_indirect(phydev->bus, MDIO_PCS_EEE_WK_ERR,
+				     MDIO_MMD_PCS, phydev->addr);
+
+}
+EXPORT_SYMBOL(phy_check_eee);
+
 /**
  * phy_probe - probe and init a PHY device
  * @dev: device to probe and init
diff --git a/include/linux/mdio.h b/include/linux/mdio.h
index dfb9479..49c9a13 100644
--- a/include/linux/mdio.h
+++ b/include/linux/mdio.h
@@ -43,7 +43,11 @@
 #define MDIO_PKGID2		15
 #define MDIO_AN_ADVERTISE	16	/* AN advertising (base page) */
 #define MDIO_AN_LPA		19	/* AN LP abilities (base page) */
+#define MDIO_PCS_EEE_ABLE	20	/* EEE Capability register */
+#define MDIO_PCS_EEE_WK_ERR	22	/* EEE wake error counter */
 #define MDIO_PHYXS_LNSTAT	24	/* PHY XGXS lane state */
+#define MDIO_AN_EEE_ADV		60	/* EEE advertisement */
+#define MDIO_AN_EEE_LPABLE	61	/* EEE link partner ability */
 
 /* Media-dependent registers. */
 #define MDIO_PMA_10GBT_SWAPPOL	130	/* 10GBASE-T pair swap & polarity */
@@ -56,7 +60,6 @@
 #define MDIO_PCS_10GBRT_STAT2	33	/* 10GBASE-R/-T PCS status 2 */
 #define MDIO_AN_10GBT_CTRL	32	/* 10GBASE-T auto-negotiation control */
 #define MDIO_AN_10GBT_STAT	33	/* 10GBASE-T auto-negotiation status */
-#define MDIO_AN_EEE_ADV		60	/* EEE advertisement */
 
 /* LASI (Link Alarm Status Interrupt) registers, defined by XENPAK MSA. */
 #define MDIO_PMA_LASI_RXCTRL	0x9000	/* RX_ALARM control */
@@ -82,6 +85,7 @@
 #define MDIO_AN_CTRL1_RESTART		BMCR_ANRESTART
 #define MDIO_AN_CTRL1_ENABLE		BMCR_ANENABLE
 #define MDIO_AN_CTRL1_XNP		0x2000	/* Enable extended next page */
+#define MDIO_PCS_CTRL1_CLKSTOP_EN	0x400	/* Stop the clock during LPI */
 
 /* 10 Gb/s */
 #define MDIO_CTRL1_SPEED10G		(MDIO_CTRL1_SPEEDSELEXT | 0x00)
diff --git a/include/linux/mii.h b/include/linux/mii.h
index 2783eca..35ddda1 100644
--- a/include/linux/mii.h
+++ b/include/linux/mii.h
@@ -21,6 +21,8 @@
 #define MII_EXPANSION		0x06	/* Expansion register          */
 #define MII_CTRL1000		0x09	/* 1000BASE-T control          */
 #define MII_STAT1000		0x0a	/* 1000BASE-T status           */
+#define	MII_MMD_CTRL		0x0d	/* MMD Access Control Register */
+#define	MII_MMD_DATA		0x0e	/* MMD Access Data Register */
 #define MII_ESTATUS		0x0f	/* Extended Status             */
 #define MII_DCOUNTER		0x12	/* Disconnect counter          */
 #define MII_FCSCOUNTER		0x13	/* False carrier counter       */
@@ -141,6 +143,15 @@
 #define FLOW_CTRL_TX		0x01
 #define FLOW_CTRL_RX		0x02
 
+/* MMD Access Control register fields */
+#define MII_MMD_CTRL_DEVAD_MASK			0x1f	/* Mask MMD DEVAD*/
+#define MII_MMD_CTRL_FUNC_ADDR			0x0000	/* Address */
+#define MII_MMD_CTRL_FUNC_DATA_NOINCR		0x4000	/* no post increment */
+#define MII_MMD_CTRL_FUNC_DATA_INCR_ON_RDWT	0x8000	/* post increment on
+							 * reads & writes */
+#define MII_MMD_CTRL_FUNC_DATA_INCR_ON_WT	0xC000	/* post increment on
+							 * writes only */
+
 /* This structure is used in all SIOCxMIIxxx ioctl calls */
 struct mii_ioctl_data {
 	__u16		phy_id;
diff --git a/include/linux/phy.h b/include/linux/phy.h
index f092032..a5d7d0d 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -533,6 +533,9 @@ int phy_register_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask,
 		int (*run)(struct phy_device *));
 int phy_scan_fixups(struct phy_device *phydev);
 
+int phy_check_eee(struct phy_device *phydev);
+int phy_get_eee_err(struct phy_device *phydev);
+
 int __init mdio_bus_init(void);
 void mdio_bus_exit(void);
 
-- 
1.7.4.4
