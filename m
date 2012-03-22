From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: use-after-free in usbnet
Date: Thu, 22 Mar 2012 17:30:36 +0800
Message-ID: <CACVXFVODFvtF1DRyWJmnYCByw7sr9QDv_+Taxo5maVaUauDNtg@mail.gmail.com>
References: <CACVXFVP+U1k7JFTmbabF-k8F3bO9zc58c3tLG6=1nQPcrR9p1g@mail.gmail.com>
	<Pine.LNX.4.44L0.1203211201560.1369-100000@iolanthe.rowland.org>
	<CACVXFVOVjnWjqpKxbU98DAyUC_OSb8ZL-3WcyYuFXgPJn5UyuA@mail.gmail.com>
	<201203221008.46882.oneukum@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Fedora Kernel Team <kernel-team-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>,
	Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201203221008.46882.oneukum-l3A5Bk7waGM@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 22, 2012 at 5:08 PM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
>
> this looks good, but could you add a comment explaining the reason for
> taking a reference?

OK, I will post a formal one if you have no objection on the below.

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 4b8b52c..febfdce 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -589,6 +589,14 @@ static int unlink_urbs (struct usbnet *dev,
struct sk_buff_head *q)
 		entry = (struct skb_data *) skb->cb;
 		urb = entry->urb;

+		/*
+		 * Get a reference count of the URB to avoid it to be
+		 * freed during usb_unlink_urb, which may trigger
+		 * use-after-free problem inside usb_unlink_urb since
+		 * usb_unlink_urb is always racing with .complete
+		 * handler(include defer_bh).
+		 */
+		usb_get_urb(urb);
 		spin_unlock_irqrestore(&q->lock, flags);
 		// during some PM-driven resume scenarios,
 		// these (async) unlinks complete immediately
@@ -597,6 +605,7 @@ static int unlink_urbs (struct usbnet *dev, struct
sk_buff_head *q)
 			netdev_dbg(dev->net, "unlink urb err, %d\n", retval);
 		else
 			count++;
+		usb_put_urb(urb);
 		spin_lock_irqsave(&q->lock, flags);
 	}
 	spin_unlock_irqrestore (&q->lock, flags);


Thanks,
-- 
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
