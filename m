From: Joe Perches <joe@perches.com>
Subject: Re: [PATCHv4 4/9] macb: convert printk to netdev_ and friends
Date: Wed, 09 Nov 2011 05:10:47 -0800
Message-ID: <1320844247.6923.18.camel@Joe-Laptop>
References: <1320761613-18641-1-git-send-email-jamie@jamieiles.com>
	 <1320761613-18641-5-git-send-email-jamie@jamieiles.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:40342 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751231Ab1KINKr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Nov 2011 08:10:47 -0500
In-Reply-To: <1320761613-18641-5-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-11-08 at 14:13 +0000, Jamie Iles wrote:
> macb is already using the dev_dbg() and friends helpers so use netdev_()
> along with a pr_fmt() definition to make the printing a little cleaner.
trivia...

> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
[]
> @@ -8,6 +8,7 @@
>   * published by the Free Software Foundation.
>   */
>  
> +#define pr_fmt(fmt) "macb: " fmt

I think this is better as
#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

> @@ -176,11 +177,11 @@ static void macb_handle_link_change(struct net_device *dev)
>  
>  	if (status_change) {
>  		if (phydev->link)
> -			printk(KERN_INFO "%s: link up (%d/%s)\n",
> -			       dev->name, phydev->speed,
> -			       DUPLEX_FULL == phydev->duplex ? "Full":"Half");
> +			netdev_info(dev, "link up (%d/%s)\n", phydev->speed,
> +				    DUPLEX_FULL == phydev->duplex ?
> +				    "Full" : "Half");

Couple of very trivial style things here.
I think this is better as var == const and I also try
to keep arguments on a single line where possible and
when not possible, more arguments after the format to
seoarate lines.

			netdev_info(dev, "link up (%d/%s)\n",
				    phydev->speed,
				    phydev->duplex == DUPLEX_FULL ?
				    "Full" : "Half");
[]
> @@ -625,12 +624,11 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  #ifdef DEBUG
>  	int i;
> -	dev_dbg(&bp->pdev->dev,
> -		"start_xmit: len %u head %p data %p tail %p end %p\n",
> -		skb->len, skb->head, skb->data,
> -		skb_tail_pointer(skb), skb_end_pointer(skb));
> -	dev_dbg(&bp->pdev->dev,
> -		"data:");
> +	netdev_dbg(bp->dev,
> +		   "start_xmit: len %u head %p data %p tail %p end %p\n",
> +		   skb->len, skb->head, skb->data,
> +		   skb_tail_pointer(skb), skb_end_pointer(skb));
> +	netdev_dbg(bp->dev, "data:");
>  	for (i = 0; i < 16; i++)
>  		printk(" %02x", (unsigned int)skb->data[i]);
>  	printk("\n");

Maybe print_hex_dump

> @@ -1228,13 +1223,13 @@ static int __init macb_probe(struct platform_device *pdev)
>  
>  	platform_set_drvdata(pdev, dev);
>  
> -	printk(KERN_INFO "%s: Atmel MACB at 0x%08lx irq %d (%pM)\n",
> -	       dev->name, dev->base_addr, dev->irq, dev->dev_addr);
> +	netdev_info(dev, "Atmel MACB at 0x%08lx irq %d (%pM)\n",
> +		dev->base_addr, dev->irq, dev->dev_addr);
>  
>  	phydev = bp->phy_dev;
> -	printk(KERN_INFO "%s: attached PHY driver [%s] "
> -		"(mii_bus:phy_addr=%s, irq=%d)\n", dev->name,
> -		phydev->drv->name, dev_name(&phydev->dev), phydev->irq);
> +	netdev_info(dev, "attached PHY driver [%s] "
> +		    "(mii_bus:phy_addr=%s, irq=%d)\n", phydev->drv->name,
> +		    dev_name(&phydev->dev), phydev->irq);

Coalescing formats can also be done to make
it slightly easier to grep.

	netdev_info(dev, "attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
		    phydev->drv->name, dev_name(&phydev->dev), phydev->irq);
