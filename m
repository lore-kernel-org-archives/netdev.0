From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH 1/3] serial/imx: add device tree support
Date: Sun, 19 Jun 2011 15:30:02 +0800
Message-ID: <20110619073000.GA23171@S2100-06.ap.freescale.net>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
	<1308410354-21387-2-git-send-email-shawn.guo@linaro.org>
	<20110618161934.GH8195@ponder.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: patches@linaro.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	Jason Liu <jason.hui@linaro.org>, linux-kernel@vger.kernel.org,
	Jeremy Kerr <jeremy.kerr@canonical.com>, Shawn Guo <shawn.guo@linaro.org>,
	Sascha Hauer <s.hauer@pengutronix.de>, linux-arm-kernel@lists.infradead.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20110618161934.GH8195@ponder.secretlab.ca>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 18, 2011 at 10:19:34AM -0600, Grant Likely wrote:
> On Sat, Jun 18, 2011 at 11:19:12PM +0800, Shawn Guo wrote:
> > It adds device tree data parsing support for imx tty/serial driver.
> > 
> > Signed-off-by: Jeremy Kerr <jeremy.kerr@canonical.com>
> > Signed-off-by: Jason Liu <jason.hui@linaro.org>
> > Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
> > Cc: Sascha Hauer <s.hauer@pengutronix.de>
> > ---
> >  .../bindings/tty/serial/fsl-imx-uart.txt           |   21 +++++
> >  drivers/tty/serial/imx.c                           |   81 +++++++++++++++++---
> >  2 files changed, 92 insertions(+), 10 deletions(-)
> >  create mode 100644 Documentation/devicetree/bindings/tty/serial/fsl-imx-uart.txt
> > 
> > diff --git a/Documentation/devicetree/bindings/tty/serial/fsl-imx-uart.txt b/Documentation/devicetree/bindings/tty/serial/fsl-imx-uart.txt
> > new file mode 100644
> > index 0000000..7648e17
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/tty/serial/fsl-imx-uart.txt
> > @@ -0,0 +1,21 @@
> > +* Freescale i.MX Universal Asynchronous Receiver/Transmitter (UART)
> > +
> > +Required properties:
> > +- compatible : should be "fsl,<soc>-uart", "fsl,imx-uart"
> 
> I'd make this "fsl,<soc>-uart", "fsl,imx51-uart"
> 
> It's better to anchor these things on real silicon, or a real ip block
> specification rather than something pseudo-generic.  Subsequent chips,
> like the imx53, should simply claim compatibility with the older
> fsl,imx51-uart.

It is a real IP block on all imx silicons (except imx23 and imx28
which are known as former stmp).

> 
> (in essence, "fsl,imx51-uart" becomes the generic string without the
> downside of having no obvious recourse when new silicon shows up that
> is an imx part, but isn't compatible with the imx51 uart.
> 
In this case, should imx1 the ancestor of imx family than imx51
becomes part of that generic string?  Claiming uart of imx1, imx21
and imx31 (senior than imx51) compatible with the imx51 uart seems
odd to me.

That said, IMO, "fsl,imx-uart" stands a real IP block specification
here and can be a perfect generic compatibility string to tell the
recourse of any imx silicon using this IP.

> > +- reg : address and length of the register set for the device
> > +- interrupts : should contain uart interrupt
> > +- id : should be the port ID defined by soc
> > +
> > +Optional properties:
> > +- fsl,has-rts-cts : indicate it has rts-cts
> > +- fsl,irda-mode : support irda mode
> > +
> > +Example:
> > +
> > +uart@73fbc000 {
> > +	compatible = "fsl,imx51-uart", "fsl,imx-uart";
> > +	reg = <0x73fbc000 0x4000>;
> > +	interrupts = <31>;
> > +	id = <1>;
> > +	fsl,has-rts-cts;
> > +};
> > diff --git a/drivers/tty/serial/imx.c b/drivers/tty/serial/imx.c
> > index a544731..2769353 100644
> > --- a/drivers/tty/serial/imx.c
> > +++ b/drivers/tty/serial/imx.c
> > @@ -45,6 +45,8 @@
> >  #include <linux/delay.h>
> >  #include <linux/rational.h>
> >  #include <linux/slab.h>
> > +#include <linux/of.h>
> > +#include <linux/of_address.h>
> >  
> >  #include <asm/io.h>
> >  #include <asm/irq.h>
> > @@ -1223,6 +1225,63 @@ static int serial_imx_resume(struct platform_device *dev)
> >  	return 0;
> >  }
> >  
> > +#ifdef CONFIG_OF
> > +static int serial_imx_probe_dt(struct imx_port *sport,
> > +		struct platform_device *pdev)
> > +{
> > +	struct device_node *node = pdev->dev.of_node;
> > +	const __be32 *line;
> > +
> > +	if (!node)
> > +		return -ENODEV;
> > +
> > +	line = of_get_property(node, "id", NULL);
> > +	if (!line)
> > +		return -ENODEV;
> > +
> > +	sport->port.line = be32_to_cpup(line) - 1;
> 
> Hmmm, I really would like to be rid of this.  Instead, if uarts must
> be enumerated, the driver should look for a /aliases/uart* property
> that matches the of_node.  Doing it that way is already established in
> the OpenFirmware documentation, and it ensures there are no overlaps
> in the global namespace.
> 

I just gave one more try to avoid using 'aliases', and you gave a
'no' again.  Now, I know how hard you are on this.  Okay, I start
thinking about your suggestion seriously :)

> We do need some infrastructure to make that easier though.  Would you
> have time to help put that together?
> 
Ok, I will give it a try.

-- 
Regards,
Shawn
