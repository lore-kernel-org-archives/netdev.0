From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RESEND][NET-NEXT PATCH 04/29] ixgbe: Update watchdog thread to
	accomodate longerlink_up events
Date: Thu, 11 Sep 2008 19:55:32 -0700
Message-ID: <20080912025517.6234.56321.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:43432 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754764AbYILCzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 22:55:35 -0400
Received: by wa-out-1112.google.com with SMTP id j37so392135waf.23
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 19:55:35 -0700 (PDT)
In-Reply-To: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This patch updates the link_up code and watchdog thread so that link_up
doesn't cause stack overflows due to long waits in interrupt context.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |    6 ++
 drivers/net/ixgbe/ixgbe_82598.c   |   29 +++++++-
 drivers/net/ixgbe/ixgbe_ethtool.c |    2 -
 drivers/net/ixgbe/ixgbe_main.c    |  129 +++++++++++++++++++++++++------------
 drivers/net/ixgbe/ixgbe_type.h    |    3 +
 5 files changed, 118 insertions(+), 51 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 90b5383..2b827a6 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -309,6 +309,12 @@ struct ixgbe_adapter {
 	u64 lro_aggregated;
 	u64 lro_flushed;
 	u64 lro_no_desc;
+
+	u32 link_speed;
+	bool link_up;
+	unsigned long link_check_timeout;
+
+	struct work_struct watchdog_task;
 };
 
 enum ixbge_state_t {
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index ba09063..1e014bc 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -47,7 +47,8 @@ static s32 ixgbe_get_copper_link_settings_82598(struct ixgbe_hw *hw,
 static enum ixgbe_media_type ixgbe_get_media_type_82598(struct ixgbe_hw *hw);
 static s32 ixgbe_setup_mac_link_82598(struct ixgbe_hw *hw);
 static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw, u32 *speed,
-				      bool *link_up);
+                                      bool *link_up,
+                                      bool link_up_wait_to_complete);
 static s32 ixgbe_setup_mac_link_speed_82598(struct ixgbe_hw *hw, u32 speed,
 					    bool autoneg,
 					    bool autoneg_wait_to_complete);
@@ -277,20 +278,36 @@ static s32 ixgbe_setup_mac_link_82598(struct ixgbe_hw *hw)
  *  @hw: pointer to hardware structure
  *  @speed: pointer to link speed
  *  @link_up: true is link is up, false otherwise
+ *  @link_up_wait_to_complete: bool used to wait for link up or not
  *
  *  Reads the links register to determine if link is up and the current speed
  **/
 static s32 ixgbe_check_mac_link_82598(struct ixgbe_hw *hw, u32 *speed,
-				      bool *link_up)
+                                      bool *link_up,
+                                      bool link_up_wait_to_complete)
 {
 	u32 links_reg;
+	u32 i;
 
 	links_reg = IXGBE_READ_REG(hw, IXGBE_LINKS);
 
-	if (links_reg & IXGBE_LINKS_UP)
-		*link_up = true;
-	else
-		*link_up = false;
+	if (link_up_wait_to_complete) {
+		for (i = 0; i < IXGBE_LINK_UP_TIME; i++) {
+			if (links_reg & IXGBE_LINKS_UP) {
+				*link_up = true;
+				break;
+			} else {
+				*link_up = false;
+			}
+			msleep(100);
+			links_reg = IXGBE_READ_REG(hw, IXGBE_LINKS);
+		}
+	} else {
+		if (links_reg & IXGBE_LINKS_UP)
+			*link_up = true;
+		else
+			*link_up = false;
+	}
 
 	if (links_reg & IXGBE_LINKS_SPEED)
 		*speed = IXGBE_LINK_SPEED_10GB_FULL;
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 61c000e..8f0e3f9 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -130,7 +130,7 @@ static int ixgbe_get_settings(struct net_device *netdev,
 		ecmd->port = PORT_FIBRE;
 	}
 
-	adapter->hw.mac.ops.check_link(hw, &(link_speed), &link_up);
+	adapter->hw.mac.ops.check_link(hw, &(link_speed), &link_up, false);
 	if (link_up) {
 		ecmd->speed = (link_speed == IXGBE_LINK_SPEED_10GB_FULL) ?
 				SPEED_10000 : SPEED_1000;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 9048195..036393e 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -902,6 +902,20 @@ static void ixgbe_set_itr_msix(struct ixgbe_q_vector *q_vector)
 	return;
 }
 
+
+static void ixgbe_check_lsc(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	adapter->lsc_int++;
+	adapter->flags |= IXGBE_FLAG_NEED_LINK_UPDATE;
+	adapter->link_check_timeout = jiffies;
+	if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
+		IXGBE_WRITE_REG(hw, IXGBE_EIMC, IXGBE_EIMC_LSC);
+		schedule_work(&adapter->watchdog_task);
+	}
+}
+
 static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 {
 	struct net_device *netdev = data;
@@ -909,11 +923,8 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 eicr = IXGBE_READ_REG(hw, IXGBE_EICR);
 
-	if (eicr & IXGBE_EICR_LSC) {
-		adapter->lsc_int++;
-		if (!test_bit(__IXGBE_DOWN, &adapter->state))
-			mod_timer(&adapter->watchdog_timer, jiffies);
-	}
+	if (eicr & IXGBE_EICR_LSC)
+		ixgbe_check_lsc(adapter);
 
 	if (!test_bit(__IXGBE_DOWN, &adapter->state))
 		IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EIMS_OTHER);
@@ -1237,12 +1248,8 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	if (!eicr)
 		return IRQ_NONE;	/* Not our interrupt */
 
-	if (eicr & IXGBE_EICR_LSC) {
-		adapter->lsc_int++;
-		if (!test_bit(__IXGBE_DOWN, &adapter->state))
-			mod_timer(&adapter->watchdog_timer, jiffies);
-	}
-
+	if (eicr & IXGBE_EICR_LSC)
+		ixgbe_check_lsc(adapter);
 
 	if (netif_rx_schedule_prep(netdev, &adapter->q_vector[0].napi)) {
 		adapter->tx_ring[0].total_packets = 0;
@@ -1897,6 +1904,8 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 
 	/* bring the link up in the watchdog, this could race with our first
 	 * link up interrupt but shouldn't be a problem */
+	adapter->flags |= IXGBE_FLAG_NEED_LINK_UPDATE;
+	adapter->link_check_timeout = jiffies;
 	mod_timer(&adapter->watchdog_timer, jiffies);
 	return 0;
 }
@@ -2098,6 +2107,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 	ixgbe_napi_disable_all(adapter);
 	del_timer_sync(&adapter->watchdog_timer);
+	cancel_work_sync(&adapter->watchdog_task);
 
 	netif_carrier_off(netdev);
 	netif_tx_stop_all_queues(netdev);
@@ -3010,27 +3020,74 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 static void ixgbe_watchdog(unsigned long data)
 {
 	struct ixgbe_adapter *adapter = (struct ixgbe_adapter *)data;
-	struct net_device *netdev = adapter->netdev;
-	bool link_up;
-	u32 link_speed = 0;
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	/* Do the watchdog outside of interrupt context due to the lovely
+	 * delays that some of the newer hardware requires */
+	if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
+		/* Cause software interrupt to ensure rx rings are cleaned */
+		if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+			u32 eics =
+			 (1 << (adapter->num_msix_vectors - NON_Q_VECTORS)) - 1;
+			IXGBE_WRITE_REG(hw, IXGBE_EICS, eics);
+		} else {
+			/* For legacy and MSI interrupts don't set any bits that
+			 * are enabled for EIAM, because this operation would
+			 * set *both* EIMS and EICS for any bit in EIAM */
+			IXGBE_WRITE_REG(hw, IXGBE_EICS,
+                                    (IXGBE_EICS_TCP_TIMER | IXGBE_EICS_OTHER));
+		}
+		/* Reset the timer */
+		mod_timer(&adapter->watchdog_timer,
+		          round_jiffies(jiffies + 2 * HZ));
+	}
 
-	adapter->hw.mac.ops.check_link(&adapter->hw, &(link_speed), &link_up);
+	schedule_work(&adapter->watchdog_task);
+}
+
+/**
+ *  ixgbe_watchdog_task - worker thread to bring link up
+ *  @work: pointer to work_struct containing our data
+ **/
+static void ixgbe_watchdog_task(struct work_struct *work)
+{
+	struct ixgbe_adapter *adapter = container_of(work,
+	                                             struct ixgbe_adapter,
+	                                             watchdog_task);
+	struct net_device *netdev = adapter->netdev;
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 link_speed = adapter->link_speed;
+	bool link_up = adapter->link_up;
+
+	adapter->flags |= IXGBE_FLAG_IN_WATCHDOG_TASK;
+
+	if (adapter->flags & IXGBE_FLAG_NEED_LINK_UPDATE) {
+		hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
+		if (link_up ||
+		    time_after(jiffies, (adapter->link_check_timeout +
+		                         IXGBE_TRY_LINK_TIMEOUT))) {
+			IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EIMC_LSC);
+			adapter->flags &= ~IXGBE_FLAG_NEED_LINK_UPDATE;
+		}
+		adapter->link_up = link_up;
+		adapter->link_speed = link_speed;
+	}
 
 	if (link_up) {
 		if (!netif_carrier_ok(netdev)) {
-			u32 frctl = IXGBE_READ_REG(&adapter->hw, IXGBE_FCTRL);
-			u32 rmcs = IXGBE_READ_REG(&adapter->hw, IXGBE_RMCS);
+			u32 frctl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
+			u32 rmcs = IXGBE_READ_REG(hw, IXGBE_RMCS);
 #define FLOW_RX (frctl & IXGBE_FCTRL_RFCE)
 #define FLOW_TX (rmcs & IXGBE_RMCS_TFCE_802_3X)
 			DPRINTK(LINK, INFO, "NIC Link is Up %s, "
-				"Flow Control: %s\n",
-				(link_speed == IXGBE_LINK_SPEED_10GB_FULL ?
-				 "10 Gbps" :
-				 (link_speed == IXGBE_LINK_SPEED_1GB_FULL ?
-				  "1 Gbps" : "unknown speed")),
-				((FLOW_RX && FLOW_TX) ? "RX/TX" :
-				 (FLOW_RX ? "RX" :
-				 (FLOW_TX ? "TX" : "None"))));
+			        "Flow Control: %s\n",
+			        (link_speed == IXGBE_LINK_SPEED_10GB_FULL ?
+			         "10 Gbps" :
+			         (link_speed == IXGBE_LINK_SPEED_1GB_FULL ?
+			          "1 Gbps" : "unknown speed")),
+			        ((FLOW_RX && FLOW_TX) ? "RX/TX" :
+			         (FLOW_RX ? "RX" :
+			         (FLOW_TX ? "TX" : "None"))));
 
 			netif_carrier_on(netdev);
 			netif_tx_wake_all_queues(netdev);
@@ -3039,6 +3096,8 @@ static void ixgbe_watchdog(unsigned long data)
 			adapter->detect_tx_hung = true;
 		}
 	} else {
+		adapter->link_up = false;
+		adapter->link_speed = 0;
 		if (netif_carrier_ok(netdev)) {
 			DPRINTK(LINK, INFO, "NIC Link is Down\n");
 			netif_carrier_off(netdev);
@@ -3047,24 +3106,7 @@ static void ixgbe_watchdog(unsigned long data)
 	}
 
 	ixgbe_update_stats(adapter);
-
-	if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
-		/* Cause software interrupt to ensure rx rings are cleaned */
-		if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
-			u32 eics =
-			 (1 << (adapter->num_msix_vectors - NON_Q_VECTORS)) - 1;
-			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS, eics);
-		} else {
-			/* for legacy and MSI interrupts don't set any bits that
-			 * are enabled for EIAM, because this operation would
-			 * set *both* EIMS and EICS for any bit in EIAM */
-			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS,
-				     (IXGBE_EICS_TCP_TIMER | IXGBE_EICS_OTHER));
-		}
-		/* Reset the timer */
-		mod_timer(&adapter->watchdog_timer,
-			  round_jiffies(jiffies + 2 * HZ));
-	}
+	adapter->flags &= ~IXGBE_FLAG_IN_WATCHDOG_TASK;
 }
 
 static int ixgbe_tso(struct ixgbe_adapter *adapter,
@@ -3707,6 +3749,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	adapter->watchdog_timer.data = (unsigned long)adapter;
 
 	INIT_WORK(&adapter->reset_task, ixgbe_reset_task);
+	INIT_WORK(&adapter->watchdog_task, ixgbe_watchdog_task);
 
 	err = ixgbe_init_interrupt_scheme(adapter);
 	if (err)
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 3e9c483..172f766 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -703,6 +703,7 @@
 #define IXGBE_LINKS_TL_FAULT    0x00001000
 #define IXGBE_LINKS_SIGNAL      0x00000F00
 
+#define IXGBE_LINK_UP_TIME      90 /* 9.0 Seconds */
 #define IXGBE_AUTO_NEG_TIME     45 /* 4.5 Seconds */
 
 /* SW Semaphore Register bitmasks */
@@ -1249,7 +1250,7 @@ struct ixgbe_mac_operations {
 	s32 (*reset)(struct ixgbe_hw *);
 	enum ixgbe_media_type (*get_media_type)(struct ixgbe_hw *);
 	s32 (*setup_link)(struct ixgbe_hw *);
-	s32 (*check_link)(struct ixgbe_hw *, u32 *, bool *);
+	s32 (*check_link)(struct ixgbe_hw *, u32 *, bool *, bool);
 	s32 (*setup_link_speed)(struct ixgbe_hw *, u32, bool, bool);
 	s32 (*get_link_settings)(struct ixgbe_hw *, u32 *, bool *);
 };

