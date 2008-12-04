From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: ixp4xx_hss: Little improvement in create_chan function
Date: Thu, 04 Dec 2008 21:54:00 +0100
Message-ID: <m34p1jzmon.fsf@maximus.localdomain>
References: <b0438a630811260938n14835453jda2da43c6f1445f9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-2?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:53398 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754882AbYLDUyD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 15:54:03 -0500
In-Reply-To: <b0438a630811260938n14835453jda2da43c6f1445f9@mail.gmail.com>
 ("Miguel =?iso-8859-2?Q?=C1ngel_=C1lvarez=22's?= message of "Wed\, 26 Nov
 2008 18\:38\:10 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:

> We are searching for the desired channel three times in the same list=
=2E
> So I think we could erase two of them. What do you think?
>
> +++ ixp4xx_hss.c.create_chan	2008-11-26 18:34:23.000000000 +0100
>
>  	for (ch =3D 0; ch < MAX_CHANNELS; ch++)
> -		if (channels[ch] && port->channels[ch] !=3D CHANNEL_UNUSED) {
> -			printk(KERN_DEBUG "Channel #%i already in use\n", ch);
> -			err =3D -EBUSY;
> -			goto free;

Well, the above checks if _all_ needed port->channels[] are unused.

> +		if (channels[ch]) {
> +		 	if (port->channels[ch] !=3D CHANNEL_UNUSED) {
> +				printk(KERN_DEBUG "Channel #%i already in use\n", ch);
> +				err =3D -EBUSY;
> +				goto free;
> +			} else
> +				break;

We can't break here because we have to check all the remaining
channels (which are in channels[]).

>  		}
>

> -	for (ch =3D 0; ch < MAX_CHANNELS; ch++)
> -		if (channels[ch])
> -			break;
> -

This simply seeks the first channel (to pick up number for the
device name).

> -	for (ch =3D 0; ch < MAX_CHANNELS; ch++)
> -		if (channels[ch])
> -			port->channels[ch] =3D id;

This sets the ID of all requested channels (i.e., it's some sort of
a bitmap).

> +	port->channels[ch] =3D id;
>  	port->chan_devices[id] =3D chan_dev;
>  	dev_set_drvdata(chan_dev->dev, chan_dev);
>  	BUG_ON(device_create_file(chan_dev->dev, &chan_attr));

We need to
a) first check if all needed channels are free, then
b) mark the above as used (with our ID), and
c) note the first requested ID for the device name.

"c" could be optimized (in terms of execution speed), perhaps. Since
it's a slow path (device setup), I didn't bother, I just tried to use
something simple and readable.
--=20
Krzysztof Halasa
