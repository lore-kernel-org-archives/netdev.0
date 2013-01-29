From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH v2] vmxnet3: set carrier state properly on probe
Date: Tue, 29 Jan 2013 13:36:51 -0500
Message-ID: <1359484611-23860-1-git-send-email-nhorman@tuxdriver.com>
References: <1359147253-7204-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"VMware, Inc." <pv-drivers@vmware.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:34958 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143Ab3A2ShO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 13:37:14 -0500
In-Reply-To: <1359147253-7204-1-git-send-email-nhorman@tuxdriver.com>
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
---
 drivers/net/vmxnet3/vmxnet3_drv.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index b1c90f8..ffb97b2 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -150,8 +150,7 @@ vmxnet3_check_link(struct vmxnet3_adapter *adapter, bool affectTxQueue)
 	if (ret & 1) { /* Link is up. */
 		netdev_info(adapter->netdev, "NIC Link is Up %d Mbps\n",
 			    adapter->link_speed);
-		if (!netif_carrier_ok(adapter->netdev))
-			netif_carrier_on(adapter->netdev);
+		netif_carrier_on(adapter->netdev);
 
 		if (affectTxQueue) {
 			for (i = 0; i < adapter->num_tx_queues; i++)
@@ -160,8 +159,7 @@ vmxnet3_check_link(struct vmxnet3_adapter *adapter, bool affectTxQueue)
 		}
 	} else {
 		netdev_info(adapter->netdev, "NIC Link is Down\n");
-		if (netif_carrier_ok(adapter->netdev))
-			netif_carrier_off(adapter->netdev);
+		netif_carrier_off(adapter->netdev);
 
 		if (affectTxQueue) {
 			for (i = 0; i < adapter->num_tx_queues; i++)
@@ -3060,6 +3058,7 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	netif_set_real_num_tx_queues(adapter->netdev, adapter->num_tx_queues);
 	netif_set_real_num_rx_queues(adapter->netdev, adapter->num_rx_queues);
 
+	netif_carrier_off(netdev);
 	err = register_netdev(netdev);
 
 	if (err) {
-- 
1.7.11.7
