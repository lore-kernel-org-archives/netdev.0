From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 1/3] serial/imx: add device tree support
Date: Tue, 21 Jun 2011 13:38:03 -0600
Message-ID: <BANLkTik9LXTJ--fRwUBscokWraPwOZnpHA@mail.gmail.com>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
 <1308410354-21387-2-git-send-email-shawn.guo@linaro.org> <20110618161934.GH8195@ponder.secretlab.ca>
 <20110619073000.GA23171@S2100-06.ap.freescale.net> <20110621135558.GB9228@S2101-09.ap.freescale.net>
 <BANLkTim4vunTm1176MRw3pqRZnunu4=9jg@mail.gmail.com> <4E00F290.2010303@firmworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: patches@linaro.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	Jason Liu <jason.hui@linaro.org>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Jeremy Kerr <jeremy.kerr@canonical.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Shawn Guo <shawn.guo@freescale.com>
To: Mitch Bradley <wmb@firmworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E00F290.2010303@firmworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 21, 2011 at 1:35 PM, Mitch Bradley <wmb@firmworks.com> wrot=
e:
> What is the problem with
>
> aliases{
> =A0 serial0 =3D "/uart@7000c000";
> }
>
> Properties in the alias node are supposed to have string values.

?

Not sure I follow.  Indeed, properties in the aliases node are string v=
alues.

Are you referring to how I was proposing some dtc syntax for
generating the alias strings?

g.

>
>
> On 6/21/2011 9:13 AM, Grant Likely wrote:
>>
>> On Tue, Jun 21, 2011 at 7:55 AM, Shawn Guo<shawn.guo@freescale.com>
>> =A0wrote:
>>>
>>> Hi Grant,
>>>
>>> I just gave a try to use aliases node for identify the device index=
=2E
>>> Please take a look and let me know if it's what you expect.
>>
>> Thanks Shawn. =A0This is definitely on track. =A0Comments below...
>>
>>>
>>> On Sun, Jun 19, 2011 at 03:30:02PM +0800, Shawn Guo wrote:
>>> [...]
>>>>>>
>>>>>> +#ifdef CONFIG_OF
>>>>>> +static int serial_imx_probe_dt(struct imx_port *sport,
>>>>>> + =A0 =A0 =A0 =A0 struct platform_device *pdev)
>>>>>> +{
>>>>>> + struct device_node *node =3D pdev->dev.of_node;
>>>>>> + const __be32 *line;
>>>>>> +
>>>>>> + if (!node)
>>>>>> + =A0 =A0 =A0 =A0 return -ENODEV;
>>>>>> +
>>>>>> + line =3D of_get_property(node, "id", NULL);
>>>>>> + if (!line)
>>>>>> + =A0 =A0 =A0 =A0 return -ENODEV;
>>>>>> +
>>>>>> + sport->port.line =3D be32_to_cpup(line) - 1;
>>>>>
>>>>> Hmmm, I really would like to be rid of this. =A0Instead, if uarts=
 must
>>>>> be enumerated, the driver should look for a /aliases/uart* proper=
ty
>>>>> that matches the of_node. =A0Doing it that way is already establi=
shed in
>>>>> the OpenFirmware documentation, and it ensures there are no overl=
aps
>>>>> in the global namespace.
>>>>>
>>>>
>>>> I just gave one more try to avoid using 'aliases', and you gave a
>>>> 'no' again. =A0Now, I know how hard you are on this. =A0Okay, I st=
art
>>>> thinking about your suggestion seriously :)
>>>>
>>>>> We do need some infrastructure to make that easier though. =A0Wou=
ld you
>>>>> have time to help put that together?
>>>>>
>>>> Ok, I will give it a try.
>>>>
>>>
>>> diff --git a/arch/arm/boot/dts/imx51-babbage.dts
>>> b/arch/arm/boot/dts/imx51-babbage.dts
>>> index da0381a..f4a5c3c 100644
>>> --- a/arch/arm/boot/dts/imx51-babbage.dts
>>> +++ b/arch/arm/boot/dts/imx51-babbage.dts
>>> @@ -18,6 +18,12 @@
>>> =A0 =A0 =A0 =A0compatible =3D "fsl,imx51-babbage", "fsl,imx51";
>>> =A0 =A0 =A0 =A0interrupt-parent =3D<&tzic>;
>>>
>>> + =A0 =A0 =A0 aliases {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 serial0 =3D&uart0;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 serial1 =3D&uart1;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 serial2 =3D&uart2;
>>> + =A0 =A0 =A0 };
>>> +
>>
>> Hmmm. =A0David Gibson had tossed out an idea of automatically genera=
ting
>> aliases from labels. =A0It may be time to revisit that idea.
>>
>> David, perhaps using this format for a label should turn it into an
>> alias (prefix label with an asterisk):
>>
>> =A0 =A0 =A0 =A0 *thealias: i2c@12340000 { /*...*/ };
>>
>> .... although that approach gets *really* hairy when considering tha=
t
>> different boards will want different enumeration. =A0How would one
>> override an automatic alias defined by an included .dts file?
>>
>>> =A0 =A0 =A0 =A0chosen {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bootargs =3D "console=3Dttymxc0,1152=
00 root=3D/dev/mmcblk0p3
>>> rootwait";
>>> =A0 =A0 =A0 =A0};
>>> @@ -47,29 +53,29 @@
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reg =3D<0x70000000 0=
x40000>;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ranges;
>>>
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 uart@7000c000 {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 uart2: uart@7000c000 =
{
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0comp=
atible =3D "fsl,imx51-uart",
>>> "fsl,imx21-uart";
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reg =
=3D<0x7000c000 0x4000>;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inte=
rrupts =3D<33>;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0id =3D=
<3>;
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fsl,h=
as-rts-cts;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fsl,u=
art-has-rtscts;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
>>>
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 uart@73fbc000 {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 uart0: uart@73fbc000 {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0compatible =3D "fsl,=
imx51-uart", "fsl,imx21-uart";
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reg =3D<0x73fbc000 0=
x4000>;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0interrupts =3D<31>;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0id =3D<1>;
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fsl,has-rts-cts;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fsl,uart-has-rtscts;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
>>>
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 uart@73fc0000 {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 uart1: uart@73fc0000 {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0compatible =3D "fsl,=
imx51-uart", "fsl,imx21-uart";
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reg =3D<0x73fc0000 0=
x4000>;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0interrupts =3D<32>;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0id =3D<2>;
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fsl,has-rts-cts;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fsl,uart-has-rtscts;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
>>> =A0 =A0 =A0 =A0};
>>>
>>> diff --git a/drivers/of/base.c b/drivers/of/base.c
>>> index 632ebae..13df5d2 100644
>>> --- a/drivers/of/base.c
>>> +++ b/drivers/of/base.c
>>> @@ -737,6 +737,37 @@ err0:
>>> =A0EXPORT_SYMBOL(of_parse_phandles_with_args);
>>>
>>> =A0/**
>>> + * =A0 =A0 of_get_device_index - Get device index by looking up "a=
liases"
>>> node
>>> + * =A0 =A0 @np: =A0 =A0Pointer to device node that asks for device=
 index
>>> + * =A0 =A0 @name: =A0The device alias without index number
>>> + *
>>> + * =A0 =A0 Returns the device index if find it, else returns -ENOD=
EV.
>>> + */
>>> +int of_get_device_index(struct device_node *np, const char *alias)
>>> +{
>>> + =A0 =A0 =A0 struct device_node *aliases =3D of_find_node_by_name(=
NULL,
>>> "aliases");
>>> + =A0 =A0 =A0 struct property *prop;
>>> + =A0 =A0 =A0 char name[32];
>>> + =A0 =A0 =A0 int index =3D 0;
>>> +
>>> + =A0 =A0 =A0 if (!aliases)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
>>> +
>>> + =A0 =A0 =A0 while (1) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 snprintf(name, sizeof(name), "%s%d", =
alias, index);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 prop =3D of_find_property(aliases, na=
me, NULL);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!prop)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (np =3D=3D of_find_node_by_path(pr=
op->value))
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 index++;
>>> + =A0 =A0 =A0 }
>>
>> Rather than parsing the alias strings everytime, it would probably b=
e
>> better to preprocess all the properties in the aliases node and crea=
te
>> a lookup table of alias->node references that can be walked quickly
>> and trivially.
>>
>> Also, when obtaining an enumeration for a device, you'll need to be
>> careful about what number gets returned. =A0If the node doesn't matc=
h a
>> given alias, but aliases do exist for other devices of like type, th=
en
>> you need to be careful not to assign a number already assigned to
>> another device via an alias (this of course assumes the driver
>> supports dynamics enumeration, which many drivers will). =A0It would=
 be
>>
>> \> =A0+
>>>
>>> + =A0 =A0 =A0 return index;
>>> +}
>>> +EXPORT_SYMBOL(of_get_device_index);
>>> +
>>> +/**
>>> =A0* prom_add_property - Add a property to a node
>>> =A0*/
>>> =A0int prom_add_property(struct device_node *np, struct property *p=
rop)
>>> diff --git a/drivers/tty/serial/imx.c b/drivers/tty/serial/imx.c
>>> index da436e0..852668f 100644
>>> --- a/drivers/tty/serial/imx.c
>>> +++ b/drivers/tty/serial/imx.c
>>> @@ -1271,18 +1271,18 @@ static int serial_imx_probe_dt(struct imx_p=
ort
>>> *sport,
>>> =A0 =A0 =A0 =A0struct device_node *node =3D pdev->dev.of_node;
>>> =A0 =A0 =A0 =A0const struct of_device_id *of_id =3D
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0of_match_device(imx_=
uart_dt_ids,&pdev->dev);
>>> - =A0 =A0 =A0 const __be32 *line;
>>> + =A0 =A0 =A0 int line;
>>>
>>> =A0 =A0 =A0 =A0if (!node)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENODEV;
>>>
>>> - =A0 =A0 =A0 line =3D of_get_property(node, "id", NULL);
>>> - =A0 =A0 =A0 if (!line)
>>> + =A0 =A0 =A0 line =3D of_get_device_index(node, "serial");
>>> + =A0 =A0 =A0 if (IS_ERR_VALUE(line))
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENODEV;
>>
>> Personally, it an alias isn't present, then I'd dynamically assign a=
 port
>> id.
>>
>>>
>>> - =A0 =A0 =A0 sport->port.line =3D be32_to_cpup(line) - 1;
>>> + =A0 =A0 =A0 sport->port.line =3D line;
>>>
>>> - =A0 =A0 =A0 if (of_get_property(node, "fsl,has-rts-cts", NULL))
>>> + =A0 =A0 =A0 if (of_get_property(node, "fsl,uart-has-rtscts", NULL=
))
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sport->have_rtscts =3D 1;
>>>
>>> =A0 =A0 =A0 =A0if (of_get_property(node, "fsl,irda-mode", NULL))
>>> diff --git a/include/linux/of.h b/include/linux/of.h
>>> index bfc0ed1..3153752 100644
>>> --- a/include/linux/of.h
>>> +++ b/include/linux/of.h
>>> @@ -213,6 +213,8 @@ extern int of_parse_phandles_with_args(struct
>>> device_node *np,
>>> =A0 =A0 =A0 =A0const char *list_name, const char *cells_name, int i=
ndex,
>>> =A0 =A0 =A0 =A0struct device_node **out_node, const void **out_args=
);
>>>
>>> +extern int of_get_device_index(struct device_node *np, const char
>>> *alias);
>>> +
>>> =A0extern int of_machine_is_compatible(const char *compat);
>>>
>>> =A0extern int prom_add_property(struct device_node* np, struct prop=
erty*
>>> prop);
>>>
>>> --
>>> Regards,
>>> Shawn
>>>
>>>
>>
>>
>>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
