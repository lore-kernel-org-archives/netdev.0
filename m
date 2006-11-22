From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take25 1/6] kevent: Description.
Date: Wed, 22 Nov 2006 15:46:42 -0800
Message-ID: <4564E162.8040901@redhat.com>
References: <11641265982190@2ka.mipt.ru>
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
Received: from mx1.redhat.com ([66.187.233.31]:17587 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1757187AbWKVXuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Nov 2006 18:50:16 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <11641265982190@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> + int kevent_wait(int ctl_fd, unsigned int num, __u64 timeout);
> +
> +ctl_fd - file descriptor referring to the kevent queue=20
> +num - number of processed kevents=20
> +timeout - this timeout specifies number of nanoseconds to wait until=
 there is=20
> +		free space in kevent queue=20
> +
> +Return value:
> + number of events copied into ring buffer or negative error value.

This is not quite sufficient.  What we also need is a parameter which=20
specifies which ring buffer the code assumes is currently active.  This=
=20
is just like the EWOULDBLOCK error in the futex.  I.e., the kernel=20
doesn't move the thread on the wait list if the index has changed.=20
Otherwise asynchronous ring buffer filling is impossible.  Assume this

     thread                             kernel

     get current ring buffer idx

     front and tail pointer the same

                                        add new entry to ring buffer

                                        bump front pointer

     call kevent_wait()


With the interface above this leads to a deadlock.  The kernel delivere=
d=20
the event and is done with it.

If the kevent_wait() syscall gets an additional parameter which=20
specifies the expected front pointer the kernel wouldn't put the thread=
=20
to sleep since, in this case, the front pointer changed since last chec=
ked.

The kernel cannot and should not check the ring buffer is empty.=20
Userlevel should maintain the tail pointer all by itself.  And even if=20
the tail pointer is available to the kernel, the program might want to=20
handle the queued events differently.

The above also comes to bear without asynchronous queuing if a thread=20
waits for more than one event and it is possible to handle both events=20
concurrently in two threads.

Passing in the expected front pointer value is flexible and efficient.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
