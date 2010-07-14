From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: [PATCH 2.6.35-rc1] net-next: vmxnet3 fixes [3/5] Initialize link
 state at probe time
Date: Tue, 13 Jul 2010 17:48:55 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1007131748180.32055@localhost.localdomain>
References: <alpine.LRH.2.00.1007070125440.4652@localhost.localdomain> <alpine.LRH.2.00.1007070202080.5939@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, pv-drivers@vmware.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1007070202080.5939@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Initialize vmxnet3 link state at probe time

This change initializes the state of link at the time when driver is
loaded. The ethtool output for 'link detected' and 'link speed'
is thus valid even before the interface is brought up.

Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>

---
 drivers/net/vmxnet3/vmxnet3_drv.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 7792a44..1e31d40 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -130,7 +130,7 @@ vmxnet3_tq_stop(struct vmxnet3_tx_queue *tq, struct vmxnet3_adapter *adapter)
  * Check the link state. This may start or stop the tx queue.
  */
 static void
-vmxnet3_check_link(struct vmxnet3_adapter *adapter)
+vmxnet3_check_link(struct vmxnet3_adapter *adapter, bool affectTxQueue)
 {
 	u32 ret;
 
@@ -143,14 +143,16 @@ vmxnet3_check_link(struct vmxnet3_adapter *adapter)
 		if (!netif_carrier_ok(adapter->netdev))
 			netif_carrier_on(adapter->netdev);
 
-		vmxnet3_tq_start(&adapter->tx_queue, adapter);
+		if (affectTxQueue)
+			vmxnet3_tq_start(&adapter->tx_queue, adapter);
 	} else {
 		printk(KERN_INFO "%s: NIC Link is Down\n",
 		       adapter->netdev->name);
 		if (netif_carrier_ok(adapter->netdev))
 			netif_carrier_off(adapter->netdev);
 
-		vmxnet3_tq_stop(&adapter->tx_queue, adapter);
+		if (affectTxQueue)
+			vmxnet3_tq_stop(&adapter->tx_queue, adapter);
 	}
 }
 
@@ -165,7 +167,7 @@ vmxnet3_process_events(struct vmxnet3_adapter *adapter)
 
 	/* Check if link state has changed */
 	if (events & VMXNET3_ECR_LINK)
-		vmxnet3_check_link(adapter);
+		vmxnet3_check_link(adapter, true);
 
 	/* Check if there is an error on xmit/recv queues */
 	if (events & (VMXNET3_ECR_TQERR | VMXNET3_ECR_RQERR)) {
@@ -1947,7 +1949,7 @@ vmxnet3_activate_dev(struct vmxnet3_adapter *adapter)
 	 * Check link state when first activating device. It will start the
 	 * tx queue if the link is up.
 	 */
-	vmxnet3_check_link(adapter);
+	vmxnet3_check_link(adapter, true);
 
 	napi_enable(&adapter->napi);
 	vmxnet3_enable_all_intrs(adapter);
@@ -2549,6 +2551,7 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	}
 
 	set_bit(VMXNET3_STATE_BIT_QUIESCED, &adapter->state);
+	vmxnet3_check_link(adapter, false);
 	atomic_inc(&devices_found);
 	return 0;
