From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 51/58] ethernet/intel: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:35 -0700
Message-ID: <1508200182-104605-52-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly. Switches test of .data field to
.function, since .data will be going away.

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: intel-wired-lan@lists.osuosl.org
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/intel/e100.c                 |  6 +++---
 drivers/net/ethernet/intel/e1000e/netdev.c        | 14 ++++++--------
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c      |  8 ++++----
 drivers/net/ethernet/intel/i40e/i40e_main.c       |  8 ++++----
 drivers/net/ethernet/intel/i40evf/i40evf_main.c   |  8 ++++----
 drivers/net/ethernet/intel/igb/igb_main.c         | 18 ++++++++----------
 drivers/net/ethernet/intel/igbvf/netdev.c         |  7 +++----
 drivers/net/ethernet/intel/ixgb/ixgb_main.c       |  9 ++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  7 +++----
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  8 ++++----
 10 files changed, 43 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 184f11242f56..44b3937f7e81 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -1710,9 +1710,9 @@ static void e100_adjust_adaptive_ifs(struct nic *nic, int speed, int duplex)
 	}
 }
 
-static void e100_watchdog(unsigned long data)
+static void e100_watchdog(struct timer_list *t)
 {
-	struct nic *nic = (struct nic *)data;
+	struct nic *nic = from_timer(nic, t, watchdog);
 	struct ethtool_cmd cmd = { .cmd = ETHTOOL_GSET };
 	u32 speed;
 
@@ -2920,7 +2920,7 @@ static int e100_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_master(pdev);
 
-	setup_timer(&nic->watchdog, e100_watchdog, (unsigned long)nic);
+	timer_setup(&nic->watchdog, e100_watchdog, 0);
 
 	INIT_WORK(&nic->tx_timeout_task, e100_tx_timeout_task);
 
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index bf8f38f76953..f2f49239b015 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4823,9 +4823,9 @@ static void e1000e_update_phy_task(struct work_struct *work)
  * Need to wait a few seconds after link up to get diagnostic information from
  * the phy
  **/
-static void e1000_update_phy_info(unsigned long data)
+static void e1000_update_phy_info(struct timer_list *t)
 {
-	struct e1000_adapter *adapter = (struct e1000_adapter *)data;
+	struct e1000_adapter *adapter = from_timer(adapter, t, phy_info_timer);
 
 	if (test_bit(__E1000_DOWN, &adapter->state))
 		return;
@@ -5159,9 +5159,9 @@ static void e1000e_check_82574_phy_workaround(struct e1000_adapter *adapter)
  * e1000_watchdog - Timer Call-back
  * @data: pointer to adapter cast into an unsigned long
  **/
-static void e1000_watchdog(unsigned long data)
+static void e1000_watchdog(struct timer_list *t)
 {
-	struct e1000_adapter *adapter = (struct e1000_adapter *)data;
+	struct e1000_adapter *adapter = from_timer(adapter, t, watchdog_timer);
 
 	/* Do the rest outside of interrupt context */
 	schedule_work(&adapter->watchdog_task);
@@ -7267,10 +7267,8 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_eeprom;
 	}
 
-	setup_timer(&adapter->watchdog_timer, e1000_watchdog,
-		    (unsigned long)adapter);
-	setup_timer(&adapter->phy_info_timer, e1000_update_phy_info,
-		    (unsigned long)adapter);
+	timer_setup(&adapter->watchdog_timer, e1000_watchdog, 0);
+	timer_setup(&adapter->phy_info_timer, e1000_update_phy_info, 0);
 
 	INIT_WORK(&adapter->reset_task, e1000_reset_task);
 	INIT_WORK(&adapter->watchdog_task, e1000_watchdog_task);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 1e9ae3197b17..7f605221a686 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -213,9 +213,10 @@ static void fm10k_start_service_event(struct fm10k_intfc *interface)
  * fm10k_service_timer - Timer Call-back
  * @data: pointer to interface cast into an unsigned long
  **/
-static void fm10k_service_timer(unsigned long data)
+static void fm10k_service_timer(struct timer_list *t)
 {
-	struct fm10k_intfc *interface = (struct fm10k_intfc *)data;
+	struct fm10k_intfc *interface = from_timer(interface, t,
+						   service_timer);
 
 	/* Reset the timer */
 	mod_timer(&interface->service_timer, (HZ * 2) + jiffies);
@@ -2315,8 +2316,7 @@ static int fm10k_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* Initialize service timer and service task late in order to avoid
 	 * cleanup issues.
 	 */
-	setup_timer(&interface->service_timer, &fm10k_service_timer,
-		    (unsigned long)interface);
+	timer_setup(&interface->service_timer, fm10k_service_timer, 0);
 	INIT_WORK(&interface->service_task, fm10k_service_task);
 
 	/* Setup the MAC/VLAN queue */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 4de52001a2b9..53d7830a4251 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7629,9 +7629,9 @@ static void i40e_service_task(struct work_struct *work)
  * i40e_service_timer - timer callback
  * @data: pointer to PF struct
  **/
-static void i40e_service_timer(unsigned long data)
+static void i40e_service_timer(struct timer_list *t)
 {
-	struct i40e_pf *pf = (struct i40e_pf *)data;
+	struct i40e_pf *pf = from_timer(pf, t, service_timer);
 
 	mod_timer(&pf->service_timer,
 		  round_jiffies(jiffies + pf->service_timer_period));
@@ -11557,7 +11557,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 #endif /* CONFIG_I40E_DCB */
 
 	/* set up periodic task facility */
-	setup_timer(&pf->service_timer, i40e_service_timer, (unsigned long)pf);
+	timer_setup(&pf->service_timer, i40e_service_timer, 0);
 	pf->service_timer_period = HZ;
 
 	INIT_WORK(&pf->service_task, i40e_service_task);
@@ -11880,7 +11880,7 @@ static void i40e_remove(struct pci_dev *pdev)
 	/* no more scheduling of any task */
 	set_bit(__I40E_SUSPENDED, pf->state);
 	set_bit(__I40E_DOWN, pf->state);
-	if (pf->service_timer.data)
+	if (pf->service_timer.function)
 		del_timer_sync(&pf->service_timer);
 	if (pf->service_task.func)
 		cancel_work_sync(&pf->service_task);
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 5bcbd46e2f6c..ca2ebdbd24d7 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1594,9 +1594,10 @@ static int i40evf_reinit_interrupt_scheme(struct i40evf_adapter *adapter)
  * i40evf_watchdog_timer - Periodic call-back timer
  * @data: pointer to adapter disguised as unsigned long
  **/
-static void i40evf_watchdog_timer(unsigned long data)
+static void i40evf_watchdog_timer(struct timer_list *t)
 {
-	struct i40evf_adapter *adapter = (struct i40evf_adapter *)data;
+	struct i40evf_adapter *adapter = from_timer(adapter, t,
+						    watchdog_timer);
 
 	schedule_work(&adapter->watchdog_task);
 	/* timer will be rescheduled in watchdog task */
@@ -2748,8 +2749,7 @@ static void i40evf_init_task(struct work_struct *work)
 		ether_addr_copy(netdev->perm_addr, adapter->hw.mac.addr);
 	}
 
-	setup_timer(&adapter->watchdog_timer, &i40evf_watchdog_timer,
-		    (unsigned long)adapter);
+	timer_setup(&adapter->watchdog_timer, i40evf_watchdog_timer, 0);
 	mod_timer(&adapter->watchdog_timer, jiffies + 1);
 
 	adapter->tx_desc_count = I40EVF_DEFAULT_TXD;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 837d9b46a390..58d01a211367 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -133,8 +133,8 @@ static void igb_clean_all_rx_rings(struct igb_adapter *);
 static void igb_clean_tx_ring(struct igb_ring *);
 static void igb_clean_rx_ring(struct igb_ring *);
 static void igb_set_rx_mode(struct net_device *);
-static void igb_update_phy_info(unsigned long);
-static void igb_watchdog(unsigned long);
+static void igb_update_phy_info(struct timer_list *);
+static void igb_watchdog(struct timer_list *);
 static void igb_watchdog_task(struct work_struct *);
 static netdev_tx_t igb_xmit_frame(struct sk_buff *skb, struct net_device *);
 static void igb_get_stats64(struct net_device *dev,
@@ -2538,10 +2538,8 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		wr32(E1000_TXPBS, I210_TXPBSIZE_DEFAULT);
 	}
 
-	setup_timer(&adapter->watchdog_timer, igb_watchdog,
-		    (unsigned long) adapter);
-	setup_timer(&adapter->phy_info_timer, igb_update_phy_info,
-		    (unsigned long) adapter);
+	timer_setup(&adapter->watchdog_timer, igb_watchdog, 0);
+	timer_setup(&adapter->phy_info_timer, igb_update_phy_info, 0);
 
 	INIT_WORK(&adapter->reset_task, igb_reset_task);
 	INIT_WORK(&adapter->watchdog_task, igb_watchdog_task);
@@ -4425,9 +4423,9 @@ static void igb_spoof_check(struct igb_adapter *adapter)
 /* Need to wait a few seconds after link up to get diagnostic information from
  * the phy
  */
-static void igb_update_phy_info(unsigned long data)
+static void igb_update_phy_info(struct timer_list *t)
 {
-	struct igb_adapter *adapter = (struct igb_adapter *) data;
+	struct igb_adapter *adapter = from_timer(adapter, t, phy_info_timer);
 	igb_get_phy_info(&adapter->hw);
 }
 
@@ -4514,9 +4512,9 @@ static void igb_check_lvmmc(struct igb_adapter *adapter)
  *  igb_watchdog - Timer Call-back
  *  @data: pointer to adapter cast into an unsigned long
  **/
-static void igb_watchdog(unsigned long data)
+static void igb_watchdog(struct timer_list *t)
 {
-	struct igb_adapter *adapter = (struct igb_adapter *)data;
+	struct igb_adapter *adapter = from_timer(adapter, t, watchdog_timer);
 	/* Do the rest outside of interrupt context */
 	schedule_work(&adapter->watchdog_task);
 }
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 1ed556911b14..713e8df23744 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -1915,9 +1915,9 @@ static bool igbvf_has_link(struct igbvf_adapter *adapter)
  * igbvf_watchdog - Timer Call-back
  * @data: pointer to adapter cast into an unsigned long
  **/
-static void igbvf_watchdog(unsigned long data)
+static void igbvf_watchdog(struct timer_list *t)
 {
-	struct igbvf_adapter *adapter = (struct igbvf_adapter *)data;
+	struct igbvf_adapter *adapter = from_timer(adapter, t, watchdog_timer);
 
 	/* Do the rest outside of interrupt context */
 	schedule_work(&adapter->watchdog_task);
@@ -2878,8 +2878,7 @@ static int igbvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		       netdev->addr_len);
 	}
 
-	setup_timer(&adapter->watchdog_timer, &igbvf_watchdog,
-		    (unsigned long)adapter);
+	timer_setup(&adapter->watchdog_timer, igbvf_watchdog, 0);
 
 	INIT_WORK(&adapter->reset_task, igbvf_reset_task);
 	INIT_WORK(&adapter->watchdog_task, igbvf_watchdog_task);
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 1e6ec2277d54..2353c383f0a7 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -83,7 +83,7 @@ static void ixgb_setup_rctl(struct ixgb_adapter *adapter);
 static void ixgb_clean_tx_ring(struct ixgb_adapter *adapter);
 static void ixgb_clean_rx_ring(struct ixgb_adapter *adapter);
 static void ixgb_set_multi(struct net_device *netdev);
-static void ixgb_watchdog(unsigned long data);
+static void ixgb_watchdog(struct timer_list *t);
 static netdev_tx_t ixgb_xmit_frame(struct sk_buff *skb,
 				   struct net_device *netdev);
 static int ixgb_change_mtu(struct net_device *netdev, int new_mtu);
@@ -508,8 +508,7 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	adapter->part_num = ixgb_get_ee_pba_number(&adapter->hw);
 
-	setup_timer(&adapter->watchdog_timer, ixgb_watchdog,
-		    (unsigned long)adapter);
+	timer_setup(&adapter->watchdog_timer, ixgb_watchdog, 0);
 
 	INIT_WORK(&adapter->tx_timeout_task, ixgb_tx_timeout_task);
 
@@ -1151,9 +1150,9 @@ ixgb_set_multi(struct net_device *netdev)
  **/
 
 static void
-ixgb_watchdog(unsigned long data)
+ixgb_watchdog(struct timer_list *t)
 {
-	struct ixgb_adapter *adapter = (struct ixgb_adapter *)data;
+	struct ixgb_adapter *adapter = from_timer(adapter, t, watchdog_timer);
 	struct net_device *netdev = adapter->netdev;
 	struct ixgb_desc_ring *txdr = &adapter->tx_ring;
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7683c14024aa..3e83edd10e23 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7690,9 +7690,9 @@ static void ixgbe_sfp_link_config_subtask(struct ixgbe_adapter *adapter)
  * ixgbe_service_timer - Timer Call-back
  * @data: pointer to adapter cast into an unsigned long
  **/
-static void ixgbe_service_timer(unsigned long data)
+static void ixgbe_service_timer(struct timer_list *t)
 {
-	struct ixgbe_adapter *adapter = (struct ixgbe_adapter *)data;
+	struct ixgbe_adapter *adapter = from_timer(adapter, t, service_timer);
 	unsigned long next_event_offset;
 
 	/* poll faster when waiting for link */
@@ -10508,8 +10508,7 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	ether_addr_copy(hw->mac.addr, hw->mac.perm_addr);
 	ixgbe_mac_set_default_filter(adapter);
 
-	setup_timer(&adapter->service_timer, &ixgbe_service_timer,
-		    (unsigned long) adapter);
+	timer_setup(&adapter->service_timer, ixgbe_service_timer, 0);
 
 	if (ixgbe_removed(hw->hw_addr)) {
 		err = -EIO;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 032f8ac06357..12d3601b1d57 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2747,9 +2747,10 @@ void ixgbevf_update_stats(struct ixgbevf_adapter *adapter)
  * ixgbevf_service_timer - Timer Call-back
  * @data: pointer to adapter cast into an unsigned long
  **/
-static void ixgbevf_service_timer(unsigned long data)
+static void ixgbevf_service_timer(struct timer_list *t)
 {
-	struct ixgbevf_adapter *adapter = (struct ixgbevf_adapter *)data;
+	struct ixgbevf_adapter *adapter = from_timer(adapter, t,
+						     service_timer);
 
 	/* Reset the timer */
 	mod_timer(&adapter->service_timer, (HZ * 2) + jiffies);
@@ -4120,8 +4121,7 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_sw_init;
 	}
 
-	setup_timer(&adapter->service_timer, &ixgbevf_service_timer,
-		    (unsigned long)adapter);
+	timer_setup(&adapter->service_timer, ixgbevf_service_timer, 0);
 
 	INIT_WORK(&adapter->service_task, ixgbevf_service_task);
 	set_bit(__IXGBEVF_SERVICE_INITED, &adapter->state);
-- 
2.7.4
