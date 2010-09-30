From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/3] e1000e: reset PHY after errors detected on
	82574 Si
Date: Thu, 30 Sep 2010 00:39:12 -0700
Message-ID: <20100930073909.13378.34776.stgit@localhost.localdomain>
References: <20100930073814.13378.4212.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:45756
	"EHLO qmta13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754925Ab0I3HpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 03:45:19 -0400
In-Reply-To: <20100930073814.13378.4212.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

Some errors can be induced in the PHY via environmental testing
(specifically extreme temperature changes and electro static
discharge testing), and in the case of the PHY hanging due to
this input, this detects the problem and resets to continue.
This issue only applies to 82574 silicon.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c  |   40 +++++++++++++++++++++++++++++++++++++++-
 drivers/net/e1000e/e1000.h  |    3 +++
 drivers/net/e1000e/netdev.c |   25 +++++++++++++++++++++++++
 3 files changed, 67 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index ca663f1..db5ef6e 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -52,6 +52,10 @@
 			      (ID_LED_DEF1_DEF2))
 
 #define E1000_GCR_L1_ACT_WITHOUT_L0S_RX 0x08000000
+#define E1000_BASE1000T_STATUS          10
+#define E1000_IDLE_ERROR_COUNT_MASK     0xFF
+#define E1000_RECEIVE_ERROR_COUNTER     21
+#define E1000_RECEIVE_ERROR_MAX         0xFFFF
 
 #define E1000_NVM_INIT_CTRL2_MNGM 0x6000 /* Manageability Operation Mode mask */
 
@@ -1243,6 +1247,39 @@ static s32 e1000_led_on_82574(struct e1000_hw *hw)
 }
 
 /**
+ *  e1000_check_phy_82574 - check 82574 phy hung state
+ *  @hw: pointer to the HW structure
+ *
+ *  Returns whether phy is hung or not
+ **/
+bool e1000_check_phy_82574(struct e1000_hw *hw)
+{
+	u16 status_1kbt = 0;
+	u16 receive_errors = 0;
+	bool phy_hung = false;
+	s32 ret_val = 0;
+
+	/*
+	 * Read PHY Receive Error counter first, if its is max - all F's then
+	 * read the Base1000T status register If both are max then PHY is hung.
+	 */
+	ret_val = e1e_rphy(hw, E1000_RECEIVE_ERROR_COUNTER, &receive_errors);
+
+	if (ret_val)
+		goto out;
+	if (receive_errors == E1000_RECEIVE_ERROR_MAX)  {
+		ret_val = e1e_rphy(hw, E1000_BASE1000T_STATUS, &status_1kbt);
+		if (ret_val)
+			goto out;
+		if ((status_1kbt & E1000_IDLE_ERROR_COUNT_MASK) ==
+		    E1000_IDLE_ERROR_COUNT_MASK)
+			phy_hung = true;
+	}
+out:
+	return phy_hung;
+}
+
+/**
  *  e1000_setup_link_82571 - Setup flow control and link settings
  *  @hw: pointer to the HW structure
  *
@@ -1858,7 +1895,8 @@ struct e1000_info e1000_82574_info = {
 				  | FLAG_RX_CSUM_ENABLED
 				  | FLAG_HAS_SMART_POWER_DOWN
 				  | FLAG_HAS_AMT
-				  | FLAG_HAS_CTRLEXT_ON_LOAD,
+				  | FLAG_HAS_CTRLEXT_ON_LOAD
+				  | FLAG2_CHECK_PHY_HANG,
 	.pba			= 36,
 	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_82571,
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 5ec0af5..da3b82f 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -397,6 +397,7 @@ struct e1000_adapter {
 	struct work_struct print_hang_task;
 
 	bool idle_check;
+	int phy_hang_count;
 };
 
 struct e1000_info {
@@ -453,6 +454,7 @@ struct e1000_info {
 #define FLAG2_HAS_PHY_STATS               (1 << 4)
 #define FLAG2_HAS_EEE                     (1 << 5)
 #define FLAG2_DMA_BURST                   (1 << 6)
+#define FLAG2_CHECK_PHY_HANG              (1 << 7)
 
 #define E1000_RX_DESC_PS(R, i)	    \
 	(&(((union e1000_rx_desc_packet_split *)((R).desc))[i]))
@@ -630,6 +632,7 @@ extern s32 e1000_get_phy_info_ife(struct e1000_hw *hw);
 extern s32 e1000_check_polarity_ife(struct e1000_hw *hw);
 extern s32 e1000_phy_force_speed_duplex_ife(struct e1000_hw *hw);
 extern s32 e1000_check_polarity_igp(struct e1000_hw *hw);
+extern bool e1000_check_phy_82574(struct e1000_hw *hw);
 
 static inline s32 e1000_phy_hw_reset(struct e1000_hw *hw)
 {
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 1aa4228..a8b55ab 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4060,6 +4060,28 @@ static void e1000e_enable_receives(struct e1000_adapter *adapter)
 	}
 }
 
+static void e1000e_check_82574_phy_workaround(struct e1000_adapter *adapter)
+{
+	struct e1000_hw *hw = &adapter->hw;
+
+	if (!(adapter->flags2 & FLAG2_CHECK_PHY_HANG))
+		return;
+
+	/*
+	 * With 82574 controllers, PHY needs to be checked periodically
+	 * for hung state and reset, if two calls return true
+	 */
+	if (e1000_check_phy_82574(hw))
+		adapter->phy_hang_count++;
+	else
+		adapter->phy_hang_count = 0;
+
+	if (adapter->phy_hang_count > 1) {
+		adapter->phy_hang_count = 0;
+		schedule_work(&adapter->reset_task);
+	}
+}
+
 /**
  * e1000_watchdog - Timer Call-back
  * @data: pointer to adapter cast into an unsigned long
@@ -4295,6 +4317,9 @@ link_up:
 	if (e1000e_get_laa_state_82571(hw))
 		e1000e_rar_set(hw, adapter->hw.mac.addr, 0);
 
+	if (adapter->flags2 & FLAG2_CHECK_PHY_HANG)
+		e1000e_check_82574_phy_workaround(adapter);
+
 	/* Reset the timer */
 	if (!test_bit(__E1000_DOWN, &adapter->state))
 		mod_timer(&adapter->watchdog_timer,

