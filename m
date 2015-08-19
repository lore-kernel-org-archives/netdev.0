From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] usbnet: Fix two races between usbnet_stop() and the BH
Date: Wed, 19 Aug 2015 12:54:29 +0200
Message-ID: <87k2sreefu.fsf@nemi.mork.no>
References: <55CE1D7E.2070400@rosalab.ru>
	<1439571516-11862-1-git-send-email-eugene.shatokhin@rosalab.ru>
	<20150818.185407.1667358232705414236.davem@davemloft.net>
	<55D436D5.6010105@rosalab.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, oneukum@suse.com,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55D436D5.6010105@rosalab.ru> (Eugene Shatokhin's message of
	"Wed, 19 Aug 2015 10:57:09 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eugene Shatokhin <eugene.shatokhin@rosalab.ru> writes:

> 19.08.2015 04:54, David Miller =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
>> Date: Fri, 14 Aug 2015 19:58:36 +0300
>>
>>> 2. The second race is on dev->flags.
>>>
>>> dev->flags is set to 0 here:
>>> *0  usbnet_stop (usbnet.c:816)
>>>      /* deferred work (task, timer, softirq) must also stop.
>>>       * can't flush_scheduled_work() until we drop rtnl (later),
>>>       * else workers could deadlock; so make workers a NOP.
>>>       */
>>>      dev->flags =3D 0;
>>>      del_timer_sync (&dev->delay);
>>>      tasklet_kill (&dev->bh);
>>>
>>> And here, the code clears EVENT_RX_KILL bit in dev->flags, which ma=
y
>>> execute concurrently with the above operation:
>>> *0 clear_bit (bitops.h:113, inlined)
>>> *1 usbnet_bh (usbnet.c:1475)
>>>      /* restart RX again after disabling due to high error rate */
>>>      clear_bit(EVENT_RX_KILL, &dev->flags);
>>>
>>> It seems, setting dev->flags to 0 is not necessarily atomic w.r.t.
>>> clear_bit() and other bit operations with dev->flags. It is safer t=
o
>>> make it atomic and this way, make the race harmless.
>>>
>>> While at it, the checking of EVENT_NO_RUNTIME_PM bit of dev->flags =
in
>>> usbnet_stop() was fixed too: the bit should be checked before dev->=
flags
>>> is cleared.
>>
>> The fix for this is excessive.
>>
>> Instead of all of this madness, looping over expensive clear_bit()
>> atomics, just do whatever it takes to make sure that usbnet_bh() is
>> quiesced and cannot execute any more.  Then you can safely clear
>> dev->flags normally.
>>
>
> If I understand it correctly, it is to make sure usbnet_bh() is not
> scheduled again that dev->flags should be set to 0 first, one way or
> another. That is what this madness is for.

Assuming there is a race which may reorder these, exactly what
difference does it make wrt EVENT_RX_KILL if you do

a)  clear_bit(EVENT_RX_KILL, &dev->flags);
    dev->flags =3D 0;

or

b)  dev->flags =3D 0;
    clear_bit(EVENT_RX_KILL, &dev->flags);


AFAICS, the result will be a cleared EVENT_RX_KILL bit in either case.


The EVENT_NO_RUNTIME_PM bug should definitely be fixed.  Please split
that out as a separate fix.  It's a separate issue, and should be
backported to all maintained stable releases it applies to (anything
from v3.8 and newer)


Bj=C3=B8rn
