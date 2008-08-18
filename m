From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- success reverting for 2.6.26, need advice
Date: Mon, 18 Aug 2008 05:50:04 -0700 (PDT)
Message-ID: <612194.7263.qm@web82102.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82102.mail.mud.yahoo.com ([209.191.84.215]:44553 "HELO
	web82102.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752143AbYHRMuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 08:50:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


SUMMARY

1.  I succeeded in my attempt to revert 2 problem commits and get
a working 2.6.26 kernel which boots with no lockup without using
"hpet=disable".

2.  I would like to apply the commits between "v2.6.26" and
"v2.6.27-rc3", but would like advice on the best approach for doing
so.  I am not sure about the "best" approach to use, and all 3 of
the files involved were merged into others as 2.6.26 became 2.6.27-rc1.

3.  I am more interested in finding out why Yinghai's commits fail
on this hardware than I am in reverting those commits.  I still don't
think those two commits were broken, and have an interest in knowing
whether the problem lies with my hardware or some nastier issue in
the kernel waiting to spring on us all later.


REVERTING


Well, Bill Fink's idea of reverting the 2 successive commits that cause
my 2 ECS AMD690GM-M2 machines to lock up worked.  I performed these
steps on Saturday afternoon:

$ git checkout -b my-2.6.26 v2.6.26

$ git revert 3def3d6d
[manually edit conflict in arch/x86/kernel/e820_64.c]

$ git commit -a

$ git revert 1e934dda


It took about 5 minutes, and I now have my very first 2.6.26 kernel
which can boot and run perfectly without "hpet=disable".  (I am using
it now as my main kernel on the test machine, but with "notsc" to
avoid the annoying complaints about TSC being unstable.)

This is the minimum result that I wanted to achieve:  a patch for the
Debian Kernel Team, in case they are interested in having it.  Is this
something appropriate for the maintainers of stable 2.6.26.x here to 
be interested in?


HOW BEST TO APPLY CHANGES FROM 2.6.26 TO 2.6.27-rc3

I made no attempt to apply the additional commits up to the current
tip.  Somewhere between 2.6.26 and 2.6.27-rc1 the files involved
disappear, part of the process of merging x86_64 with x86_32.  Here
are the file changes to which I am referring:

arch/x86/kernel/e820_64.c  --> e820.c
arch/x86/kernel/setup_64.c --> setup.c
include/asm-x86/e820_64.h  --> e820.h

[Note: arch/x86/kernel/apic_64.c is also involved, but still exists.]

I currently have 2 branches in my local git tree, called:

master
my-2.6.26

The "master" branch is the cloned "origin/master" from when I did my
first bisection before bringing my troubles to LKML.  It is Linus' git
tree:

[remote "origin"]
    url = git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6

I also have Ingo's "tip" tree available as a remote, but currently have
no branch for it:

[remote "tip"]
    url = git://git.kernel.org/pub/scm/linux/kernel/git/tip/linux-2.6-tip.git
    fetch = +refs/heads/*:refs/remotes/tip/*

Should I be trying to preserve all of the individual commits with something
like 'git rebase' (or even 'git filter-branch'), or should I just use
'git merge' and not worry about preserving commit history.


STILL LOOKING FOR THE REAL PROBLEM

Since Yinghai's commits which I reverted above (3def3d6d... and 1e934dda...)
work fine for everyone here, including for me on one of my 3 machines, I
spent the rest of the weekend trying to extract information from kernels
experiencing the lockup.

I work as a walk-in tutor at a community college, and one of my specialties
is C++ programming.  I haven't really used C since I first learned it from
Kochan's _Programming in C_ in 1991.  I have certainly never even looked
at low-level OS code before, so I was trying to avoid looking at the code...
leaving that to the experts here.

When the revert worked on Saturday, I had a moment of relief.  Then I became
angry at the thought that those commits might simply end up reverted without
anyone ever know the reason why they won't work on my hardware.

I spent the rest of Saturday and all day Sunday reading books, documentation,
info on websites, etc.  I printed out versions of the functions involved in
the changes -- before and after the problem commits -- and came up with a
huge list of ideas for diagnostic code I could use to print info before the
kernels lock.

I have been trying those diagnostics since Sunday morning.  I still don't know
what is causing the problem, but I have been able to produce some output that
rules out certain causes and provides some information.  One big problem is
that the kernel is in 80x25 text mode when it freezes, so it is difficult to
keep things from scrolling off the top before I can even read it, much less
write it down.

However, since I know a place in the kernel code where a function is called
but never returns, I have been able to print lots of information just before
the lockup occurs.  I even have the equivalent of 'cat /proc/iomem' for a
locking kernel.

Is anyone here interested in that information?  (With or without the code used
to generate it?)  I am sure I will continue to try to solve the real problem
here, even if I have to study the entire kernel source tree for the next 2 
years!  I don't want to end up with release after release of the Linux kernel
which can only run on 2 of my machines with "hpet=disable"!


Thank all,
Dave W.
