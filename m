From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: [PATCH: 2.6.12-rc1] mii: Add test for GigE support
Date: Tue, 22 Mar 2005 16:17:46 -0700
Message-ID: <20050322231746.GA27770@xyzzy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>
To: Netdev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch adds the ability to test a PHY for GigE support

Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

Index: linux-2.5-enet/drivers/net/mii.c
===================================================================
--- linux-2.5-enet.orig/drivers/net/mii.c
+++ linux-2.5-enet/drivers/net/mii.c
@@ -207,6 +207,21 @@
 	return 0;
 }
 
+int mii_check_gmii_support(struct mii_if_info *mii)
+{
+	int reg;
+
+	reg = mii->mdio_read(mii->dev, mii->phy_id, MII_BMSR);
+	if (reg & BMSR_HAS_EXTSTAT1000) {
+		reg = mii->mdio_read(mii->dev, mii->phy_id, MII_EXTSTAT1000);
+		if (reg & (ESR_1000_BASE_X_FD | ESR_1000_BASE_T_FD |
+			   ESR_1000_BASE_X_HD | ESR_1000_BASE_T_HD))
+			return 1;
+	}
+
+	return 0;
+}
+
 int mii_link_ok (struct mii_if_info *mii)
 {
 	/* first, a dummy read, needed to latch some MII phys */
Index: linux-2.5-enet/include/linux/mii.h
===================================================================
--- linux-2.5-enet.orig/include/linux/mii.h
+++ linux-2.5-enet/include/linux/mii.h
@@ -22,6 +22,7 @@
 #define MII_EXPANSION       0x06        /* Expansion register          */
 #define MII_CTRL1000        0x09        /* 1000BASE-T control          */
 #define MII_STAT1000        0x0a        /* 1000BASE-T status           */
+#define MII_EXTSTAT1000     0x0f	/* 1000BASE-XX extended status */
 #define MII_DCOUNTER        0x12        /* Disconnect counter          */
 #define MII_FCSCOUNTER      0x13        /* False carrier counter       */
 #define MII_NWAYTEST        0x14        /* N-way auto-neg test reg     */
@@ -54,7 +55,8 @@
 #define BMSR_ANEGCAPABLE        0x0008  /* Able to do auto-negotiation */
 #define BMSR_RFAULT             0x0010  /* Remote fault detected       */
 #define BMSR_ANEGCOMPLETE       0x0020  /* Auto-negotiation complete   */
-#define BMSR_RESV               0x07c0  /* Unused...                   */
+#define BMSR_HAS_EXTSTAT1000    0x0100  /* Has 1000BASE extended status*/
+#define BMSR_RESV               0x06c0  /* Unused...                   */
 #define BMSR_10HALF             0x0800  /* Can do 10mbps, half-duplex  */
 #define BMSR_10FULL             0x1000  /* Can do 10mbps, full-duplex  */
 #define BMSR_100HALF            0x2000  /* Can do 100mbps, half-duplex */
@@ -121,6 +123,12 @@
 #define LPA_1000FULL            0x0800  /* Link partner 1000BASE-T full duplex */
 #define LPA_1000HALF            0x0400  /* Link partner 1000BASE-T half duplex */
 
+/* 1000BASE Ext Status register */
+#define ESR_1000_BASE_X_FD      0x8000
+#define ESR_1000_BASE_X_HD      0x4000
+#define ESR_1000_BASE_T_FD      0x2000
+#define ESR_1000_BASE_T_HD      0x1000
+
 struct mii_if_info {
 	int phy_id;
 	int advertising;
@@ -143,6 +151,7 @@
 extern int mii_nway_restart (struct mii_if_info *mii);
 extern int mii_ethtool_gset(struct mii_if_info *mii, struct ethtool_cmd *ecmd);
 extern int mii_ethtool_sset(struct mii_if_info *mii, struct ethtool_cmd *ecmd);
+extern int mii_check_gmii_support(struct mii_if_info *mii);
 extern void mii_check_link (struct mii_if_info *mii);
 extern unsigned int mii_check_media (struct mii_if_info *mii,
 				     unsigned int ok_to_print,
