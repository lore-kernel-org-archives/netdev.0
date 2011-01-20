From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [GIT] Networking
Date: Thu, 20 Jan 2011 22:25:48 +0100
Message-ID: <1295558748.2613.28.camel@edumazet-laptop>
References: <20110119.180418.216749267.davem@davemloft.net>
	 <AANLkTin32jUnBtHF-EAkSMnFQM6cTbn-G3NZQJ3xjTWU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTin32jUnBtHF-EAkSMnFQM6cTbn-G3NZQJ3xjTWU@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 20 janvier 2011 =C3=A0 13:12 -0800, Linus Torvalds a =C3=A9cri=
t :
> On Wed, Jan 19, 2011 at 6:04 PM, David Miller <davem@davemloft.net> w=
rote:
> >
> > 1) Revert a netlink flag sanity check that is causing regressions i=
n
> >   existing applications.
> ...
>=20
> This is a long-shot, but I thought I'd ask before I start trying to
> bisect the fourth independent suspend/resume related issue in this
> merge window..
>=20
> When I suspend/resume while logged in by closing the lid on my laptop
> on FC14, it causes the gnome-screensaver-dialog to start up. So far s=
o
> fine, that's what I want, and it all works fin in 2.6.37.
>=20
> But in current -git (and in -rc8, so it's not changed by your latest
> pull request), gnome-screensaver-dialog gets stuck after I type in my
> password, making the box basically useless.
>=20
> So I straced it over the network, and if I attach _when_ it is alread=
y
> stuck, it immediately becomes unstuck.  But if I attach to it before
> typing my password, I can see the hang in strace, and it looks like
> this:
>=20
>   ...
>   read(3, 0x9806500, 4096)                =3D -1 EAGAIN (Resource
> temporarily unavailable)
>   poll([{fd=3D4, events=3DPOLLIN}, {fd=3D3, events=3DPOLLIN}, {fd=3D1=
2,
> events=3DPOLLIN|POLLPRI}, {fd=3D14, events=3DPOLLIN|POLLPRI}, {fd=3D9=
,
> events=3DPOLLIN|POLLPRI}, {fd=3D10, events=3DPOLLIN|POLLPRI}, {fd=3D1=
5,
> events=3DPOLLIN}, {fd=3D16, events=3DPOLLIN}, {fd=3D17, events=3D0}, =
{fd=3D19,
> events=3DPOLLIN}], 10, -1) =3D ? ERESTART_RESTARTBLOCK (To be restart=
ed)
>   restart_syscall(
>=20
> and that's it - it's now hung. So why did it work when I straced it
> while hung? And why is it doing that ERESTART_RESTARTBLOCK in the
> first place, I'm not seeing any signals there?
>=20
> So I tried sending it a useless signal, which will re-animate the
> strace, and now I get:
>=20
>   restart_syscall(<... resuming interrupted call ...>) =3D 1
>   --- SIGWINCH (Window changed) @ 0 (0) ---
>   poll([{fd=3D3, events=3DPOLLIN|POLLOUT}], 1, -1) =3D 1 ([{fd=3D3, r=
events=3DPOLLOUT}])
>=20
> Whee. That signal got it started again, and the poll finished immedia=
tely.
>=20
> And how/why did the input to the poll apparently change? That looks
> suspicious too. Might be some odd strace artifact, but whatever.
>=20
> So I'm contacting you because that fd=3D3 is a socket (I didn't check
> details), and because anything I find in the git logs that discusses
> "poll" seems to be network-related. So I'm wondering it this rings an=
y
> bells, because bisecting this is going to be painful as hell (since I
> have to carefully work around all the _other_ problems I've bisected
> on that machine while doing so).
>=20

Do you know the type of socket ? UNIX or INET ?

You could try a revert of 2c6607c611cb7bf0a6750bcea3
(net: add POLLPRI to sock_def_readable())

But I dont understand how it could hurt...
