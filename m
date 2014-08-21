From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH 8/8 v2] staging: et131x: Implement NAPI support
Date: Thu, 21 Aug 2014 11:26:09 +0100
Message-ID: <1408616769-5717-1-git-send-email-mark.einon@gmail.com>
References: <1408572883-9235-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Mark Einon <mark.einon@gmail.com>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1408572883-9235-1-git-send-email-mark.einon@gmail.com>
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

This implements NAPI support for et131x by:

-adding a napi_struct to the private adapter struct
-changing netfif_rx_skb() call to netif_receive_skb()
-changing et131x_handle_recv_interrupt() to et131x_handle_recv_pkts()
 and taking a budget allocation.
-changing et131x_handle_send_interrupt() to et131x_handle_send_pkts()
-replacing bottom half workqueue with poll function which handles
 send & receive of skbs.
-adding various other necessary standard napi calls.

Also remove this item from the README TODO list.

Signed-off-by: Mark Einon <mark.einon@gmail.com>
---

Updated after Stephen Hemminger commented that using a negative variable
isn't such a good idea (bool not_done -> bool done).

 drivers/staging/et131x/README   |   1 -
 drivers/staging/et131x/et131x.c | 112 ++++++++++++++++++----------------------
 2 files changed, 50 insertions(+), 63 deletions(-)

diff --git a/drivers/staging/et131x/README b/drivers/staging/et131x/README
index 3befc45..05555a3 100644
--- a/drivers/staging/et131x/README
+++ b/drivers/staging/et131x/README
@@ -10,7 +10,6 @@ driver as they did not build properly at the time.
 TODO:
 	- Look at reducing the number of spinlocks
 	- Simplify code in nic_rx_pkts(), when determining multicast_pkts_rcvd
-	- Implement NAPI support
 	- In et131x_tx(), don't return NETDEV_TX_BUSY, just drop the packet with kfree_skb().
 	- Reduce the number of split lines by careful consideration of variable names etc.
 
diff --git a/drivers/staging/et131x/et131x.c b/drivers/staging/et131x/et131x.c
index bf9ac15..18c355d 100644
--- a/drivers/staging/et131x/et131x.c
+++ b/drivers/staging/et131x/et131x.c
@@ -470,7 +470,7 @@ struct et131x_adapter {
 	struct pci_dev *pdev;
 	struct mii_bus *mii_bus;
 	struct phy_device *phydev;
-	struct work_struct task;
+	struct napi_struct napi;
 
 	/* Flags that indicate current state of the adapter */
 	u32 flags;
@@ -2538,26 +2538,30 @@ static struct rfd *nic_rx_pkts(struct et131x_adapter *adapter)
 
 	skb->protocol = eth_type_trans(skb, adapter->netdev);
 	skb->ip_summed = CHECKSUM_NONE;
-	netif_rx_ni(skb);
+	netif_receive_skb(skb);
 
 out:
 	nic_return_rfd(adapter, rfd);
 	return rfd;
 }
 
-/* et131x_handle_recv_interrupt - Interrupt handler for receive processing
+/* et131x_handle_recv_pkts - Interrupt handler for receive processing
  *
  * Assumption, Rcv spinlock has been acquired.
  */
-static void et131x_handle_recv_interrupt(struct et131x_adapter *adapter)
+static int et131x_handle_recv_pkts(struct et131x_adapter *adapter, int budget)
 {
 	struct rfd *rfd = NULL;
-	u32 count = 0;
+	int count = 0;
+	int limit = budget;
 	bool done = true;
 	struct rx_ring *rx_ring = &adapter->rx_ring;
 
+	if (budget > MAX_PACKETS_HANDLED)
+		limit = MAX_PACKETS_HANDLED;
+
 	/* Process up to available RFD's */
-	while (count < MAX_PACKETS_HANDLED) {
+	while (count < limit) {
 		if (list_empty(&rx_ring->recv_list)) {
 			WARN_ON(rx_ring->num_ready_recv != 0);
 			done = false;
@@ -2589,13 +2593,15 @@ static void et131x_handle_recv_interrupt(struct et131x_adapter *adapter)
 		count++;
 	}
 
-	if (count == MAX_PACKETS_HANDLED || !done) {
+	if (count == limit || !done) {
 		rx_ring->unfinished_receives = true;
 		writel(PARM_TX_TIME_INT_DEF * NANO_IN_A_MICRO,
 		       &adapter->regs->global.watchdog_timer);
 	} else
 		/* Watchdog timer will disable itself if appropriate. */
 		rx_ring->unfinished_receives = false;
+
+	return count;
 }
 
 /* et131x_tx_dma_memory_alloc
@@ -3081,14 +3087,14 @@ static void et131x_free_busy_send_packets(struct et131x_adapter *adapter)
 	tx_ring->used = 0;
 }
 
-/* et131x_handle_send_interrupt - Interrupt handler for sending processing
+/* et131x_handle_send_pkts - Interrupt handler for sending processing
  *
  * Re-claim the send resources, complete sends and get more to send from
  * the send wait queue.
  *
  * Assumption - Send spinlock has been acquired
  */
-static void et131x_handle_send_interrupt(struct et131x_adapter *adapter)
+static void et131x_handle_send_pkts(struct et131x_adapter *adapter)
 {
 	unsigned long flags;
 	u32 serviced;
@@ -3708,9 +3714,9 @@ static void et131x_pci_remove(struct pci_dev *pdev)
 	struct et131x_adapter *adapter = netdev_priv(netdev);
 
 	unregister_netdev(netdev);
+	netif_napi_del(&adapter->napi);
 	phy_disconnect(adapter->phydev);
 	mdiobus_unregister(adapter->mii_bus);
-	cancel_work_sync(&adapter->task);
 	kfree(adapter->mii_bus->irq);
 	mdiobus_free(adapter->mii_bus);
 
@@ -3790,6 +3796,7 @@ static irqreturn_t et131x_isr(int irq, void *dev_id)
 	bool handled = true;
 	struct net_device *netdev = (struct net_device *)dev_id;
 	struct et131x_adapter *adapter = netdev_priv(netdev);
+	struct address_map __iomem *iomem = adapter->regs;
 	struct rx_ring *rx_ring = &adapter->rx_ring;
 	struct tx_ring *tx_ring = &adapter->tx_ring;
 	u32 status;
@@ -3826,7 +3833,6 @@ static irqreturn_t et131x_isr(int irq, void *dev_id)
 	}
 
 	/* This is our interrupt, so process accordingly */
-
 	if (status & ET_INTR_WATCHDOG) {
 		struct tcb *tcb = tx_ring->send_head;
 
@@ -3842,54 +3848,8 @@ static irqreturn_t et131x_isr(int irq, void *dev_id)
 		status &= ~ET_INTR_WATCHDOG;
 	}
 
-	if (!status) {
-		/* This interrupt has in some way been "handled" by
-		 * the ISR. Either it was a spurious Rx interrupt, or
-		 * it was a Tx interrupt that has been filtered by
-		 * the ISR.
-		 */
-		et131x_enable_interrupts(adapter);
-		goto out;
-	}
-
-	/* We need to save the interrupt status value for use in our
-	 * DPC. We will clear the software copy of that in that
-	 * routine.
-	 */
-	adapter->stats.interrupt_status = status;
-
-	/* Schedule the ISR handler as a bottom-half task in the
-	 * kernel's tq_immediate queue, and mark the queue for
-	 * execution
-	 */
-	schedule_work(&adapter->task);
-out:
-	return IRQ_RETVAL(handled);
-}
-
-/* et131x_isr_handler - The ISR handler
- *
- * scheduled to run in a deferred context by the ISR. This is where the ISR's
- * work actually gets done.
- */
-static void et131x_isr_handler(struct work_struct *work)
-{
-	struct et131x_adapter *adapter =
-		container_of(work, struct et131x_adapter, task);
-	u32 status = adapter->stats.interrupt_status;
-	struct address_map __iomem *iomem = adapter->regs;
-
-	/* These first two are by far the most common.  Once handled, we clear
-	 * their two bits in the status word.  If the word is now zero, we
-	 * exit.
-	 */
-	/* Handle all the completed Transmit interrupts */
-	if (status & ET_INTR_TXDMA_ISR)
-		et131x_handle_send_interrupt(adapter);
-
-	/* Handle all the completed Receives interrupts */
-	if (status & ET_INTR_RXDMA_XFR_DONE)
-		et131x_handle_recv_interrupt(adapter);
+	if (status & (ET_INTR_RXDMA_XFR_DONE | ET_INTR_TXDMA_ISR))
+		napi_schedule(&adapter->napi);
 
 	status &= ~(ET_INTR_TXDMA_ISR | ET_INTR_RXDMA_XFR_DONE);
 
@@ -4041,8 +4001,34 @@ static void et131x_isr_handler(struct work_struct *work)
 		 * addressed module is in a power-down state and can't respond.
 		 */
 	}
+
+	if (!status) {
+		/* This interrupt has in some way been "handled" by
+		 * the ISR. Either it was a spurious Rx interrupt, or
+		 * it was a Tx interrupt that has been filtered by
+		 * the ISR.
+		 */
+		et131x_enable_interrupts(adapter);
+	}
+
 out:
-	et131x_enable_interrupts(adapter);
+	return IRQ_RETVAL(handled);
+}
+
+static int et131x_poll(struct napi_struct *napi, int budget)
+{
+	struct et131x_adapter *adapter =
+		container_of(napi, struct et131x_adapter, napi);
+	int work_done = et131x_handle_recv_pkts(adapter, budget);
+
+	et131x_handle_send_pkts(adapter);
+
+	if (work_done < budget) {
+		napi_complete(&adapter->napi);
+		et131x_enable_interrupts(adapter);
+	}
+
+	return work_done;
 }
 
 /* et131x_stats - Return the current device statistics  */
@@ -4111,6 +4097,8 @@ static int et131x_open(struct net_device *netdev)
 
 	adapter->flags |= FMP_ADAPTER_INTERRUPT_IN_USE;
 
+	napi_enable(&adapter->napi);
+
 	et131x_up(netdev);
 
 	return result;
@@ -4122,6 +4110,7 @@ static int et131x_close(struct net_device *netdev)
 	struct et131x_adapter *adapter = netdev_priv(netdev);
 
 	et131x_down(netdev);
+	napi_disable(&adapter->napi);
 
 	adapter->flags &= ~FMP_ADAPTER_INTERRUPT_IN_USE;
 	free_irq(adapter->pdev->irq, netdev);
@@ -4502,8 +4491,7 @@ static int et131x_pci_setup(struct pci_dev *pdev,
 	/* Init send data structures */
 	et131x_init_send(adapter);
 
-	/* Set up the task structure for the ISR's deferred handler */
-	INIT_WORK(&adapter->task, et131x_isr_handler);
+	netif_napi_add(netdev, &adapter->napi, et131x_poll, 64);
 
 	/* Copy address into the net_device struct */
 	memcpy(netdev->dev_addr, adapter->addr, ETH_ALEN);
-- 
2.1.0
