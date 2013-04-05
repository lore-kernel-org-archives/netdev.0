From: Werner Almesberger <werner-SEdMjqphH88wryQfseakQg@public.gmane.org>
Subject: Re: [PATCH 2/2] at86rf230: change irq handling
 to prevent lockups with edge type irq
Date: Fri, 5 Apr 2013 00:59:49 -0300
Message-ID: <20130405035949.GC29789@ws>
References: <cover.1365107512.git.sascha@ps.nvbi.de>
	<57c67195742f5e7482dc57f5a05b6d69156b00d2.1365107512.git.sascha@ps.nvbi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Sascha Herrmann <sascha-2k69yqSu1NaELgA04lAiVw@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <57c67195742f5e7482dc57f5a05b6d69156b00d2.1365107512.git.sascha-2k69yqSu1NaELgA04lAiVw@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Sascha Herrmann wrote:
> -	rc = request_irq(spi->irq, at86rf230_isr, IRQF_SHARED,
> +	rc = request_irq(spi->irq, at86rf230_isr,
> +			 IRQF_SHARED | IRQF_TRIGGER_RISING,

To clarify the purpose of your patch, I think it's only needed
for platforms that don't support level-triggered interrupts.
I.e., if you used IRQF_TRIGGER_HIGH (and happened to have a
platform that supports it, which you said on IRC you don't),
the existing code should work fine. Correct ?

I wonder if it wouldn't be better to make the code work with
both edge and level interrupts instead of having to choose.

E.g., this sort of loop in at86rf230_irqwork should work with
either:

	while (1) {
		irq = read_and_clear_interrupt();
		...
		if (!test_and_clear_bit(0, &lp->irq_disabled))
			break;
		enable_irq();
	}
	lp->irq_busy = 0; /* allow _xmit */

Disadvantage: you get extra IRQ_STATUS reads, which has a
slight penalty, given that all this is on SPI.

To achieve perfection, at86rf230_probe could try all four
possible trigger modes, pick one the platform supports, and
set TRX_CTRL_1.IRQ_POLARITY accordingly.

In any case, I gave your patch very light testing on ATBEN and
it performed as good as the original code.

- Werner

------------------------------------------------------------------------------
Minimize network downtime and maximize team effectiveness.
Reduce network management and security costs.Learn how to hire 
the most talented Cisco Certified professionals. Visit the 
Employer Resources Portal
http://www.cisco.com/web/learning/employer_resources/index.html
