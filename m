From: Eugene Shatokhin <eugene.shatokhin-irhHPgl+04UvJsYlp49lxw@public.gmane.org>
Subject: Re: [PATCH] usbnet: Fix two races between usbnet_stop() and the BH
Date: Wed, 19 Aug 2015 10:57:09 +0300
Message-ID: <55D436D5.6010105@rosalab.ru>
References: <55CE1D7E.2070400@rosalab.ru>
 <1439571516-11862-1-git-send-email-eugene.shatokhin@rosalab.ru>
 <20150818.185407.1667358232705414236.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: oneukum-IBi9RG/b67k@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150818.185407.1667358232705414236.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

19.08.2015 04:54, David Miller =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> From: Eugene Shatokhin <eugene.shatokhin-irhHPgl+04UvJsYlp49lxw@public.gmane.org>
> Date: Fri, 14 Aug 2015 19:58:36 +0300
>
>> 2. The second race is on dev->flags.
>>
>> dev->flags is set to 0 here:
>> *0  usbnet_stop (usbnet.c:816)
>>      /* deferred work (task, timer, softirq) must also stop.
>>       * can't flush_scheduled_work() until we drop rtnl (later),
>>       * else workers could deadlock; so make workers a NOP.
>>       */
>>      dev->flags =3D 0;
>>      del_timer_sync (&dev->delay);
>>      tasklet_kill (&dev->bh);
>>
>> And here, the code clears EVENT_RX_KILL bit in dev->flags, which may
>> execute concurrently with the above operation:
>> *0 clear_bit (bitops.h:113, inlined)
>> *1 usbnet_bh (usbnet.c:1475)
>>      /* restart RX again after disabling due to high error rate */
>>      clear_bit(EVENT_RX_KILL, &dev->flags);
>>
>> It seems, setting dev->flags to 0 is not necessarily atomic w.r.t.
>> clear_bit() and other bit operations with dev->flags. It is safer to
>> make it atomic and this way, make the race harmless.
>>
>> While at it, the checking of EVENT_NO_RUNTIME_PM bit of dev->flags i=
n
>> usbnet_stop() was fixed too: the bit should be checked before dev->f=
lags
>> is cleared.
>
> The fix for this is excessive.
>
> Instead of all of this madness, looping over expensive clear_bit()
> atomics, just do whatever it takes to make sure that usbnet_bh() is
> quiesced and cannot execute any more.  Then you can safely clear
> dev->flags normally.
>

If I understand it correctly, it is to make sure usbnet_bh() is not=20
scheduled again that dev->flags should be set to 0 first, one way or=20
another. That is what this madness is for.

tasklet_kill() will wait then for the already running instance of=20
usbnet_bh() (if one is running). After that, it is guaranteed BH is not=
=20
running and will not be re-scheduled.

As for the performance concerns, I doubt that usbnet_stop() is anywhere=
=20
on the critical path. I have been testing this patch for some time and=20
haven't seen any new performance issues with it yet.

If needed, it is possible to measure and compare the time needed for=20
usbnet_stop() before and after this patch and try to estimate the impac=
t=20
of this on the overall performance.

Regards,
Eugene

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
