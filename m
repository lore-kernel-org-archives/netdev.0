From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.19] AT91RM9200 Ethernet update 1
Date: Mon, 04 Dec 2006 18:41:58 -0500
Message-ID: <4574B246.2090700@pobox.com>
References: <1165235217.4525.100.camel@fuzzie.sanpeople.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39544 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967835AbWLDXmD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 18:42:03 -0500
To: Andrew Victor <andrew@sanpeople.com>
In-Reply-To: <1165235217.4525.100.camel@fuzzie.sanpeople.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


NAK.  see inline comments in quoted text.


Andrew Victor wrote:

Please fix your email's subject line per 
http://linux.yyz.us/patch-format.html  The subject is a one-line summary 
that tells us not only what driver is being update, but also summarizes 
the changes in the patch.  "update 1" tells us nothing.

Your email subject line is the one-summary of this change that will be 
copied directly into the kernel source code repository, archived for all 
eternity.


> This patch is an update to the Atmel AT91RM9200 Ethernet driver.

Remove this line.  Your email's body is copied directly into the kernel 
changelog, and it's redundant.  From your subject line, we already know 
what this is updating.


> 1. Remove the global 'at91_dev' variable. 
> 2. Move the global 'check_timer' variable into the private data
> structure.
> 
> 
> Signed-off-by: Andrew Victor <andrew@sanpeople.com>
> 
> 
> diff -urN linux-2.6.19-final.orig/drivers/net/arm/at91_ether.c linux-2.6.19-final/drivers/net/arm/at91_ether.c
> --- linux-2.6.19-final.orig/drivers/net/arm/at91_ether.c	Sat Dec  2 17:28:27 2006
> +++ linux-2.6.19-final/drivers/net/arm/at91_ether.c	Mon Dec  4 14:13:01 2006
> @@ -41,9 +41,6 @@
>  #define DRV_NAME	"at91_ether"
>  #define DRV_VERSION	"1.0"
>  
> -static struct net_device *at91_dev;
> -
> -static struct timer_list check_timer;
>  #define LINK_POLL_INTERVAL	(HZ)
>  
>  /* ..................................................................... */
> @@ -252,8 +249,8 @@
>  		 * PHY doesn't have an IRQ pin (RTL8201, DP83847, AC101L),
>  		 * or board does not have it connected.
>  		 */
> -		check_timer.expires = jiffies + LINK_POLL_INTERVAL;
> -		add_timer(&check_timer);
> +		lp->check_timer.expires = jiffies + LINK_POLL_INTERVAL;
> +		add_timer(&lp->check_timer);

consider using mod_timer()


>  		return;
>  	}
>  
> @@ -300,7 +297,7 @@
>  
>  	irq_number = lp->board_data.phy_irq_pin;
>  	if (!irq_number) {
> -		del_timer_sync(&check_timer);
> +		del_timer_sync(&lp->check_timer);
>  		return;
>  	}
>  
> @@ -362,13 +359,14 @@
>  static void at91ether_check_link(unsigned long dev_id)
>  {
>  	struct net_device *dev = (struct net_device *) dev_id;
> +	struct at91_private *lp = (struct at91_private *) dev->priv;
>  
>  	enable_mdi();
>  	update_linkspeed(dev, 1);
>  	disable_mdi();
>  
> -	check_timer.expires = jiffies + LINK_POLL_INTERVAL;
> -	add_timer(&check_timer);
> +	lp->check_timer.expires = jiffies + LINK_POLL_INTERVAL;
> +	add_timer(&lp->check_timer);

ditto


>  }
>  
>  /* ......................... ADDRESS MANAGEMENT ........................ */
> @@ -939,9 +937,6 @@
>  	unsigned int val;
>  	int res;
>  
> -	if (at91_dev)			/* already initialized */
> -		return 0;
> -
>  	dev = alloc_etherdev(sizeof(struct at91_private));
>  	if (!dev)
>  		return -ENOMEM;
> @@ -1024,7 +1019,6 @@
>  		dma_free_coherent(NULL, sizeof(struct recv_desc_bufs), lp->dlist, (dma_addr_t)lp->dlist_phys);
>  		return res;
>  	}
> -	at91_dev = dev;
>  
>  	/* Determine current link speed */
>  	spin_lock_irq(&lp->lock);
> @@ -1036,9 +1030,9 @@
>  
>  	/* If board has no PHY IRQ, use a timer to poll the PHY */
>  	if (!lp->board_data.phy_irq_pin) {
> -		init_timer(&check_timer);
> -		check_timer.data = (unsigned long)dev;
> -		check_timer.function = at91ether_check_link;
> +		init_timer(&lp->check_timer);
> +		lp->check_timer.data = (unsigned long)dev;
> +		lp->check_timer.function = at91ether_check_link;
>  	}
>  
>  	/* Display ethernet banner */
> @@ -1115,15 +1109,16 @@
>  
>  static int __devexit at91ether_remove(struct platform_device *pdev)
>  {
> -	struct at91_private *lp = (struct at91_private *) at91_dev->priv;
> +	struct net_device *dev = platform_get_drvdata(pdev);
> +	struct at91_private *lp = (struct at91_private *) dev->priv;

use netdev_priv()


> -	unregister_netdev(at91_dev);
> -	free_irq(at91_dev->irq, at91_dev);
> +	unregister_netdev(dev);
> +	free_irq(dev->irq, dev);
>  	dma_free_coherent(NULL, sizeof(struct recv_desc_bufs), lp->dlist, (dma_addr_t)lp->dlist_phys);
>  	clk_put(lp->ether_clk);
>  
> -	free_netdev(at91_dev);
> -	at91_dev = NULL;
> +	platform_set_drvdata(pdev, NULL);
> +	free_netdev(dev);
>  	return 0;
>  }
>  
> @@ -1131,8 +1126,8 @@
>  
>  static int at91ether_suspend(struct platform_device *pdev, pm_message_t mesg)
>  {
> -	struct at91_private *lp = (struct at91_private *) at91_dev->priv;
>  	struct net_device *net_dev = platform_get_drvdata(pdev);
> +	struct at91_private *lp = (struct at91_private *) net_dev->priv;

ditto


>  	int phy_irq = lp->board_data.phy_irq_pin;
>  
>  	if (netif_running(net_dev)) {
> @@ -1149,8 +1144,8 @@
>  
>  static int at91ether_resume(struct platform_device *pdev)
>  {
> -	struct at91_private *lp = (struct at91_private *) at91_dev->priv;
>  	struct net_device *net_dev = platform_get_drvdata(pdev);
> +	struct at91_private *lp = (struct at91_private *) net_dev->priv;

ditto


>  	int phy_irq = lp->board_data.phy_irq_pin;
>  
>  	if (netif_running(net_dev)) {
> diff -urN linux-2.6.19-final.orig/drivers/net/arm/at91_ether.h linux-2.6.19-final/drivers/net/arm/at91_ether.h
> --- linux-2.6.19-final.orig/drivers/net/arm/at91_ether.h	Sat Dec  2 17:26:41 2006
> +++ linux-2.6.19-final/drivers/net/arm/at91_ether.h	Mon Dec  4 14:12:30 2006
> @@ -87,6 +87,7 @@
>  	spinlock_t lock;			/* lock for MDI interface */
>  	short phy_media;			/* media interface type */
>  	unsigned short phy_address;		/* 5-bit MDI address of PHY (0..31) */
> +	struct timer_list check_timer;		/* Poll link status */
>  
>  	/* Transmit */
>  	struct sk_buff *skb;			/* holds skb until xmit interrupt completes */
> 
> 
> 
> 

