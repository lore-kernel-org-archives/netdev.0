From: Dong Aisheng <b29396@freescale.com>
Subject: Re: [PATCH 1/3] can: m_can: add Bosch M_CAN controller support
Date: Mon, 30 Jun 2014 16:03:47 +0800
Message-ID: <20140630080344.GA25689@shlinux1.ap.freescale.net>
References: <1403863246-18822-1-git-send-email-b29396@freescale.com>
 <1403863246-18822-2-git-send-email-b29396@freescale.com>
 <20140627123545.GI7262@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"mkl@pengutronix.de" <mkl@pengutronix.de>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0238.outbound.protection.outlook.com ([207.46.163.238]:40655
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755183AbaF3Jfc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jun 2014 05:35:32 -0400
Content-Disposition: inline
In-Reply-To: <20140627123545.GI7262@leverpostej>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mark,

First of all, thanks for the quick and carefully review.

On Fri, Jun 27, 2014 at 01:35:45PM +0100, Mark Rutland wrote:
> On Fri, Jun 27, 2014 at 11:00:44AM +0100, Dong Aisheng wrote:
> > The patch adds the basic CAN TX/RX function support for Bosch M_CAN controller.
> > For TX, only one dedicated tx buffer is used for sending data.
> > For RX, RXFIFO 0 is used for receiving data to avoid overflow.
> > Rx FIFO 1 and Rx Buffers are not used currently, as well as Tx Event FIFO.
> > 
> > Due to the message ram can be shared by multi m_can instances
> > and the fifo element is configurable which is SoC dependant,
> > the design is to parse the message ram related configuration data from device
> > tree rather than hardcode define it in driver which can make the message
> > ram sharing fully transparent to M_CAN controller driver,
> > then we can gain better driver maintainability and future features upgrade.
> > 
> > M_CAN also supports CANFD protocol features like data payload up to 64 bytes
> > and bitrate switch at runtime, however, this patch still does not add the
> > support for these features.
> > 
> > Signed-off-by: Dong Aisheng <b29396@freescale.com>
> > ---
> >  .../devicetree/bindings/net/can/m_can.txt          |   29 +
> >  drivers/net/can/Kconfig                            |    5 +
> >  drivers/net/can/Makefile                           |    1 +
> >  drivers/net/can/m_can.c                            |  867 ++++++++++++++++++++
> >  4 files changed, 902 insertions(+), 0 deletions(-)
> > 
> > diff --git a/Documentation/devicetree/bindings/net/can/m_can.txt b/Documentation/devicetree/bindings/net/can/m_can.txt
> > new file mode 100644
> > index 0000000..2b22d02
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/can/m_can.txt
> > @@ -0,0 +1,29 @@
> > +Bosch MCAN controller Device Tree Bindings
> > +-------------------------------------------------
> > +
> > +Required properties:
> > +- compatible           : Should be "bosch,m_can" for M_CAN controllers
> 
> In general we use '-' rather than '_' in compatible strings...
> 

First i'm following the exist c_can.txt rule.
Second M_CAN is the M_CAN user manual defined name, i'm not sure change
to bosch,m-can is a good idea.

> > +- reg                  : physical base address and size of the M_CAN
> > +                         registers map and message ram
> > +- interrupts           : property with a value describing the interrupt
> > +                         number
> 
> We know this is a property, and we know it has a value.
> 
> The important detail is _which_ interrupt this represents. Does the
> M_CAN block have a single output interrupt?
> 

The m_can module provides two interrupt lines. Interrupts can be routed
either to m_can_int0 or to m_can_int1. By default all interrupts are
routed to interrupt line m_can_int0. By programming ILE.EINT0 and ILE.EINT1
the interrupt lines can be enabled or disabled separately.

However, whether these two interrupts line are connected to two separate
interrupts to interrupt controller depends on SoC design.

For iMX6SX it has a single interrupt number of canfd1(m_can) which is 146,
since both m_can_int0 and m_can_int1 are connected to interrupt 146.
For other SoCs, it may have two interrupt numbers for one m_can instance.

Thus this property could be one value or two.
The current driver only parsed one interrupt line.

Probably we could add description as follows:
- interrupts           : Should be the interrupt number shared by m_can_int0
			and m_can_int1. If two numbers, the first one is
			m_can_int0 and the second one is m_can_int1.

For driver, we still only parse m_can_int0 and route all interrupts
to m_can_int0 to make things a bit simple.

> > +- clocks               : clocks used by controller
> 
> How many?
> 
> Which clock inputs on the M_CAN to they feed into?
> 

Yes, M_CAN could be Dual Clock Sources, host clock m_can_hclk and
can clock m_can_cclk. I will add them here.

> > +- mram-cfg             : message ram configuration data, the format is
> > +  <offset sidf_elems xidf_elems rxf1_elems rxb_elems txe_elems txb_elems>
> 
> This is far too complicated for a single property.
> 
> > +  The 'offset' is the address offset inside the message ram. This is usually set
> > +  if you're using the shared message ram while the other part is used by another
> > +  m_can controller.
> 
> It sounds like what we actually need to describe is the message RAM and
> how M_CAN instances relate to it.
> 
> > +  The left cell are all the number of each elements inside the message ram.
> 
> Pardon?
> 
> > +  Please refer to 2.4.1 Message RAM Con.guration in Bosch M_CAN user mannual
> > +  for each elements definition.
> 
> This is far too complicated, and far too low-level. I want to see a
> better description of what this is any why thie is necessary.
> 

Yes, this is a bit complicated.
The main reason for adding this property is that message ram can be shared
by multiple m_can instances according to m_can user manual.
For a SOC design, each m_can instance may use the shared message ram
or has its own private message ram.
e.g. For iMX6SX, there's 16K message ram shared by m_can0 and m_can1.
If sharing, we don't know how many instances share it and how the message ram
are shared using by multi m_can.
It's not good to hardcode these information in driver.
Thus i introduced a property called mram-cfg to let driver to parse this
information from device tree. Then controller driver could be fully transparently
to the ram sharing mechanism.

For iMX6SX, we assigned the first 8K for m_can0 and the left 8K for m_can1 to use.
This is done by offset value in mram-cfg property.

Due to each fifo/buffer elements in message ram can also be configurable, the driver
also needs this information calculate the address to know where to put/read
the correct data, e.g. rx data or tx data and etc.
So we need extra cells to let user to define the elements number of each fifo/buffers.

According to user manual, the elements include:
11-bit Filter	0-128 elements / 0-128 words
29-bit Filter	0-64 elements / 0-128 words
Rx FIFO 0	0-64 elements / 0-1152 words
Rx FIFO 1	0-64 elements / 0-1152 words
Rx Buffers	0-64 elements / 0-1152 words
Tx Event FIFO	0-32 elements / 0-64 words
Tx Buffers	0-32 elements / 0-576 words

Maybe i could add more information in the binding doc to describe it to make it
more easy to understand.

> > +
> > +Example:
> > +canfd1: canfd@020e8000 {
> > +       compatible = "bosch,m_can";
> > +       reg = <0x020e8000 0x4000>, <0x02298000 0x4000>;
> > +       reg-names = "canfd", "message_ram";
> 
> The use of reg-names was not described.
> 

Yes, will add the description in 'Required properties'.
Driver can find the correct resource by the name.

> > +       interrupts = <0 114 0x04>;
> > +       clocks = <&clks IMX6SX_CLK_CANFD>;
> > +       mram-cfg = <0x0 0 0 32 32 32 0 1>;
> > +       status = "disabled";
> 
> Any reason for a disabled status in the example?
> 

No any special reason, just because the example given is usually in SoC dtsi
and disabled by default then it is enabled it board dts later.
Is it a problem?
I could remove it if you really want.

> [...]
> 
> > +                       *(u32 *)(frame->data + 0) = readl(priv->mram_base +
> > +                                       priv->rxf0_off + fgi * 16 + 0x8);
> > +                       *(u32 *)(frame->data + 4) = readl(priv->mram_base +
> > +                                       priv->rxf0_off + fgi * 16 + 0xC);
> 
> This doesn't look endian-clean.
> 

Yes, i guess the m_can could also be used in big endian system.
Due to i only have littel endian chip on hands, i just used little endian
in the initial driver.
Big endian could be added later if if there's a chip to verify.

> How are the registers laid out? Are they a string of bytes than can be
> accessed in 4-byte chunks, or are they a string of 4-byte values?
> 

The register is laid out as follows and can be accessed in 4-byte chunks.
R2 DB3[7:0] DB2[7:0] DB1[7:0] DB0[7:0]
R3 DB7[7:0] DB6[7:0] DB5[7:0] DB4[7:0]
...
Rn DBm[7:0] DBm-1[7:0] DBm-2[7:0] DBm-3[7:0]

> [...]
> 
> > +static int m_can_get_berr_counter(const struct net_device *dev,
> > +                                 struct can_berr_counter *bec)
> > +{
> > +       /* TODO */
> > +
> > +       return 0;
> 
> Still to be done?
> 

Yes, most error handling code are implemented in second patch.

> [...]
> 
> > +static int m_can_of_parse_mram(struct platform_device *pdev,
> > +                               struct m_can_priv *priv)
> > +{
> > +       struct device_node *np = pdev->dev.of_node;
> > +       struct resource *res;
> > +       void __iomem *addr;
> > +       u32 out_val[8];
> 
> Why 8? Use a #define here...
> 

It's according to mram-cfg cells number.
Seems change to #define is better, will do it.

> > +       int ret;
> > +
> > +       /* message ram could be shared */
> > +       res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "message_ram");
> > +       if (!res)
> > +               return -ENODEV;
> > +
> > +       addr = devm_ioremap(&pdev->dev, res->start, resource_size(res));
> > +       if (!addr)
> > +               return -ENODEV;
> > +
> > +       /* get message ram configuration */
> > +       ret = of_property_read_u32_array(np, "mram-cfg",
> > +                               out_val, sizeof(out_val) / 4);
> 
> ...and use it here too.
> 
> That said, I want a better description of this property as I mentioned
> previously.
> 
> [...]
> 
> > +static int m_can_plat_probe(struct platform_device *pdev)
> > +{
> > +       struct net_device *dev;
> > +       struct m_can_priv *priv;
> > +       struct pinctrl *pinctrl;
> > +       struct resource *res;
> > +       void __iomem *addr;
> > +       struct clk *clk;
> > +       int irq, ret;
> > +
> > +       pinctrl = devm_pinctrl_get_select_default(&pdev->dev);
> > +       if (IS_ERR(pinctrl))
> > +               dev_warn(&pdev->dev,
> > +                       "failed to configure pins from driver\n");
> 
> Doesn't this need pinctrl properties in the DT?

I will remove it to let pinctrl code in driver core to handle it.

> 
> > +       clk = devm_clk_get(&pdev->dev, NULL);
> > +       if (IS_ERR(clk)) {
> > +               dev_err(&pdev->dev, "no clock find\n");
> > +               return PTR_ERR(clk);
> > +       }
> 
> So just the one clock?
> 

For iMX6SX, it is only one clock.
But M_CAN user manual defines two clocks.
I could add them here.

> > +
> > +       res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "canfd");
> 
> This wasn't in the binding.

Yes, will add it in the binding description.

> 
> Thanks,
> Mark.

Regards
Dong Aisheng
