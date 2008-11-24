From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: ixp4xx_hss MAX_CHAN_DEVICES
Date: Mon, 24 Nov 2008 17:14:36 +0100
Message-ID: <m3prkl14pf.fsf@maximus.localdomain>
References: <b0438a630811190317u715f1376j830133591ec497b9@mail.gmail.com>
	<m3fxlksncm.fsf@maximus.localdomain>
	<b0438a630811240203mdc431aev8b1bb9e8c924ac7e@mail.gmail.com>
	<b0438a630811240415n6a1a0b23lf7ac37925d04a6b3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
To: =?iso-8859-2?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:34393 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753240AbYKXQOj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 11:14:39 -0500
In-Reply-To: <b0438a630811240415n6a1a0b23lf7ac37925d04a6b3@mail.gmail.com>
 ("Miguel =?iso-8859-2?Q?=C1ngel_=C1lvarez=22's?= message of "Mon\, 24 Nov
 2008 13\:15\:54 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:

> +++ linux-2.6.26.7/drivers/net/wan/ixp4xx_hss.c	2008-11-24

> +struct physical_modes {
> +	u8 id;
> +	unsigned int frame_size;
> +	unsigned int clock_rate;
> +	u32 clock_config;
> +};

I think the clock rate shouldn't be a part of the fixed port config.
I don't know much about 4E1 configs, but in the usual case (single
physical port connected directly to the HSS) you can use many clock
and frame size configurations.

IOW I think physical mode =3D only signal/timeslot routing topology.
The platform code could also optionally check if the specified clock
type and rate is valid.

> +static const struct physical_modes phmodes[] =3D {
> +	{IXP4XX_HSS_T1, 193, 1544000, CLK42X_SPEED_1544KHZ},
> +	{IXP4XX_HSS_E1, 256, 2048000, CLK42X_SPEED_2048KHZ},
> +	{IXP4XX_HSS_2_E1, 512, 4096000, CLK42X_SPEED_4096KHZ},
> +	{IXP4XX_HSS_4_E1, 1024, 8192000, CLK42X_SPEED_8192KHZ},
> +	{0, 256, 2048000, CLK42X_SPEED_2048KHZ}
> +};

If we need different internal clock rates (most framers/multiplexers
provide their own, don't they?) then I guess we need to calculate the
required settings ourselves. I don't exactly know how do they
calculate the register but it should be easy to find out. There was no
need yet.

> +#define IXP4XX_HSS_T1     0x10
> +#define IXP4XX_HSS_E1     0x11

T1 and E1 are the same WRT hardware connection to the port.

> - How should all these changes interact with show_frame_size and
> set_frame_size?

Perhaps the platform code should initialize the value and then check
changes for validity. Only matters with G.704 framers I think.
Otherwise the user should be able to select anything.

> - I am a bit lost with MAX_CHANNELS and MAX_CHAN_DEVICES... Which are
> the differences between both?

MAX_CHANNELS =3D (currenly) 32 =3D max for single channel (32 E1
channels).
MAX_CHAN_DEVICES =3D limit of /dev/hssXchY nodes (for one port).

> - As MAX_CHANNELS and MAX_CHAN_DEVICES should not be set by defines, =
I
> am going to alloc memory for chan_devices... I am going to do it in
> init_one... Is it OK?.

MAX_CHANNELS, I think so.
MAX_CHAN_DEVICES isn't directly related.

> My first intention for all this is to set HSS into MVIP mode and have
> 4 HDLC channels in a packetized mode.
> - How could I set this MVIP mode?
> - How could I interface with generic HDLC so that hss_hdlc_xmit sends
> the data for each stream to a different FIFO?

The HSS driver should initialize MVIP based on platform's
physical_config value, then it would have to register 4 HDLC devices.

The HDLC part (not the channelized one) should be quite trivial.
I think we now need the HSS HDLC driver upstream, will look at this.
--=20
Krzysztof Halasa
