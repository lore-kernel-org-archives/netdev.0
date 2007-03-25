From: David Miller <davem@davemloft.net>
Subject: Re: [TG3 2/3]: Exit irq handler during chip reset.
Date: Sat, 24 Mar 2007 20:58:26 -0700 (PDT)
Message-ID: <20070324.205826.59027243.davem@davemloft.net>
References: <1174601067.9753.42.camel@dell>
	<20070322232048.GC3333@sykes.suse.de>
	<1174695187.4834.9.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bwalle@suse.de, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54107
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932687AbXCYD6i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Mar 2007 23:58:38 -0400
In-Reply-To: <1174695187.4834.9.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 23 Mar 2007 16:13:07 -0800

> [TG3]: Exit irq handler during chip reset.
> 
> On most tg3 chips, the memory enable bit in the PCI command register
> gets cleared during chip reset and must be restored before accessing
> PCI registers using memory cycles.  The chip does not generate
> interrupt during chip reset, but the irq handler can still be called
> because of irq sharing or irqpoll.  Reading a register in the irq
> handler can cause a master abort in this scenario and may result in a
> crash on some architectures.
> 
> Use the TG3_FLAG_CHIP_RESETTING flag to tell the irq handler to exit
> without touching any registers.  The checking of the flag is in the
> "slow" path of the irq handler and will not affect normal performance.
> The msi handler is not shared and therefore does not require checking
> the flag.
> 
> Thanks to Bernhard Walle <bwalle@suse.de> for reporting the problem.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, except I fixed up some weird tabbing on this line:

> @@ -3568,32 +3568,34 @@ static irqreturn_t tg3_interrupt(int irq, void *dev_id)
 ...
> +	} else {
> +		/* No work, shared interrupt perhaps?  re-enable
> +		 * interrupts, and flush that PCI write
> +		 */
> +		tw32_mailbox_f(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
> +		     	0x00000000);
                ^^^^^^^^

There are two tabs, some space characters, then a final tab,
and it doesn't even make the argument match up to the openning
parenthesis on the previous line :-)
