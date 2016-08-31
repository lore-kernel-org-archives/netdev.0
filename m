From: Marc Zyngier <marc.zyngier@arm.com>
Subject: Re: [Patch v3 03/11] irqchip: axi-intc: Add support for parent intc
Date: Wed, 31 Aug 2016 17:57:21 +0100
Message-ID: <57C70C71.3060603@arm.com>
References: <1472661352-11983-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1472661352-11983-4-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: soren.brinkmann@xilinx.com, linux-kernel@vger.kernel.org,
        linux-mips@linux-mips.org, michal.simek@xilinx.com,
        netdev@vger.kernel.org
To: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>,
        monstr@monstr.eu, ralf@linux-mips.org, tglx@linutronix.de,
        jason@lakedaemon.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472661352-11983-4-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31/08/16 17:35, Zubair Lutfullah Kakakhel wrote:
> The MIPS based xilfpga platform has the following IRQ structure
> 
> Peripherals --> xilinx_intcontroller -> mips_cpu_int controller
> 
> Add support for the driver to chain the irq handler
> 
> Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
> 
> ---
> V2 -> V3
> Reused existing parent node instead of finding again.
> Cleanup up handler based on review
> 
> V1 -> V2
> 
> No change
> ---
>  drivers/irqchip/irq-axi-intc.c | 24 +++++++++++++++++++++++-
>  1 file changed, 23 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/irqchip/irq-axi-intc.c b/drivers/irqchip/irq-axi-intc.c
> index cb69241..30bb084 100644
> --- a/drivers/irqchip/irq-axi-intc.c
> +++ b/drivers/irqchip/irq-axi-intc.c
> @@ -15,6 +15,7 @@
>  #include <linux/of_address.h>
>  #include <linux/io.h>
>  #include <linux/bug.h>
> +#include <linux/of_irq.h>
>  
>  /* No one else should require these constants, so define them locally here. */
>  #define ISR 0x00			/* Interrupt Status Register */
> @@ -154,11 +155,23 @@ static const struct irq_domain_ops xintc_irq_domain_ops = {
>  	.map = xintc_map,
>  };
>  
> +static void xil_intc_irq_handler(struct irq_desc *desc)
> +{
> +	u32 pending;
> +
> +	do {
> +		pending = get_irq();
> +		if (pending == -1U)
> +			break;
> +		generic_handle_irq(pending);
> +	} while (true);
> +}
> +
>  static int __init xilinx_intc_of_init(struct device_node *intc,
>  					     struct device_node *parent)
>  {
>  	u32 nr_irq;
> -	int ret;
> +	int ret, irq;
>  	struct xintc_irq_chip *irqc;
>  
>  	irqc = kzalloc(sizeof(*irqc), GFP_KERNEL);
> @@ -211,6 +224,15 @@ static int __init xilinx_intc_of_init(struct device_node *intc,
>  	root_domain = irq_domain_add_linear(intc, nr_irq, &xintc_irq_domain_ops,
>  					    irqc);
>  
> +	if (parent) {
> +		irq = irq_of_parse_and_map(intc, 0);
> +		if (irq)
> +			irq_set_chained_handler_and_data(irq,
> +							 xil_intc_irq_handler,
> +							 root_domain);
> +
> +	}
> +
>  	irq_set_default_host(root_domain);
>  
>  	return 0;
> 

This doesn't seem right. You've now overridden the xintc_irqc pointer,
so I don't know how you can still process interrupts once you've
discovered a secondary interrupt controller. You've also allocated a
second root_domain, changed the default domain to point to the secondary
controller...

Have you tested this code? Or am I missing something obvious?

Thanks,

	M.
-- 
Jazz is not dead. It just smells funny...
