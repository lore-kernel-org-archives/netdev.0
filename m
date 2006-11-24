From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Kevent POSIX timers support.
Date: Fri, 24 Nov 2006 12:50:52 +0300
Message-ID: <20061124095052.GC13600@2ka.mipt.ru>
References: <20061120082500.GA25467@2ka.mipt.ru> <4562102B.5010503@redhat.com> <20061121095302.GA15210@2ka.mipt.ru> <45633049.2000209@redhat.com> <20061121174334.GA25518@2ka.mipt.ru> <20061121184605.GA7787@2ka.mipt.ru> <4563FE71.4040807@redhat.com> <20061122104416.GD11480@2ka.mipt.ru> <20061123085243.GA11575@2ka.mipt.ru> <456603E7.9090006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Alexander Viro <aviro@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:28034 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S934526AbWKXJxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Nov 2006 04:53:07 -0500
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <456603E7.9090006@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 23, 2006 at 12:26:15PM -0800, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> >+static int posix_kevent_init(void)
> >+{
> >+	struct kevent_callbacks tc =3D {
> >+		.callback =3D &posix_kevent_callback,
> >+		.enqueue =3D &posix_kevent_enqueue,
> >+		.dequeue =3D &posix_kevent_dequeue};
>=20
> How do we prevent that somebody tries to register a POSIX timer event=
=20
> source with kevent_ctl(KEVENT_CTL_ADD)?  This should only be possible=
=20
> from sys_timer_create and nowhere else.
>=20
> Can you add a parameter to kevent_enqueue indicating this is a call f=
rom=20
> inside the kernel and then ignore certain enqueue callbacks?

I think we need some set of flags for callbacks - where they can be
called, maybe even from which context and so on. So userspace will not
be allowed to create such timers through kevent API.
Will do it for release.
=20
> >@@ -343,23 +439,27 @@ static int posix_timer_fn(struct hrtimer
> >=20
> > 	timr =3D container_of(timer, struct k_itimer, it.real.timer);
> > 	spin_lock_irqsave(&timr->it_lock, flags);
> >+=09
> >+	if (timr->it_sigev_notify & SIGEV_KEVENT) {
> >+		kevent_storage_ready(&timr->st, NULL, KEVENT_MASK_ALL);
> >+	} else {
>=20
> We need to pass the data in the sigev_value meember of the struct=20
> sigevent structure passed to timer_create to the caller.  I don't see=
 it=20
> being done here nor when the timer is created.  Do I miss something?=20
> The sigev_value value should be stored in the user/ptr member of stru=
ct=20
> ukevent.

sigev_value was stored in k_itimer structure, I just do not know where
to put it in the ukevent provided to userspace - it can be placed in
pointer value if you like.

> >+		if (event.sigev_notify & SIGEV_KEVENT) {
>=20
> Don't use a bit.  It makes no sense to combine SIGEV_SIGNAL with=20
> SIGEV_KEVENT etc.  Only SIGEV_THREAD_ID is a special case.
>=20
> Just define SIGEV_KEVENT to 3 and replace the tests like the one cite=
d=20
> above with
>=20
>   if (timr->it_sigev_notify =3D=3D SIGEV_KEVENT)

Ok.

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96

--=20
	Evgeniy Polyakov
