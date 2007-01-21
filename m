From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [BUG] e100: eth0 appers many times in /proc/interrupts after
 resume
Date: Sun, 21 Jan 2007 13:45:27 -0800
Message-ID: <45B3DEF7.8020505@intel.com>
References: <1167520557.2566.23.camel@nigel.suspend2.net> <1167571281.7175.1.camel@localhost> <1167599458.2662.8.camel@nigel.suspend2.net> <1167605481.12328.0.camel@localhost> <1167607994.2662.39.camel@nigel.suspend2.net> <1167644970.7142.6.camel@localhost> <1168317278.6948.9.camel@nigel.suspend2.net> <1168448689.7430.1.camel@localhost> <1168463852.3205.1.camel@nigel.suspend2.net> <1169407062.1932.4.camel@localhost> <20070121212209.GB8958@slug>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrei Popa <andrei.popa@i-neo.ro>, linux-kernel@vger.kernel.org,
	nigel@suspend2.net, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:37803 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751683AbXAUVpd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Jan 2007 16:45:33 -0500
To: Frederik Deweerdt <deweerdt@free.fr>
In-Reply-To: <20070121212209.GB8958@slug>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Frederik Deweerdt wrote:
> On Sun, Jan 21, 2007 at 09:17:41PM +0200, Andrei Popa wrote:
>> It's the 10th resume and in /proc/interrupts eth0 appers 10 times.
> 
> The e100_resume() function should be calling netif_device_detach and
> free_irq. Could you try the following (compile tested) patch?

I just fixed suspend/shutdown for e100 in 2.6.19, not sure why the problem still 
shows up. Since it's a driver/net issue, you should CC netdev on it tho, 
otherwise it might go unnoticed.

I'll open up the can-o-worms on this issue and see what's up with it.

I'm not so sure that this patch is OK, and I wonder why it stopped working, 
because I spent quite some time fixing it only a few months ago. Did swsup 
change again? sigh...

Auke

> 
> Signed-off-by: Frederik Deweerdt <frederik.deweerdt@gmail.com>
> 
> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> index 2fe0445..0c376e4 100644
> --- a/drivers/net/e100.c
> +++ b/drivers/net/e100.c
> @@ -2671,6 +2671,7 @@ static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
>  	del_timer_sync(&nic->watchdog);
>  	netif_carrier_off(nic->netdev);
>  
> +	netif_device_detach(netdev);
>  	pci_save_state(pdev);
>  
>  	if ((nic->flags & wol_magic) | e100_asf(nic)) {
> @@ -2682,6 +2683,7 @@ static int e100_suspend(struct pci_dev *pdev, pm_message_t state)
>  	}
>  
>  	pci_disable_device(pdev);
> +	free_irq(pdev->irq, netdev);
>  	pci_set_power_state(pdev, PCI_D3hot);
>  
>  	return 0;
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
