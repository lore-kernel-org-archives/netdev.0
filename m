From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] net: ethernet: davicom: fix devicetree irq resource
Date: Sun, 7 Feb 2016 13:49:23 +0300
Message-ID: <56B72133.5090801@cogentembedded.com>
References: <1454796693-4446-1-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Robert Jarzmik <robert.jarzmik@free.fr>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:34938 "EHLO
	mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753224AbcBGKt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 05:49:26 -0500
Received: by mail-lf0-f54.google.com with SMTP id l143so80656112lfe.2
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 02:49:25 -0800 (PST)
In-Reply-To: <1454796693-4446-1-git-send-email-robert.jarzmik@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/7/2016 1:11 AM, Robert Jarzmik wrote:

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

    Fixes: tag here?

> IRQ flags from resources"), the interrupt trigger flags are honored in
> platform_get_irq(), so remove the needless code in dm9000.
>
> Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
> Acked-by: Marcel Ziswiler <marcel@ziswiler.com>
> Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> ---
> Since v1: comment style and requested irq test < 0
>            David, you should know that Sergei is concerned with the
> 	  subsystem prefix in the patch subject (too long for him).
> ---
>   drivers/net/ethernet/davicom/dm9000.c | 29 +++++++++++++++--------------
>   1 file changed, 15 insertions(+), 14 deletions(-)
>
> diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
> index cf94b72dbacd..2bae5c8c1f85 100644
> --- a/drivers/net/ethernet/davicom/dm9000.c
> +++ b/drivers/net/ethernet/davicom/dm9000.c
[...]
> @@ -1300,18 +1299,15 @@ static int
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
> +	 * problem
> +	 */
> +	if (irq_get_trigger_type(dev->irq) == IRQF_TRIGGER_NONE)
>   		dev_warn(db->dev, "WARNING: no IRQ resource flags set.\n");
>
>   	irqflags |= IRQF_SHARED;

    Why not just initialize to IRQF_SHARED?
    But actually you don't need this variable anymore.

> @@ -1500,15 +1496,21 @@ dm9000_probe(struct platform_device *pdev)
>
>   	db->addr_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>   	db->data_res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
> -	db->irq_res  = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
>
> -	if (db->addr_res == NULL || db->data_res == NULL ||
> -	    db->irq_res == NULL) {
> -		dev_err(db->dev, "insufficient resources\n");
> +	if (!db->addr_res || !db->data_res) {
> +		dev_err(db->dev, "insufficient resources addr=%p data=%p\n",
> +			db->addr_res, db->data_res);
>   		ret = -ENOENT;
>   		goto out;
>   	}
>
> +	ndev->irq = platform_get_irq(pdev, 0);
> +	if (ndev->irq < 0) {
> +		dev_err(db->dev, "interrupt resource unavailable: %d\n",
> +			ndev->irq);
> +		return ndev->irq;

    As already noted, direct *return* can't be used here.

[...]

MBR, Sergei
