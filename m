From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [RFC PATCH v2 tip 0/7] 64-bit BPF insn set and tracing filters
Date: Thu, 13 Feb 2014 23:22:05 +0100
Message-ID: <52FD458D.6020107@redhat.com>
References: <1391649046-4383-1-git-send-email-ast@plumgrid.com> <52F3670D.5090608@redhat.com> <CAMEtUuza3NuM7L0RnVVgU-MTfjE2M==8wb4UY2TAo0Pg6DKZqA@mail.gmail.com> <52FD2908.8000009@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52FD2908.8000009@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/13/2014 09:20 PM, Daniel Borkmann wrote:
> On 02/07/2014 02:20 AM, Alexei Starovoitov wrote:
> ...
>> Hi Daniel,
>
> Thanks for your answer and sorry for the late reply.
>
>> Thank you for taking a look. Good questions. I had the same concerns.
>> Old BPF was carefully extended in specific places.
>> End result may look big at first glance, but every extension has specific
>> reason behind it. I tried to explain the reasoning in Documentation/bpf_jit.txt
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
> Do you see a possibility to integrate your work step by step? That is,
> to first integrate the interpreter part only; meaning, to detect "old"
> BPF programs e.g. coming from SO_ATTACH_FILTER et al and run them in
> compatibility mode while extended BPF is fully integrated and replaces
> the old engine in net/core/filter.c. Maybe, "old" programs can be
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
>
>>> First of all, I think it's very interesting work ! I'm just a bit concerned
>>> that this _huge_ patchset with 64 bit BPF, or however we call it, will line
>>
>> Huge?
>> kernel is only 2k
>> the rest is 6k of userspace LLVM backend where most of it is llvm's
>> boilerplate code. GCC backend for BPF is 3k.
>> The goal is to have both GCC and LLVM backends to be upstreamed
>> when kernel pieces are agreed upon.
>> For comparison existing tools/net/bpf* is 2.5k
>> but here with 6k we get optimizing compiler from C and assembler.
>>
>>> up in one row next to the BPF code we currently have and next to new
>>> nftables
>>> engine and we will end up with three such engines which do quite similar
>>> things and are all exposed to user space thus they need to be maintained
>>> _forever_, adding up legacy even more. What would be the long-term future
>>> use
>>> cases where the 64 bit engine comes into place compared to the current BPF
>>> engine? What are the concrete killer features? I didn't went through your
>>
>> killer features vs old bpf are:
>> - zero-cost function calls
>> - 32-bit vs 64-bit
>> - optimizing compiler that can compile C into BPF64
>>
>> Why call kernel function from BPF?
>> So that BPF instruction set has to be extended only once and JITs are
>> written only once.
>> Over the years many extensions crept into old BPF as 'negative offsets'.
>> but JITs don't support all of them and assume bpf input as 'skb' only.
>> seccomp is using old bpf, but, because of these limitations, cannot use JIT.
>> BPF64 allows seccomp to be JITed, since bpf input is generalized
>> as 'struct bpf_context'.
>> New 'negative offset' extension for old bpf would mean implementing it in
>> JITs of all architectures? Painful, but doable. We can do better.

I'm very curious, do you also have any performance numbers, e.g. for
networking by taking JIT'ed/non-JIT'ed BPF filters and compare them against
JIT'ed/non-JIT'ed eBPF filters to see how many pps we gain or loose e.g.
for a scenario with a middle box running cls_bpf .. or some other macro/
micro benchmark just to get a picture where both stand in terms of
performance? Who knows, maybe it would outperform nftables engine as
well? ;-) How would that look on a 32bit arch with eBPF that is 64bit?

>> Fixed instruction set that allows zero-overhead calls into kernel functions
>> is much more flexible and extendable in a clean way.
>> Take a look at kernel/trace/bpf_trace_callbacks.c
>> It is a customization of generic BPF64 core for 'tracing filters'.
>> The set of functions for networking and definition of 'bpf_context'
>> will be different.
>> So BPF64 for tracing need X extensions, BPF64 for networking needs Y
>> extensions, but core framework stays the same and JIT stays the same.
>>
>> How to do zero-overhead call?
>> Map BPF registers to native registers one to one
>> and have compatible calling convention between BPF and native.
>> Then BPF asm code:
>> mov R1, 1
>> mov R2, 2
>> call foo
>> will be JITed into x86-64:
>> mov rdi, 1
>> mov rsi, 2
>> call foo
>> That makes BPF64 calls into kernel as fast as possible.
>> Especially for networking we don't want overhead of FFI mechanisms.
>>
>> That's why A and X regs and lack of callee-saved regs make old BPF
>> impractical to support generic function calls.
>>
>> BPF64 defines R1-R5 as function arguments and R6-R9 as
>> callee-saved, so kernel can natively call into JIT-ed BPF and back
>> with no extra argument shuffling.
>> gcc/llvm backends know that R6-R9 will be preserved while BPF is
>> calling into kernel functions and can make proper optimizations.
>> R6-R9 map to rbx-r15 on x86-64. On aarch64 we have
>> even more freedom of mapping.
>>
>>> code
>>> in detail, but although we might/could have _some_ performance benefits but
>>> at
>>> the _huge_ cost of adding complexity. The current BPF I find okay to debug
>>> and
>>> to follow, but how would be debug'ability of 64 bit programs end up, as you
>>> mention, it becomes "unbearably complex"?
>>
>> "unbearably complex" was the reference to x86 static analyzer :)
>> It's difficult to reconstruct and verify control and data flow of x86 asm code.
>> Binary compilers do that (like transmeta and others), but that's not suitable
>> for kernel.
>>
>> Both old bpf asm and bpf64 asm code I find equivalent in readability.
>>
>> clang dropmon.c ...|llc -filetype=asm
>> will produce the following bpf64 asm code:
>>          mov     r6, r1
>>          ldd     r1, 8(r6)
>>          std     -8(r10), r1
>>          mov     r7, 0
>>          mov     r3, r10
>>          addi    r3, -8
>>          mov     r1, r6
>>          mov     r2, r7
>>          call    bpf_table_lookup
>>          jeqi    r0, 0 goto .LBB0_2
>>
>> which corresponds to C:
>> void dropmon(struct bpf_context *ctx)
>> {       void *loc;
>>          uint64_t *drop_cnt;
>>          loc = (void *)ctx->arg2;
>>          drop_cnt = bpf_table_lookup(ctx, 0, &loc);
>>          if (drop_cnt) ...
>>
>> I think restricted C is easier to program and debug.
>> Which is another killer feature of bpf64.
>>
>> Interesting use case would be if some kernel subsystem
>> decides to generate BPF64 insns on the fly and JIT them.
>> Sort of self-modifieable kernel code.
>> It's certainly easier to generate BPF64 binary with macroses
>> from linux/bpf.h instead of x86 binary...
>> I may be dreaming here :)
>>
>>> Did you instead consider to
>>> replace
>>> the current BPF engine instead, and add a sort of built-in compatibility
>>> mode for current BPF programs? I think that this would be the way better
>>> option to go with instead of adding a new engine next to the other. For
>>> maintainability, trying to replace the old one might be harder to do on the
>>> short term but better to maintain on the long run for everyone, no?
>>
>> Exactly. I think on-the-fly converter from bpf32->bpf64 is this built-in
>> compatibility layer. I completely agree that replacing bpf32 is hard
>> short term, since it will raise too many concerns about
>> stability/safety, but long term it's a way to go.
>
> Yes, I agree.
>
>> I'm open to all suggestions on how to make it more generic, useful,
>> faster.
>>
>> Thank you for feedback.
>
> Thank you, must have been really fun to implement this. :)
>
>> Regards,
>> Alexei
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
