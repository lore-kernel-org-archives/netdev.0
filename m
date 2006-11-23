From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take25 1/6] kevent: Description.
Date: Thu, 23 Nov 2006 12:00:45 -0800
Message-ID: <4565FDED.2050003@redhat.com>
References: <11641265982190@2ka.mipt.ru> <4564E2AB.1020202@redhat.com> <20061123115504.GB20294@2ka.mipt.ru>
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
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:7385 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S933857AbWKWUBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Nov 2006 15:01:53 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061123115504.GB20294@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> uidx is an index, starting from which there are unread entries. It is
> updated by userspace when it commits entries, so it is 'consumer'
> pointer, while kidx is an index where kernel will put new entries, i.=
e.
> 'producer' index. We definitely need them both.
> Userspace can only update (implicitly by calling kevent_commit()) uid=
x.

Right, which is why exporting this entry is not needed.  Keep the=20
interface as small as possible.

Userlevel has to maintain its own index.  Just assume kevent_wait=20
returns 10 new entries and you have multiple threads.  In this case all=
=20
threads take their turns and pick an entry from the ring buffer.  This=20
basically has to be done with something like this (I ignore wrap-around=
s=20
here to simplify the example):

   int getidx() {
     while (uidx < kidx)
        if (atomic_cmpxchg(uidx, uidx + 1, uidx) =3D=3D 0)
          return uidx;
     return -1;
   }

Very much simplified but it should show that we need a writable copy of=
=20
the uidx.  And this value at any time must be consistent with the index=
=20
the kernel assumes.

The current ring_uidx value can at best be used to reinitialize the=20
userlevel uidx value after each kevent_wait call but this is unnecessar=
y=20
at best (since uidx must already have this value) and racy in problem=20
cases (what if more than one thread gets woken concurrently with uidx=20
having the same value and one thread stores the uidx value and=20
immediately increments it to get an index; the second store would=20
overwrite the increment).

I can assure you that any implementation I write would not use the=20
ring_uidx value.  Only trivial, single-threaded examples like you=20
ring_buffer.c could ever take advantage of this value.  It's not worth =
it.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
