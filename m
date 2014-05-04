From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH 7/7] net: mvmdio: Use devm_* API to simplify the code
Date: Sun, 04 May 2014 23:24:15 +0200
Message-ID: <5366AFFF.8090205@gmail.com>
References: <1399141622-30654-1-git-send-email-ezequiel.garcia@free-electrons.com> <1399141622-30654-8-git-send-email-ezequiel.garcia@free-electrons.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:38132 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752534AbaEDVYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 17:24:20 -0400
Received: by mail-ee0-f41.google.com with SMTP id t10so1151724eei.0
        for <netdev@vger.kernel.org>; Sun, 04 May 2014 14:24:19 -0700 (PDT)
In-Reply-To: <1399141622-30654-8-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/03/2014 08:27 PM, Ezequiel Garcia wrote:
> This commit makes use of devm_kmalloc() for memory allocation and the
> recently introduced devm_mdiobus_alloc() API to simplify driver's code.
> While here, remove a redundant out of memory error message.
> 
> Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>

Acked-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

Thanks!

> ---
>  drivers/net/ethernet/marvell/mvmdio.c | 18 ++++++------------
>  1 file changed, 6 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
> index b161a52..995e182 100644
> --- a/drivers/net/ethernet/marvell/mvmdio.c
> +++ b/drivers/net/ethernet/marvell/mvmdio.c
> @@ -195,11 +195,10 @@ static int orion_mdio_probe(struct platform_device *pdev)
>  		return -ENODEV;
>  	}
>  
> -	bus = mdiobus_alloc_size(sizeof(struct orion_mdio_dev));
> -	if (!bus) {
> -		dev_err(&pdev->dev, "Cannot allocate MDIO bus\n");
> +	bus = devm_mdiobus_alloc_size(&pdev->dev,
> +				      sizeof(struct orion_mdio_dev));
> +	if (!bus)
>  		return -ENOMEM;
> -	}
>  
>  	bus->name = "orion_mdio_bus";
>  	bus->read = orion_mdio_read;
> @@ -208,11 +207,10 @@ static int orion_mdio_probe(struct platform_device *pdev)
>  		 dev_name(&pdev->dev));
>  	bus->parent = &pdev->dev;
>  
> -	bus->irq = kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
> -	if (!bus->irq) {
> -		mdiobus_free(bus);
> +	bus->irq = devm_kmalloc(&pdev->dev,
> +				sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
> +	if (!bus->irq)
>  		return -ENOMEM;
> -	}
>  
>  	for (i = 0; i < PHY_MAX_ADDR; i++)
>  		bus->irq[i] = PHY_POLL;
> @@ -261,8 +259,6 @@ static int orion_mdio_probe(struct platform_device *pdev)
>  out_mdio:
>  	if (!IS_ERR(dev->clk))
>  		clk_disable_unprepare(dev->clk);
> -	kfree(bus->irq);
> -	mdiobus_free(bus);
>  	return ret;
>  }
>  
> @@ -273,8 +269,6 @@ static int orion_mdio_remove(struct platform_device *pdev)
>  
>  	writel(0, dev->regs + MVMDIO_ERR_INT_MASK);
>  	mdiobus_unregister(bus);
> -	kfree(bus->irq);
> -	mdiobus_free(bus);
>  	if (!IS_ERR(dev->clk))
>  		clk_disable_unprepare(dev->clk);
>  
> 
