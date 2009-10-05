From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH RFC] isdn/capi: fix up CAPI subsystem workaround locking a bit
Date: Mon, 5 Oct 2009 23:24:07 +0200
Message-ID: <200910052324.09992.mb@bu3sch.de>
References: <20091003120657.2228911186C@xenon.ts.pxnet.com> <200910032035.21884.mb@bu3sch.de> <4AC9DBA5.1090701@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: i4ldeveloper@listserv.isdn4linux.de,
	Carsten Paeth <calle@calle.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	Karsten Keil <keil@b1-systems.de>,
	Armin Schindler <armin@melware.de>,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:36302 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754094AbZJEVY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2009 17:24:56 -0400
In-Reply-To: <4AC9DBA5.1090701@imap.cc>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 05 October 2009 13:42:29 Tilman Schmidt wrote:
> On Sat, 2009-10-03 20:35:19 +0200, Michael Buesch wrote:
> 
> >> I remember that handle_minor_send() and/or handle_minor_recv() showed up
> >> in the crash backtraces. So if you move them out of the critical
> >> section, you can as well remove the lock completely.
> >
> > here's my original mail:
> > http://lkml.indiana.edu/hypermail/linux/kernel/0605.0/0455.html
> >
> > Note the patch in that mail does _not_ fix the issue, as it turned out later.
> > Then I did the workaround-lock patch, which _did_ fix it.
> 
> Thanks for the info. So do I understand correctly that after:
> 
> commit 6aa65472d18703064898eefb5eb58f7ecd0d8912
> Author: Michael Buesch <mb@bu3sch.de>
> Date:   Mon Jun 26 00:25:30 2006 -0700
> 
>     [PATCH] CAPI crash / race condition
> 
> you were actually still seeing LIST_POISON2 Oopses in
> capiminor_del_ack(), but after:

Yeah well. The oops with LIST_POISON was with a patch that converted the
datahandle_queue to struct list_head, but without the spinlock_t ackqlock added.
Then I added the spinlock_t ackqlock and it first seemed to fix the problem. (That
is the patch from the mail).
But it did only shrink the race window, so the crash did still happen, but less often.
The crash was only "fixed" with the workaround_lock patch (but _without_ any of the
ackqueue patches applied.)

> commit 053b47ff249b9e0a634dae807f81465205e7c228
> Author: Michael Buesch <mb@bu3sch.de>
> Date:   Mon Feb 12 00:53:26 2007 -0800
> 
>     [PATCH] Workaround CAPI subsystem locking issue
> 
> they were gone? That's interesting. I'll try to wrap my mind around
> this.

Yeah, this sledgehammer lock did fix the crash while leaving the old non-list-head
queue in place (it should still be there today).

> It's unfortunate that these crashes only seem to occur with one specific
> device (FritzCard DSL) which I don't have.

I still have the device somewhere. If you want to have it, I can blow off the
dust and send it to you. If you don't want it, I'll throw it away soon.
I'd really like to send it to you to get rid of it. ;)

> Can anyone shed some light on 
> what that device is doing differently from other ISDN cards?

Well, it's a combined ISDN/DSL card, but I never used the ISDN part. So the crash
happened while transferring data over the DSL link.
The vendor driver is closed source with an open wrapper (like nvidia). It's a pretty
crappy unmaintained piece of software, but it ran stable with some patches applied
to the driver and the workaround-lock patch to the capi stack.

-- 
Greetings, Michael.
