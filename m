From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 1/3] can: m_can: add Bosch M_CAN controller support
Date: Fri, 27 Jun 2014 13:35:45 +0100
Message-ID: <20140627123545.GI7262@leverpostej>
References: <1403863246-18822-1-git-send-email-b29396@freescale.com>
 <1403863246-18822-2-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"mkl@pengutronix.de" <mkl@pengutronix.de>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Dong Aisheng <b29396@freescale.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1403863246-18822-2-git-send-email-b29396@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 27, 2014 at 11:00:44AM +0100, Dong Aisheng wrote:
> The patch adds the basic CAN TX/RX function support for Bosch M_CAN controller.
> For TX, only one dedicated tx buffer is used for sending data.
> For RX, RXFIFO 0 is used for receiving data to avoid overflow.
> Rx FIFO 1 and Rx Buffers are not used currently, as well as Tx Event FIFO.
> 
> Due to the message ram can be shared by multi m_can instances
> and the fifo element is configurable which is SoC dependant,
> the design is to parse the message ram related configuration data from device
> tree rather than hardcode define it in driver which can make the message
> ram sharing fully transparent to M_CAN controller driver,
> then we can gain better driver maintainability and future features upgrade.
> 
> M_CAN also supports CANFD protocol features like data payload up to 64 bytes
> and bitrate switch at runtime, however, this patch still does not add the
> support for these features.
> 
> Signed-off-by: Dong Aisheng <b29396@freescale.com>
> ---
>  .../devicetree/bindings/net/can/m_can.txt          |   29 +
>  drivers/net/can/Kconfig                            |    5 +
>  drivers/net/can/Makefile                           |    1 +
>  drivers/net/can/m_can.c                            |  867 ++++++++++++++++++++
>  4 files changed, 902 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/can/m_can.txt b/Documentation/devicetree/bindings/net/can/m_can.txt
> new file mode 100644
> index 0000000..2b22d02
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/can/m_can.txt
> @@ -0,0 +1,29 @@
> +Bosch MCAN controller Device Tree Bindings
> +-------------------------------------------------
> +
> +Required properties:
> +- compatible           : Should be "bosch,m_can" for M_CAN controllers

In general we use '-' rather than '_' in compatible strings...

> +- reg                  : physical base address and size of the M_CAN
> +                         registers map and message ram
> +- interrupts           : property with a value describing the interrupt
> +                         number

We know this is a property, and we know it has a value.

The important detail is _which_ interrupt this represents. Does the
M_CAN block have a single output interrupt?

> +- clocks               : clocks used by controller

How many?

Which clock inputs on the M_CAN to they feed into?

> +- mram-cfg             : message ram configuration data, the format is
> +  <offset sidf_elems xidf_elems rxf1_elems rxb_elems txe_elems txb_elems>

This is far too complicated for a single property.

> +  The 'offset' is the address offset inside the message ram. This is usually set
> +  if you're using the shared message ram while the other part is used by another
> +  m_can controller.

It sounds like what we actually need to describe is the message RAM and
how M_CAN instances relate to it.

> +  The left cell are all the number of each elements inside the message ram.

Pardon?

> +  Please refer to 2.4.1 Message RAM Con.guration in Bosch M_CAN user mannual
> +  for each elements definition.

This is far too complicated, and far too low-level. I want to see a
better description of what this is any why thie is necessary.

> +
> +Example:
> +canfd1: canfd@020e8000 {
> +       compatible = "bosch,m_can";
> +       reg = <0x020e8000 0x4000>, <0x02298000 0x4000>;
> +       reg-names = "canfd", "message_ram";

The use of reg-names was not described.

> +       interrupts = <0 114 0x04>;
> +       clocks = <&clks IMX6SX_CLK_CANFD>;
> +       mram-cfg = <0x0 0 0 32 32 32 0 1>;
> +       status = "disabled";

Any reason for a disabled status in the example?

[...]

> +                       *(u32 *)(frame->data + 0) = readl(priv->mram_base +
> +                                       priv->rxf0_off + fgi * 16 + 0x8);
> +                       *(u32 *)(frame->data + 4) = readl(priv->mram_base +
> +                                       priv->rxf0_off + fgi * 16 + 0xC);

This doesn't look endian-clean.

How are the registers laid out? Are they a string of bytes than can be
accessed in 4-byte chunks, or are they a string of 4-byte values?

[...]

> +static int m_can_get_berr_counter(const struct net_device *dev,
> +                                 struct can_berr_counter *bec)
> +{
> +       /* TODO */
> +
> +       return 0;

Still to be done?

[...]

> +static int m_can_of_parse_mram(struct platform_device *pdev,
> +                               struct m_can_priv *priv)
> +{
> +       struct device_node *np = pdev->dev.of_node;
> +       struct resource *res;
> +       void __iomem *addr;
> +       u32 out_val[8];

Why 8? Use a #define here...

> +       int ret;
> +
> +       /* message ram could be shared */
> +       res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "message_ram");
> +       if (!res)
> +               return -ENODEV;
> +
> +       addr = devm_ioremap(&pdev->dev, res->start, resource_size(res));
> +       if (!addr)
> +               return -ENODEV;
> +
> +       /* get message ram configuration */
> +       ret = of_property_read_u32_array(np, "mram-cfg",
> +                               out_val, sizeof(out_val) / 4);

...and use it here too.

That said, I want a better description of this property as I mentioned
previously.

[...]

> +static int m_can_plat_probe(struct platform_device *pdev)
> +{
> +       struct net_device *dev;
> +       struct m_can_priv *priv;
> +       struct pinctrl *pinctrl;
> +       struct resource *res;
> +       void __iomem *addr;
> +       struct clk *clk;
> +       int irq, ret;
> +
> +       pinctrl = devm_pinctrl_get_select_default(&pdev->dev);
> +       if (IS_ERR(pinctrl))
> +               dev_warn(&pdev->dev,
> +                       "failed to configure pins from driver\n");

Doesn't this need pinctrl properties in the DT?

> +       clk = devm_clk_get(&pdev->dev, NULL);
> +       if (IS_ERR(clk)) {
> +               dev_err(&pdev->dev, "no clock find\n");
> +               return PTR_ERR(clk);
> +       }

So just the one clock?

> +
> +       res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "canfd");

This wasn't in the binding.

Thanks,
Mark.
