From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 7/9] net: mvmdio: add xmdio support
Date: Wed, 7 Jun 2017 08:48:06 -0700
Message-ID: <e423ea96-12df-6a19-ce94-149ace2e2272@gmail.com>
References: <20170607083810.30922-1-antoine.tenart@free-electrons.com>
 <20170607083810.30922-8-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f195.google.com ([74.125.82.195]:34288 "EHLO
        mail-ot0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750831AbdFGPsJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 11:48:09 -0400
Received: by mail-ot0-f195.google.com with SMTP id a2so1359837oth.1
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 08:48:09 -0700 (PDT)
In-Reply-To: <20170607083810.30922-8-antoine.tenart@free-electrons.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2017 01:38 AM, Antoine Tenart wrote:
> This patch adds the xMDIO interface support in the mvmdio driver. This
> interface is used in Ethernet controllers on Marvell 370, 7k and 8k (as
> of now). The xSMI interface supported by this driver complies with the
> IEEE 802.3 clause 45 (while the SMI interface complies with the clause
> 22). The xSMI interface is used by 10GbE devices.
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> ---

> +	if (of_device_is_compatible(np, "marvell,orion-mdio")) {
> +		ops->is_done = smi_is_done;
> +		ops->is_read_valid = smi_is_read_valid;
> +		ops->start_read = smi_start_read_op;
> +		ops->read = smi_read_op;
> +		ops->write = smi_write_op;
> +
> +		dev->poll_interval_min = MVMDIO_SMI_POLL_INTERVAL_MIN;
> +		dev->poll_interval_max = MVMDIO_SMI_POLL_INTERVAL_MAX;
> +	} else if (of_device_is_compatible(np, "marvell,xmdio")) {
> +		ops->is_done = xsmi_is_done;
> +		ops->is_read_valid = xsmi_is_read_valid;
> +		ops->start_read = xsmi_start_read_op;
> +		ops->read = xsmi_read_op;
> +		ops->write = xsmi_write_op;
> +
> +		dev->poll_interval_min = MVMDIO_XSMI_POLL_INTERVAL_MIN;
> +		dev->poll_interval_max = MVMDIO_XSMI_POLL_INTERVAL_MAX;
> +	} else {
> +		return -EINVAL;
> +	}

Instead of doing this, you could have the ops structure declared e.g: a
static global variables in the driver and reference them from the
of_device_id .data field, something like:

static struct orion_mdio_ops mdio_ops = {
	...
};

static struct orion_mdio_data mdio_data = {
	.ops = &mdio_ops,
	.poll_intervall_min = ...,
	.poll_interfave_max = ...,
};

static struct orion_mdio_ops xmdio_ops = {
	...
};

static strcut orion_mdio_data xmdio_ data = {
};

and then reference those using of_id->data in the probe function

> +
> +	dev->ops = ops;
> +	return 0;
> +}
> +
>  static int orion_mdio_probe(struct platform_device *pdev)
>  {
>  	struct resource *r;
>  	struct mii_bus *bus;
>  	struct orion_mdio_dev *dev;
> -	struct orion_mdio_ops *ops;
>  	int i, ret;
>  
>  	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> @@ -278,18 +367,9 @@ static int orion_mdio_probe(struct platform_device *pdev)
>  
>  	mutex_init(&dev->lock);
>  
> -	ops = devm_kzalloc(&pdev->dev, sizeof(*ops), GFP_KERNEL);
> -	if (!ops)
> -		return -ENOMEM;
> -
> -	dev->poll_interval_min = MVMDIO_SMI_POLL_INTERVAL_MIN;
> -	dev->poll_interval_max = MVMDIO_SMI_POLL_INTERVAL_MAX;
> -	ops->is_done = orion_mdio_smi_is_done;
> -	ops->is_read_valid = orion_mdio_smi_is_read_valid;
> -	ops->start_read = orion_mdio_start_read_op;
> -	ops->read = orion_mdio_read_op;
> -	ops->write = orion_mdio_write_op;
> -	dev->ops = ops;
> +	ret = orion_mdio_populate_ops(pdev, dev);
> +	if (ret)
> +		return ret;
>  
>  	if (pdev->dev.of_node)
>  		ret = of_mdiobus_register(bus, pdev->dev.of_node);
> @@ -340,6 +420,7 @@ static int orion_mdio_remove(struct platform_device *pdev)
>  
>  static const struct of_device_id orion_mdio_match[] = {
>  	{ .compatible = "marvell,orion-mdio" },

and do .data = &mdio_data

> +	{ .compatible = "marvell,xmdio" },

and .data = &xmdio_data

>  	{ }
>  };
>  MODULE_DEVICE_TABLE(of, orion_mdio_match);
> 

-- 
Florian
