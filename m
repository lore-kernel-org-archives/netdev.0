From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] e1000 fixes
Date: Fri, 27 Apr 2007 13:06:17 -0400
Message-ID: <20070427170617.GA3302@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756333AbXD0RGX@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'e1000-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git e1000-fixes

to receive the following updates:

 drivers/net/e1000/e1000_main.c |  104 ++++++++++++++++++++++------------------
 1 files changed, 58 insertions(+), 46 deletions(-)

Auke Kok (1):
      e1000: FIX: be ready for incoming irq at pci_request_irq

Bruce Allan (1):
      e1000: FIX: firmware handover bits

Mark Huth (1):
      e1000: FIX: Stop raw interrupts disabled nag from RT

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index b28a915..eb3ff1f 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -409,25 +409,21 @@ e1000_release_hw_control(struct e1000_adapter *adapter)
 {
 	uint32_t ctrl_ext;
 	uint32_t swsm;
-	uint32_t extcnf;
 
 	/* Let firmware taken over control of h/w */
 	switch (adapter->hw.mac_type) {
-	case e1000_82571:
-	case e1000_82572:
-	case e1000_80003es2lan:
-		ctrl_ext = E1000_READ_REG(&adapter->hw, CTRL_EXT);
-		E1000_WRITE_REG(&adapter->hw, CTRL_EXT,
-				ctrl_ext & ~E1000_CTRL_EXT_DRV_LOAD);
-		break;
 	case e1000_82573:
 		swsm = E1000_READ_REG(&adapter->hw, SWSM);
 		E1000_WRITE_REG(&adapter->hw, SWSM,
 				swsm & ~E1000_SWSM_DRV_LOAD);
+		break;
+	case e1000_82571:
+	case e1000_82572:
+	case e1000_80003es2lan:
 	case e1000_ich8lan:
-		extcnf = E1000_READ_REG(&adapter->hw, CTRL_EXT);
+		ctrl_ext = E1000_READ_REG(&adapter->hw, CTRL_EXT);
 		E1000_WRITE_REG(&adapter->hw, CTRL_EXT,
-				extcnf & ~E1000_CTRL_EXT_DRV_LOAD);
+				ctrl_ext & ~E1000_CTRL_EXT_DRV_LOAD);
 		break;
 	default:
 		break;
@@ -450,26 +446,21 @@ e1000_get_hw_control(struct e1000_adapter *adapter)
 {
 	uint32_t ctrl_ext;
 	uint32_t swsm;
-	uint32_t extcnf;
 
 	/* Let firmware know the driver has taken over */
 	switch (adapter->hw.mac_type) {
-	case e1000_82571:
-	case e1000_82572:
-	case e1000_80003es2lan:
-		ctrl_ext = E1000_READ_REG(&adapter->hw, CTRL_EXT);
-		E1000_WRITE_REG(&adapter->hw, CTRL_EXT,
-				ctrl_ext | E1000_CTRL_EXT_DRV_LOAD);
-		break;
 	case e1000_82573:
 		swsm = E1000_READ_REG(&adapter->hw, SWSM);
 		E1000_WRITE_REG(&adapter->hw, SWSM,
 				swsm | E1000_SWSM_DRV_LOAD);
 		break;
+	case e1000_82571:
+	case e1000_82572:
+	case e1000_80003es2lan:
 	case e1000_ich8lan:
-		extcnf = E1000_READ_REG(&adapter->hw, EXTCNF_CTRL);
-		E1000_WRITE_REG(&adapter->hw, EXTCNF_CTRL,
-				extcnf | E1000_EXTCNF_CTRL_SWFLAG);
+		ctrl_ext = E1000_READ_REG(&adapter->hw, CTRL_EXT);
+		E1000_WRITE_REG(&adapter->hw, CTRL_EXT,
+				ctrl_ext | E1000_CTRL_EXT_DRV_LOAD);
 		break;
 	default:
 		break;
@@ -522,14 +513,15 @@ e1000_release_manageability(struct e1000_adapter *adapter)
 	}
 }
 
-int
-e1000_up(struct e1000_adapter *adapter)
+/**
+ * e1000_configure - configure the hardware for RX and TX
+ * @adapter = private board structure
+ **/
+static void e1000_configure(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	int i;
 
-	/* hardware has been reset, we need to reload some things */
-
 	e1000_set_multi(netdev);
 
 	e1000_restore_vlan(adapter);
@@ -548,14 +540,20 @@ e1000_up(struct e1000_adapter *adapter)
 	}
 
 	adapter->tx_queue_len = netdev->tx_queue_len;
+}
+
+int e1000_up(struct e1000_adapter *adapter)
+{
+	/* hardware has been reset, we need to reload some things */
+	e1000_configure(adapter);
+
+	clear_bit(__E1000_DOWN, &adapter->flags);
 
 #ifdef CONFIG_E1000_NAPI
-	netif_poll_enable(netdev);
+	netif_poll_enable(adapter->netdev);
 #endif
 	e1000_irq_enable(adapter);
 
-	clear_bit(__E1000_DOWN, &adapter->flags);
-
 	/* fire a link change interrupt to start the watchdog */
 	E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_LSC);
 	return 0;
@@ -640,15 +638,15 @@ e1000_down(struct e1000_adapter *adapter)
 	 * reschedule our watchdog timer */
 	set_bit(__E1000_DOWN, &adapter->flags);
 
+#ifdef CONFIG_E1000_NAPI
+	netif_poll_disable(netdev);
+#endif
 	e1000_irq_disable(adapter);
 
 	del_timer_sync(&adapter->tx_fifo_stall_timer);
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_info_timer);
 
-#ifdef CONFIG_E1000_NAPI
-	netif_poll_disable(netdev);
-#endif
 	netdev->tx_queue_len = adapter->tx_queue_len;
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
@@ -1410,21 +1408,17 @@ e1000_open(struct net_device *netdev)
 		return -EBUSY;
 
 	/* allocate transmit descriptors */
-	if ((err = e1000_setup_all_tx_resources(adapter)))
+	err = e1000_setup_all_tx_resources(adapter);
+	if (err)
 		goto err_setup_tx;
 
 	/* allocate receive descriptors */
-	if ((err = e1000_setup_all_rx_resources(adapter)))
-		goto err_setup_rx;
-
-	err = e1000_request_irq(adapter);
+	err = e1000_setup_all_rx_resources(adapter);
 	if (err)
-		goto err_req_irq;
+		goto err_setup_rx;
 
 	e1000_power_up_phy(adapter);
 
-	if ((err = e1000_up(adapter)))
-		goto err_up;
 	adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
 	if ((adapter->hw.mng_cookie.status &
 			  E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT)) {
@@ -1437,12 +1431,33 @@ e1000_open(struct net_device *netdev)
 	    e1000_check_mng_mode(&adapter->hw))
 		e1000_get_hw_control(adapter);
 
+	/* before we allocate an interrupt, we must be ready to handle it.
+	 * Setting DEBUG_SHIRQ in the kernel makes it fire an interrupt
+	 * as soon as we call pci_request_irq, so we have to setup our
+	 * clean_rx handler before we do so.  */
+	e1000_configure(adapter);
+
+	err = e1000_request_irq(adapter);
+	if (err)
+		goto err_req_irq;
+
+	/* From here on the code is the same as e1000_up() */
+	clear_bit(__E1000_DOWN, &adapter->flags);
+
+#ifdef CONFIG_E1000_NAPI
+	netif_poll_enable(netdev);
+#endif
+
+	e1000_irq_enable(adapter);
+
+	/* fire a link status change interrupt to start the watchdog */
+	E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_LSC);
+
 	return E1000_SUCCESS;
 
-err_up:
-	e1000_power_down_phy(adapter);
-	e1000_free_irq(adapter);
 err_req_irq:
+	e1000_release_hw_control(adapter);
+	e1000_power_down_phy(adapter);
 	e1000_free_all_rx_resources(adapter);
 err_setup_rx:
 	e1000_free_all_tx_resources(adapter);
@@ -3363,12 +3378,9 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	    (adapter->hw.mac_type == e1000_82573))
 		e1000_transfer_dhcp_info(adapter, skb);
 
-	local_irq_save(flags);
-	if (!spin_trylock(&tx_ring->tx_lock)) {
+	if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags))
 		/* Collision - tell upper layer to requeue */
-		local_irq_restore(flags);
 		return NETDEV_TX_LOCKED;
-	}
 
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
