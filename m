From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] declance: Fix 64-bit compilation warnings
Date: Sat, 28 Jun 2014 16:06:58 -0700
Message-ID: <1403996818.9064.48.camel@joe-AO725>
References: <alpine.LFD.2.11.1406282329040.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0038.hostedemail.com ([216.40.44.38]:36710 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750957AbaF1XHC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jun 2014 19:07:02 -0400
In-Reply-To: <alpine.LFD.2.11.1406282329040.15455@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-06-28 at 23:57 +0100, Maciej W. Rozycki wrote:
> This fixes compiler warnings:
> 
> drivers/net/ethernet/amd/declance.c: In function 'lance_init_ring':
> drivers/net/ethernet/amd/declance.c:478: warning: format '%8.8x' expects type 'unsigned int', but argument 3 has type 'long unsigned int'
> drivers/net/ethernet/amd/declance.c:487: warning: format '%8.8x' expects type 'unsigned int', but argument 3 has type 'long unsigned int'
> drivers/net/ethernet/amd/declance.c:503: warning: cast from pointer to integer of different size
> drivers/net/ethernet/amd/declance.c:520: warning: cast from pointer to integer of different size
> 
> in 64-bit compilation.  Where the value printed is an offset (whose range 
> will always fit) the cast uses a 32-bit type, otherwise, where it is a 
> host memory address, the `long' type is used and the width of the number 
> printed adjusted according to the size of this type.
> 
> Tested with both 32-bit and 64-bit compilation, as well as at the run time 
> (with the debug messages affected enabled).
[]
> Index: net-next-20140424-4maxp64/drivers/net/ethernet/amd/declance.c
[]
> @@ -499,8 +499,9 @@ static void lance_init_ring(struct net_d
>  						/* The ones required by tmd2 */
>  		*lib_ptr(ib, btx_ring[i].misc, lp->type) = 0;
>  		if (i < 3 && ZERO)
> -			printk("%d: 0x%8.8x(0x%8.8x)\n",
> -			       i, leptr, (uint)lp->tx_buf_ptr_cpu[i]);
> +			printk("%d: 0x%8.8x(%#0*lx)\n",
> +			       i, leptr, (int)sizeof(long),
> +			       (long)lp->tx_buf_ptr_cpu[i]);

You need to adjust the "*" and sizeof(long) with +2 for the
0x prefix in the output length here.
