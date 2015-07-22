From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Subject: Re: Several races in "usbnet" module (kernel 4.1.x)
Date: Wed, 22 Jul 2015 21:33:52 +0300
Message-ID: <55AFE210.7030104@rosalab.ru>
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

Thanks for the quick replies!
My comments are below.

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

Right, I missed that. Indeed, if one needs EVENT_NO_RUNTIME_PM bit, one=
=20
should get it before dev->flags is set to 0.

>   	dev->flags =3D 0;

I suppose usbnet_bh() cannot be re-scheduled at this point. And if it i=
s=20
running now, tasklet_kill will wait till it finishes. So, I guess, it=20
would be enough to zero dev->flags after "tasklet_kill (&dev->bh);"=20
rather than before it, like it is now.

Anyway, if it is needed to clear any particular flags to prevent=20
re-scheduling of usbnet_bh(), this can be done here with clear_bit().=20
Not sure if there are such flags, I am by no means an expert in usbnet.

>   	del_timer_sync (&dev->delay);
>   	tasklet_kill (&dev->bh);

The following part is not necessary, I think. usbnet_bh() does not touc=
h=20
EVENT_NO_RUNTIME_PM bit explicitly and these bit operations are atomic=20
w.r.t. each other.

> +	mpn |=3D !test_and_clear_bit(EVENT_NO_RUNTIME_PM, &dev->flags);
> +	/* in case the bh reset a flag */

But zeroing dev->flags here is necessary, I agree.

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

Regards,
Eugene
