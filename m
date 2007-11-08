From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 00/05] pull request for 'upstream-jeff' branch
Date: Fri, 9 Nov 2007 00:07:34 +0100
Message-ID: <20071108230734.GA15968@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Mark Lord <mlord@pobox.com>,
	Ciaran McCreesh <ciaran.mccreesh@blueyonder.co.uk>,
	Josh Logan <joshtlogan@gmail.com>,
	cecco <f.cecco77@tiscali.it>,
	Hans-Jurgen Koch <hjk@linutronix.de>,
	David Gundersen <gundy@iinet.net.au>,
	Will Trives <will@trivescon.com.au>,
	"Alexander Y. Fomichev" <gluk@php4.ru>,
	Rolf Eike Beer <eike-kernel@sf-tec.de>,
	Daniel Drake <dsd@gentoo.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Philip Craig <philipc@snapgear.com>,
	Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38766 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753440AbXKHXPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 18:15:38 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from branch 'upstream-jeff' in repository

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git upstream-jeff

to get the changes below.

They should make things better for people who have experienced the 8168b
regression since 2.6.24-rc1.

Distance from 'master' (f2511f13daaf00fdd206bee7b108f75923a613c6)
-----------------------------------------------------------------

407b35429151dd1d7a64cbef9f4bc59dac2efe5d
d981c1de3b81edf50fe59f0e1298668919117b14
9d891d0bb0a14bc8184eee45323cb010db4d0db4
69b4d070ea49bd7f589776ea471a6988345eeee5
db1470271c581050dcacc6ed681b9166d30bdba0

Diffstat
--------

 drivers/net/r8169.c |   26 +++++++-------------------
 1 files changed, 7 insertions(+), 19 deletions(-)

Shortlog
--------

Ciaran McCreesh (1):
      r8169: add PCI ID for the 8168 in the Abit Fatal1ty F-190HD motherboard

Francois Romieu (2):
      r8169: do not enable the TBI for the 8168 and the 81x0
      r8169: prevent bit sign expansion error in mdio_write

Mark Lord (2):
      r8169: revert 7da97ec96a0934319c7fbedd3d38baf533e20640 (partly)
      r8169: revert 7da97ec96a0934319c7fbedd3d38baf533e20640 (bis repetita)

Patch
-----

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index b94fa7e..1f647b9 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -171,6 +171,8 @@ static struct pci_device_id rtl8169_pci_tbl[] = {
 	{ PCI_DEVICE(0x16ec,			0x0116), 0, 0, RTL_CFG_0 },
 	{ PCI_VENDOR_ID_LINKSYS,		0x1032,
 		PCI_ANY_ID, 0x0024, 0, 0, RTL_CFG_0 },
+	{ 0x0001,				0x8168,
+		PCI_ANY_ID, 0x2410, 0, 0, RTL_CFG_2 },
 	{0,},
 };
 
@@ -468,7 +470,7 @@ static void mdio_write(void __iomem *ioaddr, int reg_addr, int value)
 {
 	int i;
 
-	RTL_W32(PHYAR, 0x80000000 | (reg_addr & 0xFF) << 16 | value);
+	RTL_W32(PHYAR, 0x80000000 | (reg_addr & 0x1f) << 16 | (value & 0xffff));
 
 	for (i = 20; i > 0; i--) {
 		/*
@@ -485,7 +487,7 @@ static int mdio_read(void __iomem *ioaddr, int reg_addr)
 {
 	int i, value = -1;
 
-	RTL_W32(PHYAR, 0x0 | (reg_addr & 0xFF) << 16);
+	RTL_W32(PHYAR, 0x0 | (reg_addr & 0x1f) << 16);
 
 	for (i = 20; i > 0; i--) {
 		/*
@@ -493,7 +495,7 @@ static int mdio_read(void __iomem *ioaddr, int reg_addr)
 		 * the specified MII register.
 		 */
 		if (RTL_R32(PHYAR) & 0x80000000) {
-			value = (int) (RTL_R32(PHYAR) & 0xFFFF);
+			value = RTL_R32(PHYAR) & 0xffff;
 			break;
 		}
 		udelay(25);
@@ -1245,16 +1247,6 @@ static void rtl8169sb_hw_phy_config(void __iomem *ioaddr)
 
 	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
-static void rtl8168b_hw_phy_config(void __iomem *ioaddr)
-{
-	struct phy_reg phy_reg_init[] = {
-		{ 0x1f, 0x0000 },
-		{ 0x10, 0xf41b },
-		{ 0x1f, 0x0000 }
-	};
-
-	rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
-}
 
 static void rtl8168cp_hw_phy_config(void __iomem *ioaddr)
 {
@@ -1324,11 +1316,6 @@ static void rtl_hw_phy_config(struct net_device *dev)
 	case RTL_GIGA_MAC_VER_04:
 		rtl8169sb_hw_phy_config(ioaddr);
 		break;
-	case RTL_GIGA_MAC_VER_11:
-	case RTL_GIGA_MAC_VER_12:
-	case RTL_GIGA_MAC_VER_17:
-		rtl8168b_hw_phy_config(ioaddr);
-		break;
 	case RTL_GIGA_MAC_VER_18:
 		rtl8168cp_hw_phy_config(ioaddr);
 		break;
@@ -1739,7 +1726,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->features |= rtl_try_msi(pdev, ioaddr, cfg);
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
-	if (RTL_R8(PHYstatus) & TBI_Enable) {
+	if ((tp->mac_version <= RTL_GIGA_MAC_VER_06) &&
+	    (RTL_R8(PHYstatus) & TBI_Enable)) {
 		tp->set_speed = rtl8169_set_speed_tbi;
 		tp->get_settings = rtl8169_gset_tbi;
 		tp->phy_reset_enable = rtl8169_tbi_reset_enable;
-- 
Ueimor
