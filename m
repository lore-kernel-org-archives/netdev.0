From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [RFC PATCH v2 tip 0/7] 64-bit BPF insn set and tracing filters
Date: Thu, 13 Feb 2014 16:59:56 -0800
Message-ID: <CAMEtUuwfSYr=7+_8jKryUMUTL1NE-wRV_h=PX7uKdkUebgGiPg@mail.gmail.com>
References: <1391649046-4383-1-git-send-email-ast@plumgrid.com>
	<52F3670D.5090608@redhat.com>
	<CAMEtUuza3NuM7L0RnVVgU-MTfjE2M==8wb4UY2TAo0Pg6DKZqA@mail.gmail.com>
	<52FD2908.8000009@redhat.com>
	<52FD458D.6020107@redhat.com>
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
In-Reply-To: <52FD458D.6020107@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 13, 2014 at 2:22 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 02/13/2014 09:20 PM, Daniel Borkmann wrote:
>>
>> On 02/07/2014 02:20 AM, Alexei Starovoitov wrote:
>> ...
>>>
>>> Hi Daniel,
>>
>>
>> Thanks for your answer and sorry for the late reply.
>>
>>> Thank you for taking a look. Good questions. I had the same concerns.
>>> Old BPF was carefully extended in specific places.
>>> End result may look big at first glance, but every extension has specific
>>> reason behind it. I tried to explain the reasoning in
>>> Documentation/bpf_jit.txt
>>>
>>> I'm planning to write an on-the-fly converter from old BPF to BPF64
>>> when BPF64 manages to demonstrate that it is equally safe.
>>> It is straight forward to convert. Encoding is very similar.
>>> Core concepts are the same.
>>> Try diff include/uapi/linux/filter.h include/linux/bpf.h
>>> to see how much is reused.
>>>
>>> I believe that old BPF outlived itself and BPF64 should
>>> replace it in all current use cases plus a lot more.
>>> It just cannot happen at once.
>>> BPF64 can come in. bpf32->bpf64 converter functioning.
>>> JIT from bpf64->aarch64 and may be sparc64 needs to be in place.
>>> Then old bpf can fade away.
>>
>>
>> Do you see a possibility to integrate your work step by step? That is,
>> to first integrate the interpreter part only; meaning, to detect "old"
>> BPF programs e.g. coming from SO_ATTACH_FILTER et al and run them in
>> compatibility mode while extended BPF is fully integrated and replaces
>> the old engine in net/core/filter.c. Maybe, "old" programs can be
>> transformed transparently to the new representation and then would be
>> good to execute in eBPF. If possible, in such a way that in the first
>> step JIT compilers won't need any upgrades. Once that is resolved,
>> JIT compilers could successively migrate, arch by arch, to compile the
>> new code? And last but not least the existing tools as well for handling
>> eBPF. I think, if possible, that would be great. Also, I unfortunately
>> haven't looked into your code too deeply yet due to time constraints,
>> but I'm wondering e.g. for accessing some skb fields we currently use
>> the "hack" to "overload" load instructions with negative arguments. Do
>> we have a sort of "meta" instruction that is extendible in eBPF to avoid
>> such things in future?
>>
>>>> First of all, I think it's very interesting work ! I'm just a bit
>>>> concerned
>>>> that this _huge_ patchset with 64 bit BPF, or however we call it, will
>>>> line
>>>
>>>
>>> Huge?
>>> kernel is only 2k
>>> the rest is 6k of userspace LLVM backend where most of it is llvm's
>>> boilerplate code. GCC backend for BPF is 3k.
>>> The goal is to have both GCC and LLVM backends to be upstreamed
>>> when kernel pieces are agreed upon.
>>> For comparison existing tools/net/bpf* is 2.5k
>>> but here with 6k we get optimizing compiler from C and assembler.
>>>
>>>> up in one row next to the BPF code we currently have and next to new
>>>> nftables
>>>> engine and we will end up with three such engines which do quite similar
>>>> things and are all exposed to user space thus they need to be maintained
>>>> _forever_, adding up legacy even more. What would be the long-term
>>>> future
>>>> use
>>>> cases where the 64 bit engine comes into place compared to the current
>>>> BPF
>>>> engine? What are the concrete killer features? I didn't went through
>>>> your
>>>
>>>
>>> killer features vs old bpf are:
>>> - zero-cost function calls
>>> - 32-bit vs 64-bit
>>> - optimizing compiler that can compile C into BPF64
>>>
>>> Why call kernel function from BPF?
>>> So that BPF instruction set has to be extended only once and JITs are
>>> written only once.
>>> Over the years many extensions crept into old BPF as 'negative offsets'.
>>> but JITs don't support all of them and assume bpf input as 'skb' only.
>>> seccomp is using old bpf, but, because of these limitations, cannot use
>>> JIT.
>>> BPF64 allows seccomp to be JITed, since bpf input is generalized
>>> as 'struct bpf_context'.
>>> New 'negative offset' extension for old bpf would mean implementing it in
>>> JITs of all architectures? Painful, but doable. We can do better.
>
>
> I'm very curious, do you also have any performance numbers, e.g. for
> networking by taking JIT'ed/non-JIT'ed BPF filters and compare them against
> JIT'ed/non-JIT'ed eBPF filters to see how many pps we gain or loose e.g.
> for a scenario with a middle box running cls_bpf .. or some other macro/
> micro benchmark just to get a picture where both stand in terms of
> performance? Who knows, maybe it would outperform nftables engine as
> well? ;-) How would that look on a 32bit arch with eBPF that is 64bit?

I don't have jited/non-jited numbers, but I suspect for micro-benchmarks
the gap should be big. I was shooting for near native performance after JIT.

So I took flow_dissector() function, tweaked it a bit and compiled into BPF.
x86_64 skb_flow_dissect() same skb (all cached)          -  42 nsec per call
x86_64 skb_flow_dissect() different skbs (cache misses)  - 141 nsec per call
bpf_jit skb_flow_dissect() same skb (all cached)         -  51 nsec per call
bpf_jit skb_flow_dissect() different skbs (cache misses) - 135 nsec per call

C->BPF64->x86_64 is slower than C->x86_64 when all data is in cache,
but presence of cache misses hide extra insns.

For gre flow_dissector() looks into inner packet, but for vxlan it does not,
since it needs to know udp port number. We can extend it with if (static_key)
and walk the list of udp_offload_base->offload->port like we do in
udp_gro_receive(),
but for RPS we just need a hash. I think custom loadable
flow_dissector() is the way to go.
If we know that majority of the traffic on the given machine is vxlan to port N
we can hard code this into BPF program. Don't need to walk outer packet either.
Just pick ip/port from inner. It's doable with old BPF too.

What we used to think as dynamic, with BPF can be hard coded.

As soon as I have time I'm thinking to play with nftables. The idea is:
rules are changed rarely, but a lot of traffic goes through them,
so we can spend time optimizing them.

Either user input or nft program can be converted to C, then LLVM invoked
to optimize the whole thing, generate BPF and load it.
Adding a rule will take time, but if execution of such ip/nftables
will be faster
the end user will benefit.
