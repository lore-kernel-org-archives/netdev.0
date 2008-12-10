From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 2/2] igb: Correctly determine pci-e function number
	in virtual environment
Date: Tue, 09 Dec 2008 18:42:16 -0800
Message-ID: <20081210024216.27280.8218.stgit@lost.foo-projects.org>
References: <20081210024156.27280.78618.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:34487
	"EHLO QMTA10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754539AbYLJCmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 21:42:35 -0500
In-Reply-To: <20081210024156.27280.78618.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

When running in a virtual environment the ports of an 82575/6 can appear to
be single function devices which is not correct.  To resolve this we rely
on the function number stored in the status register.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_mac.c   |   18 ++++++------------
 drivers/net/igb/e1000_regs.h  |    4 ++++
 drivers/net/igb/igb_ethtool.c |    2 --
 3 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index e18747c..137269d 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -83,8 +83,8 @@ s32 igb_get_bus_info_pcie(struct e1000_hw *hw)
 {
 	struct e1000_bus_info *bus = &hw->bus;
 	s32 ret_val;
-	u32 status;
-	u16 pcie_link_status, pci_header_type;
+	u32 reg;
+	u16 pcie_link_status;
 
 	bus->type = e1000_bus_type_pci_express;
 	bus->speed = e1000_bus_speed_2500;
@@ -99,14 +99,8 @@ s32 igb_get_bus_info_pcie(struct e1000_hw *hw)
 						     PCIE_LINK_WIDTH_MASK) >>
 						     PCIE_LINK_WIDTH_SHIFT);
 
-	igb_read_pci_cfg(hw, PCI_HEADER_TYPE_REGISTER, &pci_header_type);
-	if (pci_header_type & PCI_HEADER_TYPE_MULTIFUNC) {
-		status = rd32(E1000_STATUS);
-		bus->func = (status & E1000_STATUS_FUNC_MASK)
-			    >> E1000_STATUS_FUNC_SHIFT;
-	} else {
-		bus->func = 0;
-	}
+	reg = rd32(E1000_STATUS);
+	bus->func = (reg & E1000_STATUS_FUNC_MASK) >> E1000_STATUS_FUNC_SHIFT;
 
 	return 0;
 }
@@ -229,8 +223,8 @@ void igb_rar_set(struct e1000_hw *hw, u8 *addr, u32 index)
 	if (!hw->mac.disable_av)
 		rar_high |= E1000_RAH_AV;
 
-	array_wr32(E1000_RA, (index << 1), rar_low);
-	array_wr32(E1000_RA, ((index << 1) + 1), rar_high);
+	wr32(E1000_RAL(index), rar_low);
+	wr32(E1000_RAH(index), rar_high);
 }
 
 /**
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index 95523af..bdf5d83 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -221,6 +221,10 @@
 #define E1000_MTA      0x05200  /* Multicast Table Array - RW Array */
 #define E1000_RA       0x05400  /* Receive Address - RW Array */
 #define E1000_RA2      0x054E0  /* 2nd half of receive address array - RW Array */
+#define E1000_RAL(_i)  (((_i) <= 15) ? (0x05400 + ((_i) * 8)) : \
+                                       (0x054E0 + ((_i - 16) * 8)))
+#define E1000_RAH(_i)  (((_i) <= 15) ? (0x05404 + ((_i) * 8)) : \
+                                       (0x054E4 + ((_i - 16) * 8)))
 #define E1000_VFTA     0x05600  /* VLAN Filter Table Array - RW Array */
 #define E1000_VMD_CTL  0x0581C  /* VMDq Control - RW */
 #define E1000_WUC      0x05800  /* Wakeup Control - RW */
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index d5efbcc..3c831f1 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -494,8 +494,6 @@ static void igb_get_regs(struct net_device *netdev,
 
 	/* These should probably be added to e1000_regs.h instead */
 	#define E1000_PSRTYPE_REG(_i) (0x05480 + ((_i) * 4))
-	#define E1000_RAL(_i)         (0x05400 + ((_i) * 8))
-	#define E1000_RAH(_i)         (0x05404 + ((_i) * 8))
 	#define E1000_IP4AT_REG(_i)   (0x05840 + ((_i) * 8))
 	#define E1000_IP6AT_REG(_i)   (0x05880 + ((_i) * 4))
 	#define E1000_WUPM_REG(_i)    (0x05A00 + ((_i) * 4))

