From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take25 1/6] kevent: Description.
Date: Fri, 24 Nov 2006 08:06:59 -0800
Message-ID: <456718A3.1070108@redhat.com>
References: <11641265982190@2ka.mipt.ru> <4564E162.8040901@redhat.com> <20061123115240.GA20294@2ka.mipt.ru> <4565FA60.9000402@redhat.com> <20061124110143.GF13600@2ka.mipt.ru>
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
Received: from mx1.redhat.com ([66.187.233.31]:45539 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1757793AbWKXQIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Nov 2006 11:08:05 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061124110143.GF13600@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
>> I know this is how it's done now.  But it is not where it has to end=
=2E=20
>> IMO we have to get to a solution where new events are posted to the =
ring=20
>> buffer asynchronously, i.e., without a thread calling kevent_wait.  =
And=20
>> then you need the extra parameter and verification.  Even if it's to=
day=20
>> not needed we have to future-proof the interface since it cannot be=20
>> changed once in use.
>=20
> There is a special flag in kevent_user to wake it if there are no rea=
dy
> events - kernel thread which has added new events will set it and thu=
s
> subsequent kevent_wait() will return with updated indexes - userspace
> must check indexes after kevent_wait().

You misunderstand.  I don't want to return without waiting unconditiona=
lly.

There is a race which has to be closed.  It's exactly the same as in th=
e=20
futex syscall.  I've shown the interaction between the kernel and the=20
thread in the previous mail.  There is inevitably a time difference=20
between the thread checking whether the ring buffer is empty and the=20
kernel putting the thread to sleep in the kevent_wait call.

This is no problem with the current kevent_wait implementation since th=
e=20
ring buffer is not filled asynchronously.  But if/when it will be the=20
kernel might add something to the ring buffer _after_ the thread checks=
=20
for an empty ring buffer and _before_ it enters the kernel in the=20
kevent_wait syscall.

The kevent_wait syscall will only wake the thread when a new event is=20
posted.  We do not in general want it to be woken when the ring buffer=20
is non empty.  This would create far too many unnecessary wakeups it=20
there is more than one thread working on the queue.

With the addition parameters for kevent_wait indicating when the callin=
g=20
thread last checked the ring buffer the kernel can find out whether the=
=20
decision to call kevent_wait was made based on outdated information or=20
not.  Outdated in the case a new event has been posted.  In this case=20
the thread is not put to sleep but instead returns.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
