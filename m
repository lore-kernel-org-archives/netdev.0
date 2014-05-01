From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v4 1/1] Driver for Beckhoff CX5020 EtherCAT master module.
Date: Thu, 1 May 2014 17:53:31 +0200
Message-ID: <20140501155331.GA6523@electric-eye.fr.zoreil.com>
References: <20140501062047.GA1156@newterm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Darek Marcinkiewicz <reksio@newterm.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140501062047.GA1156@newterm.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Darek Marcinkiewicz <reksio@newterm.pl> :
[changes]

(you may add those after the "---" above the diffstat)

[...]
> diff --git a/drivers/net/ethernet/ec_bh.c b/drivers/net/ethernet/ec_bh.c
> new file mode 100644
> index 0000000..2ed2cee
> --- /dev/null
> +++ b/drivers/net/ethernet/ec_bh.c
[...]
> +#define TX_HEADER_SIZE		16

sizeof() ?

> +#define MAX_TX_BODY_SIZE	1518

s/1518/ETH_FRAME_LEN + ETH_FCS_LEN/ ?

> +#define MAX_TX_PKT_SIZE		(MAX_TX_BODY_SIZE + TX_HEADER_SIZE)
> +
> +#define FIFO_SIZE		64
> +
> +static long polling_frequency = TIMER_INTERVAL_NSEC;
> +
> +struct bh_priv {

Nit: it would be nice to avoid "_bh_" as it is already used in a set of
common kernel functions.

[...]
> +	u8 *tx_put;
> +	u8 *tx_get;

It's part u8 and part tx_header.

You may consider using a struct that adds an extra 'u8 data[0]' at
the end of the struct tx_header.

skb_copy_and_csum_dev in the xmit path rings a bell but the DMA FIFO
zone handling could imho save some pointer arithmetic and turn a bit
more literate.

[...]
> +static void ec_bh_print_status(struct bh_priv *priv)
> +{
> +	dev_info(PRIV_TO_DEV(priv),
> +		 "Frame error counter:%d\n",

- Excess new line. The message always fits within the (less than) 80 columns
  limit. There are several occurences of it in the driver.

- You may add a local variable to save the numerous PRIV_TO_DEV(priv).

- A space between the ":" and the "%" should help reading.

[...]
> +static void ec_bh_send_packet(struct bh_priv *priv)
> +{
> +	struct tx_header *header = (struct tx_header *)priv->tx_get;
> +	u32 addr = priv->tx_get - priv->tx;
> +	u32 len = le16_to_cpu(header->len) + sizeof(*header);

Please reorder so as to get an inverted xmas tree. You should do it
wherever it can be done in the driver.

> +
> +	iowrite32((((len + 8) / 8) << 24) | addr,
> +			priv->fifo_io + FIFO_TX_REG);

	iowrite32(addr | (((len + 8) / 8) << 24), priv->fifo_io + FIFO_TX_REG);

[...]
> +static void ec_bh_process_tx(struct bh_priv *priv)
> +{
> +	int sent;
> +	struct tx_header *header;
> +	u8 *pkt_end, *next_pkt;
> +
> +	if (!priv->tx_in_flight)
> +		return;
> +
> +	header = (struct tx_header *)priv->tx_get;

You may merge it with the variable declaration.

> +	sent = le32_to_cpu(header->sent) & TX_HDR_SENT;
> +	if (!sent)
> +		return;
> +
> +	pkt_end = priv->tx_get;
> +	pkt_end += (sizeof(*header) + le16_to_cpu(header->len) + 7) / 8 * 8;

ALIGN() ?

[...]
> +	if (netif_queue_stopped(priv->net_dev) &&
> +		(priv->tx_put > priv->tx_get
> +			|| priv->tx_put + MAX_TX_PKT_SIZE < priv->tx_get)) {

|| should be a the end of the preceding line

[...]
> +static void ec_bh_process_rx(struct bh_priv *priv)
> +{
> +	struct rx_desc *desc = priv->rx_desc;
> +
> +	while (ec_bh_pkt_received(desc)) {
> +		int pkt_size = (le16_to_cpu(desc->header.len) & RXHDR_LEN_MASK)
> +			       - sizeof(struct rx_header)
> +			       - 4;

The operator should be at the end of the preceding line.

> +		u8 *data = desc->data;
> +		struct sk_buff *skb;
> +
> +		skb = netdev_alloc_skb_ip_align(priv->net_dev, pkt_size);
> +		dev_dbg(PRIV_TO_DEV(priv),

You may use local variable instead of repeating (capitalized) macro.

[...]
> +static enum hrtimer_restart ec_bh_timer_fun(struct hrtimer *timer)
> +{
> +	struct bh_priv *priv = container_of(timer,
> +					struct bh_priv,
> +					hrtimer);
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&priv->lock, flags);
> +
> +	ec_bh_process_rx(priv);

The Rx part should not race with anything. You should thus push the
locked section into ec_bh_process_tx (then narrow it).

> +	ec_bh_process_tx(priv);
> +
> +	spin_unlock_irqrestore(&priv->lock, flags);
> +
> +	if (atomic_read(&priv->shutting_down))
> +		return HRTIMER_NORESTART;

You can use 'netif_running' and remove 'shutting_down'.

[...]
> +static netdev_tx_t ec_bh_start_xmit(struct sk_buff *skb,
> +				    struct net_device *net_dev)
> +{
> +	unsigned long flags;
> +	unsigned len;
> +	struct bh_priv *priv = netdev_priv(net_dev);
> +	struct tx_header *header = (struct tx_header *)priv->tx_put;
> +	u8 *tx = priv->tx_put + sizeof(struct tx_header);
> +
> +	spin_lock_irqsave(&priv->lock, flags);
> +
> +	dev_dbg(PRIV_TO_DEV(priv), "Starting xmit\n");
> +
> +	/* Drop packets that are too large or have no chance
> +	 * to be a ethercat packets (cause they are too small)
> +	 */
> +	if (unlikely(skb->len > priv->tx_len
> +			|| skb->len < 13)) {
> +		net_dev->stats.tx_dropped++;
> +		dev_info(PRIV_TO_DEV(priv), "Dropping packet\n");
> +		goto out_unlock;
> +	}
> +
> +	skb_copy_and_csum_dev(skb, tx);
> +	len = skb->len;

Up to this point the lock is not required (ec_bh_process_tx does not
modifiy tx_put).

Bonus: 'out_unlock' turns into 'out' and you can narrow the locked
section at the end of the function.

> +
> +	memset(header, 0, sizeof(*header));
> +	header->len = cpu_to_le16(len);
> +	header->port = TX_HDR_PORT_0;
> +	mmiowb();
> +
> +	if (!priv->tx_in_flight) {
> +		ec_bh_send_packet(priv);
> +		priv->tx_in_flight = 1;
> +	}
> +
> +	priv->tx_put += (TX_HEADER_SIZE + len + 7) / 8 * 8;
> +	if (priv->tx_put + MAX_TX_PKT_SIZE > priv->tx + priv->tx_len)
> +		priv->tx_put = priv->tx;
> +
> +	if (priv->tx_put <= priv->tx_get
> +			&& priv->tx_put + MAX_TX_PKT_SIZE > priv->tx_get) {
> +		dev_info(PRIV_TO_DEV(priv), "Stopping netif queue\n");
> +		ec_bh_print_status(priv);
> +		netif_stop_queue(net_dev);
> +	}
> +
> +	priv->net_dev->stats.tx_bytes += len;
> +	priv->net_dev->stats.tx_packets++;

ec_bh_process_tx does not care about Tx error. Can it do better or is
it unable to ?

> +out_unlock:
> +	spin_unlock_irqrestore(&priv->lock, flags);
> +
> +	dev_kfree_skb(skb);
> +
> +	return NETDEV_TX_OK;
> +}
> +
> +void *ec_bh_alloc_dma_mem(struct bh_priv *priv,

static

[...]
> +	*buf = pci_alloc_consistent(priv->dev,
> +				    *buf_len,
> +				    phys_buf);

Go for dma_alloc_coherent(..., GFP_KERNEL) once you've removed the
spinlock in the open method.

[...]
> +static int ec_bh_open(struct net_device *net_dev)
> +{
> +	int err = 0, i;
> +	unsigned long flags;
> +	struct rx_desc *desc;
> +	struct bh_priv *priv = netdev_priv(net_dev);
> +
> +	dev_info(PRIV_TO_DEV(priv), "Opening device\n");
> +
> +	spin_lock_irqsave(&priv->lock, flags);

What is ec_bh_open supposed to be racing with ?

> +
> +	ec_bh_reset(priv);
> +
> +	priv->rx = ec_bh_alloc_dma_mem(priv, priv->rx_dma_chan,
> +				       &priv->rx_buf, &priv->rx_phys,
> +				       &priv->rx_buf_phys, &priv->rx_len,
> +				       &priv->rx_buf_len);

Yuck.

The Tx part duplicates this call. You want to introduce an extra struct
that both Tx and Rx would use in bh_priv.

[...]
> +	memset(priv->rx, 0, priv->rx_len);
> +	memset(priv->tx, 0, priv->tx_len);

Useless.

> +
> +	iowrite8(0, priv->mii_io + MII_MAC_FILT_FLAG);
> +
> +	priv->rx_dcount = min_t(int, FIFO_SIZE,
> +				priv->rx_len / (sizeof(struct rx_desc)));
> +	desc = (struct rx_desc *)(priv->rx);
> +	for (i = 0; i < priv->rx_dcount; i++) {
> +		u32 next;
> +
> +		if (i != priv->rx_dcount - 1)
> +			next = (u8 *)(desc + 1) - priv->rx;
> +		else
> +			next = 0;
> +		next |= RXHDR_NEXT_VALID;
> +		desc->header.next = cpu_to_le32(next);
> +		desc->header.recv = 0;
> +		ec_bh_add_rx_desc(priv, desc);
> +
> +		desc += 1;
> +	}
> +
> +	netif_start_queue(net_dev);
> +
> +	hrtimer_init(&priv->hrtimer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
> +	priv->hrtimer.function = ec_bh_timer_fun;
> +	hrtimer_start(&priv->hrtimer,
> +		      ktime_set(0, TIMER_INTERVAL_NSEC),

Nit: s/TIMER_INTERVAL_NSEC/polling_frequency/ ?

> +		      HRTIMER_MODE_REL);
> +
> +	dev_info(PRIV_TO_DEV(priv), "Device open\n");
> +
> +	ec_bh_print_status(priv);

(a bit too much debug messages imho)

[...]
> +static int ec_bh_probe(struct pci_dev *dev, const struct pci_device_id *id)
> +{
[...]
> +	net_dev->mem_start = pci_resource_start(dev, 0);
> +	net_dev->mem_end = pci_resource_end(dev, 0);
> +	net_dev->irq = dev->irq;

Legacy net_device fields. Please don't use these.

[...]
> +	if (ec_bh_setup_offsets(priv)) {
> +		err = -ENODEV;
> +		goto err_free_net_dev;
> +	}

	err = ec_bh_setup_offsets(...)
	if (err < 0) {
		...
> +
> +	memcpy_fromio(net_dev->dev_addr, priv->mii_io + MII_MAC_ADDR, 6);
> +
> +	dev_info(PRIV_TO_DEV(priv),

s/PRIV_TO_DEV(priv)/&dev->dev/ ?

[...]
> +static void ec_bh_remove(struct pci_dev *dev)
> +{
> +	struct net_device *net_dev = pci_get_drvdata(dev);
> +	struct bh_priv *priv = netdev_priv(net_dev);
> +	void * __iomem io = priv->io;
> +	void * __iomem dma_io = priv->dma_io;

The void * are used only once in this function. They don't deserve local
variables.

[...]
> +static struct pci_driver pci_driver = {
> +	.name = "ec_bh",
> +	.id_table = ids,
> +	.probe = ec_bh_probe,
> +	.remove = ec_bh_remove,

Please use tabs before "=" to line things up.

-- 
Ueimor
