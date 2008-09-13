From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Don't take the mdio_lock in atl1e_probe
Date: Sat, 13 Sep 2008 15:55:54 -0400
Message-ID: <48CC1ACA.6070101@garzik.org>
References: <20080812131314.GZ8618@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiong.huang@atheros.com, jie.yang@atheros.com,
	netdev@vger.kernel.org
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52813 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753372AbYIMTz7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 15:55:59 -0400
In-Reply-To: <20080812131314.GZ8618@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matthew Wilcox wrote:
> Lockdep warns about the mdio_lock taken with interrupts enabled then later
> taken from interrupt context.  Initially, I considered changing these
> to spin_lock_irq/spin_unlock_irq, but then I looked at atl1e_phy_init()
> and saw that it calls msleep().  Sleeping while holding a spinlock is
> not allowed either.
> 
> In the probe path, we haven't registered the interrupt handler, so
> it can't poke at this card yet.  It's before we call register_netdev(),
> so I don't think any other threads can reach this card either.  If I'm
> right, we don't need a spinlock at all.
> 
> Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
> 
> diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
> index 82d7be1..ba22a51 100644
> --- a/drivers/net/atl1e/atl1e_main.c
> +++ b/drivers/net/atl1e/atl1e_main.c
> @@ -2389,9 +2389,7 @@ static int __devinit atl1e_probe(struct pci_dev *pdev,
>  	}
>  
>  	/* Init GPHY as early as possible due to power saving issue  */
> -	spin_lock(&adapter->mdio_lock);
>  	atl1e_phy_init(&adapter->hw);
> -	spin_unlock(&adapter->mdio_lock);
>  	/* reset the controller to
>  	 * put the device in a known good starting state */

applied


