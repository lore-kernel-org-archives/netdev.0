From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 11/29] fm10k: Add support for ndo_open/stop
Date: Tue, 23 Sep 2014 04:16:39 -0700
Message-ID: <1411471017-28213-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:20875 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755609AbaIWLRL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 07:17:11 -0400
In-Reply-To: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Add support for brining the interface up/down.  This is still primitive yet
as we have not yet added support for the descriptor queues.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h        |  4 ++
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 68 +++++++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c    | 45 ++++++++++++++++
 3 files changed, 117 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 1172cba..bd47f28 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -130,9 +130,13 @@ extern const char fm10k_driver_version[];
 /* PCI */
 int fm10k_register_pci_driver(void);
 void fm10k_unregister_pci_driver(void);
+void fm10k_up(struct fm10k_intfc *interface);
+void fm10k_down(struct fm10k_intfc *interface);
 
 /* Netdev */
 struct net_device *fm10k_alloc_netdev(void);
 void fm10k_restore_rx_state(struct fm10k_intfc *);
 void fm10k_reset_rx_state(struct fm10k_intfc *);
+int fm10k_open(struct net_device *netdev);
+int fm10k_close(struct net_device *netdev);
 #endif /* _FM10K_H_ */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index cf7b4f3..ca84898 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -20,6 +20,72 @@
 
 #include "fm10k.h"
 
+/**
+ * fm10k_request_glort_range - Request GLORTs for use in configuring rules
+ * @interface: board private structure
+ *
+ * This function allocates a range of glorts for this inteface to use.
+ **/
+static void fm10k_request_glort_range(struct fm10k_intfc *interface)
+{
+	struct fm10k_hw *hw = &interface->hw;
+	u16 mask = (~hw->mac.dglort_map) >> FM10K_DGLORTMAP_MASK_SHIFT;
+
+	/* establish GLORT base */
+	interface->glort = hw->mac.dglort_map & FM10K_DGLORTMAP_NONE;
+	interface->glort_count = 0;
+
+	/* nothing we can do until mask is allocated */
+	if (hw->mac.dglort_map == FM10K_DGLORTMAP_NONE)
+		return;
+
+	interface->glort_count = mask + 1;
+}
+
+/**
+ * fm10k_open - Called when a network interface is made active
+ * @netdev: network interface device structure
+ *
+ * Returns 0 on success, negative value on failure
+ *
+ * The open entry point is called when a network interface is made
+ * active by the system (IFF_UP).  At this point all resources needed
+ * for transmit and receive operations are allocated, the interrupt
+ * handler is registered with the OS, the watchdog timer is started,
+ * and the stack is notified that the interface is ready.
+ **/
+int fm10k_open(struct net_device *netdev)
+{
+	struct fm10k_intfc *interface = netdev_priv(netdev);
+
+	/* setup GLORT assignment for this port */
+	fm10k_request_glort_range(interface);
+
+	fm10k_up(interface);
+
+	return 0;
+}
+
+/**
+ * fm10k_close - Disables a network interface
+ * @netdev: network interface device structure
+ *
+ * Returns 0, this is not allowed to fail
+ *
+ * The close entry point is called when an interface is de-activated
+ * by the OS.  The hardware is still under the drivers control, but
+ * needs to be disabled.  A global MAC reset is issued to stop the
+ * hardware, and all transmit and receive resources are freed.
+ **/
+int fm10k_close(struct net_device *netdev)
+{
+	struct fm10k_intfc *interface = netdev_priv(netdev);
+
+	fm10k_down(interface);
+
+	return 0;
+}
+
 static netdev_tx_t fm10k_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 {
 	dev_kfree_skb_any(skb);
@@ -398,6 +464,8 @@ void fm10k_reset_rx_state(struct fm10k_intfc *interface)
 }
 
 static const struct net_device_ops fm10k_netdev_ops = {
+	.ndo_open		= fm10k_open,
+	.ndo_stop		= fm10k_close,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_start_xmit		= fm10k_xmit_frame,
 	.ndo_set_mac_address	= fm10k_set_mac,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 5fcbd1d..b6d5e72 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -87,6 +87,51 @@ static int fm10k_hw_ready(struct fm10k_intfc *interface)
 	return FM10K_REMOVED(hw->hw_addr) ? -ENODEV : 0;
 }
 
+void fm10k_up(struct fm10k_intfc *interface)
+{
+	struct fm10k_hw *hw = &interface->hw;
+
+	/* Enable Tx/Rx DMA */
+	hw->mac.ops.start_hw(hw);
+
+	/* configure interrupts */
+	hw->mac.ops.update_int_moderator(hw);
+
+	/* clear down bit to indicate we are ready to go */
+	clear_bit(__FM10K_DOWN, &interface->state);
+
+	/* re-establish Rx filters */
+	fm10k_restore_rx_state(interface);
+
+	/* enable transmits */
+	netif_tx_start_all_queues(interface->netdev);
+}
+
+void fm10k_down(struct fm10k_intfc *interface)
+{
+	struct net_device *netdev = interface->netdev;
+	struct fm10k_hw *hw = &interface->hw;
+
+	/* signal that we are down to the interrupt handler and service task */
+	set_bit(__FM10K_DOWN, &interface->state);
+
+	/* call carrier off first to avoid false dev_watchdog timeouts */
+	netif_carrier_off(netdev);
+
+	/* disable transmits */
+	netif_tx_stop_all_queues(netdev);
+	netif_tx_disable(netdev);
+
+	/* reset Rx filters */
+	fm10k_reset_rx_state(interface);
+
+	/* allow 10ms for device to quiesce */
+	usleep_range(10000, 20000);
+
+	/* Disable DMA engine for Tx/Rx */
+	hw->mac.ops.stop_hw(hw);
+}
+
 /**
  * fm10k_sw_init - Initialize general software structures
  * @interface: host interface private structure to initialize
-- 
1.9.3
