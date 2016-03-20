From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] lan78xx: Protect runtime_auto check by #ifdef CONFIG_PM
Date: Sun, 20 Mar 2016 09:35:52 -0700
Message-ID: <1458491752.10868.4.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1458470636-18986-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Woojung Huh <woojung.huh@microchip.com>,
	Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-pm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35808 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbcCTQfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2016 12:35:55 -0400
In-Reply-To: <1458470636-18986-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-03-20 at 11:43 +0100, Geert Uytterhoeven wrote:
> If CONFIG_PM=3Dn:
>=20
>     drivers/net/usb/lan78xx.c: In function =E2=80=98lan78xx_get_stats=
64=E2=80=99:
>     drivers/net/usb/lan78xx.c:3274: error: =E2=80=98struct dev_pm_inf=
o=E2=80=99 has no member named =E2=80=98runtime_auto=E2=80=99
>=20
> If PM is disabled, the runtime_auto flag is not available, but auto
> suspend is not enabled anyway.  Hence protect the check for runtime_a=
uto
> by #ifdef CONFIG_PM to fix this.
>=20
> Fixes: a59f8c5b048dc938 ("lan78xx: add ndo_get_stats64")
> Reported-by: Guenter Roeck <linux@roeck-us.net>
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
> Alternatively, we can add a dev_pm_runtime_auto_is_enabled() wrapper =
to
> include/linux/pm.h, which always return false if CONFIG_PM is disable=
d.
>=20
> The only other user in non-core code (drivers/usb/core/sysfs.c) has a
> big #ifdef CONFIG_PM check around all PM-related code.
>=20
> Thoughts?
> ---
>  drivers/net/usb/lan78xx.c | 2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
> index d36d5ebf37f355f2..7b9ac47b2ecf9905 100644
> --- a/drivers/net/usb/lan78xx.c
> +++ b/drivers/net/usb/lan78xx.c
> @@ -3271,7 +3271,9 @@ struct rtnl_link_stats64 *lan78xx_get_stats64(s=
truct net_device *netdev,
>  	 * periodic reading from HW will prevent from entering USB auto sus=
pend.
>  	 * if autosuspend is disabled, read from HW.
>  	 */
> +#ifdef CONFIG_PM
>  	if (!dev->udev->dev.power.runtime_auto)
> +#endif
>  		lan78xx_update_stats(dev);
> =20
>  	mutex_lock(&dev->stats.access_lock);

Note that a ndo_get_stat64() handler is not allowed to sleep,
so the mutex_lock() is not wise...

Historically /proc/net/dev handler but also bonding ndo_get_stats() use=
d
RCU or a rwlock or a spinlock.

So a complete fix would need to get rid of this mutex as well.
