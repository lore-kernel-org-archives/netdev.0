From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 5/9] net: mvmdio: introduce an ops structure
Date: Wed, 7 Jun 2017 12:28:28 -0700
Message-ID: <dc639e44-17db-a1a9-217d-4215789aa7ac@gmail.com>
References: <20170607083810.30922-1-antoine.tenart@free-electrons.com>
 <20170607083810.30922-6-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:33270 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752007AbdFGT2c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 15:28:32 -0400
Received: by mail-qt0-f193.google.com with SMTP id w1so3318632qtg.0
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 12:28:32 -0700 (PDT)
In-Reply-To: <20170607083810.30922-6-antoine.tenart@free-electrons.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2017 01:38 AM, Antoine Tenart wrote:
> Introduce an ops structure to add an indirection on functions accessing
> the registers. This is needed to add the xMDIO support later.
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> ---
>  drivers/net/ethernet/marvell/mvmdio.c | 65 +++++++++++++++++++++++++++--------
>  1 file changed, 51 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
> index 56bbe3990590..8a71ef93a61b 100644
> --- a/drivers/net/ethernet/marvell/mvmdio.c
> +++ b/drivers/net/ethernet/marvell/mvmdio.c
> @@ -62,6 +62,15 @@ struct orion_mdio_dev {
>  	 */
>  	int err_interrupt;
>  	wait_queue_head_t smi_busy_wait;
> +	struct orion_mdio_ops *ops;
> +};
> +
> +struct orion_mdio_ops {
> +	int (*is_done)(struct orion_mdio_dev *);
> +	int (*is_read_valid)(struct orion_mdio_dev *);
> +	void (*start_read)(struct orion_mdio_dev *, int, int);
> +	u16 (*read)(struct orion_mdio_dev *);
> +	void (*write)(struct orion_mdio_dev *, int, int, u16);
>  };
>  
>  static int orion_mdio_smi_is_done(struct orion_mdio_dev *dev)
> @@ -74,6 +83,30 @@ static int orion_mdio_smi_is_read_valid(struct orion_mdio_dev *dev)
>  	return !(readl(dev->regs) & MVMDIO_SMI_READ_VALID);
>  }
>  
> +static void orion_mdio_start_read_op(struct orion_mdio_dev *dev, int mii_id,
> +				     int regnum)
> +{
> +	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
> +		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
> +		MVMDIO_SMI_READ_OPERATION),
> +	       dev->regs);
> +}
> +
> +static u16 orion_mdio_read_op(struct orion_mdio_dev *dev)
> +{
> +	return readl(dev->regs) & GENMASK(15,0);
> +}
> +
> +static void orion_mdio_write_op(struct orion_mdio_dev *dev, int mii_id,
> +				int regnum, u16 value)
> +{
> +	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
> +		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
> +		MVMDIO_SMI_WRITE_OPERATION            |
> +		(value << MVMDIO_SMI_DATA_SHIFT)),
> +	       dev->regs);
> +}
> +
>  /* Wait for the SMI unit to be ready for another operation
>   */
>  static int orion_mdio_wait_ready(struct mii_bus *bus)
> @@ -84,7 +117,7 @@ static int orion_mdio_wait_ready(struct mii_bus *bus)
>  	int timedout = 0;
>  
>  	while (1) {
> -	        if (orion_mdio_smi_is_done(dev))
> +	        if (dev->ops->is_done(dev))

Nit: you could actually keep this function (and all of them that have a
corresponding dev->ops function pointer) and just make it a static
inline that calls into dev->ops->is_done()

That would limit the delta to review, and it would still be within the
namespace of the driver (orion_mdio_*).

Your call.

>  			return 0;
>  	        else if (timedout)
>  			break;
> @@ -103,8 +136,7 @@ static int orion_mdio_wait_ready(struct mii_bus *bus)
>  			if (timeout < 2)
>  				timeout = 2;
>  			wait_event_timeout(dev->smi_busy_wait,
> -				           orion_mdio_smi_is_done(dev),
> -				           timeout);
> +				           dev->ops->is_done(dev), timeout);
>  
>  			++timedout;
>  	        }
> @@ -126,22 +158,19 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
>  	if (ret < 0)
>  		goto out;
>  
> -	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
> -		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
> -		MVMDIO_SMI_READ_OPERATION),
> -	       dev->regs);
> +	dev->ops->start_read(dev, mii_id, regnum);
>  
>  	ret = orion_mdio_wait_ready(bus);
>  	if (ret < 0)
>  		goto out;
>  
> -	if (orion_mdio_smi_is_read_valid(dev)) {
> +	if (dev->ops->is_read_valid(dev)) {
>  		dev_err(bus->parent, "SMI bus read not valid\n");
>  		ret = -ENODEV;
>  		goto out;
>  	}
>  
> -	ret = readl(dev->regs) & GENMASK(15,0);
> +	ret = dev->ops->read(dev);
>  out:
>  	mutex_unlock(&dev->lock);
>  	return ret;
> @@ -159,11 +188,7 @@ static int orion_mdio_write(struct mii_bus *bus, int mii_id,
>  	if (ret < 0)
>  		goto out;
>  
> -	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
> -		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
> -		MVMDIO_SMI_WRITE_OPERATION            |
> -		(value << MVMDIO_SMI_DATA_SHIFT)),
> -	       dev->regs);
> +	dev->ops->write(dev, mii_id, regnum, value);
>  
>  out:
>  	mutex_unlock(&dev->lock);
> @@ -190,6 +215,7 @@ static int orion_mdio_probe(struct platform_device *pdev)
>  	struct resource *r;
>  	struct mii_bus *bus;
>  	struct orion_mdio_dev *dev;
> +	struct orion_mdio_ops *ops;
>  	int i, ret;
>  
>  	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> @@ -249,6 +275,17 @@ static int orion_mdio_probe(struct platform_device *pdev)
>  
>  	mutex_init(&dev->lock);
>  
> +	ops = devm_kzalloc(&pdev->dev, sizeof(*ops), GFP_KERNEL);
> +	if (!ops)
> +		return -ENOMEM;
> +
> +	ops->is_done = orion_mdio_smi_is_done;
> +	ops->is_read_valid = orion_mdio_smi_is_read_valid;
> +	ops->start_read = orion_mdio_start_read_op;
> +	ops->read = orion_mdio_read_op;
> +	ops->write = orion_mdio_write_op;
> +	dev->ops = ops;
> +
>  	if (pdev->dev.of_node)
>  		ret = of_mdiobus_register(bus, pdev->dev.of_node);
>  	else
> 


-- 
Florian
