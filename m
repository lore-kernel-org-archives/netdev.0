From: Marc Zyngier <marc.zyngier@arm.com>
Subject: Re: [Patch v4 04/12] irqchip: axi-intc: Add support for parent intc
Date: Thu, 1 Sep 2016 18:17:58 +0100
Message-ID: <57C862C6.7070703@arm.com>
References: <1472748665-47774-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1472748665-47774-5-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: soren.brinkmann@xilinx.com, linux-kernel@vger.kernel.org,
        linux-mips@linux-mips.org, michal.simek@xilinx.com,
        netdev@vger.kernel.org
To: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>,
        monstr@monstr.eu, ralf@linux-mips.org, tglx@linutronix.de,
        jason@lakedaemon.net
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1472748665-47774-5-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On 01/09/16 17:50, Zubair Lutfullah Kakakhel wrote:
> The MIPS based xilfpga platform has the following IRQ structure
> 
> Peripherals --> xilinx_intcontroller -> mips_cpu_int controller
> 
> Add support for the driver to chain the irq handler
> 
> Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
> 
> ---
> V3 -> V4
> Clean up if/else when a parent is found
> Pass irqchip structure to handler as data
> 
> V2 -> V3
> Reused existing parent node instead of finding again.
> Cleanup up handler based on review
> 
> V1 -> V2
> 
> No change
> ---
>  drivers/irqchip/irq-axi-intc.c | 25 +++++++++++++++++++++++--
>  1 file changed, 23 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/irqchip/irq-axi-intc.c b/drivers/irqchip/irq-axi-intc.c
> index ac31548..683b1f7 100644
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
> +		pending = xintc_get_irq();
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
> @@ -217,7 +230,15 @@ static int __init xilinx_intc_of_init(struct device_node *intc,
>  	root_domain = irq_domain_add_linear(intc, nr_irq, &xintc_irq_domain_ops,
>  					    irqc);
>  
> -	irq_set_default_host(root_domain);
> +	if (parent) {
> +		irq = irq_of_parse_and_map(intc, 0);
> +		if (irq)
> +			irq_set_chained_handler_and_data(irq,
> +							 xil_intc_irq_handler,
> +							 irqc);
> +
> +	} else
> +		irq_set_default_host(root_domain);

Coding style, please.

Thanks,

	M.
-- 
Jazz is not dead. It just smells funny...
