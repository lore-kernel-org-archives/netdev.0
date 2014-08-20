From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH 1/8] staging: et131x: Use eth_mac_addr() instead of
 duplicating the functionality
Date: Wed, 20 Aug 2014 23:17:51 +0100
Message-ID: <1408573078-9320-2-git-send-email-mark.einon@gmail.com>
References: <1408573078-9320-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Mark Einon <mark.einon@gmail.com>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1408573078-9320-1-git-send-email-mark.einon@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

There's already working code to set the mac address, so let's use it.

Signed-off-by: Mark Einon <mark.einon@gmail.com>
---
 drivers/staging/et131x/et131x.c | 53 +----------------------------------------
 1 file changed, 1 insertion(+), 52 deletions(-)

diff --git a/drivers/staging/et131x/et131x.c b/drivers/staging/et131x/et131x.c
index 831b7c6..ac6700b 100644
--- a/drivers/staging/et131x/et131x.c
+++ b/drivers/staging/et131x/et131x.c
@@ -4468,57 +4468,6 @@ static int et131x_change_mtu(struct net_device *netdev, int new_mtu)
 	return result;
 }
 
-/* et131x_set_mac_addr - handler to change the MAC address for the device */
-static int et131x_set_mac_addr(struct net_device *netdev, void *new_mac)
-{
-	int result = 0;
-	struct et131x_adapter *adapter = netdev_priv(netdev);
-	struct sockaddr *address = new_mac;
-
-	if (adapter == NULL)
-		return -ENODEV;
-
-	/* Make sure the requested MAC is valid */
-	if (!is_valid_ether_addr(address->sa_data))
-		return -EADDRNOTAVAIL;
-
-	et131x_disable_txrx(netdev);
-	et131x_handle_send_interrupt(adapter);
-	et131x_handle_recv_interrupt(adapter);
-
-	/* Set the new MAC */
-	/* netdev->set_mac_address  = &new_mac; */
-
-	memcpy(netdev->dev_addr, address->sa_data, netdev->addr_len);
-
-	netdev_info(netdev, "Setting MAC address to %pM\n",
-		    netdev->dev_addr);
-
-	/* Free Rx DMA memory */
-	et131x_adapter_memory_free(adapter);
-
-	et131x_soft_reset(adapter);
-
-	/* Alloc and init Rx DMA memory */
-	result = et131x_adapter_memory_alloc(adapter);
-	if (result != 0) {
-		dev_err(&adapter->pdev->dev,
-			"Change MAC failed; couldn't re-alloc DMA memory\n");
-		return result;
-	}
-
-	et131x_init_send(adapter);
-
-	et131x_hwaddr_init(adapter);
-
-	/* Init the device with the new settings */
-	et131x_adapter_setup(adapter);
-
-	et131x_enable_txrx(netdev);
-
-	return result;
-}
-
 static const struct net_device_ops et131x_netdev_ops = {
 	.ndo_open		= et131x_open,
 	.ndo_stop		= et131x_close,
@@ -4526,7 +4475,7 @@ static const struct net_device_ops et131x_netdev_ops = {
 	.ndo_set_rx_mode	= et131x_multicast,
 	.ndo_tx_timeout		= et131x_tx_timeout,
 	.ndo_change_mtu		= et131x_change_mtu,
-	.ndo_set_mac_address	= et131x_set_mac_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_get_stats		= et131x_stats,
 	.ndo_do_ioctl		= et131x_ioctl,
-- 
2.1.0
