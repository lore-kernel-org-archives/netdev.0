From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 5/7] e1000e: fix flow control denial of
	service possibility
Date: Thu, 21 Feb 2008 15:11:02 -0800
Message-ID: <20080221231102.5595.51852.stgit@localhost.localdomain>
References: <20080221231041.5595.4933.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080221231041.5595.4933.stgit@localhost.localdomain>
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

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

this patch avoids a denial of service from an evildoer sending a
continuous stream of flow control at our adapter that is plugged
into a non-flow control enabled switch.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/lib.c |   31 +++++--------------------------
 1 files changed, 5 insertions(+), 26 deletions(-)

diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 0860b5f..341d74e 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -1104,34 +1104,13 @@ s32 e1000e_config_fc_after_link_up(struct e1000_hw *hw)
 			 (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
 			mac->fc = e1000_fc_rx_pause;
 			hw_dbg(hw, "Flow Control = RX PAUSE frames only.\r\n");
-		}
-		/* Per the IEEE spec, at this point flow control should be
-		 * disabled.  However, we want to consider that we could
-		 * be connected to a legacy switch that doesn't advertise
-		 * desired flow control, but can be forced on the link
-		 * partner.  So if we advertised no flow control, that is
-		 * what we will resolve to.  If we advertised some kind of
-		 * receive capability (Rx Pause Only or Full Flow Control)
-		 * and the link partner advertised none, we will configure
-		 * ourselves to enable Rx Flow Control only.  We can do
-		 * this safely for two reasons:  If the link partner really
-		 * didn't want flow control enabled, and we enable Rx, no
-		 * harm done since we won't be receiving any PAUSE frames
-		 * anyway.  If the intent on the link partner was to have
-		 * flow control enabled, then by us enabling RX only, we
-		 * can at least receive pause frames and process them.
-		 * This is a good idea because in most cases, since we are
-		 * predominantly a server NIC, more times than not we will
-		 * be asked to delay transmission of packets than asking
-		 * our link partner to pause transmission of frames.
-		 */
-		else if ((mac->original_fc == e1000_fc_none) ||
-			 (mac->original_fc == e1000_fc_tx_pause)) {
+		} else {
+			/*
+			 * Per the IEEE spec, at this point flow control
+			 * should be disabled.
+			 */
 			mac->fc = e1000_fc_none;
 			hw_dbg(hw, "Flow Control = NONE.\r\n");
-		} else {
-			mac->fc = e1000_fc_rx_pause;
-			hw_dbg(hw, "Flow Control = RX PAUSE frames only.\r\n");
 		}
 
 		/* Now we need to do one last check...  If we auto-


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
