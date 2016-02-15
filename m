From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: [PATCH 00/33] Compile-time stack metadata validation
Date: Mon, 15 Feb 2016 10:31:34 -0600
Message-ID: <20160215163134.GA20585@treble.redhat.com>
References: <cover.1453405861.git.jpoimboe@redhat.com>
 <56BDB5A8.9030006@suse.cz>
 <20160212144543.GA29004@treble.redhat.com>
 <20160212171037.GV6357@twins.programming.kicks-ass.net>
 <20160212183206.GB29004@treble.redhat.com>
 <20160212201011.GW6357@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jiri Slaby <jslaby@suse.cz>, Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	linux-kernel@vger.kernel.org, live-patching@vger.kernel.org,
	Michal Marek <mmarek@suse.cz>,
	Andy Lutomirski <luto@kernel.org>,
	Borislav Petkov <bp@alien8.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>,
	Pedro Alves <palves@redhat.com>,
	Namhyung Kim <namhyung@gmail.com>,
	Bernd Petrovitsch <bernd@petrovitsch.priv.at>,
	Chris J Arges <chris.j.arges@canonical.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Borislav Petkov <bp@suse.de>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Chris Wright <chrisw@sous-sol.org>,
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45365 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751235AbcBOQbq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2016 11:31:46 -0500
Content-Disposition: inline
In-Reply-To: <20160212201011.GW6357@twins.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 12, 2016 at 09:10:11PM +0100, Peter Zijlstra wrote:
> On Fri, Feb 12, 2016 at 12:32:06PM -0600, Josh Poimboeuf wrote:
> > What I actually see in the listing is:
> > 
> >  	decl	__percpu_prefix:__preempt_count
> >  	je	1f:
> > 	....
> >  1:
> >  	call	___preempt_schedule
> > 
> > So it puts the "call ___preempt_schedule" in the slow path.
> 
> Ah yes indeed. Same difference though.
> 
> > I also don't see how that would be related to the use of the asm
> > statement in the __preempt_schedule() macro.  Doesn't the use of
> > unlikely() in preempt_enable() put the call in the slow path?
> 
> Sadly no, unlikely() and asm_goto don't work well together. But the slow
> path or not isn't the reason we do the asm call thing.
> 
> >   #define preempt_enable() \
> >   do { \
> > 	  barrier(); \
> > 	  if (unlikely(preempt_count_dec_and_test())) \
> > 		  preempt_schedule(); \
> >   } while (0)
> > 
> > Also, why is the thunk needed?  Any reason why preempt_enable() can't be
> > called directly from C?
> 
> That would make the call-site save registers and increase the size of
> every preempt_enable(). By using the thunk we can do callee saved
> registers and avoid blowing up the call site.

So is the goal to optimize for size?  If I replace the calls to
__preempt_schedule[_notrace]() with real C calls and remove the thunks,
it only adds about 2k to vmlinux.

There are two ways to fix the warnings:

1. get rid of the thunks and call the C functions directly; or

2. add the stack pointer to the asm() statement output operand list to
ensure a stack frame gets created in the caller function before the
call.  (Note this still allows the thunks to do callee saved registers.)

I like #1 better, but maybe I'm still missing the point of the thunks.

-- 
Josh
