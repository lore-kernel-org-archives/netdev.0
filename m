From: Mark Einon <mark.einon@gmail.com>
Subject: Re: [RFC PATCH linux-next] et131x: Promote staging et131x driver to
 drivers/net
Date: Tue, 23 Sep 2014 10:46:15 +0100
Message-ID: <20140923094614.GA5130@leicester.auvation.com>
References: <1411421283-25073-1-git-send-email-mark.einon@gmail.com>
 <20140923072251.GD4657@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org, davem@davemloft.net,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20140923072251.GD4657@distanz.ch>
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

On Tue, Sep 23, 2014 at 09:22:53AM +0200, Tobias Klauser wrote:

Hi Tobias,

Thanks for the details review. I've replied below -

[...]
> > +/* et131x_rx_dma_memory_alloc
> > + *
> > + * Allocates Free buffer ring 1 for sure, free buffer ring 0 if required,
> > + * and the Packet Status Ring.
> > + */
> > +static int et131x_rx_dma_memory_alloc(struct et131x_adapter *adapter)
> > +{
> > +	u8 id;
> > +	u32 i, j;
> > +	u32 bufsize;
> > +	u32 psr_size;
> > +	u32 fbr_chunksize;
> > +	struct rx_ring *rx_ring = &adapter->rx_ring;
> > +	struct fbr_lookup *fbr;
> > +
> > +	/* Alloc memory for the lookup table */
> > +	rx_ring->fbr[0] = kmalloc(sizeof(*fbr), GFP_KERNEL);
> > +	if (rx_ring->fbr[0] == NULL)
> > +		return -ENOMEM;
> > +	rx_ring->fbr[1] = kmalloc(sizeof(*fbr), GFP_KERNEL);
> > +	if (rx_ring->fbr[1] == NULL)
> > +		return -ENOMEM;
> 
> If you fail here, et131x_rx_dma_memory_free() will be called by
> et131x_adapter_memory_free() in the error handling path which in turn
> will access the members of the already allocated rx_ring->fbr[0] (e.g.
> ->buffsize). Since it is allocated with kmalloc() these members contain
> arbitrary values and cause problems in et131x_rx_dma_memory_free(). I'
> suggest to do the cleanup (i.e. free rx_ring->fbr[0] directly here and
> not call et131x_rx_dma_memory_free() in the error handling path. You
> might want to check that memory allocation failures are properly handled
> in the rest of the driver as well. There are multiple other cases where
> et131x_adapter_memory_free() is called on partially
> allocated/initialized memory.
> 

I don't think this is the case - the members of rx_ring->fbr[x] are not
accessed unless this pointer is non-NULL in et131x_rx_dma_memory_free()
(see code snippet below), which is exactly why the kmalloc code above
would fail, so buffsize never gets accessed and the code is cleaned up
correctly.  Actually, for further explanation, this thread discusses
these changes:

http://www.spinics.net/lists/linux-driver-devel/msg42128.html


> > +/* et131x_rx_dma_memory_free - Free all memory allocated within this module */
> > +static void et131x_rx_dma_memory_free(struct et131x_adapter *adapter)
> > +{

[...]

> > +	/* Free Free Buffer Rings */
> > +	for (id = 0; id < NUM_FBRS; id++) {
> > +		fbr = rx_ring->fbr[id];
> > +
> > +		if (!fbr || !fbr->ring_virtaddr)
> > +			continue;
> > +
> > +		/* First the packet memory */
> > +		for (ii = 0; ii < fbr->num_entries / FBR_CHUNKS; ii++) {
> > +			if (fbr->mem_virtaddrs[ii]) {
> > +				bufsize = fbr->buffsize * FBR_CHUNKS;

[...]

> > +static SIMPLE_DEV_PM_OPS(et131x_pm_ops, et131x_suspend, et131x_resume);
> > +#define ET131X_PM_OPS (&et131x_pm_ops)
> > +#else
> > +#define ET131X_PM_OPS NULL
> > +#endif
> 
> No need for the #define here, just assigne et131x_pm_ops to .driver.pm
> directly, its members will be NULL and thus never called. Also, you can
> make et131x_pm_ops const.

Ok, I can change this.

Btw, this appears to be a fairly standard way of using .driver.pm among
ethernet drivers, e.g. see 3com/3c59x.c, atheros, marvell... - perhaps
there is a case for changing all instances of this code?

> > +
> > +/* et131x_isr - The Interrupt Service Routine for the driver.
> > + * @irq: the IRQ on which the interrupt was received.
> > + * @dev_id: device-specific info (here a pointer to a net_device struct)
> > + *
> > + * Returns a value indicating if the interrupt was handled.
> > + */
> > +static irqreturn_t et131x_isr(int irq, void *dev_id)
> > +{
> > +	bool handled = true;
> > +	bool enable_interrupts = true;
> > +	struct net_device *netdev = (struct net_device *)dev_id;
> 
> No need to cast a void *.
> 
> [...]
> 
> > +static const struct pci_device_id et131x_pci_table[] = {
> > +	{ PCI_VDEVICE(ATT, ET131X_PCI_DEVICE_ID_GIG), 0UL},
> > +	{ PCI_VDEVICE(ATT, ET131X_PCI_DEVICE_ID_FAST), 0UL},
> > +	{0,}
> 
> Nit: Space after opening curly brace.

Ok, I'll change both of these, thanks.

Mark
