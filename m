From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 05/13] e1000: test link state conclusively
Date: Fri, 25 Sep 2009 15:17:44 -0700
Message-ID: <20090925221744.26715.88272.stgit@localhost.localdomain>
References: <20090925221613.26715.66796.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:51852
	"EHLO QMTA14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752541AbZIYWSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 18:18:07 -0400
In-Reply-To: <20090925221613.26715.66796.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

e1000 was using one particular way to detect link, but with the advent
of some of the newer hardware designs using SERDES connections, tests
for link must completely cover all cases.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |    4 -
 drivers/net/e1000/e1000_hw.c      |  179 +++++++++++++++++++++++--------------
 drivers/net/e1000/e1000_hw.h      |    2 
 drivers/net/e1000/e1000_main.c    |   49 ++++++++--
 4 files changed, 157 insertions(+), 77 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index f2e756f..490b2b7 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1481,13 +1481,13 @@ static int e1000_link_test(struct e1000_adapter *adapter, u64 *data)
 	*data = 0;
 	if (hw->media_type == e1000_media_type_internal_serdes) {
 		int i = 0;
-		hw->serdes_link_down = true;
+		hw->serdes_has_link = false;
 
 		/* On some blade server designs, link establishment
 		 * could take as long as 2-3 minutes */
 		do {
 			e1000_check_for_link(hw);
-			if (!hw->serdes_link_down)
+			if (hw->serdes_has_link)
 				return *data;
 			msleep(20);
 		} while (i++ < 3750);
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 765fd71..076db19 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -2136,6 +2136,116 @@ static s32 e1000_config_fc_after_link_up(struct e1000_hw *hw)
     return E1000_SUCCESS;
 }
 
+/**
+ *  e1000_check_for_serdes_link_generic - Check for link (Serdes)
+ *  @hw: pointer to the HW structure
+ *
+ *  Checks for link up on the hardware.  If link is not up and we have
+ *  a signal, then we need to force link up.
+ **/
+s32 e1000_check_for_serdes_link_generic(struct e1000_hw *hw)
+{
+	u32 rxcw;
+	u32 ctrl;
+	u32 status;
+	s32 ret_val = E1000_SUCCESS;
+
+	DEBUGFUNC("e1000_check_for_serdes_link_generic");
+
+	ctrl = er32(CTRL);
+	status = er32(STATUS);
+	rxcw = er32(RXCW);
+
+	/*
+	 * If we don't have link (auto-negotiation failed or link partner
+	 * cannot auto-negotiate), and our link partner is not trying to
+	 * auto-negotiate with us (we are receiving idles or data),
+	 * we need to force link up. We also need to give auto-negotiation
+	 * time to complete.
+	 */
+	/* (ctrl & E1000_CTRL_SWDPIN1) == 1 == have signal */
+	if ((!(status & E1000_STATUS_LU)) && (!(rxcw & E1000_RXCW_C))) {
+		if (hw->autoneg_failed == 0) {
+			hw->autoneg_failed = 1;
+			goto out;
+		}
+		DEBUGOUT("NOT RXing /C/, disable AutoNeg and force link.\n");
+
+		/* Disable auto-negotiation in the TXCW register */
+		ew32(TXCW, (hw->txcw & ~E1000_TXCW_ANE));
+
+		/* Force link-up and also force full-duplex. */
+		ctrl = er32(CTRL);
+		ctrl |= (E1000_CTRL_SLU | E1000_CTRL_FD);
+		ew32(CTRL, ctrl);
+
+		/* Configure Flow Control after forcing link up. */
+		ret_val = e1000_config_fc_after_link_up(hw);
+		if (ret_val) {
+			DEBUGOUT("Error configuring flow control\n");
+			goto out;
+		}
+	} else if ((ctrl & E1000_CTRL_SLU) && (rxcw & E1000_RXCW_C)) {
+		/*
+		 * If we are forcing link and we are receiving /C/ ordered
+		 * sets, re-enable auto-negotiation in the TXCW register
+		 * and disable forced link in the Device Control register
+		 * in an attempt to auto-negotiate with our link partner.
+		 */
+		DEBUGOUT("RXing /C/, enable AutoNeg and stop forcing link.\n");
+		ew32(TXCW, hw->txcw);
+		ew32(CTRL, (ctrl & ~E1000_CTRL_SLU));
+
+		hw->serdes_has_link = true;
+	} else if (!(E1000_TXCW_ANE & er32(TXCW))) {
+		/*
+		 * If we force link for non-auto-negotiation switch, check
+		 * link status based on MAC synchronization for internal
+		 * serdes media type.
+		 */
+		/* SYNCH bit and IV bit are sticky. */
+		udelay(10);
+		rxcw = er32(RXCW);
+		if (rxcw & E1000_RXCW_SYNCH) {
+			if (!(rxcw & E1000_RXCW_IV)) {
+				hw->serdes_has_link = true;
+				DEBUGOUT("SERDES: Link up - forced.\n");
+			}
+		} else {
+			hw->serdes_has_link = false;
+			DEBUGOUT("SERDES: Link down - force failed.\n");
+		}
+	}
+
+	if (E1000_TXCW_ANE & er32(TXCW)) {
+		status = er32(STATUS);
+		if (status & E1000_STATUS_LU) {
+			/* SYNCH bit and IV bit are sticky, so reread rxcw. */
+			udelay(10);
+			rxcw = er32(RXCW);
+			if (rxcw & E1000_RXCW_SYNCH) {
+				if (!(rxcw & E1000_RXCW_IV)) {
+					hw->serdes_has_link = true;
+					DEBUGOUT("SERDES: Link up - autoneg "
+					   "completed sucessfully.\n");
+				} else {
+					hw->serdes_has_link = false;
+					DEBUGOUT("SERDES: Link down - invalid"
+					   "codewords detected in autoneg.\n");
+				}
+			} else {
+				hw->serdes_has_link = false;
+				DEBUGOUT("SERDES: Link down - no sync.\n");
+			}
+		} else {
+			hw->serdes_has_link = false;
+			DEBUGOUT("SERDES: Link down - autoneg failed\n");
+		}
+	}
+
+out:
+	return ret_val;
+}
 /******************************************************************************
  * Checks to see if the link status of the hardware has changed.
  *
@@ -2300,74 +2410,11 @@ s32 e1000_check_for_link(struct e1000_hw *hw)
             }
         }
     }
-    /* If we don't have link (auto-negotiation failed or link partner cannot
-     * auto-negotiate), the cable is plugged in (we have signal), and our
-     * link partner is not trying to auto-negotiate with us (we are receiving
-     * idles or data), we need to force link up. We also need to give
-     * auto-negotiation time to complete, in case the cable was just plugged
-     * in. The autoneg_failed flag does this.
-     */
-    else if ((((hw->media_type == e1000_media_type_fiber) &&
-              ((ctrl & E1000_CTRL_SWDPIN1) == signal)) ||
-              (hw->media_type == e1000_media_type_internal_serdes)) &&
-              (!(status & E1000_STATUS_LU)) &&
-              (!(rxcw & E1000_RXCW_C))) {
-        if (hw->autoneg_failed == 0) {
-            hw->autoneg_failed = 1;
-            return 0;
-        }
-        DEBUGOUT("NOT RXing /C/, disable AutoNeg and force link.\n");
-
-        /* Disable auto-negotiation in the TXCW register */
-        ew32(TXCW, (hw->txcw & ~E1000_TXCW_ANE));
 
-        /* Force link-up and also force full-duplex. */
-        ctrl = er32(CTRL);
-        ctrl |= (E1000_CTRL_SLU | E1000_CTRL_FD);
-        ew32(CTRL, ctrl);
-
-        /* Configure Flow Control after forcing link up. */
-        ret_val = e1000_config_fc_after_link_up(hw);
-        if (ret_val) {
-            DEBUGOUT("Error configuring flow control\n");
-            return ret_val;
-        }
-    }
-    /* If we are forcing link and we are receiving /C/ ordered sets, re-enable
-     * auto-negotiation in the TXCW register and disable forced link in the
-     * Device Control register in an attempt to auto-negotiate with our link
-     * partner.
-     */
-    else if (((hw->media_type == e1000_media_type_fiber) ||
-              (hw->media_type == e1000_media_type_internal_serdes)) &&
-              (ctrl & E1000_CTRL_SLU) && (rxcw & E1000_RXCW_C)) {
-        DEBUGOUT("RXing /C/, enable AutoNeg and stop forcing link.\n");
-        ew32(TXCW, hw->txcw);
-        ew32(CTRL, (ctrl & ~E1000_CTRL_SLU));
+    if ((hw->media_type == e1000_media_type_fiber) ||
+        (hw->media_type == e1000_media_type_internal_serdes))
+        e1000_check_for_serdes_link_generic(hw);
 
-        hw->serdes_link_down = false;
-    }
-    /* If we force link for non-auto-negotiation switch, check link status
-     * based on MAC synchronization for internal serdes media type.
-     */
-    else if ((hw->media_type == e1000_media_type_internal_serdes) &&
-             !(E1000_TXCW_ANE & er32(TXCW))) {
-        /* SYNCH bit and IV bit are sticky. */
-        udelay(10);
-        if (E1000_RXCW_SYNCH & er32(RXCW)) {
-            if (!(rxcw & E1000_RXCW_IV)) {
-                hw->serdes_link_down = false;
-                DEBUGOUT("SERDES: Link is up.\n");
-            }
-        } else {
-            hw->serdes_link_down = true;
-            DEBUGOUT("SERDES: Link is down.\n");
-        }
-    }
-    if ((hw->media_type == e1000_media_type_internal_serdes) &&
-        (E1000_TXCW_ANE & er32(TXCW))) {
-        hw->serdes_link_down = !(E1000_STATUS_LU & er32(STATUS));
-    }
     return E1000_SUCCESS;
 }
 
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 1a8a000..1c782d2 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -1372,7 +1372,7 @@ struct e1000_hw {
 	e1000_smart_speed	smart_speed;
 	e1000_dsp_config	dsp_config_state;
 	bool			get_link_status;
-	bool			serdes_link_down;
+	bool			serdes_has_link;
 	bool			tbi_compatibility_en;
 	bool			tbi_compatibility_on;
 	bool			laa_is_present;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 7af3255..11508af 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2251,6 +2251,41 @@ static void e1000_82547_tx_fifo_stall(unsigned long data)
 	}
 }
 
+static bool e1000_has_link(struct e1000_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	bool link_active = false;
+	s32 ret_val = 0;
+
+	/* get_link_status is set on LSC (link status) interrupt or
+	 * rx sequence error interrupt.  get_link_status will stay
+	 * false until the e1000_check_for_link establishes link
+	 * for copper adapters ONLY
+	 */
+	switch (hw->media_type) {
+	case e1000_media_type_copper:
+		if (hw->get_link_status) {
+			ret_val = e1000_check_for_link(hw);
+			link_active = !hw->get_link_status;
+		} else {
+			link_active = true;
+		}
+		break;
+	case e1000_media_type_fiber:
+		ret_val = e1000_check_for_link(hw);
+		link_active = !!(er32(STATUS) & E1000_STATUS_LU);
+		break;
+	case e1000_media_type_internal_serdes:
+		ret_val = e1000_check_for_link(hw);
+		link_active = hw->serdes_has_link;
+		break;
+	default:
+		break;
+	}
+
+	return link_active;
+}
+
 /**
  * e1000_watchdog - Timer Call-back
  * @data: pointer to adapter cast into an unsigned long
@@ -2263,18 +2298,15 @@ static void e1000_watchdog(unsigned long data)
 	struct e1000_tx_ring *txdr = adapter->tx_ring;
 	u32 link, tctl;
 
-	e1000_check_for_link(hw);
-
-	if ((hw->media_type == e1000_media_type_internal_serdes) &&
-	   !(er32(TXCW) & E1000_TXCW_ANE))
-		link = !hw->serdes_link_down;
-	else
-		link = er32(STATUS) & E1000_STATUS_LU;
+	link = e1000_has_link(adapter);
+	if ((netif_carrier_ok(netdev)) && link)
+		goto link_up;
 
 	if (link) {
 		if (!netif_carrier_ok(netdev)) {
 			u32 ctrl;
 			bool txb2b = true;
+			/* update snapshot of PHY registers on LSC */
 			e1000_get_speed_and_duplex(hw,
 			                           &adapter->link_speed,
 			                           &adapter->link_duplex);
@@ -2299,7 +2331,7 @@ static void e1000_watchdog(unsigned long data)
 			case SPEED_10:
 				txb2b = false;
 				netdev->tx_queue_len = 10;
-				adapter->tx_timeout_factor = 8;
+				adapter->tx_timeout_factor = 16;
 				break;
 			case SPEED_100:
 				txb2b = false;
@@ -2335,6 +2367,7 @@ static void e1000_watchdog(unsigned long data)
 		e1000_smartspeed(adapter);
 	}
 
+link_up:
 	e1000_update_stats(adapter);
 
 	hw->tx_packet_delta = adapter->stats.tpt - adapter->tpt_old;

