From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/2] e1000e: PCIe devices do not need to unset MANC_ARP_ENA
Date: Thu, 14 Feb 2008 10:17:20 -0800
Message-ID: <20080214181720.11070.43867.stgit@localhost.localdomain>
References: <20080214181712.11070.48342.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26310 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760842AbYBNSR1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2008 13:17:27 -0500
In-Reply-To: <20080214181712.11070.48342.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Graham <david.graham@intel.com>

Users reported that ARP's were lost with e1000e. The problem
is fixed by not enabling this manageability configuration
bit.

None of the release_manageability code is actually needed as the
normal device reset during a shutdown returns everthing to
the right condition automatically.

Signed-off-by: David Graham <david.graham@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/netdev.c |   26 --------------------------
 1 files changed, 0 insertions(+), 26 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index ea4ecc3..3031d6d 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1055,23 +1055,6 @@ static void e1000_release_hw_control(struct e1000_adapter *adapter)
 	}
 }
 
-static void e1000_release_manageability(struct e1000_adapter *adapter)
-{
-	if (adapter->flags & FLAG_MNG_PT_ENABLED) {
-		struct e1000_hw *hw = &adapter->hw;
-
-		u32 manc = er32(MANC);
-
-		/* re-enable hardware interception of ARP */
-		manc |= E1000_MANC_ARP_EN;
-		manc &= ~E1000_MANC_EN_MNG2HOST;
-
-		/* don't explicitly have to mess with MANC2H since
-		 * MANC has an enable disable that gates MANC2H */
-		ew32(MANC, manc);
-	}
-}
-
 /**
  * @e1000_alloc_ring - allocate memory for a ring structure
  **/
@@ -1561,9 +1544,6 @@ static void e1000_init_manageability(struct e1000_adapter *adapter)
 
 	manc = er32(MANC);
 
-	/* disable hardware interception of ARP */
-	manc &= ~(E1000_MANC_ARP_EN);
-
 	/* enable receiving management packets to the host. this will probably
 	 * generate destination unreachable messages from the host OS, but
 	 * the packets will be handled on SMBUS */
@@ -2140,8 +2120,6 @@ void e1000e_reset(struct e1000_adapter *adapter)
 		phy_data &= ~IGP02E1000_PM_SPD;
 		e1e_wphy(hw, IGP02E1000_PHY_POWER_MGMT, phy_data);
 	}
-
-	e1000_release_manageability(adapter);
 }
 
 int e1000e_up(struct e1000_adapter *adapter)
@@ -3487,8 +3465,6 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
 
-	e1000_release_manageability(adapter);
-
 	/* make sure adapter isn't asleep if manageability is enabled */
 	if (adapter->flags & FLAG_MNG_PT_ENABLED) {
 		pci_enable_wake(pdev, PCI_D3hot, 1);
@@ -4054,8 +4030,6 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 
 	flush_scheduled_work();
 
-	e1000_release_manageability(adapter);
-
 	/* Release control of h/w to f/w.  If f/w is AMT enabled, this
 	 * would have already happened in close and is redundant. */
 	e1000_release_hw_control(adapter);

