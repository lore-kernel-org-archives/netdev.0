From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 23/33] x86/asm/bpf: Create stack frames in bpf_jit.S
Date: Thu, 21 Jan 2016 18:44:28 -0800
Message-ID: <20160122024427.GA6000@ast-mbp.thefacebook.com>
References: <cover.1453405861.git.jpoimboe@redhat.com>
 <fa4c41976b438b51954cb8021f06bceb1d1d66cc.1453405861.git.jpoimboe@redhat.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36260 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113AbcAVCo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 21:44:29 -0500
Content-Disposition: inline
In-Reply-To: <fa4c41976b438b51954cb8021f06bceb1d1d66cc.1453405861.git.jpoimboe@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 21, 2016 at 04:49:27PM -0600, Josh Poimboeuf wrote:
> bpf_jit.S has several callable non-leaf functions which don't honor
> CONFIG_FRAME_POINTER, which can result in bad stack traces.
> 
> Create a stack frame before the call instructions when
> CONFIG_FRAME_POINTER is enabled.
> 
> Signed-off-by: Josh Poimboeuf <jpoimboe@redhat.com>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: netdev@vger.kernel.org
> ---
>  arch/x86/net/bpf_jit.S | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/net/bpf_jit.S b/arch/x86/net/bpf_jit.S
> index eb4a3bd..f2a7faf 100644
> --- a/arch/x86/net/bpf_jit.S
> +++ b/arch/x86/net/bpf_jit.S
> @@ -8,6 +8,7 @@
>   * of the License.
>   */
>  #include <linux/linkage.h>
> +#include <asm/frame.h>
>  
>  /*
>   * Calling convention :
> @@ -65,16 +66,18 @@ FUNC(sk_load_byte_positive_offset)
>  
>  /* rsi contains offset and can be scratched */
>  #define bpf_slow_path_common(LEN)		\
> +	lea	-MAX_BPF_STACK + 32(%rbp), %rdx;\
> +	FRAME_BEGIN;				\
>  	mov	%rbx, %rdi; /* arg1 == skb */	\
>  	push	%r9;				\
>  	push	SKBDATA;			\
>  /* rsi already has offset */			\
>  	mov	$LEN,%ecx;	/* len */	\
> -	lea	- MAX_BPF_STACK + 32(%rbp),%rdx;			\
>  	call	skb_copy_bits;			\
>  	test    %eax,%eax;			\
>  	pop	SKBDATA;			\
> -	pop	%r9;
> +	pop	%r9;				\
> +	FRAME_END

I'm not sure what above is doing.
There is already 'push rbp; mov rbp,rsp' at the beginning of generated
code and with above the stack trace will show two function at the same ip?
since there were no calls between them?
I think the stack walker will get even more confused?
Also the JIT of bpf_call insn will emit variable number of push/pop
around the call and I definitely don't want to add extra push rbp
there, since it's the critical path and callee will do its own
push rbp.
Also there are push/pops emitted around div/mod
and there is indirect goto emitted as well for bpf_tail_call
that jumps into different function body without touching
current stack.
Also none of the JITed function are dwarf annotated.
I could be missing something. I think either this patch
is not need or you need to teach the tool to ignore
all JITed stuff. I don't think it's practical to annotate
everything. Different JITs do their own magic.
s390 JIT is even more fancy.
