From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take25 1/6] kevent: Description.
Date: Thu, 23 Nov 2006 14:33:16 -0800
Message-ID: <456621AC.7000009@redhat.com>
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
Received: from mx1.redhat.com ([66.187.233.31]:34222 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S934193AbWKWWeV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Nov 2006 17:34:21 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <11641265982190@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> + int kevent_commit(int ctl_fd, unsigned int start,=20
> + 	unsigned int num, unsigned int over);

I think we can simplify this interface:

    int kevent_commit(int ctl_fd, unsigned int new_tail,
                      unsigned int over);

The kernel sets the ring_uidx value to the 'new_tail' value if the tail=
=20
pointer would be incremented (module wrap around) and is not higher the=
n=20
the current front pointer.  The test will be a bit complicated but not=20
more so than what the current code has to do to check for mistakes.

This approach has the advantage that the commit calls don't have to be=20
synchronized.  If one thread sets the tail pointer to, say, 10 and=20
another to 12, then it does not matter whether the first thread is=20
delayed.  If it will eventually be executed the result is simply a no-o=
p=20
and since second thread's action supersedes it.

Maybe the current form is even impossible to use with explicit locking=20
at userlevel.  What if one thread, which is about to call kevent_commit=
,=20
if indefinitely delayed.  Then this commit request's value is never=20
taken into account and the tail pointer is always short of what it=20
should be.


There is one more thing to consider.  Oftentimes the commit request wil=
l=20
be immediately followed by a kevent_wait call.  It would be good to=20
merge this pair of calls.  The two parameters new_tail and over could=20
also be passed to the kevent_wait call and the commit can happen before=
=20
the thread looks for new events and eventually goes to sleep.  If this=20
can be implemented then the kevent_commit syscall by itself might not b=
e=20
needed at all.  Instead you'd call kevent_wait() and make the maximum=20
number of events which can be returned zero.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
