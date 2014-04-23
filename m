From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 5/5] net: filter: optimize BPF migration for
 ARG1/CTX handling
Date: Wed, 23 Apr 2014 15:37:38 -0700
Message-ID: <CAMEtUuzboCLpVXNd+6NQVco=NbX4wcKHt1F+ZkD7DYVpMbBxEw@mail.gmail.com>
References: <1398286621-3591-1-git-send-email-dborkman@redhat.com>
	<1398286621-3591-6-git-send-email-dborkman@redhat.com>
	<CAMEtUux3YZW9G80Da2B3pBB2Sq7C7eC62ntnrVifN8_RJugzHw@mail.gmail.com>
	<53583CEB.3040203@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:39384 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600AbaDWWhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 18:37:40 -0400
Received: by mail-we0-f173.google.com with SMTP id w61so1499125wes.32
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 15:37:38 -0700 (PDT)
In-Reply-To: <53583CEB.3040203@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 23, 2014 at 3:21 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 04/23/2014 11:59 PM, Alexei Starovoitov wrote:
>>
>> On Wed, Apr 23, 2014 at 1:57 PM, Daniel Borkmann <dborkman@redhat.com>
>> wrote:
>>>
>>> Currently, at initial setup in __sk_run_filter() we initialize the
>>> BPF stack's frame-pointer and CTX register. However, instead of the
>>> CTX register, we initialize context to ARG1, and during user filter
>>> migration we emit *always* an instruction that copies the content
>>> from ARG1 to CTX. ARG1 is needed in BPF_CALL instructions to setup
>>> ctx, A, X for call emission. However, we nevertheless copy CTX over
>>> to ARG1 in these cases. So all in all, we always emit one instruction
>>> at BPF program beginning that should have actually been avoided to
>>> spare this overhead.
>>>
>>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>>> Cc: Alexei Starovoitov <ast@plumgrid.com>
>>
>>
>> First 4 patches look great, but this one I have to disagree.
>> See below.
>>
>>> ---
>>>   net/core/filter.c | 10 +---------
>>>   1 file changed, 1 insertion(+), 9 deletions(-)
>>>
>>> diff --git a/net/core/filter.c b/net/core/filter.c
>>> index eada3d5..6fed231 100644
>>> --- a/net/core/filter.c
>>> +++ b/net/core/filter.c
>>> @@ -62,7 +62,6 @@
>>>   #define A      regs[insn->a_reg]
>>>   #define X      regs[insn->x_reg]
>>>   #define FP     regs[BPF_REG_FP]
>>> -#define ARG1   regs[BPF_REG_ARG1]
>>>   #define CTX    regs[BPF_REG_CTX]
>>>   #define K      insn->imm
>>>
>>> @@ -257,7 +256,7 @@ unsigned int __sk_run_filter(void *ctx, const struct
>>> sock_filter_int *insn)
>>>   #define CONT_JMP ({ insn++; goto select_insn; })
>>>
>>>          FP = (u64) (unsigned long) &stack[ARRAY_SIZE(stack)];
>>> -       ARG1 = (u64) (unsigned long) ctx;
>>> +       CTX = (u64) (unsigned long) ctx;
>>
>>
>> R1 (ARG1) is the register that used to pass first argument to the
>> function.
>
>
> Yes that's clear. Which is why f.e. in convert_bpf_extensions() we currently
> copy ctx over to arg1 for calls, i.e.:
>
>   /* arg1 = ctx */
>
>   insn->code = BPF_ALU64 | BPF_MOV | BPF_X;
>   insn->a_reg = ARG1_REG;
>   insn->x_reg = CTX_REG;
>   insn++;
>
>
>> For seamless kernel->bpf->kernel transition we have to follow calling
>> convention, so 'void *ctx' has to go into R1 by design.
>> Storing it into R6 (CTX) will only work for classic filters converted
>> to extended.
>> all native ebpf filters will be broken.
>
>
> My objection was that currently, we do _not_ have _any_ users or even kernel
> API for _native_ filters, at least not in mainline tree. The _main_ users we
> have are currently _all_ being converted, hence this patch. Given that these
> calls have likely just a minority of use cases triggered by tcpdump et al,
> the majority of users still need to do this overhead/additional work.
>
>
>> In documentation we say:
>>      * R1 - R5   - arguments from BPF program to in-kernel function
>> so llvm/gcc are following this ebpf ABI.
>> Calling convention is the same whether to call kernel function from ebpf
>> or ebpf from kernel. So 1st argument (void *ctx) has to go into R1.
>
>
> Yes, that's clear and convert_bpf_extensions() is doing that. So far we're
> not using llvm/gcc backend here and have the internal instruction set not
> exposed to user space, but even there you would need to prepare R1 - R5 to
> hand-over arguments for the BPF_CALL insns, so why can't we load CTX into R1
> at that time just as we do with convert_bpf_extensions()?

How about then removing extra generated R6=R1 from converted and do
both in __sk_run_filter() ?
        regs[ARG1_REG] = (u64) (unsigned long) ctx;
        regs[CTX_REG] = (u64) (unsigned long) ctx;

Overhead problem will be solved and ABI is still clean.

>> By convention ld_abs/ld_ind insns are using implicit input register 'ctx'
>> (R6),
>> that's why we do a copy from R1 into R6 as a first insn of the
>> _converted_ filter.
>
>
> Yep, and R6 stays as is here. So ld_abs/ld_ind insns are correctly using
> 'ctx'.
>
> Best,
>
> Daniel
