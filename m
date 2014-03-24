From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Mon, 24 Mar 2014 16:18:01 +0100
Message-ID: <13743364.WZtdi2BZb3@wuerfel>
References: <1395670496-17381-1-git-send-email-zhangfei.gao@linaro.org> <1395670496-17381-4-git-send-email-zhangfei.gao@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Zhangfei Gao <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1395670496-17381-4-git-send-email-zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 24 March 2014 22:14:56 Zhangfei Gao wrote:

> +
> +static void hip04_tx_reclaim(struct net_device *ndev, bool force)
> +{
> +	struct hip04_priv *priv = netdev_priv(ndev);
> +	unsigned tx_head = priv->tx_head;
> +	unsigned tx_tail = priv->tx_tail;
> +	struct tx_desc *desc = &priv->tx_desc[priv->tx_tail];
> +
> +	while (tx_tail != tx_head) {
> +		if (desc->send_addr != 0) {
> +			if (force)
> +				desc->send_addr = 0;
> +			else
> +				break;
> +		}
> +		if (priv->tx_phys[tx_tail]) {
> +			dma_unmap_single(&ndev->dev, priv->tx_phys[tx_tail],
> +				priv->tx_skb[tx_tail]->len, DMA_TO_DEVICE);
> +			priv->tx_phys[tx_tail] = 0;
> +		}
> +		dev_kfree_skb_irq(priv->tx_skb[tx_tail]);
> +		priv->tx_skb[tx_tail] = NULL;
> +		tx_tail = TX_NEXT(tx_tail);
> +		priv->tx_count--;
> +	}
> +	priv->tx_tail = tx_tail;
> +}

I think you still need to find a solution to ensure that the tx reclaim is
called eventually through a method other than start_xmit.

> +
> +	priv->map = syscon_regmap_lookup_by_compatible("hisilicon,hip04-ppe");
> +	if (IS_ERR(priv->map)) {
> +		dev_warn(d, "no hisilicon,hip04-ppe\n");
> +		ret = PTR_ERR(priv->map);
> +		goto init_fail;
> +	}
> +
> +	n = of_parse_phandle(node, "port-handle", 0);
> +	if (n) {
> +		ret = of_property_read_u32(n, "reg", &priv->port);
> +		if (ret) {
> +			dev_warn(d, "no reg info\n");
> +			goto init_fail;
> +		}
> +
> +		ret = of_property_read_u32(n, "channel", &priv->chan);
> +		if (ret) {
> +			dev_warn(d, "no channel info\n");
> +			goto init_fail;
> +		}
> +	} else {
> +		dev_warn(d, "no port-handle\n");
> +		ret = -EINVAL;
> +		goto init_fail;
> +	}

Doing the lookup by "compatible" string doesn't really help you
at solve the problem of single-instance ppe at all, because that
function will only ever look at the first one. Use
syscon_regmap_lookup_by_phandle instead and pass the phandle
you get from the "port-handle" property.

Also, since you decided to treat the ppe as a dump regmap, I would
recommend moving the 'reg' and 'channel' properties into arguments
of the port-handle link, and retting rid of the child nodes of
the ppe, like:

+       ppe: ppe@28c0000 {
+               compatible = "hisilicon,hip04-ppe", "syscon";
+               reg = <0x28c0000 0x10000>;
+       };
+
+       fe: ethernet@28b0000 {
+               compatible = "hisilicon,hip04-mac";
+               reg = <0x28b0000 0x10000>;
+               interrupts = <0 413 4>;
+               phy-mode = "mii";
+               port-handle = <&ppe 0xf1 0>;
+       };


	Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
