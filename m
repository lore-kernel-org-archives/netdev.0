From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 1/3] serial/imx: add device tree support
Date: Sun, 19 Jun 2011 09:05:49 -0600
Message-ID: <BANLkTi=1hf7ycwMBcZ0+VDNRMG1_vdnSqA@mail.gmail.com>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
 <1308410354-21387-2-git-send-email-shawn.guo@linaro.org> <20110618161934.GH8195@ponder.secretlab.ca>
 <20110619073000.GA23171@S2100-06.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@linaro.org>, patches@linaro.org,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	Jason Liu <jason.hui@linaro.org>, linux-kernel@vger.kernel.org,
	Jeremy Kerr <jeremy.kerr@canonical.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:34410 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754019Ab1FSPGL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 11:06:11 -0400
In-Reply-To: <20110619073000.GA23171@S2100-06.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 19, 2011 at 1:30 AM, Shawn Guo <shawn.guo@freescale.com> wr=
ote:
> On Sat, Jun 18, 2011 at 10:19:34AM -0600, Grant Likely wrote:
>> On Sat, Jun 18, 2011 at 11:19:12PM +0800, Shawn Guo wrote:
>> > It adds device tree data parsing support for imx tty/serial driver=
=2E
>> >
>> > Signed-off-by: Jeremy Kerr <jeremy.kerr@canonical.com>
>> > Signed-off-by: Jason Liu <jason.hui@linaro.org>
>> > Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
>> > Cc: Sascha Hauer <s.hauer@pengutronix.de>
>> > ---
>> > =A0.../bindings/tty/serial/fsl-imx-uart.txt =A0 =A0 =A0 =A0 =A0 | =
=A0 21 +++++
>> > =A0drivers/tty/serial/imx.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 | =A0 81 +++++++++++++++++---
>> > =A02 files changed, 92 insertions(+), 10 deletions(-)
>> > =A0create mode 100644 Documentation/devicetree/bindings/tty/serial=
/fsl-imx-uart.txt
>> >
>> > diff --git a/Documentation/devicetree/bindings/tty/serial/fsl-imx-=
uart.txt b/Documentation/devicetree/bindings/tty/serial/fsl-imx-uart.tx=
t
>> > new file mode 100644
>> > index 0000000..7648e17
>> > --- /dev/null
>> > +++ b/Documentation/devicetree/bindings/tty/serial/fsl-imx-uart.tx=
t
>> > @@ -0,0 +1,21 @@
>> > +* Freescale i.MX Universal Asynchronous Receiver/Transmitter (UAR=
T)
>> > +
>> > +Required properties:
>> > +- compatible : should be "fsl,<soc>-uart", "fsl,imx-uart"
>>
>> I'd make this "fsl,<soc>-uart", "fsl,imx51-uart"
>>
>> It's better to anchor these things on real silicon, or a real ip blo=
ck
>> specification rather than something pseudo-generic. =A0Subsequent ch=
ips,
>> like the imx53, should simply claim compatibility with the older
>> fsl,imx51-uart.
>
> It is a real IP block on all imx silicons (except imx23 and imx28
> which are known as former stmp).
>
>>
>> (in essence, "fsl,imx51-uart" becomes the generic string without the
>> downside of having no obvious recourse when new silicon shows up tha=
t
>> is an imx part, but isn't compatible with the imx51 uart.
>>
> In this case, should imx1 the ancestor of imx family than imx51
> becomes part of that generic string? =A0Claiming uart of imx1, imx21
> and imx31 (senior than imx51) compatible with the imx51 uart seems
> odd to me.
>
> That said, IMO, "fsl,imx-uart" stands a real IP block specification
> here and can be a perfect generic compatibility string to tell the
> recourse of any imx silicon using this IP.

Yes, but which /version/ of the IP block?  Hardware designers are
notorious for changing hardware designs for newer silicon, sometimes
to add features, sometimes to fix bugs.  While I understand the
temptation to boil a compatible value down to a nice clean generic
string, doing so only works in a perfect world.  In the real world,
you still need to have some information about the specific
implementation.  I prefer this specifying it to the SoC name, but I've
been known to be convinced that specifying it to the ip-block name &
version in certain circumstances, like for IP blocks in an FPGA, or
some of the Freescale powerpc pXXXX SoCs which actually had an IP
block swapped out midway through the life of the chip.

Besides, encoding an soc or ip block version into the 'generic'
compatible values is not just good practice, it has *zero downside*.
That's the beauty of the compatible property semantics.  Any node can
claim compatibility with an existing device.  If no existing device
fits correctly, then the node simple does not claim compatibility.
Drivers can bind to any number of compatible strings, so it would be
just fine for the of_match_table list to include both "fsl,imx-21" and
"fsl,imx-51" (assuming that is the appropriate solution in this case).

>
>> > +- reg : address and length of the register set for the device
>> > +- interrupts : should contain uart interrupt
>> > +- id : should be the port ID defined by soc
>> > +
>> > +Optional properties:
>> > +- fsl,has-rts-cts : indicate it has rts-cts
>> > +- fsl,irda-mode : support irda mode
>> > +
>> > +Example:
>> > +
>> > +uart@73fbc000 {
>> > + =A0 compatible =3D "fsl,imx51-uart", "fsl,imx-uart";
>> > + =A0 reg =3D <0x73fbc000 0x4000>;
>> > + =A0 interrupts =3D <31>;
>> > + =A0 id =3D <1>;
>> > + =A0 fsl,has-rts-cts;
>> > +};
>> > diff --git a/drivers/tty/serial/imx.c b/drivers/tty/serial/imx.c
>> > index a544731..2769353 100644
>> > --- a/drivers/tty/serial/imx.c
>> > +++ b/drivers/tty/serial/imx.c
>> > @@ -45,6 +45,8 @@
>> > =A0#include <linux/delay.h>
>> > =A0#include <linux/rational.h>
>> > =A0#include <linux/slab.h>
>> > +#include <linux/of.h>
>> > +#include <linux/of_address.h>
>> >
>> > =A0#include <asm/io.h>
>> > =A0#include <asm/irq.h>
>> > @@ -1223,6 +1225,63 @@ static int serial_imx_resume(struct platfor=
m_device *dev)
>> > =A0 =A0 return 0;
>> > =A0}
>> >
>> > +#ifdef CONFIG_OF
>> > +static int serial_imx_probe_dt(struct imx_port *sport,
>> > + =A0 =A0 =A0 =A0 =A0 struct platform_device *pdev)
>> > +{
>> > + =A0 struct device_node *node =3D pdev->dev.of_node;
>> > + =A0 const __be32 *line;
>> > +
>> > + =A0 if (!node)
>> > + =A0 =A0 =A0 =A0 =A0 return -ENODEV;
>> > +
>> > + =A0 line =3D of_get_property(node, "id", NULL);
>> > + =A0 if (!line)
>> > + =A0 =A0 =A0 =A0 =A0 return -ENODEV;
>> > +
>> > + =A0 sport->port.line =3D be32_to_cpup(line) - 1;
>>
>> Hmmm, I really would like to be rid of this. =A0Instead, if uarts mu=
st
>> be enumerated, the driver should look for a /aliases/uart* property
>> that matches the of_node. =A0Doing it that way is already establishe=
d in
>> the OpenFirmware documentation, and it ensures there are no overlaps
>> in the global namespace.
>>
>
> I just gave one more try to avoid using 'aliases', and you gave a
> 'no' again. =A0Now, I know how hard you are on this. =A0Okay, I start
> thinking about your suggestion seriously :)

Ha ha ha.

>
>> We do need some infrastructure to make that easier though. =A0Would =
you
>> have time to help put that together?
>>
> Ok, I will give it a try.

Cool. We'll talk next week about it.
