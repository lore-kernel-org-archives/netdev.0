From: Ben Dooks <ben-linux@fluff.org>
Subject: Re: [PATCH 1/6] smsc911x: add support for platform-specific irq flags
Date: Tue, 20 Jan 2009 14:55:39 +0000
Message-ID: <20090120145539.GD2425@trinity.fluff.org>
References: <1232458114-10997-1-git-send-email-steve.glendinning@smsc.com>
	<1232458114-10997-2-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, Russell King <linux@arm.linux.org.uk>,
	Stanley Miao <stanley.miao@windriver.com>,
	Ian Saturley <ian.saturley@smsc.com>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
Content-Disposition: inline
In-Reply-To: <1232458114-10997-2-git-send-email-steve.glendinning@smsc.com>
List-Unsubscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=unsubscribe>
List-Archive: <http://lists.arm.linux.org.uk/lurker/list/linux-arm-kernel.html>
List-Post: <mailto:linux-arm-kernel@lists.arm.linux.org.uk>
List-Help: <mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=help>
List-Subscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.arm.linux.org.uk
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk
List-Id: netdev.vger.kernel.org

On Tue, Jan 20, 2009 at 01:28:29PM +0000, Steve Glendinning wrote:
> this patch adds support for the platform_device's resources to indicate
> additional flags to use when registering the irq, for example
> IORESOURCE_IRQ_LOWLEVEL (which corresponds to IRQF_TRIGGER_LOW).  These
> should be set in the irq resource flags field.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
> ---
>  drivers/net/smsc911x.c |   19 ++++++++++++++-----
>  1 files changed, 14 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
> index f513bdf..3565df1 100644
> --- a/drivers/net/smsc911x.c
> +++ b/drivers/net/smsc911x.c
> @@ -1892,9 +1892,9 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
>  	struct net_device *dev;
>  	struct smsc911x_data *pdata;
>  	struct smsc911x_platform_config *config = pdev->dev.platform_data;
> -	struct resource *res;
> +	struct resource *res, *irq_res;
>  	unsigned int intcfg = 0;
> -	int res_size;
> +	int res_size, irq_flags;
>  	int retval;
>  	DECLARE_MAC_BUF(mac);
>  
> @@ -1919,6 +1919,14 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
>  	}
>  	res_size = res->end - res->start;
>  
> +	irq_res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
> +	if (!irq_res) {
> +		pr_warning("%s: Could not allocate irq resource.\n",
> +			SMSC_CHIPNAME);
> +		retval = -ENODEV;
> +		goto out_0;

-ENODEV is certainly not the right code to be returning here, it is
likely to get lost in the driver porbe process.

> +	}
> +
>  	if (!request_mem_region(res->start, res_size, SMSC_CHIPNAME)) {
>  		retval = -EBUSY;
>  		goto out_0;
> @@ -1935,7 +1943,8 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
>  
>  	pdata = netdev_priv(dev);
>  
> -	dev->irq = platform_get_irq(pdev, 0);
> +	dev->irq = irq_res->start;
> +	irq_flags = irq_res->flags & IRQF_TRIGGER_MASK;
>  	pdata->ioaddr = ioremap_nocache(res->start, res_size);
>  
>  	/* copy config parameters across to pdata */
> @@ -1968,8 +1977,8 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
>  	smsc911x_reg_write(pdata, INT_EN, 0);
>  	smsc911x_reg_write(pdata, INT_STS, 0xFFFFFFFF);
>  
> -	retval = request_irq(dev->irq, smsc911x_irqhandler, IRQF_DISABLED,
> -			     dev->name, dev);
> +	retval = request_irq(dev->irq, smsc911x_irqhandler,
> +			     irq_flags | IRQF_DISABLED, dev->name, dev);
>  	if (retval) {
>  		SMSC_WARNING(PROBE,
>  			"Unable to claim requested irq: %d", dev->irq);
> -- 
> 1.6.0.6
> 
> 
> -------------------------------------------------------------------
> List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
> FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
> Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php

-- 
-- 
Ben

Q:      What's a light-year?
A:      One-third less calories than a regular year.


-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
