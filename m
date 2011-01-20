From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [GIT] Networking
Date: Thu, 20 Jan 2011 22:28:00 +0100
Message-ID: <201101202228.00400.rjw@sisk.pl>
References: <20110119.180418.216749267.davem@davemloft.net> <AANLkTin32jUnBtHF-EAkSMnFQM6cTbn-G3NZQJ3xjTWU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:35083 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754887Ab1ATV2c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jan 2011 16:28:32 -0500
In-Reply-To: <AANLkTin32jUnBtHF-EAkSMnFQM6cTbn-G3NZQJ3xjTWU@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, January 20, 2011, Linus Torvalds wrote:
> On Wed, Jan 19, 2011 at 6:04 PM, David Miller <davem@davemloft.net> wrote:
> >
> > 1) Revert a netlink flag sanity check that is causing regressions in
> >   existing applications.
> ...
> 
> This is a long-shot, but I thought I'd ask before I start trying to
> bisect the fourth independent suspend/resume related issue in this
> merge window..
> 
> When I suspend/resume while logged in by closing the lid on my laptop
> on FC14, it causes the gnome-screensaver-dialog to start up. So far so
> fine, that's what I want, and it all works fin in 2.6.37.
> 
> But in current -git (and in -rc8, so it's not changed by your latest
> pull request), gnome-screensaver-dialog gets stuck after I type in my
> password, making the box basically useless.
> 
> So I straced it over the network, and if I attach _when_ it is already
> stuck, it immediately becomes unstuck.  But if I attach to it before
> typing my password, I can see the hang in strace, and it looks like
> this:
> 
>   ...
>   read(3, 0x9806500, 4096)                = -1 EAGAIN (Resource
> temporarily unavailable)
>   poll([{fd=4, events=POLLIN}, {fd=3, events=POLLIN}, {fd=12,
> events=POLLIN|POLLPRI}, {fd=14, events=POLLIN|POLLPRI}, {fd=9,
> events=POLLIN|POLLPRI}, {fd=10, events=POLLIN|POLLPRI}, {fd=15,
> events=POLLIN}, {fd=16, events=POLLIN}, {fd=17, events=0}, {fd=19,
> events=POLLIN}], 10, -1) = ? ERESTART_RESTARTBLOCK (To be restarted)
>   restart_syscall(
> 
> and that's it - it's now hung. So why did it work when I straced it
> while hung? And why is it doing that ERESTART_RESTARTBLOCK in the
> first place, I'm not seeing any signals there?
> 
> So I tried sending it a useless signal, which will re-animate the
> strace, and now I get:
> 
>   restart_syscall(<... resuming interrupted call ...>) = 1
>   --- SIGWINCH (Window changed) @ 0 (0) ---
>   poll([{fd=3, events=POLLIN|POLLOUT}], 1, -1) = 1 ([{fd=3, revents=POLLOUT}])
> 
> Whee. That signal got it started again, and the poll finished immediately.
> 
> And how/why did the input to the poll apparently change? That looks
> suspicious too. Might be some odd strace artifact, but whatever.
> 
> So I'm contacting you because that fd=3 is a socket (I didn't check
> details), and because anything I find in the git logs that discusses
> "poll" seems to be network-related. So I'm wondering it this rings any
> bells, because bisecting this is going to be painful as hell (since I
> have to carefully work around all the _other_ problems I've bisected
> on that machine while doing so).

This is a long shot too, but perhaps it's related to

8cfe400 Freezer: Fix a race during freezing of TASK_STOPPED tasks

(adding Tejun to the CC just in case).

Rafael
