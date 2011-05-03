From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] usbnet: runtime pm: fix out of memory
Date: Tue, 3 May 2011 09:53:44 +0200
Message-ID: <201105030953.44131.oneukum@suse.de>
References: <1304066229-30875-1-git-send-email-tom.leiming@gmail.com> <20110502.155214.179953741.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110502.155214.179953741.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 3. Mai 2011, 00:52:14 schrieb David Miller:
> From: tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
> Date: Fri, 29 Apr 2011 16:37:09 +0800
>=20
> > From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >=20
> > This patch makes use of the EVENT_DEV_OPEN flag introduced recently=
 to
> > fix one out of memory issue, which can be reproduced on omap3/4 bas=
ed
> > pandaboard/beagle XM easily with steps below:
>  ...
>=20
> Oliver please review this patch.  Thanks!
>=20
> >       - enable runtime pm
> >       echo auto > /sys/devices/platform/usbhs-omap.0/ehci-omap.0/us=
b1/1-1/1-1.1/power/control
> >=20
> >       - ifconfig eth0 up
> >=20
> >       - then out of memroy happened, see [1] for kernel message.
> >=20
> > Follows my analysis:
> >       - 'ifconfig eth0 up' brings eth0 out of suspend, and usbnet_r=
esume
> >       is called to schedule dev->bh, then rx urbs are submited to p=
repare for
> >       recieving data;
> >=20
> >       - some usbnet devices will produce garbage rx packets flood i=
f
> >       info->reset is not called in usbnet_open.
> >=20
> >       - so there is no enough chances for usbnet_bh to handle and r=
elease
> >       recieved skb buffers since many rx interrupts consumes cpu, s=
o out of memory
> >       for atomic allocation in rx_submit happened.
> >=20
> > This patch fixes the issue by simply not allowing schedule of usbne=
t_bh until device
> > is opened.

Do the devices in question use cdc_ether?
The problem I see with this patch is that cdc_ether uses .reset_resume =
=3D usbnet_resume
Therefore the device will not have been reset from the viewpoint of the=
 device, yet
the device may be open, so the bug would strike again.

It seems to me that this patch is not wrong as such, but incomplete.

	Regards
		Oliver

--=20
- - -=20
SUSE LINUX Products GmbH, GF: Jeff Hawn, Jennifer Guild, Felix Imend=F6=
rffer, HRB 16746 (AG N=FCrnberg)=20
Maxfeldstra=DFe 5                        =20
90409 N=FCrnberg=20
Germany=20
- - -=20
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
