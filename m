From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Subject: Re: Several races in "usbnet" module (kernel 4.1.x)
Date: Fri, 14 Aug 2015 19:55:26 +0300
Message-ID: <55CE1D7E.2070400@rosalab.ru>
References: <55AD3A41.2040100@rosalab.ru> <1437488529.3823.16.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437488529.3823.16.camel@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

21.07.2015 17:22, Oliver Neukum =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Mon, 2015-07-20 at 21:13 +0300, Eugene Shatokhin wrote:
>> And here, the code clears EVENT_RX_KILL bit in dev->flags, which may
>> execute concurrently with the above operation:
>> #0 clear_bit (bitops.h:113, inlined)
>> #1 usbnet_bh (usbnet.c:1475)
>>          /* restart RX again after disabling due to high error rate =
*/
>>          clear_bit(EVENT_RX_KILL, &dev->flags);
>>
>> If clear_bit() is atomic w.r.t. setting dev->flags to 0, this race i=
s
>> not a problem, I guess. Otherwise, it may be.
>
> clear_bit is atomic with respect to other atomic operations.
> So how about this:
>
> 	Regards
> 		Oliver
>
>>From 1c4e685b3a9c183e04c46b661830e5c7ed35b513 Mon Sep 17 00:00:00 200=
1
> From: Oliver Neukum <oneukum@suse.com>
> Date: Tue, 21 Jul 2015 16:19:40 +0200
> Subject: [PATCH] usbnet: fix race between usbnet_stop() and the BH
>
> Does this do the job?
>
> Signed-off-by: Oliver Neukum <oneukum@suse.com>
> ---
>   drivers/net/usb/usbnet.c | 9 ++++++---
>   1 file changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 3c86b10..77a9a86 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -778,7 +778,7 @@ int usbnet_stop (struct net_device *net)
>   {
>   	struct usbnet		*dev =3D netdev_priv(net);
>   	struct driver_info	*info =3D dev->driver_info;
> -	int			retval, pm;
> +	int			retval, pm, mpn;
>
>   	clear_bit(EVENT_DEV_OPEN, &dev->flags);
>   	netif_stop_queue (net);
> @@ -813,14 +813,17 @@ int usbnet_stop (struct net_device *net)
>   	 * can't flush_scheduled_work() until we drop rtnl (later),
>   	 * else workers could deadlock; so make workers a NOP.
>   	 */
> +	mpn =3D !test_and_clear_bit(EVENT_NO_RUNTIME_PM, &dev->flags);
>   	dev->flags =3D 0;
>   	del_timer_sync (&dev->delay);
>   	tasklet_kill (&dev->bh);
> +	mpn |=3D !test_and_clear_bit(EVENT_NO_RUNTIME_PM, &dev->flags);
> +	/* in case the bh reset a flag */
> +	dev->flags =3D 0;
>   	if (!pm)
>   		usb_autopm_put_interface(dev->intf);
>
> -	if (info->manage_power &&
> -	    !test_and_clear_bit(EVENT_NO_RUNTIME_PM, &dev->flags))
> +	if (info->manage_power && mpn)
>   		info->manage_power(dev, 0);
>   	else
>   		usb_autopm_put_interface(dev->intf);
>

 From what we have discussed here, I have combined a patch that fixes=20
the race #1 in usbnet_stop() and makes #4 harmless by using atomics. I=20
will send it shortly.

I had to make some adjustments (e.g. using spin_lock_nested in one plac=
e=20
for lockdep to see it is OK to take dev->done.lock there).

I have tested the patch on the mainline kernel 4.2-rc6 built for x86-64=
,=20
with the same USB modem. So far, lockdep, Kmemleak (just in case) and m=
y=20
tools have not detected problems in the relevant parts of the code. The=
=20
device and the driver seem to work well.

So, what is your opinion?

Regards,
Eugene
