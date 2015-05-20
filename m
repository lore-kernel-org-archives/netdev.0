From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH net-next 1/4] bpf: allow bpf programs to tail-call other
 bpf programs
Date: Tue, 19 May 2015 17:13:22 -0700
Message-ID: <CALCETrVP=7sCM12cCZVZCCMozGcHyqTsOFvjv7cEpc7Frxj4Xg@mail.gmail.com>
References: <1432079946-9878-1-git-send-email-ast@plumgrid.com> <1432079946-9878-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Michael Holzheu <holzheu-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Zi Shen Lim <zlim.lnx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1432079946-9878-2-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 19, 2015 at 4:59 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> introduce bpf_tail_call(ctx, &jmp_table, index) helper function
> which can be used from BPF programs like:
> int bpf_prog(struct pt_regs *ctx)
> {
>   ...
>   bpf_tail_call(ctx, &jmp_table, index);
>   ...
> }
> that is roughly equivalent to:
> int bpf_prog(struct pt_regs *ctx)
> {
>   ...
>   if (jmp_table[index])
>     return (*jmp_table[index])(ctx);
>   ...
> }
> The important detail that it's not a normal call, but a tail call.
> The kernel stack is precious, so this helper reuses the current
> stack frame and jumps into another BPF program without adding
> extra call frame.
> It's trivially done in interpreter and a bit trickier in JITs.
> In case of x64 JIT the bigger part of generated assembler prologue
> is common for all programs, so it is simply skipped while jumping.
> Other JITs can do similar prologue-skipping optimization or
> do stack unwind before jumping into the next program.
>
> bpf_tail_call() arguments:
> ctx - context pointer
> jmp_table - one of BPF_MAP_TYPE_PROG_ARRAY maps used as the jump table
> index - index in the jump table
>
> Since all BPF programs are idenitified by file descriptor, user space
> need to populate the jmp_table with FDs of other BPF programs.
> If jmp_table[index] is empty the bpf_tail_call() doesn't jump anywhere
> and program execution continues as normal.
>
> New BPF_MAP_TYPE_PROG_ARRAY map type is introduced so that user space can
> populate this jmp_table array with FDs of other bpf programs.
> Programs can share the same jmp_table array or use multiple jmp_tables.
>
> The chain of tail calls can form unpredictable dynamic loops therefore
> tail_call_cnt is used to limit the number of calls and currently is set to 32.

IMO this is starting to get a bit ugly.  Would it be possible to have
the program dereference the subprogram reference itself from the jump
table?  There would have to be a verifier type that represents a
reference to a program tail-call entry point, but that seems better
than having this weird indirection.

--Andy
