From: Marc Zyngier <marc.zyngier@arm.com>
Subject: Re: [PATCH V2 02/10] irqchip: xilinx: Add support for parent intc
Date: Fri, 26 Aug 2016 15:23:01 +0100
Message-ID: <20160826152301.74132534@arm.com>
References: <1471527804-26175-1-git-send-email-Zubair.Kakakhel@imgtec.com>
        <1471527804-26175-3-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <monstr@monstr.eu>, <ralf@linux-mips.org>, <tglx@linutronix.de>,
        <jason@lakedaemon.net>, <linux-mips@linux-mips.org>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471527804-26175-3-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Aug 2016 14:43:16 +0100
Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com> wrote:

> The MIPS based xilfpga platform has the following IRQ structure
> 
> Peripherals --> xilinx_intcontroller -> mips_cpu_int controller
> 
> Add support for the driver to chain the irq handler
> 
> Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
> 
> ---
> V1 -> V2
> 
> No change
> ---
>  drivers/irqchip/irq-axi-intc.c | 28 +++++++++++++++++++++++++++-
>  1 file changed, 27 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/irqchip/irq-axi-intc.c b/drivers/irqchip/irq-axi-intc.c
> index 90bec7d..a0be6fa 100644
> --- a/drivers/irqchip/irq-axi-intc.c
> +++ b/drivers/irqchip/irq-axi-intc.c
> @@ -15,6 +15,7 @@
>  #include <linux/of_address.h>
>  #include <linux/io.h>
>  #include <linux/bug.h>
> +#include <linux/of_irq.h>
>  
>  static void __iomem *intc_baseaddr;
>  
> @@ -135,11 +136,26 @@ static const struct irq_domain_ops xintc_irq_domain_ops = {
>  	.map = xintc_map,
>  };
>  
> +static void xil_intc_irq_handler(struct irq_desc *desc)
> +{
> +	u32 pending = get_irq();
> +
> +	if (pending != -1U) {
> +		while (true) {
> +			pending = get_irq();
> +			generic_handle_irq(pending);
> +			if (pending == -1U)

Erm... So even when pending is -1, you're calling generic_handle_irq?
This doesn't seem right.

You're also missing the chained_irq_enter/exit calls around this loop.

Overall, this should be rewritten in a less cumbersome way. Something
like:

	do {
		u32 pending;

		pending = get_irq();
		if (pending == ~0)
			break;
		generic_handle_irq(pending);
	} while (true);

> +				break;
> +		}
> +	}
> +}
> +
>  static int __init xilinx_intc_of_init(struct device_node *intc,
>  					     struct device_node *parent)
>  {
>  	u32 nr_irq, intr_mask;
> -	int ret;
> +	int ret, irq;
> +	struct device_node *parent_node;
>  
>  	intc_baseaddr = of_iomap(intc, 0);
>  	BUG_ON(!intc_baseaddr);
> @@ -188,6 +204,16 @@ static int __init xilinx_intc_of_init(struct device_node *intc,
>  	root_domain = irq_domain_add_linear(intc, nr_irq, &xintc_irq_domain_ops,
>  							(void *)intr_mask);
>  
> +	parent_node = of_irq_find_parent(intc);

You already have the parent node as an argument to the function. Why do
you need to do that again?

> +	if (parent_node) {
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


Thanks,

	M.
-- 
Jazz is not dead. It just smells funny.
