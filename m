From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v6 net-next 1/3] filter: add Extended BPF interpreter and converter
Date: Mon, 10 Mar 2014 13:02:10 -0700
Message-ID: <CAMEtUuyr__joDR9YYHuaqWd2fJL5-1ct5pEaQ2NRaq+G-BZK+w@mail.gmail.com>
References: <1394076617-8108-2-git-send-email-ast@plumgrid.com>
	<20140307.153808.649644634357014854.davem@davemloft.net>
	<CAMEtUuzgM5xKAXZaC+Up9bKy6MaS8V6jFGq49QY7VxQOSFgcBw@mail.gmail.com>
	<20140310.152242.340501323969517196.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <dborkman@redhat.com>,
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
	=?ISO-8859-1?Q?Fr=E9d=E9ric_Weisbecker?= <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Pekka Enberg <penberg@iki.fi>,
	Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140310.152242.340501323969517196.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 10, 2014 at 12:22 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Fri, 7 Mar 2014 14:19:39 -0800
>
>> On Fri, Mar 7, 2014 at 12:38 PM, David Miller <davem@davemloft.net> wrote:
>> 2.
>> Another alternative is to do
>> struct sk_filter {
>>   ..
>> union {
>>     unsigned int (*bpf_func)(const struct sk_buff *skb,const struct
>> sock_filter *filter);
>>     unsigned int (*bpf_func_ext)(void*, const struct sock_filter_ext *filter);
>>     unsigned int (*bpf_func_generic)(void *, void*);
>> };
>>
>> assignments into sk_filter will use correct field like:
>> fp->bpf_func_ext = sk_run_filter_ext;
>> and the hot call macro will look like:
>> #define SK_RUN_FILTER(F, CTX) (*F->bpf_func_generic)(CTX, F->insns)
>>
>> I think current typecasts are equally ugly, but 'union' style
>> will be cleaner from gcc point of view.
>
> The main point is that we should only bypass the type protection provided
> by the C language as an absolute last resort.
>
> But in some cases, we can consider making an exception.
>
> The problem with letting sk_check_filter() do the verification is that the
> type is also determined by the call site.  That requires some kind of type
> based or run time verification.

agree. To solve the call site issue, we can do 'type based' verification:
I can make sk_run_filter_ext(void *, ...) to be private in filter.c
and provide two globally visible:
sk_run_filter_ext_seccomp(struct seccomp_data*,...
sk_run_filter_ext_skb(struct sk_buff*,...

and inside them just call the private function.
Compiler will do a type verification at the call site for us.
The only problem with this approach is that tracing+ebpf, ovs+ebpf, nft+ebpf
would need their own call functions.

I feel we're overprotecting ourselves here.
Please consider making an exception for this case.

> Although it doesn't use C typing, one thing you could do is encoded the
> pointer into an unsigned long.  Then you encode the context in the lowest
> bits of that value, masking them out when derferencing at run time.
>
> So that way we can make sure seccomp _only_ runs seccomd filters.
>
> And sockets only run socket filters with SKBs in the second argument.
>
>> btw, ebpf jit coming in the next diff (it was also previewed in V1 series).
>>
>> In the 1/3 commit log of this patch I explain the current relation
>> between bpf_ext_enable and bpf_jit_enable flags.
>>
>> In the next patch with ebpf jit, single bpf_jit_enable flag will act for both:
>>   if (bpf_ext_enable) {
>>         convert to new
>>         sk_chk_filter() - check old bpf
>>         if (bpf_jit_enable)
>>              use new jit
>>         else
>>              use new interpreter
>>      } else {
>>         sk_chk_filter() - check old bpf
>>         if (bpf_jit_enable)
>>             use old jit
>>         else
>>             use old interpreter
>>      }
>>
>> I believe Daniel oked this approach, but if you object, I can do it differently.
>> Are you saying 'bpf_jit_enable' flag should mean: do old jit no matter what?
>> Then we would need another flag 'bpf_ext_jit_enable' as well?
>> Seems overkill to me.
>
> It is not OK to create a temporary regression in between patch sets.
>
> You can make JIT higher priority than EBPF in this series, then once every
> single JIT is converted to EBPF, you can just adjust things accordingly.

ok. will change priority.

Thanks
Alex
