From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take25 1/6] kevent: Description.
Date: Fri, 24 Nov 2006 15:05:31 +0300
Message-ID: <20061124120531.GC32545@2ka.mipt.ru>
References: <11641265982190@2ka.mipt.ru> <456621AC.7000009@redhat.com>
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
Received: from relay.2ka.mipt.ru ([194.85.82.65]:13549 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S934429AbWKXMG3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Nov 2006 07:06:29 -0500
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <456621AC.7000009@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 23, 2006 at 02:33:16PM -0800, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> >+ int kevent_commit(int ctl_fd, unsigned int start,=20
> >+ 	unsigned int num, unsigned int over);
>=20
> I think we can simplify this interface:
>=20
>    int kevent_commit(int ctl_fd, unsigned int new_tail,
>                      unsigned int over);
>=20
> The kernel sets the ring_uidx value to the 'new_tail' value if the ta=
il=20
> pointer would be incremented (module wrap around) and is not higher t=
hen=20
> the current front pointer.  The test will be a bit complicated but no=
t=20
> more so than what the current code has to do to check for mistakes.
>=20
> This approach has the advantage that the commit calls don't have to b=
e=20
> synchronized.  If one thread sets the tail pointer to, say, 10 and=20
> another to 12, then it does not matter whether the first thread is=20
> delayed.  If it will eventually be executed the result is simply a no=
-op=20
> and since second thread's action supersedes it.
>=20
> Maybe the current form is even impossible to use with explicit lockin=
g=20
> at userlevel.  What if one thread, which is about to call kevent_comm=
it,=20
> if indefinitely delayed.  Then this commit request's value is never=20
> taken into account and the tail pointer is always short of what it=20
> should be.

I like this interface, although current one does not allow special
synchronization in userspace, since it calculates if new commit is in
the area where previous commit was.
Will change for the next release.
=20
> There is one more thing to consider.  Oftentimes the commit request w=
ill=20
> be immediately followed by a kevent_wait call.  It would be good to=20
> merge this pair of calls.  The two parameters new_tail and over could=
=20
> also be passed to the kevent_wait call and the commit can happen befo=
re=20
> the thread looks for new events and eventually goes to sleep.  If thi=
s=20
> can be implemented then the kevent_commit syscall by itself might not=
 be=20
> needed at all.  Instead you'd call kevent_wait() and make the maximum=
=20
> number of events which can be returned zero.

It _IS_ how previous interface worked.

	EXACTLY!

There was one syscall which committed requested number of events and
waited when there are new ready events. The only thing it missed, was
userspace index (it assumed that if userspace waits for something, then
all previous work is done).

Ulrich, I'm not going to think for other people all over the world and
blindly implementing ideas, which in a day or two will be commented as
redundant, since flow of mind has changed, and they had not enough time
to check previous version.

I will wait for some time until you and other people made theirs commen=
ts=20
on interfaces and release final version in about a week, and now I will
go to hack netchannels.

	NO INTERFACE CHANGES AFTER THAT DAY.=20
		COMPLETELY.

So, feel free to think about perfect interface anyone will be happy
with. But please release your thoughts not in form of abstract words,
but more precisely, at least like in this e-mail, so I could understand
what _you_ want from _your_ interface.

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96

--=20
	Evgeniy Polyakov
