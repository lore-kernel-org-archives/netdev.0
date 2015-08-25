From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] usbnet: Fix two races between usbnet_stop() and the BH
Date: Tue, 25 Aug 2015 14:31:51 +0200
Message-ID: <1440505911.13824.4.camel@suse.com>
References: <55CE1D7E.2070400@rosalab.ru>
	 <1439571516-11862-1-git-send-email-eugene.shatokhin@rosalab.ru>
	 <20150818.185407.1667358232705414236.davem@davemloft.net>
	 <55D436D5.6010105@rosalab.ru> <87k2sreefu.fsf@nemi.mork.no>
	 <55D46F85.50608@rosalab.ru> <877fore9yn.fsf@nemi.mork.no>
	 <55DB0C1C.5030607@rosalab.ru> <87io84byr8.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87io84byr8.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-08-24 at 15:29 +0200, Bj=C3=B8rn Mork wrote:
> Eugene Shatokhin <eugene.shatokhin@rosalab.ru> writes:
>=20
> > 19.08.2015 15:31, Bj=C3=B8rn Mork =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> >> Eugene Shatokhin <eugene.shatokhin@rosalab.ru> writes:

> >> Stopping the tasklet rescheduling etc depends only on netif_runnin=
g(),
> >> which will be false when usbnet_stop is called.  There is no need =
to
> >> touch dev->flags for this to happen.
> >
> > That was one of the first ideas we discussed here. Unfortunately, i=
t
> > is probably not so simple.
> >
> > Setting dev->flags to 0 makes some delayed operations do nothing an=
d,
> > among other things, not to reschedule usbnet_bh().
>=20
> Yes, but I believe that is merely a side effect.  You should never ne=
ed
> to clear multiple flags to get the desired behaviour.

Why? Is there any reason you cannot have a TX and an RX halt at the sam=
e
time?

> > As you can see in drivers/net/usb/usbnet.c, usbnet_bh() can be call=
ed
> > as a tasklet function and as a timer function in a number of
> > situations (look for the usage of dev->bh and dev->delay there).
> >
> > netif_running() is indeed false when usbnet_stop() runs, usbnet_sto=
p()
> > also disables Tx. This seems to be enough for many cases where
> > usbnet_bh() is scheduled, but I am not so sure about the remaining
> > ones, namely:
> >
> > 1. A work function, usbnet_deferred_kevent(), may reschedule
> > usbnet_bh(). Looks like the workqueue is only stopped in
> > usbnet_disconnect(), so a work item might be processed while
> > usbnet_stop() works. Setting dev->flags to 0 makes the work functio=
n
> > do nothing, by the way. See also the comment in usbnet_stop() about
> > this.

Yes, this is the main reason the flags are collectively cleared.
We could do them all with clear_bit(). Ugly though.

> > A work item may be placed to this workqueue in a number of ways, by
> > both usbnet module and the mini-drivers. It is not too easy to trac=
k
> > all these situations.
>=20
> That's an understatement :)

Yes.

> So FLAG_AVOID_UNLINK_URBS should probably be removed and replaced cal=
ls
> to usbnet_status_start() and usbnet_status_stop().  This will require
> testing on some of the devices with the original firmware problem
> however.

And there you point out the main problem.

> In any case: I do not think this flag should be considered when tryin=
g
> to make usbnet_stop behaviour saner.  It's only purpose is to
> deliberately break usbnet_stop by not actually stopping.

Yes.

	Regards
		Oliver
