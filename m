From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Subject: Re: [PATCH] usbnet: Fix two races between usbnet_stop() and the BH
Date: Wed, 19 Aug 2015 14:59:01 +0300
Message-ID: <55D46F85.50608@rosalab.ru>
References: <55CE1D7E.2070400@rosalab.ru>
 <1439571516-11862-1-git-send-email-eugene.shatokhin@rosalab.ru>
 <20150818.185407.1667358232705414236.davem@davemloft.net>
 <55D436D5.6010105@rosalab.ru> <87k2sreefu.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, oneukum@suse.com,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87k2sreefu.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

19.08.2015 13:54, Bj=C3=B8rn Mork =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Eugene Shatokhin <eugene.shatokhin@rosalab.ru> writes:
>
>> 19.08.2015 04:54, David Miller =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
>>> Date: Fri, 14 Aug 2015 19:58:36 +0300
>>>
>>>> 2. The second race is on dev->flags.
>>>>
>>>> dev->flags is set to 0 here:
>>>> *0  usbnet_stop (usbnet.c:816)
>>>>       /* deferred work (task, timer, softirq) must also stop.
>>>>        * can't flush_scheduled_work() until we drop rtnl (later),
>>>>        * else workers could deadlock; so make workers a NOP.
>>>>        */
>>>>       dev->flags =3D 0;
>>>>       del_timer_sync (&dev->delay);
>>>>       tasklet_kill (&dev->bh);
>>>>
>>>> And here, the code clears EVENT_RX_KILL bit in dev->flags, which m=
ay
>>>> execute concurrently with the above operation:
>>>> *0 clear_bit (bitops.h:113, inlined)
>>>> *1 usbnet_bh (usbnet.c:1475)
>>>>       /* restart RX again after disabling due to high error rate *=
/
>>>>       clear_bit(EVENT_RX_KILL, &dev->flags);
>>>>
>>>> It seems, setting dev->flags to 0 is not necessarily atomic w.r.t.
>>>> clear_bit() and other bit operations with dev->flags. It is safer =
to
>>>> make it atomic and this way, make the race harmless.
>>>>
>>>> While at it, the checking of EVENT_NO_RUNTIME_PM bit of dev->flags=
 in
>>>> usbnet_stop() was fixed too: the bit should be checked before dev-=
>flags
>>>> is cleared.
>>>
>>> The fix for this is excessive.
>>>
>>> Instead of all of this madness, looping over expensive clear_bit()
>>> atomics, just do whatever it takes to make sure that usbnet_bh() is
>>> quiesced and cannot execute any more.  Then you can safely clear
>>> dev->flags normally.
>>>
>>
>> If I understand it correctly, it is to make sure usbnet_bh() is not
>> scheduled again that dev->flags should be set to 0 first, one way or
>> another. That is what this madness is for.
>
> Assuming there is a race which may reorder these, exactly what
> difference does it make wrt EVENT_RX_KILL if you do
>
> a)  clear_bit(EVENT_RX_KILL, &dev->flags);
>      dev->flags =3D 0;
>
> or
>
> b)  dev->flags =3D 0;
>      clear_bit(EVENT_RX_KILL, &dev->flags);
>
>
> AFAICS, the result will be a cleared EVENT_RX_KILL bit in either case=
=2E
>

Thanks for the review!

The problem is not in the reordering but rather in the fact that=20
"dev->flags =3D 0" is not necessarily atomic w.r.t.=20
"clear_bit(EVENT_RX_KILL, &dev->flags)", and vice versa.

So the following might be possible, although unlikely:

CPU0             CPU1
                  clear_bit: read dev->flags
                  clear_bit: clear EVENT_RX_KILL in the read value

dev->flags=3D0;

                  clear_bit: write updated dev->flags

As a result, dev->flags may become non-zero again.

I cannot prove yet that this is an impossible situation. If anyone can,=
=20
please explain. If so, this part of the patch will not be needed.

>
> The EVENT_NO_RUNTIME_PM bug should definitely be fixed.  Please split
> that out as a separate fix.  It's a separate issue, and should be
> backported to all maintained stable releases it applies to (anything
> from v3.8 and newer)

Yes, that makes sense. However, this fix was originally provided by=20
Oliver Neukum rather than me, so I would like to hear his opinion as=20
well first.
>
>
> Bj=C3=B8rn
>

Regards,
Eugene
