From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [RFC PATCH v2 tip 0/7] 64-bit BPF insn set and tracing filters
Date: Thu, 13 Feb 2014 20:47:17 -0800
Message-ID: <CAMEtUuySNdj4_YBxQtaGu3qJ6TZhp65mSBy7DbhzL_Lvn9YiPw@mail.gmail.com>
References: <1391649046-4383-1-git-send-email-ast@plumgrid.com>
	<52F3670D.5090608@redhat.com>
	<CAMEtUuza3NuM7L0RnVVgU-MTfjE2M==8wb4UY2TAo0Pg6DKZqA@mail.gmail.com>
	<52FD2908.8000009@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ingo Molnar <mingo@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
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
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52FD2908.8000009@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 13, 2014 at 12:20 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 02/07/2014 02:20 AM, Alexei Starovoitov wrote:
> ...
>>
>> Hi Daniel,
>
>
> Thanks for your answer and sorry for the late reply.
>
>
>> Thank you for taking a look. Good questions. I had the same concerns.
>> Old BPF was carefully extended in specific places.
>> End result may look big at first glance, but every extension has specific
>> reason behind it. I tried to explain the reasoning in
>> Documentation/bpf_jit.txt
>>
>> I'm planning to write an on-the-fly converter from old BPF to BPF64
>> when BPF64 manages to demonstrate that it is equally safe.
>> It is straight forward to convert. Encoding is very similar.
>> Core concepts are the same.
>> Try diff include/uapi/linux/filter.h include/linux/bpf.h
>> to see how much is reused.
>>
>> I believe that old BPF outlived itself and BPF64 should
>> replace it in all current use cases plus a lot more.
>> It just cannot happen at once.
>> BPF64 can come in. bpf32->bpf64 converter functioning.
>> JIT from bpf64->aarch64 and may be sparc64 needs to be in place.
>> Then old bpf can fade away.
>
>
> Do you see a possibility to integrate your work step by step? That is,

Sure. let's see how we can do it.

> to first integrate the interpreter part only; meaning, to detect "old"
> BPF programs e.g. coming from SO_ATTACH_FILTER et al and run them in
> compatibility mode while extended BPF is fully integrated and replaces
> the old engine in net/core/filter.c. Maybe, "old" programs can be

do you mean drop bfp64_jit, checker and just have bpf32->bpf64 converter
and bpf64 interpreter as phase 1 ?
Checking is done by old bpf32,
all existing bpf32 jits, if available, can convert bpf32 to native,
but interpreter will be running on bpf64 ?
phase 2 to introduce bpf64_x86 jit and so on?
Sounds fine.

Today I didn't try to optimize bpf64 interpreter, since insn set is designed
for eventual JITing and interpreter is there to support archs that don't
have jit yet.
I guess I have to tweak it to perform at bpf32 interpreter speeds.

> transformed transparently to the new representation and then would be
> good to execute in eBPF. If possible, in such a way that in the first
> step JIT compilers won't need any upgrades. Once that is resolved,
> JIT compilers could successively migrate, arch by arch, to compile the
> new code? And last but not least the existing tools as well for handling
> eBPF. I think, if possible, that would be great. Also, I unfortunately
> haven't looked into your code too deeply yet due to time constraints,
> but I'm wondering e.g. for accessing some skb fields we currently use
> the "hack" to "overload" load instructions with negative arguments. Do
> we have a sort of "meta" instruction that is extendible in eBPF to avoid
> such things in future?

Exactly.
This 'negative offset' hack of bpf32 isn't very clean, since jits for all archs
need to change when new offsets added.
For bpf64 I'm proposing a customizable 'bpf_context' and variable set
of bpf-callable functions, so JITs don't need to change and verifier
stays the same.
That's the idea behind 'bpf_callbacks' in include/linux/bpf_jit.h

Some meta data makes sense to pass as input into bpf program.
Like for seccomp 'bpf_context' can be 'struct seccomp_data'

For networking, bpf_context can be 'skb',
then bpf_s_anc_protocol becomes a normal 2-byte bpf64 load
from skb->protocol field. Allowing access to other fields of skb
is just a matter of defining permissions of 'struct bpf_context' in
bpf_callback->get_context_access()

Some other meta data and extensions are cleaner when defined
as function calls from bpf, since calls are free.
I think bpf_table_lookup() is a fundamental one that allows to define
arbitrary tables within bpf and access them from the program.
(here I need feedback the most whether to access tables
via netlink from userspace or via debugfs...)

It probably will be easier to read the code of bpf32-bpf64 converter
to understand the differences between the two.
I guess I have to start working on the converter sooner than I thought...

Thanks
Alexei
