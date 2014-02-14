From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [RFC PATCH v2 tip 0/7] 64-bit BPF insn set and tracing filters
Date: Fri, 14 Feb 2014 12:17:37 -0800
Message-ID: <CAMEtUux0K6xTy=wtoutny+HXv8yrTMurPWB6q_LVf7KAOAkzhw@mail.gmail.com>
References: <1391649046-4383-1-git-send-email-ast@plumgrid.com>
	<52F3670D.5090608@redhat.com>
	<CAMEtUuza3NuM7L0RnVVgU-MTfjE2M==8wb4UY2TAo0Pg6DKZqA@mail.gmail.com>
	<52FD2908.8000009@redhat.com>
	<CAMEtUuySNdj4_YBxQtaGu3qJ6TZhp65mSBy7DbhzL_Lvn9YiPw@mail.gmail.com>
	<52FE51E9.8000203@redhat.com>
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
In-Reply-To: <52FE51E9.8000203@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 14, 2014 at 9:27 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 02/14/2014 05:47 AM, Alexei Starovoitov wrote:
> ...
>>>
>>> Do you see a possibility to integrate your work step by step? That is,
>>
>>
>> Sure. let's see how we can do it.
>>
>>> to first integrate the interpreter part only; meaning, to detect "old"
>>> BPF programs e.g. coming from SO_ATTACH_FILTER et al and run them in
>>> compatibility mode while extended BPF is fully integrated and replaces
>>> the old engine in net/core/filter.c. Maybe, "old" programs can be
>>
>>
>> do you mean drop bfp64_jit, checker and just have bpf32->bpf64 converter
>> and bpf64 interpreter as phase 1 ?
>> Checking is done by old bpf32,
>> all existing bpf32 jits, if available, can convert bpf32 to native,
>> but interpreter will be running on bpf64 ?
>> phase 2 to introduce bpf64_x86 jit and so on?
>> Sounds fine.
>
>
> If that's possible, so first step would be to migrate bpf_run() from patch1
> into sk_run_filter() form net/core/filter.c, and also bring in related
> include file into include/linux/filter.h resp. include/uapi/linux/filter.h.
> Plus code that is needed to verify the image in new (and old) format e.g.
> bpf_load_image() et al, and to either convert old programs into the new
> format, for example; generally, to find a way to still handle them
> (bpf/seccomp)
> while having the new code included and leaving new JITs aside. That I think
> could be phase 1. Phase 2 would be to successively replace current JITs,
> etc.

Sounds good.
Let me rephrase.
step 1:
sk_attach_filter() -> __sk_prepare_filter() -> sk_chk_filter() all stays as-is.
sk_chk_filter() calls new bpf_convert() that converts old bpf to new bpf insns.
Old sk_run_filter() is gone and replaced with bpf_run() that iterates
over new insns.
Here would need to make sure that all sk_run_filter() users (seccomp,
ppp, isdn, team)
are unaffected.

step 2:
use 'len' field of 'struct sock_fprog' to differentiate between old and new bpf.
len < 4096 -> old bpf insns, go to step 1
len > 4096 -> new bpf insns, verify them through new bpf_check()
and run them via the same new sk_run_filter()==bpf_run()
This way all current users of bpf can load new programs through the
same interfaces.

step 3:
replace bpf32_x86 jit with bpf64_jit.

step 4:
old filter attach interfaces do not allow the most interesting bpf64 programs
with bpf_tables (like the one for kernel tracing), extend them or add new

Initially I extended include/uapi/linux/filter.h, but then decided
it's too aggressive
to change uapi header and split it into include/linux/bpf.h instead.
It's definitely cleaner to have one. I guess with a comment that bpf64 insn set
may change, it should be ok. I'll go back to single filter.h

As far as making bpf64 interpreter to perform at bpf32 speeds on i386 and arm32,
I think I have to reconsider 32-bit subregs. Peter Anvin should be happy :)
If old bpf is like 8086, bpf64 with 32-bit subregs and 64-bit
registers is like x86-64 with x32.

Sounds like we're converging. What other stake holders have to say?

Thanks
Alexei
