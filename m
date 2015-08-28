From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 2/2] usbnet: Fix a race between usbnet_stop() and the BH
Date: Fri, 28 Aug 2015 10:55:26 +0200
Message-ID: <87mvxbzta9.fsf@nemi.mork.no>
References: <55AD3A41.2040100@rosalab.ru>
	<1440447223-15945-1-git-send-email-eugene.shatokhin@rosalab.ru>
	<1440447223-15945-3-git-send-email-eugene.shatokhin@rosalab.ru>
	<87k2sk9zaf.fsf@nemi.mork.no> <55E01750.4010202@rosalab.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum@suse.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55E01750.4010202@rosalab.ru> (Eugene Shatokhin's message of
	"Fri, 28 Aug 2015 11:09:52 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eugene Shatokhin <eugene.shatokhin@rosalab.ru> writes:

> 25.08.2015 00:01, Bj=C3=B8rn Mork =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> Eugene Shatokhin <eugene.shatokhin@rosalab.ru> writes:
>>
>>> The race may happen when a device (e.g. YOTA 4G LTE Modem) is
>>> unplugged while the system is downloading a large file from the Net=
=2E
>>>
>>> Hardware breakpoints and Kprobes with delays were used to confirm t=
hat
>>> the race does actually happen.
>>>
>>> The race is on skb_queue ('next' pointer) between usbnet_stop()
>>> and rx_complete(), which, in turn, calls usbnet_bh().
>>>
>>> Here is a part of the call stack with the code where the changes to=
 the
>>> queue happen. The line numbers are for the kernel 4.1.0:
>>>
>>> *0 __skb_unlink (skbuff.h:1517)
>>>      prev->next =3D next;
>>> *1 defer_bh (usbnet.c:430)
>>>      spin_lock_irqsave(&list->lock, flags);
>>>      old_state =3D entry->state;
>>>      entry->state =3D state;
>>>      __skb_unlink(skb, list);
>>>      spin_unlock(&list->lock);
>>>      spin_lock(&dev->done.lock);
>>>      __skb_queue_tail(&dev->done, skb);
>>>      if (dev->done.qlen =3D=3D 1)
>>>          tasklet_schedule(&dev->bh);
>>>      spin_unlock_irqrestore(&dev->done.lock, flags);
>>> *2 rx_complete (usbnet.c:640)
>>>      state =3D defer_bh(dev, skb, &dev->rxq, state);
>>>
>>> At the same time, the following code repeatedly checks if the queue=
 is
>>> empty and reads these values concurrently with the above changes:
>>>
>>> *0  usbnet_terminate_urbs (usbnet.c:765)
>>>      /* maybe wait for deletions to finish. */
>>>      while (!skb_queue_empty(&dev->rxq)
>>>          && !skb_queue_empty(&dev->txq)
>>>          && !skb_queue_empty(&dev->done)) {
>>>              schedule_timeout(msecs_to_jiffies(UNLINK_TIMEOUT_MS));
>>>              set_current_state(TASK_UNINTERRUPTIBLE);
>>>              netif_dbg(dev, ifdown, dev->net,
>>>                    "waited for %d urb completions\n", temp);
>>>      }
>>> *1  usbnet_stop (usbnet.c:806)
>>>      if (!(info->flags & FLAG_AVOID_UNLINK_URBS))
>>>          usbnet_terminate_urbs(dev);
>>>
>>> As a result, it is possible, for example, that the skb is removed f=
rom
>>> dev->rxq by __skb_unlink() before the check
>>> "!skb_queue_empty(&dev->rxq)" in usbnet_terminate_urbs() is made. I=
t is
>>> also possible in this case that the skb is added to dev->done queue
>>> after "!skb_queue_empty(&dev->done)" is checked. So
>>> usbnet_terminate_urbs() may stop waiting and return while dev->done
>>> queue still has an item.
>>
>> Exactly what problem will that result in?  The tasklet_kill() will w=
ait
>> for the processing of the single element done queue, and everything =
will
>> be fine.  Or?
>
> Given enough time, what prevents defer_bh() from calling
> tasklet_schedule(&dev->bh) *after* usbnet_stop() calls tasklet_kill()=
?
>
> Consider the following situation (assuming '&&' are changed to '||' i=
n
> that while loop in usbnet_terminate_urbs() as they should be):
>
> CPU0                            CPU1
> usbnet_stop()                   defer_bh() with list =3D=3D dev->rxq
>   usbnet_terminate_urbs()
>                                 __skb_unlink() removes the last
>                                 skb from dev->rxq.
>                                 dev->rxq, dev->txq and dev->done
>                                 are now empty.
>   while (!skb_queue_empty()...)
>     The loop ends because all 3
>     queues are now empty.
>
>   usbnet_terminate_urbs() ends.
>
> usbnet_stop() continues:
>   usbnet_status_stop(dev);
>   ...
>   del_timer_sync (&dev->delay);
>   tasklet_kill (&dev->bh);
>                                 __skb_queue_tail(&dev->done, skb);
>                                 if (dev->done.qlen =3D=3D 1)
>                                   tasklet_schedule(&dev->bh);
>
> The BH is scheduled at this point, which is not what was intended. Th=
e
> race window is small, but still.

I guess you are right.  At least I cannot prove that you are not :)

There is a bit too much complexity involved here for me...



Bj=C3=B8rn
