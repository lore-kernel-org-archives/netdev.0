From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 1/3] serial/imx: add device tree support
Date: Wed, 22 Jun 2011 09:52:11 -0600
Message-ID: <BANLkTimsk2eWKPi2hnHbaAn-vSMKmdYsGQ@mail.gmail.com>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
	<1308410354-21387-2-git-send-email-shawn.guo@linaro.org>
	<20110618161934.GH8195@ponder.secretlab.ca>
	<20110619073000.GA23171@S2100-06.ap.freescale.net>
	<20110621135558.GB9228@S2101-09.ap.freescale.net>
	<BANLkTim4vunTm1176MRw3pqRZnunu4=9jg@mail.gmail.com>
	<20110622153353.GA25799@S2100-06.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: patches@linaro.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	Jason Liu <jason.hui@linaro.org>, linux-kernel@vger.kernel.org,
	Jeremy Kerr <jeremy.kerr@canonical.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	linux-arm-kernel@lists.infradead.org,
	David Gibson <david@gibson.dropbear.id.au>
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20110622153353.GA25799@S2100-06.ap.freescale.net>
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

On Wed, Jun 22, 2011 at 9:33 AM, Shawn Guo <shawn.guo@freescale.com> wrote:
> On Tue, Jun 21, 2011 at 01:13:50PM -0600, Grant Likely wrote:
>> On Tue, Jun 21, 2011 at 7:55 AM, Shawn Guo <shawn.guo@freescale.com> wro=
te:
>> > Hi Grant,
>> >
>> > I just gave a try to use aliases node for identify the device index.
>> > Please take a look and let me know if it's what you expect.
>>
>> Thanks Shawn. =A0This is definitely on track. =A0Comments below...
>>
>> >
>> > On Sun, Jun 19, 2011 at 03:30:02PM +0800, Shawn Guo wrote:
>> > [...]
>> >> > >
>> >> > > +#ifdef CONFIG_OF
>> >> > > +static int serial_imx_probe_dt(struct imx_port *sport,
>> >> > > + =A0 =A0 =A0 =A0 struct platform_device *pdev)
>> >> > > +{
>> >> > > + struct device_node *node =3D pdev->dev.of_node;
>> >> > > + const __be32 *line;
>> >> > > +
>> >> > > + if (!node)
>> >> > > + =A0 =A0 =A0 =A0 return -ENODEV;
>> >> > > +
>> >> > > + line =3D of_get_property(node, "id", NULL);
>> >> > > + if (!line)
>> >> > > + =A0 =A0 =A0 =A0 return -ENODEV;
>> >> > > +
>> >> > > + sport->port.line =3D be32_to_cpup(line) - 1;
>> >> >
>> >> > Hmmm, I really would like to be rid of this. =A0Instead, if uarts m=
ust
>> >> > be enumerated, the driver should look for a /aliases/uart* property
>> >> > that matches the of_node. =A0Doing it that way is already establish=
ed in
>> >> > the OpenFirmware documentation, and it ensures there are no overlaps
>> >> > in the global namespace.
>> >> >
>> >>
>> >> I just gave one more try to avoid using 'aliases', and you gave a
>> >> 'no' again. =A0Now, I know how hard you are on this. =A0Okay, I start
>> >> thinking about your suggestion seriously :)
>> >>
>> >> > We do need some infrastructure to make that easier though. =A0Would=
 you
>> >> > have time to help put that together?
>> >> >
>> >> Ok, I will give it a try.
>> >>
>> >
>> > diff --git a/arch/arm/boot/dts/imx51-babbage.dts b/arch/arm/boot/dts/i=
mx51-babbage.dts
>> > index da0381a..f4a5c3c 100644
>> > --- a/arch/arm/boot/dts/imx51-babbage.dts
>> > +++ b/arch/arm/boot/dts/imx51-babbage.dts
>> > @@ -18,6 +18,12 @@
>> > =A0 =A0 =A0 =A0compatible =3D "fsl,imx51-babbage", "fsl,imx51";
>> > =A0 =A0 =A0 =A0interrupt-parent =3D <&tzic>;
>> >
>> > + =A0 =A0 =A0 aliases {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 serial0 =3D &uart0;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 serial1 =3D &uart1;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 serial2 =3D &uart2;
>> > + =A0 =A0 =A0 };
>> > +
>>
>> Hmmm. =A0David Gibson had tossed out an idea of automatically generating
>> aliases from labels. =A0It may be time to revisit that idea.
>>
>> David, perhaps using this format for a label should turn it into an
>> alias (prefix label with an asterisk):
>>
>> =A0 =A0 =A0 =A0 *thealias: i2c@12340000 { /*...*/ };
>>
>> .... although that approach gets *really* hairy when considering that
>> different boards will want different enumeration. =A0How would one
>> override an automatic alias defined by an included .dts file?
>>
> Another dependency the patch has to wait for? =A0Or we can go ahead and
> utilize the facility later when it gets ready?

No, this isn't something you need to wait for.  Just musing on future
enhancements.

>> Also, when obtaining an enumeration for a device, you'll need to be
>> careful about what number gets returned. =A0If the node doesn't match a
>> given alias, but aliases do exist for other devices of like type, then
>> you need to be careful not to assign a number already assigned to
>> another device via an alias (this of course assumes the driver
>> supports dynamics enumeration, which many drivers will). =A0It would be
>>
> Some words not finished?

heh, that happens sometimes.  I tend to be a bit scattered when
replying to email.  Just ignore the last sentence fragment.

>> > - =A0 =A0 =A0 line =3D of_get_property(node, "id", NULL);
>> > - =A0 =A0 =A0 if (!line)
>> > + =A0 =A0 =A0 line =3D of_get_device_index(node, "serial");
>> > + =A0 =A0 =A0 if (IS_ERR_VALUE(line))
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENODEV;
>>
>> Personally, it an alias isn't present, then I'd dynamically assign a por=
t id.
>>
> We probably can not. =A0The driver works with being told the correct
> port id which is defined by soc. =A0Instead of dynamically assigning
> a port id, we have to tell the driver the exact hardware port id of
> the device that is being probed.

Are you sure?  It doesn't look like the driver behaviour uses id for
anything other than an index into the statically allocated serial port
instance table.  I don't see any change of behaviour based on the port
number anywhere.

g.
