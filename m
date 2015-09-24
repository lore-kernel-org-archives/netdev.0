From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 3/3] i40evf: Add support for netpoll
Date: Thu, 24 Sep 2015 09:04:38 -0700
Message-ID: <20150924160438.22015.60199.stgit@ahduyck-vm-fedora22>
References: <20150924160027.22015.15754.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35227 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757001AbbIXQEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 12:04:40 -0400
Received: by pacfv12 with SMTP id fv12so78074185pac.2
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 09:04:39 -0700 (PDT)
In-Reply-To: <20150924160027.22015.15754.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c |   26 +++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 429a46c2a2f7..5e1336321c2f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -444,6 +444,29 @@ out:
 	return err;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/**
+ * i40evf_netpoll - A Polling 'interrupt'handler
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
