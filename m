From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take25 1/6] kevent: Description.
Date: Fri, 24 Nov 2006 14:46:15 +0300
Message-ID: <20061124114614.GA32545@2ka.mipt.ru>
References: <11641265982190@2ka.mipt.ru> <4564E2AB.1020202@redhat.com> <20061123115504.GB20294@2ka.mipt.ru> <4565FDED.2050003@redhat.com>
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
Received: from relay.2ka.mipt.ru ([194.85.82.65]:28118 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S934115AbWKXLr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Nov 2006 06:47:29 -0500
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <4565FDED.2050003@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 23, 2006 at 12:00:45PM -0800, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> >uidx is an index, starting from which there are unread entries. It i=
s
> >updated by userspace when it commits entries, so it is 'consumer'
> >pointer, while kidx is an index where kernel will put new entries, i=
=2Ee.
> >'producer' index. We definitely need them both.
> >Userspace can only update (implicitly by calling kevent_commit()) ui=
dx.
>=20
> Right, which is why exporting this entry is not needed.  Keep the=20
> interface as small as possible.

If there are several callers of kevent_commit(), uidx can be changed fa=
r
than first user expects, so there should be possibility to check that
value. It is thus exported into shared ring buffer structure.

> Userlevel has to maintain its own index.  Just assume kevent_wait=20
> returns 10 new entries and you have multiple threads.  In this case a=
ll=20
> threads take their turns and pick an entry from the ring buffer.  Thi=
s=20
> basically has to be done with something like this (I ignore wrap-arou=
nds=20
> here to simplify the example):
>=20
>   int getidx() {
>     while (uidx < kidx)
>        if (atomic_cmpxchg(uidx, uidx + 1, uidx) =3D=3D 0)
>          return uidx;
>     return -1;
>   }
>=20
> Very much simplified but it should show that we need a writable copy =
of=20
> the uidx.  And this value at any time must be consistent with the ind=
ex=20
> the kernel assumes.

I seriously doubt it is simpler than having index provided by kernel.

> The current ring_uidx value can at best be used to reinitialize the=20
> userlevel uidx value after each kevent_wait call but this is unnecess=
ary=20
> at best (since uidx must already have this value) and racy in problem=
=20
> cases (what if more than one thread gets woken concurrently with uidx=
=20
> having the same value and one thread stores the uidx value and=20
> immediately increments it to get an index; the second store would=20
> overwrite the increment).
>=20
> I can assure you that any implementation I write would not use the=20
> ring_uidx value.  Only trivial, single-threaded examples like you=20
> ring_buffer.c could ever take advantage of this value.  It's not wort=
h it.

You propose to make uidx shared local variable - it is doable, but it
is not required - userspace can use kernel's variable, since it is
updated exactly in the places where that index is changed.

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=20
	Evgeniy Polyakov
