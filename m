From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/2] igb: PCIe devices do not need to unset
	MANC_ARP_ENA
Date: Thu, 14 Feb 2008 10:17:12 -0800
Message-ID: <20080214181712.11070.48342.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: David Graham <david.graham@intel.com>

Users reported that ARP's were lost with igb. The problem
is fixed by not enabling this manageability configuration
bit.

None of the release_manageability code is actually needed as the
normal device reset during a shutdown returns everthing to
the right condition automatically.

Signed-off-by: David Graham <david.graham@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/igb/igb_main.c |   28 ----------------------------
 1 files changed, 0 insertions(+), 28 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index d4eb8e2..bff280e 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -606,9 +606,6 @@ static void igb_init_manageability(struct igb_adapter *adapter)
 		u32 manc2h = rd32(E1000_MANC2H);
 		u32 manc = rd32(E1000_MANC);
 
-		/* disable hardware interception of ARP */
-		manc &= ~(E1000_MANC_ARP_EN);
-
 		/* enable receiving management packets to the host */
 		/* this will probably generate destination unreachable messages
 		 * from the host OS, but the packets will be handled on SMBUS */
@@ -623,25 +620,6 @@ static void igb_init_manageability(struct igb_adapter *adapter)
 	}
 }
 
-static void igb_release_manageability(struct igb_adapter *adapter)
-{
-	struct e1000_hw *hw = &adapter->hw;
-
-	if (adapter->en_mng_pt) {
-		u32 manc = rd32(E1000_MANC);
-
-		/* re-enable hardware interception of ARP */
-		manc |= E1000_MANC_ARP_EN;
-		manc &= ~E1000_MANC_EN_MNG2HOST;
-
-		/* don't explicitly have to mess with MANC2H since
-		 * MANC has an enable disable that gates MANC2H */
-
-		/* XXX stop the hardware watchdog ? */
-		wr32(E1000_MANC, manc);
-	}
-}
-
 /**
  * igb_configure - configure the hardware for RX and TX
  * @adapter: private board structure
@@ -844,7 +822,6 @@ void igb_reset(struct igb_adapter *adapter)
 
 	igb_reset_adaptive(&adapter->hw);
 	adapter->hw.phy.ops.get_phy_info(&adapter->hw);
-	igb_release_manageability(adapter);
 }
 
 /**
@@ -1178,9 +1155,6 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 
 	flush_scheduled_work();
 
-
-	igb_release_manageability(adapter);
-
 	/* Release control of h/w to f/w.  If f/w is AMT enabled, this
 	 * would have already happened in close and is redundant. */
 	igb_release_hw_control(adapter);
@@ -3955,8 +3929,6 @@ static int igb_suspend(struct pci_dev *pdev, pm_message_t state)
 		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
 
-	igb_release_manageability(adapter);
-
 	/* make sure adapter isn't asleep if manageability is enabled */
 	if (adapter->en_mng_pt) {
 		pci_enable_wake(pdev, PCI_D3hot, 1);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
