From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 09/10] i40evf: fix panic during MTU change
Date: Fri, 26 Jun 2015 03:20:39 -0700
Message-ID: <1435314040-3228-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1435314040-3228-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58214 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751682AbbFZKU4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2015 06:20:56 -0400
In-Reply-To: <1435314040-3228-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Down was requesting queue disables, but then exited immediately
without waiting for the queues to actually disable.  This could
allow any function called after i40evf_down to run immediately,
including i40evf_up, and causes a memory leak.

Removing the whole reinit_locked function is the best way
to go about this, and allows for the driver to handle the
state changes by requesting reset from the periodic timer.

Also, add a couple WARN_ONs in slow path to help us recognize
if we re-introduce this issue or missed any cases.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |   4 +
 drivers/net/ethernet/intel/i40evf/i40evf.h         |   1 -
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |   6 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 108 +++++++++------------
 4 files changed, 54 insertions(+), 65 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index f54996f..395f32f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -484,6 +484,8 @@ int i40evf_setup_tx_descriptors(struct i40e_ring *tx_ring)
 	if (!dev)
 		return -ENOMEM;
 
+	/* warn if we are about to overwrite the pointer */
+	WARN_ON(tx_ring->tx_bi);
 	bi_size = sizeof(struct i40e_tx_buffer) * tx_ring->count;
 	tx_ring->tx_bi = kzalloc(bi_size, GFP_KERNEL);
 	if (!tx_ring->tx_bi)
@@ -644,6 +646,8 @@ int i40evf_setup_rx_descriptors(struct i40e_ring *rx_ring)
 	struct device *dev = rx_ring->dev;
 	int bi_size;
 
+	/* warn if we are about to overwrite the pointer */
+	WARN_ON(rx_ring->rx_bi);
 	bi_size = sizeof(struct i40e_rx_buffer) * rx_ring->count;
 	rx_ring->rx_bi = kzalloc(bi_size, GFP_KERNEL);
 	if (!rx_ring->rx_bi)
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index 1b98c25..fea3b75 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -264,7 +264,6 @@ extern const char i40evf_driver_version[];
 
 int i40evf_up(struct i40evf_adapter *adapter);
 void i40evf_down(struct i40evf_adapter *adapter);
-void i40evf_reinit_locked(struct i40evf_adapter *adapter);
 void i40evf_reset(struct i40evf_adapter *adapter);
 void i40evf_set_ethtool_ops(struct net_device *netdev);
 void i40evf_update_stats(struct i40evf_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index f4e7766..2b53c87 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -267,8 +267,10 @@ static int i40evf_set_ringparam(struct net_device *netdev,
 	adapter->tx_desc_count = new_tx_count;
 	adapter->rx_desc_count = new_rx_count;
 
-	if (netif_running(netdev))
-		i40evf_reinit_locked(adapter);
+	if (netif_running(netdev)) {
+		adapter->flags |= I40EVF_FLAG_RESET_NEEDED;
+		schedule_work(&adapter->reset_task);
+	}
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 7c53aca..5c73374 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -170,7 +170,8 @@ static void i40evf_tx_timeout(struct net_device *netdev)
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
 
 	adapter->tx_timeout_count++;
-	if (!(adapter->flags & I40EVF_FLAG_RESET_PENDING)) {
+	if (!(adapter->flags & (I40EVF_FLAG_RESET_PENDING |
+				I40EVF_FLAG_RESET_NEEDED))) {
 		adapter->flags |= I40EVF_FLAG_RESET_NEEDED;
 		schedule_work(&adapter->reset_task);
 	}
@@ -1470,8 +1471,8 @@ static void i40evf_configure_rss(struct i40evf_adapter *adapter)
 	i40e_flush(hw);
 }
 
-#define I40EVF_RESET_WAIT_MS 100
-#define I40EVF_RESET_WAIT_COUNT 200
+#define I40EVF_RESET_WAIT_MS 10
+#define I40EVF_RESET_WAIT_COUNT 500
 /**
  * i40evf_reset_task - Call-back task to handle hardware reset
  * @work: pointer to work_struct
@@ -1495,10 +1496,17 @@ static void i40evf_reset_task(struct work_struct *work)
 				&adapter->crit_section))
 		usleep_range(500, 1000);
 
+	i40evf_misc_irq_disable(adapter);
 	if (adapter->flags & I40EVF_FLAG_RESET_NEEDED) {
-		dev_info(&adapter->pdev->dev, "Requesting reset from PF\n");
+		adapter->flags &= ~I40EVF_FLAG_RESET_NEEDED;
+		/* Restart the AQ here. If we have been reset but didn't
+		 * detect it, or if the PF had to reinit, our AQ will be hosed.
+		 */
+		i40evf_shutdown_adminq(hw);
+		i40evf_init_adminq(hw);
 		i40evf_request_reset(adapter);
 	}
+	adapter->flags |= I40EVF_FLAG_RESET_PENDING;
 
 	/* poll until we see the reset actually happen */
 	for (i = 0; i < I40EVF_RESET_WAIT_COUNT; i++) {
@@ -1507,10 +1515,10 @@ static void i40evf_reset_task(struct work_struct *work)
 		if ((rstat_val != I40E_VFR_VFACTIVE) &&
 		    (rstat_val != I40E_VFR_COMPLETED))
 			break;
-		msleep(I40EVF_RESET_WAIT_MS);
+		usleep_range(500, 1000);
 	}
 	if (i == I40EVF_RESET_WAIT_COUNT) {
-		adapter->flags &= ~I40EVF_FLAG_RESET_PENDING;
+		dev_info(&adapter->pdev->dev, "Never saw reset\n");
 		goto continue_reset; /* act like the reset happened */
 	}
 
@@ -1518,11 +1526,12 @@ static void i40evf_reset_task(struct work_struct *work)
 	for (i = 0; i < I40EVF_RESET_WAIT_COUNT; i++) {
 		rstat_val = rd32(hw, I40E_VFGEN_RSTAT) &
 			    I40E_VFGEN_RSTAT_VFR_STATE_MASK;
-		if ((rstat_val == I40E_VFR_VFACTIVE) ||
-		    (rstat_val == I40E_VFR_COMPLETED))
+		if (rstat_val == I40E_VFR_VFACTIVE)
 			break;
 		msleep(I40EVF_RESET_WAIT_MS);
 	}
+	/* extra wait to make sure minimum wait is met */
+	msleep(I40EVF_RESET_WAIT_MS);
 	if (i == I40EVF_RESET_WAIT_COUNT) {
 		struct i40evf_mac_filter *f, *ftmp;
 		struct i40evf_vlan_filter *fv, *fvtmp;
@@ -1534,11 +1543,10 @@ static void i40evf_reset_task(struct work_struct *work)
 
 		if (netif_running(adapter->netdev)) {
 			set_bit(__I40E_DOWN, &adapter->vsi.state);
-			i40evf_irq_disable(adapter);
-			i40evf_napi_disable_all(adapter);
-			netif_tx_disable(netdev);
-			netif_tx_stop_all_queues(netdev);
 			netif_carrier_off(netdev);
+			netif_tx_disable(netdev);
+			i40evf_napi_disable_all(adapter);
+			i40evf_irq_disable(adapter);
 			i40evf_free_traffic_irqs(adapter);
 			i40evf_free_all_tx_resources(adapter);
 			i40evf_free_all_rx_resources(adapter);
@@ -1550,6 +1558,7 @@ static void i40evf_reset_task(struct work_struct *work)
 			list_del(&f->list);
 			kfree(f);
 		}
+
 		list_for_each_entry_safe(fv, fvtmp, &adapter->vlan_filter_list,
 					 list) {
 			list_del(&fv->list);
@@ -1564,22 +1573,27 @@ static void i40evf_reset_task(struct work_struct *work)
 		i40evf_shutdown_adminq(hw);
 		adapter->netdev->flags &= ~IFF_UP;
 		clear_bit(__I40EVF_IN_CRITICAL_TASK, &adapter->crit_section);
+		adapter->flags &= ~I40EVF_FLAG_RESET_PENDING;
+		dev_info(&adapter->pdev->dev, "Reset task did not complete, VF disabled\n");
 		return; /* Do not attempt to reinit. It's dead, Jim. */
 	}
 
 continue_reset:
-	adapter->flags &= ~I40EVF_FLAG_RESET_PENDING;
-
-	i40evf_irq_disable(adapter);
-
 	if (netif_running(adapter->netdev)) {
-		i40evf_napi_disable_all(adapter);
-		netif_tx_disable(netdev);
-		netif_tx_stop_all_queues(netdev);
 		netif_carrier_off(netdev);
+		netif_tx_stop_all_queues(netdev);
+		i40evf_napi_disable_all(adapter);
 	}
+	i40evf_irq_disable(adapter);
 
 	adapter->state = __I40EVF_RESETTING;
+	adapter->flags &= ~I40EVF_FLAG_RESET_PENDING;
+
+	/* free the Tx/Rx rings and descriptors, might be better to just
+	 * re-use them sometime in the future
+	 */
+	i40evf_free_all_rx_resources(adapter);
+	i40evf_free_all_tx_resources(adapter);
 
 	/* kill and reinit the admin queue */
 	if (i40evf_shutdown_adminq(hw))
@@ -1603,6 +1617,7 @@ continue_reset:
 	adapter->aq_required = I40EVF_FLAG_AQ_ADD_MAC_FILTER;
 	adapter->aq_required |= I40EVF_FLAG_AQ_ADD_VLAN_FILTER;
 	clear_bit(__I40EVF_IN_CRITICAL_TASK, &adapter->crit_section);
+	i40evf_misc_irq_enable(adapter);
 
 	mod_timer(&adapter->watchdog_timer, jiffies + 2);
 
@@ -1624,7 +1639,10 @@ continue_reset:
 			goto reset_err;
 
 		i40evf_irq_enable(adapter, true);
+	} else {
+		adapter->state = __I40EVF_DOWN;
 	}
+
 	return;
 reset_err:
 	dev_err(&adapter->pdev->dev, "failed to allocate resources during reinit\n");
@@ -1667,6 +1685,11 @@ static void i40evf_adminq_task(struct work_struct *work)
 			memset(event.msg_buf, 0, I40EVF_MAX_AQ_BUF_SIZE);
 	} while (pending);
 
+	if ((adapter->flags &
+	     (I40EVF_FLAG_RESET_PENDING | I40EVF_FLAG_RESET_NEEDED)) ||
+	    adapter->state == __I40EVF_RESETTING)
+		goto freedom;
+
 	/* check for error indications */
 	val = rd32(hw, hw->aq.arq.len);
 	oldval = val;
@@ -1702,6 +1725,7 @@ static void i40evf_adminq_task(struct work_struct *work)
 	if (oldval != val)
 		wr32(hw, hw->aq.asq.len, val);
 
+freedom:
 	kfree(event.msg_buf);
 out:
 	/* re-enable Admin queue interrupt cause */
@@ -1897,47 +1921,6 @@ static struct net_device_stats *i40evf_get_stats(struct net_device *netdev)
 }
 
 /**
- * i40evf_reinit_locked - Software reinit
- * @adapter: board private structure
- *
- * Reinititalizes the ring structures in response to a software configuration
- * change. Roughly the same as close followed by open, but skips releasing
- * and reallocating the interrupts.
- **/
-void i40evf_reinit_locked(struct i40evf_adapter *adapter)
-{
-	struct net_device *netdev = adapter->netdev;
-	int err;
-
-	WARN_ON(in_interrupt());
-
-	i40evf_down(adapter);
-
-	/* allocate transmit descriptors */
-	err = i40evf_setup_all_tx_resources(adapter);
-	if (err)
-		goto err_reinit;
-
-	/* allocate receive descriptors */
-	err = i40evf_setup_all_rx_resources(adapter);
-	if (err)
-		goto err_reinit;
-
-	i40evf_configure(adapter);
-
-	err = i40evf_up_complete(adapter);
-	if (err)
-		goto err_reinit;
-
-	i40evf_irq_enable(adapter, true);
-	return;
-
-err_reinit:
-	dev_err(&adapter->pdev->dev, "failed to allocate resources during reinit\n");
-	i40evf_close(netdev);
-}
-
-/**
  * i40evf_change_mtu - Change the Maximum Transfer Unit
  * @netdev: network interface device structure
  * @new_mtu: new value for maximum frame size
@@ -1952,9 +1935,10 @@ static int i40evf_change_mtu(struct net_device *netdev, int new_mtu)
 	if ((new_mtu < 68) || (max_frame > I40E_MAX_RXBUFFER))
 		return -EINVAL;
 
-	/* must set new MTU before calling down or up */
 	netdev->mtu = new_mtu;
-	i40evf_reinit_locked(adapter);
+	adapter->flags |= I40EVF_FLAG_RESET_NEEDED;
+	schedule_work(&adapter->reset_task);
+
 	return 0;
 }
 
-- 
2.4.3
