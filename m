From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: Kevent POSIX timers support.
Date: Thu, 23 Nov 2006 12:26:15 -0800
Message-ID: <456603E7.9090006@redhat.com>
References: <20061113105458.GA8182@2ka.mipt.ru> <4560F07B.10608@redhat.com> <20061120082500.GA25467@2ka.mipt.ru> <4562102B.5010503@redhat.com> <20061121095302.GA15210@2ka.mipt.ru> <45633049.2000209@redhat.com> <20061121174334.GA25518@2ka.mipt.ru> <20061121184605.GA7787@2ka.mipt.ru> <4563FE71.4040807@redhat.com> <20061122104416.GD11480@2ka.mipt.ru> <20061123085243.GA11575@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
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
Received: from mx1.redhat.com ([66.187.233.31]:24547 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S933877AbWKWU1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Nov 2006 15:27:08 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061123085243.GA11575@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> +static int posix_kevent_init(void)
> +{
> +	struct kevent_callbacks tc =3D {
> +		.callback =3D &posix_kevent_callback,
> +		.enqueue =3D &posix_kevent_enqueue,
> +		.dequeue =3D &posix_kevent_dequeue};

How do we prevent that somebody tries to register a POSIX timer event=20
source with kevent_ctl(KEVENT_CTL_ADD)?  This should only be possible=20
from sys_timer_create and nowhere else.

Can you add a parameter to kevent_enqueue indicating this is a call fro=
m=20
inside the kernel and then ignore certain enqueue callbacks?


> @@ -343,23 +439,27 @@ static int posix_timer_fn(struct hrtimer
> =20
>  	timr =3D container_of(timer, struct k_itimer, it.real.timer);
>  	spin_lock_irqsave(&timr->it_lock, flags);
> +=09
> +	if (timr->it_sigev_notify & SIGEV_KEVENT) {
> +		kevent_storage_ready(&timr->st, NULL, KEVENT_MASK_ALL);
> +	} else {

We need to pass the data in the sigev_value meember of the struct=20
sigevent structure passed to timer_create to the caller.  I don't see i=
t=20
being done here nor when the timer is created.  Do I miss something?=20
The sigev_value value should be stored in the user/ptr member of struct=
=20
ukevent.


> +		if (event.sigev_notify & SIGEV_KEVENT) {

Don't use a bit.  It makes no sense to combine SIGEV_SIGNAL with=20
SIGEV_KEVENT etc.  Only SIGEV_THREAD_ID is a special case.

Just define SIGEV_KEVENT to 3 and replace the tests like the one cited=20
above with

   if (timr->it_sigev_notify =3D=3D SIGEV_KEVENT)

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
