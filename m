From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: [PATCH 00/33] Compile-time stack metadata validation
Date: Mon, 15 Feb 2016 14:01:56 -0600
Message-ID: <20160215200156.GA3018@treble.redhat.com>
References: <cover.1453405861.git.jpoimboe@redhat.com>
 <56BDB5A8.9030006@suse.cz>
 <20160212144543.GA29004@treble.redhat.com>
 <20160212171037.GV6357@twins.programming.kicks-ass.net>
 <20160212183206.GB29004@treble.redhat.com>
 <20160212201011.GW6357@twins.programming.kicks-ass.net>
 <20160215163134.GA20585@treble.redhat.com>
 <CA+55aFzoPCd_LcSx1FUuEhSBYk2KrfzXGj-Vcn39W5bz=KuZhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Alok Kataria <akataria@vmware.com>,
	Ingo Molnar <mingo@redhat.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Bernd Petrovitsch <bernd@petrovitsch.priv.at>,
	linux-watchdog@vger.kernel.org, Pedro Alves <palves@redhat.com>,
	Pavel Machek <pavel@ucw.cz>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Michal Marek <mmarek@suse.cz>,
	Namhyung Kim <namhyung@gmail.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Waiman Long <Waiman.Long@hpe.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	Jiri Slaby <jslaby@suse.cz>, kvm@vger.kernel.org,
	x86@kernel.org, Arnaldo Carvalho de Melo <acme@kernel.org>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Masami Hiramatsu <masami.hira
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFzoPCd_LcSx1FUuEhSBYk2KrfzXGj-Vcn39W5bz=KuZhA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 15, 2016 at 08:56:21AM -0800, Linus Torvalds wrote:
> On Feb 15, 2016 8:31 AM, "Josh Poimboeuf" <jpoimboe@redhat.com> wrote:
> >
> > So is the goal to optimize for size?  If I replace the calls to
> > __preempt_schedule[_notrace]() with real C calls and remove the thunks,
> > it only adds about 2k to vmlinux.
> 
> It adds nasty register pressure in some of the most critical parts of the
> kernel, and makes the asm code harder to read.
> 
> And yes, I still read the asm. For performance reasons, and when decoding
> oopses.
> 
> I realize that few other people care about generated code. That's sad.
> 
> > There are two ways to fix the warnings:
> >
> > 1. get rid of the thunks and call the C functions directly; or
> 
> No. Not until gcc learns about per-function callibg conventions (so that it
> can be marked as not clobbering registers).
> 
> > 2. add the stack pointer to the asm() statement output operand list to
> > ensure a stack frame gets created in the caller function before the
> > call.
> 
> That probably doesn't make things much worse. It probably makes least
> functions have a stack frame if they do preempt disable, but it might still
> be acceptable. Hard to say before I end up hurting this case again.

Oddly, this change (see patch below) actually seems to make things
faster in a lot of cases.  For many smaller functions it causes the
stack frame creation to get moved out of the common path and into the
unlikely path.

For example, here's the original cyc2ns_read_end():

  ffffffff8101f8c0 <cyc2ns_read_end>:
  ffffffff8101f8c0:	55                   	push   %rbp
  ffffffff8101f8c1:	48 89 e5             	mov    %rsp,%rbp
  ffffffff8101f8c4:	83 6f 10 01          	subl   $0x1,0x10(%rdi)
  ffffffff8101f8c8:	75 08                	jne    ffffffff8101f8d2 <cyc2ns_read_end+0x12>
  ffffffff8101f8ca:	65 48 89 3d e6 5a ff 	mov    %rdi,%gs:0x7eff5ae6(%rip)        # 153b8 <cyc2ns+0x38>
  ffffffff8101f8d1:	7e 
  ffffffff8101f8d2:	65 ff 0d 77 c4 fe 7e 	decl   %gs:0x7efec477(%rip)        # bd50 <__preempt_count>
  ffffffff8101f8d9:	74 02                	je     ffffffff8101f8dd <cyc2ns_read_end+0x1d>
  ffffffff8101f8db:	5d                   	pop    %rbp
  ffffffff8101f8dc:	c3                   	retq   
  ffffffff8101f8dd:	e8 1e 37 fe ff       	callq  ffffffff81003000 <___preempt_schedule>
  ffffffff8101f8e2:	5d                   	pop    %rbp
  ffffffff8101f8e3:	c3                   	retq   
  ffffffff8101f8e4:	66 66 66 2e 0f 1f 84 	data16 data16 nopw %cs:0x0(%rax,%rax,1)
  ffffffff8101f8eb:	00 00 00 00 00 

And here's the same function with the patch:

  ffffffff8101f8c0 <cyc2ns_read_end>:
  ffffffff8101f8c0:	83 6f 10 01          	subl   $0x1,0x10(%rdi)
  ffffffff8101f8c4:	75 08                	jne    ffffffff8101f8ce <cyc2ns_read_end+0xe>
  ffffffff8101f8c6:	65 48 89 3d ea 5a ff 	mov    %rdi,%gs:0x7eff5aea(%rip)        # 153b8 <cyc2ns+0x38>
  ffffffff8101f8cd:	7e 
  ffffffff8101f8ce:	65 ff 0d 7b c4 fe 7e 	decl   %gs:0x7efec47b(%rip)        # bd50 <__preempt_count>
  ffffffff8101f8d5:	74 01                	je     ffffffff8101f8d8 <cyc2ns_read_end+0x18>
  ffffffff8101f8d7:	c3                   	retq   
  ffffffff8101f8d8:	55                   	push   %rbp
  ffffffff8101f8d9:	48 89 e5             	mov    %rsp,%rbp
  ffffffff8101f8dc:	e8 1f 37 fe ff       	callq  ffffffff81003000 <___preempt_schedule>
  ffffffff8101f8e1:	5d                   	pop    %rbp
  ffffffff8101f8e2:	c3                   	retq   
  ffffffff8101f8e3:	66 66 66 66 2e 0f 1f 	data16 data16 data16 nopw %cs:0x0(%rax,%rax,1)
  ffffffff8101f8ea:	84 00 00 00 00 00 

Notice that it moved the frame pointer setup code to the unlikely
___preempt_schedule() call path.  Going through a sampling of the
differences in the asm, that's the most common change I see.

Otherwise it has no real effect on callers which already have stack
frames (though it does change the ordering of some 'mov's).

And it has the intended effect of fixing the following warnings by
ensuring these call sites have stack frames:

  stacktool: drivers/scsi/hpsa.o: hpsa_scsi_do_simple_cmd.constprop.106()+0x79: call without frame pointer save/setup
  stacktool: fs/mbcache.o: mb_cache_entry_find_first()+0x70: call without frame pointer save/setup
  stacktool: fs/mbcache.o: mb_cache_entry_find_first()+0x92: call without frame pointer save/setup
  stacktool: fs/mbcache.o: mb_cache_entry_free()+0xff: call without frame pointer save/setup
  stacktool: fs/mbcache.o: mb_cache_entry_free()+0xf5: call without frame pointer save/setup
  stacktool: fs/mbcache.o: mb_cache_entry_free()+0x11a: call without frame pointer save/setup
  stacktool: fs/mbcache.o: mb_cache_entry_get()+0x225: call without frame pointer save/setup
  stacktool: kernel/locking/percpu-rwsem.o: percpu_up_read()+0x27: call without frame pointer save/setup
  stacktool: kernel/profile.o: do_profile_hits.isra.5()+0x139: call without frame pointer save/setup
  stacktool: lib/nmi_backtrace.o: nmi_trigger_all_cpu_backtrace()+0x2b6: call without frame pointer save/setup
  stacktool: net/rds/ib_cm.o: rds_ib_cq_comp_handler_recv()+0x58: call without frame pointer save/setup
  stacktool: net/rds/ib_cm.o: rds_ib_cq_comp_handler_send()+0x58: call without frame pointer save/setup
  stacktool: net/rds/ib_recv.o: rds_ib_attempt_ack()+0xc1: call without frame pointer save/setup
  stacktool: net/rds/iw_recv.o: rds_iw_attempt_ack()+0xc1: call without frame pointer save/setup
  stacktool: net/rds/iw_recv.o: rds_iw_recv_cq_comp_handler()+0x55: call without frame pointer save/setup

So that only adds a stack frame to 15 call sites out of ~5000 calls to
___preempt_schedule[_notrace].  All the others already had stack frames.

Any idea for a good benchmark to run with the patch?

> The alternative is to just teach the tools about the magic issue of a few
> things like this.

I think that would be problematic for our goal of making stack traces of
sleeping tasks reliable.  If preempt_enable()'s caller doesn't first
create a stack frame, the caller of the caller will get skipped in the
stack trace.

---8<---

diff --git a/arch/x86/include/asm/preempt.h b/arch/x86/include/asm/preempt.h
index 01bcde8..2989aa6 100644
--- a/arch/x86/include/asm/preempt.h
+++ b/arch/x86/include/asm/preempt.h
@@ -94,10 +94,19 @@ static __always_inline bool should_resched(int preempt_offset)
 
 #ifdef CONFIG_PREEMPT
   extern asmlinkage void ___preempt_schedule(void);
-# define __preempt_schedule() asm ("call ___preempt_schedule")
+# define __preempt_schedule() \
+({ \
+	register void *__sp asm(_ASM_SP); \
+	asm volatile ("call ___preempt_schedule" : "+r"(__sp)); \
+})
+
   extern asmlinkage void preempt_schedule(void);
   extern asmlinkage void ___preempt_schedule_notrace(void);
-# define __preempt_schedule_notrace() asm ("call ___preempt_schedule_notrace")
+# define __preempt_schedule_notrace() \
+({ \
+	register void *__sp asm(_ASM_SP); \
+	asm volatile ("call ___preempt_schedule_notrace" : "+r"(__sp)); \
+})
   extern asmlinkage void preempt_schedule_notrace(void);
 #endif
 

-- 
Josh
