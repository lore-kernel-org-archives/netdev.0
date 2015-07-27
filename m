From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Subject: Re: Several races in "usbnet" module (kernel 4.1.x)
Date: Mon, 27 Jul 2015 17:23:53 +0300
Message-ID: <55B63EF9.6090800@rosalab.ru>
References: <55AD3A41.2040100@rosalab.ru> <1437488529.3823.16.camel@suse.com>
 <55AFE210.7030104@rosalab.ru> <1437642952.4377.10.camel@suse.com>
 <55B24EB6.5090907@rosalab.ru> <1437991239.32457.9.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437991239.32457.9.camel@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

27.07.2015 13:00, Oliver Neukum =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Fri, 2015-07-24 at 17:41 +0300, Eugene Shatokhin wrote:
>> 23.07.2015 12:15, Oliver Neukum =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>
>>   From what I see now in Documentation/atomic_ops.txt, stores to the
>> properly aligned memory locations are in fact atomic.
>
> They are, but again only with respect to each other.

You are right. The architectures like "sparc" and may be others, indeed=
,=20
use spinlocks to implement atomic operations, including bit manupulatio=
n.

Well then, I can only think about clearing each flag individually (with=
=20
clear_bit()) instead of using "dev->flags =3D 0".

Something like this:

-----------------
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 3c86b10..826eefe 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -779,6 +790,7 @@ int usbnet_stop (struct net_device *net)
         struct usbnet           *dev =3D netdev_priv(net);
         struct driver_info      *info =3D dev->driver_info;
         int                     retval, pm;
+       int                     e;

         clear_bit(EVENT_DEV_OPEN, &dev->flags);
         netif_stop_queue (net);
@@ -813,7 +825,8 @@ int usbnet_stop (struct net_device *net)
          * can't flush_scheduled_work() until we drop rtnl (later),
          * else workers could deadlock; so make workers a NOP.
          */
-       dev->flags =3D 0;
+       for (e =3D 0; e < EVENT_NUM_EVENTS; ++e)
+               clear_bit(e, &dev->flags)
         del_timer_sync (&dev->delay);
         tasklet_kill (&dev->bh);
         if (!pm)

diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 6e0ce8c..7ad62da 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -79,6 +79,7 @@ struct usbnet {
# define EVENT_RX_KILL 10
# define EVENT_LINK_CHANGE 11
# define EVENT_SET_RX_MODE 12
+# define EVENT_NUM_EVENTS 13 /* Or may be keep all these in an enum? *=
/
};

static inline struct usb_driver *driver_of(struct usb_interface *intf)
-------------------

clear_bit() is atomic w.r.t. itself and other bit ops.
>
>> So, I think, the situation you described above cannot happen for
>> dev->flags, which is good. No need to address that in the patch. The
>> race might be harmless after all.
>>
>> If I understand the code correctly now, dev->flags is set to 0 in
>> usbnet_stop() so that the worker function (usbnet_deferred_kevent) w=
ould
>
> Yes, particularly not reschedule itself.
>
>> do nothing, should it start later. If so, how about adding memory
>> barriers for all CPUs to see dev->flags is 0 before other things?
>
> Taking a lock, as del_timer_sync() does, implies a memory barrier,
> as does a work.

If so, then, yes, additional barriers are not needed.

Regards,
Eugene
