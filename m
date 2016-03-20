From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] lan78xx: Protect runtime_auto check by #ifdef CONFIG_PM
Date: Sun, 20 Mar 2016 15:59:16 -0700
Message-ID: <56EF2B44.9040807@roeck-us.net>
References: <1458470636-18986-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-pm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>,
	Woojung Huh <woojung.huh@microchip.com>,
	Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458470636-18986-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/20/2016 03:43 AM, Geert Uytterhoeven wrote:
> If CONFIG_PM=3Dn:
>
>      drivers/net/usb/lan78xx.c: In function =E2=80=98lan78xx_get_stat=
s64=E2=80=99:
>      drivers/net/usb/lan78xx.c:3274: error: =E2=80=98struct dev_pm_in=
fo=E2=80=99 has no member named =E2=80=98runtime_auto=E2=80=99
>
> If PM is disabled, the runtime_auto flag is not available, but auto
> suspend is not enabled anyway.  Hence protect the check for runtime_a=
uto
> by #ifdef CONFIG_PM to fix this.
>
> Fixes: a59f8c5b048dc938 ("lan78xx: add ndo_get_stats64")
> Reported-by: Guenter Roeck <linux@roeck-us.net>
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
> Alternatively, we can add a dev_pm_runtime_auto_is_enabled() wrapper =
to
> include/linux/pm.h, which always return false if CONFIG_PM is disable=
d.
>
> The only other user in non-core code (drivers/usb/core/sysfs.c) has a
> big #ifdef CONFIG_PM check around all PM-related code.
>
> Thoughts?

Not that it matters anymore since David reverted the original patch,
but my reason for not sending a similar patch was that I wasn't sure
if .runtime_auto should be accessed from drivers in the first place,
or if there is some logical problem with the code.

Guenter

> ---
>   drivers/net/usb/lan78xx.c | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
> index d36d5ebf37f355f2..7b9ac47b2ecf9905 100644
> --- a/drivers/net/usb/lan78xx.c
> +++ b/drivers/net/usb/lan78xx.c
> @@ -3271,7 +3271,9 @@ struct rtnl_link_stats64 *lan78xx_get_stats64(s=
truct net_device *netdev,
>   	 * periodic reading from HW will prevent from entering USB auto su=
spend.
>   	 * if autosuspend is disabled, read from HW.
>   	 */
> +#ifdef CONFIG_PM
>   	if (!dev->udev->dev.power.runtime_auto)
> +#endif
>   		lan78xx_update_stats(dev);
>
>   	mutex_lock(&dev->stats.access_lock);
>
