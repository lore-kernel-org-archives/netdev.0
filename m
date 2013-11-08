From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 net-next] 8390 : Replace ei_debug with
 msg_enable/NETIF_MSG_* feature
Date: Fri, 08 Nov 2013 11:01:03 -0800
Message-ID: <1383937263.2639.25.camel@joe-AO722>
References: <1383935522-19200-1-git-send-email-tedheadster@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matthew Whitehead <tedheadster@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0001.hostedemail.com ([216.40.44.1]:35861 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757182Ab3KHTBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 14:01:08 -0500
In-Reply-To: <1383935522-19200-1-git-send-email-tedheadster@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-08 at 13:32 -0500, Matthew Whitehead wrote:
> Removed the shared ei_debug variable. Replaced it by adding u32 msg_enable to
> the private struct ei_device. Now each 8390 ethernet instance has a per-device
> logging variable.
> 
> Changed older style printk() calls to more canonical forms.

Hi again Matthew:

You're going to have to resend this in a few weeks as
net-next is not currently open for non-regression
patches.  Right now is what's called a "merge window"
after the last "official" release and before the
"release candidate" releases.  Most of the development
trees are kept unchanged/solidified before at this
point in time.

Now, just some trivial notes:

> diff --git a/drivers/net/ethernet/8390/apne.c b/drivers/net/ethernet/8390/apne.c
[]
> @@ -133,11 +139,11 @@ struct net_device * __init apne_probe(int unit)
>  	if ( !(AMIGAHW_PRESENT(PCMCIA)) )
>  		return ERR_PTR(-ENODEV);
>  
> -	printk("Looking for PCMCIA ethernet card : ");
> +	printk(KERN_INFO "Looking for PCMCIA ethernet card : ");
>  
>  	/* check if a card is inserted */
>  	if (!(PCMCIA_INSERTED)) {
> -		printk("NO PCMCIA card inserted\n");
> +		printk(KERN_INFO "NO PCMCIA card inserted\n");

This should be pr_cont/printk(KERN_CONT

Please check whether or not each of the below printks is
actually a continuation of this "looking for..." or is a
standalone line.

Mark the continuations as pr_cont/KERN_CONT.

>  		return ERR_PTR(-ENODEV);
>  	}
>  
> @@ -148,6 +154,8 @@ struct net_device * __init apne_probe(int unit)
>  		sprintf(dev->name, "eth%d", unit);
>  		netdev_boot_setup_check(dev);
>  	}
> +	ei_local = netdev_priv(dev);
> +	ei_local->msg_enable = apne_debug;
>  
>  	/* disable pcmcia irq for readtuple */
>  	pcmcia_disable_irq();
> @@ -155,14 +163,14 @@ struct net_device * __init apne_probe(int unit)
>  #ifndef MANUAL_CONFIG
>  	if ((pcmcia_copy_tuple(CISTPL_FUNCID, tuple, 8) < 3) ||
>  		(tuple[2] != CISTPL_FUNCID_NETWORK)) {
> -		printk("not an ethernet card\n");
> +		netdev_info(dev, "not an ethernet card\n");

likely this should be pr_cont too.

> -	printk("ethernet PCMCIA card inserted\n");
> +	netdev_info(dev, "ethernet PCMCIA card inserted\n");

another pr_cont

etc...

 
>  	if (!init_pcmcia()) {
>  		/* XXX: shouldn't we re-enable irq here? */
> @@ -204,11 +212,12 @@ static int __init apne_probe1(struct net_device *dev, int ioaddr)
>      int neX000, ctron;
>  #endif
>      static unsigned version_printed;
> +    struct ei_device *ei_local = netdev_priv(dev);
>  
> -    if (ei_debug  &&  version_printed++ == 0)
> -	printk(version);
> +    if ((apne_debug & NETIF_MSG_DRV) && (version_printed++ == 0))
> +		netdev_info(dev, version);

generally anything with a debug test should
likely be emitted at KERN_DEBUG level.

cheers, Joe
