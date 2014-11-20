From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 09/15] ixgbevf: add netpoll support
Date: Thu, 20 Nov 2014 15:09:07 -0800
Message-ID: <1416524953-15161-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416524953-15161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:43162 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757618AbaKTXJV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 18:09:21 -0500
In-Reply-To: <1416524953-15161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch adds ixgbevf_netpoll() a callback for .ndo_poll_controller to
allow for the VF interface to be used with netconsole.

CC: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 29 ++++++++++++++++++-----
 2 files changed, 24 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 6660498..bb6726c 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -379,7 +379,7 @@ struct ixgbevf_adapter {
 	 */
 	u32 flags;
 #define IXGBE_FLAG_IN_WATCHDOG_TASK             (u32)(1)
-#define IXGBE_FLAG_IN_NETPOLL                   (u32)(1 << 1)
+
 #define IXGBEVF_FLAG_QUEUE_RESET_REQUESTED	(u32)(1 << 2)
 
 	struct msix_entry *msix_entries;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 70a2b8f..755f71f 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -344,10 +344,8 @@ static void ixgbevf_rx_skb(struct ixgbevf_q_vector *q_vector,
 		return;
 	}
 #endif /* CONFIG_NET_RX_BUSY_POLL */
-	if (!(q_vector->adapter->flags & IXGBE_FLAG_IN_NETPOLL))
-		napi_gro_receive(&q_vector->napi, skb);
-	else
-		netif_rx(skb);
+
+	napi_gro_receive(&q_vector->napi, skb);
 }
 
 /* ixgbevf_rx_checksum - indicate in skb if hw indicated a good cksum
@@ -919,12 +917,10 @@ static int ixgbevf_poll(struct napi_struct *napi, int budget)
 	else
 		per_ring_budget = budget;
 
-	adapter->flags |= IXGBE_FLAG_IN_NETPOLL;
 	ixgbevf_for_each_ring(ring, q_vector->rx)
 		clean_complete &= (ixgbevf_clean_rx_irq(q_vector, ring,
 							per_ring_budget)
 				   < per_ring_budget);
-	adapter->flags &= ~IXGBE_FLAG_IN_NETPOLL;
 
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	ixgbevf_qv_unlock_napi(q_vector);
@@ -3553,6 +3549,24 @@ static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
 	return 0;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/* Polling 'interrupt' - used by things like netconsole to send skbs
+ * without having to re-enable interrupts. It's not called while
+ * the interrupt routine is executing.
+ */
+static void ixgbevf_netpoll(struct net_device *netdev)
+{
+	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
+	int i;
+
+	/* if interface is down do nothing */
+	if (test_bit(__IXGBEVF_DOWN, &adapter->state))
+		return;
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		ixgbevf_msix_clean_rings(0, adapter->q_vector[i]);
+}
+#endif /* CONFIG_NET_POLL_CONTROLLER */
+
 static int ixgbevf_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -3689,6 +3703,9 @@ static const struct net_device_ops ixgbevf_netdev_ops = {
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	.ndo_busy_poll		= ixgbevf_busy_poll_recv,
 #endif
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= ixgbevf_netpoll,
+#endif
 };
 
 static void ixgbevf_assign_netdev_ops(struct net_device *dev)
-- 
1.9.3
