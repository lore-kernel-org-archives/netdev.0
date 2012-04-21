From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: use-after-free in usbnet
Date: Sat, 21 Apr 2012 15:45:48 +0800
Message-ID: <CACVXFVNc_S8pTaBqMzQZx6Dt-tSP_9iXepxJzv=iR9BFu=Tj8g@mail.gmail.com>
References: <CACVXFVP+U1k7JFTmbabF-k8F3bO9zc58c3tLG6=1nQPcrR9p1g@mail.gmail.com>
	<Pine.LNX.4.44L0.1203211201560.1369-100000@iolanthe.rowland.org>
	<CACVXFVOVjnWjqpKxbU98DAyUC_OSb8ZL-3WcyYuFXgPJn5UyuA@mail.gmail.com>
	<201203221008.46882.oneukum@suse.de>
	<CACVXFVODFvtF1DRyWJmnYCByw7sr9QDv_+Taxo5maVaUauDNtg@mail.gmail.com>
	<CA+v9cxawVwKakF6c_RpAw2XUGWcbqd8M+ZJqyq76Au9rmNosmQ@mail.gmail.com>
	<CACVXFVM5YBJkDZddeGi1_MPY7EqEV_wtoFy-NtBHYA6rxez0jg@mail.gmail.com>
	<CA+v9cxZWtGbz6uCSysVbAc1hT27rCiuJXzcvSiTxH-zuQYnrZw@mail.gmail.com>
	<CACVXFVOc0XZ+eLHGiVwKuiUResRk8Cj9MS4EPMx7k57a0tEJhA@mail.gmail.com>
	<CA+v9cxZZpL5soSga=MX_bD45KNve-Lnr2Qb6+gr7Mv6Txyh-fA@mail.gmail.com>
	<CACVXFVN6kvXk7s4Sc0d_-yKSM=rV3qcuPPBHVZYzoQjnwkGX+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Fedora Kernel Team <kernel-team-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>
To: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVN6kvXk7s4Sc0d_-yKSM=rV3qcuPPBHVZYzoQjnwkGX+Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Huajun,

On Sat, Apr 21, 2012 at 3:06 PM, Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> Just skip trying this per your following email's comments.
>
> I will prepare a new patch later, if you'd like to try it.

The below patch reverts the below commits:

       0956a8c20b23d429e79ff86d4325583fc06f9eb4
      (usbnet: increase URB reference count before usb_unlink_urb)

      4231d47e6fe69f061f96c98c30eaf9fb4c14b96d
      (net/usbnet: avoid recursive locking in usbnet_stop())

and keep holding tx/rx queue lock during unlinking, but avoid
to acquire the same queue lock inside complete handler triggered by
usb_unlink_urb.

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index db99536..effb34e 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -291,9 +291,11 @@ static void defer_bh(struct usbnet *dev, struct
sk_buff *skb, struct sk_buff_hea
 {
 	unsigned long		flags;

-	spin_lock_irqsave(&list->lock, flags);
+	if (!test_cpu_bit(URB_UNLINKING, dev->cpuflags))
+		spin_lock_irqsave(&list->lock, flags);
 	__skb_unlink(skb, list);
-	spin_unlock(&list->lock);
+	if (!test_cpu_bit(URB_UNLINKING, dev->cpuflags))
+		spin_unlock(&list->lock);
 	spin_lock(&dev->done.lock);
 	__skb_queue_tail(&dev->done, skb);
 	if (dev->done.qlen == 1)
@@ -345,7 +347,8 @@ static int rx_submit (struct usbnet *dev, struct
urb *urb, gfp_t flags)
 	usb_fill_bulk_urb (urb, dev->udev, dev->in,
 		skb->data, size, rx_complete, skb);

-	spin_lock_irqsave (&dev->rxq.lock, lockflags);
+	if (!test_cpu_bit(URB_UNLINKING, dev->cpuflags))
+		spin_lock_irqsave (&dev->rxq.lock, lockflags);

 	if (netif_running (dev->net) &&
 	    netif_device_present (dev->net) &&
@@ -377,7 +380,8 @@ static int rx_submit (struct usbnet *dev, struct
urb *urb, gfp_t flags)
 		netif_dbg(dev, ifdown, dev->net, "rx: stopped\n");
 		retval = -ENOLINK;
 	}
-	spin_unlock_irqrestore (&dev->rxq.lock, lockflags);
+	if (!test_cpu_bit(URB_UNLINKING, dev->cpuflags))
+		spin_unlock_irqrestore (&dev->rxq.lock, lockflags);
 	if (retval) {
 		dev_kfree_skb_any (skb);
 		usb_free_urb (urb);
@@ -582,6 +586,7 @@ static int unlink_urbs (struct usbnet *dev, struct
sk_buff_head *q)
 	int			count = 0;

 	spin_lock_irqsave (&q->lock, flags);
+	set_cpu_bit(URB_UNLINKING, dev->cpuflags);
 	skb_queue_walk_safe(q, skb, skbnext) {
 		struct skb_data		*entry;
 		struct urb		*urb;
@@ -590,15 +595,6 @@ static int unlink_urbs (struct usbnet *dev,
struct sk_buff_head *q)
 		entry = (struct skb_data *) skb->cb;
 		urb = entry->urb;

-		/*
-		 * Get reference count of the URB to avoid it to be
-		 * freed during usb_unlink_urb, which may trigger
-		 * use-after-free problem inside usb_unlink_urb since
-		 * usb_unlink_urb is always racing with .complete
-		 * handler(include defer_bh).
-		 */
-		usb_get_urb(urb);
-		spin_unlock_irqrestore(&q->lock, flags);
 		// during some PM-driven resume scenarios,
 		// these (async) unlinks complete immediately
 		retval = usb_unlink_urb (urb);
@@ -606,9 +602,8 @@ static int unlink_urbs (struct usbnet *dev, struct
sk_buff_head *q)
 			netdev_dbg(dev->net, "unlink urb err, %d\n", retval);
 		else
 			count++;
-		usb_put_urb(urb);
-		spin_lock_irqsave(&q->lock, flags);
 	}
+	clear_cpu_bit(URB_UNLINKING, dev->cpuflags);
 	spin_unlock_irqrestore (&q->lock, flags);
 	return count;
 }
@@ -1283,6 +1278,7 @@ void usbnet_disconnect (struct usb_interface *intf)
 	usb_kill_urb(dev->interrupt);
 	usb_free_urb(dev->interrupt);

+	free_percpu(dev->cpuflags);
 	free_netdev(net);
 	usb_put_dev (xdev);
 }
@@ -1353,6 +1349,13 @@ usbnet_probe (struct usb_interface *udev, const
struct usb_device_id *prod)
 	SET_NETDEV_DEV(net, &udev->dev);

 	dev = netdev_priv(net);
+
+	dev->cpuflags = alloc_percpu(unsigned long);
+	if (!dev->cpuflags) {
+		status = -ENOMEM;
+		goto out1;
+	}
+
 	dev->udev = xdev;
 	dev->intf = udev;
 	dev->driver_info = info;
@@ -1396,7 +1399,7 @@ usbnet_probe (struct usb_interface *udev, const
struct usb_device_id *prod)
 	if (info->bind) {
 		status = info->bind (dev, udev);
 		if (status < 0)
-			goto out1;
+			goto out2;

 		// heuristic:  "usb%d" for links we know are two-host,
 		// else "eth%d" when there's reasonable doubt.  userspace
@@ -1465,6 +1468,8 @@ usbnet_probe (struct usb_interface *udev, const
struct usb_device_id *prod)
 out3:
 	if (info->unbind)
 		info->unbind (dev, udev);
+out2:
+	free_percpu(dev->cpuflags);
 out1:
 	free_netdev(net);
 out:
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 605b0aa..2dc46f5 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -69,8 +69,28 @@ struct usbnet {
 #		define EVENT_DEV_WAKING 6
 #		define EVENT_DEV_ASLEEP 7
 #		define EVENT_DEV_OPEN	8
+	unsigned long __percpu *cpuflags;
+#		define URB_UNLINKING	0
 };

+static inline void set_cpu_bit(int nr, unsigned long __percpu *addr)
+{
+	unsigned long *fl = __this_cpu_ptr(addr);
+	set_bit(nr, fl);
+}
+
+static inline void clear_cpu_bit(int nr, unsigned long __percpu *addr)
+{
+	unsigned long *fl = __this_cpu_ptr(addr);
+	clear_bit(nr, fl);
+}
+
+static inline int test_cpu_bit(int nr, unsigned long __percpu *addr)
+{
+	unsigned long *fl = __this_cpu_ptr(addr);
+	return test_bit(nr, fl);
+}
+
 static inline struct usb_driver *driver_of(struct usb_interface *intf)
 {
 	return to_usb_driver(intf->dev.driver);


Thanks,
-- 
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
