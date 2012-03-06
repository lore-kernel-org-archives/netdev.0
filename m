From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 1/4] phy: add the EEE support and the way to access to the MMD regs
Date: Tue,  6 Mar 2012 09:28:11 +0100
Message-ID: <1331022494-12891-2-git-send-email-peppe.cavallaro@st.com>
References: <4F4E4D4B.3040909@st.com>
 <1331022494-12891-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, bhutchings@solarflare.com,
	rayagond@vayavyalabs.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:34597 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758655Ab2CFI2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 03:28:51 -0500
In-Reply-To: <1331022494-12891-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the initial support for the Energy-Efficient
Ethernet (EEE). It has been tested on IC+101G device on ST STB.

To support the EEE we have to access to the MMD registers 3.20 and
3.60/61. So I added two new functions to read/write the MMD
registers (clause 45)

The upper-layer will invoke the phy_check_eee to properly check
if the EEE is supported by the PHYs.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/phy_device.c |  136 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/mdio.h         |    5 ++
 include/linux/mii.h          |   11 ++++
 include/linux/phy.h          |    3 +
 4 files changed, 155 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index f320f46..c269492e 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -30,6 +30,7 @@
 #include <linux/mii.h>
 #include <linux/ethtool.h>
 #include <linux/phy.h>
+#include <linux/mdio.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -898,6 +899,141 @@ int genphy_resume(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_resume);
 
+static inline void mmd_phy_cl45(struct mii_bus *bus, int prtad, int devad,
+				int addr)
+{
+
+	/* Write the desired MMD Devad */
+	bus->write(bus, addr, MII_MMD_CRTL, devad);
+
+	/* Write the desired MMD register address */
+	bus->write(bus, addr, MII_MMD_DATA, prtad);
+
+	/* Select the Function : DATA with no post increment */
+	bus->write(bus, addr, MII_MMD_CRTL,
+		   (devad | MII_MMD_CTRL_FUNC_DATA_NOINCR));
+}
+
+/**
+ * read_phy_mmd - reads data from the MMC register (clause 22 to access to
+ * clause 45)
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
+static int read_phy_mmd(struct mii_bus *bus, int prtad, int devad, int addr)
+{
+	u32 ret;
+
+	mmd_phy_cl45(bus, prtad, devad, addr);
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
+ * write_phy_mmd - writes data to the MMC register (clause 22 to access to
+ * clause 45)
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
+static void write_phy_mmd(struct mii_bus *bus, int prtad, int devad, int addr,
+			  u32 data)
+{
+	mmd_phy_cl45(bus, prtad, devad, addr);
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
+		eee_cap = read_phy_mmd(phydev->bus, MDIO_EEE_PART_LINK,
+					MDIO_MMD_AN, phydev->addr);
+		if (eee_cap < 0)
+			return eee_cap;
+
+		eee_link = read_phy_mmd(phydev->bus, MDIO_EEE_CAP,
+					MDIO_MMD_PCS, phydev->addr);
+		if (eee_link < 0)
+			return eee_link;
+
+		if (eee_cap && eee_link) {
+			/* Configure the PHY to stop receiving xMII clock
+			 * while it is signaling LPI */
+			int pcs_ctrl = read_phy_mmd(phydev->bus, MDIO_CTRL1,
+						    MDIO_MMD_PCS,
+						    phydev->addr);
+			if (pcs_ctrl < 0)
+				return pcs_ctrl;
+
+			pcs_ctrl |= MDIO_PCS_CLK_STOP_ENABLE;
+			write_phy_mmd(phydev->bus, MDIO_CTRL1, MDIO_MMD_PCS,
+				      phydev->addr, pcs_ctrl);
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
+	return read_phy_mmd(phydev->bus, MDIO_EEE_WK_ERR, MDIO_MMD_PCS,
+			    phydev->addr);
+
+}
+EXPORT_SYMBOL(phy_check_eee);
+
 /**
  * phy_probe - probe and init a PHY device
  * @dev: device to probe and init
diff --git a/include/linux/mdio.h b/include/linux/mdio.h
index dfb9479..a2dfe86 100644
--- a/include/linux/mdio.h
+++ b/include/linux/mdio.h
@@ -43,7 +43,11 @@
 #define MDIO_PKGID2		15
 #define MDIO_AN_ADVERTISE	16	/* AN advertising (base page) */
 #define MDIO_AN_LPA		19	/* AN LP abilities (base page) */
+#define MDIO_EEE_CAP		20	/* EEE Capability register */
+#define MDIO_EEE_WK_ERR		22	/* EEE wake error counter */
 #define MDIO_PHYXS_LNSTAT	24	/* PHY XGXS lane state */
+#define MDIO_EEE_ADV		60	/* EEE advertisement */
+#define MDIO_EEE_PART_LINK	61	/* EEE link partner ability */
 
 /* Media-dependent registers. */
 #define MDIO_PMA_10GBT_SWAPPOL	130	/* 10GBASE-T pair swap & polarity */
@@ -82,6 +86,7 @@
 #define MDIO_AN_CTRL1_RESTART		BMCR_ANRESTART
 #define MDIO_AN_CTRL1_ENABLE		BMCR_ANENABLE
 #define MDIO_AN_CTRL1_XNP		0x2000	/* Enable extended next page */
+#define MDIO_PCS_CLK_STOP_ENABLE	0x400	/* Stop the clock during LPI */
 
 /* 10 Gb/s */
 #define MDIO_CTRL1_SPEED10G		(MDIO_CTRL1_SPEEDSELEXT | 0x00)
diff --git a/include/linux/mii.h b/include/linux/mii.h
index 2783eca..18457add 100644
--- a/include/linux/mii.h
+++ b/include/linux/mii.h
@@ -21,6 +21,8 @@
 #define MII_EXPANSION		0x06	/* Expansion register          */
 #define MII_CTRL1000		0x09	/* 1000BASE-T control          */
 #define MII_STAT1000		0x0a	/* 1000BASE-T status           */
+#define	MII_MMD_CRTL		0x0d	/* MMD Access Control Register */
+#define	MII_MMD_DATA		0x0e	/* MMD Access Data Register */
 #define MII_ESTATUS		0x0f	/* Extended Status             */
 #define MII_DCOUNTER		0x12	/* Disconnect counter          */
 #define MII_FCSCOUNTER		0x13	/* False carrier counter       */
@@ -141,6 +143,15 @@
 #define FLOW_CTRL_TX		0x01
 #define FLOW_CTRL_RX		0x02
 
+/* MMD Access Control register fields */
+#define MII_MMD_CRTL_DEVAD_MASK			0x1f	/* Mask MMD DEVAD*/
+#define MII_MMD_CRTL_FUNC_ADDR			0x0000	/* Address */
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
index c599f7ec..2d1b0d5 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -529,6 +529,9 @@ int phy_register_fixup_for_uid(u32 phy_uid, u32 phy_uid_mask,
 		int (*run)(struct phy_device *));
 int phy_scan_fixups(struct phy_device *phydev);
 
+int phy_check_eee(struct phy_device *phydev);
+int phy_get_eee_err(struct phy_device *phydev);
+
 int __init mdio_bus_init(void);
 void mdio_bus_exit(void);
 
-- 
1.7.4.4
