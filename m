From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH 5/8] [RFC] qlge: Add main source module qlge_main.c
Date: Mon, 15 Sep 2008 11:28:01 -0700
Message-ID: <20080915182801.GC23939@susedev.qlogic.org>
References: <20080910205813.GA13266@susedev.qlogic.org> <12210803433594-git-send-email-ron.mercer@qlogic.com> <48C8D937.5020708@marian.de> <20080912005837.GB23939@susedev.qlogic.org> <48CA2528.2010201@marian.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, linux-driver@qlogic.com
To: Franco Fichtner <franco@marian.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:28086 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752697AbYIOS3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 14:29:03 -0400
Content-Disposition: inline
In-Reply-To: <48CA2528.2010201@marian.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Franco,

I have cleaned up a lot of the code per your suggestions in this thread and will
do another submission this afternoon.
Regarding the delay/sleep, I've changed from mdelay to udelay and reduced the loop
into the 10s of microseconds instead of the hundreds of milliseconds.
I found out the milliseconds was intended for an emulated test
environment and not for the silicon.  Thanks again for bringing this to
my attention.

Regards,
Ron Mercer


On Fri, Sep 12, 2008 at 10:15:36AM +0200, Franco Fichtner wrote:
> Hi Ron,
> 
> Thanks for the clarification. 4000 lines of code are just too much to
> grasp at the first glance. :)
> 
> >Regarding ql_wait_idx_reg() and ql_wait_addr_reg() they provide waiting
> >while gaining access for read/writes to/from a secondary set of
> >registers.
> 
> These registers are once per hardware, right? Then your spinlocking
> would do nothing on single CPU systems, because it won't get into the
> binaries. Meaning: your registers are NOT protected the way you would
> have hoped. And even with SMP systems... if another CPU hits a locked
> spinlock it does nothing but wait, quite synchronously to your mdelay()
> loop. So both scenarios are rather suboptimal. If that's how things are,
> you're better off using a semaphore.
> 
> On non-SMP systems, you're gonna put another access on the waiting list
> by using a semaphore, which in return will give you time to finish your
> operations on the registers and free the semaphore. And, last but not
> least, SMP systems will do work they otherwise would not be able to do.
> 
> There is just the slight problem of ql_wait_idx_reg() and
> ql_wait_addr_reg() being executed from interrupt context? If that is the
> case, then you can't use the standard semaphores, because sleeping isn't
> allowed. I do hope that is not the case...
> 
> >To my understanding, you can't sleep while holding a
> >spinlock.  I tried this before and saw massive warnings.  I have
> >"Spinlock debugging: sleep-inside-spinlock checking" turned on in my
> >kernel and perhaps that's why I saw them.
> 
> You'd normally use spinlocks in interrupt context where you just have to
> make sure no other CPU mangles with your variables or hardware registers
> the fastest way possible. You don't keep a spinlock forever, not even
> for the course of a few function calls, which will make the code harder
> to read, thus harder to understand, and thus harder to debug.
> 
> The warning messages are right, but (I think) they are intended to avoid 
> deadlocks as early as possible. Though, with msleep() I don't think
> you'll get into any more serious problems than before, because unless 
> the Kernel is really not doing what it should, you should always get
> back to your loop. Using schedule() and wait queues in spinlocked 
> scenarios is a whole other thing. (Anyone, please correct me if I'm wrong.)
> 
> >At that point I changed from msleep to mdelay.
> >After reviewing your comments I've reduced and standardized the mdelay
> >wait to 5ms with a count of 50.
> 
> It may help introduce defines to get rid of magic numbers inside the
> code as well. Something like:
> 
> #define QLGE_TIMEOUT_COUNT	50
> #define QLGE_TIMEOUT_DELAY	5
> 
> That will help maintaining code and makes it more easily readable (and
> consistent as a bonus... less lines to update).
> 
> >These secondary registers are
> >accessed only during open(), reset(), and a few
> >netdev-API like set_multi and add_vlan_vid.
> 
> Okay, I see. But still, I get the vibe that this is already a bit too
> much to justify keeping the current way of locking in the code. Sooner
> or later someone else will complain about this. ;)
> 
> 
> Franco
