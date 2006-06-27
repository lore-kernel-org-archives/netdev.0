From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [Repost PATCH 6/6] PMC MSP85x0 gigabit ethernet driver
Date: Wed, 28 Jun 2006 01:20:21 +0200
Message-ID: <20060627232021.GA9592@electric-eye.fr.zoreil.com>
References: <C28979E4F697C249ABDA83AC0C33CDF80B6BC8@sjc1exm07.pmc_nt.nt.pmc-sierra.bc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Yoichi Yuasa'" <yoichi_yuasa@tripeaks.co.jp>,
	linux-mips@linux-mips.org, netdev@vger.kernel.org,
	Raj Palani <Rajesh_Palani@pmc-sierra.com>, ralf@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:54406 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1422723AbWF0XWI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 19:22:08 -0400
To: Kiran Thota <Kiran_Thota@pmc-sierra.com>
Content-Disposition: inline
In-Reply-To: <C28979E4F697C249ABDA83AC0C33CDF80B6BC8@sjc1exm07.pmc_nt.nt.pmc-sierra.bc.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Kiran Thota <Kiran_Thota@pmc-sierra.com> :
[...]
> +/*
> + * Allocate the SKBs for the Rx ring. Also used
> + * for refilling the queue
> + */
> +
> +static int msp85x0_ge_rx_task(struct net_device *netdev,
> +				msp85x0_ge_port_info *msp85x0_ge_eth)
> +{
> +	struct device *device = &msp85x0_ge_device[msp85x0_ge_eth->port_num]->dev;
> +	volatile msp85x0_ge_rx_desc *rx_desc;
> +	struct sk_buff *skb;
> +	int rx_used_desc;
> +	int count = 0;
> +	oom_flag=0;

Global variable.

[...]
> +		if((rx_used_desc + 1) == MSP85x0_GE_RX_QUEUE)
> +			msp85x0_ge_eth->rx_used_desc_q =0;
> +		else
> +			msp85x0_ge_eth->rx_used_desc_q = (rx_used_desc + 1);	

Consider greping drivers/net for NEXT_TX or RING_NEXT.

[...]
> +static void msp85x0_port_init(struct net_device *netdev,
> +			    msp85x0_ge_port_info * msp85x0_ge_eth)
> +{
> +	unsigned long reg_data;
> +	unsigned int port_num;	
> +
> +	port_num = msp85x0_ge_eth->port_num;
> +	for (port_num = 0; port_num < NO_PORTS; port_num++)

There is something strange with port_num here.

[...]
> +static int start_tx_and_rx_activity(struct net_device *netdev)
> +{

The returned value is not used.

[...]
> +static int trtg_block_enable(struct net_device *netdev)
> +{

The returned value is not used.

[...]
> +static int enable_tx_and_rx_interrupts(struct net_device *netdev)
> +{

The returned value is not used.

[...]
> +static int xdma_config(struct net_device *netdev)
> +{

The indentation of this function is mostly broken.

[...]
> +static int msp85x0_ge_port_start(struct net_device *netdev)
> +{

The returned value is not used.

[...]
> +static int msp85x0_eth_setup_tx_rx_fifo(struct net_device *dev)
> +{

The returned value is not used.

[...]
> +static int msp85x0_ge_eth_open(struct net_device *netdev)
> +{
[...]
> +	/* Fill the Rx ring with the SKBs */
> +	msp85x0_ge_port_start(netdev);
[...]
> +	if (!(phy_reg & 0x0400)) {
> +		netif_carrier_off(netdev);
> +		netif_stop_queue(netdev);
> +		return MSP85x0_ERROR;

skb leak

[...]
> +int msp85x0_ge_start_xmit(struct sk_buff *skb, struct net_device *netdev)
> +{

static

This function ought to use NETDEV_TX_OK/NETDEV_TX_BUSY (should not happen).

[...]
> +static int msp85x0_ge_free_tx_queue(struct net_device *netdev)
> +{
> +	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
> +	int pkts,port_num = msp85x0_ge_eth->port_num;
> +	int tx_desc_used;
> +	struct sk_buff *skb;
> +
> +	/* Take the lock */
> +	pkts=get_tx_pkt_count(port_num);
> +	while(pkts)
> +	{
> +		pkts--;
> +		tx_desc_used = msp85x0_ge_eth->tx_used_desc_q;
> +
> +		/* return right away */
> +		if (tx_desc_used == msp85x0_ge_eth->tx_curr_desc_q)
> +			break;
> +	
> +		skb = msp85x0_ge_eth->tx_skb[tx_desc_used];
> +		dev_kfree_skb_irq(skb);

msp85x0_ge_free_tx_queue() is issued in msp85x0_ge_start_xmit(), thus
not in irq context.

[...]
> +static int msp85x0_ge_receive_queue(struct net_device *netdev)
> +{

Indentation needs to fixed in this function.

[...]
> +		if (packet.cmd_sts & (MSP85x0_GE_RX_PERR | MSP85x0_GE_RX_OVERFLOW_ERROR | MSP85x0_GE_RX_TRUNC | MSP85x0_GE_RX_CRC_ERROR))
> +		{
> +			if(packet.cmd_sts & MSP85x0_GE_RX_OVERFLOW_ERROR)
> +				stats->rx_over_errors++; 
> +			else if(packet.cmd_sts & MSP85x0_GE_RX_TRUNC)
> +				stats->rx_frame_errors++;
> +			else
> +				stats->rx_errors++;
> +			dev_kfree_skb_any(skb);

It's called in ->poll(), outside of in_irq().

dev->last_rx should be updated after netif_receive_skb().

[...]
> +static int msp85x0_ge_poll(struct net_device *netdev, int *budget)
> +{
[...]
> +	spin_lock_irqsave(&msp85x0_ge_eth->lock,flags);

Afaik poll takes place with irq enabled: no need to save/restore.

[...]
> +/* Don't Re-Initialize the port, Just start from where it stops */ 
> +static int msp85x0_ge_eth_reopen(struct net_device *netdev)	
> +{
> +	msp85x0_ge_port_info *msp85x0_ge_eth = netdev_priv(netdev);
> +	unsigned int reg_data,irq;
> +	int retval;
> +
> +        irq = MSP85x0_ETH_PORT_IRQ;
> +
> +	retval = request_irq(irq, INTERRUPT_HANDLER,
> +		     SA_INTERRUPT | SA_SAMPLE_RANDOM | SA_SHIRQ, netdev->name, netdev);

/me scratches head...

msp85x0_ge_change_mtu() does _not_ free_irqv and it issues
msp85x0_ge_eth_reopen().

I noticed this comment in msp85x0_ge_eth_stop():

/* This to work around to solve the msp85x0 shutdown and bringup sequence */

Can you elaborate ?

Random remarks:
- drivers/net/msp85x0_ge.h includes a lot of
  #define MSP85x0_GE_MSTATX_SOMETHING

  Your customers would surely appreciate extended stats through ethtool.
  grep for get_ethtool_stats in drivers/net

- You should be able to sprinkle a few NET_IP_ALIGN here and there.

- I won't complain if you feel an urge to remove the _ge_ part in
  msp85x0_ge_whatever

-- 
Ueimor
