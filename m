From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 23/33] x86/asm/bpf: Create stack frames in bpf_jit.S
Date: Fri, 22 Jan 2016 09:18:23 -0800
Message-ID: <20160122171823.GC9608@ast-mbp.thefacebook.com>
References: <cover.1453405861.git.jpoimboe@redhat.com>
 <fa4c41976b438b51954cb8021f06bceb1d1d66cc.1453405861.git.jpoimboe@redhat.com>
 <20160122024427.GA6000@ast-mbp.thefacebook.com>
 <20160122035531.GA20502@treble.redhat.com>
 <20160122041845.GA7175@ast-mbp.thefacebook.com>
 <20160122155804.GC20502@treble.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Josh Poimboeuf <jpoimboe@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160122155804.GC20502@treble.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 22, 2016 at 09:58:04AM -0600, Josh Poimboeuf wrote:
> On Thu, Jan 21, 2016 at 08:18:46PM -0800, Alexei Starovoitov wrote:
> > On Thu, Jan 21, 2016 at 09:55:31PM -0600, Josh Poimboeuf wrote:
> > > On Thu, Jan 21, 2016 at 06:44:28PM -0800, Alexei Starovoitov wrote:
> > > > On Thu, Jan 21, 2016 at 04:49:27PM -0600, Josh Poimboeuf wrote:
> > > > > bpf_jit.S has several callable non-leaf functions which don't honor
> > > > > CONFIG_FRAME_POINTER, which can result in bad stack traces.
> > > > > 
> > > > > Create a stack frame before the call instructions when
> > > > > CONFIG_FRAME_POINTER is enabled.
> > > > > 
> > > > > Signed-off-by: Josh Poimboeuf <jpoimboe@redhat.com>
> > > > > Cc: Alexei Starovoitov <ast@kernel.org>
> > > > > Cc: netdev@vger.kernel.org
> > > > > ---
> > > > >  arch/x86/net/bpf_jit.S | 9 +++++++--
...
> > > > >  /* rsi contains offset and can be scratched */
> > > > >  #define bpf_slow_path_common(LEN)		\
> > > > > +	lea	-MAX_BPF_STACK + 32(%rbp), %rdx;\
> > > > > +	FRAME_BEGIN;				\
> > > > >  	mov	%rbx, %rdi; /* arg1 == skb */	\
> > > > >  	push	%r9;				\
> > > > >  	push	SKBDATA;			\
> > > > >  /* rsi already has offset */			\
> > > > >  	mov	$LEN,%ecx;	/* len */	\
> > > > > -	lea	- MAX_BPF_STACK + 32(%rbp),%rdx;			\
> > > > >  	call	skb_copy_bits;			\
> > > > >  	test    %eax,%eax;			\
> > > > >  	pop	SKBDATA;			\
> > > > > -	pop	%r9;
> > > > > +	pop	%r9;				\
> > > > > +	FRAME_END
...
> > > Well, but the point of these patches isn't to make the tool happy.  It's
> > > really to make sure that runtime stack traces can be made reliable.
> > > Maybe I'm missing something but I don't see why JIT code can't honor
> > > CONFIG_FRAME_POINTER just like any other code.
> > 
> > It can if there is no performance cost added.
> 
> CONFIG_FRAME_POINTER always adds a small performance cost but as you
> mentioned it only affects the slow path here.  And hopefully we'll soon
> have an in-kernel DWARF unwinder on x86 so we can get rid of the need
> for frame pointers.

ok. fair enough.
Acked-by: Alexei Starovoitov <ast@kernel.org>
