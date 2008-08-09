From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- RCU problem
Date: Sat, 9 Aug 2008 15:35:48 -0700 (PDT)
Message-ID: <630464.55583.qm@web82105.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
	linux-kernel@vger.kernel.org, Yinghai Lu <yhlu.kernel@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82105.mail.mud.yahoo.com ([209.191.84.218]:42471 "HELO
	web82105.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752653AbYHIWft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2008 18:35:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK, sorry for several hours of delay, but I had to work this
morning and just got home.




> > I am completely ignorant about how the kernel works, so any guesses I have
> > are probably worthless... but I'll throw some out anyway:
> > 
> > 1.  Maybe HPET is used (if present) for timing by RCU, so disabling it
> > forces RCU to work differently.  (Pure guess here:  I know nothing about
> > RCU, and haven't even tried looking at its code.)
> 
> RCU doesn't use HPET directly.  Most of its time-dependent behavior
> comes from its being invoked from the scheduling-clock interrupt.

  OK.  It was just a guess, anyway, but in my weak attempts to apply logic
to the problem I thought:  a locking issue would not go away merely by
disabling HPET, but if HPET touches the inner workings of RCU (or something
on which RCU depends) then it would make sense that disabling HPET causes
RCU to behave differently.
  I was just brainstorming, though....


> > 2.  Maybe my hardware is broken.  We need see one initcall return that
> > report over 280,000 msecs... when the entire boot->freeze time was about
> > 3 secs.  On the other hand, 2.6.25 (and before) work just fine with HPET
> > enabled.
> 
> For CONFIG_CLASSIC_RCU and !CONFIG_PREEMPT, in-kernel infinite spin loops
> will cause synchronize_rcu() to hang.  For other RCU configurations,
> spinning with interrupts disabled will result in similar hangs.  Invoking
> synchronize_rcu() very early in boot (before rcu_init() has been called)
> will of course also hang.
> 
> Could you please let me know whether your config has CONFIG_CLASSIC_RCU
> or CONFIG_PREEMPT_RCU?

[My apologies for the poor writing above.  The sentence "We need see one 
initcall return that report over 280,000 msecs..." was supposed to say
"We *DID* see one initcall return that *reported* over 280,000 msecs..."
In other words, something funky is going on with this machine's timers
in the crashing kernels.]

OK, I don't believe Paul was here for the beginning of this thread on
Monday, so before supplying the info requested I need to provide some
context on my situation.  I have one machine ("desktop") which works fine
with 2.6.2[67] kernels, with mboard = "Gigabyte GA-M59SLI-S5"; and I have
two machines ("fileserver", "webserver") on which 2.6.2[67] kernels freeze,
both with mboard = "ECS AMD690GM-M2".  I also am interested in getting the
Debian stock kernel working for their upcoming stable release, as well as
getting my own custom kernels working again.

First, here is the .config info for the Debian stock kernel called
"linux-image-2.6.26-1-amd64":
====================
$ egrep 'HPET|RCU|PREEMPT' config-2.6.26-1-amd64
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_CLASSIC_RCU=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
# CONFIG_RCU_TORTURE_TEST is not set
====================
This kernel freezes on webserver/fileserver, but runs fine on desktop.  (The
binary is identical, having moved it from desktop to the others via NFS instead
of downloading a separate instance from the Debian repositories.)

Here is info from the custom .config for my FREEZING fileserver machine, which
is not the same as the desktop, and not the same as Debian stock:
====================
$ egrep 'HPET|RCU|PREEMPT' config-2.6.26-2s11950.080804.fileserver.uvesafb
CONFIG_CLASSIC_RCU=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_HPET=y
CONFIG_HPET_RTC_IRQ=y
CONFIG_HPET_MMAP=y
====================
This was derived from the working .config for 2.6.25 on fileserver:
====================
$ egrep 'HPET|RCU|PREEMPT' config-2.6.25-7.080720.fileserver.uvesafb
CONFIG_CLASSIC_RCU=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_HPET=y
# CONFIG_HPET_RTC_IRQ is not set
CONFIG_HPET_MMAP=y
====================

After reading Paul's email, but before replying, I applied the changes
to PREEMPT and PREEMPT_RCU and built 2.6.27-rc2 from my git tree on
fileserver.  This kernel FREEZES on fileserver, like the custom and
Debian stock 2.6.26 kernels mentioned above:
====================
$ egrep 'HPET|RCU|PREEMPT' config-2.6.27-rc2.080809.preempt+rcu
# CONFIG_CLASSIC_RCU is not set
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_RCU=y
CONFIG_RCU_TRACE=y
CONFIG_HPET=y
CONFIG_HPET_RTC_IRQ=y
CONFIG_HPET_MMAP=y
# CONFIG_PREEMPT_TRACER is not set
====================

Here is info from the custom .config for my WORKING desktop machine, which
is not the same as fileserver/webserver, and not the same as Debian stock:
====================
$ egrep 'HPET|RCU|PREEMPT' config-2.6.26-1.080801.desktop.uvesafb
CONFIG_CLASSIC_RCU=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_HPET=y
CONFIG_HPET_RTC_IRQ=y
CONFIG_HPET_MMAP=y
====================

(My custom configurations originated with the Debian stock config, but I
disabled drivers and features irrelevant for my hardware, then tweaked
each .config according to each machine's specific hardware and usage.
All machines work fine using my custom configs for 2.6.25 kernels and
earlier.)


> > 3. I was able to find the commit that introduced the freeze
> > (3def3d6ddf43dbe20c00c3cbc38dfacc8586998f), so there has to be a connection
> > between that commit and the RCU problem.  Is it possible that a prexisting
> > error or oversight in the code was merely exposed by that commit?  (And 
> > only on certain hardware?)  Or does that code itself contain the error?
> 
> Thank you for finding the commit -- should be quite helpful!!!
> 
> A quick look reveals what appears to be reader-writer locking rather
> than RCU.  It does run in early boot before rcu_init(), so if it managed
> to call synchronize_rcu() somehow you indeed would see a hang.  I do
> not see such a call, but then again, I don't know this code much at all.
> 
> This is the second time in as many days that motivated RCU's working
> correctly before rcu_init()...  Hmmm...

Again, I think Paul was not here for the previous messages in this thread.  A
bit of recap may be in order:

The commit that first causes the freeze (and I assume that no commits since
would also cause a freeze, but that is unknown at this point) touches 3
files:

arch/x86/kernel/e820_64.c:  Here, the algorithm was altered to remove
several calls to a function called request_resource(<args>), replacing them
with a single call to insert_resource(<args>).  I have no idea whether this
change is problematic, by I observe that "request" sounds read-only, while
"insert" implies read-write behavior.  (NB: this file no longer exists, and
its contents have been merged into 'e820.c'.)

arch/x86/kernel/setup_64.c:  Here, several calls of insert_resource(<args>)
are added in 2 functions.

include/asm-x86/e820_64.h:  Here, a function prototype is modified to reflect
changes made in 'e820_64.c'.


Booting the 2.6.26 kernels on fileserver with "debug initcall_debug" reveals
that the last function called before the freeze is called "inet_init()".
(The inet_init() function itself is not important here; one desperate 
experiment I tried, disabling most of the kernel... including CONFIG_NET...
caused the freeze to occur in pci_init() instead.)  The inet_init() function
is located in net/ipv4/af_inet.c, and freezes in a loop which calls
inet_register_protosw(<arg>):

===== BEGIN CODE EXCERPT ========
    /* Register the socket-side information for inet_create. */
    for (r = &inetsw[0]; r < &inetsw[SOCK_MAX]; ++r)
        INIT_LIST_HEAD(r);

    for (q = inetsw_array; q < &inetsw_array[INETSW_ARRAY_LEN]; ++q)
        inet_register_protosw(q);
===== END EXCERPT ========

The inet_register_protosw(<arg>) function calls list_add_rcu(<args>) in a
block of code enclosed between spin_lock_bh(<arg>) and spin_unlock_bh(<arg>).
Again, I don't know what I'm doing, but it looks like this is where
inet_init() touchs RCU features.  Just before inet_register_protosw() hits
"return;" it calls, synchronize_net(); this is a tiny function, which calls
might_sleep() and synchronize_rcu().

At synchronize_rcu(), the freeze occurs.  It occurs on the first iteration
of inet_register_protosw(<arg>) as well.

To quote Daffy Duck:  "Something's amiss here...."  I lack the knowledge
and skills to know whether commit 3def3d... is really to blame, or whether
the changes it made simply revealed breakage in the other code which was
already present.  Indeed, none of you seem to be having any problem at all;
nor am I, on my "desktop" machine!


> > If any has any test code I can run to detect massive HPET breakage on
> > these motherboards, I'll be glad to do so.  Or any other experimental
> > code changes, for that matter.
> 
> If you can answer my CONFIG_CLASSIC_RCU vs. CONFIG_PREEMPT_RCU question
> above, I should be able to provide you a diagnostic patch that would say
> which CPU RCU was waiting on.  At least assuming that at least one CPU
> was still taking the scheduling-clock interrupt, that is.  ;-)

[More poor grammar apologies:  "If any has any test code..." ==> 
"If *anyone has any test code..."]

Thank you for the help.  This problem is frustrating, but incredibly
interesting to me.  I have never had this sort of problem with any previous
kernel, so I have never had an opportunity to play bug-catcher before.  By
pursuing the matter this far, I have learned elementary usage of 'git', I
have had a chance to peek at the kernel source code itself, and have even
successfully inserted code (only harmless printk()'s, though) and built the
modified kernel without errors afterward!  Without this regression, I would
have had none of this fun!

A few closing comments, then:

1.  I don't think the PREEMPT options in .config are to blame.  The Debian
stock 2.6.26 kernel runs on "desktop", but freezes on "fileserver".  That
makes it look like a hardware issue, but 2.6.25 ran fine.  [init_headache()]

2.  Commit 3def3d... draws the line between 2.6.25 working on "fileserver"
and pre-2.6.26 not working on "fileserver".  The changes in e820.c seem to
modify a function called e820_reserve_resources() from requesting resources
to inserting resources.  (The changes in setup.c don't affect me, since the
additional call of insert_resource() is in a block depending on CONFIG_KEXEC,
which is disable in my custom kernels.)  Something about this commit causes
inet_init() -- which calls inet_register_protosw(), which calls 
synchronize_net(), which calls synchronize_rcu() -- to freeze.
[init_migraine()]

3.  Whatever the cause -- whether the commit is doing something wrong, or
whether it just exposed something else that wasn't right to begin with --
the problem can just be made to go away by using "hpet=disabled" as a boot
parameter.  [init_apoplexy()]

4.  The problem seems to only manifest itself on an ECS AMD690GM-M2
motherboard, since of the thousands of users of Debian Sid I am the only
one reporting a problem on the Debian BTS, and no one else on the LKML is
experiencing it either.  [init_fatal_aneurism()]

However, even though I am the only one plagued by this problem, it is clear
that this hardware ran 2.6.25 just fine.  Maybe the full extent of the
problem is yet to be seen, since the vast majority of Linux users run
distributions with older kernels.  So, I'm viewing this as a chance for
me to finally be able to contribute, until one of 3 things is discovered:
the problem is my fault, the problem is my hardware's fault, or the problem
is a bug in the kernel.


Thanks Paul (and Peter and Yinghai),
Dave W.
