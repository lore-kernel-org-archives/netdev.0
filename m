From: Oliver Neukum <oneukum@suse.com>
Subject: Re: Several races in "usbnet" module (kernel 4.1.x)
Date: Mon, 27 Jul 2015 14:29:28 +0200
Message-ID: <1438000168.32457.18.camel@suse.com>
References: <55AD3A41.2040100@rosalab.ru> <1437480243.3823.5.camel@suse.com>
	 <55B27805.90601@rosalab.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55B27805.90601@rosalab.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-07-24 at 20:38 +0300, Eugene Shatokhin wrote:
> 21.07.2015 15:04, Oliver Neukum =D0=BF=D0=B8=D1=88=D0=B5=D1=82:

> > your analysis is correct and it looks like in addition to your prop=
osed
> > fix locking needs to be simplified and a common lock to be taken.
> > Suggestions?
>=20
> Just an idea, I haven't tested it.
>=20
> How about moving the operations with dev->done under &list->lock in=20
> defer_bh, while keeping dev->done.lock too and changing=20

Why keep dev->done.lock?
Does it make sense at all?

> usbnet_terminate_urbs() as described below?
>=20
> Like this:
> @@ -428,12 +428,12 @@ static enum skb_state defer_bh(struct usbnet *d=
ev,=20
> struct sk_buff *skb,
>   	old_state =3D entry->state;
>   	entry->state =3D state;
>   	__skb_unlink(skb, list);
> -	spin_unlock(&list->lock);
>   	spin_lock(&dev->done.lock);
>   	__skb_queue_tail(&dev->done, skb);
>   	if (dev->done.qlen =3D=3D 1)
>   		tasklet_schedule(&dev->bh);
> -	spin_unlock_irqrestore(&dev->done.lock, flags);
> +	spin_unlock(&dev->done.lock);
> +	spin_unlock_irqrestore(&list->lock, flags);
>   	return old_state;
>   }
> -------------------
>=20
> usbnet_terminate_urbs() can then be changed as follows:
>=20
> @@ -749,6 +749,20 @@ EXPORT_SYMBOL_GPL(usbnet_unlink_rx_urbs);
>=20
> =20
> /*-------------------------------------------------------------------=
------*/
>=20
> +static void wait_skb_queue_empty(struct sk_buff_head *q)
> +{
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&q->lock, flags);
> +	while (!skb_queue_empty(q)) {
> +		spin_unlock_irqrestore(&q->lock, flags);
> +		schedule_timeout(msecs_to_jiffies(UNLINK_TIMEOUT_MS));
> +		set_current_state(TASK_UNINTERRUPTIBLE);

I suppose you want to invert those lines

> +		spin_lock_irqsave(&q->lock, flags);
> +	}
> +	spin_unlock_irqrestore(&q->lock, flags);
> +}
> +

Your changes make sense, but it locks to me as if a lock would
become totally redundant.

	Regards
		Oliver
