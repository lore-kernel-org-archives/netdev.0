From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch for 2.6.27? 5/5] forcedeth: fix kexec regression
Date: Wed, 27 Aug 2008 05:48:02 -0400
Message-ID: <48B522D2.4090605@garzik.org>
References: <200808202334.m7KNYcff005038@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rjw@sisk.pl, aabdulla@nvidia.com,
	yhlu.kernel@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58445 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754153AbYH0JsH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 05:48:07 -0400
In-Reply-To: <200808202334.m7KNYcff005038@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Rafael J. Wysocki <rjw@sisk.pl>
> 
> Fix regression tracked as http://bugzilla.kernel.org/show_bug.cgi?id=11361
> and caused by commit f735a2a1a4f2a0f5cd823ce323e82675990469e2 ("[netdrvr]
> forcedeth: setup wake-on-lan before shutting down") that makes network
> adapters integrated into the NVidia MCP55 chipsets fail to work in kexeced
> kernels.  The problem appears to be that if the adapter is put into D3_hot
> during ->shutdown(), it cannot be brought back into D0 after kexec (ref. 
> http://marc.info/?l=linux-kernel&m=121900062814967&w=4).  Therefore, only
> put forcedeth into D3 during ->shutdown() if the system is to be powered
> off.
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> Tested-by: Yinghai Lu <yhlu.kernel@gmail.com>
> Cc: Ayaz Abdulla <aabdulla@nvidia.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/forcedeth.c |    8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff -puN drivers/net/forcedeth.c~forcedeth-fix-kexec-regression drivers/net/forcedeth.c
> --- a/drivers/net/forcedeth.c~forcedeth-fix-kexec-regression
> +++ a/drivers/net/forcedeth.c
> @@ -5990,10 +5990,12 @@ static void nv_shutdown(struct pci_dev *
>  	if (netif_running(dev))
>  		nv_close(dev);
>  
> -	pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
> -	pci_enable_wake(pdev, PCI_D3cold, np->wolenabled);
>  	pci_disable_device(pdev);
> -	pci_set_power_state(pdev, PCI_D3hot);
> +	if (system_state == SYSTEM_POWER_OFF) {
> +		if (pci_enable_wake(pdev, PCI_D3cold, np->wolenabled))
> +			pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
> +		pci_set_power_state(pdev, PCI_D3hot);
> +	}
>  }

All,

Is this the final version of this patch?

	Jeff



