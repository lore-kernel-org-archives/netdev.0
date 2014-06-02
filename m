From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next 0/2] split BPF out of core networking
Date: Mon, 2 Jun 2014 08:41:24 -0700
Message-ID: <CAMEtUuzkjZCsReWH9cZs8AU0mJjZH9YOdCBTWusxe6-NZ9mQ=g@mail.gmail.com>
References: <1401692506-7796-1-git-send-email-ast@plumgrid.com>
	<538C3C94.3080206@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <538C3C94.3080206@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 2, 2014 at 1:57 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 06/02/2014 09:01 AM, Alexei Starovoitov wrote:
>>
>> This patch set splits BPF out of core networking into generic component
>>
>> patch #1 splits filter.c into two logical pieces: generic BPF core and
>> socket
>> filters. It only moves functions around. No real changes.
>>
>> patch #2 adds hidden CONFIG_BPF that seccomp/tracing can select
>>
>> The main value of the patch is not a NET separation, but rather logical
>> boundary
>> between generic BPF core and socket filtering. All socket specific code
>> stays in
>> net/core/filter.c and kernel/bpf/core.c is for generic BPF infrastructure
>> (both
>> classic and internal).
>>
>> Note that CONFIG_BPF_JIT is still under NET, so NET-less configs cannot
>> use
>> BPF JITs yet. This can be cleaned up in the future. Also it seems to makes
>> sense
>> to split up filter.h into generic and socket specific as well to cleanup
>> the
>> boundary further.
>
>
> Hm, I really don't like that 'ripping code and headers apart' and then we
> believe
> it's a generic abstraction. So far seccomp-BPF could live with the current
> state
> since it was introduced, the rest of users (vast majority) is in the
> networking
> domain (and invoked through tcpdump et al) ...
>
> There are still parts in seccomp that show some BPF weaknesses in terms of
> being
> 'generic', for example shown in seccomp, we need to go once again over the
> filter
> instructions after doing the usual filter sanity checks, just to whitelist
> what
> seccomp may do in BPF.
>
> I have not yet thought about it deeply enough, but I think we should avoid
> something similar in other non-networking areas but abstract that cleanly
> w/o
> such hacks first, for example.

Glad you brought up this point :)
100% agree that current double verification done by seccomp is far from
being generic and quite hard to maintain, since any change done to
classic BPF verifier needs to be thought through from seccomp_check_filter()
perspective as well.
imo lack of generality in classic BPF is the main reason why we should stop
adding extensions to classic and switch to eBPF for any new features.
the eBPF verifier I posted now long ago is trying to be generic through
customization. The verifier core needs to stay independent of the use case.
BPF's input context, set of allowed calls need to be expressed in a generic way.
Obviously this split by itself won't make classic BPF all of a sudden generic.
It rather defines a boundary of eBPF core.
In eBPF only two instructions are not generic. It's LD_ABS/LD_IND
which are legacy instruction that we had to carry over from classic.
They require input context == sk_buff. That's why core.c had to
#include <skbuff.h> and do '__weak skb_copy_bits()'.
Alternative to that was to #ifdef these two instructions out of interpreter
and #ifndef NET #include <skbuff.h> and ld_abs helper functions in core.c
IMO that would have been ugly for code style, maintenance and testing,
but then core.c would have only one #include <filter.h> and we can
say: 'look eBPF core.c is really generic'

In the next set of patches I'll repost verifier and will explain how single
eBPF verifier core can be used for socket, seccomp, tracing and other
things. Note I'm not saying that we should use eBPF now everywhere.
Classic BPF has its niche and that niche we have to maintain forever.
So let's make sure that eBPF interpreter, its instruction set and its
verifier are staying generic.
This split is only first step in that direction that creates a file boundary
between eBPF core and sockets.

>
>> Tested with several NET and NET-less configs on arm and x86
>>
>> V1->V2:
>> rebase on top of net-next
>> split filter.c into kernel/bpf/core.c instead of net/bpf/core.c
>>
>> Alexei Starovoitov (2):
>>    net: filter: split filter.c into two files
>>    net: filter: split BPF out of core networking
>>
>>   arch/Kconfig           |    6 +-
>>   include/linux/filter.h |    2 +
>>   kernel/Makefile        |    1 +
>>   kernel/bpf/Makefile    |    5 +
>>   kernel/bpf/core.c      | 1063
>> ++++++++++++++++++++++++++++++++++++++++++++++++
>>   net/Kconfig            |    1 +
>>   net/core/filter.c      | 1023
>> +---------------------------------------------
>>   7 files changed, 1079 insertions(+), 1022 deletions(-)
>>   create mode 100644 kernel/bpf/Makefile
>>   create mode 100644 kernel/bpf/core.c
>>
>
