From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [Repost PATCH 6/6] PMC MSP85x0 gigabit ethernet driver
Date: Tue, 27 Jun 2006 00:31:25 +0200
Message-ID: <20060626223125.GA7809@electric-eye.fr.zoreil.com>
References: <C28979E4F697C249ABDA83AC0C33CDF80B6BC8@sjc1exm07.pmc_nt.nt.pmc-sierra.bc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Yoichi Yuasa'" <yoichi_yuasa@tripeaks.co.jp>,
	linux-mips@linux-mips.org, netdev@vger.kernel.org,
	Raj Palani <Rajesh_Palani@pmc-sierra.com>, ralf@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
To: Kiran Thota <Kiran_Thota@pmc-sierra.com>
Content-Disposition: inline
In-Reply-To: <C28979E4F697C249ABDA83AC0C33CDF80B6BC8@sjc1exm07.pmc_nt.nt.pmc-sierra.bc.ca>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

Kiran Thota <Kiran_Thota@pmc-sierra.com> :
[...]
>  - Based on linux-2.6.12 from 
>  http://www.linux-mips.org/pub/linux/mips/kernel/v2.6/linux-2.6.12.tar.gz

Is there a reason why the patch is not diffed against a more recent
version of the mips tree ?

The patch includes ~130 lines ending with a tab or space delimiter.
They could be removed.

[...]
> diff -Naur a/drivers/net/msp85x0_ge.c b/drivers/net/msp85x0_ge.c
> --- a/drivers/net/msp85x0_ge.c	1969-12-31 16:00:00.000000000 -0800
> +++ b/drivers/net/msp85x0_ge.c	2006-06-26 12:12:39.000000000 -0700
[...]
> +/* Static Function Declarations	 */
> +static int msp85x0_ge_eth_open(struct net_device *);
> +static int msp85x0_ge_eth_reopen(struct net_device *netdev);
> +static void msp85x0_ge_eth_stop(struct net_device *);
> +static struct net_device_stats *msp85x0_ge_get_stats(struct net_device *);
> +static int msp85x0_ge_init_rx_desc_ring(msp85x0_ge_port_info *, int, int,
> +				      unsigned long, unsigned long,
> +				      unsigned long);
> +static int msp85x0_ge_init_tx_desc_ring(msp85x0_ge_port_info *, int,
> +				      unsigned long, unsigned long);
> +
> +static int msp85x0_ge_open(struct net_device *);
> +static int msp85x0_ge_start_xmit(struct sk_buff *, struct net_device *);
> +static int msp85x0_ge_stop(struct net_device *);
> +
> +static unsigned int msp85x0_ge_tx_coal(int);
> +
> +static void msp85x0_ge_port_reset(unsigned int);
> +static int msp85x0_ge_free_tx_queue(struct net_device *);
> +static int msp85x0_ge_rx_task(struct net_device *, msp85x0_ge_port_info *);
> +static int msp85x0_ge_port_start(struct net_device *);
> +static int msp85x0_eth_setup_tx_rx_fifo(struct net_device *dev);
> +static int msp85x0_ge_xdma_reset(void);

You should be able to remove the forward declarations by correctly
reordering the code.

[...]
> +static struct platform_device *msp85x0_ge_device[NO_PORTS];
> +static struct net_device *msp85x0_eth[NO_PORTS];
> +static unsigned int msp85x0_ge_sram;
> +static unsigned int port_number;

The way it is used, port_number should be a local variable.

> +
> +/*
> + * The MSP85x0 GE has two alignment requirements:
> + * -> skb->data to be cacheline aligned (32 byte)
> + * -> IP header alignment to 16 bytes
> + *
> + * The latter is not implemented. So, that results in an extra copy on
> + * the Rx. This is a big performance hog. For the former case, the
> + * dev_alloc_skb() has been replaced with msp85x0_ge_alloc_skb(). The size
> + * requested is calculated:
> + *
> + * Ethernet Frame Size : 1518
> + * Ethernet Header     : 14
> + * Future MSP85x0 change for IP header alignment : 2
> + *
> + * Hence, we allocate (1518 + 14 + 2+ 64) = 1580 bytes.  For IP header
> + * alignment, we use skb_reserve().
> + */
> +#define ALIGNED_RX_SKB_ADDR(addr) \
> +	((((unsigned long)(addr) + (32UL - 1UL)) \
> +	& ~(32UL - 1UL)) - (unsigned long)(addr))
> +#define msp85x0_ge_alloc_skb(__length, __gfp_flags) \
> +({      struct sk_buff *__skb; \
> +	__skb = alloc_skb((__length),(__gfp_flags)); \
> +	if(__skb){ \
> +		int __offset = (int) ALIGNED_RX_SKB_ADDR(__skb->data); \
> +		if(__offset) \
> +			skb_reserve(__skb, __offset); \
> +	} \
> +	__skb; \
> +})

Please use a function for msp85x0_ge_alloc_skb.

> +
> +int increment_tx_pkt_count(unsigned int port)

static

> +{
> +	unsigned int flags;
> +	spin_lock_irqsave(&msp85x0_lock,flags);
> +	if(port==0){

CodingStyle: if (port == 0) {
(or 'if (!port)')

> +		port0_pkt_count++;
> +	}
> +	else{

	} else {

> +		port1_pkt_count++;	
> +	}
> +	spin_unlock_irqrestore(&msp85x0_lock,flags);

increment_tx_pkt_count() is only issued from msp85x0_ge_tx_queue(),
itself only issued from msp85x0_ge_start_xmit and xmit handlers run
with irq enabled. The save/restore is not needed.

> +	return 0;

Useless return.

> +}
> +
> +unsigned int get_tx_pkt_count(unsigned int port)

static

> +{
> +	unsigned int flags,pktCount,tx_pending_pkt;

Mixed case can be avoided here.

> +	spin_lock_irqsave(&msp85x0_lock,flags);

See above.

> +	tx_pending_pkt=MSP85x0_GE_READ(MSP85x0_GE_CHANNEL0_TX_DMA_STS + (port << XDMA_PORT_OFFSET));
> +	if(port==0){
> +		pktCount=port0_pkt_count - tx_pending_pkt;
> +	}
> +	else{

Sic.

> +		pktCount=port1_pkt_count - tx_pending_pkt;	
> +	}
> +	spin_unlock_irqrestore(&msp85x0_lock,flags);
> +	return pktCount;	
> +}
> +
> +unsigned int decrement_tx_pkt_count(unsigned int port)

static

[...]
> +void msp85x0_bringup_sequence(int port)

static

> +{
> +   	unsigned int reg_data;
> +
> +	/* SDQPF */
> +	reg_data=MSP85x0_GE_READ(MSP85x0_GE_SDQPF_RXFIFO_CTL + (port << 8));

reg_data = MSP85x0_GE_READ(MSP85x0_GE_...


[...]
> +static void msp85x0_ge_gmii_config(int port_num)
> +{
[...]
> +	if (phy_reg & 0x8000) {
> +		if (phy_reg & 0x2000) {
> +			/* Full Duplex and 1000 Mbps */
> +			MSP85x0_GE_WRITE((MSP85x0_GE_GMII_CONFIG_MODE +
> +					(port_num << MII_PORT_OFFSET)), 0x201);
> +		}  else {
> +			/* Half Duplex and 1000 Mbps */
> +			MSP85x0_GE_WRITE((MSP85x0_GE_GMII_CONFIG_MODE +
> +					(port_num << MII_PORT_OFFSET)), 0x2201);
> +			}
> +	}

:o(
		mode = (phy_reg & 0x2000) ? 0x0201 : 0x2201;
		MSP85x0_GE_WRITE((MSP85x0_GE_GMII_CONFIG_MODE +
				 (port_num << MII_PORT_OFFSET)), mode);
> +	if (phy_reg & 0x4000) {
> +		if (phy_reg & 0x2000) {
> +			/* Full Duplex and 100 Mbps */
> +			MSP85x0_GE_WRITE((MSP85x0_GE_GMII_CONFIG_MODE +
> +					(port_num << MII_PORT_OFFSET)), 0x100);
> +		} else {
> +			/* Half Duplex and 100 Mbps */
> +			MSP85x0_GE_WRITE((MSP85x0_GE_GMII_CONFIG_MODE +
> +					(port_num << MII_PORT_OFFSET)), 0x2100);
> +		}
> +	}

I'd bet you could make a single MSP85x0_GE_WRITE for this one and the two
above.

[...]
> +static void msp85x0_ge_update_afx(msp85x0_ge_port_info * msp85x0_ge_eth)
> +{
> +	int port = msp85x0_ge_eth->port_num;
> +	unsigned int i;
> +	volatile unsigned long reg_data = 0;

Mantra: volatile is not the answer.

Now, what's the question ? :o)


[...]
> +static void msp85x0_ge_tx_timeout_task(struct net_device *netdev)
> +{
> +	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
> +	int port = msp85x0_ge_eth->port_num;
> +
> +	printk("MSP85x0 GE: Transmit timed out. Resetting ... \n");

Missing KERN_xyz

[...]
> +static int msp85x0_ge_change_mtu(struct net_device *netdev, int new_mtu)
> +{
[...]
> +	if (netif_running(netdev)) {
> +		msp85x0_ge_eth_stop(netdev);
> +            	MSP85x0_GE_WRITE((MSP85x0_GE_RMAC_MAX_FRAME_LEN + (msp85x0_ge_eth->port_num << MAC_PORT_OFFSET)), new_mtu + 2); // for the padded bytes
> +
> +		if (msp85x0_ge_eth_reopen(netdev) != 0) {
> +			printk(KERN_ERR
> +			       "%s: Fatal error on opening device\n",
> +			       netdev->name);
> +			spin_unlock_irqrestore(&msp85x0_ge_eth->lock, flags);
> +			return -1;

Please use -Esomething.

You may consider goto to balance spin_{lock/unlock}.

[...]
> +static irqreturn_t msp85x0_ge_sequoia_int_handler(int irq, void *dev_id,
> +	struct pt_regs *regs)
> +{
> +	struct net_device *netdev = (struct net_device *) dev_id;

Useless cast from void *.

[...]
> +        /* Handle the Rx next */
> +        if (eth_int_cause1 & (RX_INT << (port_num * 16))) {
> +	      clear_xdma_interrupts(port_num,RX_INT);
> +              if (netif_rx_schedule_prep(netdev)) {
> +		   msp85x0_ge_disable_rx_int(port_num);	
> +                   __netif_rx_schedule(netdev);			       		

The indentation went badly wrong.

[...]
> +static int msp85x0_ge_open(struct net_device *netdev)
> +{
> +	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
> +	unsigned int port_num = msp85x0_ge_eth->port_num;
> +	unsigned int irq;
> +	int retval;       
> +
> +	spin_lock_irq(&(msp85x0_ge_eth->lock));
> +
> +	if (msp85x0_ge_eth_open(netdev) != MSP85x0_OK) {
> +		spin_unlock_irq(&(msp85x0_ge_eth->lock));
> +		printk("%s: Error opening interface \n", netdev->name);

Missing KERN_xyz

> +		free_irq(netdev->irq, netdev);

request_irq() comes later.

> +		return -EBUSY;

Why not propagate an usual return status code from msp85x0_ge_eth_open ?

> +	}
> +
> +	spin_unlock_irq(&(msp85x0_ge_eth->lock));
> +
> +        irq = MSP85x0_ETH_PORT_IRQ;
> +
> +	retval = request_irq(irq, INTERRUPT_HANDLER,
> +		     SA_SAMPLE_RANDOM | SA_SHIRQ, netdev->name, netdev);
> +
> +	if (retval != 0) {
> +		printk(KERN_ERR "Cannot assign IRQ number to MSP85x0 GE \n");
> +		return -1;

- msp85x0_ge_eth_open() should be balanced a bit (stop queuing for instance) ;
- no need to throw away retval.

(some sleep needed here, sorry)

-- 
Ueimor
