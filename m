From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [RFC PATCH v2 tip 0/7] 64-bit BPF insn set and tracing filters
Date: Fri, 14 Feb 2014 18:02:04 +0100
Message-ID: <52FE4C0C.1090008@redhat.com>
References: <1391649046-4383-1-git-send-email-ast@plumgrid.com> <52F3670D.5090608@redhat.com> <CAMEtUuza3NuM7L0RnVVgU-MTfjE2M==8wb4UY2TAo0Pg6DKZqA@mail.gmail.com> <52FD2908.8000009@redhat.com> <52FD458D.6020107@redhat.com> <CAMEtUuwfSYr=7+_8jKryUMUTL1NE-wRV_h=PX7uKdkUebgGiPg@mail.gmail.com>
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
In-Reply-To: <CAMEtUuwfSYr=7+_8jKryUMUTL1NE-wRV_h=PX7uKdkUebgGiPg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/14/2014 01:59 AM, Alexei Starovoitov wrote:
...
>> I'm very curious, do you also have any performance numbers, e.g. for
>> networking by taking JIT'ed/non-JIT'ed BPF filters and compare them against
>> JIT'ed/non-JIT'ed eBPF filters to see how many pps we gain or loose e.g.
>> for a scenario with a middle box running cls_bpf .. or some other macro/
>> micro benchmark just to get a picture where both stand in terms of
>> performance? Who knows, maybe it would outperform nftables engine as
>> well? ;-) How would that look on a 32bit arch with eBPF that is 64bit?
>
> I don't have jited/non-jited numbers, but I suspect for micro-benchmarks
> the gap should be big. I was shooting for near native performance after JIT.

Ohh, I meant it would be interesting to see a comparison of e.g. common libpcap
high-level filters that are in 32bit BPF + JIT (current code) vs 64bit BPF + JIT
(new code). I'm wondering how 32bit-only archs should be handled to not regress
in evaluation performance to the current code.

> So I took flow_dissector() function, tweaked it a bit and compiled into BPF.
> x86_64 skb_flow_dissect() same skb (all cached)          -  42 nsec per call
> x86_64 skb_flow_dissect() different skbs (cache misses)  - 141 nsec per call
> bpf_jit skb_flow_dissect() same skb (all cached)         -  51 nsec per call
> bpf_jit skb_flow_dissect() different skbs (cache misses) - 135 nsec per call
>
> C->BPF64->x86_64 is slower than C->x86_64 when all data is in cache,
> but presence of cache misses hide extra insns.
>
> For gre flow_dissector() looks into inner packet, but for vxlan it does not,
> since it needs to know udp port number. We can extend it with if (static_key)
> and walk the list of udp_offload_base->offload->port like we do in
> udp_gro_receive(),
> but for RPS we just need a hash. I think custom loadable
> flow_dissector() is the way to go.
> If we know that majority of the traffic on the given machine is vxlan to port N
> we can hard code this into BPF program. Don't need to walk outer packet either.
> Just pick ip/port from inner. It's doable with old BPF too.
>
> What we used to think as dynamic, with BPF can be hard coded.
>
> As soon as I have time I'm thinking to play with nftables. The idea is:
> rules are changed rarely, but a lot of traffic goes through them,
> so we can spend time optimizing them.
>
> Either user input or nft program can be converted to C, then LLVM invoked
> to optimize the whole thing, generate BPF and load it.
> Adding a rule will take time, but if execution of such ip/nftables
> will be faster
> the end user will benefit.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
