From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: [PATCH] niu: bitwise or does not imply ordering
Date: Sun, 16 Nov 2008 16:32:05 +0100
Message-ID: <1226849525.8189.6.camel@localhost.localdomain>
References: <312268717986b8b45674.846930886.miltonm@bga.com>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, segher@kernel.crashing.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Milton Miller <miltonm@bga.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:45762 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752114AbYKPPcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2008 10:32:48 -0500
In-Reply-To: <312268717986b8b45674.846930886.miltonm@bga.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I have tested it on the actual hardware, it works...

I actually agree that we should make it explicit, eventhough DaveM seems
to disagree on the netdev list.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
Tested-by: Jesper Dangaard Brouer <hawk@comx.dk>


On Sun, 2008-11-16 at 15:43 -0600, Milton Miller wrote:
> commit e23a59e1ca6d177a57a7791b3629db93ff1d9813 (niu: Fix readq
> implementation when architecture does not provide one.) reordered the
> arguments to a bitwise or to change the emitted code.   However, C does
> not guarantee the evaluation order.
> 
> Split the line into two statements.  While there, reduce some parens
> by using two variables.
> 
> Signed-off-By: Milton Miller <miltonm@bga.com>
> Acked-by: Segher Boessenkool <segher@kernel.crashing.org>
> ---
> complie tested on ppc6xx_defconfig, I have no hardware.
> making the vars u64 saves the later cast with no signficiant codegen difference
> 
> Index: work.git/drivers/net/niu.c
> ===================================================================
> --- work.git.orig/drivers/net/niu.c	2008-11-16 01:34:44.000000000 -0600
> +++ work.git/drivers/net/niu.c	2008-11-16 02:59:06.000000000 -0600
> @@ -51,7 +51,18 @@ MODULE_VERSION(DRV_MODULE_VERSION);
>  #ifndef readq
>  static u64 readq(void __iomem *reg)
>  {
> -	return ((u64) readl(reg)) | (((u64) readl(reg + 4UL)) << 32);
> +	u64 l, u;
> +	/*
> +	 * The TX_CS register has counters in the upper 32-bits and state
> +	 * bits in the lower 32-bits.  A read clears the state bits.
> +	 *
> +	 * Therefore this driver must read the lower word then the upper one
> +	 * when the architecture doesn't have an atomic readq.
> +	 */
> +	l = readl(reg);
> +	u = readl(reg + 4UL);
> +
> +	return l | (u << 32);
>  }
>  
>  static void writeq(u64 val, void __iomem *reg)
> 
-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
