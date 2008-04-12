From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] natsemi: fix for PPC 44x platforms
Date: Sat, 12 Apr 2008 04:36:17 -0400
Message-ID: <48007481.3040102@pobox.com>
References: <200804082331.23270.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58502 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755642AbYDLIgV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 04:36:21 -0400
In-Reply-To: <200804082331.23270.sshtylyov@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sergei Shtylyov wrote:
> The driver stores the the PCI resource address into 'unsigned long' variable
> before calling ioremap() on it. This warrants kernel oops when the registers
> are accessed on PPC 44x platforms which (being 32-bit) have PCI memory space
> mapped beyond 4 GB.
> 
> The arch/ppc/ kernel has a fixup in ioremap() that creates an illusion of the
> PCI I/O and memory resources are mapped below 4 GB, but arch/powerpc/ code got
> rid of this trick, having instead CONFIG_RESOURCES_64BIT enabled.
> 
> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>
> 
> ---
> This is the same issue as the one that has been recently addressed by commits
> 3c34ac36ac1084e571ef9b6fb1d6a5b10ccc1fd0 (e1000: Fix for 32 bits platforms with
> 64 bits resources) and c976816b6e901341ec3c4653147316c15549a1c4 (siimage: fix
> kernel oops on PPC 44x).  The patch has only been compile tested though...
> 
>  drivers/net/natsemi.c |    7 ++++---
>  1 files changed, 4 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6/drivers/net/natsemi.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/natsemi.c
> +++ linux-2.6/drivers/net/natsemi.c
> @@ -786,7 +786,8 @@ static int __devinit natsemi_probe1 (str
>  	struct netdev_private *np;
>  	int i, option, irq, chip_idx = ent->driver_data;
>  	static int find_cnt = -1;
> -	unsigned long iostart, iosize;
> +	resource_size_t iostart;
> +	unsigned long iosize;
>  	void __iomem *ioaddr;
>  	const int pcibar = 1; /* PCI base address register */
>  	int prev_eedata;
> @@ -946,9 +947,9 @@ static int __devinit natsemi_probe1 (str
>  		goto err_create_file;
>  
>  	if (netif_msg_drv(np)) {
> -		printk(KERN_INFO "natsemi %s: %s at %#08lx "
> +		printk(KERN_INFO "natsemi %s: %s at %#08llx "
>  		       "(%s), %s, IRQ %d",
> -		       dev->name, natsemi_pci_info[chip_idx].name, iostart,
> +		       dev->name, natsemi_pci_info[chip_idx].name, (u64)iostart,
>  		       pci_name(np->pci_dev), print_mac(mac, dev->dev_addr), irq);
>  		if (dev->if_port == PORT_TP)

ACK, with the cast fixed (to long long)


