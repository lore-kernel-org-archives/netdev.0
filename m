From: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Subject: Re: [PATCH] usbnet: Fix two races between usbnet_stop() and the BH
Date: Mon, 24 Aug 2015 15:20:44 +0300
Message-ID: <55DB0C1C.5030607@rosalab.ru>
References: <55CE1D7E.2070400@rosalab.ru>
 <1439571516-11862-1-git-send-email-eugene.shatokhin@rosalab.ru>
 <20150818.185407.1667358232705414236.davem@davemloft.net>
 <55D436D5.6010105@rosalab.ru> <87k2sreefu.fsf@nemi.mork.no>
 <55D46F85.50608@rosalab.ru> <877fore9yn.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, oneukum@suse.com,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <877fore9yn.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

19.08.2015 15:31, Bj=C3=B8rn Mork =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Eugene Shatokhin <eugene.shatokhin@rosalab.ru> writes:
>
>> The problem is not in the reordering but rather in the fact that
>> "dev->flags =3D 0" is not necessarily atomic
>> w.r.t. "clear_bit(EVENT_RX_KILL, &dev->flags)", and vice versa.
>>
>> So the following might be possible, although unlikely:
>>
>> CPU0             CPU1
>>                   clear_bit: read dev->flags
>>                   clear_bit: clear EVENT_RX_KILL in the read value
>>
>> dev->flags=3D0;
>>
>>                   clear_bit: write updated dev->flags
>>
>> As a result, dev->flags may become non-zero again.
>
> Ah, right.  Thanks for explaining.
>
>> I cannot prove yet that this is an impossible situation. If anyone
>> can, please explain. If so, this part of the patch will not be neede=
d.
>
> I wonder if we could simply move the dev->flags =3D 0 down a few line=
s to
> fix both issues?  It doesn't seem to do anything useful except for
> resetting the flags to a sane initial state after the device is down.
>
> Stopping the tasklet rescheduling etc depends only on netif_running()=
,
> which will be false when usbnet_stop is called.  There is no need to
> touch dev->flags for this to happen.

That was one of the first ideas we discussed here. Unfortunately, it is=
=20
probably not so simple.

Setting dev->flags to 0 makes some delayed operations do nothing and,=20
among other things, not to reschedule usbnet_bh().

As you can see in drivers/net/usb/usbnet.c, usbnet_bh() can be called a=
s=20
a tasklet function and as a timer function in a number of situations=20
(look for the usage of dev->bh and dev->delay there).

netif_running() is indeed false when usbnet_stop() runs, usbnet_stop()=20
also disables Tx. This seems to be enough for many cases where=20
usbnet_bh() is scheduled, but I am not so sure about the remaining ones=
,=20
namely:

1. A work function, usbnet_deferred_kevent(), may reschedule=20
usbnet_bh(). Looks like the workqueue is only stopped in=20
usbnet_disconnect(), so a work item might be processed while=20
usbnet_stop() works. Setting dev->flags to 0 makes the work function do=
=20
nothing, by the way. See also the comment in usbnet_stop() about this.

A work item may be placed to this workqueue in a number of ways, by bot=
h=20
usbnet module and the mini-drivers. It is not too easy to track all=20
these situations.

2. rx_complete() and tx_complete() may schedule execution of usbnet_bh(=
)=20
as a tasklet or a timer function. These two are URB completion callback=
s.

It seems, new Rx and Tx URBs cannot be submitted when usbnet_stop()=20
clears dev->flags, indeed. But it does not prevent the completion=20
handlers for the previously submitted URBs from running concurrently=20
with usbnet_stop(). The latter waits for them to complete (via=20
usbnet_terminate_urbs(dev)) but only if FLAG_AVOID_UNLINK_URBS is not=20
set in info->flags. rndis_wlan, however, sets this flag for a few=20
hardware models. So - no guarantees here as well.

If someone could list the particular bits of dev->flags that should be=20
cleared to make sure no deferred call could reschedule usbnet_bh(),=20
etc... Well, it would be enough to clear these first and use dev->flags=
=20
=3D 0 later, after tasklet_kill() and del_timer_sync(). I cannot point =
out=20
these particular bits now.

Besides, it is possible, although unlikely, that new event bits will be=
=20
added to dev->flags in the future. And one will need to keep track of=20
these to see if they should be cleared as well. I'd prever to play safe=
r=20
for now and clear them all.

>
>>> The EVENT_NO_RUNTIME_PM bug should definitely be fixed.  Please spl=
it
>>> that out as a separate fix.  It's a separate issue, and should be
>>> backported to all maintained stable releases it applies to (anythin=
g
>>> from v3.8 and newer)
>>
>> Yes, that makes sense. However, this fix was originally provided by
>> Oliver Neukum rather than me, so I would like to hear his opinion as
>> well first.
>
> If what I write above is correct (please help me verify...), then may=
be
> it does make sense to do these together anyway.

I think, your suggestion to make it a separate patch is right. Will do=20
it in the next version of the patchset, hopefully soon.

Regards,
Eugene
