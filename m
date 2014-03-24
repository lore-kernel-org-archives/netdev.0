From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH V13 2/7] net: sxgbe: add basic framework for Samsung 10Gb
 ethernet driver
Date: Tue, 25 Mar 2014 00:45:05 +0100
Message-ID: <20140324234505.GA22059@electric-eye.fr.zoreil.com>
References: <00a001cf46d8$f4c38bd0$de4aa370$@samsung.com>
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
In-Reply-To: <00a001cf46d8$f4c38bd0$de4aa370$@samsung.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static int sxgbe_platform_probe(struct platform_device *pdev)
[...]
> +	/* Get the SXGBE common INT information */
> +	priv->irq  = irq_of_parse_and_map(node, 0);
> +	if (priv->irq <= 0) {
> +		dev_err(dev, "sxgbe common irq parsing failed\n");
> +		irq_dispose_mapping(priv->irq);
> +		sxgbe_drv_remove(ndev);

sxgbe_drv_probe has not been issued at this point.

> +		return -EINVAL;
> +	}
> +
> +	/* Get the TX/RX IRQ numbers */
> +	for (i = 0, chan = 1; i < SXGBE_TX_QUEUES; i++) {
> +		priv->txq[i]->irq_no = irq_of_parse_and_map(node, chan++);
> +		if (priv->txq[i]->irq_no <= 0) {
> +			dev_err(dev, "sxgbe tx irq parsing failed\n");
> +			irq_dispose_mapping(priv->txq[i]->irq_no);

Releasing the failed irq_no and leaking the i - 1  succeeded ones can't
be right.

> +			sxgbe_drv_remove(ndev);

Sic.

> +			return -EINVAL;
> +		}
> +	}
> +
> +	for (i = 0; i < SXGBE_RX_QUEUES; i++) {
> +		priv->rxq[i]->irq_no = irq_of_parse_and_map(node, chan++);
> +		if (priv->rxq[i]->irq_no <= 0) {
> +			dev_err(dev, "sxgbe rx irq parsing failed\n");
> +			irq_dispose_mapping(priv->rxq[i]->irq_no);
> +			sxgbe_drv_remove(ndev);

Same problem(s) as above + priv->txq[.]->irq_no leak.

Please use goto for the unwind path.

> +			return -EINVAL;
> +		}
> +	}
> +
> +	priv = sxgbe_drv_probe(&(pdev->dev), plat_dat, addr);
> +	if (!priv) {
> +		pr_err("%s: main driver probe failed\n", __func__);
> +		return -ENODEV;

The error path is wrong.

-- 
Ueimor
