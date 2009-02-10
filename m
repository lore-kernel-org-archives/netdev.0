From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 4/4] e1000e: Serdes - attempt autoneg when link
	restored.
Date: Tue, 10 Feb 2009 14:52:28 -0800
Message-ID: <20090210225228.32208.91304.stgit@lost.foo-projects.org>
References: <20090210225116.32208.78338.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	dave graham <david.graham@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:41021
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756454AbZBJWwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 17:52:51 -0500
In-Reply-To: <20090210225116.32208.78338.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: dave graham <david.graham@intel.com>

This patch addresses an issue where we did not restart auto-negotiation on
serdes links when the link partner was disabled and re-enabled. It includes
reworking the serdes link detect mechanism to be a state machine for
82571 and 82572 parts only.

Signed-off-by: dave graham <david.graham@intel.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c |  132 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/e1000e/hw.h    |    8 +++
 2 files changed, 139 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 25f6bc9..565fd4e 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -61,6 +61,7 @@
 static s32 e1000_get_phy_id_82571(struct e1000_hw *hw);
 static s32 e1000_setup_copper_link_82571(struct e1000_hw *hw);
 static s32 e1000_setup_fiber_serdes_link_82571(struct e1000_hw *hw);
+static s32 e1000_check_for_serdes_link_82571(struct e1000_hw *hw);
 static s32 e1000_write_nvm_eewr_82571(struct e1000_hw *hw, u16 offset,
 				      u16 words, u16 *data);
 static s32 e1000_fix_nvm_checksum_82571(struct e1000_hw *hw);
@@ -250,7 +251,7 @@ static s32 e1000_init_mac_params_82571(struct e1000_adapter *adapter)
 	case e1000_media_type_internal_serdes:
 		func->setup_physical_interface =
 			e1000_setup_fiber_serdes_link_82571;
-		func->check_for_link = e1000e_check_for_serdes_link;
+		func->check_for_link = e1000_check_for_serdes_link_82571;
 		func->get_link_up_info =
 			e1000e_get_speed_and_duplex_fiber_serdes;
 		break;
@@ -830,6 +831,10 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 		hw->dev_spec.e82571.alt_mac_addr_is_present)
 			e1000e_set_laa_state_82571(hw, true);
 
+	/* Reinitialize the 82571 serdes link state machine */
+	if (hw->phy.media_type == e1000_media_type_internal_serdes)
+		hw->mac.serdes_link_state = e1000_serdes_link_down;
+
 	return 0;
 }
 
@@ -1215,6 +1220,131 @@ static s32 e1000_setup_fiber_serdes_link_82571(struct e1000_hw *hw)
 }
 
 /**
+ *  e1000_check_for_serdes_link_82571 - Check for link (Serdes)
+ *  @hw: pointer to the HW structure
+ *
+ *  Checks for link up on the hardware.  If link is not up and we have
+ *  a signal, then we need to force link up.
+ **/
+s32 e1000_check_for_serdes_link_82571(struct e1000_hw *hw)
+{
+	struct e1000_mac_info *mac = &hw->mac;
+	u32 rxcw;
+	u32 ctrl;
+	u32 status;
+	s32 ret_val = 0;
+
+	ctrl = er32(CTRL);
+	status = er32(STATUS);
+	rxcw = er32(RXCW);
+
+	if ((rxcw & E1000_RXCW_SYNCH) && !(rxcw & E1000_RXCW_IV)) {
+
+		/* Receiver is synchronized with no invalid bits.  */
+		switch (mac->serdes_link_state) {
+		case e1000_serdes_link_autoneg_complete:
+			if (!(status & E1000_STATUS_LU)) {
+				/*
+				 * We have lost link, retry autoneg before
+				 * reporting link failure
+				 */
+				mac->serdes_link_state =
+				    e1000_serdes_link_autoneg_progress;
+				hw_dbg(hw, "AN_UP     -> AN_PROG\n");
+			}
+		break;
+
+		case e1000_serdes_link_forced_up:
+			/*
+			 * If we are receiving /C/ ordered sets, re-enable
+			 * auto-negotiation in the TXCW register and disable
+			 * forced link in the Device Control register in an
+			 * attempt to auto-negotiate with our link partner.
+			 */
+			if (rxcw & E1000_RXCW_C) {
+				/* Enable autoneg, and unforce link up */
+				ew32(TXCW, mac->txcw);
+				ew32(CTRL,
+				    (ctrl & ~E1000_CTRL_SLU));
+				mac->serdes_link_state =
+				    e1000_serdes_link_autoneg_progress;
+				hw_dbg(hw, "FORCED_UP -> AN_PROG\n");
+			}
+			break;
+
+		case e1000_serdes_link_autoneg_progress:
+			/*
+			 * If the LU bit is set in the STATUS register,
+			 * autoneg has completed sucessfully. If not,
+			 * try foring the link because the far end may be
+			 * available but not capable of autonegotiation.
+			 */
+			if (status & E1000_STATUS_LU)  {
+				mac->serdes_link_state =
+				    e1000_serdes_link_autoneg_complete;
+				hw_dbg(hw, "AN_PROG   -> AN_UP\n");
+			} else {
+				/*
+				 * Disable autoneg, force link up and
+				 * full duplex, and change state to forced
+				 */
+				ew32(TXCW,
+				    (mac->txcw & ~E1000_TXCW_ANE));
+				ctrl |= (E1000_CTRL_SLU | E1000_CTRL_FD);
+				ew32(CTRL, ctrl);
+
+				/* Configure Flow Control after link up. */
+				ret_val =
+				    e1000e_config_fc_after_link_up(hw);
+				if (ret_val) {
+					hw_dbg(hw, "Error config flow control\n");
+					break;
+				}
+				mac->serdes_link_state =
+				    e1000_serdes_link_forced_up;
+				hw_dbg(hw, "AN_PROG   -> FORCED_UP\n");
+			}
+			mac->serdes_has_link = true;
+			break;
+
+		case e1000_serdes_link_down:
+		default:
+			/* The link was down but the receiver has now gained
+			 * valid sync, so lets see if we can bring the link
+			 * up. */
+			ew32(TXCW, mac->txcw);
+			ew32(CTRL,
+			    (ctrl & ~E1000_CTRL_SLU));
+			mac->serdes_link_state =
+			    e1000_serdes_link_autoneg_progress;
+			hw_dbg(hw, "DOWN      -> AN_PROG\n");
+			break;
+		}
+	} else {
+		if (!(rxcw & E1000_RXCW_SYNCH)) {
+			mac->serdes_has_link = false;
+			mac->serdes_link_state = e1000_serdes_link_down;
+			hw_dbg(hw, "ANYSTATE  -> DOWN\n");
+		} else {
+			/*
+			 * We have sync, and can tolerate one
+			 * invalid (IV) codeword before declaring
+			 * link down, so reread to look again
+			 */
+			udelay(10);
+			rxcw = er32(RXCW);
+			if (rxcw & E1000_RXCW_IV) {
+				mac->serdes_link_state = e1000_serdes_link_down;
+				mac->serdes_has_link = false;
+				hw_dbg(hw, "ANYSTATE  -> DOWN\n");
+			}
+		}
+	}
+
+	return ret_val;
+}
+
+/**
  *  e1000_valid_led_default_82571 - Verify a valid default LED config
  *  @hw: pointer to the HW structure
  *  @data: pointer to the NVM (EEPROM)
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 2d4ce04..5cb428c 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -459,6 +459,13 @@ enum e1000_smart_speed {
 	e1000_smart_speed_off
 };
 
+enum e1000_serdes_link_state {
+	e1000_serdes_link_down = 0,
+	e1000_serdes_link_autoneg_progress,
+	e1000_serdes_link_autoneg_complete,
+	e1000_serdes_link_forced_up
+};
+
 /* Receive Descriptor */
 struct e1000_rx_desc {
 	__le64 buffer_addr; /* Address of the descriptor's data buffer */
@@ -787,6 +794,7 @@ struct e1000_mac_info {
 	bool in_ifs_mode;
 	bool serdes_has_link;
 	bool tx_pkt_filtering;
+	enum e1000_serdes_link_state serdes_link_state;
 };
 
 struct e1000_phy_info {

