From: James Hogan <james.hogan-1AXoQHu6uovQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net: Linn Ethernet Packet Sniffer driver
Date: Fri, 23 Jan 2015 19:12:53 +0100
Message-ID: <1817503.588aons8oi@radagast>
References: <1422007621-13567-1-git-send-email-stathis.voukelatos@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>,
	abrestic-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org
To: Stathis Voukelatos <stathisv70-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422007621-13567-1-git-send-email-stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

A few general things below (I'll leave the actual networking bits for
others to comment about).

On Friday 23 January 2015 10:07:01 Stathis Voukelatos wrote:
> ---
>  .../bindings/net/linn-ether-packet-sniffer.txt     |  27 ++
>  .../devicetree/bindings/vendor-prefixes.txt        |   1 +
>  MAINTAINERS                                        |   7 +
>  drivers/net/Kconfig                                |   2 +
>  drivers/net/Makefile                               |   1 +
>  drivers/net/pkt-sniffer/Kconfig                    |  23 ++
>  drivers/net/pkt-sniffer/Makefile                   |   8 +
>  drivers/net/pkt-sniffer/backends/ether/channel.c   | 366 ++++++++++++++++++
>  drivers/net/pkt-sniffer/backends/ether/channel.h   |  76 ++++
>  drivers/net/pkt-sniffer/backends/ether/hw.h        |  46 +++
>  drivers/net/pkt-sniffer/backends/ether/platform.c  | 231 +++++++++++
>  drivers/net/pkt-sniffer/core/dev_table.c           | 124 ++++++
>  drivers/net/pkt-sniffer/core/module.c              |  37 ++
>  drivers/net/pkt-sniffer/core/nl.c                  | 427 +++++++++++++++++++++
>  drivers/net/pkt-sniffer/core/nl.h                  |  34 ++
>  drivers/net/pkt-sniffer/core/snf_core.h            |  64 +++
>  include/linux/pkt_sniffer.h                        |  89 +++++

Probably worth splitting this up a bit into a series of multiple
logically separate patches. E.g. the vendor prefix, the core, the ether
backend and dt bindings.

> diff --git a/drivers/net/pkt-sniffer/Kconfig b/drivers/net/pkt-sniffer/Kconfig
> new file mode 100644
> index 0000000..26b4f98
> --- /dev/null
> +++ b/drivers/net/pkt-sniffer/Kconfig
> @@ -0,0 +1,23 @@
> +menuconfig PKT_SNIFFER
> +    tristate "Linn packet sniffer support"

Should the kconfig symbol have linn in the name, or should the prompt
not have lin in the name?

> +    ---help---
> +    Say Y to add support for Linn packet sniffer drivers.
> +
> +    The core driver can also be built as a module. If so, the module
> +    will be called snf_core.
> +
> +if PKT_SNIFFER

Just make PKT_SNIFFER_ETHER depend first on PKT_SNIFFER, then it'll
appear nested within it in menuconfig.

> +
> +config PKT_SNIFFER_ETHER
> +    tristate "Ethernet packet sniffer"
> +    depends on MIPS

worth adding || COMPILE_TEST to get compile coverage on x86 allmodconfig
builds, or does it have hard dependencies on the MIPS arch?

> +    default n

No need, n is default

> +    help
> +        Say Y here if you want to use the Linn Ethernet packet sniffer
> +        module. It can be found in the upcoming Pistachio SoC by
> +        Imagination Technologies.
> +
> +        The driver can also be built as a module. If so, the module
> +        will be called snf_ether.
> +
> +endif # PKT_SNIFFER


> +/* Called when the packet sniffer device is bound with the driver */
> +static int esnf_driver_probe(struct platform_device *pdev)
> +{
> +	struct ether_snf *esnf;
> +	struct resource *res;
> +	int ret, irq;
> +	u32 fifo_blk_words;
> +	void __iomem *regs;
> +	struct device_node *ofn = pdev->dev.of_node;
> +
> +	/* Allocate the device data structure */
> +	esnf = devm_kzalloc(&pdev->dev, sizeof(*esnf), GFP_KERNEL);
> +	if (!esnf)
> +		return -ENOMEM;
> +
> +	/* Retrieve and remap register memory space */
> +	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "regs");
> +	if (!res)
> +		return -ENODEV;

No need for this check. devm_ioremap_resource does it for you.

> +
> +	regs = devm_ioremap_resource(&pdev->dev, res);
> +	if (IS_ERR(regs))
> +		return PTR_ERR(regs);
> +


> +static const struct of_device_id esnf_of_match_table[] = {
> +	{ .compatible = "linn,eth-sniffer", .data = NULL },

Nit: not strictly necessary to initialise .data since it's static.

Cheers
James

> +	{},
> +};
> +MODULE_DEVICE_TABLE(of, esnf_of_match_table);
> +
> +static struct platform_driver esnf_platform_driver = {
> +	.driver = {
> +		.name = esnf_driver_name,
> +		.of_match_table = esnf_of_match_table,
> +	},
> +	.probe = esnf_driver_probe,
> +	.remove = esnf_driver_remove,
> +};
> +
> +module_platform_driver(esnf_platform_driver);
> +
> +MODULE_DESCRIPTION("Linn Ethernet Packet Sniffer");
> +MODULE_AUTHOR("Linn Products Ltd");
> +MODULE_LICENSE("GPL v2");

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
