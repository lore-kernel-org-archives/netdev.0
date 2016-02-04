From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: ethernet: davicom: fix devicetree irq resource
Date: Thu, 4 Feb 2016 20:16:23 +0300
Message-ID: <56B38767.6040005@cogentembedded.com>
References: <1454535609-7290-1-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Robert Jarzmik <robert.jarzmik@free.fr>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454535609-7290-1-git-send-email-robert.jarzmik@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

    Your patch summary prefixes are too verbose, it was enough to say only 
"dm9000: ".

On 02/04/2016 12:40 AM, Robert Jarzmik wrote:

> The dm9000 driver doesn't work in at least one device-tree
> configuration, spitting an error message on irq resource :
> [    1.062495] dm9000 8000000.ethernet: insufficient resources
> [    1.068439] dm9000 8000000.ethernet: not found (-2).
> [    1.073451] dm9000: probe of 8000000.ethernet failed with error -2
>
> The reason behind is that the interrupt might be provided by a gpio
> controller, not probed when dm9000 is probed, and needing the probe
> deferral mechanism to apply.
>
> Currently, the interrupt is directly taken from resources. This patch
> changes this to use the more generic platform_get_irq(), which handles
> the deferral.
>
> Moreover, since commit Fixes: 7085a7401ba5 ("drivers: platform: parse
> IRQ flags from resources"), the interrupt trigger flags are honored in
> platform_get_irq(), so remove the needless code in dm9000.
>
> Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
> Acked-by: Marcel Ziswiler <marcel@ziswiler.com>
> ---
>   drivers/net/ethernet/davicom/dm9000.c | 28 ++++++++++++++--------------
>   1 file changed, 14 insertions(+), 14 deletions(-)
>
> diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
> index cf94b72dbacd..6c527bde9edb 100644
> --- a/drivers/net/ethernet/davicom/dm9000.c
> +++ b/drivers/net/ethernet/davicom/dm9000.c
[...]
> @@ -1300,18 +1299,14 @@ static int
>   dm9000_open(struct net_device *dev)
>   {
>   	struct board_info *db = netdev_priv(dev);
> -	unsigned long irqflags = db->irq_res->flags & IRQF_TRIGGER_MASK;
> +	unsigned long irqflags = 0;
>
>   	if (netif_msg_ifup(db))
>   		dev_dbg(db->dev, "enabling %s\n", dev->name);
>
> -	/* If there is no IRQ type specified, default to something that
> -	 * may work, and tell the user that this is a problem */
> -
> -	if (irqflags == IRQF_TRIGGER_NONE)
> -		irqflags = irq_get_trigger_type(dev->irq);
> -
> -	if (irqflags == IRQF_TRIGGER_NONE)
> +	/* If there is no IRQ type specified, tell the user that this is a
> +	 * problem */

    The networking code formats comments this way:

/* foo
  * bar
  */

> +	if (irq_get_trigger_type(dev->irq) == IRQF_TRIGGER_NONE)
>   		dev_warn(db->dev, "WARNING: no IRQ resource flags set.\n");
>
>   	irqflags |= IRQF_SHARED;
> @@ -1500,15 +1495,21 @@ dm9000_probe(struct platform_device *pdev)
>
>   	db->addr_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>   	db->data_res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
> -	db->irq_res  = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
>
> -	if (db->addr_res == NULL || db->data_res == NULL ||
> -	    db->irq_res == NULL) {
> -		dev_err(db->dev, "insufficient resources\n");
> +	if (db->addr_res == NULL || db->data_res == NULL) {
> +		dev_err(db->dev, "insufficient resources addr=%p data=%p\n",
> +			db->addr_res, db->data_res);
>   		ret = -ENOENT;
>   		goto out;
>   	}
>
> +	ndev->irq = platform_get_irq(pdev, 0);
> +	if (ndev->irq <= 0) {

    I don't recommend checking for 0 and returning early in this case -- 
you'll signal a probe success this way. Either ignore 0 or return -E<smth>
in this case. Unfortunately, platform_get_irq() is so sloppily coded now that 
it *can* return 0 on error. :-(

> +		dev_err(db->dev, "interrupt resource unavailable: %d\n",
> +			ndev->irq);
> +		return ndev->irq;
> +	}
> +
>   	db->irq_wake = platform_get_irq(pdev, 1);
>   	if (db->irq_wake >= 0) {
>   		dev_dbg(db->dev, "wakeup irq %d\n", db->irq_wake);
[...]

MBR, Sergei
