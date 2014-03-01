From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v3 net-next 1/1] bpf32->bpf64 mapper and bpf64 interpreter
Date: Sat, 01 Mar 2014 01:30:00 +0100
Message-ID: <53112A08.5080309@redhat.com>
References: <1393468732-3919-1-git-send-email-ast@plumgrid.com> <1393468732-3919-2-git-send-email-ast@plumgrid.com> <531084E0.5080601@redhat.com> <CAMEtUuw9aQaBQR-CQq8hdk+8WFqadG0u1fz3pDTsedhXSkQzTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
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
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Jesse Gross <jesse@nicira.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41187 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752134AbaCADW5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Feb 2014 22:22:57 -0500
In-Reply-To: <CAMEtUuw9aQaBQR-CQq8hdk+8WFqadG0u1fz3pDTsedhXSkQzTg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/28/2014 09:53 PM, Alexei Starovoitov wrote:
> On Fri, Feb 28, 2014 at 4:45 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
...
>> Did you also test that seccomp-BPF still works out?
>
> yes. Have a prototype, but it needs a bit more cleanup.

Here's [1] actually some code snippet for user space for prctl(). The
libseccomp [2] actually wraps around that and makes usage easier.

   [1] http://outflux.net/teach-seccomp/
   [2] http://lwn.net/Articles/491308/

...
>> We should keep naming consistent (so either extended BPF or BPF64),
>> so maybe bpf_ext_enable ? I'd presume rather {bpf,sk_filter}*_ext
>
> agree. we need consistent naming for both (old and new).
> I'll try all-out rename of bpf_*() into sk_filter64_*() and sk_filter_ext_*()
> to see which one looks better.
> I'm kinda leaning to sk_filter64, since it's easier to quickly spot
> the difference
> and more descriptive.

Just saw your second email regarding sk_filter_ext() et al, yep, I agree.

>> as in 'struct bpf_insn' the immediate value is 32 bit, so for 64 bit
>> comparisons, you'd still need to load to immediate values, right?
>
> there is no insn that use 64-bit immediate, since 64-bit immediates
> are extremely rare. grep x86-64 asm code for movabsq will return very few.
> llvm or gcc can easily construct any constant by combination of mov,
> shifts and ors.
> bpf64 comparisons are all 64-bit right now. So far I didn't see a need to do
> 32-bit comparison, since old bpf is all unsigned, mapping 32->64 of
> Jxx is painless.

Hm, fair enough, I was just thinking for comparisons of IPv6 addresses
when we do socket filtering. On the other hand, old and new insns are
both 64 bit wide and can be used though the same api then.

> Notice I added signed comparison, since real life programs cannot do
> without them.
> I also kept the spirit of old bpf having > and >= only. (no < and <=)
> that made llvm/gcc backends a bit harder to do, since no real cpu has
> such limitations.

Hehe, I proposed them once, but for low level BPF it was just easier to
adjust jt/jf offsets differently to achieve the same.

> I'm still contemplating do add < and <= (both signed and unsigned), which is
> interesting trade-off: number of instructions vs complexity of compiler
>
>> After all your changes, we will still have the bpf_jit_enable knob
>> in tact, right?
>
> Yes.
> In this diff the workflow is the following:
>
> old filter comes through sk_attach_filter() or sk_unattached_filter_create()
> if (bpf64) {
>      convert to new
>      sk_chk_filter() - check old bpf
>      use new interpreter
> } else {
>      sk_chk_filter() - check old bpf
>      if (bpf_jit_enable)
>          use old jit
>      else
>          use old interpreter
> }
> soon I'll add bpf64 jit and will reuse the same bpf_jit_enable knob for it.
> then add new/old inband demux into sk_attach_filter(),
> so that workflow will become:
>
> a filter comes through sk_attach_filter() or sk_unattached_filter_create()
> if (new filter prog) {
>      sk_chk_filter64() - check new bpf
>      if (bpf_jit_enable)
>          use new jit
>      else
>          use new interpreter
> } else {
>      if (bpf64_enable) {
>         convert to new
>         sk_chk_filter() - check old bpf
>         if (bpf_jit_enable)
>              use new jit
>         else
>              use new interpreter
>      } else {
>         sk_chk_filter()
>         if (bpf_jit_enable)
>             use old jit
>         else
>             use old interpreter
>      }
> }
> eventually bpf64_enable can be made default,
> the last 'else' can be retired and 'bpf64_enable' removed along with
> old interpreter.
>
> bpf_jit_enable knob will stay for foreseeable future.

Okay, cool. I think it seems reasonable to keep this knob around anyway.
E.g. for seccomp some people might argue speed is important, maybe other
more security related distros might not want to rely on JIT and therefore
trade performance.

...
>> Why would that need to be exported as a symbol?
>
> the performance numbers I mentioned are from bpf_bench that is done
> as kernel module, so I used this for debugging from it.
> also to see what execution traces I get while running trinity bpf fuzzer :)
>
>> I would actually like to avoid having this pr_info* inside the kernel.
>> Couldn't this be done e.g. through systemtap script that could e.g. be
>> placed under tools/net/ or inside the documentation file?
>
> like the idea!
> Will drop it from the diff and eventually will move it to tools/net.

Sounds great!

Thanks,

Daniel
