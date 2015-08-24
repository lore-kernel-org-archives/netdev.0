From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] usbnet: Fix two races between usbnet_stop() and the BH
Date: Mon, 24 Aug 2015 15:29:47 +0200
Message-ID: <87io84byr8.fsf@nemi.mork.no>
References: <55CE1D7E.2070400@rosalab.ru>
	<1439571516-11862-1-git-send-email-eugene.shatokhin@rosalab.ru>
	<20150818.185407.1667358232705414236.davem@davemloft.net>
	<55D436D5.6010105@rosalab.ru> <87k2sreefu.fsf@nemi.mork.no>
	<55D46F85.50608@rosalab.ru> <877fore9yn.fsf@nemi.mork.no>
	<55DB0C1C.5030607@rosalab.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, oneukum@suse.com,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55DB0C1C.5030607@rosalab.ru> (Eugene Shatokhin's message of
	"Mon, 24 Aug 2015 15:20:44 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eugene Shatokhin <eugene.shatokhin@rosalab.ru> writes:

> 19.08.2015 15:31, Bj=C3=B8rn Mork =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> Eugene Shatokhin <eugene.shatokhin@rosalab.ru> writes:
>>
>>> The problem is not in the reordering but rather in the fact that
>>> "dev->flags =3D 0" is not necessarily atomic
>>> w.r.t. "clear_bit(EVENT_RX_KILL, &dev->flags)", and vice versa.
>>>
>>> So the following might be possible, although unlikely:
>>>
>>> CPU0             CPU1
>>>                   clear_bit: read dev->flags
>>>                   clear_bit: clear EVENT_RX_KILL in the read value
>>>
>>> dev->flags=3D0;
>>>
>>>                   clear_bit: write updated dev->flags
>>>
>>> As a result, dev->flags may become non-zero again.
>>
>> Ah, right.  Thanks for explaining.
>>
>>> I cannot prove yet that this is an impossible situation. If anyone
>>> can, please explain. If so, this part of the patch will not be need=
ed.
>>
>> I wonder if we could simply move the dev->flags =3D 0 down a few lin=
es to
>> fix both issues?  It doesn't seem to do anything useful except for
>> resetting the flags to a sane initial state after the device is down=
=2E
>>
>> Stopping the tasklet rescheduling etc depends only on netif_running(=
),
>> which will be false when usbnet_stop is called.  There is no need to
>> touch dev->flags for this to happen.
>
> That was one of the first ideas we discussed here. Unfortunately, it
> is probably not so simple.
>
> Setting dev->flags to 0 makes some delayed operations do nothing and,
> among other things, not to reschedule usbnet_bh().

Yes, but I believe that is merely a side effect.  You should never need
to clear multiple flags to get the desired behaviour.

> As you can see in drivers/net/usb/usbnet.c, usbnet_bh() can be called
> as a tasklet function and as a timer function in a number of
> situations (look for the usage of dev->bh and dev->delay there).
>
> netif_running() is indeed false when usbnet_stop() runs, usbnet_stop(=
)
> also disables Tx. This seems to be enough for many cases where
> usbnet_bh() is scheduled, but I am not so sure about the remaining
> ones, namely:
>
> 1. A work function, usbnet_deferred_kevent(), may reschedule
> usbnet_bh(). Looks like the workqueue is only stopped in
> usbnet_disconnect(), so a work item might be processed while
> usbnet_stop() works. Setting dev->flags to 0 makes the work function
> do nothing, by the way. See also the comment in usbnet_stop() about
> this.
>
> A work item may be placed to this workqueue in a number of ways, by
> both usbnet module and the mini-drivers. It is not too easy to track
> all these situations.

That's an understatement :)



> 2. rx_complete() and tx_complete() may schedule execution of
> usbnet_bh() as a tasklet or a timer function. These two are URB
> completion callbacks.
>
> It seems, new Rx and Tx URBs cannot be submitted when usbnet_stop()
> clears dev->flags, indeed. But it does not prevent the completion
> handlers for the previously submitted URBs from running concurrently
> with usbnet_stop(). The latter waits for them to complete (via
> usbnet_terminate_urbs(dev)) but only if FLAG_AVOID_UNLINK_URBS is not
> set in info->flags. rndis_wlan, however, sets this flag for a few
> hardware models. So - no guarantees here as well.

=46LAG_AVOID_UNLINK_URBS looks like it should be replaced by the newer
ability to keep the status urb active. I believe that must have been th=
e
real reason for adding it, based on the commit message and the effect
the flag will have:

 commit 1487cd5e76337555737cbc55d7d83f41460d198f
 Author: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
 Date:   Thu Jul 30 19:41:20 2009 +0300

    usbnet: allow "minidriver" to prevent urb unlinking on usbnet_stop
   =20
    rndis_wlan devices freeze after running usbnet_stop several times. =
It appears
    that firmware freezes in state where it does not respond to any RND=
IS commands
    and device have to be physically unplugged/replugged. This patch le=
ts
    minidrivers to disable unlink_urbs on usbnet_stop through new info =
flag.
   =20
    Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
    Cc: David Brownell <dbrownell@users.sourceforge.net>
    Signed-off-by: John W. Linville <linville@tuxdriver.com>



The rx urbs will not be resubmitted in any case, and there are of cours=
e
no tx urbs being submitted.  So the only effect of this flag is on the
status/interrupt urb, which I can imagine some RNDIS devices wants
active all the time.=20

So FLAG_AVOID_UNLINK_URBS should probably be removed and replaced calls
to usbnet_status_start() and usbnet_status_stop().  This will require
testing on some of the devices with the original firmware problem
however.

In any case: I do not think this flag should be considered when trying
to make usbnet_stop behaviour saner.  It's only purpose is to
deliberately break usbnet_stop by not actually stopping.


> If someone could list the particular bits of dev->flags that should b=
e
> cleared to make sure no deferred call could reschedule usbnet_bh(),
> etc... Well, it would be enough to clear these first and use
> dev->flags =3D 0 later, after tasklet_kill() and del_timer_sync(). I
> cannot point out these particular bits now.


I don't think any of the flags must be cleared.  The sequence

        dev_close(dev->net);
	usbnet_terminate_urbs(dev);
	usbnet_purge_paused_rxq(dev);
	del_timer_sync (&dev->delay);
	tasklet_kill (&dev->bh);

should prevent any rescheduling of usbnet_bh

> Besides, it is possible, although unlikely, that new event bits will
> be added to dev->flags in the future. And one will need to keep track
> of these to see if they should be cleared as well. I'd prever to play
> safer for now and clear them all.

I don't think we should ever make a flag which will _have_ to be reset
for usbnet_stop.  The only reason for clearing all flags is to reset th=
e
state before the next open.

Yes, I see that we currently need to clear EVENT_DEV_OPEN in
usbnet_stop, but I really don't see what this flag gives us which isn't
already provided by netif_running().  It looks like a duplicate.


Bj=C3=B8rn
