From: Marc Zyngier <marc.zyngier@arm.com>
Subject: Re: [PATCH V2 01/10] microblaze: irqchip: Move intc driver to
 irqchip
Date: Fri, 26 Aug 2016 15:13:34 +0100
Message-ID: <20160826151334.5d702731@arm.com>
References: <1471527804-26175-1-git-send-email-Zubair.Kakakhel@imgtec.com>
        <1471527804-26175-2-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <monstr@monstr.eu>, <ralf@linux-mips.org>, <tglx@linutronix.de>,
        <jason@lakedaemon.net>, <linux-mips@linux-mips.org>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1471527804-26175-2-git-send-email-Zubair.Kakakhel@imgtec.com>
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

On Thu, 18 Aug 2016 14:43:15 +0100
Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com> wrote:

Hi Zubair,

Thanks for the heads up, comments below.

> The Xilinx AXI Interrupt Controller IP block is used by the MIPS
> based xilfpga platform.
> 
> Move the interrupt controller code out of arch/microblaze so that
> it can be used by everyone
> 
> Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
> 
> ---
> V1 -> V2
> 
> Renamed irq-xilinx to irq-axi-intc
> Renamed CONFIG_XILINX_INTC to CONFIG_XILINX_AXI_INTC
> Patch is now without rename flag so as to facilitate review
> ---
>  arch/microblaze/Kconfig         |   1 +
>  arch/microblaze/kernel/Makefile |   2 +-
>  arch/microblaze/kernel/intc.c   | 196 ----------------------------------------
>  drivers/irqchip/Kconfig         |   4 +
>  drivers/irqchip/Makefile        |   1 +
>  drivers/irqchip/irq-axi-intc.c  | 196 ++++++++++++++++++++++++++++++++++++++++
>  6 files changed, 203 insertions(+), 197 deletions(-)
>  delete mode 100644 arch/microblaze/kernel/intc.c
>  create mode 100644 drivers/irqchip/irq-axi-intc.c
> 

[...]

diff --git a/drivers/irqchip/Kconfig b/drivers/irqchip/Kconfig
> index 7f87289..4429888 100644
> --- a/drivers/irqchip/Kconfig
> +++ b/drivers/irqchip/Kconfig
> @@ -203,6 +203,10 @@ config XTENSA_MX
>  	bool
>  	select IRQ_DOMAIN
>  
> +config XILINX_AXI_INTC
> +	bool
> +	select IRQ_DOMAIN
> +
>  config IRQ_CROSSBAR
>  	bool
>  	help
> diff --git a/drivers/irqchip/Makefile b/drivers/irqchip/Makefile
> index 4c203b6..bf21f55 100644
> --- a/drivers/irqchip/Makefile
> +++ b/drivers/irqchip/Makefile
> @@ -51,6 +51,7 @@ obj-$(CONFIG_TB10X_IRQC)		+= irq-tb10x.o
>  obj-$(CONFIG_TS4800_IRQ)		+= irq-ts4800.o
>  obj-$(CONFIG_XTENSA)			+= irq-xtensa-pic.o
>  obj-$(CONFIG_XTENSA_MX)			+= irq-xtensa-mx.o
> +obj-$(CONFIG_XILINX_AXI_INTC)		+= irq-axi-intc.o
>  obj-$(CONFIG_IRQ_CROSSBAR)		+= irq-crossbar.o
>  obj-$(CONFIG_SOC_VF610)			+= irq-vf610-mscm-ir.o
>  obj-$(CONFIG_BCM6345_L1_IRQ)		+= irq-bcm6345-l1.o
> diff --git a/drivers/irqchip/irq-axi-intc.c b/drivers/irqchip/irq-axi-intc.c
> new file mode 100644
> index 0000000..90bec7d
> --- /dev/null
> +++ b/drivers/irqchip/irq-axi-intc.c
> @@ -0,0 +1,196 @@
> +/*
> + * Copyright (C) 2007-2013 Michal Simek <monstr@monstr.eu>
> + * Copyright (C) 2012-2013 Xilinx, Inc.
> + * Copyright (C) 2007-2009 PetaLogix
> + * Copyright (C) 2006 Atmark Techno, Inc.
> + *
> + * This file is subject to the terms and conditions of the GNU General Public
> + * License. See the file "COPYING" in the main directory of this archive
> + * for more details.
> + */
> +
> +#include <linux/irqdomain.h>
> +#include <linux/irq.h>
> +#include <linux/irqchip.h>
> +#include <linux/of_address.h>
> +#include <linux/io.h>
> +#include <linux/bug.h>
> +
> +static void __iomem *intc_baseaddr;
> +
> +/* No one else should require these constants, so define them locally here. */
> +#define ISR 0x00			/* Interrupt Status Register */
> +#define IPR 0x04			/* Interrupt Pending Register */
> +#define IER 0x08			/* Interrupt Enable Register */
> +#define IAR 0x0c			/* Interrupt Acknowledge Register */
> +#define SIE 0x10			/* Set Interrupt Enable bits */
> +#define CIE 0x14			/* Clear Interrupt Enable bits */
> +#define IVR 0x18			/* Interrupt Vector Register */
> +#define MER 0x1c			/* Master Enable Register */
> +
> +#define MER_ME (1<<0)
> +#define MER_HIE (1<<1)
> +
> +static unsigned int (*read_fn)(void __iomem *);
> +static void (*write_fn)(u32, void __iomem *);
> +
> +static void intc_write32(u32 val, void __iomem *addr)
> +{
> +	iowrite32(val, addr);
> +}
> +
> +static unsigned int intc_read32(void __iomem *addr)
> +{
> +	return ioread32(addr);
> +}
> +
> +static void intc_write32_be(u32 val, void __iomem *addr)
> +{
> +	iowrite32be(val, addr);
> +}
> +
> +static unsigned int intc_read32_be(void __iomem *addr)
> +{
> +	return ioread32be(addr);
> +}
> +
> +static void intc_enable_or_unmask(struct irq_data *d)
> +{
> +	unsigned long mask = 1 << d->hwirq;
> +
> +	pr_debug("enable_or_unmask: %ld\n", d->hwirq);
> +
> +	/* ack level irqs because they can't be acked during
> +	 * ack function since the handle_level_irq function
> +	 * acks the irq before calling the interrupt handler
> +	 */
> +	if (irqd_is_level_type(d))
> +		write_fn(mask, intc_baseaddr + IAR);
> +
> +	write_fn(mask, intc_baseaddr + SIE);
> +}
> +
> +static void intc_disable_or_mask(struct irq_data *d)
> +{
> +	pr_debug("disable: %ld\n", d->hwirq);
> +	write_fn(1 << d->hwirq, intc_baseaddr + CIE);
> +}
> +
> +static void intc_ack(struct irq_data *d)
> +{
> +	pr_debug("ack: %ld\n", d->hwirq);
> +	write_fn(1 << d->hwirq, intc_baseaddr + IAR);
> +}
> +
> +static void intc_mask_ack(struct irq_data *d)
> +{
> +	unsigned long mask = 1 << d->hwirq;
> +
> +	pr_debug("disable_and_ack: %ld\n", d->hwirq);
> +	write_fn(mask, intc_baseaddr + CIE);
> +	write_fn(mask, intc_baseaddr + IAR);
> +}
> +
> +static struct irq_chip intc_dev = {
> +	.name = "Xilinx INTC",
> +	.irq_unmask = intc_enable_or_unmask,
> +	.irq_mask = intc_disable_or_mask,
> +	.irq_ack = intc_ack,
> +	.irq_mask_ack = intc_mask_ack,
> +};
> +
> +static struct irq_domain *root_domain;
> +
> +unsigned int get_irq(void)

Does this need to be global? It doesn't seem to be used in this patch...

> +{
> +	unsigned int hwirq, irq = -1;
> +
> +	hwirq = read_fn(intc_baseaddr + IVR);
> +	if (hwirq != -1U)
> +		irq = irq_find_mapping(root_domain, hwirq);
> +
> +	pr_debug("get_irq: hwirq=%d, irq=%d\n", hwirq, irq);
> +
> +	return irq;
> +}
> +
> +static int xintc_map(struct irq_domain *d, unsigned int irq, irq_hw_number_t hw)
> +{
> +	u32 intr_mask = (u32)d->host_data;
> +
> +	if (intr_mask & (1 << hw)) {
> +		irq_set_chip_and_handler_name(irq, &intc_dev,
> +						handle_edge_irq, "edge");
> +		irq_clear_status_flags(irq, IRQ_LEVEL);
> +	} else {
> +		irq_set_chip_and_handler_name(irq, &intc_dev,
> +						handle_level_irq, "level");
> +		irq_set_status_flags(irq, IRQ_LEVEL);
> +	}
> +	return 0;
> +}
> +
> +static const struct irq_domain_ops xintc_irq_domain_ops = {
> +	.xlate = irq_domain_xlate_onetwocell,
> +	.map = xintc_map,
> +};
> +
> +static int __init xilinx_intc_of_init(struct device_node *intc,
> +					     struct device_node *parent)
> +{
> +	u32 nr_irq, intr_mask;
> +	int ret;
> +
> +	intc_baseaddr = of_iomap(intc, 0);
> +	BUG_ON(!intc_baseaddr);
> +
> +	ret = of_property_read_u32(intc, "xlnx,num-intr-inputs", &nr_irq);
> +	if (ret < 0) {
> +		pr_err("%s: unable to read xlnx,num-intr-inputs\n", __func__);
> +		return ret;
> +	}
> +
> +	ret = of_property_read_u32(intc, "xlnx,kind-of-intr", &intr_mask);
> +	if (ret < 0) {
> +		pr_err("%s: unable to read xlnx,kind-of-intr\n", __func__);
> +		return ret;
> +	}
> +
> +	if (intr_mask >> nr_irq)
> +		pr_warn("%s: mismatch in kind-of-intr param\n", __func__);
> +
> +	pr_info("%s: num_irq=%d, edge=0x%x\n",
> +		intc->full_name, nr_irq, intr_mask);
> +
> +	write_fn = intc_write32;
> +	read_fn = intc_read32;
> +
> +	/*
> +	 * Disable all external interrupts until they are
> +	 * explicity requested.
> +	 */
> +	write_fn(0, intc_baseaddr + IER);
> +
> +	/* Acknowledge any pending interrupts just in case. */
> +	write_fn(0xffffffff, intc_baseaddr + IAR);
> +
> +	/* Turn on the Master Enable. */
> +	write_fn(MER_HIE | MER_ME, intc_baseaddr + MER);
> +	if (!(read_fn(intc_baseaddr + MER) & (MER_HIE | MER_ME))) {
> +		write_fn = intc_write32_be;
> +		read_fn = intc_read32_be;
> +		write_fn(MER_HIE | MER_ME, intc_baseaddr + MER);
> +	}
> +
> +	/* Yeah, okay, casting the intr_mask to a void* is butt-ugly, but I'm
> +	 * lazy and Michal can clean it up to something nicer when he tests
> +	 * and commits this patch.  ~~gcl */
> +	root_domain = irq_domain_add_linear(intc, nr_irq, &xintc_irq_domain_ops,
> +							(void *)intr_mask);

Since you're now reworking this driver, how about addressing this
ugliness? You could store the intr_mask together with intc_baseaddr,
and the read/write functions in a global structure, and pass a
pointer to it? That would make the code a bit nicer...

> +
> +	irq_set_default_host(root_domain);
> +
> +	return 0;
> +}
> +
> +IRQCHIP_DECLARE(xilinx_intc, "xlnx,xps-intc-1.00.a", xilinx_intc_of_init);

Is "lnx,xps-intc-1.00.a" the only supported interrupt controller? Or is
there something slightly more generic than this one?

Thanks,

	M.
-- 
Jazz is not dead. It just smells funny.
