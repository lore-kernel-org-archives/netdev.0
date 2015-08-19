From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] usbnet: Fix two races between usbnet_stop() and the BH
Date: Wed, 19 Aug 2015 14:31:12 +0200
Message-ID: <877fore9yn.fsf@nemi.mork.no>
References: <55CE1D7E.2070400@rosalab.ru>
	<1439571516-11862-1-git-send-email-eugene.shatokhin@rosalab.ru>
	<20150818.185407.1667358232705414236.davem@davemloft.net>
	<55D436D5.6010105@rosalab.ru> <87k2sreefu.fsf@nemi.mork.no>
	<55D46F85.50608@rosalab.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, oneukum@suse.com,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55D46F85.50608@rosalab.ru> (Eugene Shatokhin's message of "Wed,
	19 Aug 2015 14:59:01 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eugene Shatokhin <eugene.shatokhin@rosalab.ru> writes:

> The problem is not in the reordering but rather in the fact that
> "dev->flags =3D 0" is not necessarily atomic
> w.r.t. "clear_bit(EVENT_RX_KILL, &dev->flags)", and vice versa.
>
> So the following might be possible, although unlikely:
>
> CPU0             CPU1
>                  clear_bit: read dev->flags
>                  clear_bit: clear EVENT_RX_KILL in the read value
>
> dev->flags=3D0;
>
>                  clear_bit: write updated dev->flags
>
> As a result, dev->flags may become non-zero again.

Ah, right.  Thanks for explaining.

> I cannot prove yet that this is an impossible situation. If anyone
> can, please explain. If so, this part of the patch will not be needed=
=2E

I wonder if we could simply move the dev->flags =3D 0 down a few lines =
to
fix both issues?  It doesn't seem to do anything useful except for
resetting the flags to a sane initial state after the device is down.

Stopping the tasklet rescheduling etc depends only on netif_running(),
which will be false when usbnet_stop is called.  There is no need to
touch dev->flags for this to happen.

>> The EVENT_NO_RUNTIME_PM bug should definitely be fixed.  Please spli=
t
>> that out as a separate fix.  It's a separate issue, and should be
>> backported to all maintained stable releases it applies to (anything
>> from v3.8 and newer)
>
> Yes, that makes sense. However, this fix was originally provided by
> Oliver Neukum rather than me, so I would like to hear his opinion as
> well first.

If what I write above is correct (please help me verify...), then maybe
it does make sense to do these together anyway.



Bj=C3=B8rn
