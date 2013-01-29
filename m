From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH v3] vmxnet3: set carrier state properly on probe
Date: Tue, 29 Jan 2013 16:15:45 -0500
Message-ID: <1359494145-28803-1-git-send-email-nhorman@tuxdriver.com>
References: <20130129.154430.2272042048726099861.davem@davemloft.net>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"VMware, Inc." <pv-drivers@vmware.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37370 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258Ab3A2VP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 16:15:59 -0500
In-Reply-To: <20130129.154430.2272042048726099861.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vmxnet3 fails to set netif_carrier_off on probe, meaning that when an interface
is opened the __LINK_STATE_NOCARRIER bit is already cleared, and so
/sys/class/net/<ifname>/operstate remains in the unknown state.  Correct this by
setting netif_carrier_off on probe, like other drivers do.

Also, while we're at it, lets remove the netif_carrier_ok checks from the
link_state_update function, as that check is atomically contained within the
netif_carrier_[on|off] functions anyway

Tested successfully by myself

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: "VMware, Inc." <pv-drivers@vmware.com>
CC: Ben Hutchings <bhutchings@solarflare.com>

---
Change notes:

v2) Moved netif_carrier_off above register_netdev to prevent race with dev_open
as per Ben H.

v3) Respin for net tree
---
 drivers/net/vmxnet3/vmxnet3_drv.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index dc8913c..12c6440 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -154,8 +154,7 @@ vmxnet3_check_link(struct vmxnet3_adapter *adapter, bool affectTxQueue)
 	if (ret & 1) { /* Link is up. */
 		printk(KERN_INFO "%s: NIC Link is Up %d Mbps\n",
 		       adapter->netdev->name, adapter->link_speed);
-		if (!netif_carrier_ok(adapter->netdev))
-			netif_carrier_on(adapter->netdev);
+		netif_carrier_on(adapter->netdev);
 
 		if (affectTxQueue) {
 			for (i = 0; i < adapter->num_tx_queues; i++)
@@ -165,8 +164,7 @@ vmxnet3_check_link(struct vmxnet3_adapter *adapter, bool affectTxQueue)
 	} else {
 		printk(KERN_INFO "%s: NIC Link is Down\n",
 		       adapter->netdev->name);
-		if (netif_carrier_ok(adapter->netdev))
-			netif_carrier_off(adapter->netdev);
+		netif_carrier_off(adapter->netdev);
 
 		if (affectTxQueue) {
 			for (i = 0; i < adapter->num_tx_queues; i++)
@@ -3061,6 +3059,7 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	netif_set_real_num_tx_queues(adapter->netdev, adapter->num_tx_queues);
 	netif_set_real_num_rx_queues(adapter->netdev, adapter->num_rx_queues);
 
+	netif_carrier_off(netdev);
 	err = register_netdev(netdev);
 
 	if (err) {
-- 
1.7.11.7
