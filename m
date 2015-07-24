From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Subject: Re: Several races in "usbnet" module (kernel 4.1.x)
Date: Fri, 24 Jul 2015 17:41:58 +0300
Message-ID: <55B24EB6.5090907@rosalab.ru>
References: <55AD3A41.2040100@rosalab.ru> <1437488529.3823.16.camel@suse.com>
 <55AFE210.7030104@rosalab.ru> <1437642952.4377.10.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437642952.4377.10.camel@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

23.07.2015 12:15, Oliver Neukum =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Wed, 2015-07-22 at 21:33 +0300, Eugene Shatokhin wrote:
>> The following part is not necessary, I think. usbnet_bh() does not
>> touch
>> EVENT_NO_RUNTIME_PM bit explicitly and these bit operations are
>> atomic
>> w.r.t. each other.
>>
>>> +     mpn |=3D !test_and_clear_bit(EVENT_NO_RUNTIME_PM, &dev->flags=
);
>>> +     /* in case the bh reset a flag */
>
> Yes, they are atomic w.r.t. each other. And that limitation worries m=
e.
>
> I am considering architectures which do atomic operations with
> spinlocks. And this code mixes another operation into it. Can
> this happen?
>
> CPU A				CPU B
>
> take lock
> read old value
> 				set value to 0
> clear bit
> write back changed value
> release lock

 From what I see now in Documentation/atomic_ops.txt, stores to the=20
properly aligned memory locations are in fact atomic.

So, I think, the situation you described above cannot happen for=20
dev->flags, which is good. No need to address that in the patch. The=20
race might be harmless after all.

If I understand the code correctly now, dev->flags is set to 0 in=20
usbnet_stop() so that the worker function (usbnet_deferred_kevent) woul=
d=20
do nothing, should it start later. If so, how about adding memory=20
barriers for all CPUs to see dev->flags is 0 before other things?

The patch could look like this then:

--------------------
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 3c86b10..d87b9c7 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -778,7 +778,7 @@ int usbnet_stop (struct net_device *net)
  {
  	struct usbnet		*dev =3D netdev_priv(net);
  	struct driver_info	*info =3D dev->driver_info;
-	int			retval, pm;
+	int			retval, pm, mpn;

  	clear_bit(EVENT_DEV_OPEN, &dev->flags);
  	netif_stop_queue (net);
@@ -813,14 +813,17 @@ int usbnet_stop (struct net_device *net)
  	 * can't flush_scheduled_work() until we drop rtnl (later),
  	 * else workers could deadlock; so make workers a NOP.
  	 */
+	mpn =3D !test_and_clear_bit(EVENT_NO_RUNTIME_PM, &dev->flags);
  	dev->flags =3D 0;
+	smp_mb(); /* make sure the workers see that dev->flags =3D=3D 0 */
+
  	del_timer_sync (&dev->delay);
  	tasklet_kill (&dev->bh);
+
  	if (!pm)
  		usb_autopm_put_interface(dev->intf);

-	if (info->manage_power &&
-	    !test_and_clear_bit(EVENT_NO_RUNTIME_PM, &dev->flags))
+	if (info->manage_power && mpn)
  		info->manage_power(dev, 0);
  	else
  		usb_autopm_put_interface(dev->intf);
@@ -1078,6 +1081,9 @@ usbnet_deferred_kevent (struct work_struct *work)
  		container_of(work, struct usbnet, kevent);
  	int			status;

+	/* See the changes in dev->flags from other CPUs. */
+	smp_mb();
+
  	/* usb_clear_halt() needs a thread context */
  	if (test_bit (EVENT_TX_HALT, &dev->flags)) {
  		unlink_urbs (dev, &dev->txq);
--------------------

What do you think?

Regards,
Eugene
