From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 11/12] netxen: support for ethtool set ringparam
Date: Sun, 26 Jul 2009 23:07:46 -0700
Message-ID: <1248674867-18821-12-git-send-email-dhananjay@netxen.com>
References: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org, Amit Kumar Salecha <amit@netxen.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:33581 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751484AbZG0GHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2009 02:07:49 -0400
In-Reply-To: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for ethtool -G to tune rx and tx ring sizes
per interface basis.

This is only supported for NX3031 based cards.

Signed-off-by: Amit Kumar Salecha <amit@netxen.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h         |    4 +++
 drivers/net/netxen/netxen_nic_ethtool.c |   44 +++++++++++++++++++++++++++++-
 drivers/net/netxen/netxen_nic_main.c    |   45 ++++++++++++++++++++++++-------
 3 files changed, 82 insertions(+), 11 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index d01cc09..9527f31 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1427,6 +1427,10 @@ struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev);
 void netxen_nic_update_cmd_producer(struct netxen_adapter *adapter,
 		struct nx_host_tx_ring *tx_ring);
 
+/* Functions from netxen_nic_main.c */
+u32 netxen_validate_ringparam(u32 val, u32 min, u32 max, char *);
+int netxen_nic_reset_context(struct netxen_adapter *);
+
 /*
  * NetXen Board information
  */
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 80d286d..ec93aa7 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -490,7 +490,8 @@ netxen_nic_get_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 }
 
 static void
-netxen_nic_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ring)
+netxen_nic_get_ringparam(struct net_device *dev,
+		struct ethtool_ringparam *ring)
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
 
@@ -513,6 +514,46 @@ netxen_nic_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ring)
 	ring->rx_mini_pending = 0;
 }
 
+static int
+netxen_nic_set_ringparam(struct net_device *dev,
+		struct ethtool_ringparam *ring)
+{
+	struct netxen_adapter *adapter = netdev_priv(dev);
+	u16 max_rcv_desc = MAX_RCV_DESCRIPTORS_10G;
+	u16 max_jumbo_desc = MAX_JUMBO_RCV_DESCRIPTORS_10G;
+	u16 num_rxd, num_jumbo_rxd, num_txd;
+
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
+		return -EOPNOTSUPP;
+
+	if (ring->rx_mini_pending)
+		return -EOPNOTSUPP;
+
+	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
+		max_rcv_desc = MAX_RCV_DESCRIPTORS_1G;
+		max_jumbo_desc = MAX_JUMBO_RCV_DESCRIPTORS_10G;
+	}
+
+	num_rxd = netxen_validate_ringparam(ring->rx_pending,
+			MIN_RCV_DESCRIPTORS, max_rcv_desc, "rx");
+
+	num_jumbo_rxd = netxen_validate_ringparam(ring->rx_jumbo_pending,
+			MIN_JUMBO_DESCRIPTORS, max_jumbo_desc, "rx jumbo");
+
+	num_txd = netxen_validate_ringparam(ring->tx_pending,
+			MIN_CMD_DESCRIPTORS, MAX_CMD_DESCRIPTORS, "tx");
+
+	if (num_rxd == adapter->num_rxd && num_txd == adapter->num_txd &&
+			num_jumbo_rxd == adapter->num_jumbo_rxd)
+		return 0;
+
+	adapter->num_rxd = num_rxd;
+	adapter->num_jumbo_rxd = num_jumbo_rxd;
+	adapter->num_txd = num_txd;
+
+	return netxen_nic_reset_context(adapter);
+}
+
 static void
 netxen_nic_get_pauseparam(struct net_device *dev,
 			  struct ethtool_pauseparam *pause)
@@ -894,6 +935,7 @@ struct ethtool_ops netxen_nic_ethtool_ops = {
 	.get_eeprom_len = netxen_nic_get_eeprom_len,
 	.get_eeprom = netxen_nic_get_eeprom,
 	.get_ringparam = netxen_nic_get_ringparam,
+	.set_ringparam = netxen_nic_set_ringparam,
 	.get_pauseparam = netxen_nic_get_pauseparam,
 	.set_pauseparam = netxen_nic_set_pauseparam,
 	.set_tx_csum = ethtool_op_set_tx_csum,
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 41ab99d..894b1fd 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -930,6 +930,9 @@ netxen_nic_attach(struct netxen_adapter *adapter)
 	struct nx_host_rds_ring *rds_ring;
 	struct nx_host_tx_ring *tx_ring;
 
+	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC)
+		return 0;
+
 	err = netxen_init_firmware(adapter);
 	if (err != 0) {
 		printk(KERN_ERR "Failed to init firmware\n");
@@ -993,6 +996,9 @@ err_out_free_sw:
 static void
 netxen_nic_detach(struct netxen_adapter *adapter)
 {
+	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
+		return;
+
 	netxen_free_hw_resources(adapter);
 	netxen_release_rx_buffers(adapter);
 	netxen_nic_free_irq(adapter);
@@ -1001,6 +1007,30 @@ netxen_nic_detach(struct netxen_adapter *adapter)
 	adapter->is_up = 0;
 }
 
+int
+netxen_nic_reset_context(struct netxen_adapter *adapter)
+{
+	int err = 0;
+	struct net_device *netdev = adapter->netdev;
+
+	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC) {
+
+		if (netif_running(netdev))
+			netxen_nic_down(adapter, netdev);
+
+		netxen_nic_detach(adapter);
+
+		err = netxen_nic_attach(adapter);
+		if (err)
+			goto done;
+
+		if (netif_running(netdev))
+			err = netxen_nic_up(adapter, netdev);
+	}
+done:
+	return err;
+}
+
 static int
 netxen_setup_netdev(struct netxen_adapter *adapter,
 		struct net_device *netdev)
@@ -1222,9 +1252,7 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 
 	unregister_netdev(netdev);
 
-	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC) {
-		netxen_nic_detach(adapter);
-	}
+	netxen_nic_detach(adapter);
 
 	if (adapter->portnum == 0)
 		netxen_free_dummy_dma(adapter);
@@ -1256,8 +1284,7 @@ netxen_nic_suspend(struct pci_dev *pdev, pm_message_t state)
 	if (netif_running(netdev))
 		netxen_nic_down(adapter, netdev);
 
-	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC)
-		netxen_nic_detach(adapter);
+	netxen_nic_detach(adapter);
 
 	pci_save_state(pdev);
 
@@ -1318,11 +1345,9 @@ static int netxen_nic_open(struct net_device *netdev)
 	if (adapter->driver_mismatch)
 		return -EIO;
 
-	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC) {
-		err = netxen_nic_attach(adapter);
-		if (err)
-			return err;
-	}
+	err = netxen_nic_attach(adapter);
+	if (err)
+		return err;
 
 	err = netxen_nic_up(adapter, netdev);
 	if (err)
-- 
1.6.0.2

