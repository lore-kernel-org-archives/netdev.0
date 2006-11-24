From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take25 1/6] kevent: Description.
Date: Fri, 24 Nov 2006 19:14:06 +0300
Message-ID: <20061124161406.GA5054@2ka.mipt.ru>
References: <11641265982190@2ka.mipt.ru> <4564E162.8040901@redhat.com> <20061123115240.GA20294@2ka.mipt.ru> <4565FA60.9000402@redhat.com> <20061124110143.GF13600@2ka.mipt.ru> <456718A3.1070108@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:50328 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S934505AbWKXQOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Nov 2006 11:14:52 -0500
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <456718A3.1070108@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 24, 2006 at 08:06:59AM -0800, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> >>I know this is how it's done now.  But it is not where it has to en=
d.=20
> >>IMO we have to get to a solution where new events are posted to the=
 ring=20
> >>buffer asynchronously, i.e., without a thread calling kevent_wait. =
 And=20
> >>then you need the extra parameter and verification.  Even if it's t=
oday=20
> >>not needed we have to future-proof the interface since it cannot be=
=20
> >>changed once in use.
> >
> >There is a special flag in kevent_user to wake it if there are no re=
ady
> >events - kernel thread which has added new events will set it and th=
us
> >subsequent kevent_wait() will return with updated indexes - userspac=
e
> >must check indexes after kevent_wait().
>=20
> You misunderstand.  I don't want to return without waiting unconditio=
nally.
>=20
> There is a race which has to be closed.  It's exactly the same as in =
the=20
> futex syscall.  I've shown the interaction between the kernel and the=
=20
> thread in the previous mail.  There is inevitably a time difference=20
> between the thread checking whether the ring buffer is empty and the=20
> kernel putting the thread to sleep in the kevent_wait call.
>=20
> This is no problem with the current kevent_wait implementation since =
the=20
> ring buffer is not filled asynchronously.  But if/when it will be the=
=20
> kernel might add something to the ring buffer _after_ the thread chec=
ks=20
> for an empty ring buffer and _before_ it enters the kernel in the=20
> kevent_wait syscall.
>=20
> The kevent_wait syscall will only wake the thread when a new event is=
=20
> posted.  We do not in general want it to be woken when the ring buffe=
r=20
> is non empty.  This would create far too many unnecessary wakeups it=20
> there is more than one thread working on the queue.
>=20
> With the addition parameters for kevent_wait indicating when the call=
ing=20
> thread last checked the ring buffer the kernel can find out whether t=
he=20
> decision to call kevent_wait was made based on outdated information o=
r=20
> not.  Outdated in the case a new event has been posted.  In this case=
=20
> the thread is not put to sleep but instead returns.

Read my mail again.

If kernel has put data asynchronously it will setup special flag, thus=20
kevent_wait() will not sleep and will return, so thread will check new
entries and process them.

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96

--=20
	Evgeniy Polyakov
