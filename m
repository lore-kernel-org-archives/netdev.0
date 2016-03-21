From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH] lan78xx: Protect runtime_auto check by #ifdef CONFIG_PM
Date: Mon, 21 Mar 2016 10:57:45 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1603211049050.1708-100000@iolanthe.rowland.org>
References: <1458549361.2299.1.camel@suse.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Woojung Huh <woojung.huh@microchip.com>,
	Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <linux-pm@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458549361.2299.1.camel@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Mar 2016, Oliver Neukum wrote:

> On Sun, 2016-03-20 at 11:43 +0100, Geert Uytterhoeven wrote:
> > If CONFIG_PM=3Dn:
> >=20
> >     drivers/net/usb/lan78xx.c: In function =E2=80=98lan78xx_get_sta=
ts64=E2=80=99:
> >     drivers/net/usb/lan78xx.c:3274: error: =E2=80=98struct dev_pm_i=
nfo=E2=80=99 has no
> > member named =E2=80=98runtime_auto=E2=80=99
> >=20
> > If PM is disabled, the runtime_auto flag is not available, but auto
> > suspend is not enabled anyway.  Hence protect the check for
> > runtime_auto
> > by #ifdef CONFIG_PM to fix this.
> >=20
> > Fixes: a59f8c5b048dc938 ("lan78xx: add ndo_get_stats64")
> > Reported-by: Guenter Roeck <linux@roeck-us.net>
> > Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> > ---
> > Alternatively, we can add a dev_pm_runtime_auto_is_enabled() wrappe=
r
> > to
> > include/linux/pm.h, which always return false if CONFIG_PM is
> > disabled.
>=20
> That is what we do for almost everything else in include/pm_runtime.h
> So it is the best solution to add the stub.

Guenter's question about whether drivers should try to access
runtime_auto in the first place was a good one.  A similar problem
arises in the block layer: When a block device has removable media, the
block layer probes at 1-second intervals looking for media changes. =20
This defeats autosuspend in the same way as we're talking about here.

One possible solution is to export a sysfs parameter to prevent=20
statistics collection (or more generally, to change the interval at=20
which it occurs).

But checking the runtime_auto flag is probably not a great idea.  Even
if it isn't set, collecting statistics is likely to wait up a device
that otherwise would have remained suspended.

Perhaps the best solution is to collect the statistics only when the=20
device is not suspended or is about to suspend.

Alan Stern
