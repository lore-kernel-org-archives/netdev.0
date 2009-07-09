From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] netpoll: Fix carrier detection for drivers that are
 using phylib
Date: Thu, 09 Jul 2009 08:26:17 -0500
Message-ID: <1247145977.21295.899.camel@calx>
References: <20090707235812.GA12824@oksana.dev.rtsoft.ru>
	 <20090708005000.GA12380@redhat.com> <1247034263.9777.24.camel@twins>
	 <alpine.LFD.2.01.0907080907210.3210@localhost.localdomain>
	 <20090708141024.f8b581c5.akpm@linux-foundation.org>
	 <20090708213331.GA9346@oksana.dev.rtsoft.ru>
	 <20090708144744.5555b88d.akpm@linux-foundation.org>
	 <20090708222003.GA12318@oksana.dev.rtsoft.ru>
	 <alpine.LFD.2.01.0907081701050.3352@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Anton Vorontsov <avorontsov@ru.mvista.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	a.p.zijlstra@chello.nl, oleg@redhat.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:58385 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757483AbZGIN3g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2009 09:29:36 -0400
In-Reply-To: <alpine.LFD.2.01.0907081701050.3352@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-07-08 at 17:01 -0700, Linus Torvalds wrote:
> 
> On Thu, 9 Jul 2009, Anton Vorontsov wrote:
> > 
> > The netpoll code is using msleep() just a few lines below cond_resched(),
> > so we won't make things worse. ;-)
> 
> Yeah. That function is definitely sleeping. It does things like 
> kmalloc(GFP_KERNEL), rtnl_lock() and synchronize_rcu() etc too, so an 
> added msleep() is the least of our problems.
> 
> Afaik, it's called from a bog-standard "module_init()", which happens late 
> enough that everything works.
> 
> In fact, I wonder if we should set SYSTEM_RUNNING much earlier - _before_ 
> doing the whole "do_initcalls()".

Well there are two ways of consistently defining SYSTEM_RUNNING:

a) define it with reference to the well-understood notion of booting vs
running and don't switch it until handing off to init

b) define it with reference to its usage by an arbitrary user like
cond_resched()

In the latter case, we obviously need to move it to the earliest point
that scheduling is possible. But there are a number of things like 

http://lxr.linux.no/linux+v2.6.30/kernel/printk.c#L228

that assume the definition is actually (a). We're currently within a
couple lines of a strict definition of (a) already, so I actually think
cond_resched() is just wrong (and we already know it broke a
previously-working user). It should perhaps be using another private
flag that gets set as soon as scheduling is up and running.

But I'd actually go further and say that it's unfortunate to be checking
extra flags in such an important inline, especially since the check is
false for all but the first couple seconds of run time. Seems like we
could avoid adding an extra check by artificially elevating the preempt
count in early boot (or at compile time) then dropping it when
scheduling becomes available.

-- 
http://selenic.com : development and support for Mercurial and Linux


