From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 08/12] netxen: refactor net_device setup code
Date: Sun, 26 Jul 2009 23:07:43 -0700
Message-ID: <1248674867-18821-9-git-send-email-dhananjay@netxen.com>
References: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:33577 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751353AbZG0GHs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2009 02:07:48 -0400
In-Reply-To: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move all net_device initialization into one function
netxen_setup_netdev().

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |  138 ++++++++++++++++++---------------
 1 files changed, 75 insertions(+), 63 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 8d4c30a..8a4e6ce 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -86,7 +86,7 @@ static int netxen_nic_open(struct net_device *netdev);
 static int netxen_nic_close(struct net_device *netdev);
 static int netxen_nic_xmit_frame(struct sk_buff *, struct net_device *);
 static void netxen_tx_timeout(struct net_device *netdev);
-static void netxen_tx_timeout_task(struct work_struct *work);
+static void netxen_reset_task(struct work_struct *work);
 static void netxen_watchdog(unsigned long);
 static int netxen_nic_poll(struct napi_struct *napi, int budget);
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -202,7 +202,7 @@ netxen_napi_add(struct netxen_adapter *adapter, struct net_device *netdev)
 	struct netxen_recv_context *recv_ctx = &adapter->recv_ctx;
 
 	if (netxen_alloc_sds_rings(recv_ctx, adapter->max_sds_rings))
-		return 1;
+		return -ENOMEM;
 
 	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 		sds_ring = &recv_ctx->sds_rings[ring];
@@ -1001,6 +1001,68 @@ netxen_nic_detach(struct netxen_adapter *adapter)
 	adapter->is_up = 0;
 }
 
+static int
+netxen_setup_netdev(struct netxen_adapter *adapter,
+		struct net_device *netdev)
+{
+	int err = 0;
+	struct pci_dev *pdev = adapter->pdev;
+
+	adapter->rx_csum = 1;
+	adapter->mc_enabled = 0;
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		adapter->max_mc_count = 38;
+	else
+		adapter->max_mc_count = 16;
+
+	netdev->netdev_ops	   = &netxen_netdev_ops;
+	netdev->watchdog_timeo     = 2*HZ;
+
+	netxen_nic_change_mtu(netdev, netdev->mtu);
+
+	SET_ETHTOOL_OPS(netdev, &netxen_nic_ethtool_ops);
+
+	netdev->features |= (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO);
+	netdev->features |= (NETIF_F_GRO);
+	netdev->vlan_features |= (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO);
+
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
+		netdev->features |= (NETIF_F_IPV6_CSUM | NETIF_F_TSO6);
+		netdev->vlan_features |= (NETIF_F_IPV6_CSUM | NETIF_F_TSO6);
+	}
+
+	if (adapter->pci_using_dac) {
+		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->vlan_features |= NETIF_F_HIGHDMA;
+	}
+
+	netdev->irq = adapter->msix_entries[0].vector;
+
+	err = netxen_napi_add(adapter, netdev);
+	if (err)
+		return err;
+
+	init_timer(&adapter->watchdog_timer);
+	adapter->watchdog_timer.function = &netxen_watchdog;
+	adapter->watchdog_timer.data = (unsigned long)adapter;
+	INIT_WORK(&adapter->watchdog_task, netxen_watchdog_task);
+	INIT_WORK(&adapter->tx_timeout_task, netxen_reset_task);
+
+	if (netxen_read_mac_addr(adapter))
+		dev_warn(&pdev->dev, "failed to read mac addr\n");
+
+	netif_carrier_off(netdev);
+	netif_stop_queue(netdev);
+
+	err = register_netdev(netdev);
+	if (err) {
+		dev_err(&pdev->dev, "failed to register net device\n");
+		return err;
+	}
+
+	return 0;
+}
+
 static int __devinit
 netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -1038,9 +1100,8 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netdev = alloc_etherdev(sizeof(struct netxen_adapter));
 	if(!netdev) {
-		printk(KERN_ERR"%s: Failed to allocate memory for the "
-				"device block.Check system memory resource"
-				" usage.\n", netxen_nic_driver_name);
+		dev_err(&pdev->dev, "failed to allocate net_device\n");
+		err = -ENOMEM;
 		goto err_out_free_res;
 	}
 
@@ -1068,38 +1129,10 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* This will be reset for mezz cards  */
 	adapter->portnum = pci_func_id;
-	adapter->rx_csum = 1;
-	adapter->mc_enabled = 0;
-	if (NX_IS_REVISION_P3(revision_id))
-		adapter->max_mc_count = 38;
-	else
-		adapter->max_mc_count = 16;
-
-	netdev->netdev_ops	   = &netxen_netdev_ops;
-	netdev->watchdog_timeo     = 2*HZ;
-
-	netxen_nic_change_mtu(netdev, netdev->mtu);
-
-	SET_ETHTOOL_OPS(netdev, &netxen_nic_ethtool_ops);
-
-	netdev->features |= (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO);
-	netdev->features |= (NETIF_F_GRO);
-	netdev->vlan_features |= (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO);
-
-	if (NX_IS_REVISION_P3(revision_id)) {
-		netdev->features |= (NETIF_F_IPV6_CSUM | NETIF_F_TSO6);
-		netdev->vlan_features |= (NETIF_F_IPV6_CSUM | NETIF_F_TSO6);
-	}
-
-	if (adapter->pci_using_dac) {
-		netdev->features |= NETIF_F_HIGHDMA;
-		netdev->vlan_features |= NETIF_F_HIGHDMA;
-	}
 
-	if (netxen_nic_get_board_info(adapter) != 0) {
-		printk("%s: Error getting board config info.\n",
-				netxen_nic_driver_name);
-		err = -EIO;
+	err = netxen_nic_get_board_info(adapter);
+	if (err) {
+		dev_err(&pdev->dev, "Error getting board config info.\n");
 		goto err_out_iounmap;
 	}
 
@@ -1119,6 +1152,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	err = netxen_start_firmware(adapter, 1);
 	if (err)
 		goto err_out_iounmap;
+
 	/*
 	 * See if the firmware gave us a virtual-physical port mapping.
 	 */
@@ -1133,31 +1167,9 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netxen_setup_intr(adapter);
 
-	netdev->irq = adapter->msix_entries[0].vector;
-
-	if (netxen_napi_add(adapter, netdev))
-		goto err_out_disable_msi;
-
-	init_timer(&adapter->watchdog_timer);
-	adapter->watchdog_timer.function = &netxen_watchdog;
-	adapter->watchdog_timer.data = (unsigned long)adapter;
-	INIT_WORK(&adapter->watchdog_task, netxen_watchdog_task);
-	INIT_WORK(&adapter->tx_timeout_task, netxen_tx_timeout_task);
-
-	err = netxen_read_mac_addr(adapter);
+	err = netxen_setup_netdev(adapter, netdev);
 	if (err)
-		dev_warn(&pdev->dev, "failed to read mac addr\n");
-
-	netif_carrier_off(netdev);
-	netif_stop_queue(netdev);
-
-	if ((err = register_netdev(netdev))) {
-		printk(KERN_ERR "%s: register_netdev failed port #%d"
-			       " aborting\n", netxen_nic_driver_name,
-			       adapter->portnum);
-		err = -EIO;
 		goto err_out_disable_msi;
-	}
 
 	pci_set_drvdata(pdev, adapter);
 
@@ -1676,10 +1688,13 @@ static void netxen_tx_timeout(struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = (struct netxen_adapter *)
 						netdev_priv(netdev);
+
+	dev_err(&netdev->dev, "transmit timeout, resetting.\n");
+
 	SCHEDULE_WORK(&adapter->tx_timeout_task);
 }
 
-static void netxen_tx_timeout_task(struct work_struct *work)
+static void netxen_reset_task(struct work_struct *work)
 {
 	struct netxen_adapter *adapter =
 		container_of(work, struct netxen_adapter, tx_timeout_task);
@@ -1687,9 +1702,6 @@ static void netxen_tx_timeout_task(struct work_struct *work)
 	if (!netif_running(adapter->netdev))
 		return;
 
-	printk(KERN_ERR "%s %s: transmit timeout, resetting.\n",
-	       netxen_nic_driver_name, adapter->netdev->name);
-
 	netxen_napi_disable(adapter);
 
 	adapter->netdev->trans_start = jiffies;
-- 
1.6.0.2

