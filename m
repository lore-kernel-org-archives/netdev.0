From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/3] net: ethernet: socionext: add AVE ethernet
 driver
Date: Sat, 9 Sep 2017 09:30:58 -0700
Message-ID: <46b1bd9e-35ff-dc7f-fa32-f8d22b37a403@gmail.com>
References: <1504875731-3680-1-git-send-email-hayashi.kunihiko@socionext.com>
 <1504875731-3680-3-git-send-email-hayashi.kunihiko@socionext.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Masami Hiramatsu <masami.hiramatsu@linaro.org>,
        Jassi Brar <jaswinder.singh@linaro.org>
To: Kunihiko Hayashi <hayashi.kunihiko@socionext.com>,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504875731-3680-3-git-send-email-hayashi.kunihiko@socionext.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 09/08/2017 06:02 AM, Kunihiko Hayashi wrote:
> The UniPhier platform from Socionext provides the AVE ethernet
> controller that includes MAC and MDIO bus supporting RGMII/RMII
> modes. The controller is named AVE.
> 
> Signed-off-by: Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
> Signed-off-by: Jassi Brar <jaswinder.singh@linaro.org>
> ---

[snip]

> +static int ave_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> +{
> +	struct ave_private *priv = netdev_priv(ndev);
> +	u32 proc_idx, done_idx, ndesc, cmdsts;
> +	int freepkt;
> +	unsigned char *buffptr = NULL; /* buffptr for descriptor */
> +	unsigned int len;
> +	dma_addr_t paddr;
> +
> +	proc_idx = priv->tx.proc_idx;
> +	done_idx = priv->tx.done_idx;
> +	ndesc = priv->tx.ndesc;
> +	freepkt = ((done_idx + ndesc - 1) - proc_idx) % ndesc;
> +
> +	/* not enough entry, then we stop queue */
> +	if (unlikely(freepkt < 2)) {
> +		netif_stop_queue(ndev);
> +		if (unlikely(freepkt < 1))
> +			return NETDEV_TX_BUSY;

This looks wrong, why are you checking first for less than 2
descriptors, and if there is none, NETDEV_TX_BUSY? If you need 2 slots
to complete a transmision, stop the transmit queue and return
NETDEV_TX_BUSY.

> +	}
> +
> +	priv->tx.desc[proc_idx].skbs = skb;
> +
> +	/* add padding for short packet */
> +	if (skb_padto(skb, ETH_ZLEN)) {
> +		dev_kfree_skb_any(skb);
> +		return NETDEV_TX_OK;
> +	}

skb_padto() frees the SKB in case of error, that would lead to a double
free here.

> +
> +	buffptr = skb->data - NET_IP_ALIGN;
> +	len = max_t(unsigned int, ETH_ZLEN, skb->len);

If you use skb_put_padto() if padding was necessary skb->len will be at
least ETH_ZLEN, so you can remove this.

> +
> +	paddr = ave_dma_map(ndev, &priv->tx.desc[proc_idx], buffptr,
> +			    len + NET_IP_ALIGN, DMA_TO_DEVICE);

As mentioned before you can't assume this will never fail.

> +	paddr += NET_IP_ALIGN;
> +
> +	/* set buffer address to descriptor */
> +	ave_wdesc_addr(ndev, AVE_DESCID_TX, proc_idx, 4, paddr);

Also mentioned in the other email, make this 4 a constant so we know
it's an offset and not a length.

> +
> +	/* set flag and length to send */
> +	cmdsts = AVE_STS_OWN | AVE_STS_1ST | AVE_STS_LAST
> +		| (len & AVE_STS_PKTLEN_TX);

AVE_STS_PKTLEN_TX would be better named with a _MASK suffix.

> +
> +	/* set interrupt per AVE_FORCE_TXINTCNT or when queue is stopped */
> +	if (!(proc_idx % AVE_FORCE_TXINTCNT) || netif_queue_stopped(ndev))
> +		cmdsts |= AVE_STS_INTR;
> +
> +	/* disable checksum calculation when skb doesn't calurate checksum */
> +	if (skb->ip_summed == CHECKSUM_NONE ||
> +	    skb->ip_summed == CHECKSUM_UNNECESSARY)
> +		cmdsts |= AVE_STS_NOCSUM;
> +
> +	/* set cmdsts */
> +	ave_wdesc(ndev, AVE_DESCID_TX, proc_idx, 0, cmdsts);
> +
> +	priv->tx.proc_idx = (proc_idx + 1) % ndesc;

You should also check the ring space after transmission and assert flow
control on the transmit queue if needed.

> +
> +	return NETDEV_TX_OK;
> +}

[snip]

> +static struct net_device_stats *ave_stats(struct net_device *ndev)
> +{
> +	struct ave_private *priv = netdev_priv(ndev);
> +	u32 drop_num = 0;
> +
> +	priv->stats.rx_errors = ave_r32(ndev, AVE_BFCR);
> +
> +	drop_num += ave_r32(ndev, AVE_RX0OVFFC);
> +	drop_num += ave_r32(ndev, AVE_SN5FC);
> +	drop_num += ave_r32(ndev, AVE_SN6FC);
> +	drop_num += ave_r32(ndev, AVE_SN7FC);
> +	priv->stats.rx_dropped = drop_num;
> +

You should consider switching to 64-bit statistics, this requires a
little bit more work for 32-bit hosts (see
include/linux/u64_stats_sync.h) but this allows you to keep statistics
around above 4GB.

> +	return &priv->stats;
> +}
> +-- 
Florian
