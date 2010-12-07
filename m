From: Neil Jones <neiljay-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: usbnet: Recursive Locking bug ?
Date: Tue, 7 Dec 2010 14:08:43 +0000
Message-ID: <AANLkTikBjxZEvWu+322qP2v0MU9xFQrgJmq2xA-Zdo32@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I get a recursice lock warning from usbnet (asix adapter) with lockdep
checking on:

=============================================
[ INFO: possible recursive locking detected ]
2.6.37-rc4+ #1695
---------------------------------------------
ifconfig/536 is trying to acquire lock:
 (&(&list->lock)->rlock#2){-.-...}, at: [<401a63bc>] _defer_bh+0x24/0x124

but task is already holding lock:
 (&(&list->lock)->rlock#2){-.-...}, at: [<401a5f28>] _unlink_urbs+0x1c/0xa8

other info that might help us debug this:
2 locks held by ifconfig/536:
 #0:  (rtnl_mutex){+.+.+.}, at: [<4026b4f8>] _rtnl_lock+0x1c/0x2c
 #1:  (&(&list->lock)->rlock#2){-.-...}, at: [<401a5f28>] _unlink_urbs+0x1c/0xa8

this occurs on bring the interface down.

I think this is due to unlink_urbs():

static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q)
{
	unsigned long		flags;
	struct sk_buff		*skb, *skbnext;
	int			count = 0;

	spin_lock_irqsave (&q->lock, flags);
	skb_queue_walk_safe(q, skb, skbnext) {
		struct skb_data		*entry;
		struct urb		*urb;
		int			retval;

		entry = (struct skb_data *) skb->cb;
		urb = entry->urb;

		// during some PM-driven resume scenarios,
		// these (async) unlinks complete immediately
		retval = usb_unlink_urb (urb);
		if (retval != -EINPROGRESS && retval != 0)
			netdev_dbg(dev->net, "unlink urb err, %d\n", retval);
		else
			count++;
	}
	spin_unlock_irqrestore (&q->lock, flags);
	return count;
}

I dont think this should hold the list lock when calling usb_unlink_urb (urb).
The completion for the URBs takes the lock as required in its bottom half:

If people agree I will submit a patch.

Cheers

Neil
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
