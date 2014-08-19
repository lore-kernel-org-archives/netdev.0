From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC v4 net-next 17/26] tracing: allow eBPF programs to be
 attached to events
Date: Tue, 19 Aug 2014 11:39:09 -0700
Message-ID: <CAMEtUuwF+CRjzhn-gj_CPAyuaNSAx70gp47hx7DXw3SeGtvZow@mail.gmail.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
	<1407916658-8731-18-git-send-email-ast@plumgrid.com>
	<CAE40pdf0pNYyazjpdkzxNJi7iC4LOOr_XEu078OUqP_uoCXnHg@mail.gmail.com>
	<CAMEtUuymPDhYBe42i4DJNXsdgZRaq9LuEU_nGSsqrY1FcFHqhQ@mail.gmail.com>
	<CALCETrVH8KXr8uSHAVy5eBsqmi1LjB5QZpboAGcjYswXvW1opA@mail.gmail.com>
	<CAMEtUuzey7PanznrAguOpvPLxyhgJB++ovE8RNys7srs=EY1qg@mail.gmail.com>
	<CALCETrVhjO5c7ob1vntx031c5RmxRHimkRt1F2EsmzdKB53_NA@mail.gmail.com>
	<CAMEtUuzT53jeH-L+saW-RopSR2EERO5UKVHyeORTGHVMCHbYag@mail.gmail.com>
	<CALCETrUNvg88_VrwE+9RKnSgts=3zVcXbX6tuNLgUxJU436CrQ@mail.gmail.com>
	<CAMEtUuwF2_+qzkaW6rkw9cyYJ2eb01B_ZyBcwrJ7nd+GqN5-mQ@mail.gmail.com>
	<CALCETrUqop+UB-BhyX4Y41kELO+6kcFdS1F7ZyN0CzRwg4UGhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux API <linux-api@vger.kernel.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Kees Cook <keescook@chromium.org>,
	Network Development <netdev@vger.kernel.org>,
	Ingo Molnar <mingo@kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrUqop+UB-BhyX4Y41kELO+6kcFdS1F7ZyN0CzRwg4UGhA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 15, 2014 at 12:18 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Fri, Aug 15, 2014 at 12:16 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> This bpf_context struct for tracing is trying to answer the question:
>>  'what's the most convenient way to access tracepoint arguments
>> from a script'.
>> When kernel code has something like:
>>  trace_kfree_skb(skb, net_tx_action);
>> the script needs to be able to access this 'skb' and 'net_tx_action'
>> values through _single_ data structure.
>> In this proposal they are ctx->arg1 and ctx->arg2.
>> I've considered having different bpf_context's for every event, but
>> the complexity explodes. I need to hack all event definitions and so on.
>> imo it's better to move complexity to userspace, so program author
>> or high level language abstracts these details.
>
> I still don't understand why making them long instead of u64 is
> helpful, though.  I feel like I'm missing obvious here.

The problem statement:
- tracepoint events are defined as:
  TRACE_EVENT(sock_exceed_buf_limit,
    TP_PROTO(struct sock *sk, struct proto *prot, long allocated),
    TP_ARGS(sk, prot, allocated),

- from eBPF C program (or higher level language) I would like
  to access these tracepoint arguments as
  ctx->arg1, ctx->arg2, ctx->arg3

- accessing tracepoint fields after buffer copy is not an option,
  since it's unnecessary alloc/copy/free of a lot of values
  (including strings) per event that programs will mostly ignore.
  If needed, programs can fetch them on demand.

Bad approach #1
- define different bpf_context per event and customize eBPF verifier
  to have different program types per event, so particular program
  can be attached to one particular event only
Cons: quite complex, require trace/events/*.h hacking,
  one ebpf program cannot be used to attach to multiple events
So #1 is no go.

Approach #2
- define bpf_context once for all tracepoint events as:
  struct bpf_context {
    unsigned long arg1, arg2, arg3, ...
  };
  and main ftrace.h macro as:
    struct bpf_context ctx;
    populate_bpf_context(&ctx, args, 0, 0, 0, 0, 0);
    trace_filter_call_bpf(ftrace_file->filter, &ctx);
  where 'args' is a macro taken from TP_ARGS above and
  /* called from ftrace_raw_event_*() to copy args */
  void populate_bpf_context(struct bpf_context *ctx, ...)
  {
    va_start(args, ctx);
    ctx->arg1 = va_arg(args, unsigned long);
    ctx->arg2 = va_arg(args, unsigned long);
this approach relies on type promotion when args are passed
into vararg function.
On 64-bit arch our tracepoint arguments 'sk, prot, allocated' will
get stored into arg1, arg2, arg3 and the rest of argX will be zeros.
On 32-bit 'u64' types will be passed in two 'long' slots of vararg.
Obviously changing 'long' to 'u64' in bpf_context and in
populate_bpf_context() will not work, because types
are promoted to 'long'.
Disadvantage of this approach is that 32 vs 64 bit archs need to
deal with argX differently.
That's what you saw in this patch.

New approach #3
just discovered __MAPx() macro used by syscalls.h which can
be massaged for this use case, so define:
struct bpf_context {
  u64 arg1, arg2, arg3,...
};
and argument casting macro as:
#define __BPF_CAST1(a,...) __CAST_TO_U64(a)
#define __BPF_CAST2(a,...) __CAST_TO_U64(a), __BPF_CAST1(__VA_ARGS__)
..
#define __BPF_CAST(a,...)  __CAST_TO_U64(a), __BPF_CAST6(__VA_ARGS__)

so main ftrace.h macro becomes:
struct bpf_context __ctx = ((struct bpf_context) {
  __BPF_CAST(args, 0, 0, 0, 0, 0, 0)
});
trace_filter_call_bpf(ftrace_file->filter, &__ctx);

where 'args' is still the same 'sk, prot, allocated' from TP_ARGS.
Casting macro will cast 'sk' to u64 and will assign into arg1,
'prot' will be casted to u64 and assigned to arg2, etc

All good, but the tricky part is how to cast all arguments passed
into tracepoint events into u64 without warnings on
32-bit and 64-bit architectures.
The following:
#define __CAST_TO_U64(expr) (u64) expr
will not work, since compiler will be spewing warnings about
casting pointer to integer...
The following
#define __CAST_TO_U64(expr) (u64) (long) expr
will work fine on 64-bit architectures, since all integer and
pointer types will be warning-free casted and stored
in arg1, arg2, arg3, ...
but it won't work on 32-bit architectures, since full u64
tracepoint arguments will be chopped to 'long'.

It took a lot of macro wizardry to come up with the following:
/* cast any interger or pointer type to u64 without warnings */
#define __CAST_TO_U64(expr) \
         __builtin_choose_expr(sizeof(long) < sizeof(expr), \
                               (u64) (expr - ((typeof(expr))0)), \
                               (u64) (long) expr)
the tricky part is that GCC syntax-parses and warns
in both sides of __builtin_choose_expr(), so u64 case in 32-bit
archs needs to be fancy, so all types can go through it
warning free.
Though it's tricky the end result is nice.
The disadvantages of approach #2 are solved and tracepoint
arguments are stored into 'u64 argX' on both 32 and 64-bit archs.
The extra benefit is that this casting macro is way faster than
vararg approach #2.
So in V5 of this series I'm planning to use this new approach
unless there are better ideas.
full diff of this approach:
https://git.kernel.org/cgit/linux/kernel/git/ast/bpf.git/commit/?id=235d87dd7afd8d5262556cba7882d6efb25d8305
