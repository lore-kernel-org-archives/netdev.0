From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] net: filter: cleanup A/X name usage
Date: Mon, 9 Jun 2014 12:25:21 -0700
Message-ID: <CAMEtUux+sj7o9=57JAaHvGJXJmfuyRKb+dFL_3ZdkmAoHy9XzA@mail.gmail.com>
References: <1402091166-5206-1-git-send-email-ast@plumgrid.com>
	<5394C5CB.7050000@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:56648 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753984AbaFITZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 15:25:22 -0400
Received: by mail-we0-f177.google.com with SMTP id u56so4102702wes.8
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 12:25:21 -0700 (PDT)
In-Reply-To: <5394C5CB.7050000@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 8, 2014 at 1:21 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 06/06/2014 11:46 PM, Alexei Starovoitov wrote:
>>
>> The macro 'A' used in internal BPF interpreter:
>>   #define A regs[insn->a_reg]
>> was easily confused with the name of classic BPF register 'A', since
>> 'A' would mean two different things depending on context.
>>
>> This patch is trying to clean up the naming and clarify its usage in the
>> following way:
>>
>> - A and X are names of two classic BPF registers
>>
>> - BPF_REG_A denotes internal BPF register R0 used to map classic register
>> A
>>    in internal BPF programs generated from classic
>>
>> - BPF_REG_X denotes internal BPF register R7 used to map classic register
>> X
>>    in internal BPF programs generated from classic
>>
>> - internal BPF instruction format:
>> struct sock_filter_int {
>>          __u8    code;           /* opcode */
>>          __u8    dst_reg:4;      /* dest register */
>>          __u8    src_reg:4;      /* source register */
>>          __s16   off;            /* signed offset */
>>          __s32   imm;            /* signed immediate constant */
>> };
>>
>> - BPF_X/BPF_K is 1 bit used to encode source operand of instruction
>> In classic:
>>    BPF_X - means use register X as source operand
>>    BPF_K - means use 32-bit immediate as source operand
>> In internal:
>>    BPF_X - means use 'src_reg' register as source operand
>>    BPF_K - means use 32-bit immediate as source operand
>>
>> Suggested-by: Chema Gonzalez <chema@google.com>
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>
>
> Acked-by: Daniel Borkmann <dborkman@redhat.com>
>
> You could also have mentioned in the changelog that you replace
> direct access to ctx pointer with CTX register, it's valid since
> we emit a mov from ARG1 to CTX at the beginning which contains
> ctx. Anyway, looks good to me.

Point taken. Will do more thorough documentation patch to
explain eBPF instruction set a bit better. Mainly to clarify encoding.
eBPF tried to be as close as possible to classic BPF, since I thought
it will make it easier to understand. That's why I reused A/X in names
and bits in opcode encoding.
In classic, A is accumulator and X is indeX. In eBPF I thought
calling destination register 'a_reg' made sense, since it would
indicate that this 'a_reg' is a register that is used as 'accumulator'
in the instruction. Like in "bpf_add R2, 5", R2 is Accumulator.
In "bpf_add R2, R3", R2  is Accumulator and R3 is indeX
and BPF_X bit in opcode indicates whether 'x_reg' field of the
instruction is used. Unfortunately that decision caused the whole
A/X naming confusion, that this patch is addressing.
src_reg and dst_reg are indeed better names.
The next patch of doc updates hopefully will make encoding clear too.

Thanks guys for reviewing.
