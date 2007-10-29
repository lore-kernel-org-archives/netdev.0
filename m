From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] pegasos_eth.c: Fix compile error over MV643XX_ defines
Date: Mon, 29 Oct 2007 23:47:14 +0100
Message-ID: <20071029224714.GA23975@xi.wantstofly.org>
References: <20071029212729.GA4074@pogo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Jeff Garzik <jeff@garzik.org>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Dale Farnsworth <dale@farnsworth.org>
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:45977 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446AbXJ2WrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 18:47:17 -0400
Content-Disposition: inline
In-Reply-To: <20071029212729.GA4074@pogo>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 29, 2007 at 05:27:29PM -0400, Luis R. Rodriguez wrote:

> This commit made an incorrect assumption:
> --
> Author: Lennert Buytenhek <buytenh@wantstofly.org>
>  Date:   Fri Oct 19 04:10:10 2007 +0200
> 
>     mv643xx_eth: Move ethernet register definitions into private header
>     
>     Move the mv643xx's ethernet-related register definitions from
>     include/linux/mv643xx.h into drivers/net/mv643xx_eth.h, since
>     they aren't of any use outside the ethernet driver.
>     
>     Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
>     Acked-by: Tzachi Perelstein <tzachi@marvell.com>
>     Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
> --
> 
> arch/powerpc/platforms/chrp/pegasos_eth.c made use of a 3 defines there.
> 
> mcgrof@pogo:~/devel/wireless-2.6$ git-describe 
> 
> v2.6.24-rc1-138-g0119130
> 
> This patch fixes this by internalizing 3 defines onto pegasos which are
> simply no longer available elsewhere. Without this your compile will fail
> whenever you enable 'Common Hardware Reference Platform (CHRP) based machines',
>
> [...]
> 
> diff --git a/arch/powerpc/platforms/chrp/pegasos_eth.c b/arch/powerpc/platforms/chrp/pegasos_eth.c
> index 5bcc58d..1fc9e8c 100644
> --- a/arch/powerpc/platforms/chrp/pegasos_eth.c
> +++ b/arch/powerpc/platforms/chrp/pegasos_eth.c
> @@ -24,6 +24,9 @@
>  #define PEGASOS2_SRAM_BASE_ETH0			(PEGASOS2_SRAM_BASE)
>  #define PEGASOS2_SRAM_BASE_ETH1			(PEGASOS2_SRAM_BASE_ETH0 + (PEGASOS2_SRAM_SIZE / 2) )
>  
> +#define PEGASOS2_ETH_BAR_4			0x2220
> +#define PEGASOS2_ETH_SIZE_REG_4			0x2224
> +#define PEGASOS2_ETH_BASE_ADDR_ENABLE_REG	0x2290
>  
>  #define PEGASOS2_SRAM_RXRING_SIZE		(PEGASOS2_SRAM_SIZE/4)
>  #define PEGASOS2_SRAM_TXRING_SIZE		(PEGASOS2_SRAM_SIZE/4)
> @@ -147,13 +150,13 @@ static int Enable_SRAM(void)
>  
>  	ALong = 0x02;
>  	ALong |= PEGASOS2_SRAM_BASE & 0xffff0000;
> -	MV_WRITE(MV643XX_ETH_BAR_4, ALong);
> +	MV_WRITE(PEGASOS2_ETH_BAR_4, ALong);
>  
> -	MV_WRITE(MV643XX_ETH_SIZE_REG_4, (PEGASOS2_SRAM_SIZE-1) & 0xffff0000);
> +	MV_WRITE(PEGASOS2_ETH_SIZE_REG_4, (PEGASOS2_SRAM_SIZE-1) & 0xffff0000);
>  
> -	MV_READ(MV643XX_ETH_BASE_ADDR_ENABLE_REG, ALong);
> +	MV_READ(PEGASOS2_ETH_BASE_ADDR_ENABLE_REG, ALong);
>  	ALong &= ~(1 << 4);
> -	MV_WRITE(MV643XX_ETH_BASE_ADDR_ENABLE_REG, ALong);
> +	MV_WRITE(PEGASOS2_ETH_BASE_ADDR_ENABLE_REG, ALong);
>  
>  #ifdef BE_VERBOSE
>  	printk("Pegasos II/Marvell MV64361: register unmapped\n");

Al Viro sent a patch for this breakage a couple of days ago:

	http://marc.info/?l=linux-kernel&m=119351541706811&w=2

(FWIW, I think that code outside of mv643xx_eth.c should not be poking
into the mv643xx's registers directly.  Ideally, this info should just
be passed by pegasos_eth into mv643xx_eth via platform data, and then
mv643xx_eth can write the relevant hardware registers.)
