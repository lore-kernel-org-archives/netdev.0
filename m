From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v7 net-next 1/3] filter: add Extended BPF interpreter and converter
Date: Sun, 9 Mar 2014 10:38:55 -0700
Message-ID: <CAMEtUuyB9ZhvwU+Lv5UypXDbgAG02BgdRomF9nOef-GqNAxjww@mail.gmail.com>
References: <1394320530-3508-1-git-send-email-ast@plumgrid.com>
	<1394320530-3508-2-git-send-email-ast@plumgrid.com>
	<1394376353.20149.96.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Ingo Molnar <mingo@kernel.org>, Will Drewry <wad@chromium.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Jesse Gross <jesse@nicira.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Jovi Zhangwei <jovi.zhangwei@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Pekka Enberg <penberg@iki.fi>,
	Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.k
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394376353.20149.96.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 9, 2014 at 7:45 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2014-03-08 at 15:15 -0800, Alexei Starovoitov wrote:
>
>> +/**
>> + *   sk_run_filter_ext - run an extended filter
>> + *   @ctx: buffer to run the filter on
>> + *   @insn: filter to apply
>> + *
>> + * Decode and execute extended BPF instructions.
>> + * @ctx is the data we are operating on.
>> + * @filter is the array of filter instructions.
>> + */
>> +notrace u32 sk_run_filter_ext(void *ctx, const struct sock_filter_ext *insn)
>> +{
>> +     u64 stack[64];
>> +     u64 regs[16];
>> +     void *ptr;
>> +     u64 tmp;
>> +     int off;

First of all, great that you finally reviewed it! Feedback is appreciated :)

> Why is this 'notrace' ?

to avoid overhead of dummy call.
JITed filters are not adding this dummy call.
So 'notrace' on interpreter brings it to parity with JITed filters.

> 80 u64 on the stack, that is 640 bytes to run a filter ????

yes. that was described in commit log and in Doc...filter.txt:
"
- 16 4-byte stack slots for register spill-fill replaced with
  up to 512 bytes of multi-use stack space
"

For interpreter it is prohibitive to dynamically allocate stack space
that's why it just grabs 64*8 to run any program.
For JIT it's going to be close to zero for majority of filters, since
generated program will allocate only as much as was allowed
by sk_chk_filter_ext(). Only largest programs would need 'up to 512'.
This much stack would be needed for programs that need to use
large key/value pairs in their ebpf tables.
So far I haven't seen a program that approaches this limit,
but it seems to me that 512 is reasonable, since kernel warns on
functions with > 1k stack.

btw, current x86 jit just does 'subq  $96,%rsp',
I think ebpf jit should use the minimum amount of stack. Only amount
that is needed.
May be I'm over thinking it and having 'subq $512, %rsp' for JIT is also fine.
Let me know.

Thanks
Alexei
