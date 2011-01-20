From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Thu, 20 Jan 2011 13:12:52 -0800
Message-ID: <AANLkTin32jUnBtHF-EAkSMnFQM6cTbn-G3NZQJ3xjTWU@mail.gmail.com>
References: <20110119.180418.216749267.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110119.180418.216749267.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 19, 2011 at 6:04 PM, David Miller <davem@davemloft.net> wro=
te:
>
> 1) Revert a netlink flag sanity check that is causing regressions in
> =A0 existing applications.
=2E..

This is a long-shot, but I thought I'd ask before I start trying to
bisect the fourth independent suspend/resume related issue in this
merge window..

When I suspend/resume while logged in by closing the lid on my laptop
on FC14, it causes the gnome-screensaver-dialog to start up. So far so
fine, that's what I want, and it all works fin in 2.6.37.

But in current -git (and in -rc8, so it's not changed by your latest
pull request), gnome-screensaver-dialog gets stuck after I type in my
password, making the box basically useless.

So I straced it over the network, and if I attach _when_ it is already
stuck, it immediately becomes unstuck.  But if I attach to it before
typing my password, I can see the hang in strace, and it looks like
this:

  ...
  read(3, 0x9806500, 4096)                =3D -1 EAGAIN (Resource
temporarily unavailable)
  poll([{fd=3D4, events=3DPOLLIN}, {fd=3D3, events=3DPOLLIN}, {fd=3D12,
events=3DPOLLIN|POLLPRI}, {fd=3D14, events=3DPOLLIN|POLLPRI}, {fd=3D9,
events=3DPOLLIN|POLLPRI}, {fd=3D10, events=3DPOLLIN|POLLPRI}, {fd=3D15,
events=3DPOLLIN}, {fd=3D16, events=3DPOLLIN}, {fd=3D17, events=3D0}, {f=
d=3D19,
events=3DPOLLIN}], 10, -1) =3D ? ERESTART_RESTARTBLOCK (To be restarted=
)
  restart_syscall(

and that's it - it's now hung. So why did it work when I straced it
while hung? And why is it doing that ERESTART_RESTARTBLOCK in the
first place, I'm not seeing any signals there?

So I tried sending it a useless signal, which will re-animate the
strace, and now I get:

  restart_syscall(<... resuming interrupted call ...>) =3D 1
  --- SIGWINCH (Window changed) @ 0 (0) ---
  poll([{fd=3D3, events=3DPOLLIN|POLLOUT}], 1, -1) =3D 1 ([{fd=3D3, rev=
ents=3DPOLLOUT}])

Whee. That signal got it started again, and the poll finished immediate=
ly.

And how/why did the input to the poll apparently change? That looks
suspicious too. Might be some odd strace artifact, but whatever.

So I'm contacting you because that fd=3D3 is a socket (I didn't check
details), and because anything I find in the git logs that discusses
"poll" seems to be network-related. So I'm wondering it this rings any
bells, because bisecting this is going to be painful as hell (since I
have to carefully work around all the _other_ problems I've bisected
on that machine while doing so).

                           Linus
