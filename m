From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH V11 2/7] net: sxgbe: add basic framework for Samsung 10Gb
 ethernet driver
Date: Sat, 22 Mar 2014 12:45:57 +0100
Message-ID: <20140322114557.GA14955@electric-eye.fr.zoreil.com>
References: <007f01cf4597$50abac40$f20304c0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	devicetree@vger.kernel.org, "'David Miller'" <davem@davemloft.net>,
	"'GIRISH K S'" <ks.giri@samsung.com>,
	"'SIVAREDDY KALLAM'" <siva.kallam@samsung.com>,
	"'Vipul Chandrakant'" <vipul.pandya@samsung.com>,
	"'Ilho Lee'" <ilho215.lee@samsung.com>
To: Byungho An <bh74.an@samsung.com>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <007f01cf4597$50abac40$f20304c0$@samsung.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Byungho An <bh74.an@samsung.com> :
[...]
> +static int sxgbe_init_rx_buffers(struct net_device *dev,
> +				 struct sxgbe_rx_norm_desc *p, int i,
> +				 unsigned int dma_buf_sz,
> +				 struct sxgbe_rx_queue *rx_ring)
> +{
> +	struct sxgbe_priv_data *priv = netdev_priv(dev);
> +	struct sk_buff *skb;
> +
> +	skb = __netdev_alloc_skb(dev, dma_buf_sz, GFP_KERNEL);
> +	if (!skb)
> +		return -ENOMEM;
> +
> +	skb_reserve(skb, NET_IP_ALIGN);

__netdev_alloc_skb_ip_align

[...]
> +static int sxgbe_platform_probe(struct platform_device *pdev)
> +{
[...]
> +	priv = sxgbe_drv_probe(&(pdev->dev), plat_dat, addr);
> +	if (!priv) {
> +		pr_err("%s: main driver probe failed\n", __func__);
> +		return -ENODEV;
> +	}
> +
> +	/* Get MAC address if available (DT) */
> +	if (mac)
> +		ether_addr_copy(priv->dev->dev_addr, mac);
> +
> +	/* Get the SXGBE common INT information */
> +	priv->irq  = platform_get_irq(pdev, loop++);
> +	if (priv->irq <= 0) {
> +		dev_err(dev, "sxgbe common irq parsing failed\n");
> +		sxgbe_drv_remove(ndev);
> +		return -EINVAL;
> +	}
> +
> +	/* Get the TX/RX IRQ numbers */
> +	for (i = 0, chan = 0; i < SXGBE_TX_QUEUES; i++) {
> +		priv->txq[i]->irq_no = irq_of_parse_and_map(node, chan++);
> +		if (priv->txq[i]->irq_no <= 0) {
> +			dev_err(dev, "sxgbe tx irq parsing failed\n");
> +			return -EINVAL;
> +		}
> +	}
> +
> +	for (i = 0; i < SXGBE_RX_QUEUES; i++) {
> +		priv->rxq[i]->irq_no = irq_of_parse_and_map(node, chan++);
> +		if (priv->rxq[i]->irq_no <= 0) {
> +			dev_err(dev, "sxgbe rx irq parsing failed\n");
> +			return -EINVAL;
> +		}
> +	}

The error path should use sxgbe_drv_remove.

It should use irq_dispose_mapping as well to unwind irq_create_mapping
(called by irq_of_parse_and_map).

[...]
> +int sxgbe_xpcs_init(struct net_device *ndev)
> +{
> +	u32 value;
> +
> +	value = sxgbe_xpcs_read(ndev, SR_PCS_MMD_CONTROL1);
> +	/* 10G XAUI mode */
> +	sxgbe_xpcs_write(ndev, SR_PCS_CONTROL2, XPCS_TYPE_SEL_X);
> +	sxgbe_xpcs_write(ndev, VR_PCS_MMD_XAUI_MODE_CONTROL, XPCS_XAUI_MODE);
> +	sxgbe_xpcs_write(ndev, VR_PCS_MMD_XAUI_MODE_CONTROL, value | BIT(13));
> +	sxgbe_xpcs_write(ndev, SR_PCS_MMD_CONTROL1, value | BIT(11));
> +
> +	do {
> +		value = sxgbe_xpcs_read(ndev, VR_PCS_MMD_DIGITAL_STATUS);
> +
> +	} while ((value & XPCS_QSEQ_STATE_MPLLOFF) == XPCS_QSEQ_STATE_STABLE);

Excess empty line.

-- 
Ueimor
