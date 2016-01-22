From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 31/33] bpf: Add __bpf_prog_run() to stacktool whitelist
Date: Thu, 21 Jan 2016 18:55:41 -0800
Message-ID: <20160122025540.GB6000@ast-mbp.thefacebook.com>
References: <cover.1453405861.git.jpoimboe@redhat.com>
 <8ee01c195432e4c1ebaa79c20e91525c7af22384.1453405861.git.jpoimboe@redhat.com>
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
In-Reply-To: <8ee01c195432e4c1ebaa79c20e91525c7af22384.1453405861.git.jpoimboe@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 21, 2016 at 04:49:35PM -0600, Josh Poimboeuf wrote:
> stacktool reports the following false positive warnings:
> 
>   stacktool: kernel/bpf/core.o: __bpf_prog_run()+0x5c: sibling call from callable instruction with changed frame pointer
>   stacktool: kernel/bpf/core.o: __bpf_prog_run()+0x60: function has unreachable instruction
>   stacktool: kernel/bpf/core.o: __bpf_prog_run()+0x64: function has unreachable instruction
>   [...]
> 
> It's confused by the following dynamic jump instruction in
> __bpf_prog_run()::
> 
>   jmp     *(%r12,%rax,8)
> 
> which corresponds to the following line in the C code:
> 
>   goto *jumptable[insn->code];
> 
> There's no way for stacktool to deterministically find all possible
> branch targets for a dynamic jump, so it can't verify this code.
> 
> In this case the jumps all stay within the function, and there's nothing
> unusual going on related to the stack, so we can whitelist the function.

well, few things are very unusual in this function.
did you see what JMP_CALL does? it's a call into a different function,
but not like typical indirect call. Will it be ok as well?

In general it's not possible for any tool to identify all possible
branch targets. bpf programs can be loaded on the fly and
jumping sequence will change.
So if this marking says 'don't bother analyzing this function because
it does sane stuff' that's probably not the case.
If this marking says 'don't bother analyzing, the stack may be crazy
from here on' then it's ok.
