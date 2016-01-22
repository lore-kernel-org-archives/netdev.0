From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: [PATCH 23/33] x86/asm/bpf: Create stack frames in bpf_jit.S
Date: Fri, 22 Jan 2016 09:58:04 -0600
Message-ID: <20160122155804.GC20502@treble.redhat.com>
References: <cover.1453405861.git.jpoimboe@redhat.com>
 <fa4c41976b438b51954cb8021f06bceb1d1d66cc.1453405861.git.jpoimboe@redhat.com>
 <20160122024427.GA6000@ast-mbp.thefacebook.com>
 <20160122035531.GA20502@treble.redhat.com>
 <20160122041845.GA7175@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	linux-kernel@vger.kernel.org, live-patching@vger.kernel.org,
	Michal Marek <mmarek@suse.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@kernel.org>,
	Borislav Petkov <bp@alien8.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>,
	Pedro Alves <palves@redhat.com>,
	Namhyung Kim <namhyung@gmail.com>,
	Bernd Petrovitsch <bernd@petrovitsch.priv.at>,
	Chris J Arges <chris.j.arges@canonical.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jiri Slaby <jslaby@suse.cz>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
	daniel@iogearbox.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160122041845.GA7175@ast-mbp.thefacebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 21, 2016 at 08:18:46PM -0800, Alexei Starovoitov wrote:
> On Thu, Jan 21, 2016 at 09:55:31PM -0600, Josh Poimboeuf wrote:
> > On Thu, Jan 21, 2016 at 06:44:28PM -0800, Alexei Starovoitov wrote:
> > > On Thu, Jan 21, 2016 at 04:49:27PM -0600, Josh Poimboeuf wrote:
> > > > bpf_jit.S has several callable non-leaf functions which don't honor
> > > > CONFIG_FRAME_POINTER, which can result in bad stack traces.
> > > > 
> > > > Create a stack frame before the call instructions when
> > > > CONFIG_FRAME_POINTER is enabled.
> > > > 
> > > > Signed-off-by: Josh Poimboeuf <jpoimboe@redhat.com>
> > > > Cc: Alexei Starovoitov <ast@kernel.org>
> > > > Cc: netdev@vger.kernel.org
> > > > ---
> > > >  arch/x86/net/bpf_jit.S | 9 +++++++--
> > > >  1 file changed, 7 insertions(+), 2 deletions(-)
> > > > 
> > > > diff --git a/arch/x86/net/bpf_jit.S b/arch/x86/net/bpf_jit.S
> > > > index eb4a3bd..f2a7faf 100644
> > > > --- a/arch/x86/net/bpf_jit.S
> > > > +++ b/arch/x86/net/bpf_jit.S
> > > > @@ -8,6 +8,7 @@
> > > >   * of the License.
> > > >   */
> > > >  #include <linux/linkage.h>
> > > > +#include <asm/frame.h>
> > > >  
> > > >  /*
> > > >   * Calling convention :
> > > > @@ -65,16 +66,18 @@ FUNC(sk_load_byte_positive_offset)
> > > >  
> > > >  /* rsi contains offset and can be scratched */
> > > >  #define bpf_slow_path_common(LEN)		\
> > > > +	lea	-MAX_BPF_STACK + 32(%rbp), %rdx;\
> > > > +	FRAME_BEGIN;				\
> > > >  	mov	%rbx, %rdi; /* arg1 == skb */	\
> > > >  	push	%r9;				\
> > > >  	push	SKBDATA;			\
> > > >  /* rsi already has offset */			\
> > > >  	mov	$LEN,%ecx;	/* len */	\
> > > > -	lea	- MAX_BPF_STACK + 32(%rbp),%rdx;			\
> > > >  	call	skb_copy_bits;			\
> > > >  	test    %eax,%eax;			\
> > > >  	pop	SKBDATA;			\
> > > > -	pop	%r9;
> > > > +	pop	%r9;				\
> > > > +	FRAME_END
> > > 
> > > I'm not sure what above is doing.
> > > There is already 'push rbp; mov rbp,rsp' at the beginning of generated
> > > code and with above the stack trace will show two function at the same ip?
> > > since there were no calls between them?
> > > I think the stack walker will get even more confused?
> > > Also the JIT of bpf_call insn will emit variable number of push/pop
> > > around the call and I definitely don't want to add extra push rbp
> > > there, since it's the critical path and callee will do its own
> > > push rbp.
> > > Also there are push/pops emitted around div/mod
> > > and there is indirect goto emitted as well for bpf_tail_call
> > > that jumps into different function body without touching
> > > current stack.
> > 
> > Hm, I'm not sure I follow.  Let me try to explain my understanding.
> > 
> > As you mentioned, the generated code sets up the frame pointer.  From
> > emit_prologue():
> > 
> >         EMIT1(0x55); /* push rbp */
> > 	EMIT3(0x48, 0x89, 0xE5); /* mov rbp,rsp */
> > 
> > And then later, do_jit() can generate a call into the functions in
> > bpf_jit.S.  For example:
> > 
> > 	func = CHOOSE_LOAD_FUNC(imm32, sk_load_word);
> > 	...
> > 	EMIT1_off32(0xE8, jmp_offset); /* call */
> > 
> > So the functions in bpf_jit.S are being called by the generated code.
> > They're not part of the generated code itself.  So they're callees and
> > need to create their own stack frame before they call out to somewhere
> > else.
> > 
> > Or did I miss something?
> 
> yes. all correct.
> This particular patch is ok, since it adds to
> bpf_slow_path_common and as the name says it's slow and rare,
> but wanted to make sure the rest of it is understood.
> 
> > > Also none of the JITed function are dwarf annotated.
> > 
> > But what does that have to do with frame pointers?
> 
> nothing, but then why do you need
> .type name, @function
> annotations in another patch?

Those are ELF function annotations which are needed so that stacktool
can find and analyze all callable functions (and they're a good idea
anyway for the sake of other tooling).

Obviously we can't annotate the JIT functions which have no name, but
that's ok.  As long as they're doing the right thing with respect to
frame pointers, the stack dump code will still be able to see their
frames (and that they're associated with generated code).

> > > I could be missing something. I think either this patch
> > > is not need or you need to teach the tool to ignore
> > > all JITed stuff. I don't think it's practical to annotate
> > > everything. Different JITs do their own magic.
> > > s390 JIT is even more fancy.
> > 
> > Well, but the point of these patches isn't to make the tool happy.  It's
> > really to make sure that runtime stack traces can be made reliable.
> > Maybe I'm missing something but I don't see why JIT code can't honor
> > CONFIG_FRAME_POINTER just like any other code.
> 
> It can if there is no performance cost added.

CONFIG_FRAME_POINTER always adds a small performance cost but as you
mentioned it only affects the slow path here.  And hopefully we'll soon
have an in-kernel DWARF unwinder on x86 so we can get rid of the need
for frame pointers.

> I can speak for x64 JIT, but the rest needs to be analyzed as well.
> My point was that may be it's easier to ignore all JITed code and
> just say that such call stacks may be unreliable?
> live-patching is not applicable to JITed code anyway
> or you want to livepatch the callees of it?

Right.  We can't patch JIT code, but we might need to patch other
functions on the call stack (including callees and callers).

-- 
Josh
