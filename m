From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: use-after-free in usbnet
Date: Wed, 21 Mar 2012 09:04:15 +0800
Message-ID: <CACVXFVP9-Ao_UyBoxkxzq5dg8TfkZ9CECqEUFW5bD_JRzfQybw@mail.gmail.com>
References: <20120319151224.GA16031@redhat.com>
	<CACVXFVN5O2S0hsnzHoi=LX+KAnccHc_F0SXq9-hMOXnaoUOdkg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Fedora Kernel Team <kernel-team-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>
To: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVN5O2S0hsnzHoi=LX+KAnccHc_F0SXq9-hMOXnaoUOdkg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 20, 2012 at 5:40 PM, Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Hi,
>
> On Mon, Mar 19, 2012 at 11:12 PM, Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>> We've had two reports of this use after free in Fedora now recently..
>
> Could you provide output of 'dmesg' and 'lsusb -v' from the reported machine?

Looks I have figured out why your problem is triggered.

If the URB being unlinked is freed before usb_put_dev
inside usb_hcd_unlink_urb, the use-after-free will be triggered.
And the below patch[1] should fix the problem.

Also there is another bug in tx_complete() of usbnet, the line below

                urb->dev = NULL;

should be removed to avoid possible oops or memory leak in unlink path.

Please test the patch if you can reproduce the problem.

[1],
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 59681f0..4f4e028 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -592,7 +592,9 @@ static int unlink_urbs (struct usbnet *dev, struct
sk_buff_head *q)
 		spin_unlock_irqrestore(&q->lock, flags);
 		// during some PM-driven resume scenarios,
 		// these (async) unlinks complete immediately
+		local_bh_disable();
 		retval = usb_unlink_urb (urb);
+		local_bh_enable();
 		if (retval != -EINPROGRESS && retval != 0)
 			netdev_dbg(dev->net, "unlink urb err, %d\n", retval);
 		else
@@ -1028,7 +1030,6 @@ static void tx_complete (struct urb *urb)
 	}

 	usb_autopm_put_interface_async(dev->intf);
-	urb->dev = NULL;
 	entry->state = tx_done;
 	defer_bh(dev, skb, &dev->txq);
 }


Thanks,
-- 
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
