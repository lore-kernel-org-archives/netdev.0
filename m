From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH net-next 14/15] drivers/net/typhoon.c: Use
 (pr|netdev)_<level> macro helpers
Date: Wed, 17 Feb 2010 20:59:30 -0500
Message-ID: <1266458370.5719.43.camel@obelisk.thedillows.org>
References: <cover.1266454575.git.joe@perches.com>
	 <40a714d7757b0c24f3f0737f028d0242853f935b.1266454576.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:37946 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756339Ab0BRCGy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 21:06:54 -0500
In-Reply-To: <40a714d7757b0c24f3f0737f028d0242853f935b.1266454576.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-02-17 at 17:02 -0800, Joe Perches wrote:
> Use pr_<level>
> Use netdev_<level>

The way the driver uses tp->name, most of the pr_<level> changes add an
extraneous "typhoon:" to the front of the messages, which is not
desirable. Your absolute change-over from PFX/ERR_PFX to pr_fmt()
KBUILD_MODNAME misses the distinction between the message where the
prefix is needed, and where it isn't.

The netdev_<level> changes are much more palatable to me than the
pr_<level> ones. I have no problem getting behind those.

> Coalesce long formats

I don't like these changes very much, either. I tend to work in 80 char
terminals, and the wrap of a few characters is usually annoying. I can
use a wider term, sure, but then you obscure the hint about too-deep
nesting that the more narrow terminal gives you. Also, it leaves
droppings about on those rare occasions when the code is printed 2-up.

I don't have very much to do on this driver these days, so I'll defer to
others on this issue. However, if you're going to be reformatting
things, please pull things up a line when you shorten things enough to
fit. You did it here:

> @@ -606,9 +605,8 @@ typhoon_issue_command(struct typhoon *tp, int num_cmd, struct cmd_desc *cmd,
>  	freeResp = typhoon_num_free_resp(tp);
>  
>  	if(freeCmd < num_cmd || freeResp < num_resp) {
> -		printk("%s: no descs for cmd, had (needed) %d (%d) cmd, "
> -			"%d (%d) resp\n", tp->name, freeCmd, num_cmd,
> -			freeResp, num_resp);
> +		pr_err("%s: no descs for cmd, had (needed) %d (%d) cmd, %d (%d) resp\n",
> +		       tp->name, freeCmd, num_cmd, freeResp, num_resp);
>  		err = -ENOMEM;
>  		goto out;
>  	}

But not here -- perhaps an 80 char limit, I've not looked at the patched
file:

> @@ -1492,7 +1490,7 @@ typhoon_download_firmware(struct typhoon *tp)
>  			if(typhoon_wait_interrupt(ioaddr) < 0 ||
>  			   ioread32(ioaddr + TYPHOON_REG_STATUS) !=
>  			   TYPHOON_STATUS_WAITING_FOR_SEGMENT) {
> -				printk(KERN_ERR "%s: segment ready timeout\n",
> +				pr_err("%s: segment ready timeout\n",
>  				       tp->name);
>  				goto err_out_irq;
>  			}

These __func__ conversions need to go.

> @@ -1901,16 +1898,16 @@ typhoon_sleep(struct typhoon *tp, pci_power_t state, __le16 events)
>  	xp_cmd.parm1 = events;
>  	err = typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
>  	if(err < 0) {
> -		printk(KERN_ERR "%s: typhoon_sleep(): wake events cmd err %d\n",
> -				tp->name, err);
> +		pr_err("%s: %s(): wake events cmd err %d\n",
> +		       tp->name, __func__, err);
>  		return err;
>  	}

Pull up tp->name?

> @@ -2089,11 +2085,11 @@ typhoon_stop_runtime(struct typhoon *tp, int wait_type)
>  	typhoon_issue_command(tp, 1, &xp_cmd, 0, NULL);
>  
>  	if(typhoon_wait_status(ioaddr, TYPHOON_STATUS_HALTED) < 0)
> -		printk(KERN_ERR "%s: timed out waiting for 3XP to halt\n",
> +		pr_err("%s: timed out waiting for 3XP to halt\n",
>  		       tp->name);

Please don't change this printk(), or change the version string, as
you'll have a redundant "typhoon:" in there now.

> @@ -2384,11 +2372,11 @@ typhoon_init_one(struct pci_dev *pdev, const > struct pci_device_id *ent
>        int err = 0;
> 
>        if(!did_version++)
>-               printk(KERN_INFO "%s", version);
>+               pr_info("%s", version);

Pull up pci_name()? Or does that overflow 80 chars?

> @@ -2384,11 +2372,11 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	dev = alloc_etherdev(sizeof(*tp));
>  	if(dev == NULL) {
> -		printk(ERR_PFX "%s: unable to alloc new net device\n",
> +		pr_err("%s: unable to alloc new net device\n",
>  		       pci_name(pdev));
>  		err = -ENOMEM;
>  		goto error_out;
> @@ -2397,20 +2385,20 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  
>  	err = pci_enable_device(pdev);
>  	if(err < 0) {
> -		printk(ERR_PFX "%s: unable to enable device\n",
> +		pr_err("%s: unable to enable device\n",
>  		       pci_name(pdev));
>  		goto error_out_dev;
>  	}
>  
>  	err = pci_set_mwi(pdev);
>  	if(err < 0) {
> -		printk(ERR_PFX "%s: unable to set MWI\n", pci_name(pdev));
> +		pr_err("%s: unable to set MWI\n", pci_name(pdev));
>  		goto error_out_disable;
>  	}
>  
>  	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
>  	if(err < 0) {
> -		printk(ERR_PFX "%s: No usable DMA configuration\n",
> +		pr_err("%s: No usable DMA configuration\n",
>  		       pci_name(pdev));
>  		goto error_out_mwi;
>  	}

> @@ -2523,7 +2509,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  
>  	INIT_COMMAND_WITH_RESPONSE(&xp_cmd, TYPHOON_CMD_READ_MAC_ADDRESS);
>  	if(typhoon_issue_command(tp, 1, &xp_cmd, 1, xp_resp) < 0) {
> -		printk(ERR_PFX "%s: cannot read MAC address\n",
> +		pr_err("%s: cannot read MAC address\n",
>  		       pci_name(pdev));
>  		err = -EIO;
>  		goto error_out_reset;

> @@ -2561,7 +2547,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  		tp->capabilities |= TYPHOON_WAKEUP_NEEDS_RESET;
>  
>  	if(typhoon_sleep(tp, PCI_D3hot, 0) < 0) {
> -		printk(ERR_PFX "%s: cannot put adapter to sleep\n",
> +		pr_err("%s: cannot put adapter to sleep\n",
>  		       pci_name(pdev));
>  		err = -EIO;
>  		goto error_out_reset;



