From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH v2]  net: add Fast Ethernet driver for PXA168.
Date: Tue, 10 Aug 2010 14:33:29 +0200
Message-ID: <20100810123329.GR8876@mail.wantstofly.org>
References: <EC64E4604C8024438259B683BB2514E1082B1CB1B0@SC-VEXCH1.marvell.com> <FE9BFA4C-11AB-46B9-A514-EB62467A1BB7@marvell.com> <1281429004.17990.2.camel@pe-lt522.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Philip Rakity <prakity@marvell.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Prabhanjan Sarnaik <sarnaik@marvell.com>,
	"eric.y.miao@gmail.com" <eric.y.miao@gmail.com>,
	Mark Brown <markb@marvell.com>
To: Sachin Sanap <ssanap@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:49666 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753589Ab0HJMdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 08:33:31 -0400
Content-Disposition: inline
In-Reply-To: <1281429004.17990.2.camel@pe-lt522.marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 10, 2010 at 02:00:04PM +0530, Sachin Sanap wrote:

> * Headroom in SKB for 802.11 not included in the patch since that
>   varies based on 802.11 a/b/g/n.

I don't think this is true?

(The 11a/b/n on-the-air preambles are of different lengths (and are
sent at different rates), but that isn't visible to software.)


> +#define ETH_HW_IP_ALIGN		2	/* hw aligns IP header */
> +#define ETH_DATA_LEN		1500
> +#define MAX_PKT_SIZE		1518

How about (stacked) VLANs?

Is the hardware entirely unable to receive larger packets than this, or
is it capable of receiving such packets but e.g. with loss of hardware
receive checksum offloading?

(I guess the hardware can't do RX checksum offload at all since I see
no references to skb->ip_summed and CHECKSUM_*?)


> +#define MAX_DESCS_PER_HIGH	(60)
> +#define TX_DESC_COUNT_LOW	(10)

These don't seem used.


> +struct pxa168_eth_private {
>
> [...]
>
> +	/* Size of Tx Ring per queue */
> +	int tx_ring_size;
>
> [...]
>
> +	/* Size of Rx Ring per queue */
> +	int rx_ring_size;

If you're not going to let the tx/rx ring size be runtime configurable
(like they are in mv643xx_eth), you might as well leave these as defines.


> +static void ethernet_phy_set_addr(struct pxa168_eth_private *pep, int phy_addr)
> +{
> +	u32 reg_data;
> +
> +	reg_data = rdl(pep, PHY_ADDRESS);
> +	reg_data &= ~(0x1f);

No need for the parentheses.


> +static inline u8 flip_8_bits(u8 x)
> +{
> +	return (((x) & 0x01) << 3) | (((x) & 0x002) << 1)
> +	    | (((x) & 0x04) >> 1) | (((x) & 0x008) >> 3)

0x02, 0x08


> +	addr0 = (mac_addr[5] >> 2) & 0x03f;
> +	addr1 = (mac_addr[5] & 0x003) | (((mac_addr[4] & 0x7f)) << 2);
> +	addr2 = ((mac_addr[4] & 0x80) >> 7) | mac_addr[3] << 1;
> +	addr3 = (mac_addr[2] & 0x0ff) | ((mac_addr[1] & 1) << 8);

0x34, 0x03, 0xff


> +	if (i == HOP_NUMBER) {
> +		if (!del) {
> +			printk(KERN_INFO "%s: table section is full\n",
> +			       __FILE__);
> +			return -ENOSPC;
> +		} else

What does it mean in practice if this happens?  (The error message
could be a bit more descriptive.)


> +static void pxa168_eth_set_rx_mode(struct net_device *dev)
> +{
> +	struct pxa168_eth_private *pep = netdev_priv(dev);
> +	struct netdev_hw_addr *ha;
> +	u32 val;
> +
> +	val = rdl(pep, PORT_CONFIG);
> +	if (dev->flags & IFF_PROMISC)
> +		val |= PCR_PM;
> +	else
> +		val &= ~PCR_PM;
> +	wrl(pep, PORT_CONFIG, val);
> +	netdev_for_each_mc_addr(ha, dev)
> +	    update_hash_table_mac_address(pep, NULL, ha->addr);
> +}

1. Don't indent with spaces.
2. This will never remove old multicast MAC addresses?


> +	pep->work_todo &= ~(WORK_TX_DONE);

Doesn't need parentheses.


> +static int rxq_process(struct net_device *dev, int budget)
> +{
> +	struct pxa168_eth_private *pep = netdev_priv(dev);
> +	struct net_device_stats *stats = &dev->stats;
> +	unsigned int received_packets = 0;
> +	struct sk_buff *skb;
> +
> +	while (budget-- > 0) {
> +
> +		int rx_next_curr_desc, rx_curr_desc, rx_used_desc;

No need for an empty line.


> +static int pxa168_eth_collect_events(struct pxa168_eth_private *pep,
> +				     struct net_device *dev)
> +{
> +	u32 icr;
> +	int ret = 0;
> +
> +	icr = rdl(pep, INT_CAUSE);
> +	if (0x00 == icr)

	icr == 0


> +	wrl(pep, INT_CAUSE, icr ^ 0xffffffff);

~icr ?


> +	/* Extended Port Configuration */
> +	wrl(pep,
> +	    PORT_CONFIG_EXT, PCXR_2BSM | /* Two byte suffix aligns IP hdr */

Prefix?


> +		dma_free_coherent(NULL, pep->tx_desc_area_size,
> +				  pep->p_tx_desc_area, pep->tx_desc_dma);

BTW, you should pass in a struct device * to the DMA allocation
functions.


> +	err = request_irq(dev->irq, pxa168_eth_int_handler,
> +			  IRQF_DISABLED , dev->name, dev);

Superfluous space before the comma.


> +static void eth_tx_submit_descs_for_skb(struct pxa168_eth_private *pep,
> +					struct sk_buff *skb)
> +{
> +	int tx_index;
> +	struct tx_desc *desc;
> +	int length;
> +
> +	tx_index = eth_alloc_tx_desc_index(pep);
> +	desc = &pep->p_tx_desc_area[tx_index];
> +	length = skb->len;
> +	pep->tx_skb[tx_index] = skb;
> +	desc->byte_cnt = length;
> +	desc->buf_ptr = dma_map_single(NULL, skb->data, length, DMA_TO_DEVICE);
> +	wmb();
> +	desc->cmd_sts = BUF_OWNED_BY_DMA | TX_GEN_CRC | TX_FIRST_DESC |
> +			TX_ZERO_PADDING | TX_LAST_DESC;
> +	if (unlikely(!(pep->tx_desc_count % (pep->tx_ring_size / 4))))
> +		desc->cmd_sts |= TX_EN_INT;

Is this intended to only generate transmit completion interrupts for
every N packets?

If so, you cannot delay kfree_skb()ing a transmitted skb indefinitely.
If you want to batch TX completion interrupts, you at least have to put
in a timeout.

Also, the descriptor is in device-visible memory, and BUF_OWNED_BY_DMA
becomes visible to the device as soon as you do the preceding store to
desc->cmd_sts -- you cannot then go back and alter that field, as you
could race with the device clearing BUF_OWNED_BY_DMA.


> +static int pxa168_eth_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct pxa168_eth_private *pep = netdev_priv(dev);
> +	struct net_device_stats *stats = &dev->stats;
> +
> +	eth_tx_submit_descs_for_skb(pep, skb);

In mv643xx_eth, txq_submit_*() are much larger because they have to deal
with scatter-gather transmit.  Since you don't support that, you might
as well just inline this function here.


> +static int pxa168_smi_read(struct mii_bus *bus, int phy_addr, int regnum)
> +{
> +	int val;
> +	struct pxa168_eth_private *pep = bus->priv;
> +	int i = 0;
> +
> +	/* wait for the SMI register to become available */
> +	for (i = 0; (val = rdl(pep, SMI)) & SMI_BUSY; i++) {
> +		if (i == PHY_WAIT_ITERATIONS) {
> +			printk(KERN_ERR
> +			       "pxa168 PHY timeout, val=0x%x\n", val);
> +			return -ETIMEDOUT;
> +		}
> +		udelay(1);
> +	}
> +	wrl(pep, SMI, (phy_addr << 16) | (regnum << 21) | SMI_OP_R);
> +	/* now wait for the data to be valid */
> +	for (i = 0; !((val = rdl(pep, SMI)) & SMI_R_VALID); i++) {
> +		if (i == PHY_WAIT_ITERATIONS) {
> +			printk(KERN_ERR
> +			       "pxa168 PHY RD timeout, val=0x%x\n", val);
> +			return -ETIMEDOUT;
> +		}
> +		udelay(1);
> +	}
> +	return val & 0xffff;
> +}

This can end up busy-waiting (i.e. hogging the CPU) for twice 500 us,
i.e. 1 msec.  Isn't there a SMI completion interrupt you can use, or
at least yield the cpu by sleeping for a bit?


> +static int pxa168_smi_write(struct mii_bus *bus, int phy_addr, int regnum,
> +			    u16 value)
> +{
> +	struct pxa168_eth_private *pep = bus->priv;
> +	int i;
> +
> +	/* wait for the SMI register to become available */
> +	for (i = 0; rdl(pep, SMI) & SMI_BUSY; i++) {
> +		if (i == PHY_WAIT_ITERATIONS) {
> +			printk(KERN_ERR "pxa168 PHY busy timeout.\n");
> +			return -ETIMEDOUT;
> +		}
> +		udelay(1);
> +	}
> +	wrl(pep, SMI, (phy_addr << 16) | (regnum << 21) |
> +	    SMI_OP_W | (value & 0xffff));

I would wait here for the write to complete, otherwise you can't report
errors due to the slave address not responding.


> +	clk = clk_get(&pdev->dev, "MFUCLK");
> +	if (IS_ERR(clk)) {
> +		printk(KERN_ERR "fast Ethernet failed to get clock\n");

At least stick the name of the driver in here.


> +	/* init callback is used for board specific initialization
> +	 * e.g on Aspenite its used to initialize the PHY transceiver.
> +	 */
> +	int (*init)(void);

Is resetting the PHY not enough?
