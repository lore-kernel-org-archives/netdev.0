From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH 00/33] Compile-time stack metadata validation
Date: Mon, 15 Feb 2016 17:49:52 +0100
Message-ID: <20160215164952.GL6357@twins.programming.kicks-ass.net>
References: <cover.1453405861.git.jpoimboe@redhat.com>
 <56BDB5A8.9030006@suse.cz>
 <20160212144543.GA29004@treble.redhat.com>
 <20160212171037.GV6357@twins.programming.kicks-ass.net>
 <20160212183206.GB29004@treble.redhat.com>
 <20160212201011.GW6357@twins.programming.kicks-ass.net>
 <20160215163134.GA20585@treble.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, live-patching-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Michal Marek <mmarek-AlSwsSmVLrQ@public.gmane.org>,
	Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>,
	Pedro Alves <palves-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Namhyung Kim <namhyung-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Bernd Petrovitsch <bernd-JY8rjfDgnXcb9sJ47jD7nuTv7YV0F9Eg@public.gmane.org>,
	Chris J Arges <chris.j.arges-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	David Vrabel <david.vrabel-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>,
	Borislav Petkov <bp-l3A5Bk7waGM@public.gmane.org>,
	Konrad Rzeszutek Wilk <konrad.wilk-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Boris Ostrovsky <boris.ostrovsky-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Jeremy Fitzhardinge <jeremy-TSDbQ3PG+2Y@public.gmane.org>,
	Chris Wright <chrisw-69jw2NvuJkxg9hUCZPvPmw@public.gmane.org>,
To: Josh Poimboeuf <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160215163134.GA20585-8wJ5/zUtDR0XGNroddHbYwC/G2K4zDHf@public.gmane.org>
Sender: linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 15, 2016 at 10:31:34AM -0600, Josh Poimboeuf wrote:
> On Fri, Feb 12, 2016 at 09:10:11PM +0100, Peter Zijlstra wrote:
> > On Fri, Feb 12, 2016 at 12:32:06PM -0600, Josh Poimboeuf wrote:
> > > What I actually see in the listing is:
> > > 
> > >  	decl	__percpu_prefix:__preempt_count
> > >  	je	1f:
> > > 	....
> > >  1:
> > >  	call	___preempt_schedule
> > > 
> > > So it puts the "call ___preempt_schedule" in the slow path.
> > 
> > Ah yes indeed. Same difference though.
> > 
> > > I also don't see how that would be related to the use of the asm
> > > statement in the __preempt_schedule() macro.  Doesn't the use of
> > > unlikely() in preempt_enable() put the call in the slow path?
> > 
> > Sadly no, unlikely() and asm_goto don't work well together. But the slow
> > path or not isn't the reason we do the asm call thing.
> > 
> > >   #define preempt_enable() \
> > >   do { \
> > > 	  barrier(); \
> > > 	  if (unlikely(preempt_count_dec_and_test())) \
> > > 		  preempt_schedule(); \
> > >   } while (0)
> > > 
> > > Also, why is the thunk needed?  Any reason why preempt_enable() can't be
> > > called directly from C?
> > 
> > That would make the call-site save registers and increase the size of
> > every preempt_enable(). By using the thunk we can do callee saved
> > registers and avoid blowing up the call site.
> 
> So is the goal to optimize for size?  

General performance impact of preempt_enable().

> If I replace the calls to
> __preempt_schedule[_notrace]() with real C calls and remove the thunks,
> it only adds about 2k to vmlinux.

That's less than I had expected, but probably still worth it.

And is that added text purely in the slow path? We really want to avoid
putting any more register pressure on the preempt_enable() call sites.
The single memop and Jcc is about as fast we can get and we spend quite
a bit of effort getting there.

> There are two ways to fix the warnings:
> 
> 1. get rid of the thunks and call the C functions directly; or
> 
> 2. add the stack pointer to the asm() statement output operand list to
> ensure a stack frame gets created in the caller function before the
> call.  (Note this still allows the thunks to do callee saved registers.)
> 
> I like #1 better, but maybe I'm still missing the point of the thunks.

Ingo, Linus?
--
To unsubscribe from this list: send the line "unsubscribe linux-watchdog" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
