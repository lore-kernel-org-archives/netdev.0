From: Eugene Shatokhin <eugene.shatokhin-irhHPgl+04UvJsYlp49lxw@public.gmane.org>
Subject: Re: Several races in "usbnet" module (kernel 4.1.x)
Date: Fri, 24 Jul 2015 20:38:13 +0300
Message-ID: <55B27805.90601@rosalab.ru>
References: <55AD3A41.2040100@rosalab.ru> <1437480243.3823.5.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1437480243.3823.5.camel-IBi9RG/b67k@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

21.07.2015 15:04, Oliver Neukum =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Mon, 2015-07-20 at 21:13 +0300, Eugene Shatokhin wrote:
>> Hi,
>>
>> I have recently found several data races in "usbnet" module, checked=
 on
>> vanilla kernel 4.1.0 on x86_64. The races do actually happen, I have
>> confirmed it by adding delays and using hardware breakpoints to dete=
ct
>> the conflicting memory accesses (with RaceHound tool,
>> https://github.com/winnukem/racehound).
>>
>> I have not analyzed yet how harmful these races are (if they are), b=
ut
>> it is better to report them anyway, I think.
>>
>> Everything was checked using YOTA 4G LTE Modem that works via "usbne=
t"
>> and "cdc_ether" kernel modules.
>> --------------------------
>>
>> [Race #1]
>>
>> Race on skb_queue ('next' pointer) between usbnet_stop() and rx_comp=
lete().
>>
>> Reproduced that by unplugging the device while the system was
>> downloading a large file from the Net.
>>
>> Here is part of the call stack with the code where the changes to th=
e
>> queue happen:
>>
>> #0 __skb_unlink (skbuff.h:1517)=09
>> 	prev->next =3D next;
>> #1 defer_bh (usbnet.c:430)
>> 	spin_lock_irqsave(&list->lock, flags);
>> 	old_state =3D entry->state;
>> 	entry->state =3D state;
>> 	__skb_unlink(skb, list);
>> 	spin_unlock(&list->lock);
>> 	spin_lock(&dev->done.lock);
>> 	__skb_queue_tail(&dev->done, skb);
>> 	if (dev->done.qlen =3D=3D 1)
>> 		tasklet_schedule(&dev->bh);
>> 	spin_unlock_irqrestore(&dev->done.lock, flags);
>> #2 rx_complete (usbnet.c:640)
>> 	state =3D defer_bh(dev, skb, &dev->rxq, state);
>>
>> At the same time, the following code repeatedly checks if the queue =
is
>> empty and reads the same values concurrently with the above changes:
>>
>> #0  usbnet_terminate_urbs (usbnet.c:765)
>> 	/* maybe wait for deletions to finish. */
>> 	while (!skb_queue_empty(&dev->rxq)
>> 		&& !skb_queue_empty(&dev->txq)
>> 		&& !skb_queue_empty(&dev->done)) {
>> 			schedule_timeout(msecs_to_jiffies(UNLINK_TIMEOUT_MS));
>> 			set_current_state(TASK_UNINTERRUPTIBLE);
>> 			netif_dbg(dev, ifdown, dev->net,
>> 				  "waited for %d urb completions\n", temp);
>> 	}
>> #1  usbnet_stop (usbnet.c:806)
>> 	if (!(info->flags & FLAG_AVOID_UNLINK_URBS))
>> 		usbnet_terminate_urbs(dev);
>>
>> For example, it is possible that the skb is removed from dev->rxq by
>> __skb_unlink() before the check "!skb_queue_empty(&dev->rxq)" in
>> usbnet_terminate_urbs() is made. It is also possible in this case th=
at
>> the skb is added to dev->done queue after "!skb_queue_empty(&dev->do=
ne)"
>> is checked. So usbnet_terminate_urbs() may stop waiting and return w=
hile
>> dev->done queue still has an item.
>
> Hi,
>
> your analysis is correct and it looks like in addition to your propos=
ed
> fix locking needs to be simplified and a common lock to be taken.
> Suggestions?

Just an idea, I haven't tested it.

How about moving the operations with dev->done under &list->lock in=20
defer_bh, while keeping dev->done.lock too and changing=20
usbnet_terminate_urbs() as described below?

Like this:
@@ -428,12 +428,12 @@ static enum skb_state defer_bh(struct usbnet *dev=
,=20
struct sk_buff *skb,
  	old_state =3D entry->state;
  	entry->state =3D state;
  	__skb_unlink(skb, list);
-	spin_unlock(&list->lock);
  	spin_lock(&dev->done.lock);
  	__skb_queue_tail(&dev->done, skb);
  	if (dev->done.qlen =3D=3D 1)
  		tasklet_schedule(&dev->bh);
-	spin_unlock_irqrestore(&dev->done.lock, flags);
+	spin_unlock(&dev->done.lock);
+	spin_unlock_irqrestore(&list->lock, flags);
  	return old_state;
  }
-------------------

usbnet_terminate_urbs() can then be changed as follows:

@@ -749,6 +749,20 @@ EXPORT_SYMBOL_GPL(usbnet_unlink_rx_urbs);

=20
/*---------------------------------------------------------------------=
----*/

+static void wait_skb_queue_empty(struct sk_buff_head *q)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&q->lock, flags);
+	while (!skb_queue_empty(q)) {
+		spin_unlock_irqrestore(&q->lock, flags);
+		schedule_timeout(msecs_to_jiffies(UNLINK_TIMEOUT_MS));
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		spin_lock_irqsave(&q->lock, flags);
+	}
+	spin_unlock_irqrestore(&q->lock, flags);
+}
+
  // precondition: never called in_interrupt
  static void usbnet_terminate_urbs(struct usbnet *dev)
  {
@@ -762,14 +776,11 @@ static void usbnet_terminate_urbs(struct usbnet *=
dev)
  		unlink_urbs(dev, &dev->rxq);

  	/* maybe wait for deletions to finish. */
-	while (!skb_queue_empty(&dev->rxq)
-		&& !skb_queue_empty(&dev->txq)
-		&& !skb_queue_empty(&dev->done)) {
-			schedule_timeout(msecs_to_jiffies(UNLINK_TIMEOUT_MS));
-			set_current_state(TASK_UNINTERRUPTIBLE);
-			netif_dbg(dev, ifdown, dev->net,
-				  "waited for %d urb completions\n", temp);
-	}
+	wait_skb_queue_empty(&dev->rxq);
+	wait_skb_queue_empty(&dev->txq);
+	wait_skb_queue_empty(&dev->done);
+	netif_dbg(dev, ifdown, dev->net,
+		  "waited for %d urb completions\n", temp);
  	set_current_state(TASK_RUNNING);
  	remove_wait_queue(&dev->wait, &wait);
  }
-------------------

This way, when usbnet_terminate_urbs() finds dev->rxq or dev->txq empty=
,=20
the skbs from these queues, if there were any, have already been queued=
=20
to dev->done.

At the first glance, moving the code under list->lock in defer_bh()=20
should not produce deadlocks. Still, I suppose, it is better to use=20
lockdep to be sure.

Regards,
Eugene

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
