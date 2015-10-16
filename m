From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/17] i40evf: Add support for netpoll
Date: Fri, 16 Oct 2015 05:10:11 -0700
Message-ID: <1444997425-3396-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444997425-3396-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64539 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754110AbbJPMKj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 08:10:39 -0400
In-Reply-To: <1444997425-3396-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 26 +++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 429a46c..139801f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -444,6 +444,29 @@ out:
 	return err;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/**
+ * i40evf_netpoll - A Polling 'interrupt' handler
+ * @netdev: network interface device structure
+ *
+ * This is used by netconsole to send skbs without having to re-enable
+ * interrupts.  It's not called while the normal interrupt routine is executing.
+ **/
+static void i40evf_netpoll(struct net_device *netdev)
+{
+	struct i40evf_adapter *adapter = netdev_priv(netdev);
+	int q_vectors = adapter->num_msix_vectors - NONQ_VECS;
+	int i;
+
+	/* if interface is down do nothing */
+	if (test_bit(__I40E_DOWN, &adapter->vsi.state))
+		return;
+
+	for (i = 0; i < q_vectors; i++)
+		i40evf_msix_clean_rings(0, adapter->q_vector[i]);
+}
+
+#endif
 /**
  * i40evf_request_traffic_irqs - Initialize MSI-X interrupts
  * @adapter: board private structure
@@ -2049,6 +2072,9 @@ static const struct net_device_ops i40evf_netdev_ops = {
 	.ndo_tx_timeout		= i40evf_tx_timeout,
 	.ndo_vlan_rx_add_vid	= i40evf_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= i40evf_vlan_rx_kill_vid,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= i40evf_netpoll,
+#endif
 };
 
 /**
-- 
2.4.3
