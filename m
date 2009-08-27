From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 1/2] alchemy: add au1000-eth platform device
Date: Thu, 27 Aug 2009 16:55:09 +0200
Message-ID: <200908271655.11086.florian@openwrt.org>
References: <200908170105.38154.florian@openwrt.org> <200908271442.36306.florian@openwrt.org> <4A969519.7010604@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org,
	Manuel Lauss <manuel.lauss@googlemail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:49431 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638AbZH0OzP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2009 10:55:15 -0400
Received: by ewy2 with SMTP id 2so1269911ewy.17
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2009 07:55:16 -0700 (PDT)
In-Reply-To: <4A969519.7010604@ru.mvista.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Le Thursday 27 August 2009 16:15:53 Sergei Shtylyov, vous avez =E9crit=A0=
:
> Hello.
>
> Florian Fainelli wrote:
> >>>>>This patch adds the board code to register a per-board au1000-et=
h
> >>>>>platform device to be used wit the au1000-eth platform driver in=
 a
> >>>>>subsequent patch. Note that the au1000-eth driver knows about th=
e
> >>>>>default driver settings such that we do not need to pass any
> >>>>>platform_data informations in most cases except db1x00.
> >>>>
> >>>>   Sigh, NAK...
> >>>>   Please don't register the SoC device per board, do it in
> >>>>alchemy/common/platfrom.c and find a way to pass the board specif=
ic
> >>>>platform data from the board file there instead -- something like
> >>>>arch/arm/mach-davinci/usb.c does.
> >>>
> >>>Ok, like I promised, this was the per-board device registration. D=
o you
> >>>prefer something like this:
> >>
> >>    I certainly do, but still not in this incarnation... :-)
> >>
> >>>+static struct au1000_eth_platform_data au1xxx_eth0_platform_data =
=3D {
> >>>+	.phy1_search_mac0 =3D 1,
> >>>+};
> >>
> >>    I'm not sure that the default platfrom data is really a great i=
dea...
> >
> > Can you elaborate a bit more ? We actually need to make the Etherne=
t MAC
> > driver aware of some PHY settings.
>
>     But why do you have the platform data in *this* file, no the boar=
d
> files?

The default setting is to search for a PHY on the corresponding MAC, wh=
ich is=20
the case for all boards but bosporus, thus it is in this file. No platf=
orm=20
data at all would be fine too.

>
> >>>+#ifndef CONFIG_SOC_AU1100
> >>>+static struct platform_device au1xxx_eth1_device =3D {
> >>>+	.name		=3D "au1000-eth",
> >>>+	.id		=3D 1,
> >>>+	.num_resources	=3D ARRAY_SIZE(au1xxx_eth1_resources),
> >>>+	.resource	=3D au1xxx_eth1_resources,
> >>
> >>    And where's the platfrom data for the second Ethernet?
> >
> > There is no need to, as the driver originally did not override any
> > specific settings on the second MAC (afair).
>
>     Specific settings where, in the driver? Shouldn't all such settin=
gs be
> bound to the platform data instead?

Yes, platform data should handle that for us, what I was trying to expl=
ain is=20
that the driver did not configure anything specific for MAC1 already, t=
hus=20
there is no platfo

>
> >>>+};
> >>>+#endif
> >>>+
> >>>+void __init au1xxx_override_eth0_cfg(struct au1000_eth_platform_d=
ata
> >>>*eth_data) +{
> >>>+	if (!eth_data)
> >>>+		return;
> >>>+
> >>>+	memcpy(&au1xxx_eth0_platform_data, eth_data,
> >>>+		sizeof(struct au1000_eth_platform_data));
> >>
> >>    Why not just set the pointer in au1xxx_eth0_device. And really,=
 why
> >> not make the function more generic, with a prototype like:
> >
> > For the same reasons as explained below, MAC1 did not need any spec=
ific
> > change.
>
>     So, the driver can get away without platform data? What does it d=
o in
> this case -- I haven't looked at that patch?

In that case it searchs for a PHY attached to the MAC, this is what the=
 driver=20
did already. Please have a look at the patch, specifically the part whi=
ch=20
handles a NULL platform_data.

>
> >>void __init au1xxx_override_eth_cfg(unsigned port, struct
> >>				    au1000_eth_platform_data *eth_data);
> >>
> >>>+}
> >>>+
> >>> static struct platform_device *au1xxx_platform_devices[] __initda=
ta =3D {
> >>> 	&au1xx0_uart_device,
> >>> 	&au1xxx_usb_ohci_device,
> >>>@@ -351,17 +422,25 @@ static struct platform_device
> >>>*au1xxx_platform_devices[] __initdata =3D { #ifdef SMBUS_PSC_BASE
> >>> 	&pbdb_smbus_device,
> >>> #endif
> >>>+	&au1xxx_eth0_device,
> >>> };
> >>>
> >>> static int __init au1xxx_platform_init(void)
> >>> {
> >>> 	unsigned int uartclk =3D get_au1x00_uart_baud_base() * 16;
> >>>-	int i;
> >>>+	int i, ni;
> >>>
> >>> 	/* Fill up uartclk. */
> >>> 	for (i =3D 0; au1x00_uart_data[i].flags; i++)
> >>> 		au1x00_uart_data[i].uartclk =3D uartclk;
> >>>
> >>>+	/* Register second MAC if enabled in pinfunc */
> >>>+#ifndef CONFIG_SOC_AU1100
> >>>+	ni =3D (int)((au_readl(SYS_PINFUNC) & (u32)(SYS_PF_NI2)) >> 4);
> >>>+	if (!(ni + 1))
> >>
> >>    Why so complex, and how can (ni + 1) ever be 0?! :-/
> >
> > This is left-over debugging stub, I will rework it. About complexit=
y,
> > this line is taken directly from the au1000_eth driver.
>
>     I don't see !(ni + 1) there, only:
>
> 	num_ifs =3D NUM_ETH_INTERFACES - ni;
>
> which is correct, unlike what you've written.
--=20
Best regards, Florian Fainelli
Email: florian@openwrt.org
Web: http://openwrt.org
IRC: [florian] on irc.freenode.net
-------------------------------
