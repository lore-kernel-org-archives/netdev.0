From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH v8 1/1] Driver for Beckhoff CX5020 EtherCAT master
 module.
Date: Tue, 6 May 2014 16:56:06 +0200
Message-ID: <20140506145606.GH6455@distanz.ch>
References: <20140505191045.GK1156@newterm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Darek Marcinkiewicz <reksio@newterm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:55245 "EHLO sym2.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752330AbaEFPFA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2014 11:05:00 -0400
Content-Disposition: inline
In-Reply-To: <20140505191045.GK1156@newterm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-05-05 at 21:10:45 +0200, Darek Marcinkiewicz <reksio@newterm.pl> wrote:
> 
> This driver adds support for EtherCAT master module located on CCAT
> FPGA found on Beckhoff CX series industrial PCs. The driver exposes
> EtherCAT master as an ethernet interface.
> 
> EtherCAT is a fieldbus protocol defined on top of ethernet and Beckhoff
> CX5020 PCs come with built-in EtherCAT master module located on a FPGA,
> which in turn is connected to a PCI bus.
> 
> Signed-off-by: Dariusz Marcinkiewicz <reksio@newterm.pl>
> ---
> 
> Changes from v7:
>   * added 'depends on PCI' to the driver's Kconfig entry
> 
> Changes from v6:
>   * added memory barriers to avoid race between timer handler and xmit routine 
>   * includes formatting/indeting changes from Francois Romieu
> 
> Changes from v5:
>   * removal of needless locking on tx path
>   * driver makes actual use of tx fifo
>   * driver uses descriptors' array instead of descriptor list
> 
> Changes from v4: 
>   * incorporates Francois Romieu comments
>   * fixes typo spotted by Jesper Brouer
> 
> Changes from v3:
>   * some clarificatoins around buffer allocations
> 
> Changes from v2:
>   * removed all checkpatch warnings
>   * driver makes use of device rx fifo
> 
> Changes from v1:
>   * added endianess annotation to descriptors' structures
>   * killed checkpath warnings about string literals being split into multiple
>     lines
> 
>  drivers/net/ethernet/Kconfig  |   12 +
>  drivers/net/ethernet/Makefile |    1 +
>  drivers/net/ethernet/ec_bhf.c |  705 +++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 718 insertions(+)
>  create mode 100644 drivers/net/ethernet/ec_bhf.c

[...]

> +struct ec_bhf_priv {
> +	struct net_device *net_dev;
> +
> +	struct pci_dev *dev;
> +
> +	void * __iomem io;
> +	void * __iomem dma_io;
> +
> +	struct hrtimer hrtimer;
> +
> +	int tx_dma_chan;
> +	int rx_dma_chan;
> +	void * __iomem ec_io;
> +	void * __iomem fifo_io;
> +	void * __iomem mii_io;
> +	void * __iomem mac_io;
> +
> +	struct bhf_dma rx_buf;
> +	struct rx_desc *rx_descs;
> +	int rx_dnext;
> +	int rx_dcount;
> +
> +	struct bhf_dma tx_buf;
> +	struct tx_desc *tx_descs;
> +	int tx_dcount;
> +	int tx_dnext;
> +
> +	u64 stat_rx_bytes;
> +	u64 stat_tx_bytes;

netdev->stats already provides {rx,tx}_bytes members, so you can get rid
of these two.

[...]

> +static void ec_bhf_process_rx(struct ec_bhf_priv *priv)
> +{
> +	struct rx_desc *desc = &priv->rx_descs[priv->rx_dnext];
> +	struct device *dev = PRIV_TO_DEV(priv);
> +
> +	while (ec_bhf_pkt_received(desc)) {
> +		int pkt_size = (le16_to_cpu(desc->header.len) &
> +			       RXHDR_LEN_MASK) - sizeof(struct rx_header) - 4;
> +		u8 *data = desc->data;
> +		struct sk_buff *skb;
> +
> +		skb = netdev_alloc_skb_ip_align(priv->net_dev, pkt_size);
> +		dev_dbg(dev, "Received packet, size: %d\n", pkt_size);
> +
> +		if (skb) {
> +			memcpy(skb_put(skb, pkt_size), data, pkt_size);
> +			skb->protocol = eth_type_trans(skb, priv->net_dev);
> +			dev_dbg(dev, "Protocol type: %x\n", skb->protocol);
> +
> +			netif_rx(skb);
> +		} else {
> +			dev_err_ratelimited(dev,
> +				"Couldn't allocate a skb_buff for a packet of size %u\n",
> +				pkt_size);
> +		}
> +
> +		priv->stat_rx_bytes += pkt_size;

This should only be incremented if the packet was actually passed to
netif_rx(), no?

> +
> +		desc->header.recv = 0;
> +
> +		ec_bhf_add_rx_desc(priv, desc);
> +
> +		priv->rx_dnext = (priv->rx_dnext + 1) % priv->rx_dcount;
> +		desc = &priv->rx_descs[priv->rx_dnext];
> +	}
> +
> +}

[...]

> +static struct rtnl_link_stats64 *
> +ec_bhf_get_stats(struct net_device *net_dev,
> +		 struct rtnl_link_stats64 *stats)
> +{
> +	struct ec_bhf_priv *priv = netdev_priv(net_dev);
> +
> +	memset(stats, 0, sizeof(*stats));

No need to memset() here, this is already done in dev_get_stats()

> +	stats->rx_errors = ioread8(priv->mac_io + MAC_RX_ERR_CNT) +
> +				ioread8(priv->mac_io + MAC_CRC_ERR_CNT) +
> +				ioread8(priv->mac_io + MAC_FRAME_ERR_CNT);
> +	stats->rx_packets = ioread32(priv->mac_io + MAC_RX_FRAME_CNT);
> +	stats->tx_packets = ioread32(priv->mac_io + MAC_TX_FRAME_CNT);
> +	stats->rx_dropped = ioread8(priv->mac_io + MAC_DROPPED_FRMS);
> +
> +	stats->tx_bytes = priv->stat_tx_bytes;
> +	stats->rx_bytes = priv->stat_rx_bytes;
> +
> +	return stats;
> +}

[...]
