From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 5/5] net: filter: optimize BPF migration for
 ARG1/CTX handling
Date: Wed, 23 Apr 2014 20:05:23 -0700
Message-ID: <CAMEtUuy82KA90_0CtkwwZMAXaWbpwtR1RBt9neb1CuX6v-EstA@mail.gmail.com>
References: <1398286621-3591-1-git-send-email-dborkman@redhat.com>
	<1398286621-3591-6-git-send-email-dborkman@redhat.com>
	<CAMEtUux3YZW9G80Da2B3pBB2Sq7C7eC62ntnrVifN8_RJugzHw@mail.gmail.com>
	<53583CEB.3040203@redhat.com>
	<CAMEtUuzboCLpVXNd+6NQVco=NbX4wcKHt1F+ZkD7DYVpMbBxEw@mail.gmail.com>
	<5358453E.4050005@redhat.com>
	<CAMEtUuzT6smejsgoKP5c_NCw8mQw39xfPR+hsfV1Oh77ZeG3bA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:40541 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451AbaDXDFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 23:05:24 -0400
Received: by mail-wi0-f180.google.com with SMTP id q5so374571wiv.13
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 20:05:23 -0700 (PDT)
In-Reply-To: <CAMEtUuzT6smejsgoKP5c_NCw8mQw39xfPR+hsfV1Oh77ZeG3bA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 23, 2014 at 4:14 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On Wed, Apr 23, 2014 at 3:57 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> On 04/24/2014 12:37 AM, Alexei Starovoitov wrote:
>>>
>>> On Wed, Apr 23, 2014 at 3:21 PM, Daniel Borkmann <dborkman@redhat.com>
>>> wrote:
>>>>
>>>> On 04/23/2014 11:59 PM, Alexei Starovoitov wrote:
>>>>>
>>>>> On Wed, Apr 23, 2014 at 1:57 PM, Daniel Borkmann <dborkman@redhat.com>
>>>>> wrote:
>>>>>>
>>>>>>
>>>>>> Currently, at initial setup in __sk_run_filter() we initialize the
>>>>>> BPF stack's frame-pointer and CTX register. However, instead of the
>>>>>> CTX register, we initialize context to ARG1, and during user filter
>>>>>> migration we emit *always* an instruction that copies the content
>>>>>> from ARG1 to CTX. ARG1 is needed in BPF_CALL instructions to setup
>>>>>> ctx, A, X for call emission. However, we nevertheless copy CTX over
>>>>>> to ARG1 in these cases. So all in all, we always emit one instruction
>>>>>> at BPF program beginning that should have actually been avoided to
>>>>>> spare this overhead.
>>>>>>
>>>>>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>>>>>> Cc: Alexei Starovoitov <ast@plumgrid.com>
>>>>>
>>>>>
>>>>> First 4 patches look great, but this one I have to disagree.
>>>>> See below.
>>>>>
>>>>>> ---
>>>>>>    net/core/filter.c | 10 +---------
>>>>>>    1 file changed, 1 insertion(+), 9 deletions(-)
>>>>>>
>>>>>> diff --git a/net/core/filter.c b/net/core/filter.c
>>>>>> index eada3d5..6fed231 100644
>>>>>> --- a/net/core/filter.c
>>>>>> +++ b/net/core/filter.c
>>>>>> @@ -62,7 +62,6 @@
>>>>>>    #define A      regs[insn->a_reg]
>>>>>>    #define X      regs[insn->x_reg]
>>>>>>    #define FP     regs[BPF_REG_FP]
>>>>>> -#define ARG1   regs[BPF_REG_ARG1]
>>>>>>    #define CTX    regs[BPF_REG_CTX]
>>>>>>    #define K      insn->imm
>>>>>>
>>>>>> @@ -257,7 +256,7 @@ unsigned int __sk_run_filter(void *ctx, const
>>>>>> struct
>>>>>> sock_filter_int *insn)
>>>>>>    #define CONT_JMP ({ insn++; goto select_insn; })
>>>>>>
>>>>>>           FP = (u64) (unsigned long) &stack[ARRAY_SIZE(stack)];
>>>>>> -       ARG1 = (u64) (unsigned long) ctx;
>>>>>> +       CTX = (u64) (unsigned long) ctx;
>>>>>
>>>>>
>>>>>
>>>>> R1 (ARG1) is the register that used to pass first argument to the
>>>>> function.
>>>>
>>>>
>>>> Yes that's clear. Which is why f.e. in convert_bpf_extensions() we
>>>> currently
>>>> copy ctx over to arg1 for calls, i.e.:
>>>>
>>>>    /* arg1 = ctx */
>>>>
>>>>    insn->code = BPF_ALU64 | BPF_MOV | BPF_X;
>>>>    insn->a_reg = ARG1_REG;
>>>>    insn->x_reg = CTX_REG;
>>>>    insn++;
>>>>
>>>>> For seamless kernel->bpf->kernel transition we have to follow calling
>>>>> convention, so 'void *ctx' has to go into R1 by design.
>>>>> Storing it into R6 (CTX) will only work for classic filters converted
>>>>> to extended.
>>>>> all native ebpf filters will be broken.
>>>>
>>>>
>>>> My objection was that currently, we do _not_ have _any_ users or even
>>>> kernel
>>>> API for _native_ filters, at least not in mainline tree. The _main_ users
>>>> we
>>>> have are currently _all_ being converted, hence this patch. Given that
>>>> these
>>>> calls have likely just a minority of use cases triggered by tcpdump et
>>>> al,
>>>> the majority of users still need to do this overhead/additional work.
>>>>
>>>>> In documentation we say:
>>>>>       * R1 - R5   - arguments from BPF program to in-kernel function
>>>>> so llvm/gcc are following this ebpf ABI.
>>>>> Calling convention is the same whether to call kernel function from ebpf
>>>>> or ebpf from kernel. So 1st argument (void *ctx) has to go into R1.
>>>>
>>>>
>>>> Yes, that's clear and convert_bpf_extensions() is doing that. So far
>>>> we're
>>>> not using llvm/gcc backend here and have the internal instruction set not
>>>> exposed to user space, but even there you would need to prepare R1 - R5
>>>> to
>>>> hand-over arguments for the BPF_CALL insns, so why can't we load CTX into
>>>> R1
>>>> at that time just as we do with convert_bpf_extensions()?
>>>
>>>
>>> How about then removing extra generated R6=R1 from converted and do
>>> both in __sk_run_filter() ?
>>>          regs[ARG1_REG] = (u64) (unsigned long) ctx;
>>>          regs[CTX_REG] = (u64) (unsigned long) ctx;
>>>
>>> Overhead problem will be solved and ABI is still clean.
>>
>>
>> Well, I just don't understand the concerns of ABI here. Given that we do not
>> have any native BPF code to maintain in the kernel tree and given that we
>> currently do not expose the instruction set to user space, we're free to do
>> what we want, no? Eventually what's in mainline kernel is that dictates an
>> ABI, so far we have it only in kernel space and the only current user of the
>> ABI is the conversion function from user BPF programs. Given that helper
>
> well, all the patches for llvm and the rest were posted.
> Obviously they cannot go in at once, but breaking this ABI right now
> makes it impossible to continue working on them.
> I want to make ebpf engine to be useful for tracing filters and so on.
> Are you saying forget it, this is classic bpf engine only?
>
>> function calls may happen less often than executing instructions from the
>> rest of the code, why can't your llvm/gcc backend emit the load of ctx into
>> arg1? JITs don't need to treat that differently in any way, imho. Simply
>
> I don't think we're on the same page here. compiler at the end is just
> a piece of sw and can do everything, but imbalanced ebpf ABI is really
> out of normal compiler work flow.
> Pretty much compiler somehow need to generate one way of passing
> arguments into a function, but inside the function it needs to expect
> them in different registers?! That is practically impossible to do
> in normal gcc/llvm.

Have to correct myself here.
sparc is an architecture where args are passed in %o regs
and received by the callee in %i regs, so there is a precedent.
but it's a unique sliding register window architecture.
ebpf ABI is picked carefully to match x86/arm ABI one to one where
in/out regs are the same.

The following patch does the same.
It saves one extra copy insn and doesn't break ABI.
imo much better solution.

diff --git a/net/core/filter.c b/net/core/filter.c
index 78a636e60a0b..a12f62a64ed1 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -242,6 +242,7 @@ unsigned int __sk_run_filter(void *ctx, const
struct sock_filter_int *insn)

        regs[FP_REG]  = (u64) (unsigned long) &stack[ARRAY_SIZE(stack)];
        regs[ARG1_REG] = (u64) (unsigned long) ctx;
+       regs[CTX_REG] = regs[ARG1_REG];

 select_insn:
        goto *jumptable[insn->code];
@@ -893,13 +894,6 @@ do_pass:
        new_insn = new_prog;
        fp = prog;

-       if (new_insn) {
-               new_insn->code = BPF_ALU64 | BPF_MOV | BPF_X;
-               new_insn->a_reg = CTX_REG;
-               new_insn->x_reg = ARG1_REG;
-       }
-       new_insn++;
-
        for (i = 0; i < len; fp++, i++) {
                struct sock_filter_int tmp_insns[6] = { };
                struct sock_filter_int *insn = tmp_insns;

> Even without any compiler insight.
> If you insist on ctx to be in R6 only, then please kill the whole
> concept of ABI in the doc. It doesn't make sense to pass a value
> into a function in R1, but the function will see in R6?!
>
>> the one who is generating the BPF insns needs to emit ctx into arg1 just as
>> he prepares the other argX registers. Btw, since we know a priori that
>> __skb_get_pay_offset() and __get_raw_cpu_id() are not making use of all
>> prepared registers, we could even go that far and avoid preparing loads for
>> the two.
