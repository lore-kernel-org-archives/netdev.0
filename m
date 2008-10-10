From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 0/14] Pull request for 'r8169' branch
Date: Fri, 10 Oct 2008 23:36:38 +0200
Message-ID: <20081010213638.GA25005@electric-eye.fr.zoreil.com>
References: <20081006071229.GA23039@electric-eye.fr.zoreil.com> <20081007222202.GA9393@electric-eye.fr.zoreil.com> <20081009190015.GB19721@electric-eye.fr.zoreil.com> <20081009.122026.239988133.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamagallon@ono.com, greg@kroah.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bonbons@linux-vserver.org,
	ivecera@redhat.com, Ben Hutchings <bhutchings@solarflare.com>,
	ishikawa <chiaki.ishikawa@ubin.jp>, Mark Lord <lkml@rtr.ca>,
	edward_hsu@realtek.com.tw
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40712 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763174AbYJJViQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 17:38:16 -0400
Content-Disposition: inline
In-Reply-To: <20081009.122026.239988133.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'r8169' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r8169

to get the changes below.

Patches #1 .. #14 will be sent for review to netdev only.

A former version of patches #2 .. #11 has already been published
by the end of june for review. Ben Hutchings's remark regarding
the readability of the Tx performance tweak has been applied.

Distance from 'davem-next' (df58ef51caea073f4b45857c51f445f65267dac7)
---------------------------------------------------------------------

1765f95d2db0a516b5816e016fdf459c4bb5affb
5b538df9dedb3469b688b93ffab2a7efb64c88e3
7f3e3d3a69da262016db6eec803881603c61ddf6
ef808d502cc3b18b2d823bbe8c03c0b8ea0df1b5
ef3386f00fcd18a40343047329ec7ed2eb98bbe8
6fb07058d2b6c748c308e4ee453035433d34ca93
197ff761dbf9fa5de9a4684a51ee5cb534cbb852
b726e493e8dc13537d1d7f8cd66bcd28516606c3
2e68ae44309bfadccdb5ddd68b9c38d2a1efeb94
219a1e9d46dcc21f279c428941ded2328f1a5ee5
b8363901596f64ef74db906df0c4a95daea47464
236b8082aa239e91c3cd9cb466d0527a735e54db
f50d4275422415cfb2a5b94bad3b2b229d0ec1aa
a2de6b89b74b28052e293fdb39975a5a03c432e0

Diffstat
--------

 drivers/net/r8169.c |  457 ++++++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 434 insertions(+), 23 deletions(-)

Shortlog
--------

Francois Romieu (14):
      r8169: wake up the PHY of the 8168
      r8169: update phy init parameters
      r8169: new phy init parameters for the 8168b
      r8169: shuffle some registers handling around (8168 operation only)
      r8169: make room for more specific 8168 hardware start procedure
      r8169: 8168b Tx performance tweak
      r8169: sync existing 8168 device hardware start sequences with vendor driver
      r8169: add a new 8168c flavor
      r8169: add a new 8168c flavor (bis)
      r8169: add a new 8168cp flavor
      r8169: change default behavior for mildly identified 8168c chipsets
      r8169: support additional 8168cp chipset
      r8169: preliminary 8168d support
      r8169: add shutdown handler

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 59fbc64..bdae2c5 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -109,7 +109,12 @@ enum mac_version {
 	RTL_GIGA_MAC_VER_17 = 0x10, // 8168Bf
 	RTL_GIGA_MAC_VER_18 = 0x12, // 8168CP
 	RTL_GIGA_MAC_VER_19 = 0x13, // 8168C
-	RTL_GIGA_MAC_VER_20 = 0x14  // 8168C
+	RTL_GIGA_MAC_VER_20 = 0x14, // 8168C
+	RTL_GIGA_MAC_VER_21 = 0x15, // 8168C
+	RTL_GIGA_MAC_VER_22 = 0x16, // 8168C
+	RTL_GIGA_MAC_VER_23 = 0x17, // 8168CP
+	RTL_GIGA_MAC_VER_24 = 0x18, // 8168CP
+	RTL_GIGA_MAC_VER_25 = 0x19  // 8168D
 };
 
 #define _R(NAME,MAC,MASK) \
@@ -139,7 +144,12 @@ static const struct {
 	_R("RTL8101e",		RTL_GIGA_MAC_VER_16, 0xff7e1880), // PCI-E
 	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_18, 0xff7e1880), // PCI-E
 	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_19, 0xff7e1880), // PCI-E
-	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_20, 0xff7e1880)  // PCI-E
+	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_20, 0xff7e1880), // PCI-E
+	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_21, 0xff7e1880), // PCI-E
+	_R("RTL8168c/8111c",	RTL_GIGA_MAC_VER_22, 0xff7e1880), // PCI-E
+	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_23, 0xff7e1880), // PCI-E
+	_R("RTL8168cp/8111cp",	RTL_GIGA_MAC_VER_24, 0xff7e1880), // PCI-E
+	_R("RTL8168d/8111d",	RTL_GIGA_MAC_VER_25, 0xff7e1880)  // PCI-E
 };
 #undef _R
 
@@ -865,9 +875,13 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 
 	auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
 
-	if ((tp->mac_version == RTL_GIGA_MAC_VER_12) ||
-	    (tp->mac_version == RTL_GIGA_MAC_VER_17)) {
-		/* Vendor specific (0x1f) and reserved (0x0e) MII registers. */
+	if ((tp->mac_version == RTL_GIGA_MAC_VER_11) ||
+	    (tp->mac_version == RTL_GIGA_MAC_VER_12) ||
+	    (tp->mac_version >= RTL_GIGA_MAC_VER_17)) {
+		/*
+		 * Wake up the PHY.
+		 * Vendor specific (0x1f) and reserved (0x0e) MII registers.
+		 */
 		mdio_write(ioaddr, 0x1f, 0x0000);
 		mdio_write(ioaddr, 0x0e, 0x0000);
 	}
@@ -1212,11 +1226,19 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
 		u32 val;
 		int mac_version;
 	} mac_info[] = {
-		/* 8168B family. */
-		{ 0x7c800000, 0x3c800000,	RTL_GIGA_MAC_VER_18 },
+		/* 8168D family. */
+		{ 0x7c800000, 0x28000000,	RTL_GIGA_MAC_VER_25 },
+
+		/* 8168C family. */
+		{ 0x7cf00000, 0x3ca00000,	RTL_GIGA_MAC_VER_24 },
+		{ 0x7cf00000, 0x3c900000,	RTL_GIGA_MAC_VER_23 },
+		{ 0x7cf00000, 0x3c800000,	RTL_GIGA_MAC_VER_18 },
+		{ 0x7c800000, 0x3c800000,	RTL_GIGA_MAC_VER_24 },
 		{ 0x7cf00000, 0x3c000000,	RTL_GIGA_MAC_VER_19 },
 		{ 0x7cf00000, 0x3c200000,	RTL_GIGA_MAC_VER_20 },
-		{ 0x7c800000, 0x3c000000,	RTL_GIGA_MAC_VER_20 },
+		{ 0x7cf00000, 0x3c300000,	RTL_GIGA_MAC_VER_21 },
+		{ 0x7cf00000, 0x3c400000,	RTL_GIGA_MAC_VER_22 },
+		{ 0x7c800000, 0x3c000000,	RTL_GIGA_MAC_VER_22 },
 
 		/* 8168B family. */
 		{ 0x7cf00000, 0x38000000,	RTL_GIGA_MAC_VER_12 },
@@ -1346,7 +1368,31 @@ static void rtl8169sb_hw_phy_config(void __iomem *ioaddr)
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
-static void rtl8168cp_hw_phy_config(void __iomem *ioaddr)
+static void rtl8168bb_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x10, 0xf41b },
+		{ 0x1f, 0x0000 }
+	};
+
+	mdio_write(ioaddr, 0x1f, 0x0001);
+	mdio_patch(ioaddr, 0x16, 1 << 0);
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
+static void rtl8168bef_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0001 },
+		{ 0x10, 0xf41b },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
+static void rtl8168cp_1_hw_phy_config(void __iomem *ioaddr)
 {
 	struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0000 },
@@ -1359,7 +1405,22 @@ static void rtl8168cp_hw_phy_config(void __iomem *ioaddr)
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
-static void rtl8168c_hw_phy_config(void __iomem *ioaddr)
+static void rtl8168cp_2_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0001 },
+		{ 0x1d, 0x3d98 },
+		{ 0x1f, 0x0000 }
+	};
+
+	mdio_write(ioaddr, 0x1f, 0x0000);
+	mdio_patch(ioaddr, 0x14, 1 << 5);
+	mdio_patch(ioaddr, 0x0d, 1 << 5);
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+
+static void rtl8168c_1_hw_phy_config(void __iomem *ioaddr)
 {
 	struct phy_reg phy_reg_init[] = {
 		{ 0x1f, 0x0001 },
@@ -1375,26 +1436,142 @@ static void rtl8168c_hw_phy_config(void __iomem *ioaddr)
 		{ 0x1f, 0x0003 },
 		{ 0x12, 0xc096 },
 		{ 0x16, 0x000a },
-		{ 0x1f, 0x0000 }
+		{ 0x1f, 0x0000 },
+		{ 0x1f, 0x0000 },
+		{ 0x09, 0x2000 },
+		{ 0x09, 0x0000 }
 	};
 
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+
+	mdio_patch(ioaddr, 0x14, 1 << 5);
+	mdio_patch(ioaddr, 0x0d, 1 << 5);
+	mdio_write(ioaddr, 0x1f, 0x0000);
 }
 
-static void rtl8168cx_hw_phy_config(void __iomem *ioaddr)
+static void rtl8168c_2_hw_phy_config(void __iomem *ioaddr)
 {
 	struct phy_reg phy_reg_init[] = {
-		{ 0x1f, 0x0000 },
+		{ 0x1f, 0x0001 },
 		{ 0x12, 0x2300 },
+		{ 0x03, 0x802f },
+		{ 0x02, 0x4f02 },
+		{ 0x01, 0x0409 },
+		{ 0x00, 0xf099 },
+		{ 0x04, 0x9800 },
+		{ 0x04, 0x9000 },
+		{ 0x1d, 0x3d98 },
+		{ 0x1f, 0x0002 },
+		{ 0x0c, 0x7eb8 },
+		{ 0x06, 0x0761 },
 		{ 0x1f, 0x0003 },
 		{ 0x16, 0x0f0a },
-		{ 0x1f, 0x0000 },
+		{ 0x1f, 0x0000 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+
+	mdio_patch(ioaddr, 0x16, 1 << 0);
+	mdio_patch(ioaddr, 0x14, 1 << 5);
+	mdio_patch(ioaddr, 0x0d, 1 << 5);
+	mdio_write(ioaddr, 0x1f, 0x0000);
+}
+
+static void rtl8168c_3_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0001 },
+		{ 0x12, 0x2300 },
+		{ 0x1d, 0x3d98 },
 		{ 0x1f, 0x0002 },
 		{ 0x0c, 0x7eb8 },
+		{ 0x06, 0x5461 },
+		{ 0x1f, 0x0003 },
+		{ 0x16, 0x0f0a },
 		{ 0x1f, 0x0000 }
 	};
 
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+
+	mdio_patch(ioaddr, 0x16, 1 << 0);
+	mdio_patch(ioaddr, 0x14, 1 << 5);
+	mdio_patch(ioaddr, 0x0d, 1 << 5);
+	mdio_write(ioaddr, 0x1f, 0x0000);
+}
+
+static void rtl8168c_4_hw_phy_config(void __iomem *ioaddr)
+{
+	rtl8168c_3_hw_phy_config(ioaddr);
+}
+
+static void rtl8168d_hw_phy_config(void __iomem *ioaddr)
+{
+	struct phy_reg phy_reg_init_0[] = {
+		{ 0x1f, 0x0001 },
+		{ 0x09, 0x2770 },
+		{ 0x08, 0x04d0 },
+		{ 0x0b, 0xad15 },
+		{ 0x0c, 0x5bf0 },
+		{ 0x1c, 0xf101 },
+		{ 0x1f, 0x0003 },
+		{ 0x14, 0x94d7 },
+		{ 0x12, 0xf4d6 },
+		{ 0x09, 0xca0f },
+		{ 0x1f, 0x0002 },
+		{ 0x0b, 0x0b10 },
+		{ 0x0c, 0xd1f7 },
+		{ 0x1f, 0x0002 },
+		{ 0x06, 0x5461 },
+		{ 0x1f, 0x0002 },
+		{ 0x05, 0x6662 },
+		{ 0x1f, 0x0000 },
+		{ 0x14, 0x0060 },
+		{ 0x1f, 0x0000 },
+		{ 0x0d, 0xf8a0 },
+		{ 0x1f, 0x0005 },
+		{ 0x05, 0xffc2 }
+	};
+
+	rtl_phy_write(ioaddr, phy_reg_init_0, ARRAY_SIZE(phy_reg_init_0));
+
+	if (mdio_read(ioaddr, 0x06) == 0xc400) {
+		struct phy_reg phy_reg_init_1[] = {
+			{ 0x1f, 0x0005 },
+			{ 0x01, 0x0300 },
+			{ 0x1f, 0x0000 },
+			{ 0x11, 0x401c },
+			{ 0x16, 0x4100 },
+			{ 0x1f, 0x0005 },
+			{ 0x07, 0x0010 },
+			{ 0x05, 0x83dc },
+			{ 0x06, 0x087d },
+			{ 0x05, 0x8300 },
+			{ 0x06, 0x0101 },
+			{ 0x06, 0x05f8 },
+			{ 0x06, 0xf9fa },
+			{ 0x06, 0xfbef },
+			{ 0x06, 0x79e2 },
+			{ 0x06, 0x835f },
+			{ 0x06, 0xe0f8 },
+			{ 0x06, 0x9ae1 },
+			{ 0x06, 0xf89b },
+			{ 0x06, 0xef31 },
+			{ 0x06, 0x3b65 },
+			{ 0x06, 0xaa07 },
+			{ 0x06, 0x81e4 },
+			{ 0x06, 0xf89a },
+			{ 0x06, 0xe5f8 },
+			{ 0x06, 0x9baf },
+			{ 0x06, 0x06ae },
+			{ 0x05, 0x83dc },
+			{ 0x06, 0x8300 },
+		};
+
+		rtl_phy_write(ioaddr, phy_reg_init_1,
+			      ARRAY_SIZE(phy_reg_init_1));
+	}
+
+	mdio_write(ioaddr, 0x1f, 0x0000);
 }
 
 static void rtl8102e_hw_phy_config(void __iomem *ioaddr)
@@ -1435,15 +1612,38 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_09:
 		rtl8102e_hw_phy_config(ioaddr);
 		break;
+	case RTL_GIGA_MAC_VER_11:
+		rtl8168bb_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_12:
+		rtl8168bef_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_17:
+		rtl8168bef_hw_phy_config(ioaddr);
+		break;
 	case RTL_GIGA_MAC_VER_18:
-		rtl8168cp_hw_phy_config(ioaddr);
+		rtl8168cp_1_hw_phy_config(ioaddr);
 		break;
 	case RTL_GIGA_MAC_VER_19:
-		rtl8168c_hw_phy_config(ioaddr);
+		rtl8168c_1_hw_phy_config(ioaddr);
 		break;
 	case RTL_GIGA_MAC_VER_20:
-		rtl8168cx_hw_phy_config(ioaddr);
+		rtl8168c_2_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_21:
+		rtl8168c_3_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_22:
+		rtl8168c_4_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_23:
+	case RTL_GIGA_MAC_VER_24:
+		rtl8168cp_2_hw_phy_config(ioaddr);
+		break;
+	case RTL_GIGA_MAC_VER_25:
+		rtl8168d_hw_phy_config(ioaddr);
 		break;
+
 	default:
 		break;
 	}
@@ -2328,6 +2528,164 @@ static void rtl_ephy_init(void __iomem *ioaddr, struct ephy_info *e, int len)
 	}
 }
 
+static void rtl_disable_clock_request(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct rtl8169_private *tp = netdev_priv(dev);
+	int cap = tp->pcie_cap;
+
+	if (cap) {
+		u16 ctl;
+
+		pci_read_config_word(pdev, cap + PCI_EXP_LNKCTL, &ctl);
+		ctl &= ~PCI_EXP_LNKCTL_CLKREQ_EN;
+		pci_write_config_word(pdev, cap + PCI_EXP_LNKCTL, ctl);
+	}
+}
+
+#define R8168_CPCMD_QUIRK_MASK (\
+	EnableBist | \
+	Mac_dbgo_oe | \
+	Force_half_dup | \
+	Force_rxflow_en | \
+	Force_txflow_en | \
+	Cxpl_dbg_sel | \
+	ASF | \
+	PktCntrDisable | \
+	Mac_dbgo_sel)
+
+static void rtl_hw_start_8168bb(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
+
+	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
+
+	rtl_tx_performance_tweak(pdev,
+		(0x5 << MAX_READ_REQUEST_SHIFT) | PCI_EXP_DEVCTL_NOSNOOP_EN);
+}
+
+static void rtl_hw_start_8168bef(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl_hw_start_8168bb(ioaddr, pdev);
+
+	RTL_W8(EarlyTxThres, EarlyTxThld);
+
+	RTL_W8(Config4, RTL_R8(Config4) & ~(1 << 0));
+}
+
+static void __rtl_hw_start_8168cp(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	RTL_W8(Config1, RTL_R8(Config1) | Speed_down);
+
+	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
+
+	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+
+	rtl_disable_clock_request(pdev);
+
+	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
+}
+
+static void rtl_hw_start_8168cp_1(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	static struct ephy_info e_info_8168cp[] = {
+		{ 0x01, 0,	0x0001 },
+		{ 0x02, 0x0800,	0x1000 },
+		{ 0x03, 0,	0x0042 },
+		{ 0x06, 0x0080,	0x0000 },
+		{ 0x07, 0,	0x2000 }
+	};
+
+	rtl_csi_access_enable(ioaddr);
+
+	rtl_ephy_init(ioaddr, e_info_8168cp, ARRAY_SIZE(e_info_8168cp));
+
+	__rtl_hw_start_8168cp(ioaddr, pdev);
+}
+
+static void rtl_hw_start_8168cp_2(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl_csi_access_enable(ioaddr);
+
+	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
+
+	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+
+	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
+}
+
+static void rtl_hw_start_8168cp_3(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl_csi_access_enable(ioaddr);
+
+	RTL_W8(Config3, RTL_R8(Config3) & ~Beacon_en);
+
+	/* Magic. */
+	RTL_W8(DBG_REG, 0x20);
+
+	RTL_W8(EarlyTxThres, EarlyTxThld);
+
+	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+
+	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
+}
+
+static void rtl_hw_start_8168c_1(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	static struct ephy_info e_info_8168c_1[] = {
+		{ 0x02, 0x0800,	0x1000 },
+		{ 0x03, 0,	0x0002 },
+		{ 0x06, 0x0080,	0x0000 }
+	};
+
+	rtl_csi_access_enable(ioaddr);
+
+	RTL_W8(DBG_REG, 0x06 | FIX_NAK_1 | FIX_NAK_2);
+
+	rtl_ephy_init(ioaddr, e_info_8168c_1, ARRAY_SIZE(e_info_8168c_1));
+
+	__rtl_hw_start_8168cp(ioaddr, pdev);
+}
+
+static void rtl_hw_start_8168c_2(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	static struct ephy_info e_info_8168c_2[] = {
+		{ 0x01, 0,	0x0001 },
+		{ 0x03, 0x0400,	0x0220 }
+	};
+
+	rtl_csi_access_enable(ioaddr);
+
+	rtl_ephy_init(ioaddr, e_info_8168c_2, ARRAY_SIZE(e_info_8168c_2));
+
+	__rtl_hw_start_8168cp(ioaddr, pdev);
+}
+
+static void rtl_hw_start_8168c_3(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl_hw_start_8168c_2(ioaddr, pdev);
+}
+
+static void rtl_hw_start_8168c_4(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl_csi_access_enable(ioaddr);
+
+	__rtl_hw_start_8168cp(ioaddr, pdev);
+}
+
+static void rtl_hw_start_8168d(void __iomem *ioaddr, struct pci_dev *pdev)
+{
+	rtl_csi_access_enable(ioaddr);
+
+	rtl_disable_clock_request(pdev);
+
+	RTL_W8(EarlyTxThres, EarlyTxThld);
+
+	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
+
+	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
+}
+
 static void rtl_hw_start_8168(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -2340,14 +2698,10 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	rtl_set_rx_max_size(ioaddr);
 
-	rtl_set_rx_tx_config_registers(tp);
-
 	tp->cp_cmd |= RTL_R16(CPlusCmd) | PktCntrDisable | INTT_1;
 
 	RTL_W16(CPlusCmd, tp->cp_cmd);
 
-	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
-
 	RTL_W16(IntrMitigate, 0x5151);
 
 	/* Work around for RxFIFO overflow. */
@@ -2358,14 +2712,65 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	rtl_set_rx_tx_desc_registers(tp, ioaddr);
 
-	RTL_W8(Cfg9346, Cfg9346_Lock);
+	rtl_set_rx_mode(dev);
+
+	RTL_W32(TxConfig, (TX_DMA_BURST << TxDMAShift) |
+		(InterFrameGap << TxInterFrameGapShift));
 
 	RTL_R8(IntrMask);
 
-	rtl_set_rx_mode(dev);
+	switch (tp->mac_version) {
+	case RTL_GIGA_MAC_VER_11:
+		rtl_hw_start_8168bb(ioaddr, pdev);
+	break;
+
+	case RTL_GIGA_MAC_VER_12:
+	case RTL_GIGA_MAC_VER_17:
+		rtl_hw_start_8168bef(ioaddr, pdev);
+	break;
+
+	case RTL_GIGA_MAC_VER_18:
+		rtl_hw_start_8168cp_1(ioaddr, pdev);
+	break;
+
+	case RTL_GIGA_MAC_VER_19:
+		rtl_hw_start_8168c_1(ioaddr, pdev);
+	break;
+
+	case RTL_GIGA_MAC_VER_20:
+		rtl_hw_start_8168c_2(ioaddr, pdev);
+	break;
+
+	case RTL_GIGA_MAC_VER_21:
+		rtl_hw_start_8168c_3(ioaddr, pdev);
+	break;
+
+	case RTL_GIGA_MAC_VER_22:
+		rtl_hw_start_8168c_4(ioaddr, pdev);
+	break;
+
+	case RTL_GIGA_MAC_VER_23:
+		rtl_hw_start_8168cp_2(ioaddr, pdev);
+	break;
+
+	case RTL_GIGA_MAC_VER_24:
+		rtl_hw_start_8168cp_3(ioaddr, pdev);
+	break;
+
+	case RTL_GIGA_MAC_VER_25:
+		rtl_hw_start_8168d(ioaddr, pdev);
+	break;
+
+	default:
+		printk(KERN_ERR PFX "%s: unknown chipset (mac_version = %d).\n",
+			dev->name, tp->mac_version);
+	break;
+	}
 
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
 
 	RTL_W16(IntrMask, tp->intr_event);
@@ -3469,6 +3874,11 @@ out:
 	return 0;
 }
 
+static void rtl_shutdown(struct pci_dev *pdev)
+{
+	rtl8169_suspend(pdev, PMSG_SUSPEND);
+}
+
 #endif /* CONFIG_PM */
 
 static struct pci_driver rtl8169_pci_driver = {
@@ -3479,6 +3889,7 @@ static struct pci_driver rtl8169_pci_driver = {
 #ifdef CONFIG_PM
 	.suspend	= rtl8169_suspend,
 	.resume		= rtl8169_resume,
+	.shutdown	= rtl_shutdown,
 #endif
 };
 
-- 
Ueimor
