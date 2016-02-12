From: Josh Poimboeuf <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 00/33] Compile-time stack metadata validation
Date: Fri, 12 Feb 2016 12:34:00 -0600
Message-ID: <20160212183400.GC29004@treble.redhat.com>
References: <cover.1453405861.git.jpoimboe@redhat.com>
 <56BDB5A8.9030006@suse.cz>
 <20160212144543.GA29004@treble.redhat.com>
 <20160212171037.GV6357@twins.programming.kicks-ass.net>
 <20160212183206.GB29004@treble.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
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
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160212183206.GB29004-8wJ5/zUtDR0XGNroddHbYwC/G2K4zDHf@public.gmane.org>
Sender: linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 12, 2016 at 12:32:06PM -0600, Josh Poimboeuf wrote:
> On Fri, Feb 12, 2016 at 06:10:37PM +0100, Peter Zijlstra wrote:
> > On Fri, Feb 12, 2016 at 08:45:43AM -0600, Josh Poimboeuf wrote:
> > > On Fri, Feb 12, 2016 at 11:36:24AM +0100, Jiri Slaby wrote:
> > > 
> > > This seems like a real frame pointer bug caused by the following line in
> > > arch/x86/include/asm/preempt.h:
> > > 
> > >   # define __preempt_schedule() asm ("call ___preempt_schedule")
> > 
> > The purpose there is that:
> > 
> > 	preempt_enable();
> > 
> > turns into:
> > 
> > 	decl	__percpu_prefix:__preempt_count
> > 	jnz	1f:
> > 	call	___preempt_schedule
> > 1:
> > 
> > See arch/x86/include/asm/preempt.h:__preempt_count_dec_and_test()
> 
> Sorry, I'm kind of confused.  Do you mean that's what preempt_enable()
> would turn into *without* the above define?
> 
> What I actually see in the listing is:
> 
>  	decl	__percpu_prefix:__preempt_count
>  	je	1f:
> 	....
>  1:
>  	call	___preempt_schedule
> 
> So it puts the "call ___preempt_schedule" in the slow path.
> 
> I also don't see how that would be related to the use of the asm
> statement in the __preempt_schedule() macro.  Doesn't the use of
> unlikely() in preempt_enable() put the call in the slow path?
> 
>   #define preempt_enable() \
>   do { \
> 	  barrier(); \
> 	  if (unlikely(preempt_count_dec_and_test())) \
> 		  preempt_schedule(); \
>   } while (0)
> 
> Also, why is the thunk needed?  Any reason why preempt_enable() can't be
> called directly from C?

Sorry, s/preempt_enable/preempt_schedule/ on that last sentence.

-- 
Josh
--
To unsubscribe from this list: send the line "unsubscribe linux-watchdog" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
