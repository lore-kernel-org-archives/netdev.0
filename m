From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [RFC PATCH linux-next] et131x: Promote staging et131x driver to
 drivers/net
Date: Tue, 23 Sep 2014 09:22:53 +0200
Message-ID: <20140923072251.GD4657@distanz.ch>
References: <1411421283-25073-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org, davem@davemloft.net,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mark Einon <mark.einon@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1411421283-25073-1-git-send-email-mark.einon@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On 2014-09-22 at 23:28:03 +0200, Mark Einon <mark.einon@gmail.com> wrote:
> This patch moves the et131x gigabit ethernet driver from drivers/staging
> to drivers/net/ethernet/agere.
> 
> There are no known issues at this time.
> 
> Signed-off-by: Mark Einon <mark.einon@gmail.com>
> ---
> 
> This patch will only apply once the last few pending changes
> make their way from staging-next to linux-next, but posting
> now in the hope that feedback can be given and this change can
> make it in before the next merge window.
> 
>  drivers/net/ethernet/Kconfig        |    1 +
>  drivers/net/ethernet/Makefile       |    1 +
>  drivers/net/ethernet/agere/Kconfig  |   31 +
>  drivers/net/ethernet/agere/Makefile |    5 +
>  drivers/net/ethernet/agere/et131x.c | 4412 +++++++++++++++++++++++++++++++++++
>  drivers/net/ethernet/agere/et131x.h | 1533 ++++++++++++
>  drivers/staging/Kconfig             |    2 -
>  drivers/staging/Makefile            |    1 -
>  drivers/staging/et131x/Kconfig      |   10 -
>  drivers/staging/et131x/Makefile     |    5 -
>  drivers/staging/et131x/README       |   15 -
>  drivers/staging/et131x/et131x.c     | 4412 -----------------------------------
>  drivers/staging/et131x/et131x.h     | 1533 ------------
>  13 files changed, 5983 insertions(+), 5978 deletions(-)
>  create mode 100644 drivers/net/ethernet/agere/Kconfig
>  create mode 100644 drivers/net/ethernet/agere/Makefile
>  create mode 100644 drivers/net/ethernet/agere/et131x.c
>  create mode 100644 drivers/net/ethernet/agere/et131x.h
>  delete mode 100644 drivers/staging/et131x/Kconfig
>  delete mode 100644 drivers/staging/et131x/Makefile
>  delete mode 100644 drivers/staging/et131x/README
>  delete mode 100644 drivers/staging/et131x/et131x.c
>  delete mode 100644 drivers/staging/et131x/et131x.h

[...]

> diff --git a/drivers/net/ethernet/agere/et131x.c b/drivers/net/ethernet/agere/et131x.c
> new file mode 100644
> index 0000000..93afd61
> --- /dev/null
> +++ b/drivers/net/ethernet/agere/et131x.c
> @@ -0,0 +1,4412 @@

[...]

> +/* et131x_rx_dma_memory_alloc
> + *
> + * Allocates Free buffer ring 1 for sure, free buffer ring 0 if required,
> + * and the Packet Status Ring.
> + */
> +static int et131x_rx_dma_memory_alloc(struct et131x_adapter *adapter)
> +{
> +	u8 id;
> +	u32 i, j;
> +	u32 bufsize;
> +	u32 psr_size;
> +	u32 fbr_chunksize;
> +	struct rx_ring *rx_ring = &adapter->rx_ring;
> +	struct fbr_lookup *fbr;
> +
> +	/* Alloc memory for the lookup table */
> +	rx_ring->fbr[0] = kmalloc(sizeof(*fbr), GFP_KERNEL);
> +	if (rx_ring->fbr[0] == NULL)
> +		return -ENOMEM;
> +	rx_ring->fbr[1] = kmalloc(sizeof(*fbr), GFP_KERNEL);
> +	if (rx_ring->fbr[1] == NULL)
> +		return -ENOMEM;

If you fail here, et131x_rx_dma_memory_free() will be called by
et131x_adapter_memory_free() in the error handling path which in turn
will access the members of the already allocated rx_ring->fbr[0] (e.g.
->buffsize). Since it is allocated with kmalloc() these members contain
arbitrary values and cause problems in et131x_rx_dma_memory_free(). I'
suggest to do the cleanup (i.e. free rx_ring->fbr[0] directly here and
not call et131x_rx_dma_memory_free() in the error handling path. You
might want to check that memory allocation failures are properly handled
in the rest of the driver as well. There are multiple other cases where
et131x_adapter_memory_free() is called on partially
allocated/initialized memory.

> +
> +	/* The first thing we will do is configure the sizes of the buffer
> +	 * rings. These will change based on jumbo packet support.  Larger
> +	 * jumbo packets increases the size of each entry in FBR0, and the
> +	 * number of entries in FBR0, while at the same time decreasing the
> +	 * number of entries in FBR1.
> +	 *
> +	 * FBR1 holds "large" frames, FBR0 holds "small" frames.  If FBR1
> +	 * entries are huge in order to accommodate a "jumbo" frame, then it
> +	 * will have less entries.  Conversely, FBR1 will now be relied upon
> +	 * to carry more "normal" frames, thus it's entry size also increases
> +	 * and the number of entries goes up too (since it now carries
> +	 * "small" + "regular" packets.
> +	 *
> +	 * In this scheme, we try to maintain 512 entries between the two
> +	 * rings. Also, FBR1 remains a constant size - when it's size doubles
> +	 * the number of entries halves.  FBR0 increases in size, however.
> +	 */
> +	if (adapter->registry_jumbo_packet < 2048) {
> +		rx_ring->fbr[0]->buffsize = 256;
> +		rx_ring->fbr[0]->num_entries = 512;
> +		rx_ring->fbr[1]->buffsize = 2048;
> +		rx_ring->fbr[1]->num_entries = 512;
> +	} else if (adapter->registry_jumbo_packet < 4096) {
> +		rx_ring->fbr[0]->buffsize = 512;
> +		rx_ring->fbr[0]->num_entries = 1024;
> +		rx_ring->fbr[1]->buffsize = 4096;
> +		rx_ring->fbr[1]->num_entries = 512;
> +	} else {
> +		rx_ring->fbr[0]->buffsize = 1024;
> +		rx_ring->fbr[0]->num_entries = 768;
> +		rx_ring->fbr[1]->buffsize = 16384;
> +		rx_ring->fbr[1]->num_entries = 128;
> +	}
> +
> +	rx_ring->psr_entries = rx_ring->fbr[0]->num_entries +
> +			       rx_ring->fbr[1]->num_entries;
> +
> +	for (id = 0; id < NUM_FBRS; id++) {
> +		fbr = rx_ring->fbr[id];
> +		/* Allocate an area of memory for Free Buffer Ring */
> +		bufsize = sizeof(struct fbr_desc) * fbr->num_entries;
> +		fbr->ring_virtaddr = dma_alloc_coherent(&adapter->pdev->dev,
> +							bufsize,
> +							&fbr->ring_physaddr,
> +							GFP_KERNEL);
> +		if (!fbr->ring_virtaddr) {
> +			dev_err(&adapter->pdev->dev,
> +				"Cannot alloc memory for Free Buffer Ring %d\n",
> +				id);
> +			return -ENOMEM;
> +		}
> +	}
> +
> +	for (id = 0; id < NUM_FBRS; id++) {
> +		fbr = rx_ring->fbr[id];
> +		fbr_chunksize = (FBR_CHUNKS * fbr->buffsize);
> +
> +		for (i = 0; i < fbr->num_entries / FBR_CHUNKS; i++) {
> +			dma_addr_t fbr_physaddr;
> +
> +			fbr->mem_virtaddrs[i] = dma_alloc_coherent(
> +					&adapter->pdev->dev, fbr_chunksize,
> +					&fbr->mem_physaddrs[i],
> +					GFP_KERNEL);
> +
> +			if (!fbr->mem_virtaddrs[i]) {
> +				dev_err(&adapter->pdev->dev,
> +					"Could not alloc memory\n");
> +				return -ENOMEM;
> +			}
> +
> +			/* See NOTE in "Save Physical Address" comment above */
> +			fbr_physaddr = fbr->mem_physaddrs[i];
> +
> +			for (j = 0; j < FBR_CHUNKS; j++) {
> +				u32 k = (i * FBR_CHUNKS) + j;
> +
> +				/* Save the Virtual address of this index for
> +				 * quick access later
> +				 */
> +				fbr->virt[k] = (u8 *)fbr->mem_virtaddrs[i] +
> +						   (j * fbr->buffsize);
> +
> +				/* now store the physical address in the
> +				 * descriptor so the device can access it
> +				 */
> +				fbr->bus_high[k] = upper_32_bits(fbr_physaddr);
> +				fbr->bus_low[k] = lower_32_bits(fbr_physaddr);
> +				fbr_physaddr += fbr->buffsize;
> +			}
> +		}
> +	}
> +
> +	/* Allocate an area of memory for FIFO of Packet Status ring entries */
> +	psr_size = sizeof(struct pkt_stat_desc) * rx_ring->psr_entries;
> +
> +	rx_ring->ps_ring_virtaddr = dma_alloc_coherent(&adapter->pdev->dev,
> +						  psr_size,
> +						  &rx_ring->ps_ring_physaddr,
> +						  GFP_KERNEL);
> +
> +	if (!rx_ring->ps_ring_virtaddr) {
> +		dev_err(&adapter->pdev->dev,
> +			"Cannot alloc memory for Packet Status Ring\n");
> +		return -ENOMEM;
> +	}
> +
> +	/* NOTE : dma_alloc_coherent(), used above to alloc DMA regions,
> +	 * ALWAYS returns SAC (32-bit) addresses. If DAC (64-bit) addresses
> +	 * are ever returned, make sure the high part is retrieved here before
> +	 * storing the adjusted address.
> +	 */
> +
> +	/* Allocate an area of memory for writeback of status information */
> +	rx_ring->rx_status_block = dma_alloc_coherent(&adapter->pdev->dev,
> +					    sizeof(struct rx_status_block),
> +					    &rx_ring->rx_status_bus,
> +					    GFP_KERNEL);
> +	if (!rx_ring->rx_status_block) {
> +		dev_err(&adapter->pdev->dev,
> +			"Cannot alloc memory for Status Block\n");
> +		return -ENOMEM;
> +	}
> +	rx_ring->num_rfd = NIC_DEFAULT_NUM_RFD;
> +
> +	/* The RFDs are going to be put on lists later on, so initialize the
> +	 * lists now.
> +	 */
> +	INIT_LIST_HEAD(&rx_ring->recv_list);
> +	return 0;
> +}
> +
> +/* et131x_rx_dma_memory_free - Free all memory allocated within this module */
> +static void et131x_rx_dma_memory_free(struct et131x_adapter *adapter)
> +{
> +	u8 id;
> +	u32 ii;
> +	u32 bufsize;
> +	u32 psr_size;
> +	struct rfd *rfd;
> +	struct rx_ring *rx_ring = &adapter->rx_ring;
> +	struct fbr_lookup *fbr;
> +
> +	/* Free RFDs and associated packet descriptors */
> +	WARN_ON(rx_ring->num_ready_recv != rx_ring->num_rfd);
> +
> +	while (!list_empty(&rx_ring->recv_list)) {
> +		rfd = list_entry(rx_ring->recv_list.next,
> +				 struct rfd, list_node);
> +
> +		list_del(&rfd->list_node);
> +		rfd->skb = NULL;
> +		kfree(rfd);
> +	}
> +
> +	/* Free Free Buffer Rings */
> +	for (id = 0; id < NUM_FBRS; id++) {
> +		fbr = rx_ring->fbr[id];
> +
> +		if (!fbr || !fbr->ring_virtaddr)
> +			continue;
> +
> +		/* First the packet memory */
> +		for (ii = 0; ii < fbr->num_entries / FBR_CHUNKS; ii++) {
> +			if (fbr->mem_virtaddrs[ii]) {
> +				bufsize = fbr->buffsize * FBR_CHUNKS;
> +
> +				dma_free_coherent(&adapter->pdev->dev,
> +						  bufsize,
> +						  fbr->mem_virtaddrs[ii],
> +						  fbr->mem_physaddrs[ii]);
> +
> +				fbr->mem_virtaddrs[ii] = NULL;
> +			}
> +		}
> +
> +		bufsize = sizeof(struct fbr_desc) * fbr->num_entries;
> +
> +		dma_free_coherent(&adapter->pdev->dev,
> +				  bufsize,
> +				  fbr->ring_virtaddr,
> +				  fbr->ring_physaddr);
> +
> +		fbr->ring_virtaddr = NULL;
> +	}
> +
> +	/* Free Packet Status Ring */
> +	if (rx_ring->ps_ring_virtaddr) {
> +		psr_size = sizeof(struct pkt_stat_desc) * rx_ring->psr_entries;
> +
> +		dma_free_coherent(&adapter->pdev->dev, psr_size,
> +				  rx_ring->ps_ring_virtaddr,
> +				  rx_ring->ps_ring_physaddr);
> +
> +		rx_ring->ps_ring_virtaddr = NULL;
> +	}
> +
> +	/* Free area of memory for the writeback of status information */
> +	if (rx_ring->rx_status_block) {
> +		dma_free_coherent(&adapter->pdev->dev,
> +				  sizeof(struct rx_status_block),
> +				  rx_ring->rx_status_block,
> +				  rx_ring->rx_status_bus);
> +		rx_ring->rx_status_block = NULL;
> +	}
> +
> +	/* Free the FBR Lookup Table */
> +	kfree(rx_ring->fbr[0]);
> +	kfree(rx_ring->fbr[1]);
> +
> +	/* Reset Counters */
> +	rx_ring->num_ready_recv = 0;
> +}

[...]

> +/* et131x_adapter_memory_free - Free all memory allocated for use by Tx & Rx */
> +static void et131x_adapter_memory_free(struct et131x_adapter *adapter)
> +{
> +	et131x_tx_dma_memory_free(adapter);
> +	et131x_rx_dma_memory_free(adapter);
> +}
> +
> +/* et131x_adapter_memory_alloc
> + * Allocate all the memory blocks for send, receive and others.
> + */
> +static int et131x_adapter_memory_alloc(struct et131x_adapter *adapter)
> +{
> +	int status;
> +
> +	/* Allocate memory for the Tx Ring */
> +	status = et131x_tx_dma_memory_alloc(adapter);
> +	if (status) {
> +		dev_err(&adapter->pdev->dev,
> +			"et131x_tx_dma_memory_alloc FAILED\n");
> +		et131x_tx_dma_memory_free(adapter);
> +		return status;
> +	}
> +	/* Receive buffer memory allocation */
> +	status = et131x_rx_dma_memory_alloc(adapter);
> +	if (status) {
> +		dev_err(&adapter->pdev->dev,
> +			"et131x_rx_dma_memory_alloc FAILED\n");
> +		et131x_adapter_memory_free(adapter);
> +		return status;
> +	}
> +
> +	/* Init receive data structures */
> +	status = et131x_init_recv(adapter);
> +	if (status) {
> +		dev_err(&adapter->pdev->dev, "et131x_init_recv FAILED\n");
> +		et131x_adapter_memory_free(adapter);
> +	}
> +	return status;
> +}

[...]

> +#ifdef CONFIG_PM_SLEEP
> +static int et131x_suspend(struct device *dev)
> +{
> +	struct pci_dev *pdev = to_pci_dev(dev);
> +	struct net_device *netdev = pci_get_drvdata(pdev);
> +
> +	if (netif_running(netdev)) {
> +		netif_device_detach(netdev);
> +		et131x_down(netdev);
> +		pci_save_state(pdev);
> +	}
> +
> +	return 0;
> +}
> +
> +static int et131x_resume(struct device *dev)
> +{
> +	struct pci_dev *pdev = to_pci_dev(dev);
> +	struct net_device *netdev = pci_get_drvdata(pdev);
> +
> +	if (netif_running(netdev)) {
> +		pci_restore_state(pdev);
> +		et131x_up(netdev);
> +		netif_device_attach(netdev);
> +	}
> +
> +	return 0;
> +}
> +
> +static SIMPLE_DEV_PM_OPS(et131x_pm_ops, et131x_suspend, et131x_resume);
> +#define ET131X_PM_OPS (&et131x_pm_ops)
> +#else
> +#define ET131X_PM_OPS NULL
> +#endif

No need for the #define here, just assigne et131x_pm_ops to .driver.pm
directly, its members will be NULL and thus never called. Also, you can
make et131x_pm_ops const.

> +
> +/* et131x_isr - The Interrupt Service Routine for the driver.
> + * @irq: the IRQ on which the interrupt was received.
> + * @dev_id: device-specific info (here a pointer to a net_device struct)
> + *
> + * Returns a value indicating if the interrupt was handled.
> + */
> +static irqreturn_t et131x_isr(int irq, void *dev_id)
> +{
> +	bool handled = true;
> +	bool enable_interrupts = true;
> +	struct net_device *netdev = (struct net_device *)dev_id;

No need to cast a void *.

> +	struct et131x_adapter *adapter = netdev_priv(netdev);
> +	struct address_map __iomem *iomem = adapter->regs;
> +	struct rx_ring *rx_ring = &adapter->rx_ring;
> +	struct tx_ring *tx_ring = &adapter->tx_ring;
> +	u32 status;
> +
> +	if (!netif_device_present(netdev)) {
> +		handled = false;
> +		enable_interrupts = false;
> +		goto out;
> +	}
> +
> +	/* If the adapter is in low power state, then it should not
> +	 * recognize any interrupt
> +	 */
> +
> +	/* Disable Device Interrupts */
> +	et131x_disable_interrupts(adapter);
> +
> +	/* Get a copy of the value in the interrupt status register
> +	 * so we can process the interrupting section
> +	 */
> +	status = readl(&adapter->regs->global.int_status);
> +
> +	if (adapter->flow == FLOW_TXONLY || adapter->flow == FLOW_BOTH)
> +		status &= ~INT_MASK_ENABLE;
> +	else
> +		status &= ~INT_MASK_ENABLE_NO_FLOW;
> +
> +	/* Make sure this is our interrupt */
> +	if (!status) {
> +		handled = false;
> +		et131x_enable_interrupts(adapter);
> +		goto out;
> +	}
> +
> +	/* This is our interrupt, so process accordingly */
> +	if (status & ET_INTR_WATCHDOG) {
> +		struct tcb *tcb = tx_ring->send_head;
> +
> +		if (tcb)
> +			if (++tcb->stale > 1)
> +				status |= ET_INTR_TXDMA_ISR;
> +
> +		if (rx_ring->unfinished_receives)
> +			status |= ET_INTR_RXDMA_XFR_DONE;
> +		else if (tcb == NULL)
> +			writel(0, &adapter->regs->global.watchdog_timer);
> +
> +		status &= ~ET_INTR_WATCHDOG;
> +	}
> +
> +	if (status & (ET_INTR_RXDMA_XFR_DONE | ET_INTR_TXDMA_ISR)) {
> +		enable_interrupts = false;
> +		napi_schedule(&adapter->napi);
> +	}
> +
> +	status &= ~(ET_INTR_TXDMA_ISR | ET_INTR_RXDMA_XFR_DONE);
> +
> +	if (!status)
> +		goto out;
> +
> +	/* Handle the TXDMA Error interrupt */
> +	if (status & ET_INTR_TXDMA_ERR) {
> +		/* Following read also clears the register (COR) */
> +		u32 txdma_err = readl(&iomem->txdma.tx_dma_error);
> +
> +		dev_warn(&adapter->pdev->dev,
> +			 "TXDMA_ERR interrupt, error = %d\n",
> +			 txdma_err);
> +	}
> +
> +	/* Handle Free Buffer Ring 0 and 1 Low interrupt */
> +	if (status & (ET_INTR_RXDMA_FB_R0_LOW | ET_INTR_RXDMA_FB_R1_LOW)) {
> +		/* This indicates the number of unused buffers in RXDMA free
> +		 * buffer ring 0 is <= the limit you programmed. Free buffer
> +		 * resources need to be returned.  Free buffers are consumed as
> +		 * packets are passed from the network to the host. The host
> +		 * becomes aware of the packets from the contents of the packet
> +		 * status ring. This ring is queried when the packet done
> +		 * interrupt occurs. Packets are then passed to the OS. When
> +		 * the OS is done with the packets the resources can be
> +		 * returned to the ET1310 for re-use. This interrupt is one
> +		 * method of returning resources.
> +		 */
> +
> +		/*  If the user has flow control on, then we will
> +		 * send a pause packet, otherwise just exit
> +		 */
> +		if (adapter->flow == FLOW_TXONLY || adapter->flow == FLOW_BOTH) {
> +			u32 pm_csr;
> +
> +			/* Tell the device to send a pause packet via the back
> +			 * pressure register (bp req and bp xon/xoff)
> +			 */
> +			pm_csr = readl(&iomem->global.pm_csr);
> +			if (!et1310_in_phy_coma(adapter))
> +				writel(3, &iomem->txmac.bp_ctrl);
> +		}
> +	}
> +
> +	/* Handle Packet Status Ring Low Interrupt */
> +	if (status & ET_INTR_RXDMA_STAT_LOW) {
> +		/* Same idea as with the two Free Buffer Rings. Packets going
> +		 * from the network to the host each consume a free buffer
> +		 * resource and a packet status resource. These resources are
> +		 * passed to the OS. When the OS is done with the resources,
> +		 * they need to be returned to the ET1310. This is one method
> +		 * of returning the resources.
> +		 */
> +	}
> +
> +	/* Handle RXDMA Error Interrupt */
> +	if (status & ET_INTR_RXDMA_ERR) {
> +		/* The rxdma_error interrupt is sent when a time-out on a
> +		 * request issued by the JAGCore has occurred or a completion is
> +		 * returned with an un-successful status. In both cases the
> +		 * request is considered complete. The JAGCore will
> +		 * automatically re-try the request in question. Normally
> +		 * information on events like these are sent to the host using
> +		 * the "Advanced Error Reporting" capability. This interrupt is
> +		 * another way of getting similar information. The only thing
> +		 * required is to clear the interrupt by reading the ISR in the
> +		 * global resources. The JAGCore will do a re-try on the
> +		 * request. Normally you should never see this interrupt. If
> +		 * you start to see this interrupt occurring frequently then
> +		 * something bad has occurred. A reset might be the thing to do.
> +		 */
> +		/* TRAP();*/
> +
> +		dev_warn(&adapter->pdev->dev,
> +			 "RxDMA_ERR interrupt, error %x\n",
> +			 readl(&iomem->txmac.tx_test));
> +	}
> +
> +	/* Handle the Wake on LAN Event */
> +	if (status & ET_INTR_WOL) {
> +		/* This is a secondary interrupt for wake on LAN. The driver
> +		 * should never see this, if it does, something serious is
> +		 * wrong. We will TRAP the message when we are in DBG mode,
> +		 * otherwise we will ignore it.
> +		 */
> +		dev_err(&adapter->pdev->dev, "WAKE_ON_LAN interrupt\n");
> +	}
> +
> +	/* Let's move on to the TxMac */
> +	if (status & ET_INTR_TXMAC) {
> +		u32 err = readl(&iomem->txmac.err);
> +
> +		/* When any of the errors occur and TXMAC generates an
> +		 * interrupt to report these errors, it usually means that
> +		 * TXMAC has detected an error in the data stream retrieved
> +		 * from the on-chip Tx Q. All of these errors are catastrophic
> +		 * and TXMAC won't be able to recover data when these errors
> +		 * occur. In a nutshell, the whole Tx path will have to be reset
> +		 * and re-configured afterwards.
> +		 */
> +		dev_warn(&adapter->pdev->dev,
> +			 "TXMAC interrupt, error 0x%08x\n",
> +			 err);
> +
> +		/* If we are debugging, we want to see this error, otherwise we
> +		 * just want the device to be reset and continue
> +		 */
> +	}
> +
> +	/* Handle RXMAC Interrupt */
> +	if (status & ET_INTR_RXMAC) {
> +		/* These interrupts are catastrophic to the device, what we need
> +		 * to do is disable the interrupts and set the flag to cause us
> +		 * to reset so we can solve this issue.
> +		 */
> +		/* MP_SET_FLAG( adapter, FMP_ADAPTER_HARDWARE_ERROR); */
> +
> +		dev_warn(&adapter->pdev->dev,
> +			 "RXMAC interrupt, error 0x%08x.  Requesting reset\n",
> +			 readl(&iomem->rxmac.err_reg));
> +
> +		dev_warn(&adapter->pdev->dev,
> +			 "Enable 0x%08x, Diag 0x%08x\n",
> +			 readl(&iomem->rxmac.ctrl),
> +			 readl(&iomem->rxmac.rxq_diag));
> +
> +		/* If we are debugging, we want to see this error, otherwise we
> +		 * just want the device to be reset and continue
> +		 */
> +	}
> +
> +	/* Handle MAC_STAT Interrupt */
> +	if (status & ET_INTR_MAC_STAT) {
> +		/* This means at least one of the un-masked counters in the
> +		 * MAC_STAT block has rolled over. Use this to maintain the top,
> +		 * software managed bits of the counter(s).
> +		 */
> +		et1310_handle_macstat_interrupt(adapter);
> +	}
> +
> +	/* Handle SLV Timeout Interrupt */
> +	if (status & ET_INTR_SLV_TIMEOUT) {
> +		/* This means a timeout has occurred on a read or write request
> +		 * to one of the JAGCore registers. The Global Resources block
> +		 * has terminated the request and on a read request, returned a
> +		 * "fake" value. The most likely reasons are: Bad Address or the
> +		 * addressed module is in a power-down state and can't respond.
> +		 */
> +	}
> +
> +out:
> +	if (enable_interrupts)
> +		et131x_enable_interrupts(adapter);
> +
> +	return IRQ_RETVAL(handled);
> +}

[...]

> +static const struct pci_device_id et131x_pci_table[] = {
> +	{ PCI_VDEVICE(ATT, ET131X_PCI_DEVICE_ID_GIG), 0UL},
> +	{ PCI_VDEVICE(ATT, ET131X_PCI_DEVICE_ID_FAST), 0UL},
> +	{0,}

Nit: Space after opening curly brace.
