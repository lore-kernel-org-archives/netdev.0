From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH next 1/2]e1000: e1000_adapter->polling_netdev is useless
Date: Wed, 03 Dec 2008 20:57:41 +0800
Message-ID: <49368245.5040804@cn.fujitsu.com>
References: <49353915.4060002@cn.fujitsu.com> <20081202.150623.70107608.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57434 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751886AbYLCM5x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2008 07:57:53 -0500
In-Reply-To: <20081202.150623.70107608.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-12-3 7:06:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Tue, 02 Dec 2008 21:33:09 +0800
> 
>> e1000_adapter->polling_netdev is not actually used after allocated.
>> So, my question is that is it useless?
> 
> It's probably a leftover from before we added support for
> multiqueue NAPI.
> 
> Intel folks can probably confirm.

Commit bea3348eef27e6044b6161fd04c3152215f96411
"[NET]: Make NAPI polling independent of struct net_device objects."
made NAPI polling to be independent of net_device.
So e1000_adapter->polling_netdev is no longer used.
Kill it.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/e1000/e1000.h      |    1 -
 drivers/net/e1000/e1000_main.c |   27 +--------------------------
 2 files changed, 1 insertions(+), 27 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 62f6297..f5581de 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -284,7 +284,6 @@ struct e1000_adapter {
 			     int cleaned_count);
 	struct e1000_rx_ring *rx_ring;      /* One per active queue */
 	struct napi_struct napi;
-	struct net_device *polling_netdev;  /* One per active queue */
 
 	int num_tx_queues;
 	int num_rx_queues;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 6494d24..116c96e 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1242,12 +1242,8 @@ err_eeprom:
 	if (hw->flash_address)
 		iounmap(hw->flash_address);
 err_flashmap:
-	for (i = 0; i < adapter->num_rx_queues; i++)
-		dev_put(&adapter->polling_netdev[i]);
-
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
-	kfree(adapter->polling_netdev);
 err_sw_init:
 	iounmap(hw->hw_addr);
 err_ioremap:
@@ -1275,7 +1271,6 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	int i;
 
 	cancel_work_sync(&adapter->reset_task);
 
@@ -1285,9 +1280,6 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 	 * would have already happened in close and is redundant. */
 	e1000_release_hw_control(adapter);
 
-	for (i = 0; i < adapter->num_rx_queues; i++)
-		dev_put(&adapter->polling_netdev[i]);
-
 	unregister_netdev(netdev);
 
 	if (!e1000_check_phy_reset_block(hw))
@@ -1295,7 +1287,6 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
-	kfree(adapter->polling_netdev);
 
 	iounmap(hw->hw_addr);
 	if (hw->flash_address)
@@ -1321,7 +1312,6 @@ static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
-	int i;
 
 	/* PCI config space info */
 
@@ -1378,11 +1368,6 @@ static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
 		return -ENOMEM;
 	}
 
-	for (i = 0; i < adapter->num_rx_queues; i++) {
-		adapter->polling_netdev[i].priv = adapter;
-		dev_hold(&adapter->polling_netdev[i]);
-		set_bit(__LINK_STATE_START, &adapter->polling_netdev[i].state);
-	}
 	spin_lock_init(&adapter->tx_queue_lock);
 
 	/* Explicitly disable IRQ since the NIC can be in any state. */
@@ -1400,8 +1385,7 @@ static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
  * @adapter: board private structure to initialize
  *
  * We allocate one ring per queue at run-time since we don't know the
- * number of queues at compile-time.  The polling_netdev array is
- * intended for Multiqueue, but should work fine with a single queue.
+ * number of queues at compile-time.
  **/
 
 static int __devinit e1000_alloc_queues(struct e1000_adapter *adapter)
@@ -1418,15 +1402,6 @@ static int __devinit e1000_alloc_queues(struct e1000_adapter *adapter)
 		return -ENOMEM;
 	}
 
-	adapter->polling_netdev = kcalloc(adapter->num_rx_queues,
-	                                  sizeof(struct net_device),
-	                                  GFP_KERNEL);
-	if (!adapter->polling_netdev) {
-		kfree(adapter->tx_ring);
-		kfree(adapter->rx_ring);
-		return -ENOMEM;
-	}
-
 	return E1000_SUCCESS;
 }
 
-- 
1.5.3.4


