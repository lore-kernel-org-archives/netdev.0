From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 0/8] Pull request for 'davem-next.r8169' branch
Date: Mon, 9 May 2011 21:02:05 +0200
Message-ID: <20110509190205.GA20677@electric-eye.fr.zoreil.com>
References: <20110509190446.GA6053@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Ciprian Docan <docan@eden.rutgers.edu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50145 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821Ab1EITLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 15:11:50 -0400
Content-Disposition: inline
In-Reply-To: <20110509190446.GA6053@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'davem-next.r8169' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git davem-next.r8169

to get the changes below.

Patches #1, #3, #4, #5 and #6 are similar to those previously posted.
Things have been modified as suggested by the reviewers (see #1 and #3).

#2 does not hurt.

#7 and #8 are new.

Individual patches follow.

Things seem ok with an old 8169, a 8168d (w/o firmware) and a mildly
identified 8168 which uses the 8168 family fallback.

Comments and testing reports are welcome.

Distance from 'davem-next.base' (706527280ec38fcdcd0466f10b607105fd23801b)
--------------------------------------------------------------------------

5d320a205de277774962782a4b1923e4f8cdf781
85bffe6ca2e2d7e9510c115aa4f11c3d4209051f
31bd204f97e3796c5cfcfc582a93a10e45b99946
56de414c0c7333f1e1adedc23057e131ce84233e
4876cc1e49efac03827a51a2422cfbbb7f6335de
826e6cbdadfa51495c7189641df2514cc48e23da
6f43adc88f49cb8164fbd665e968de4de380dc35
cecb5fd7c277c1bba161980bb41792a60b56df4a

Diffstat
--------

 drivers/net/r8169.c |  574 +++++++++++++++++++++++----------------------------
 1 files changed, 261 insertions(+), 313 deletions(-)

Shortlog
--------

Francois Romieu (8):
      r8169: style cleanups.
      r8169: remove some code duplication.
      r8169: rtl8169_set_speed_xmii cleanup.
      r8169: link speed selection timer rework.
      r8169: remove non-NAPI context invocation of rtl8169_rx_interrupt.
      r8169: provide some firmware information via ethtool.
      r8169: merge firmware information into the chipset description data.
      r8169: avoid late chip identifier initialisation.

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index a8976a7..04f4e60 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -98,40 +98,40 @@ static const int multicast_filter_limit = 32;
 #define RTL_R32(reg)		readl (ioaddr + (reg))
 
 enum mac_version {
-	RTL_GIGA_MAC_NONE   = 0x00,
-	RTL_GIGA_MAC_VER_01 = 0x01, // 8169
-	RTL_GIGA_MAC_VER_02 = 0x02, // 8169S
-	RTL_GIGA_MAC_VER_03 = 0x03, // 8110S
-	RTL_GIGA_MAC_VER_04 = 0x04, // 8169SB
-	RTL_GIGA_MAC_VER_05 = 0x05, // 8110SCd
-	RTL_GIGA_MAC_VER_06 = 0x06, // 8110SCe
-	RTL_GIGA_MAC_VER_07 = 0x07, // 8102e
-	RTL_GIGA_MAC_VER_08 = 0x08, // 8102e
-	RTL_GIGA_MAC_VER_09 = 0x09, // 8102e
-	RTL_GIGA_MAC_VER_10 = 0x0a, // 8101e
-	RTL_GIGA_MAC_VER_11 = 0x0b, // 8168Bb
-	RTL_GIGA_MAC_VER_12 = 0x0c, // 8168Be
-	RTL_GIGA_MAC_VER_13 = 0x0d, // 8101Eb
-	RTL_GIGA_MAC_VER_14 = 0x0e, // 8101 ?
-	RTL_GIGA_MAC_VER_15 = 0x0f, // 8101 ?
-	RTL_GIGA_MAC_VER_16 = 0x11, // 8101Ec
-	RTL_GIGA_MAC_VER_17 = 0x10, // 8168Bf
-	RTL_GIGA_MAC_VER_18 = 0x12, // 8168CP
-	RTL_GIGA_MAC_VER_19 = 0x13, // 8168C
-	RTL_GIGA_MAC_VER_20 = 0x14, // 8168C
-	RTL_GIGA_MAC_VER_21 = 0x15, // 8168C
-	RTL_GIGA_MAC_VER_22 = 0x16, // 8168C
-	RTL_GIGA_MAC_VER_23 = 0x17, // 8168CP
-	RTL_GIGA_MAC_VER_24 = 0x18, // 8168CP
-	RTL_GIGA_MAC_VER_25 = 0x19, // 8168D
-	RTL_GIGA_MAC_VER_26 = 0x1a, // 8168D
-	RTL_GIGA_MAC_VER_27 = 0x1b, // 8168DP
-	RTL_GIGA_MAC_VER_28 = 0x1c, // 8168DP
-	RTL_GIGA_MAC_VER_29 = 0x1d, // 8105E
-	RTL_GIGA_MAC_VER_30 = 0x1e, // 8105E
-	RTL_GIGA_MAC_VER_31 = 0x1f, // 8168DP
-	RTL_GIGA_MAC_VER_32 = 0x20, // 8168E
-	RTL_GIGA_MAC_VER_33 = 0x21, // 8168E
+	RTL_GIGA_MAC_VER_01 = 0,
+	RTL_GIGA_MAC_VER_02,
+	RTL_GIGA_MAC_VER_03,
+	RTL_GIGA_MAC_VER_04,
+	RTL_GIGA_MAC_VER_05,
+	RTL_GIGA_MAC_VER_06,
+	RTL_GIGA_MAC_VER_07,
+	RTL_GIGA_MAC_VER_08,
+	RTL_GIGA_MAC_VER_09,
+	RTL_GIGA_MAC_VER_10,
+	RTL_GIGA_MAC_VER_11,
+	RTL_GIGA_MAC_VER_12,
+	RTL_GIGA_MAC_VER_13,
+	RTL_GIGA_MAC_VER_14,
+	RTL_GIGA_MAC_VER_15,
+	RTL_GIGA_MAC_VER_16,
+	RTL_GIGA_MAC_VER_17,
+	RTL_GIGA_MAC_VER_18,
+	RTL_GIGA_MAC_VER_19,
+	RTL_GIGA_MAC_VER_20,
+	RTL_GIGA_MAC_VER_21,
+	RTL_GIGA_MAC_VER_22,
+	RTL_GIGA_MAC_VER_23,
+	RTL_GIGA_MAC_VER_24,
+	RTL_GIGA_MAC_VER_25,
+	RTL_GIGA_MAC_VER_26,
+	RTL_GIGA_MAC_VER_27,
+	RTL_GIGA_MAC_VER_28,
+	RTL_GIGA_MAC_VER_29,
+	RTL_GIGA_MAC_VER_30,
+	RTL_GIGA_MAC_VER_31,
+	RTL_GIGA_MAC_VER_32,
+	RTL_GIGA_MAC_VER_33,
+	RTL_GIGA_MAC_NONE   = 0xff,
 };
 
 enum rtl_tx_desc_version {
@@ -139,61 +139,84 @@ enum rtl_tx_desc_version {
 	RTL_TD_1	= 1,
 };
 
-#define _R(NAME,MAC,TD) \
-	{ .name = NAME, .mac_version = MAC, .txd_version = TD }
+#define _R(NAME,TD,FW) \
+	{ .name = NAME, .txd_version = TD, .fw_name = FW }
 
 static const struct {
 	const char *name;
-	u8 mac_version;
 	enum rtl_tx_desc_version txd_version;
-} rtl_chip_info[] = {
-	_R("RTL8169",		RTL_GIGA_MAC_VER_01, RTL_TD_0), // 8169
-	_R("RTL8169s",		RTL_GIGA_MAC_VER_02, RTL_TD_0), // 8169S
-	_R("RTL8110s",		RTL_GIGA_MAC_VER_03, RTL_TD_0), // 8110S
-	_R("RTL8169sb/8110sb",	RTL_GIGA_MAC_VER_04, RTL_TD_0), // 8169SB
-	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_05, RTL_TD_0), // 8110SCd
-	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_06, RTL_TD_0), // 8110SCe
-	_R("RTL8102e",		RTL_GIGA_MAC_VER_07, RTL_TD_1), // PCI-E
-	_R("RTL8102e",		RTL_GIGA_MAC_VER_08, RTL_TD_1), // PCI-E
-	_R("RTL8102e",		RTL_GIGA_MAC_VER_09, RTL_TD_1), // PCI-E
-	_R("RTL8101e",		RTL_GIGA_MAC_VER_10, RTL_TD_0), // PCI-E
-	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_11, RTL_TD_0), // PCI-E
-	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_12, RTL_TD_0), // PCI-E
-	_R("RTL8101e",		RTL_GIGA_MAC_VER_13, RTL_TD_0), // PCI-E 8139
-	_R("RTL8100e",		RTL_GIGA_MAC_VER_14, RTL_TD_0), // PCI-E 8139
-	_R("RTL8100e",		RTL_GIGA_MAC_VER_15, RTL_TD_0), // PCI-E 8139
-	_R("RTL8168b/8111b",	RTL_GIGA_MAC_VER_17, RTL_TD_0), // PCI-E
-	_R("RTL8101e",		RTL_GIGA_MAC_VER_16, RTL_TD_0), // PCI-E
-	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_18, RTL_TD_1), // PCI-E
-	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_19, RTL_TD_1), // PCI-E
-	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_20, RTL_TD_1), // PCI-E
-	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_21, RTL_TD_1), // PCI-E
-	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_22, RTL_TD_1), // PCI-E
-	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_23, RTL_TD_1), // PCI-E
-	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_24, RTL_TD_1), // PCI-E
-	_R("RTL8168d/8111d",	RTL_GIGA_MAC_VER_25, RTL_TD_1), // PCI-E
-	_R("RTL8168d/8111d",	RTL_GIGA_MAC_VER_26, RTL_TD_1), // PCI-E
-	_R("RTL8168dp/8111dp",	RTL_GIGA_MAC_VER_27, RTL_TD_1), // PCI-E
-	_R("RTL8168dp/8111dp",	RTL_GIGA_MAC_VER_28, RTL_TD_1), // PCI-E
-	_R("RTL8105e",		RTL_GIGA_MAC_VER_29, RTL_TD_1), // PCI-E
-	_R("RTL8105e",		RTL_GIGA_MAC_VER_30, RTL_TD_1), // PCI-E
-	_R("RTL8168dp/8111dp",	RTL_GIGA_MAC_VER_31, RTL_TD_1), // PCI-E
-	_R("RTL8168e/8111e",	RTL_GIGA_MAC_VER_32, RTL_TD_1), // PCI-E
-	_R("RTL8168e/8111e",	RTL_GIGA_MAC_VER_33, RTL_TD_1)  // PCI-E
-};
-#undef _R
-
-static const struct rtl_firmware_info {
-	int mac_version;
 	const char *fw_name;
-} rtl_firmware_infos[] = {
-	{ .mac_version = RTL_GIGA_MAC_VER_25, .fw_name = FIRMWARE_8168D_1 },
-	{ .mac_version = RTL_GIGA_MAC_VER_26, .fw_name = FIRMWARE_8168D_2 },
-	{ .mac_version = RTL_GIGA_MAC_VER_29, .fw_name = FIRMWARE_8105E_1 },
-	{ .mac_version = RTL_GIGA_MAC_VER_30, .fw_name = FIRMWARE_8105E_1 },
-	{ .mac_version = RTL_GIGA_MAC_VER_32, .fw_name = FIRMWARE_8168E_1 },
-	{ .mac_version = RTL_GIGA_MAC_VER_33, .fw_name = FIRMWARE_8168E_2 }
+} rtl_chip_infos[] = {
+	/* PCI devices. */
+	[RTL_GIGA_MAC_VER_01] =
+		_R("RTL8169",		RTL_TD_0, NULL),
+	[RTL_GIGA_MAC_VER_02] =
+		_R("RTL8169s",		RTL_TD_0, NULL),
+	[RTL_GIGA_MAC_VER_03] =
+		_R("RTL8110s",		RTL_TD_0, NULL),
+	[RTL_GIGA_MAC_VER_04] =
+		_R("RTL8169sb/8110sb",	RTL_TD_0, NULL),
+	[RTL_GIGA_MAC_VER_05] =
+		_R("RTL8169sc/8110sc",	RTL_TD_0, NULL),
+	[RTL_GIGA_MAC_VER_06] =
+		_R("RTL8169sc/8110sc",	RTL_TD_0, NULL),
+	/* PCI-E devices. */
+	[RTL_GIGA_MAC_VER_07] =
+		_R("RTL8102e",		RTL_TD_1, NULL),
+	[RTL_GIGA_MAC_VER_08] =
+		_R("RTL8102e",		RTL_TD_1, NULL),
+	[RTL_GIGA_MAC_VER_09] =
+		_R("RTL8102e",		RTL_TD_1, NULL),
+	[RTL_GIGA_MAC_VER_10] =
+		_R("RTL8101e",		RTL_TD_0, NULL),
+	[RTL_GIGA_MAC_VER_11] =
+		_R("RTL8168b/8111b",	RTL_TD_0, NULL),
+	[RTL_GIGA_MAC_VER_12] =
+		_R("RTL8168b/8111b",	RTL_TD_0, NULL),
+	[RTL_GIGA_MAC_VER_13] =
+		_R("RTL8101e",		RTL_TD_0, NULL),
+	[RTL_GIGA_MAC_VER_14] =
+		_R("RTL8100e",		RTL_TD_0, NULL),
+	[RTL_GIGA_MAC_VER_15] =
+		_R("RTL8100e",		RTL_TD_0, NULL),
+	[RTL_GIGA_MAC_VER_16] =
+		_R("RTL8101e",		RTL_TD_0, NULL),
+	[RTL_GIGA_MAC_VER_17] =
+		_R("RTL8168b/8111b",	RTL_TD_0, NULL),
+	[RTL_GIGA_MAC_VER_18] =
+		_R("RTL8168cp/8111cp",	RTL_TD_1, NULL),
+	[RTL_GIGA_MAC_VER_19] =
+		_R("RTL8168c/8111c",	RTL_TD_1, NULL),
+	[RTL_GIGA_MAC_VER_20] =
+		_R("RTL8168c/8111c",	RTL_TD_1, NULL),
+	[RTL_GIGA_MAC_VER_21] =
+		_R("RTL8168c/8111c",	RTL_TD_1, NULL),
+	[RTL_GIGA_MAC_VER_22] =
+		_R("RTL8168c/8111c",	RTL_TD_1, NULL),
+	[RTL_GIGA_MAC_VER_23] =
+		_R("RTL8168cp/8111cp",	RTL_TD_1, NULL),
+	[RTL_GIGA_MAC_VER_24] =
+		_R("RTL8168cp/8111cp",	RTL_TD_1, NULL),
+	[RTL_GIGA_MAC_VER_25] =
+		_R("RTL8168d/8111d",	RTL_TD_1, FIRMWARE_8168D_1),
+	[RTL_GIGA_MAC_VER_26] =
+		_R("RTL8168d/8111d",	RTL_TD_1, FIRMWARE_8168D_2),
+	[RTL_GIGA_MAC_VER_27] =
+		_R("RTL8168dp/8111dp",	RTL_TD_1, NULL),
+	[RTL_GIGA_MAC_VER_28] =
+		_R("RTL8168dp/8111dp",	RTL_TD_1, NULL),
+	[RTL_GIGA_MAC_VER_29] =
+		_R("RTL8105e",		RTL_TD_1, FIRMWARE_8105E_1),
+	[RTL_GIGA_MAC_VER_30] =
+		_R("RTL8105e",		RTL_TD_1, FIRMWARE_8105E_1),
+	[RTL_GIGA_MAC_VER_31] =
+		_R("RTL8168dp/8111dp",	RTL_TD_1, NULL),
+	[RTL_GIGA_MAC_VER_32] =
+		_R("RTL8168e/8111e",	RTL_TD_1, FIRMWARE_8168E_1),
+	[RTL_GIGA_MAC_VER_33] =
+		_R("RTL8168e/8111e",	RTL_TD_1, FIRMWARE_8168E_2)
 };
+#undef _R
 
 enum cfg_version {
 	RTL_CFG_0 = 0x00,
@@ -345,7 +368,7 @@ enum rtl8168_registers {
 #define OCPAR_GPHY_READ_CMD		0x0000f060
 	RDSAR1			= 0xd0,	/* 8168c only. Undocumented on 8168dp */
 	MISC			= 0xf0,	/* 8168e only. */
-	txpla_rst			= (1 << 29)
+#define TXPLA_RST			(1 << 29)
 };
 
 enum rtl_register_content {
@@ -423,7 +446,7 @@ enum rtl_register_content {
 	BWF		= (1 << 6),	/* Accept Broadcast wakeup frame */
 	MWF		= (1 << 5),	/* Accept Multicast wakeup frame */
 	UWF		= (1 << 4),	/* Accept Unicast wakeup frame */
-	spi_en		= (1 << 3),
+	Spi_en		= (1 << 3),
 	LanWake		= (1 << 1),	/* LanWake enable/disable */
 	PMEStatus	= (1 << 0),	/* PME status can be reset by PCI RST# */
 
@@ -594,10 +617,10 @@ struct rtl8169_counters {
 
 struct rtl8169_private {
 	void __iomem *mmio_addr;	/* memory map physical address */
-	struct pci_dev *pci_dev;	/* Index of PCI device */
+	struct pci_dev *pci_dev;
 	struct net_device *dev;
 	struct napi_struct napi;
-	spinlock_t lock;		/* spin lock flag */
+	spinlock_t lock;
 	u32 msg_enable;
 	u16 txd_version;
 	u16 mac_version;
@@ -616,7 +639,6 @@ struct rtl8169_private {
 	u16 intr_event;
 	u16 napi_event;
 	u16 intr_mask;
-	int phy_1000_ctrl_reg;
 
 	struct mdio_ops {
 		void (*write)(void __iomem *, int, int);
@@ -730,17 +752,19 @@ static void rtl8168_oob_notify(struct rtl8169_private *tp, u8 cmd)
 #define OOB_CMD_DRIVER_START	0x05
 #define OOB_CMD_DRIVER_STOP	0x06
 
+static u16 rtl8168_get_ocp_reg(struct rtl8169_private *tp)
+{
+	return (tp->mac_version == RTL_GIGA_MAC_VER_31) ? 0xb8 : 0x10;
+}
+
 static void rtl8168_driver_start(struct rtl8169_private *tp)
 {
+	u16 reg;
 	int i;
-	u32 reg;
 
 	rtl8168_oob_notify(tp, OOB_CMD_DRIVER_START);
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_31)
-		reg = 0xb8;
-	else
-		reg = 0x10;
+	reg = rtl8168_get_ocp_reg(tp);
 
 	for (i = 0; i < 10; i++) {
 		msleep(10);
@@ -751,15 +775,12 @@ static void rtl8168_driver_start(struct rtl8169_private *tp)
 
 static void rtl8168_driver_stop(struct rtl8169_private *tp)
 {
+	u16 reg;
 	int i;
-	u32 reg;
 
 	rtl8168_oob_notify(tp, OOB_CMD_DRIVER_STOP);
 
-	if (tp->mac_version == RTL_GIGA_MAC_VER_31)
-		reg = 0xb8;
-	else
-		reg = 0x10;
+	reg = rtl8168_get_ocp_reg(tp);
 
 	for (i = 0; i < 10; i++) {
 		msleep(10);
@@ -770,17 +791,9 @@ static void rtl8168_driver_stop(struct rtl8169_private *tp)
 
 static int r8168dp_check_dash(struct rtl8169_private *tp)
 {
-	u32 reg;
-
-	if (tp->mac_version == RTL_GIGA_MAC_VER_31)
-		reg = 0xb8;
-	else
-		reg = 0x10;
+	u16 reg = rtl8168_get_ocp_reg(tp);
 
-	if (ocp_read(tp, 0xF, reg) & 0x00008000)
-		return 1;
-	else
-		return 0;
+	return (ocp_read(tp, 0x0f, reg) & 0x00008000) ? 1 : 0;
 }
 
 static void r8169_mdio_write(void __iomem *ioaddr, int reg_addr, int value)
@@ -1080,9 +1093,8 @@ static void rtl8169_xmii_reset_enable(struct rtl8169_private *tp)
 }
 
 static void __rtl8169_check_link_status(struct net_device *dev,
-				      struct rtl8169_private *tp,
-				      void __iomem *ioaddr,
-				      bool pm)
+					struct rtl8169_private *tp,
+					void __iomem *ioaddr, bool pm)
 {
 	unsigned long flags;
 
@@ -1199,6 +1211,11 @@ static int rtl8169_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 	return 0;
 }
 
+static const char *rtl_lookup_firmware_name(struct rtl8169_private *tp)
+{
+	return rtl_chip_infos[tp->mac_version].fw_name;
+}
+
 static void rtl8169_get_drvinfo(struct net_device *dev,
 				struct ethtool_drvinfo *info)
 {
@@ -1207,6 +1224,8 @@ static void rtl8169_get_drvinfo(struct net_device *dev,
 	strcpy(info->driver, MODULENAME);
 	strcpy(info->version, RTL8169_VERSION);
 	strcpy(info->bus_info, pci_name(tp->pci_dev));
+	strncpy(info->fw_version, IS_ERR_OR_NULL(tp->fw) ? "N/A" :
+		rtl_lookup_firmware_name(tp), sizeof(info->fw_version) - 1);
 }
 
 static int rtl8169_get_regs_len(struct net_device *dev)
@@ -1268,16 +1287,7 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 		giga_ctrl &= ~(ADVERTISE_1000FULL | ADVERTISE_1000HALF);
 
 		/* The 8100e/8101e/8102e do Fast Ethernet only. */
-		if ((tp->mac_version != RTL_GIGA_MAC_VER_07) &&
-		    (tp->mac_version != RTL_GIGA_MAC_VER_08) &&
-		    (tp->mac_version != RTL_GIGA_MAC_VER_09) &&
-		    (tp->mac_version != RTL_GIGA_MAC_VER_10) &&
-		    (tp->mac_version != RTL_GIGA_MAC_VER_13) &&
-		    (tp->mac_version != RTL_GIGA_MAC_VER_14) &&
-		    (tp->mac_version != RTL_GIGA_MAC_VER_15) &&
-		    (tp->mac_version != RTL_GIGA_MAC_VER_16) &&
-		    (tp->mac_version != RTL_GIGA_MAC_VER_29) &&
-		    (tp->mac_version != RTL_GIGA_MAC_VER_30)) {
+		if (tp->mii.supports_gmii) {
 			if (adv & ADVERTISED_1000baseT_Half)
 				giga_ctrl |= ADVERTISE_1000HALF;
 			if (adv & ADVERTISED_1000baseT_Full)
@@ -1307,12 +1317,10 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 			bmcr |= BMCR_FULLDPLX;
 	}
 
-	tp->phy_1000_ctrl_reg = giga_ctrl;
-
 	rtl_writephy(tp, MII_BMCR, bmcr);
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_02) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_03)) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_02 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_03) {
 		if ((speed == SPEED_100) && (autoneg != AUTONEG_ENABLE)) {
 			rtl_writephy(tp, 0x17, 0x2138);
 			rtl_writephy(tp, 0x0e, 0x0260);
@@ -1334,10 +1342,14 @@ static int rtl8169_set_speed(struct net_device *dev,
 	int ret;
 
 	ret = tp->set_speed(dev, autoneg, speed, duplex, advertising);
+	if (ret < 0)
+		goto out;
 
-	if (netif_running(dev) && (tp->phy_1000_ctrl_reg & ADVERTISE_1000FULL))
+	if (netif_running(dev) && (autoneg == AUTONEG_ENABLE) &&
+	    (advertising & ADVERTISED_1000baseT_Full)) {
 		mod_timer(&tp->timer, jiffies + RTL8169_PHY_TIMEOUT);
-
+	}
+out:
 	return ret;
 }
 
@@ -1347,9 +1359,10 @@ static int rtl8169_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	unsigned long flags;
 	int ret;
 
+	del_timer_sync(&tp->timer);
+
 	spin_lock_irqsave(&tp->lock, flags);
-	ret = rtl8169_set_speed(dev,
-				cmd->autoneg, ethtool_cmd_speed(cmd),
+	ret = rtl8169_set_speed(dev, cmd->autoneg, ethtool_cmd_speed(cmd),
 				cmd->duplex, cmd->advertising);
 	spin_unlock_irqrestore(&tp->lock, flags);
 
@@ -1507,11 +1520,11 @@ static void rtl8169_update_counters(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
+	struct device *d = &tp->pci_dev->dev;
 	struct rtl8169_counters *counters;
 	dma_addr_t paddr;
 	u32 cmd;
 	int wait = 1000;
-	struct device *d = &tp->pci_dev->dev;
 
 	/*
 	 * Some chips are unable to dump tally counters when the receiver
@@ -1531,7 +1544,6 @@ static void rtl8169_update_counters(struct net_device *dev)
 
 	while (wait--) {
 		if ((RTL_R32(CounterAddrLow) & CounterDump) == 0) {
-			/* copy updated counters */
 			memcpy(&tp->counters, counters, sizeof(*counters));
 			break;
 		}
@@ -1594,8 +1606,9 @@ static const struct ethtool_ops rtl8169_ethtool_ops = {
 };
 
 static void rtl8169_get_mac_version(struct rtl8169_private *tp,
-				    void __iomem *ioaddr)
+				    struct net_device *dev, u8 default_version)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
 	/*
 	 * The driver currently handles the 8168Bf and the 8168Be identically
 	 * but they can be identified more specifically through the test below
@@ -1682,6 +1695,12 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 	while ((reg & p->mask) != p->val)
 		p++;
 	tp->mac_version = p->mac_version;
+
+	if (tp->mac_version == RTL_GIGA_MAC_NONE) {
+		netif_notice(tp, probe, dev,
+			     "unknown MAC, using family default\n");
+		tp->mac_version = default_version;
+	}
 }
 
 static void rtl8169_print_mac_version(struct rtl8169_private *tp)
@@ -1751,14 +1770,14 @@ rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
 		case PHY_BJMPN:
 			if (regno > index) {
 				netif_err(tp, probe, tp->dev,
-					"Out of range of firmware\n");
+					  "Out of range of firmware\n");
 				return;
 			}
 			break;
 		case PHY_READCOUNT_EQ_SKIP:
 			if (index + 2 >= fw_size) {
 				netif_err(tp, probe, tp->dev,
-					"Out of range of firmware\n");
+					  "Out of range of firmware\n");
 				return;
 			}
 			break;
@@ -1767,7 +1786,7 @@ rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
 		case PHY_SKIPN:
 			if (index + 1 + regno >= fw_size) {
 				netif_err(tp, probe, tp->dev,
-					"Out of range of firmware\n");
+					  "Out of range of firmware\n");
 				return;
 			}
 			break;
@@ -1823,10 +1842,7 @@ rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
 			index++;
 			break;
 		case PHY_READCOUNT_EQ_SKIP:
-			if (count == data)
-				index += 2;
-			else
-				index += 1;
+			index += (count == data) ? 2 : 1;
 			break;
 		case PHY_COMP_EQ_SKIPN:
 			if (predata == data)
@@ -2237,7 +2253,7 @@ static void rtl8168d_1_hw_phy_config(struct rtl8169_private *tp)
 
 		/*
 		 * Tx Error Issue
-		 * enhance line driver power
+		 * Enhance line driver power
 		 */
 		{ 0x1f, 0x0002 },
 		{ 0x06, 0x5561 },
@@ -2349,7 +2365,7 @@ static void rtl8168d_2_hw_phy_config(struct rtl8169_private *tp)
 
 		/*
 		 * Tx Error Issue
-		 * enhance line driver power
+		 * Enhance line driver power
 		 */
 		{ 0x1f, 0x0002 },
 		{ 0x06, 0x5561 },
@@ -2548,7 +2564,7 @@ static void rtl8168e_hw_phy_config(struct rtl8169_private *tp)
 	/* For impedance matching */
 	rtl_writephy(tp, 0x1f, 0x0002);
 	rtl_w1w0_phy(tp, 0x08, 0x8000, 0x7f00);
-	rtl_writephy(tp, 0x1F, 0x0000);
+	rtl_writephy(tp, 0x1f, 0x0000);
 
 	/* PHY auto speed down */
 	rtl_writephy(tp, 0x1f, 0x0007);
@@ -2692,6 +2708,9 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_30:
 		rtl8105e_hw_phy_config(tp);
 		break;
+	case RTL_GIGA_MAC_VER_31:
+		/* None. */
+		break;
 	case RTL_GIGA_MAC_VER_32:
 	case RTL_GIGA_MAC_VER_33:
 		rtl8168e_hw_phy_config(tp);
@@ -2712,9 +2731,6 @@ static void rtl8169_phy_timer(unsigned long __opaque)
 
 	assert(tp->mac_version > RTL_GIGA_MAC_VER_01);
 
-	if (!(tp->phy_1000_ctrl_reg & ADVERTISE_1000FULL))
-		return;
-
 	spin_lock_irq(&tp->lock);
 
 	if (tp->phy_reset_pending(tp)) {
@@ -2739,28 +2755,6 @@ out_unlock:
 	spin_unlock_irq(&tp->lock);
 }
 
-static inline void rtl8169_delete_timer(struct net_device *dev)
-{
-	struct rtl8169_private *tp = netdev_priv(dev);
-	struct timer_list *timer = &tp->timer;
-
-	if (tp->mac_version <= RTL_GIGA_MAC_VER_01)
-		return;
-
-	del_timer_sync(timer);
-}
-
-static inline void rtl8169_request_timer(struct net_device *dev)
-{
-	struct rtl8169_private *tp = netdev_priv(dev);
-	struct timer_list *timer = &tp->timer;
-
-	if (tp->mac_version <= RTL_GIGA_MAC_VER_01)
-		return;
-
-	mod_timer(timer, jiffies + RTL8169_PHY_TIMEOUT);
-}
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 /*
  * Polling 'interrupt' - used by things like netconsole to send skbs
@@ -2828,11 +2822,11 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 	rtl8169_phy_reset(dev, tp);
 
 	rtl8169_set_speed(dev, AUTONEG_ENABLE, SPEED_1000, DUPLEX_FULL,
-		ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full |
-		ADVERTISED_100baseT_Half | ADVERTISED_100baseT_Full |
-		(tp->mii.supports_gmii ?
-			ADVERTISED_1000baseT_Half |
-			ADVERTISED_1000baseT_Full : 0));
+			  ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full |
+			  ADVERTISED_100baseT_Half | ADVERTISED_100baseT_Full |
+			  (tp->mii.supports_gmii ?
+			   ADVERTISED_1000baseT_Half |
+			   ADVERTISED_1000baseT_Full : 0));
 
 	if (RTL_R8(PHYstatus) & TBI_Enable)
 		netif_info(tp, link, dev, "TBI auto-negotiating\n");
@@ -2885,7 +2879,8 @@ static int rtl8169_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return netif_running(dev) ? tp->do_ioctl(tp, data, cmd) : -ENODEV;
 }
 
-static int rtl_xmii_ioctl(struct rtl8169_private *tp, struct mii_ioctl_data *data, int cmd)
+static int rtl_xmii_ioctl(struct rtl8169_private *tp,
+			  struct mii_ioctl_data *data, int cmd)
 {
 	switch (cmd) {
 	case SIOCGMIIPHY:
@@ -3107,15 +3102,15 @@ static void r8168_pll_power_down(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	if (((tp->mac_version == RTL_GIGA_MAC_VER_27) ||
-	     (tp->mac_version == RTL_GIGA_MAC_VER_28) ||
-	     (tp->mac_version == RTL_GIGA_MAC_VER_31)) &&
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_27 ||
+	     tp->mac_version == RTL_GIGA_MAC_VER_28 ||
+	     tp->mac_version == RTL_GIGA_MAC_VER_31) &&
 	    r8168dp_check_dash(tp)) {
 		return;
 	}
 
-	if (((tp->mac_version == RTL_GIGA_MAC_VER_23) ||
-	     (tp->mac_version == RTL_GIGA_MAC_VER_24)) &&
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_23 ||
+	     tp->mac_version == RTL_GIGA_MAC_VER_24) &&
 	    (RTL_R16(CPlusCmd) & ASF)) {
 		return;
 	}
@@ -3152,9 +3147,9 @@ static void r8168_pll_power_up(struct rtl8169_private *tp)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	if (((tp->mac_version == RTL_GIGA_MAC_VER_27) ||
-	     (tp->mac_version == RTL_GIGA_MAC_VER_28) ||
-	     (tp->mac_version == RTL_GIGA_MAC_VER_31)) &&
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_27 ||
+	     tp->mac_version == RTL_GIGA_MAC_VER_28 ||
+	     tp->mac_version == RTL_GIGA_MAC_VER_31) &&
 	    r8168dp_check_dash(tp)) {
 		return;
 	}
@@ -3235,6 +3230,22 @@ static void __devinit rtl_init_pll_power_ops(struct rtl8169_private *tp)
 	}
 }
 
+static void rtl_hw_reset(struct rtl8169_private *tp)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	int i;
+
+	/* Soft reset the chip. */
+	RTL_W8(ChipCmd, CmdReset);
+
+	/* Check that the chip has finished the reset. */
+	for (i = 0; i < 100; i++) {
+		if ((RTL_R8(ChipCmd) & CmdReset) == 0)
+			break;
+		msleep_interruptible(1);
+	}
+}
+
 static int __devinit
 rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -3334,6 +3345,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		rc = -EIO;
 		goto err_out_free_res_3;
 	}
+	tp->mmio_addr = ioaddr;
 
 	tp->pcie_cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
 	if (!tp->pcie_cap)
@@ -3341,22 +3353,14 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	RTL_W16(IntrMask, 0x0000);
 
-	/* Soft reset the chip. */
-	RTL_W8(ChipCmd, CmdReset);
-
-	/* Check that the chip has finished the reset. */
-	for (i = 0; i < 100; i++) {
-		if ((RTL_R8(ChipCmd) & CmdReset) == 0)
-			break;
-		msleep_interruptible(1);
-	}
+	rtl_hw_reset(tp);
 
 	RTL_W16(IntrStatus, 0xffff);
 
 	pci_set_master(pdev);
 
 	/* Identify chip attached to board */
-	rtl8169_get_mac_version(tp, ioaddr);
+	rtl8169_get_mac_version(tp, dev, cfg->default_ver);
 
 	/*
 	 * Pretend we are using VLANs; This bypasses a nasty bug where
@@ -3368,26 +3372,10 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	rtl_init_mdio_ops(tp);
 	rtl_init_pll_power_ops(tp);
 
-	/* Use appropriate default if unknown */
-	if (tp->mac_version == RTL_GIGA_MAC_NONE) {
-		netif_notice(tp, probe, dev,
-			     "unknown MAC, using family default\n");
-		tp->mac_version = cfg->default_ver;
-	}
-
 	rtl8169_print_mac_version(tp);
 
-	for (i = 0; i < ARRAY_SIZE(rtl_chip_info); i++) {
-		if (tp->mac_version == rtl_chip_info[i].mac_version)
-			break;
-	}
-	if (i == ARRAY_SIZE(rtl_chip_info)) {
-		dev_err(&pdev->dev,
-			"driver bug, MAC version not found in rtl_chip_info\n");
-		goto err_out_msi_4;
-	}
-	chipset = i;
-	tp->txd_version = rtl_chip_info[chipset].txd_version;
+	chipset = tp->mac_version;
+	tp->txd_version = rtl_chip_infos[chipset].txd_version;
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 	RTL_W8(Config1, RTL_R8(Config1) | PMEnable);
@@ -3407,8 +3395,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		tp->phy_reset_pending = rtl8169_tbi_reset_pending;
 		tp->link_ok = rtl8169_tbi_link_ok;
 		tp->do_ioctl = rtl_tbi_ioctl;
-
-		tp->phy_1000_ctrl_reg = ADVERTISE_1000FULL; /* Implied by TBI */
 	} else {
 		tp->set_speed = rtl8169_set_speed_xmii;
 		tp->get_settings = rtl8169_gset_xmii;
@@ -3420,8 +3406,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	spin_lock_init(&tp->lock);
 
-	tp->mmio_addr = ioaddr;
-
 	/* Get MAC address */
 	for (i = 0; i < MAC_ADDR_LEN; i++)
 		dev->dev_addr[i] = RTL_R8(MAC0 + i);
@@ -3466,12 +3450,12 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	pci_set_drvdata(pdev, dev);
 
 	netif_info(tp, probe, dev, "%s at 0x%lx, %pM, XID %08x IRQ %d\n",
-		   rtl_chip_info[chipset].name, dev->base_addr, dev->dev_addr,
+		   rtl_chip_infos[chipset].name, dev->base_addr, dev->dev_addr,
 		   (u32)(RTL_R32(TxConfig) & 0x9cf0f8ff), dev->irq);
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_27) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_28) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_31)) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
 		rtl8168_driver_start(tp);
 	}
 
@@ -3503,9 +3487,9 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_27) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_28) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_31)) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_27 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_28 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_31) {
 		rtl8168_driver_stop(tp);
 	}
 
@@ -3528,33 +3512,23 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
 
 static void rtl_request_firmware(struct rtl8169_private *tp)
 {
-	int i;
-
 	/* Return early if the firmware is already loaded / cached. */
-	if (!IS_ERR(tp->fw))
-		goto out;
-
-	for (i = 0; i < ARRAY_SIZE(rtl_firmware_infos); i++) {
-		const struct rtl_firmware_info *info = rtl_firmware_infos + i;
+	if (IS_ERR(tp->fw)) {
+		const char *name;
 
-		if (info->mac_version == tp->mac_version) {
-			const char *name = info->fw_name;
+		name = rtl_lookup_firmware_name(tp);
+		if (name) {
 			int rc;
 
 			rc = request_firmware(&tp->fw, name, &tp->pci_dev->dev);
-			if (rc < 0) {
-				netif_warn(tp, ifup, tp->dev, "unable to load "
-					"firmware patch %s (%d)\n", name, rc);
-				goto out_disable_request_firmware;
-			}
-			goto out;
+			if (rc >= 0)
+				return;
+
+			netif_warn(tp, ifup, tp->dev, "unable to load "
+				"firmware patch %s (%d)\n", name, rc);
 		}
+		tp->fw = NULL;
 	}
-
-out_disable_request_firmware:
-	tp->fw = NULL;
-out:
-	return;
 }
 
 static int rtl8169_open(struct net_device *dev)
@@ -3606,8 +3580,6 @@ static int rtl8169_open(struct net_device *dev)
 
 	rtl_hw_start(dev);
 
-	rtl8169_request_timer(dev);
-
 	tp->saved_wolopts = 0;
 	pm_runtime_put_noidle(&pdev->dev);
 
@@ -3669,25 +3641,14 @@ static void rtl_set_rx_tx_config_registers(struct rtl8169_private *tp)
 static void rtl_hw_start(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	void __iomem *ioaddr = tp->mmio_addr;
-	unsigned int i;
-
-	/* Soft reset the chip. */
-	RTL_W8(ChipCmd, CmdReset);
 
-	/* Check that the chip has finished the reset. */
-	for (i = 0; i < 100; i++) {
-		if ((RTL_R8(ChipCmd) & CmdReset) == 0)
-			break;
-		msleep_interruptible(1);
-	}
+	rtl_hw_reset(tp);
 
 	tp->hw_start(dev);
 
 	netif_start_queue(dev);
 }
 
-
 static void rtl_set_rx_tx_desc_registers(struct rtl8169_private *tp,
 					 void __iomem *ioaddr)
 {
@@ -3753,26 +3714,26 @@ static void rtl_hw_start_8169(struct net_device *dev)
 	}
 
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_01) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_02) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_03) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_04))
+	if (tp->mac_version == RTL_GIGA_MAC_VER_01 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_02 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_03 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_04)
 		RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 
 	RTL_W8(EarlyTxThres, NoEarlyTx);
 
 	rtl_set_rx_max_size(ioaddr, rx_buf_sz);
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_01) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_02) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_03) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_04))
+	if (tp->mac_version == RTL_GIGA_MAC_VER_01 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_02 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_03 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_04)
 		rtl_set_rx_tx_config_registers(tp);
 
 	tp->cp_cmd |= rtl_rw_cpluscmd(ioaddr) | PCIMulRW;
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_02) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_03)) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_02 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_03) {
 		dprintk("Set MAC Reg C+CR Offset 0xE0. "
 			"Bit-3 and bit-14 MUST be 1\n");
 		tp->cp_cmd |= (1 << 14);
@@ -3790,10 +3751,10 @@ static void rtl_hw_start_8169(struct net_device *dev)
 
 	rtl_set_rx_tx_desc_registers(tp, ioaddr);
 
-	if ((tp->mac_version != RTL_GIGA_MAC_VER_01) &&
-	    (tp->mac_version != RTL_GIGA_MAC_VER_02) &&
-	    (tp->mac_version != RTL_GIGA_MAC_VER_03) &&
-	    (tp->mac_version != RTL_GIGA_MAC_VER_04)) {
+	if (tp->mac_version != RTL_GIGA_MAC_VER_01 &&
+	    tp->mac_version != RTL_GIGA_MAC_VER_02 &&
+	    tp->mac_version != RTL_GIGA_MAC_VER_03 &&
+	    tp->mac_version != RTL_GIGA_MAC_VER_04) {
 		RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 		rtl_set_rx_tx_config_registers(tp);
 	}
@@ -4103,10 +4064,10 @@ static void rtl_hw_start_8168e(void __iomem *ioaddr, struct pci_dev *pdev)
 	rtl_disable_clock_request(pdev);
 
 	/* Reset tx FIFO pointer */
-	RTL_W32(MISC, RTL_R32(MISC) | txpla_rst);
-	RTL_W32(MISC, RTL_R32(MISC) & ~txpla_rst);
+	RTL_W32(MISC, RTL_R32(MISC) | TXPLA_RST);
+	RTL_W32(MISC, RTL_R32(MISC) & ~TXPLA_RST);
 
-	RTL_W8(Config5, RTL_R8(Config5) & ~spi_en);
+	RTL_W8(Config5, RTL_R8(Config5) & ~Spi_en);
 }
 
 static void rtl_hw_start_8168(struct net_device *dev)
@@ -4190,6 +4151,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_28:
 		rtl_hw_start_8168d_4(ioaddr, pdev);
 		break;
+
 	case RTL_GIGA_MAC_VER_31:
 		rtl_hw_start_8168dp(ioaddr, pdev);
 		break;
@@ -4286,10 +4248,10 @@ static void rtl_hw_start_8105e_1(void __iomem *ioaddr, struct pci_dev *pdev)
 		{ 0x0a,	0, 0x0020 }
 	};
 
-	/* Force LAN exit from ASPM if Rx/Tx are not idel */
+	/* Force LAN exit from ASPM if Rx/Tx are not idle */
 	RTL_W32(FuncEvent, RTL_R32(FuncEvent) | 0x002800);
 
-	/* disable Early Tally Counter */
+	/* Disable Early Tally Counter */
 	RTL_W32(FuncEvent, RTL_R32(FuncEvent) & ~0x010000);
 
 	RTL_W8(MCU, RTL_R8(MCU) | EN_NDP | EN_OOB_RESET);
@@ -4310,8 +4272,8 @@ static void rtl_hw_start_8101(struct net_device *dev)
 	void __iomem *ioaddr = tp->mmio_addr;
 	struct pci_dev *pdev = tp->pci_dev;
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_13) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_16)) {
+	if (tp->mac_version == RTL_GIGA_MAC_VER_13 ||
+	    tp->mac_version == RTL_GIGA_MAC_VER_16) {
 		int cap = tp->pcie_cap;
 
 		if (cap) {
@@ -4613,6 +4575,7 @@ static void rtl8169_reset_task(struct work_struct *work)
 	struct rtl8169_private *tp =
 		container_of(work, struct rtl8169_private, task.work);
 	struct net_device *dev = tp->dev;
+	int i;
 
 	rtnl_lock();
 
@@ -4621,19 +4584,15 @@ static void rtl8169_reset_task(struct work_struct *work)
 
 	rtl8169_wait_for_quiescence(dev);
 
-	rtl8169_rx_interrupt(dev, tp, tp->mmio_addr, ~(u32)0);
+	for (i = 0; i < NUM_RX_DESC; i++)
+		rtl8169_mark_to_asic(tp->RxDescArray + i, rx_buf_sz);
+
 	rtl8169_tx_clear(tp);
 
-	if (tp->dirty_rx == tp->cur_rx) {
-		rtl8169_init_ring_indexes(tp);
-		rtl_hw_start(dev);
-		netif_wake_queue(dev);
-		rtl8169_check_link_status(dev, tp, tp->mmio_addr);
-	} else {
-		if (net_ratelimit())
-			netif_emerg(tp, intr, dev, "Rx buffers shortage\n");
-		rtl8169_schedule_work(dev, rtl8169_reset_task);
-	}
+	rtl8169_init_ring_indexes(tp);
+	rtl_hw_start(dev);
+	netif_wake_queue(dev);
+	rtl8169_check_link_status(dev, tp, tp->mmio_addr);
 
 out_unlock:
 	rtnl_unlock();
@@ -4677,7 +4636,7 @@ static int rtl8169_xmit_frags(struct rtl8169_private *tp, struct sk_buff *skb,
 			goto err_out;
 		}
 
-		/* anti gcc 2.95.3 bugware (sic) */
+		/* Anti gcc 2.95.3 bugware (sic) */
 		status = opts[0] | len |
 			(RingEnd * !((entry + 1) % NUM_TX_DESC));
 
@@ -4773,7 +4732,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	wmb();
 
-	/* anti gcc 2.95.3 bugware (sic) */
+	/* Anti gcc 2.95.3 bugware (sic) */
 	status = opts[0] | len | (RingEnd * !((entry + 1) % NUM_TX_DESC));
 	txd->opts1 = cpu_to_le32(status);
 
@@ -4781,7 +4740,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	wmb();
 
-	RTL_W8(TxPoll, NPQ);	/* set polling bit */
+	RTL_W8(TxPoll, NPQ);
 
 	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
 		netif_stop_queue(dev);
@@ -4938,20 +4897,12 @@ static struct sk_buff *rtl8169_try_rx_copy(void *data,
 	return skb;
 }
 
-/*
- * Warning : rtl8169_rx_interrupt() might be called :
- * 1) from NAPI (softirq) context
- *	(polling = 1 : we should call netif_receive_skb())
- * 2) from process context (rtl8169_reset_task())
- *	(polling = 0 : we must call netif_rx() instead)
- */
 static int rtl8169_rx_interrupt(struct net_device *dev,
 				struct rtl8169_private *tp,
 				void __iomem *ioaddr, u32 budget)
 {
 	unsigned int cur_rx, rx_left;
 	unsigned int count;
-	int polling = (budget != ~(u32)0) ? 1 : 0;
 
 	cur_rx = tp->cur_rx;
 	rx_left = NUM_RX_DESC + tp->dirty_rx - cur_rx;
@@ -5011,10 +4962,7 @@ static int rtl8169_rx_interrupt(struct net_device *dev,
 
 			rtl8169_rx_vlan_tag(desc, skb);
 
-			if (likely(polling))
-				napi_gro_receive(&tp->napi, skb);
-			else
-				netif_rx(skb);
+			napi_gro_receive(&tp->napi, skb);
 
 			dev->stats.rx_bytes += pkt_size;
 			dev->stats.rx_packets++;
@@ -5170,7 +5118,7 @@ static void rtl8169_down(struct net_device *dev)
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	rtl8169_delete_timer(dev);
+	del_timer_sync(&tp->timer);
 
 	netif_stop_queue(dev);
 
@@ -5207,7 +5155,7 @@ static int rtl8169_close(struct net_device *dev)
 
 	pm_runtime_get_sync(&pdev->dev);
 
-	/* update counters before going down */
+	/* Update counters before going down */
 	rtl8169_update_counters(dev);
 
 	rtl8169_down(dev);
@@ -5400,15 +5348,15 @@ static int rtl8169_runtime_idle(struct device *device)
 }
 
 static const struct dev_pm_ops rtl8169_pm_ops = {
-	.suspend = rtl8169_suspend,
-	.resume = rtl8169_resume,
-	.freeze = rtl8169_suspend,
-	.thaw = rtl8169_resume,
-	.poweroff = rtl8169_suspend,
-	.restore = rtl8169_resume,
-	.runtime_suspend = rtl8169_runtime_suspend,
-	.runtime_resume = rtl8169_runtime_resume,
-	.runtime_idle = rtl8169_runtime_idle,
+	.suspend		= rtl8169_suspend,
+	.resume			= rtl8169_resume,
+	.freeze			= rtl8169_suspend,
+	.thaw			= rtl8169_resume,
+	.poweroff		= rtl8169_suspend,
+	.restore		= rtl8169_resume,
+	.runtime_suspend	= rtl8169_runtime_suspend,
+	.runtime_resume		= rtl8169_runtime_resume,
+	.runtime_idle		= rtl8169_runtime_idle,
 };
 
 #define RTL8169_PM_OPS	(&rtl8169_pm_ops)
@@ -5427,7 +5375,7 @@ static void rtl_shutdown(struct pci_dev *pdev)
 
 	rtl8169_net_suspend(dev);
 
-	/* restore original MAC address */
+	/* Restore original MAC address */
 	rtl_rar_set(tp, dev->perm_addr);
 
 	spin_lock_irq(&tp->lock);
-- 
Ueimor
