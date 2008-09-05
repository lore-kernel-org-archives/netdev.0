From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Fwd: Packet mmap: TX RING and zero copy
Date: Fri, 5 Sep 2008 15:31:12 +0400
Message-ID: <20080905113112.GA29926@2ka.mipt.ru>
References: <7e0dd21a0809030800v5e39808bl2f22893bc8214c2a@mail.gmail.com> <20080903151340.GA7566@2ka.mipt.ru> <7e0dd21a0809030858h7fdc454dj33acc6be25a0aab@mail.gmail.com> <20080903164346.GA6729@2ka.mipt.ru> <7e0dd21a0809031330i1363c4aema9c57ef06a3d5279@mail.gmail.com> <20080903220347.GA22395@2ka.mipt.ru> <7e0dd21a0809040744q3ee65695uc33f6cc26a1fe4dd@mail.gmail.com> <20080905071754.GA25998@2ka.mipt.ru> <7e0dd21a0809050216r65b8f08fm1ad0630790a13a54@mail.gmail.com> <7e0dd21a0809050217v33ecb8fvcadd5e65118d6afe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:36189 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750705AbYIELbh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2008 07:31:37 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0809050217v33ecb8fvcadd5e65118d6afe@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johann.

On Fri, Sep 05, 2008 at 11:17:07AM +0200, Johann Baudy (johaahn@gmail.com) wrote:
> > vmsplice() can be slow, try to inject header via usual send() call, or
> > better do not use it at all for testing.
> >
> vmsplice() is short in comparison to splice()  ~ 200us !
> This was just to show you that even this vmpslice duration of 80us
> that is needed for each packet is too long to send only 1 packet.
> I really need a mechanism that allow sending of ~ 40 packets of 7200K
> in one system call to keep some cpu ressources to do other things.
> (Not spending time in kernel layers :))

Hmmm... splice()/sendfile() shuold be able to send the whole file in
single syscall. This looks like a problem in the userspace.

> > kill_fasync() also took too much time (top CPU user
> > is at bottom I suppose?), do you use SIGIO? Also vma traveling and page
> > checking is not what will be done in network code and your project, so
> > it also adds an overhead.
> 
> Between kill_fasync() sys_gettimeofday() , I thought that we returned
> to user space.
> No SIGIO. But FYI, I use PREEMPT_RT patch.

Does it also push softirq processing into threads?

> >Please try without vmsplice() at all, usual
> > splice()/sendfile() _has_ to saturate the link, otherwise we have a
> > serious problem.
> 
> I've already tried sendfile only with standard TCP/UDP socket. I've
> not saturated the link.
> Around same bitrate.

This worries me a lot: sendfile should be a single syscall which very
optimally creates network packets getting into account MTU and hardware
capabilities. I do belive it is a problem with userspace code.

-- 
	Evgeniy Polyakov
