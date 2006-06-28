From: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Subject: Re: [RFT PATCH] pcnet32:  NAPI support
Date: Wed, 28 Jun 2006 10:40:10 -0400
Message-ID: <20060628144010.GA1446@csclub.uwaterloo.ca>
References: <20060623213212.GA24388@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.uwaterloo.ca ([129.97.134.17]:62096 "EHLO
	caffeine.csclub.uwaterloo.ca") by vger.kernel.org with ESMTP
	id S1030274AbWF1OkL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 10:40:11 -0400
To: Don Fry <brazilnut@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <20060623213212.GA24388@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 23, 2006 at 02:32:12PM -0700, Don Fry wrote:
> This set of changes combines the work done by Len Sorensen and myself to
> add compile time support for NAPI for the pcnet32 driver.  I have tested
> it on ia32 and ppc64 hardware with various versions of the pcnet32
> adapter.  I have also made a few changes requested by Jon Mason, but the
> substitution of the many magic numbers in the driver is not yet done.
> 
> If no-one encounters any problems when testing this, I will break up the
> several changes, into proper patches and submit them next week.

Well so far this is working for me.  It is a somewhat different layout
of the interrupt handler so it took me a bit of work to get the features
I need patched in, but in the end I ended up with simpler code as a
reesult, so I am quite happy with the new layout.  The driver works on
everything I have to try it on so far.

> Signed-off-by:  Don Fry <brazilnut@us.ibm.com>
> 
> 
> --- linux-2.6.17/drivers/net/orig.Kconfig	2006-06-15 11:49:39.000000000 -0700
> +++ linux-2.6.17/drivers/net/Kconfig	2006-06-22 15:44:52.000000000 -0700
> @@ -1272,6 +1272,23 @@ config PCNET32
>  	  <file:Documentation/networking/net-modules.txt>. The module
>  	  will be called pcnet32.
>  
> +config PCNET32_NAPI
> +	bool "Use RX polling (NAPI) (EXPERIMENTAL)"
> +	depends on PCNET32 && EXPERIMENTAL
> +	help
> +	  NAPI is a new driver API designed to reduce CPU and interrupt load
> +	  when the driver is receiving lots of packets from the card. It is
> +	  still somewhat experimental and thus not yet enabled by default.
> +
> +	  If your estimated Rx load is 10kpps or more, or if the card will be
> +	  deployed on potentially unfriendly networks (e.g. in a firewall),
> +	  then say Y here.
> +
> +	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
> +	  information.
> +
> +	  If in doubt, say N.
> +
>  config AMD8111_ETH
>  	tristate "AMD 8111 (new PCI lance) support"
>  	depends on NET_PCI && PCI
> 
> --- linux-2.6.17/drivers/net/orig.pcnet32.c	Sat Jun 17 18:49:35 2006
> +++ linux-2.6.17/drivers/net/pcnet32.c	Fri Jun 23 13:13:02 2006
> @@ -21,9 +21,15 @@
>   *
>   *************************************************************************/
>  
> +#include <linux/config.h>
> +
>  #define DRV_NAME	"pcnet32"
> -#define DRV_VERSION	"1.32"
> -#define DRV_RELDATE	"18.Mar.2006"
> +#ifdef CONFIG_PCNET32_NAPI
> +#define DRV_VERSION	"1.33-NAPI"
> +#else
> +#define DRV_VERSION	"1.33"
> +#endif
> +#define DRV_RELDATE	"23.Jun.2006"
>  #define PFX		DRV_NAME ": "
>  
>  static const char *const version =
> @@ -58,18 +64,15 @@ static const char *const version =
>   * PCI device identifiers for "new style" Linux PCI Device Drivers
>   */
>  static struct pci_device_id pcnet32_pci_tbl[] = {
> -	{ PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD_LANCE_HOME,
> -	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
> -	{ PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD_LANCE,
> -	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
> +	{ PCI_DEVICE(PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD_LANCE_HOME), },
> +	{ PCI_DEVICE(PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD_LANCE), },
>  
>  	/*
>  	 * Adapters that were sold with IBM's RS/6000 or pSeries hardware have
>  	 * the incorrect vendor id.
>  	 */
> -	{ PCI_VENDOR_ID_TRIDENT, PCI_DEVICE_ID_AMD_LANCE,
> -	  PCI_ANY_ID, PCI_ANY_ID,
> -	  PCI_CLASS_NETWORK_ETHERNET << 8, 0xffff00, 0},
> +	{ PCI_DEVICE(PCI_VENDOR_ID_TRIDENT, PCI_DEVICE_ID_AMD_LANCE),
> +	  .class = (PCI_CLASS_NETWORK_ETHERNET << 8), .class_mask = 0xffff00, },
>  
>  	{ }	/* terminate list */
>  };
> @@ -277,13 +280,14 @@ struct pcnet32_private {
>  	u32			phymask;
>  };
>  
> -static void pcnet32_probe_vlbus(void);
>  static int pcnet32_probe_pci(struct pci_dev *, const struct pci_device_id *);
>  static int pcnet32_probe1(unsigned long, int, struct pci_dev *);
>  static int pcnet32_open(struct net_device *);
>  static int pcnet32_init_ring(struct net_device *);
>  static int pcnet32_start_xmit(struct sk_buff *, struct net_device *);
> -static int pcnet32_rx(struct net_device *);
> +#ifdef CONFIG_PCNET32_NAPI
> +static int pcnet32_poll(struct net_device *dev, int *budget);
> +#endif
>  static void pcnet32_tx_timeout(struct net_device *dev);
>  static irqreturn_t pcnet32_interrupt(int, void *, struct pt_regs *);
>  static int pcnet32_close(struct net_device *);
> @@ -425,6 +429,235 @@ static struct pcnet32_access pcnet32_dwi
>  	.reset = pcnet32_dwio_reset
>  };
>  
> +static void pcnet32_netif_stop(struct net_device *dev)
> +{
> +	dev->trans_start = jiffies;
> +	netif_poll_disable(dev);
> +	netif_tx_disable(dev);
> +}
> +
> +static void pcnet32_netif_start(struct net_device *dev)
> +{
> +	netif_wake_queue(dev);
> +	netif_poll_enable(dev);
> +}
> +
> +/*
> + * Allocate space for the new sized tx ring.
> + * Free old resources
> + * Save new resources.
> + * Any failure keeps old resources.
> + * Must be called with lp->lock held.
> + */
> +static void pcnet32_realloc_tx_ring(struct net_device *dev,
> +				    struct pcnet32_private *lp,
> +				    unsigned int size)
> +{
> +	dma_addr_t new_ring_dma_addr;
> +	dma_addr_t *new_dma_addr_list;
> +	struct pcnet32_tx_head *new_tx_ring;
> +	struct sk_buff **new_skb_list;
> +
> +	pcnet32_purge_tx_ring(dev);
> +
> +	new_tx_ring = pci_alloc_consistent(lp->pci_dev,
> +					   sizeof(struct pcnet32_tx_head) *
> +					   (1 << size),
> +					   &new_ring_dma_addr);
> +	if (new_tx_ring == NULL) {
> +		if (pcnet32_debug & NETIF_MSG_DRV)
> +			printk("\n" KERN_ERR PFX
> +			       "%s: Consistent memory allocation failed.\n",
> +			       dev->name);
> +		return;
> +	}
> +	memset(new_tx_ring, 0, sizeof(struct pcnet32_tx_head) * (1 << size));
> +
> +	new_dma_addr_list = kcalloc(sizeof(dma_addr_t), (1 << size), GFP_ATOMIC);
> +	if (!new_dma_addr_list) {
> +		if (pcnet32_debug & NETIF_MSG_DRV)
> +			printk("\n" KERN_ERR PFX
> +			       "%s: Memory allocation failed.\n", dev->name);
> +		goto free_new_tx_ring;
> +	}
> +
> +	new_skb_list = kcalloc(sizeof(struct sk_buff *), (1 << size), GFP_ATOMIC);
> +	if (!new_skb_list) {
> +		if (pcnet32_debug & NETIF_MSG_DRV)
> +			printk("\n" KERN_ERR PFX
> +			       "%s: Memory allocation failed.\n", dev->name);
> +		goto free_new_lists;
> +	}
> +
> +	kfree(lp->tx_skbuff);
> +	kfree(lp->tx_dma_addr);
> +	pci_free_consistent(lp->pci_dev,
> +			    sizeof(struct pcnet32_tx_head) *
> +			    lp->tx_ring_size, lp->tx_ring,
> +			    lp->tx_ring_dma_addr);
> +
> +	lp->tx_ring_size = (1 << size);
> +	lp->tx_mod_mask = lp->tx_ring_size - 1;
> +	lp->tx_len_bits = (size << 12);
> +	lp->tx_ring = new_tx_ring;
> +	lp->tx_ring_dma_addr = new_ring_dma_addr;
> +	lp->tx_dma_addr = new_dma_addr_list;
> +	lp->tx_skbuff = new_skb_list;
> +	return;
> +
> +    free_new_lists:
> +	kfree(new_dma_addr_list);
> +    free_new_tx_ring:
> +	pci_free_consistent(lp->pci_dev,
> +			    sizeof(struct pcnet32_tx_head) *
> +			    (1 << size),
> +			    new_tx_ring,
> +			    new_ring_dma_addr);
> +	return;
> +}
> +
> +/*
> + * Allocate space for the new sized rx ring.
> + * Re-use old receive buffers.
> + *   alloc extra buffers
> + *   free unneeded buffers
> + *   free unneeded buffers
> + * Save new resources.
> + * Any failure keeps old resources.
> + * Must be called with lp->lock held.
> + */
> +static void pcnet32_realloc_rx_ring(struct net_device *dev,
> +				    struct pcnet32_private *lp,
> +				    unsigned int size)
> +{
> +	dma_addr_t new_ring_dma_addr;
> +	dma_addr_t *new_dma_addr_list;
> +	struct pcnet32_rx_head *new_rx_ring;
> +	struct sk_buff **new_skb_list;
> +	int new, overlap;
> +
> +	new_rx_ring = pci_alloc_consistent(lp->pci_dev,
> +					   sizeof(struct pcnet32_rx_head) *
> +					   (1 << size),
> +					   &new_ring_dma_addr);
> +	if (new_rx_ring == NULL) {
> +		if (pcnet32_debug & NETIF_MSG_DRV)
> +			printk("\n" KERN_ERR PFX
> +			       "%s: Consistent memory allocation failed.\n",
> +			       dev->name);
> +		return;
> +	}
> +	memset(new_rx_ring, 0, sizeof(struct pcnet32_rx_head) * (1 << size));
> +
> +	new_dma_addr_list = kcalloc(sizeof(dma_addr_t), (1 << size), GFP_ATOMIC);
> +	if (!new_dma_addr_list) {
> +		if (pcnet32_debug & NETIF_MSG_DRV)
> +			printk("\n" KERN_ERR PFX
> +			       "%s: Memory allocation failed.\n", dev->name);
> +		goto free_new_rx_ring;
> +	}
> +
> +	new_skb_list = kcalloc(sizeof(struct sk_buff *), (1 << size), GFP_ATOMIC);
> +	if (!new_skb_list) {
> +		if (pcnet32_debug & NETIF_MSG_DRV)
> +			printk("\n" KERN_ERR PFX
> +			       "%s: Memory allocation failed.\n", dev->name);
> +		goto free_new_lists;
> +	}
> +
> +	/* first copy the current receive buffers */
> +	overlap = min(size, lp->rx_ring_size);
> +	for (new = 0; new < overlap; new++) {
> +		new_rx_ring[new] = lp->rx_ring[new];
> +		new_dma_addr_list[new] = lp->rx_dma_addr[new];
> +		new_skb_list[new] = lp->rx_skbuff[new];
> +	}
> +	/* now allocate any new buffers needed */
> +	for (; new < size; new++ ) {
> +		struct sk_buff *rx_skbuff;
> +		new_skb_list[new] = dev_alloc_skb(PKT_BUF_SZ);
> +		if (!(rx_skbuff = new_skb_list[new])) {
> +			/* keep the original lists and buffers */
> +			if (netif_msg_drv(lp))
> +				printk(KERN_ERR
> +				       "%s: pcnet32_realloc_rx_ring dev_alloc_skb failed.\n",
> +				       dev->name);
> +			goto free_all_new;
> +		}
> +		skb_reserve(rx_skbuff, 2);
> +
> +		new_dma_addr_list[new] =
> +			    pci_map_single(lp->pci_dev, rx_skbuff->data,
> +					   PKT_BUF_SZ - 2, PCI_DMA_FROMDEVICE);
> +		new_rx_ring[new].base = (u32) le32_to_cpu(new_dma_addr_list[new]);
> +		new_rx_ring[new].buf_length = le16_to_cpu(2 - PKT_BUF_SZ);
> +		new_rx_ring[new].status = le16_to_cpu(0x8000);
> +	}
> +	/* and free any unneeded buffers */
> +	for (; new < lp->rx_ring_size; new++) {
> +		if (lp->rx_skbuff[new]) {
> +			pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[new],
> +					 PKT_BUF_SZ - 2, PCI_DMA_FROMDEVICE);
> +			dev_kfree_skb(lp->rx_skbuff[new]);
> +		}
> +	}
> +
> +	kfree(lp->rx_skbuff);
> +	kfree(lp->rx_dma_addr);
> +	pci_free_consistent(lp->pci_dev,
> +			    sizeof(struct pcnet32_rx_head) *
> +			    lp->rx_ring_size, lp->rx_ring,
> +			    lp->rx_ring_dma_addr);
> +
> +	lp->rx_ring_size = (1 << size);
> +	lp->rx_mod_mask = lp->rx_ring_size - 1;
> +	lp->rx_len_bits = (size << 4);
> +	lp->rx_ring = new_rx_ring;
> +	lp->rx_ring_dma_addr = new_ring_dma_addr;
> +	lp->rx_dma_addr = new_dma_addr_list;
> +	lp->rx_skbuff = new_skb_list;
> +	return;
> +
> +    free_all_new:
> +	for (; --new >= lp->rx_ring_size; ) {
> +		if (new_skb_list[new]) {
> +			pci_unmap_single(lp->pci_dev, new_dma_addr_list[new],
> +					 PKT_BUF_SZ - 2, PCI_DMA_FROMDEVICE);
> +			dev_kfree_skb(new_skb_list[new]);
> +		}
> +	}
> +	kfree(new_skb_list);
> +    free_new_lists:
> +	kfree(new_dma_addr_list);
> +    free_new_rx_ring:
> +	pci_free_consistent(lp->pci_dev,
> +			    sizeof(struct pcnet32_rx_head) *
> +			    (1 << size),
> +			    new_rx_ring,
> +			    new_ring_dma_addr);
> +	return;
> +}
> +
> +static void pcnet32_purge_rx_ring(struct net_device *dev)
> +{
> +	struct pcnet32_private *lp = dev->priv;
> +	int i;
> +
> +	/* free all allocated skbuffs */
> +	for (i = 0; i < lp->rx_ring_size; i++) {
> +		lp->rx_ring[i].status = 0;	/* CPU owns buffer */
> +		wmb();		/* Make sure adapter sees owner change */
> +		if (lp->rx_skbuff[i]) {
> +			pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[i],
> +					 PKT_BUF_SZ - 2, PCI_DMA_FROMDEVICE);
> +			dev_kfree_skb_any(lp->rx_skbuff[i]);
> +		}
> +		lp->rx_skbuff[i] = NULL;
> +		lp->rx_dma_addr[i] = 0;
> +	}
> +}
> +
> +
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  static void pcnet32_poll_controller(struct net_device *dev)
>  {
> @@ -525,10 +758,10 @@ static void pcnet32_get_ringparam(struct
>  {
>  	struct pcnet32_private *lp = dev->priv;
>  
> -	ering->tx_max_pending = TX_MAX_RING_SIZE - 1;
> -	ering->tx_pending = lp->tx_ring_size - 1;
> -	ering->rx_max_pending = RX_MAX_RING_SIZE - 1;
> -	ering->rx_pending = lp->rx_ring_size - 1;
> +	ering->tx_max_pending = TX_MAX_RING_SIZE;
> +	ering->tx_pending = lp->tx_ring_size;
> +	ering->rx_max_pending = RX_MAX_RING_SIZE;
> +	ering->rx_pending = lp->rx_ring_size;
>  }
>  
>  static int pcnet32_set_ringparam(struct net_device *dev,
> @@ -536,44 +769,44 @@ static int pcnet32_set_ringparam(struct 
>  {
>  	struct pcnet32_private *lp = dev->priv;
>  	unsigned long flags;
> +	unsigned int size;
> +	ulong ioaddr = dev->base_addr;
>  	int i;
>  
>  	if (ering->rx_mini_pending || ering->rx_jumbo_pending)
>  		return -EINVAL;
>  
>  	if (netif_running(dev))
> -		pcnet32_close(dev);
> +		pcnet32_netif_stop(dev);
>  
>  	spin_lock_irqsave(&lp->lock, flags);
> -	pcnet32_free_ring(dev);
> -	lp->tx_ring_size =
> -	    min(ering->tx_pending, (unsigned int)TX_MAX_RING_SIZE);
> -	lp->rx_ring_size =
> -	    min(ering->rx_pending, (unsigned int)RX_MAX_RING_SIZE);
> +	lp->a.write_csr(ioaddr, 0, 0x0004);	/* stop the chip */
> +
> +	size = min(ering->tx_pending, (unsigned int)TX_MAX_RING_SIZE);
>  
>  	/* set the minimum ring size to 4, to allow the loopback test to work
>  	 * unchanged.
>  	 */
>  	for (i = 2; i <= PCNET32_LOG_MAX_TX_BUFFERS; i++) {
> -		if (lp->tx_ring_size <= (1 << i))
> +		if (size <= (1 << i))
>  			break;
>  	}
> -	lp->tx_ring_size = (1 << i);
> -	lp->tx_mod_mask = lp->tx_ring_size - 1;
> -	lp->tx_len_bits = (i << 12);
> -
> +	if ((1 << i) != lp->tx_ring_size)
> +		pcnet32_realloc_tx_ring(dev, lp, i);
> +	
> +	size = min(ering->rx_pending, (unsigned int)RX_MAX_RING_SIZE);
>  	for (i = 2; i <= PCNET32_LOG_MAX_RX_BUFFERS; i++) {
> -		if (lp->rx_ring_size <= (1 << i))
> +		if (size <= (1 << i))
>  			break;
>  	}
> -	lp->rx_ring_size = (1 << i);
> -	lp->rx_mod_mask = lp->rx_ring_size - 1;
> -	lp->rx_len_bits = (i << 4);
> +	if ((1 << i) != lp->rx_ring_size)
> +		pcnet32_realloc_rx_ring(dev, lp, i);
> +	
> +	dev->weight = lp->rx_ring_size / 2;
>  
> -	if (pcnet32_alloc_ring(dev, dev->name)) {
> -		pcnet32_free_ring(dev);
> -		spin_unlock_irqrestore(&lp->lock, flags);
> -		return -ENOMEM;
> +	if (netif_running(dev)) {
> +		pcnet32_netif_start(dev);
> +		pcnet32_restart(dev, 0x0042);
>  	}
>  
>  	spin_unlock_irqrestore(&lp->lock, flags);
> @@ -583,9 +816,6 @@ static int pcnet32_set_ringparam(struct 
>  		       "%s: Ring Param Settings: RX: %d, TX: %d\n", dev->name,
>  		       lp->rx_ring_size, lp->tx_ring_size);
>  
> -	if (netif_running(dev))
> -		pcnet32_open(dev);
> -
>  	return 0;
>  }
>  
> @@ -639,25 +869,27 @@ static int pcnet32_loopback_test(struct 
>  	unsigned long flags;
>  	unsigned long ticks;
>  
> -	*data1 = 1;		/* status of test, default to fail */
>  	rc = 1;			/* default to fail */
>  
>  	if (netif_running(dev))
> +#ifdef CONFIG_PCNET32_NAPI
> +		pcnet32_netif_stop(dev);
> +#else
>  		pcnet32_close(dev);
> +#endif
>  
>  	spin_lock_irqsave(&lp->lock, flags);
> +	lp->a.write_csr(ioaddr, 0, 0x0004);	/* stop the chip */
> +
> +	numbuffs = min(numbuffs, (int)min(lp->rx_ring_size, lp->tx_ring_size));
>  
>  	/* Reset the PCNET32 */
>  	lp->a.reset(ioaddr);
> +	lp->a.write_csr(ioaddr, 4, 0x0915);
>  
>  	/* switch pcnet32 to 32bit mode */
>  	lp->a.write_bcr(ioaddr, 20, 2);
>  
> -	lp->init_block.mode =
> -	    le16_to_cpu((lp->options & PCNET32_PORT_PORTSEL) << 7);
> -	lp->init_block.filter[0] = 0;
> -	lp->init_block.filter[1] = 0;
> -
>  	/* purge & init rings but don't actually restart */
>  	pcnet32_restart(dev, 0x0000);
>  
> @@ -704,10 +936,10 @@ static int pcnet32_loopback_test(struct 
>  	}
>  
>  	x = a->read_bcr(ioaddr, 32);	/* set internal loopback in BSR32 */
> -	x = x | 0x0002;
> -	a->write_bcr(ioaddr, 32, x);
> +	a->write_bcr(ioaddr, 32, x | 0x0002);
>  
> -	lp->a.write_csr(ioaddr, 15, 0x0044);	/* set int loopback in CSR15 */
> +	x = a->read_csr(ioaddr, 15);	/* set int loopback in CSR15 */
> +	lp->a.write_csr(ioaddr, 15, x | 0x0044);
>  
>  	teststatus = le16_to_cpu(0x8000);
>  	lp->a.write_csr(ioaddr, 0, 0x0002);	/* Set STRT bit */
> @@ -764,25 +996,30 @@ static int pcnet32_loopback_test(struct 
>  		}
>  		x++;
>  	}
> -	if (!rc) {
> -		*data1 = 0;
> -	}
>  
>        clean_up:
> +	*data1 = rc;
>  	pcnet32_purge_tx_ring(dev);
> +
>  	x = a->read_csr(ioaddr, 15) & 0xFFFF;
>  	a->write_csr(ioaddr, 15, (x & ~0x0044));	/* reset bits 6 and 2 */
>  
>  	x = a->read_bcr(ioaddr, 32);	/* reset internal loopback */
> -	x = x & ~0x0002;
> -	a->write_bcr(ioaddr, 32, x);
> -
> -	spin_unlock_irqrestore(&lp->lock, flags);
> +	a->write_bcr(ioaddr, 32, (x & ~0x0002));
>  
>  	if (netif_running(dev)) {
> +#ifdef CONFIG_PCNET32_NAPI
> +		pcnet32_netif_start(dev);
> +		pcnet32_restart(dev, 0x0042);
> +		spin_unlock_irqrestore(&lp->lock, flags); 
> +#else
> +		spin_unlock_irqrestore(&lp->lock, flags);
>  		pcnet32_open(dev);
> +#endif
>  	} else {
> +		pcnet32_purge_rx_ring(dev);
>  		lp->a.write_bcr(ioaddr, 20, 4);	/* return to 16bit mode */
> +		spin_unlock_irqrestore(&lp->lock, flags); 
>  	}
>  
>  	return (rc);
> @@ -845,6 +1082,39 @@ static int pcnet32_phys_id(struct net_de
>  	return 0;
>  }
>  
> +/*
> + * lp->lock must be held.
> + */
> +static int pcnet32_suspend(struct net_device *dev, unsigned long *flags)
> +{
> +	int csr5;
> +	struct pcnet32_private *lp = dev->priv;
> +	struct pcnet32_access *a = &lp->a;
> +	ulong ioaddr = dev->base_addr;
> +	int ticks;
> +
> +	/* set SUSPEND (SPND) - CSR5 bit 0 */
> +	csr5 = a->read_csr(ioaddr, 5);
> +	a->write_csr(ioaddr, 5, csr5 | 0x0001);
> +
> +	/* poll waiting for bit to be set */
> +	ticks = 0;
> +	while (!(a->read_csr(ioaddr, 5) & 0x0001)) {
> +		spin_unlock_irqrestore(&lp->lock, *flags);
> +		mdelay(1);
> +		spin_lock_irqsave(&lp->lock, *flags);
> +		ticks++;
> +		if (ticks > 200) {
> +			if (netif_msg_hw(lp))
> +				printk(KERN_DEBUG
> +				       "%s: Error getting into suspend!\n",
> +				       dev->name);
> +			return 0;
> +		}
> +	}
> +	return 1;
> +}
> +
>  #define PCNET32_REGS_PER_PHY	32
>  #define PCNET32_MAX_PHYS	32
>  static int pcnet32_get_regs_len(struct net_device *dev)
> @@ -863,31 +1133,17 @@ static void pcnet32_get_regs(struct net_
>  	struct pcnet32_private *lp = dev->priv;
>  	struct pcnet32_access *a = &lp->a;
>  	ulong ioaddr = dev->base_addr;
> -	int ticks;
>  	unsigned long flags;
>  
>  	spin_lock_irqsave(&lp->lock, flags);
>  
>  	csr0 = a->read_csr(ioaddr, 0);
>  	if (!(csr0 & 0x0004)) {	/* If not stopped */
> -		/* set SUSPEND (SPND) - CSR5 bit 0 */
> -		a->write_csr(ioaddr, 5, 0x0001);
> -
> -		/* poll waiting for bit to be set */
> -		ticks = 0;
> -		while (!(a->read_csr(ioaddr, 5) & 0x0001)) {
> -			spin_unlock_irqrestore(&lp->lock, flags);
> -			mdelay(1);
> -			spin_lock_irqsave(&lp->lock, flags);
> -			ticks++;
> -			if (ticks > 200) {
> -				if (netif_msg_hw(lp))
> -					printk(KERN_DEBUG
> -					       "%s: Error getting into suspend!\n",
> -					       dev->name);
> -				break;
> -			}
> -		}
> +		if (!pcnet32_suspend(dev, &flags))
> +			if (netif_msg_hw(lp))
> +				printk(KERN_DEBUG
> +				       "%s: Error getting into suspend!\n",
> +				       dev->name);
>  	}
>  
>  	/* read address PROM */
> @@ -926,8 +1182,11 @@ static void pcnet32_get_regs(struct net_
>  	}
>  
>  	if (!(csr0 & 0x0004)) {	/* If not stopped */
> +		int csr5;
> +
>  		/* clear SUSPEND (SPND) - CSR5 bit 0 */
> -		a->write_csr(ioaddr, 5, 0x0000);
> +		csr5 = a->read_csr(ioaddr, 5);
> +		a->write_csr(ioaddr, 5, csr5 & (~0x0001));
>  	}
>  
>  	spin_unlock_irqrestore(&lp->lock, flags);
> @@ -958,7 +1217,7 @@ static struct ethtool_ops pcnet32_ethtoo
>  /* only probes for non-PCI devices, the rest are handled by
>   * pci_register_driver via pcnet32_probe_pci */
>  
> -static void __devinit pcnet32_probe_vlbus(void)
> +static void __devinit pcnet32_probe_vlbus(unsigned int *pcnet32_portlist)
>  {
>  	unsigned int *port, ioaddr;
>  
> @@ -1396,6 +1655,10 @@ pcnet32_probe1(unsigned long ioaddr, int
>  	dev->ethtool_ops = &pcnet32_ethtool_ops;
>  	dev->tx_timeout = pcnet32_tx_timeout;
>  	dev->watchdog_timeo = (5 * HZ);
> +	dev->weight = lp->rx_ring_size / 2;
> +#ifdef CONFIG_PCNET32_NAPI
> +	dev->poll = pcnet32_poll;
> +#endif
>  
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	dev->poll_controller = pcnet32_poll_controller;
> @@ -1763,16 +2026,7 @@ static int pcnet32_open(struct net_devic
>  
>        err_free_ring:
>  	/* free any allocated skbuffs */
> -	for (i = 0; i < lp->rx_ring_size; i++) {
> -		lp->rx_ring[i].status = 0;
> -		if (lp->rx_skbuff[i]) {
> -			pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[i],
> -					 PKT_BUF_SZ - 2, PCI_DMA_FROMDEVICE);
> -			dev_kfree_skb(lp->rx_skbuff[i]);
> -		}
> -		lp->rx_skbuff[i] = NULL;
> -		lp->rx_dma_addr[i] = 0;
> -	}
> +	pcnet32_purge_rx_ring(dev);
>  
>  	/*
>  	 * Switch back to 16bit mode to avoid problems with dumb
> @@ -2004,6 +2258,286 @@ static int pcnet32_start_xmit(struct sk_
>  	return 0;
>  }
>  
> +static int pcnet32_rx_entry(struct net_device *dev,
> +			    struct pcnet32_private *lp,
> +			    struct pcnet32_rx_head *rxp,
> +			    int entry)
> +{
> +	int status = (short)le16_to_cpu(rxp->status) >> 8;
> +	int rx_in_place = 0;
> +	struct sk_buff *skb;
> +	short pkt_len;
> +
> +	if (status != 0x03) {	/* There was an error. */
> +		/*
> +		 * There is a tricky error noted by John Murphy,
> +		 * <murf@perftech.com> to Russ Nelson: Even with full-sized
> +		 * buffers it's possible for a jabber packet to use two
> +		 * buffers, with only the last correctly noting the error.
> +		 */
> +		if (status & 0x01)	/* Only count a general error at the */
> +			lp->stats.rx_errors++;	/* end of a packet. */
> +		if (status & 0x20)
> +			lp->stats.rx_frame_errors++;
> +		if (status & 0x10)
> +			lp->stats.rx_over_errors++;
> +		if (status & 0x08)
> +			lp->stats.rx_crc_errors++;
> +		if (status & 0x04)
> +			lp->stats.rx_fifo_errors++;
> +		return 1;
> +	}
> +
> +	pkt_len = (le32_to_cpu(rxp->msg_length) & 0xfff) - 4;
> +
> +	/* Discard oversize frames. */
> +	if (unlikely(pkt_len > PKT_BUF_SZ - 2)) {
> +		if (netif_msg_drv(lp))
> +			printk(KERN_ERR "%s: Impossible packet size %d!\n",
> +			       dev->name, pkt_len);
> +		lp->stats.rx_errors++;
> +		return 1;
> +	}
> +	if (pkt_len < 60) {
> +		if (netif_msg_rx_err(lp))
> +			printk(KERN_ERR "%s: Runt packet!\n", dev->name);
> +		lp->stats.rx_errors++;
> +		return 1;
> +	}
> +
> +	if (pkt_len > rx_copybreak) {
> +		struct sk_buff *newskb;
> +
> +		if ((newskb = dev_alloc_skb(PKT_BUF_SZ))) {
> +			skb_reserve(newskb, 2);
> +			skb = lp->rx_skbuff[entry];
> +			pci_unmap_single(lp->pci_dev,
> +					 lp->rx_dma_addr[entry],
> +					 PKT_BUF_SZ - 2,
> +					 PCI_DMA_FROMDEVICE);
> +			skb_put(skb, pkt_len);
> +			lp->rx_skbuff[entry] = newskb;
> +			newskb->dev = dev;
> +			lp->rx_dma_addr[entry] =
> +			    pci_map_single(lp->pci_dev,
> +					   newskb->data,
> +					   PKT_BUF_SZ - 2,
> +					   PCI_DMA_FROMDEVICE);
> +			rxp->base = le32_to_cpu(lp->rx_dma_addr[entry]);
> +			rx_in_place = 1;
> +		} else
> +			skb = NULL;
> +	} else {
> +		skb = dev_alloc_skb(pkt_len + 2);
> +	}
> +
> +	if (skb == NULL) {
> +		if (netif_msg_drv(lp))
> +			printk(KERN_ERR
> +			       "%s: Memory squeeze, dropping packet.\n",
> +			       dev->name);
> +		lp->stats.rx_dropped++;
> +		return 1;
> +	}
> +	skb->dev = dev;
> +	if (!rx_in_place) {
> +		skb_reserve(skb, 2);	/* 16 byte align */
> +		skb_put(skb, pkt_len);	/* Make room */
> +		pci_dma_sync_single_for_cpu(lp->pci_dev,
> +					    lp->rx_dma_addr[entry],
> +					    PKT_BUF_SZ - 2,
> +					    PCI_DMA_FROMDEVICE);
> +		eth_copy_and_sum(skb,
> +				 (unsigned char *)(lp->rx_skbuff[entry]->data),
> +				 pkt_len, 0);
> +		pci_dma_sync_single_for_device(lp->pci_dev,
> +					       lp->rx_dma_addr[entry],
> +					       PKT_BUF_SZ - 2,
> +					       PCI_DMA_FROMDEVICE);
> +	}
> +	lp->stats.rx_bytes += skb->len;
> +	lp->stats.rx_packets++;
> +	skb->protocol = eth_type_trans(skb, dev);
> +#ifdef CONFIG_PCNET32_NAPI
> +	netif_receive_skb(skb);
> +#else
> +	netif_rx(skb);
> +#endif
> +	dev->last_rx = jiffies;
> +	return 1;
> +}
> +
> +static int pcnet32_rx(struct net_device *dev, int quota)
> +{
> +	struct pcnet32_private *lp = dev->priv;
> +	int entry = lp->cur_rx & lp->rx_mod_mask;
> +	struct pcnet32_rx_head *rxp = &lp->rx_ring[entry];
> +	int npackets = 0;
> +
> +	/* If we own the next entry, it's a new packet. Send it up. */
> +	while (quota > npackets && (short)le16_to_cpu(rxp->status) >= 0) {
> +		npackets += pcnet32_rx_entry(dev, lp, rxp, entry);
> +//printk("DONF:  %s npackets=%d\n", dev->name, npackets);

Should that be in the patch?

> +		/*
> +		 * The docs say that the buffer length isn't touched, but Andrew
> +		 * Boyd of QNX reports that some revs of the 79C965 clear it.
> +		 */
> +		rxp->buf_length = le16_to_cpu(2 - PKT_BUF_SZ);
> +		wmb();	/* Make sure owner changes after others are visible */
> +		rxp->status = le16_to_cpu(0x8000);
> +		entry = (++lp->cur_rx) & lp->rx_mod_mask;
> +		rxp = &lp->rx_ring[entry];
> +	}
> +
> +	return npackets;
> +}
> +
> +static int pcnet32_tx(struct net_device *dev)
> +{
> +	struct pcnet32_private *lp = dev->priv;
> +	unsigned int dirty_tx = lp->dirty_tx;
> +	int delta;
> +	int must_restart = 0;
> +
> +	while (dirty_tx != lp->cur_tx) {
> +		int entry = dirty_tx & lp->tx_mod_mask;
> +		int status = (short)le16_to_cpu(lp->tx_ring[entry].status);
> +
> +		if (status < 0)
> +			break;	/* It still hasn't been Txed */
> +
> +		lp->tx_ring[entry].base = 0;
> +
> +		if (status & 0x4000) {
> +			/* There was an major error, log it. */
> +			int err_status =
> +			    le32_to_cpu(lp->tx_ring[entry].
> +					misc);
> +			lp->stats.tx_errors++;
> +			if (netif_msg_tx_err(lp))
> +				printk(KERN_ERR
> +				       "%s: Tx error status=%04x err_status=%08x\n",
> +				       dev->name, status,
> +				       err_status);
> +			if (err_status & 0x04000000)
> +				lp->stats.tx_aborted_errors++;
> +			if (err_status & 0x08000000)
> +				lp->stats.tx_carrier_errors++;
> +			if (err_status & 0x10000000)
> +				lp->stats.tx_window_errors++;
> +#ifndef DO_DXSUFLO
> +			if (err_status & 0x40000000) {
> +				lp->stats.tx_fifo_errors++;
> +				/* Ackk!  On FIFO errors the Tx unit is turned off! */
> +				/* Remove this verbosity later! */
> +				if (netif_msg_tx_err(lp))
> +					printk(KERN_ERR
> +					       "%s: Tx FIFO error!\n",
> +						dev->name);
> +				must_restart = 1;
> +			}
> +#else
> +			if (err_status & 0x40000000) {
> +				lp->stats.tx_fifo_errors++;
> +				if (!lp->dxsuflo) {	/* If controller doesn't recover ... */
> +					/* Ackk!  On FIFO errors the Tx unit is turned off! */
> +					/* Remove this verbosity later! */
> +					if (netif_msg_tx_err(lp))
> +						printk(KERN_ERR
> +						       "%s: Tx FIFO error!\n",
> +						       dev->name);
> +					must_restart = 1;
> +				}
> +			}
> +#endif
> +		} else {
> +			if (status & 0x1800)
> +				lp->stats.collisions++;
> +			lp->stats.tx_packets++;
> +		}
> +
> +		/* We must free the original skb */
> +		if (lp->tx_skbuff[entry]) {
> +			pci_unmap_single(lp->pci_dev,
> +					 lp->tx_dma_addr[entry],
> +					 lp->tx_skbuff[entry]->
> +					 len, PCI_DMA_TODEVICE);
> +			dev_kfree_skb_any(lp->tx_skbuff[entry]);
> +			lp->tx_skbuff[entry] = NULL;
> +			lp->tx_dma_addr[entry] = 0;
> +		}
> +		dirty_tx++;
> +	}
> +
> +	delta = (lp->cur_tx - dirty_tx) & (lp->tx_mod_mask + lp->tx_ring_size);
> +	if (delta > lp->tx_ring_size) {
> +		if (netif_msg_drv(lp))
> +			printk(KERN_ERR
> +			       "%s: out-of-sync dirty pointer, %d vs. %d, full=%d.\n",
> +			       dev->name, dirty_tx, lp->cur_tx,
> +			       lp->tx_full);
> +		dirty_tx += lp->tx_ring_size;
> +		delta -= lp->tx_ring_size;
> +	}
> +
> +	if (lp->tx_full &&
> +	    netif_queue_stopped(dev) &&
> +	    delta < lp->tx_ring_size - 2) {
> +		/* The ring is no longer full, clear tbusy. */
> +		lp->tx_full = 0;
> +		netif_wake_queue(dev);
> +	}
> +	lp->dirty_tx = dirty_tx;
> +
> +	return must_restart;
> +}
> +
> +#ifdef CONFIG_PCNET32_NAPI
> +static int pcnet32_poll(struct net_device *dev, int *budget)
> +{
> +	struct pcnet32_private *lp = dev->priv;
> +	int quota = min(dev->quota, *budget);
> +	unsigned long ioaddr = dev->base_addr;
> +	u16 val;
> +	unsigned long flags;
> +
> +	quota = pcnet32_rx(dev, quota);
> +
> +	spin_lock_irqsave(&lp->lock, flags);
> +	if (pcnet32_tx(dev)) {
> +		/* reset the chip to clear the error condition, then restart */
> +		lp->a.reset(ioaddr);
> +		lp->a.write_csr(ioaddr, 4, 0x0915);
> +		pcnet32_restart(dev, 0x0002);
> +		netif_wake_queue(dev);
> +	}
> +	spin_unlock_irqrestore(&lp->lock, flags);
> +
> +	*budget -= quota;
> +	dev->quota -= quota;
> +
> +	if (dev->quota == 0) {
> +		return 1;
> +	}
> +
> +	netif_rx_complete(dev);
> +
> +	spin_lock_irqsave(&lp->lock, flags);
> +
> +	/* clear interrupt masks */
> +	val = lp->a.read_csr(ioaddr, 3);
> +	val &= 0x00ff;
> +	lp->a.write_csr(ioaddr, 3, val);
> +
> +	/* Set interrupt enable. */
> +	lp->a.write_csr(ioaddr, 0, 0x0040);
> +
> +	spin_unlock_irqrestore(&lp->lock, flags);
> +
> +	return 0;
> +}
> +#endif
> +
>  /* The PCNET32 interrupt handler. */
>  static irqreturn_t
>  pcnet32_interrupt(int irq, void *dev_id, struct pt_regs *regs)
> @@ -2011,9 +2545,9 @@ pcnet32_interrupt(int irq, void *dev_id,
>  	struct net_device *dev = dev_id;
>  	struct pcnet32_private *lp;
>  	unsigned long ioaddr;
> -	u16 csr0, rap;
>  	int boguscnt = max_interrupt_work;
> -	int must_restart;
> +	u16 csr0;
> +	irqreturn_t rc = IRQ_HANDLED;
>  
>  	if (!dev) {
>  		if (pcnet32_debug & NETIF_MSG_INTR)
> @@ -2027,141 +2561,33 @@ pcnet32_interrupt(int irq, void *dev_id,
>  
>  	spin_lock(&lp->lock);
>  
> -	rap = lp->a.read_rap(ioaddr);
> -	while ((csr0 = lp->a.read_csr(ioaddr, 0)) & 0x8f00 && --boguscnt >= 0) {
> -		if (csr0 == 0xffff) {
> -			break;	/* PCMCIA remove happened */
> -		}
> +	csr0 = lp->a.read_csr(ioaddr, 0);
> +	if (csr0 == 0xffff) {
> +		rc = IRQ_NONE;
> +	} else while (csr0 & 0x8f00 && --boguscnt >= 0) {
>  		/* Acknowledge all of the current interrupt sources ASAP. */
>  		lp->a.write_csr(ioaddr, 0, csr0 & ~0x004f);
>  
> -		must_restart = 0;
> -
>  		if (netif_msg_intr(lp))
>  			printk(KERN_DEBUG
>  			       "%s: interrupt  csr0=%#2.2x new csr=%#2.2x.\n",
>  			       dev->name, csr0, lp->a.read_csr(ioaddr, 0));
>  
> -		if (csr0 & 0x0400)	/* Rx interrupt */
> -			pcnet32_rx(dev);
> -
> -		if (csr0 & 0x0200) {	/* Tx-done interrupt */
> -			unsigned int dirty_tx = lp->dirty_tx;
> -			int delta;
> -
> -			while (dirty_tx != lp->cur_tx) {
> -				int entry = dirty_tx & lp->tx_mod_mask;
> -				int status =
> -				    (short)le16_to_cpu(lp->tx_ring[entry].
> -						       status);
> -
> -				if (status < 0)
> -					break;	/* It still hasn't been Txed */
> -
> -				lp->tx_ring[entry].base = 0;
> -
> -				if (status & 0x4000) {
> -					/* There was an major error, log it. */
> -					int err_status =
> -					    le32_to_cpu(lp->tx_ring[entry].
> -							misc);
> -					lp->stats.tx_errors++;
> -					if (netif_msg_tx_err(lp))
> -						printk(KERN_ERR
> -						       "%s: Tx error status=%04x err_status=%08x\n",
> -						       dev->name, status,
> -						       err_status);
> -					if (err_status & 0x04000000)
> -						lp->stats.tx_aborted_errors++;
> -					if (err_status & 0x08000000)
> -						lp->stats.tx_carrier_errors++;
> -					if (err_status & 0x10000000)
> -						lp->stats.tx_window_errors++;
> -#ifndef DO_DXSUFLO
> -					if (err_status & 0x40000000) {
> -						lp->stats.tx_fifo_errors++;
> -						/* Ackk!  On FIFO errors the Tx unit is turned off! */
> -						/* Remove this verbosity later! */
> -						if (netif_msg_tx_err(lp))
> -							printk(KERN_ERR
> -							       "%s: Tx FIFO error! CSR0=%4.4x\n",
> -							       dev->name, csr0);
> -						must_restart = 1;
> -					}
> -#else
> -					if (err_status & 0x40000000) {
> -						lp->stats.tx_fifo_errors++;
> -						if (!lp->dxsuflo) {	/* If controller doesn't recover ... */
> -							/* Ackk!  On FIFO errors the Tx unit is turned off! */
> -							/* Remove this verbosity later! */
> -							if (netif_msg_tx_err
> -							    (lp))
> -								printk(KERN_ERR
> -								       "%s: Tx FIFO error! CSR0=%4.4x\n",
> -								       dev->
> -								       name,
> -								       csr0);
> -							must_restart = 1;
> -						}
> -					}
> -#endif
> -				} else {
> -					if (status & 0x1800)
> -						lp->stats.collisions++;
> -					lp->stats.tx_packets++;
> -				}
> -
> -				/* We must free the original skb */
> -				if (lp->tx_skbuff[entry]) {
> -					pci_unmap_single(lp->pci_dev,
> -							 lp->tx_dma_addr[entry],
> -							 lp->tx_skbuff[entry]->
> -							 len, PCI_DMA_TODEVICE);
> -					dev_kfree_skb_irq(lp->tx_skbuff[entry]);
> -					lp->tx_skbuff[entry] = NULL;
> -					lp->tx_dma_addr[entry] = 0;
> -				}
> -				dirty_tx++;
> -			}
> -
> -			delta =
> -			    (lp->cur_tx - dirty_tx) & (lp->tx_mod_mask +
> -						       lp->tx_ring_size);
> -			if (delta > lp->tx_ring_size) {
> -				if (netif_msg_drv(lp))
> -					printk(KERN_ERR
> -					       "%s: out-of-sync dirty pointer, %d vs. %d, full=%d.\n",
> -					       dev->name, dirty_tx, lp->cur_tx,
> -					       lp->tx_full);
> -				dirty_tx += lp->tx_ring_size;
> -				delta -= lp->tx_ring_size;
> -			}
> -
> -			if (lp->tx_full &&
> -			    netif_queue_stopped(dev) &&
> -			    delta < lp->tx_ring_size - 2) {
> -				/* The ring is no longer full, clear tbusy. */
> -				lp->tx_full = 0;
> -				netif_wake_queue(dev);
> -			}
> -			lp->dirty_tx = dirty_tx;
> -		}
> -
>  		/* Log misc errors. */
>  		if (csr0 & 0x4000)
>  			lp->stats.tx_errors++;	/* Tx babble. */
>  		if (csr0 & 0x1000) {
>  			/*
> -			 * this happens when our receive ring is full. This shouldn't
> -			 * be a problem as we will see normal rx interrupts for the frames
> -			 * in the receive ring. But there are some PCI chipsets (I can
> -			 * reproduce this on SP3G with Intel saturn chipset) which have
> -			 * sometimes problems and will fill up the receive ring with
> -			 * error descriptors. In this situation we don't get a rx
> -			 * interrupt, but a missed frame interrupt sooner or later.
> -			 * So we try to clean up our receive ring here.
> +			 * This happens when our receive ring is full. This
> +			 * shouldn't be a problem as we will see normal rx
> +			 * interrupts for the frames in the receive ring. But
> +			 * there are some PCI chipsets (I can reproduce this
> +			 * on SP3G with Intel saturn chipset) which have
> +			 * sometimes problems and will fill up the receive
> +			 * ring with error descriptors. In this situation we
> +			 * don't get a rx interrupt, but a missed frame
> +			 * interrupt sooner or later.
>  			 */
> -			pcnet32_rx(dev);
>  			lp->stats.rx_errors++;	/* Missed a Rx frame. */
>  		}
>  		if (csr0 & 0x0800) {
> @@ -2171,19 +2597,34 @@ pcnet32_interrupt(int irq, void *dev_id,
>  				       dev->name, csr0);
>  			/* unlike for the lance, there is no restart needed */
>  		}
> -
> -		if (must_restart) {
> +#ifdef CONFIG_PCNET32_NAPI
> +		if (netif_rx_schedule_prep(dev)) {
> +			u16 val;
> +			/* set interrupt masks */
> +			val = lp->a.read_csr(ioaddr, 3);
> +			val |= 0x5f00;
> +			lp->a.write_csr(ioaddr, 3, val);
> +			__netif_rx_schedule(dev);
> +			break;
> +		}
> +#else
> +//printk("DONF:  %s: weight is %d\n", dev->name, dev->weight);

And the same thing here?

> +		pcnet32_rx(dev, dev->weight);
> +		if (pcnet32_tx(dev)) {
>  			/* reset the chip to clear the error condition, then restart */
>  			lp->a.reset(ioaddr);
>  			lp->a.write_csr(ioaddr, 4, 0x0915);
>  			pcnet32_restart(dev, 0x0002);
>  			netif_wake_queue(dev);
>  		}
> +#endif
> +		csr0 = lp->a.read_csr(ioaddr, 0);
>  	}
>  
> -	/* Set interrupt enable. */
> +#ifndef CONFIG_PCNET32_NAPI
> +	/*Set interrupt enable. */
>  	lp->a.write_csr(ioaddr, 0, 0x0040);
> -	lp->a.write_rap(ioaddr, rap);
> +#endif
>  
>  	if (netif_msg_intr(lp))
>  		printk(KERN_DEBUG "%s: exiting interrupt, csr0=%#4.4x.\n",
> @@ -2191,170 +2632,13 @@ pcnet32_interrupt(int irq, void *dev_id,
>  
>  	spin_unlock(&lp->lock);
>  
> -	return IRQ_HANDLED;
> -}
> -
> -static int pcnet32_rx(struct net_device *dev)
> -{
> -	struct pcnet32_private *lp = dev->priv;
> -	int entry = lp->cur_rx & lp->rx_mod_mask;
> -	int boguscnt = lp->rx_ring_size / 2;
> -
> -	/* If we own the next entry, it's a new packet. Send it up. */
> -	while ((short)le16_to_cpu(lp->rx_ring[entry].status) >= 0) {
> -		int status = (short)le16_to_cpu(lp->rx_ring[entry].status) >> 8;
> -
> -		if (status != 0x03) {	/* There was an error. */
> -			/*
> -			 * There is a tricky error noted by John Murphy,
> -			 * <murf@perftech.com> to Russ Nelson: Even with full-sized
> -			 * buffers it's possible for a jabber packet to use two
> -			 * buffers, with only the last correctly noting the error.
> -			 */
> -			if (status & 0x01)	/* Only count a general error at the */
> -				lp->stats.rx_errors++;	/* end of a packet. */
> -			if (status & 0x20)
> -				lp->stats.rx_frame_errors++;
> -			if (status & 0x10)
> -				lp->stats.rx_over_errors++;
> -			if (status & 0x08)
> -				lp->stats.rx_crc_errors++;
> -			if (status & 0x04)
> -				lp->stats.rx_fifo_errors++;
> -			lp->rx_ring[entry].status &= le16_to_cpu(0x03ff);
> -		} else {
> -			/* Malloc up new buffer, compatible with net-2e. */
> -			short pkt_len =
> -			    (le32_to_cpu(lp->rx_ring[entry].msg_length) & 0xfff)
> -			    - 4;
> -			struct sk_buff *skb;
> -
> -			/* Discard oversize frames. */
> -			if (unlikely(pkt_len > PKT_BUF_SZ - 2)) {
> -				if (netif_msg_drv(lp))
> -					printk(KERN_ERR
> -					       "%s: Impossible packet size %d!\n",
> -					       dev->name, pkt_len);
> -				lp->stats.rx_errors++;
> -			} else if (pkt_len < 60) {
> -				if (netif_msg_rx_err(lp))
> -					printk(KERN_ERR "%s: Runt packet!\n",
> -					       dev->name);
> -				lp->stats.rx_errors++;
> -			} else {
> -				int rx_in_place = 0;
> -
> -				if (pkt_len > rx_copybreak) {
> -					struct sk_buff *newskb;
> -
> -					if ((newskb =
> -					     dev_alloc_skb(PKT_BUF_SZ))) {
> -						skb_reserve(newskb, 2);
> -						skb = lp->rx_skbuff[entry];
> -						pci_unmap_single(lp->pci_dev,
> -								 lp->
> -								 rx_dma_addr
> -								 [entry],
> -								 PKT_BUF_SZ - 2,
> -								 PCI_DMA_FROMDEVICE);
> -						skb_put(skb, pkt_len);
> -						lp->rx_skbuff[entry] = newskb;
> -						newskb->dev = dev;
> -						lp->rx_dma_addr[entry] =
> -						    pci_map_single(lp->pci_dev,
> -								   newskb->data,
> -								   PKT_BUF_SZ -
> -								   2,
> -								   PCI_DMA_FROMDEVICE);
> -						lp->rx_ring[entry].base =
> -						    le32_to_cpu(lp->
> -								rx_dma_addr
> -								[entry]);
> -						rx_in_place = 1;
> -					} else
> -						skb = NULL;
> -				} else {
> -					skb = dev_alloc_skb(pkt_len + 2);
> -				}
> -
> -				if (skb == NULL) {
> -					int i;
> -					if (netif_msg_drv(lp))
> -						printk(KERN_ERR
> -						       "%s: Memory squeeze, deferring packet.\n",
> -						       dev->name);
> -					for (i = 0; i < lp->rx_ring_size; i++)
> -						if ((short)
> -						    le16_to_cpu(lp->
> -								rx_ring[(entry +
> -									 i)
> -									& lp->
> -									rx_mod_mask].
> -								status) < 0)
> -							break;
> -
> -					if (i > lp->rx_ring_size - 2) {
> -						lp->stats.rx_dropped++;
> -						lp->rx_ring[entry].status |=
> -						    le16_to_cpu(0x8000);
> -						wmb();	/* Make sure adapter sees owner change */
> -						lp->cur_rx++;
> -					}
> -					break;
> -				}
> -				skb->dev = dev;
> -				if (!rx_in_place) {
> -					skb_reserve(skb, 2);	/* 16 byte align */
> -					skb_put(skb, pkt_len);	/* Make room */
> -					pci_dma_sync_single_for_cpu(lp->pci_dev,
> -								    lp->
> -								    rx_dma_addr
> -								    [entry],
> -								    PKT_BUF_SZ -
> -								    2,
> -								    PCI_DMA_FROMDEVICE);
> -					eth_copy_and_sum(skb,
> -							 (unsigned char *)(lp->
> -									   rx_skbuff
> -									   [entry]->
> -									   data),
> -							 pkt_len, 0);
> -					pci_dma_sync_single_for_device(lp->
> -								       pci_dev,
> -								       lp->
> -								       rx_dma_addr
> -								       [entry],
> -								       PKT_BUF_SZ
> -								       - 2,
> -								       PCI_DMA_FROMDEVICE);
> -				}
> -				lp->stats.rx_bytes += skb->len;
> -				skb->protocol = eth_type_trans(skb, dev);
> -				netif_rx(skb);
> -				dev->last_rx = jiffies;
> -				lp->stats.rx_packets++;
> -			}
> -		}
> -		/*
> -		 * The docs say that the buffer length isn't touched, but Andrew Boyd
> -		 * of QNX reports that some revs of the 79C965 clear it.
> -		 */
> -		lp->rx_ring[entry].buf_length = le16_to_cpu(2 - PKT_BUF_SZ);
> -		wmb();		/* Make sure owner changes after all others are visible */
> -		lp->rx_ring[entry].status |= le16_to_cpu(0x8000);
> -		entry = (++lp->cur_rx) & lp->rx_mod_mask;
> -		if (--boguscnt <= 0)
> -			break;	/* don't stay in loop forever */
> -	}
> -
> -	return 0;
> +	return rc;
>  }
>  
>  static int pcnet32_close(struct net_device *dev)
>  {
>  	unsigned long ioaddr = dev->base_addr;
>  	struct pcnet32_private *lp = dev->priv;
> -	int i;
>  	unsigned long flags;
>  
>  	del_timer_sync(&lp->watchdog_timer);
> @@ -2385,31 +2669,8 @@ static int pcnet32_close(struct net_devi
>  
>  	spin_lock_irqsave(&lp->lock, flags);
>  
> -	/* free all allocated skbuffs */
> -	for (i = 0; i < lp->rx_ring_size; i++) {
> -		lp->rx_ring[i].status = 0;
> -		wmb();		/* Make sure adapter sees owner change */
> -		if (lp->rx_skbuff[i]) {
> -			pci_unmap_single(lp->pci_dev, lp->rx_dma_addr[i],
> -					 PKT_BUF_SZ - 2, PCI_DMA_FROMDEVICE);
> -			dev_kfree_skb(lp->rx_skbuff[i]);
> -		}
> -		lp->rx_skbuff[i] = NULL;
> -		lp->rx_dma_addr[i] = 0;
> -	}
> -
> -	for (i = 0; i < lp->tx_ring_size; i++) {
> -		lp->tx_ring[i].status = 0;	/* CPU owns buffer */
> -		wmb();		/* Make sure adapter sees owner change */
> -		if (lp->tx_skbuff[i]) {
> -			pci_unmap_single(lp->pci_dev, lp->tx_dma_addr[i],
> -					 lp->tx_skbuff[i]->len,
> -					 PCI_DMA_TODEVICE);
> -			dev_kfree_skb(lp->tx_skbuff[i]);
> -		}
> -		lp->tx_skbuff[i] = NULL;
> -		lp->tx_dma_addr[i] = 0;
> -	}
> +	pcnet32_purge_rx_ring(dev);
> +	pcnet32_purge_tx_ring(dev);
>  
>  	spin_unlock_irqrestore(&lp->lock, flags);
>  
> @@ -2420,13 +2681,10 @@ static struct net_device_stats *pcnet32_
>  {
>  	struct pcnet32_private *lp = dev->priv;
>  	unsigned long ioaddr = dev->base_addr;
> -	u16 saved_addr;
>  	unsigned long flags;
>  
>  	spin_lock_irqsave(&lp->lock, flags);
> -	saved_addr = lp->a.read_rap(ioaddr);
>  	lp->stats.rx_missed_errors = lp->a.read_csr(ioaddr, 112);
> -	lp->a.write_rap(ioaddr, saved_addr);
>  	spin_unlock_irqrestore(&lp->lock, flags);
>  
>  	return &lp->stats;
> @@ -2439,6 +2697,7 @@ static void pcnet32_load_multicast(struc
>  	volatile struct pcnet32_init_block *ib = &lp->init_block;
>  	volatile u16 *mcast_table = (u16 *) & ib->filter;
>  	struct dev_mc_list *dmi = dev->mc_list;
> +	unsigned long ioaddr = dev->base_addr;
>  	char *addrs;
>  	int i;
>  	u32 crc;
> @@ -2447,6 +2706,10 @@ static void pcnet32_load_multicast(struc
>  	if (dev->flags & IFF_ALLMULTI) {
>  		ib->filter[0] = 0xffffffff;
>  		ib->filter[1] = 0xffffffff;
> +		lp->a.write_csr(ioaddr, 8, 0xffff);
> +		lp->a.write_csr(ioaddr, 9, 0xffff);
> +		lp->a.write_csr(ioaddr, 10, 0xffff);
> +		lp->a.write_csr(ioaddr, 11, 0xffff);
>  		return;
>  	}
>  	/* clear the multicast filter */
> @@ -2468,6 +2731,8 @@ static void pcnet32_load_multicast(struc
>  		    le16_to_cpu(le16_to_cpu(mcast_table[crc >> 4]) |
>  				(1 << (crc & 0xf)));
>  	}
> +	for (i = 0; i < 4; i++)
> +		lp->a.write_csr(ioaddr, 8+i, le16_to_cpu(mcast_table[i]));
>  	return;
>  }
>  
> @@ -2478,8 +2743,11 @@ static void pcnet32_set_multicast_list(s
>  {
>  	unsigned long ioaddr = dev->base_addr, flags;
>  	struct pcnet32_private *lp = dev->priv;
> +	int csr15, suspended;
>  
>  	spin_lock_irqsave(&lp->lock, flags);
> +	suspended = pcnet32_suspend(dev, &flags);
> +	csr15 = lp->a.read_csr(ioaddr, 15);
>  	if (dev->flags & IFF_PROMISC) {
>  		/* Log any net taps. */
>  		if (netif_msg_hw(lp))
> @@ -2488,15 +2756,24 @@ static void pcnet32_set_multicast_list(s
>  		lp->init_block.mode =
>  		    le16_to_cpu(0x8000 | (lp->options & PCNET32_PORT_PORTSEL) <<
>  				7);
> +		lp->a.write_csr(ioaddr, 15, csr15 | 0x8000);
>  	} else {
>  		lp->init_block.mode =
>  		    le16_to_cpu((lp->options & PCNET32_PORT_PORTSEL) << 7);
> +		lp->a.write_csr(ioaddr, 15, csr15 & 0x7fff);
>  		pcnet32_load_multicast(dev);
>  	}
>  
> -	lp->a.write_csr(ioaddr, 0, 0x0004);	/* Temporarily stop the lance. */
> -	pcnet32_restart(dev, 0x0042);	/*  Resume normal operation */
> -	netif_wake_queue(dev);
> +	if (suspended) {
> +		int csr5;
> +		/* clear SUSPEND (SPND) - CSR5 bit 0 */
> +		csr5 = lp->a.read_csr(ioaddr, 5);
> +		lp->a.write_csr(ioaddr, 5, csr5 & (~0x0001));
> +	} else { 
> +		lp->a.write_csr(ioaddr, 0, 0x0004);	/* stop the lance. */
> +		pcnet32_restart(dev, 0x0042);	/*  Resume normal operation */
> +		netif_wake_queue(dev);
> +	}
>  
>  	spin_unlock_irqrestore(&lp->lock, flags);
>  }
> @@ -2736,7 +3013,7 @@ static int __init pcnet32_init_module(vo
>  
>  	/* should we find any remaining VLbus devices ? */
>  	if (pcnet32vlb)
> -		pcnet32_probe_vlbus();
> +		pcnet32_probe_vlbus(pcnet32_portlist);
>  
>  	if (cards_found && (pcnet32_debug & NETIF_MSG_PROBE))
>  		printk(KERN_INFO PFX "%d cards_found.\n", cards_found);
> -- 

So yep, looks pretty good to me.  Those two debug statements are my only
comments on it.

Len Sorensen
