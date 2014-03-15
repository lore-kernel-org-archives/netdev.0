From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC 0/9] socket filtering using nf_tables
Date: Fri, 14 Mar 2014 21:04:50 -0700
Message-ID: <CAMEtUuzFkCgpvMy-V5iZycfpLQmebc_Jq-MedD=FJn-EEDkdcg@mail.gmail.com>
References: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
	<531EE5A2.7090501@redhat.com>
	<CAMEtUuyJne-8uNtOAK7EcFFQNXz9m7J2DDLGH_GbYe6oWZx1pQ@mail.gmail.com>
	<20140312091500.GA4638@localhost>
	<CAMEtUuztfWniTr+3u6ttuygvG=xYdp0ANn_w9MGqacQvHrXtWA@mail.gmail.com>
	<20140313122913.GA4898@localhost>
	<CAMEtUuwV2=8sVdmfKSOytC8LKsw2RX+fgfxvucSVV0=L0XEkOg@mail.gmail.com>
	<20140314181600.GA2809@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Daniel Borkmann <dborkman@redhat.com>,
	netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:63216 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704AbaCOEEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Mar 2014 00:04:52 -0400
Received: by mail-wg0-f46.google.com with SMTP id b13so2809551wgh.17
        for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 21:04:50 -0700 (PDT)
In-Reply-To: <20140314181600.GA2809@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 14, 2014 at 11:16 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Fri, Mar 14, 2014 at 08:28:05AM -0700, Alexei Starovoitov wrote:
>> On Thu, Mar 13, 2014 at 5:29 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>> > On Wed, Mar 12, 2014 at 08:29:07PM -0700, Alexei Starovoitov wrote:
>> >> On Wed, Mar 12, 2014 at 2:15 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>> > [...]
>>
>> It seems you're assuming that ebpf inherited all the shortcomings
>> of bpf and making conclusion based on that. Not your fault.
>> I didn't explain it well enough.
>
> Frankly, from the *interface point of view* it is indeed inheriting
> all of its shortcomings...

Hi Pablo, David,

Let's go back to what ebpf is...
ebpf == generalization of assembler instructions across different architectures.

Take x86_64 instructions ld/st/alu/mov/cmp/call/jmp and
then rename them into my_ld, my_st, my_add, my_call, etc
Then do the same for arm64.
Also rename register names into r0,r1,r2
and remember how you did the mapping.
Also analyze x86_64, arm64 call convention, so that callee saved
registers are mapped to the same regs and arguments are passed
in r1, r2, ...

A function call in such assembler will look like:
my_mov r1, 1
my_mov r2, 2
my_call foo

that maps back to x86_64:
mov rdi, 1
mov rsi, 2
call foo

Since calling convention is compatible between 'renamed assembler'
and original x86_64 or arm assembler, the program written in 'renamed
assembler' can call native functions directly.
The opposite is also true.
Functions written in x86 assembler or C can call into functions
written in 'renamed' assembler.
Example:

f1.s:
 mov rdi, 1
 mov rsi, 2
 call f2
 ret

f2.s:
  my_mov r3, r1
  my_mov r2, r1
  my_mov r1, r3
  my_call f3
  my_ret

f3.s:
  mov rax, rdi
  sub  rax, rsi
  ret

fyi, in C these assembler blobs roughly do:
u64 f1() { return f2(1,2); }
u64 f2(u64 a, u64 b) { return f3(b, a); }
u64 f3(u64 a, u64 b) { return a - b; }

f1.s and f3.s are written in x86_64 and f2.s is written in 'renamed assembler'.

compile f1.s, f3.s into binary x86 code
compile f2.s into some binary code
(either fixed insn size or variable, that's irrelevant), let's call it format B

Now load all three binary blobs into kernel.
1st and 3rd blob can be loaded as-is.
2nd blob needs to be remapped from format B into x86_64 binary code.

After that CPU can call f1() and receive 1 back.

What programs can be written in x86_64 assembler? Anything.
What programs can be written in renamed assembler? Anything.

How often do we want to extend x86_64 assembler? Rarely.
Only when an algorithm implemented in pure x86_64 needs
mmx/ssa acceleration.
Intel does not extend x86 to add a feature, but to accelerate a feature.
Same with 'renamed' assembler.
Any algorithm can be implemented using renamed assembler.

So what is ebpf? It's a format B. It can be fixed size or variable.
That is irrelevant. While loading, the program in format B is
reverse mapped into x86 binary code.

What programs can be written in format B? Anything.
Does format B needs to be extended to support nft? no
to support socket filters? no
to support tracing filters? no
to support crazy idea that will come N years from now? no
Hard to believe? Think back that it is renamed x86 assembler.

Format B was chosen to look like bpf to make an adoption easier
and to make conversion from bpf to ebpf trivial,
but looks like it was a bad idea.
I should have just called it 'simplified x86_64 insn set'.

Now about 'user interface point of view'...
old bpf, netlink, nft format are interfaces.
Until format B is exposed to user space it is not an interface.
nftables can use format B to jit the code.
nftables's user interface doesn't change.

In the patches I sent, ebpf is _not_ exposed to the user.
My patch set immediately helps performance of existing
socket filters and seccomp.
And can do jitting for nft.

Another way of thinking about ebpf:
ebpf is a different way of encoding x86 insns.

I also think we can expose ebpf to the user space,
but that's a different patch and a different discussion.

Thanks!

Hi Pablo,

now back to our discussion:

>> Technically ebpf is a small evolution of bpf, but applicability made a
>> giant leap. I cannot compile C into bpf, but I can do that with ebpf.
>
> Good that we can get better userspace tools, but still the layout of
> your instructions is exposed to userspace so it cannot be changed
> *ever*. The kernel interface is still an array of binary structures of
> fixed size just like BPF does.

that fixed size is irrelevant from extensibility point of view.
sparc has fixed size instructions too, but we don't change sparc
instruction width.
Let's say we decided to remap all sparc instructions and add new
pseudo instructions. These pseudo sparc insns won't buy us any
performance, because in the end they're remapped into real
instructions that cpu can execute.
These fake new pseudo sparc instructions won't give us
any new features either.

Format B should not be changed.
We can add new instructions if we really really need,
but there will not be a need to change existing insns.
Hard to believe? Think back that it is simplified x86.
We don't have a need to change existing x86 insns.

Example 1:
there are xadd_w and xadd_dw insns in format B to do
atomic increments. They don't have to be in the instruction set.
I've added them for performance and not because it cannot
be done without them.
atomic increments could have been done with function call.
ebpf call insn is #1 instruction that was missing in bpf.
It makes ebpf usable for any job.
ebpf program can always call a function.

Example 2:
In old bpf there are many extensions that fetch skb->protocol,
skb->len, skb->pkt_type and so on.
One extension per skb field. That was bad.
They were done as instruction extensions in old bpf,
because bpf didn't have a generic load operation.
ebpf doesn't need extensions for them. All these old bpf
extensions are converted to generic 'load' insn in ebpf.
and jited to x86 as single load, whereas old bpf jit needs
to have its own 'case' statement for every extension.

We can gradually replace old bpf jits with new ebpf jits.
and take time while doing this without exposing ebpf
to the userspace.

Example 3:
Old bpf_s_anc_nlattr extension cannot be jited with
current bpf jit, because it's too complicated
(requires thinking about calling convention, etc)
After conversion to ebpf it finally can be jited,
since it becomes a function call in x86.

That's the point. We do not need to change ebpf insn set.
Anything can be implemented as generic load/store operations
and function calls because ebpf == x86 assembler.

> Why do we have to have a 32 bits immediate that may be zero most of
> the time? Just because:
>
> 1) You needed to align your new instruction layout to 64 bits / two 32
> bits words.

wrong guess. It's not alignment.
Format B could be anything.
I just picked it to be similar to old BPF to be easier to understand.
Apparently it's not that easy.

> 2) You noticed you get better performance with those changes,
> including the new "if" statement that works better with branch
> prediction.

nope. that's a side effect of 'simplified x86 assembler'
Neither x86 nor arm nor other CPUs have 'dual branch'
instructions. All CPUs either branch or fall through and
since ebpf is just a simplified x86 here you have such
style of branches.

> 3) It's easier for you to make the jit translation.

sorry, but 'easier' was not a factor.
ebpf instructions are 8-byte wide, just because old bpfs are
8-byte wide. I fitted all x86 instructions into 8 bytes.
Could have picked any other size.

Another way of thinking about ebpf:
ebpf is a different way of encoding x86 insns.

Whether instructions are variable length or fixed, it's
the same complexity to map back to x86.

ebpf interpreter is a different matter.
Interpreter obviously works better with fixed insn size.
ebpf interpreter you see only exists to support architectures
that don't have ebpf->native mapper yet.

If majority thinks that variable length insns will work better,
let's re-encode the whole thing into variable length.
I just don't see what it will buy us.
but I'm fine re-encoding ebpf into any other format.
Obviously 'simplified x86/arm insn set' can have any format,
as long as it is convenient to execute by interpreter,
not too complex for remapping into native
and has room to add instructions.
imo proposed ebpf format fits these three attributes just fine.

> That means your interface is exposing *all of your internal
> implementation decisions* and that's a very bad since we will always
> have to come up with smart tricks not to break backward compatibility
> if we want to improve the internal implementation.

We're not going to go back and break compatibility.
We're not breaking compatibility now either.
Did Intel change x86 encoding? no.
Same with ebpf. We don't need to change ebpf encoding.

>> I cannot do table lookups in bpf, but I can do that in ebpf.
>> I cannot rewrite packet headers in bpf, but I can do that in ebpf, etc.
>
> Sorry, I don't buy this "we get more features" if in the long run we
> have restricted extensibility.

That's not productive to keep saying 'restricted extensibility'
without providing a specific example.
Please come up with at least one case that ebpf cannot
handle as presented.
What instructions do you think are missing?

>> Here is the example from V2 series that shows how hash tables can be
>> used in C that translates to ebpf, without changing ebpf itself:
>> void dropmon(struct kprobe_args *ctx)
>> {
>>         void *loc;
>>         uint64_t *drop_cnt;
>>         /* skb:kfree_skb is defined as:
>>          * TRACE_EVENT(kfree_skb,
>>          *         TP_PROTO(struct sk_buff *skb, void *location),
>>          * so ctx->arg2 is 'location'
>>          */
>>         loc = (void *)ctx->arg2;
>>
>>         drop_cnt = bpf_table_lookup(ctx, 0, &loc);
>
> Is there room to extend your framework with any other data structure
> which is *not* a hashtable? What are you plans for that?

Please understand hashtable or xyztable is not an ebpf instruction.
It is a function call.
Generic call.
ebpf can call any function.
ebpf doesn't need to change a single bit to support other tables.
ebpf jits don't need to change either.
How table is implemented is out side of ebpf scope.
Type of keys, values are arbitrary.
bpf_table_lookup() is a C function inside kernel that ebpf
program calls.

> The only different that I see with ebpf is that you provide nice end
> user tools, but the design from the kernel interface has exactly the
> same problems.

ok. what problems? Please be specific.

>> > Right, you can extend interfaces forever with lots of patchwork and
>> > "smart tricks" but that doesn't mean that will look nice...
>>
>> I'm not sure what you mean here.
>
> For example, this:
>
> diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
> index cf9cd13509a7..e1b979312588 100644
> --- a/net/core/sysctl_net_core.c
> +++ b/net/core/sysctl_net_core.c
> @@ -273,6 +273,13 @@  static struct ctl_table net_core_table[] = {
>         },
>  #endif
>         {
> +               .procname       = "bpf_ext_enable",
> +               .data           = &bpf_ext_enable,
> +               .maxlen         = sizeof(int),
> +               .mode           = 0644,
> +               .proc_handler   = proc_dointvec
> +       },
>
> This /proc thing seems to me like the last resource we have to avoid
> breaking backward compatibility. I have used it as well myself, but
> it's like the *pull alarm* when we did a wrong design decision.
>
> What if we need a new ABI breakage for BPF again? Will we need to add
> a new /proc interface for that? As far as I can tell from your
> patches, the answer is yes.

Where do you see ABI breakage? It's not broken.
I can remove bpf_ext_enable flag.
On or off it doesn't break any user interface.
Socket filters are still loading old bpf programs.
seccomp is still loading old bpf programs.
They get converted on the fly to new ebpf.
I added the flag only to be able to easily benchmark two interpreters.
We're planning to remove old bpf interpreter. It's obsolete.
Just like old sk_decode_filter().
This /proc flag doesn't need to be there. It can be removed.
Not a single user space app will notice the difference,
other than faster performance.

>> > As I said, I believe that having a nice extensible interface is
>> > extremely important to make it easier for development. If we have to
>> > rearrange the internal representation for some reason, we can do it
>> > indeed without bothering about making translations to avoid breaking
>> > userspace and having to use ugly tricks (just see sk_decode_filter()
>> > or any other translation to support any new way to express a
>> > filter...).
>>
>> nice that your brought this up :)
>> As I mentioned in v4 thread sk_decode_filter() can be removed.
>> It was introduced to improve old interpreter performance and now
>> this part is obsolete.
>
> What are your plans then? Will you implement that converter in
> userspace? You mention that you don't want to enhance libpcap, which
> seems to me like the natural way to extend things.

Please see 1/3 patch. Converter from old bpf to ebpf takes 263 lines
of trivial remapping. It's that simple.

>> >> Say you want to translate nft-cmp instruction into sequence of native
>> >> comparisons. You'd need to use load from memory, compare and
>> >> branch operations. That's ebpf!
>> >
>> > Nope sorry, that's not ebpf. That's assembler code.
>>
>> Well, in my previous email I tried to explain that assembler == ebpf :)
>
> I see, so I was right. You want to expose a pseudo-assembler
> interface just because that makes it easier to you to provide the jit
> translation.

If you're saying that ebpf == assembler, then yes, you're right.

>> Please post x86_64 assembler code that future nft-jit suppose to
>> generate and I can post equivalent ebpf code that will be jited
>> exactly to your x86_64...
>
> That's possible of course. There are many ways to implement the same
> thing, they can provide the same features, but not the same degree of
> extensibility.

Totally agree. nft is definitely less extensible than ebpf.
You need to change nft for every new feature, whereas I don't need
to change ebpf. I don't need to change ebpf jits either.

Key point is: ebpf does not _need_ to be changed.
There are still plenty of reserved bits, so new instructions can be
added to improve performance, but so far I don't see a need.
We don't _have_ to add instructions. There is always
a way to do with what it has now.
It is a complete instruction set to support any integer program.
Yeah, floating point is not supported and will not be.

Thanks
Alexei
