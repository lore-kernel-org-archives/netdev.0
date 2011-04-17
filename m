From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] via-rhine: do not freak out due to invalid MAC address
Date: Sun, 17 Apr 2011 01:08:21 +0100
Message-ID: <1302998901.5282.866.camel@localhost>
References: <4DAA12C0.7030106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roger Luethi <rl@hellgate.ch>,
	"David S. Miller" <davem@davemloft.net>
To: "Alex G." <mr.nuke.me@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:27603 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331Ab1DQAI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2011 20:08:26 -0400
In-Reply-To: <4DAA12C0.7030106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-04-17 at 01:05 +0300, Alex G. wrote:
> via-rhine drops out of the init code if the hardware provides an invalid
> MAC address. Roger Luethi has had several reports of Rhine NICs doing just
> that. The hardware still works, though; assigning a random MAC address
> allows the NIC to be used as usual. Tested as a standalone interface,
> as carrier for ppp, and as bonding slave.
> 
> Signed-off-by: Alexandru Gagniuc <mr.nuke.me@gmail.com>
> 
> diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
> index 0422a79..e7e0fa9 100644
> --- a/drivers/net/via-rhine.c
> +++ b/drivers/net/via-rhine.c
> @@ -836,13 +836,18 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
>  
>      for (i = 0; i < 6; i++)
>          dev->dev_addr[i] = ioread8(ioaddr + StationAddr + i);
> -    memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
>  
> -    if (!is_valid_ether_addr(dev->perm_addr)) {
> -        rc = -EIO;
> -        printk(KERN_ERR "Invalid MAC address\n");
> -        goto err_out_unmap;
> +    if (!is_valid_ether_addr(dev->dev_addr)) {
> +        printk(KERN_ERR "via-rhine: Invalid MAC address: %pM. \n",
> +                dev->dev_addr);
> +        /* The device may still be used normally if a valid MAC is
> +         * configured
> +         */
> +        random_ether_addr(dev->dev_addr);
> +        printk(KERN_ERR "via-rhine: Using randomly generated address:"
> +                "%pM instead. \n", dev->dev_addr);
>      }
> +    memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);

I don't think you should hide the original address (presumably the
'permanent' address from EEPORM) in this way.  How about changing the
initial loop to initialise dev->perm_addr, then either copying that to
dev->dev_addr or generating a random address in dev->dev_addr?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

