From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: Re: [PATCH v2 1/2] genirq: add function to get IRQ edge/level flags
Date: Thu, 25 Apr 2013 00:10:44 +0200
Message-ID: <CAAwP0s3cV55XY7RyoPpT_BYeeuHXivqjd_2_25qJBwdgCP5DNA@mail.gmail.com>
References: <1365816094-31568-1-git-send-email-javier.martinez@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>,
	Rob Herring <robherring2@gmail.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	Jon Hunter <jon-hunter@ti.com>,
	devicetree-discuss@lists.ozlabs.org,
	linux-omap <linux-omap@vger.kernel.org>, netdev@vger.kernel.org
To: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1365816094-31568-1-git-send-email-javier.martinez@collabora.co.uk>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 13, 2013 at 3:21 AM, Javier Martinez Canillas
<javier.martinez@collabora.co.uk> wrote:
> According to Documentation/devicetree/bindings/interrupt-controller/interrupts.txt
> the "#interrupt-cells" property of an "interrupt-controller" is used
> to define the number of cells needed to specify a single interrupt.
>
> A commonly used variant is two cell on which #interrupt-cells = <2>
> and the first cell defines the index of the interrupt in the controller
> while the second cell is used to specify any of the following flags:
>
>     - bits[3:0] trigger type and level flags
>         1 = low-to-high edge triggered
>         2 = high-to-low edge triggered
>         4 = active high level-sensitive
>         8 = active low level-sensitive
>
> An example of an interrupt controller which use the two cell format is
> the OMAP GPIO controller that allows GPIO lines to be used as IRQ
> (Documentation/devicetree/bindings/gpio/gpio-omap.txt)
>
> But setting #interrupt-cells = <2> on the OMAP GPIO device node and
> specifying the GPIO-IRQ type and level flags on the second cell does not
> store this value on the populated IORESOURCE_IRQ struct resource.
>
> This is because when using an IRQ from an interrupt controller and
> setting both cells (e.g:)
>
>         interrupt-parent = <&gpio6>;
>         interrupts = <16 8>;
>
> A call to of_irq_to_resource() is made and this function calls
> irq_of_parse_and_map_type() to get the virtual IRQ mapped to the real
> index for this interrupt controller. This IRQ number is populated on
> the struct resource:
>
> int of_irq_to_resource(struct device_node *dev, int index, struct resource *r)
> {
>         int irq = irq_of_parse_and_map(dev, index);
>         ..
>         r->start = r->end = irq;
> }
>
> irq_of_parse_and_map() calls to irq_create_of_mapping() which calls to
> the correct xlate function handler according to "#interrupt-cells"
> (irq_domain_xlate_onecell or irq_domain_xlate_twocell) and to
> irq_set_irq_type() to set the IRQ type.
>
> But the type is never returned so it can't be saved on the IRQ struct
> resource flags member.
>
> This means that drivers that want to get the IRQ edge/level flags
> defined in the Device Tree from a struct resource will not be able
> to get it.
>
> Drivers can get the IRQ flags by using irq_get_irq_data(irq) and
> irqd_get_trigger_type(irq_data) but this will unnecessary expose
> irq_data to callers and also is more error prone.
>
> So, is better to add an irq_get_trigger_type() function to obtain
> the edge/level flags for an IRQ.
>
> Signed-off-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
> ---
>
> Changes since v1:
>   - use irqd_get_trigger_type() instead of a direct access to
>     d->state_use_accessors as suggested by Stephen Warren.
>
>  include/linux/irq.h |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/irq.h b/include/linux/irq.h
> index bc4e066..0e8e3a6 100644
> --- a/include/linux/irq.h
> +++ b/include/linux/irq.h
> @@ -579,6 +579,12 @@ static inline struct msi_desc *irq_data_get_msi(struct irq_data *d)
>         return d->msi_desc;
>  }
>
> +static inline u32 irq_get_trigger_type(unsigned int irq)
> +{
> +       struct irq_data *d = irq_get_irq_data(irq);
> +       return d ? irqd_get_trigger_type(d) : 0;
> +}
> +
>  int __irq_alloc_descs(int irq, unsigned int from, unsigned int cnt, int node,
>                 struct module *owner);
>
> --
> 1.7.7.6
>
> --

Hello,

Any comments about this patch?

Thanks a lot and best regards,
Javier
