From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Sat, 22 Aug 2009 04:48:52 -0700
Message-ID: <m1iqggf4rf.fsf@fess.ebiederm.org>
References: <200903041828.49972.m.bueker@berlin.de>
	<1242001754.4093.12.camel@obelisk.thedillows.org>
	<200905112248.44868.mb@bu3sch.de> <200905112310.08534.mb@bu3sch.de>
	<1242077392.3716.15.camel@lap75545.ornl.gov>
	<4A09DC3E.2080807@googlemail.com>
	<1242268709.4979.7.camel@obelisk.thedillows.org>
	<4A0C6504.8000704@googlemail.com>
	<1242328457.32579.12.camel@lap75545.ornl.gov>
	<4A0C7443.1010000@googlemail.com>
	<1243042174.3580.23.camel@obelisk.thedillows.org>
	<m1skfkrik2.fsf@fess.ebiederm.org>
	<1250895567.23419.1.camel@obelisk.thedillows.org>
	<1250897657.23419.5.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Riepe <michael.riepe@googlemail.com>,
	Michael Buesch <mb@bu3sch.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?utf-8?Q?B=C3=BCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933292AbZHVLtB@vger.kernel.org>
In-Reply-To: <1250897657.23419.5.camel@obelisk.thedillows.org> (David Dillow's message of "Fri\, 21 Aug 2009 19\:34\:17 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Dillow <dave@thedillows.org> writes:

>
> Re-looking at the code, I'd guess that some IRQ status line is getting
> stuck high, but I don't see why -- we should acknowledge all outstanding
> interrupts each time through the loop, whether we care about them or
> not.
>
> Could reproduce a problem with the following patch applied, and send the
> full dmesg, please?

Here is what I get.

r8169 screaming irq status 00000085 mask 0000ffff event 0000803f napi 0000001d

Eric

> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index b82780d..46cb05a 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -3556,6 +3556,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
>  	void __iomem *ioaddr = tp->mmio_addr;
>  	int handled = 0;
>  	int status;
> +	int count = 0;
>  
>  	/* loop handling interrupts until we have no new ones or
>  	 * we hit a invalid/hotplug case.
> @@ -3564,6 +3565,15 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
>  	while (status && status != 0xffff) {
>  		handled = 1;
>  
> +		if (count++ > 100) {
> +			printk_once("r8169 screaming irq status %08x "
> +				"mask %08x event %08x napi %08x\n",
> +				status, tp->intr_mask, tp->intr_event,
> +				tp->napi_event);
> +			break;
> +		}
> +
> +
>  		/* Handle all of the error cases first. These will reset
>  		 * the chip, so just exit the loop.
>  		 */
