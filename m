From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Subject: Re: [PATCH 2/2] usbnet: Fix a race between usbnet_stop() and the BH
Date: Fri, 28 Aug 2015 13:42:48 +0300
Message-ID: <55E03B28.6050305@rosalab.ru>
References: <55AD3A41.2040100@rosalab.ru>
 <1440447223-15945-1-git-send-email-eugene.shatokhin@rosalab.ru>
 <1440447223-15945-3-git-send-email-eugene.shatokhin@rosalab.ru>
 <87k2sk9zaf.fsf@nemi.mork.no> <55E01750.4010202@rosalab.ru>
 <87mvxbzta9.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum@suse.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from collab.rosalab.ru ([195.19.76.181]:52417 "EHLO
	collab.rosalab.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbbH1Kmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 06:42:51 -0400
In-Reply-To: <87mvxbzta9.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

28.08.2015 11:55, Bj=C3=B8rn Mork =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Eugene Shatokhin <eugene.shatokhin@rosalab.ru> writes:
>
>> 25.08.2015 00:01, Bj=C3=B8rn Mork =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> Eugene Shatokhin <eugene.shatokhin@rosalab.ru> writes:
>>>
>>>> The race may happen when a device (e.g. YOTA 4G LTE Modem) is
>>>> unplugged while the system is downloading a large file from the Ne=
t.
>>>>
>>>> Hardware breakpoints and Kprobes with delays were used to confirm =
that
>>>> the race does actually happen.
>>>>
>>>> The race is on skb_queue ('next' pointer) between usbnet_stop()
>>>> and rx_complete(), which, in turn, calls usbnet_bh().
>>>>
>>>> Here is a part of the call stack with the code where the changes t=
o the
>>>> queue happen. The line numbers are for the kernel 4.1.0:
>>>>
>>>> *0 __skb_unlink (skbuff.h:1517)
>>>>       prev->next =3D next;
>>>> *1 defer_bh (usbnet.c:430)
>>>>       spin_lock_irqsave(&list->lock, flags);
>>>>       old_state =3D entry->state;
>>>>       entry->state =3D state;
>>>>       __skb_unlink(skb, list);
>>>>       spin_unlock(&list->lock);
>>>>       spin_lock(&dev->done.lock);
>>>>       __skb_queue_tail(&dev->done, skb);
>>>>       if (dev->done.qlen =3D=3D 1)
>>>>           tasklet_schedule(&dev->bh);
>>>>       spin_unlock_irqrestore(&dev->done.lock, flags);
>>>> *2 rx_complete (usbnet.c:640)
>>>>       state =3D defer_bh(dev, skb, &dev->rxq, state);
>>>>
>>>> At the same time, the following code repeatedly checks if the queu=
e is
>>>> empty and reads these values concurrently with the above changes:
>>>>
>>>> *0  usbnet_terminate_urbs (usbnet.c:765)
>>>>       /* maybe wait for deletions to finish. */
>>>>       while (!skb_queue_empty(&dev->rxq)
>>>>           && !skb_queue_empty(&dev->txq)
>>>>           && !skb_queue_empty(&dev->done)) {
>>>>               schedule_timeout(msecs_to_jiffies(UNLINK_TIMEOUT_MS)=
);
>>>>               set_current_state(TASK_UNINTERRUPTIBLE);
>>>>               netif_dbg(dev, ifdown, dev->net,
>>>>                     "waited for %d urb completions\n", temp);
>>>>       }
>>>> *1  usbnet_stop (usbnet.c:806)
>>>>       if (!(info->flags & FLAG_AVOID_UNLINK_URBS))
>>>>           usbnet_terminate_urbs(dev);
>>>>
>>>> As a result, it is possible, for example, that the skb is removed =
from
>>>> dev->rxq by __skb_unlink() before the check
>>>> "!skb_queue_empty(&dev->rxq)" in usbnet_terminate_urbs() is made. =
It is
>>>> also possible in this case that the skb is added to dev->done queu=
e
>>>> after "!skb_queue_empty(&dev->done)" is checked. So
>>>> usbnet_terminate_urbs() may stop waiting and return while dev->don=
e
>>>> queue still has an item.
>>>
>>> Exactly what problem will that result in?  The tasklet_kill() will =
wait
>>> for the processing of the single element done queue, and everything=
 will
>>> be fine.  Or?
>>
>> Given enough time, what prevents defer_bh() from calling
>> tasklet_schedule(&dev->bh) *after* usbnet_stop() calls tasklet_kill(=
)?
>>
>> Consider the following situation (assuming '&&' are changed to '||' =
in
>> that while loop in usbnet_terminate_urbs() as they should be):
>>
>> CPU0                            CPU1
>> usbnet_stop()                   defer_bh() with list =3D=3D dev->rxq
>>    usbnet_terminate_urbs()
>>                                  __skb_unlink() removes the last
>>                                  skb from dev->rxq.
>>                                  dev->rxq, dev->txq and dev->done
>>                                  are now empty.
>>    while (!skb_queue_empty()...)
>>      The loop ends because all 3
>>      queues are now empty.
>>
>>    usbnet_terminate_urbs() ends.
>>
>> usbnet_stop() continues:
>>    usbnet_status_stop(dev);
>>    ...
>>    del_timer_sync (&dev->delay);
>>    tasklet_kill (&dev->bh);
>>                                  __skb_queue_tail(&dev->done, skb);
>>                                  if (dev->done.qlen =3D=3D 1)
>>                                    tasklet_schedule(&dev->bh);
>>
>> The BH is scheduled at this point, which is not what was intended. T=
he
>> race window is small, but still.
>
> I guess you are right.  At least I cannot prove that you are not :)
>
> There is a bit too much complexity involved here for me...

:-)

Yes, it is quite complex.

I admit, it was easier for me to find the races in usbnet (the tools=20
like KernelStrider and RaceHound do the dirty work) than to analyze=20
their consequences. The latter often requires some time and effort, and=
=20
so it did this time.

Well, any objections to this patch?

Regards,

Eugene
