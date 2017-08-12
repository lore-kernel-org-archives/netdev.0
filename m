From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/4] i40evf: prevent VF close returning before state tranistions to DOWN
Date: Sat, 12 Aug 2017 04:08:35 -0700
Message-ID: <20170812110848.18264-4-jeffrey.t.kirsher@intel.com>
References: <20170812110848.18264-1-jeffrey.t.kirsher@intel.com>
Cc: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7745 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750885AbdHLLIx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 07:08:53 -0400
In-Reply-To: <20170812110848.18264-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>

Currently i40evf_close() can return before state transitions to
__I40EVF_DOWN because of the latency involved in processing and
receiving response from PF driver and scheduling of VF watchdog_task.
Due to this inconsistency an immediate call to i40evf_open() fails
because state is still DOWN_PENDING.

When a VF interface is in up state and we try to add it as slave,
The bonding driver calls dev_close() and dev_open() in short duration
resulting in dev_open returning error. The ifenslave command needs
to be run again for dev_open to succeed.

This fix ensures that watchdog timer is scheduled immediately after
admin queue operations are scheduled in i40evf_down(). In addition a
wait condition is added at the end of i40evf_close so that function
wont return when state is still DOWN_PENDING. The timeout value is
chosen after some profiling and includes some buffer.

Signed-off-by: Sudheer Mogilappagari <sudheer.mogilappagari@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h          |  2 ++
 drivers/net/ethernet/intel/i40evf/i40evf_main.c     | 19 +++++++++++++++++++
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c |  4 +++-
 3 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index 7901cc85cbe5..52cf38f47349 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -43,6 +43,7 @@
 #include <linux/bitops.h>
 #include <linux/timer.h>
 #include <linux/workqueue.h>
+#include <linux/wait.h>
 #include <linux/delay.h>
 #include <linux/gfp.h>
 #include <linux/skbuff.h>
@@ -194,6 +195,7 @@ struct i40evf_adapter {
 	struct work_struct adminq_task;
 	struct delayed_work client_task;
 	struct delayed_work init_task;
+	wait_queue_head_t down_waitqueue;
 	struct i40e_q_vector *q_vectors;
 	struct list_head vlan_filter_list;
 	char misc_vector_name[IFNAMSIZ + 9];
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 9e719074a7d7..2b81b4bc13a9 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1143,6 +1143,7 @@ void i40evf_down(struct i40evf_adapter *adapter)
 	}
 
 	clear_bit(__I40EVF_IN_CRITICAL_TASK, &adapter->crit_section);
+	mod_timer_pending(&adapter->watchdog_timer, jiffies + 1);
 }
 
 /**
@@ -1794,6 +1795,7 @@ static void i40evf_disable_vf(struct i40evf_adapter *adapter)
 	clear_bit(__I40EVF_IN_CRITICAL_TASK, &adapter->crit_section);
 	adapter->flags &= ~I40EVF_FLAG_RESET_PENDING;
 	adapter->state = __I40EVF_DOWN;
+	wake_up(&adapter->down_waitqueue);
 	dev_info(&adapter->pdev->dev, "Reset task did not complete, VF disabled\n");
 }
 
@@ -1939,6 +1941,7 @@ static void i40evf_reset_task(struct work_struct *work)
 		i40evf_irq_enable(adapter, true);
 	} else {
 		adapter->state = __I40EVF_DOWN;
+		wake_up(&adapter->down_waitqueue);
 	}
 
 	return;
@@ -2238,6 +2241,7 @@ static int i40evf_open(struct net_device *netdev)
 static int i40evf_close(struct net_device *netdev)
 {
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
+	int status;
 
 	if (adapter->state <= __I40EVF_DOWN_PENDING)
 		return 0;
@@ -2255,7 +2259,18 @@ static int i40evf_close(struct net_device *netdev)
 	 * still active and can DMA into memory. Resources are cleared in
 	 * i40evf_virtchnl_completion() after we get confirmation from the PF
 	 * driver that the rings have been stopped.
+	 *
+	 * Also, we wait for state to transition to __I40EVF_DOWN before
+	 * returning. State change occurs in i40evf_virtchnl_completion() after
+	 * VF resources are released (which occurs after PF driver processes and
+	 * responds to admin queue commands).
 	 */
+
+	status = wait_event_timeout(adapter->down_waitqueue,
+				    adapter->state == __I40EVF_DOWN,
+				    msecs_to_jiffies(200));
+	if (!status)
+		netdev_warn(netdev, "Device resources not yet released\n");
 	return 0;
 }
 
@@ -2684,6 +2699,7 @@ static void i40evf_init_task(struct work_struct *work)
 	adapter->state = __I40EVF_DOWN;
 	set_bit(__I40E_VSI_DOWN, adapter->vsi.state);
 	i40evf_misc_irq_enable(adapter);
+	wake_up(&adapter->down_waitqueue);
 
 	adapter->rss_key = kzalloc(adapter->rss_key_size, GFP_KERNEL);
 	adapter->rss_lut = kzalloc(adapter->rss_lut_size, GFP_KERNEL);
@@ -2845,6 +2861,9 @@ static int i40evf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	schedule_delayed_work(&adapter->init_task,
 			      msecs_to_jiffies(5 * (pdev->devfn & 0x07)));
 
+	/* Setup the wait queue for indicating transition to down status */
+	init_waitqueue_head(&adapter->down_waitqueue);
+
 	return 0;
 
 err_ioremap:
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index d2bb250a71af..6c403bf1bbb8 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -991,8 +991,10 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
 	case VIRTCHNL_OP_DISABLE_QUEUES:
 		i40evf_free_all_tx_resources(adapter);
 		i40evf_free_all_rx_resources(adapter);
-		if (adapter->state == __I40EVF_DOWN_PENDING)
+		if (adapter->state == __I40EVF_DOWN_PENDING) {
 			adapter->state = __I40EVF_DOWN;
+			wake_up(&adapter->down_waitqueue);
+		}
 		break;
 	case VIRTCHNL_OP_VERSION:
 	case VIRTCHNL_OP_CONFIG_IRQ_MAP:
-- 
2.14.0
