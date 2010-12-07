From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: usbnet: Recursive Locking bug ?
Date: Tue, 7 Dec 2010 15:54:37 +0100
Message-ID: <201012071554.37519.oneukum@suse.de>
References: <AANLkTikBjxZEvWu+322qP2v0MU9xFQrgJmq2xA-Zdo32@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Neil Jones <neiljay-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTikBjxZEvWu+322qP2v0MU9xFQrgJmq2xA-Zdo32-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 7. Dezember 2010, 15:08:43 schrieb Neil Jones:
> I think this is due to unlink_urbs():

Definitely.

> static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q)
> {
>         unsigned long           flags;
>         struct sk_buff          *skb, *skbnext;
>         int                     count = 0;
> 
>         spin_lock_irqsave (&q->lock, flags);
>         skb_queue_walk_safe(q, skb, skbnext) {
>                 struct skb_data         *entry;
>                 struct urb              *urb;
>                 int                     retval;
> 
>                 entry = (struct skb_data *) skb->cb;
>                 urb = entry->urb;
> 
>                 // during some PM-driven resume scenarios,
>                 // these (async) unlinks complete immediately
>                 retval = usb_unlink_urb (urb);
>                 if (retval != -EINPROGRESS && retval != 0)
>                         netdev_dbg(dev->net, "unlink urb err, %d\n", retval);
>                 else
>                         count++;
>         }
>         spin_unlock_irqrestore (&q->lock, flags);
>         return count;
> }
> 
> I dont think this should hold the list lock when calling usb_unlink_urb (urb).
> The completion for the URBs takes the lock as required in its bottom half:

But what makes sure that the URB unlinked in unlink_urbs() stays a valid pointer?
The bottom half may run and free the URB.

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
