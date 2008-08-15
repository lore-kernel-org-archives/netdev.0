From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- NMI watchdog, interesting results
Date: Fri, 15 Aug 2008 15:11:09 -0700 (PDT)
Message-ID: <510360.16522.qm@web82105.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yinghai Lu <yhlu.kernel@gmail.com>, linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82105.mail.mud.yahoo.com ([209.191.84.218]:27430 "HELO
	web82105.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754554AbYHOWLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 18:11:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


OK, when I got home from work I tried NMI watchdog.  


> i'm still wondering whether we could try to figure out something about 
> the nature of the hard lockup itself.
>
> Have you tried to activate the NMI watchdog? It _usually_ works fine if 
> you use a boot option along the lines of:
>
>   "lapic nmi_watchdog=2 idle=poll"

Responding to this for a second time:  be advised that I am an end user,
not a developer.  I didn't even know the NMI watchdog existed!  When
developing my custom .config for the first time (~Feb 2007), I did read
quite a bit of Documentation/*, but to be honest it mostly went over my
head.  Since then, I mostly have been only reading kernel documentation 
when presented with new features during 'make oldconfig'.

If there are other obvious tricks like "NMI watchdog" that should be 
applied, please do NOT assume that I know about them.  As Yinghai 
discovered, I did not have the config settings he assumed I did (e.g.,
CONFIG_KEXEC).


> The best test would be to first boot the broken kernel with also 
> hpet=disable and the above options, and check in /proc/interrupts 
> whether the NMI count is increasing. If the NMI watchdog is working, you 
> should see a steady trickle of NMI irqs:
>
> rhea:~> while sleep 1; do grep NMI /proc/interrupts ; done

So, I ran 'git remote update' and checked out tip/master.  The kernel built
fine.  Here's some relevant info:

===== BEGIN INFO ==============
$ git show |head
commit 8b04fd7aeda34d6957f5576f175ec0eafc69ecd8
Author: Ingo Molnar <mingo@elte.hu>
Date:   Fri Aug 15 20:01:49 2008 +0200

    Revert "rcu: classic RCU locking and memory-barrier cleanups"
    
    This reverts commit 1f7b94cd3d564901f9e04a8bc5832ae7bfd690a0.
    
    lockdep splat.

$ egrep 'HPET|RTC|RCU|KEXEC|DUMP' .config
CONFIG_CLASSIC_RCU=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
# CONFIG_KEXEC is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_RTC=m
# CONFIG_GEN_RTC is not set
CONFIG_HPET=y
CONFIG_HPET_RTC_IRQ=y
CONFIG_HPET_MMAP=y
CONFIG_SND_RTCTIMER=m
CONFIG_SND_SEQ_RTCTIMER_DEFAULT=y
# CONFIG_RTC_CLASS is not set
CONFIG_RCU_CPU_STALL=y
===== END INFO ==============

Keeping my fingers crossed, I rebooted and ran the new kernel with only
"debug initcall_debug".  No luck:  still locks up (as expected).

Next I rebooted, adding "hpet=disable lapic nmi_watchdog=2 idle=poll".  Because
of disabling HPET, it booted just fine and gave me the login prompt.  Looks
like NMI is working, too:

fileserver:~# while sleep 1; do grep NMI /proc/interrupts; done
NMI:        204        178   Non-maskable interrupts
NMI:        205        179   Non-maskable interrupts
NMI:        205        179   Non-maskable interrupts
NMI:        205        179   Non-maskable interrupts
NMI:        206        180   Non-maskable interrupts
NMI:        206        180   Non-maskable interrupts
NMI:        207        181   Non-maskable interrupts
NMI:        207        181   Non-maskable interrupts
NMI:        207        181   Non-maskable interrupts
NMI:        208        182   Non-maskable interrupts
...


> So, in the ideal situation, your test of the NMI watchdog will show a 
> steady trickle of watchdog NMI. Then i'd suggest to remove the 
> hpet=disable, to provoke the lockup. Hopefully it occurs, _and_ after 
> the hard lockup has happened, you should see a nice stack backtrace 
> printed out by the NMI watchdog. That gives us the exact location of 
> lockup.

Then I rebooted, using "lapic nmi_watchdog=2 idle=poll debug initcall_debug".
It locked at the traditional location, with no additional output and no
backtrace from the watchdog.  (Bummer!)


> > Quick question: a quick browse of 'Documentation/nmi_watchdog.txt' 
> > suggests that I should use "nmi_watchdog=1", since I have SMP (CPU = 
> > Athlon 64 X2, with CONFIG_SMP=y).  Should I follow your suggestion 
> > later, or follow the recommendation of the 'nmi_watchdog.txt' doc?
> 
> you could try both, starting with nmi_watchdog=2 - and trying 
> nmi_watchdog=1 if that doesnt work. The problem with nmi_watchdog=1 is 
> that it disables high-res timers. (because it has to - it piggy-backs on 
> the back of a periodic timer interrupt)


As requested, I tried with the other value for "nmi_watchdog" --
"lapic nmi_watchdog=1 idle=poll debug initcall_debug".  I got my
hopes up as it passed the usual lockup point (inet_init) and actually
initialized UVESA FB.  It looked like it would reach the login prompt!...
but no.  :-(

It locked up _after_ returning from rtc_init().  Last line of output:

initcall rtc_init+0x0/0x101 [rtc] returned 0 after 0 msecs

I went looking to find what code runs rtc_init(), in order to find out
what runs after that.  But it doesn't seem to be called from inside a 
function.  Instead, I found 

module_init (rtc_init)

in 'drivers/char/rtc.c'.  I tried to discover what runs these *init functions,
and in which order, but gave up after about 10 minutes... and started writing
this post.  Someone on LKML will have to help me figure out what is supposed
to happen immediately after rtc_init() returns.  The next "initcall" message
never appeared!


> One theory is that the changed resource allocations are buggy in certain 
> circumstances and cause us to stomp over key kernel data structures. We 
> could for example overwrite a networking lock - that's why you lock up 
> in the networking code. hpet=disable deactivates those resource 
> allocations and works around the symptoms of the bug.

At the risk of sounding like an overconfident newbie, that has been my
hypothesis all along.  My reasoning was:

A.  The commits by Yinghai which cause the lockups make changes involving
the request_resource() and insert_resource() functions (i.e., "key kernel 
data structures").

B.  If Yinghai's commits were really broken, then the kernel would lock
on all 3 of my machines, instead of only the 2 with the same motherboard
(not to mention the hardware of everyone on LKML, all of which works fine
with those commits).


I think we can now be certain that the problem is not really in those
commits.  It could be an error in insert_resource() that can only be
triggered on rare hardware, but my money is on the notion that the
problem was already present -- and Yinghai's commits merely exposed it,
and only under "certain circumstances" (my hardware).

My sleep got messed up last night, so I will probably catch some ZZZZ's
before continuing.  Mike Galbraith had the idea that the changes in the
commit that first causes the lock can be applied to an earlier kernel 
revision WITHOUT causing the lock; if so, bisection would reveal that
commit.  (I just don't want to fall asleep at the keyboard while
bisecting...  ;)


Thanks all... especially Ingo and Mike,
Dave W.
