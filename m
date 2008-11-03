From: Manuel Lauss <mano@roarinelk.homelinux.net>
Subject: Re: smc91x: commit 51ac3beffd4afaea4350526cf01fe74aaff25eff breaks
	compilation
Date: Mon, 3 Nov 2008 09:17:24 +0100
Message-ID: <20081103081724.GE18445@roarinelk.homelinux.net>
References: <20081103071720.GB18153@roarinelk.homelinux.net> <20081103.000438.62068550.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vapier@gentoo.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fnoeppeil48.netpark.at ([217.175.205.176]:56640 "EHLO
	roarinelk.homelinux.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754626AbYKCIR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 03:17:26 -0500
Content-Disposition: inline
In-Reply-To: <20081103.000438.62068550.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 03, 2008 at 12:04:38AM -0800, David Miller wrote:
> From: Manuel Lauss <mano@roarinelk.homelinux.net>
> Date: Mon, 3 Nov 2008 08:17:20 +0100
> 
> > your commit 51ac3beffd4afaea4350526cf01fe74aaff25eff  causes this
> > compile failure on my SH and MIPS testboards (2.6.28-rc3):
> > 
> >  CC      drivers/net/smc91x.o
> > /mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c: In function 'smc_request_attrib':
> 
> That's beyond awful.
> 
> Hiding the "lp" refernce behind that sneaky SMC_IO_SHIFT macro?
> That effects a whole slew of macros and interfaces indirectly.
> What a mess.
> 
> It means that these local 'lp' variables unused in some confirations
> and used in some others.
> 
> I'll fix this like so:
> 
> commit 66935e42ddc544eec4d8d5d86f3de322766888d5
> Author: David S. Miller <davem@davemloft.net>
> Date:   Mon Nov 3 00:04:24 2008 -0800
> 
>     SMC91x: Fix compilation on some platforms.
>     
>     This reverts 51ac3beffd4afaea4350526cf01fe74aaff25eff ('SMC91x: delete
>     unused local variable "lp"') and adds __maybe_unused markers to these
>     (potentially) unused variables.
>     
>     The issue is that in some configurations SMC_IO_SHIFT evaluates
>     to '(lp->io_shift)', but in some others it's plain '0'.
>     
>     Based upon a build failure report from Manuel Lauss.
>     
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
> index 6f9895d..d88081c 100644
> --- a/drivers/net/smc91x.c
> +++ b/drivers/net/smc91x.c
> @@ -2060,6 +2060,7 @@ static int smc_request_attrib(struct platform_device *pdev,
>  			      struct net_device *ndev)
>  {
>  	struct resource * res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "smc91x-attrib");
> +	struct smc_local *lp = netdev_priv(ndev) __maybe_unused;
>  
>  	if (!res)
>  		return 0;
> @@ -2074,6 +2075,7 @@ static void smc_release_attrib(struct platform_device *pdev,
>  			       struct net_device *ndev)
>  {
>  	struct resource * res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "smc91x-attrib");
> +	struct smc_local *lp = netdev_priv(ndev) __maybe_unused;
>  
>  	if (res)
>  		release_mem_region(res->start, ATTRIB_SIZE);

That throws another error:

/mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c: In function 'smc_request_attrib':
/mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2063: error: expected ',' or ';' before '__attribute__'
/mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c: In function 'smc_release_attrib':
/mnt/work/sh7760/kernel/linux-2.6.git/drivers/net/smc91x.c:2078: error: expected ',' or ';' before '__attribute__'

	Manuel Lauss
