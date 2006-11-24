From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take25 1/6] kevent: Description.
Date: Fri, 24 Nov 2006 08:30:14 -0800
Message-ID: <45671E16.6060005@redhat.com>
References: <11641265982190@2ka.mipt.ru> <4564E2AB.1020202@redhat.com> <20061123115504.GB20294@2ka.mipt.ru> <4565FDED.2050003@redhat.com> <20061124114614.GA32545@2ka.mipt.ru>
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
Received: from mx1.redhat.com ([66.187.233.31]:40327 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S934982AbWKXQa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Nov 2006 11:30:57 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061124114614.GA32545@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
>> Very much simplified but it should show that we need a writable copy=
 of=20
>> the uidx.  And this value at any time must be consistent with the in=
dex=20
>> the kernel assumes.
>=20
> I seriously doubt it is simpler than having index provided by kernel.

What has simpler to do with it?  The userlevel code should not modify=20
the ring buffer structure at all.  If we'd do this then all operations,=
=20
at least on the uidx field, would have to be atomic operations.  This i=
s=20
currently not the case for the kernel side since it's protected by a=20
lock for the event queue.  Using the uidx field from userlevel would=20
therefore just make things slower.

And for what?  Changing the uidx value would make the commit syscall=20
unnecessary.  This might be an argument but it sounds too dangerous.=20
IMO the value should be protected by the kernel.

And in any case, the uidx value cannot be updated until the event=20
actually has been processed.  But the threads still need to coordinate=20
distributing the events from the ring buffer amongst themselves.  This=20
will in any case require a second variable.

So, if you want to do away with the commit syscall, keep the uidx value=
=2E=20
  This also requires that the ring buffer head will always be writable=20
(something I'd like to avoid making part of the interface but I'm=20
flexible on this).  Otherwise, the ring_uidx element can go away, it's=20
not needed and will only make people think about wrong approaches to us=
e it.


> You propose to make uidx shared local variable - it is doable, but it
> is not required - userspace can use kernel's variable, since it is
> updated exactly in the places where that index is changed.

As said above, we always need another variable and uidx is only a=20
replacement for the commit call.  Until the event is processed the uidx=
=20
cannot be incremented since otherwise the ring buffer entry might be=20
overwritten.

And kernel people of all should be happy to limit the exposure of the=20
implementation.  So, leave the problem of keeping track of the tail=20
pointer to the userlevel code.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
