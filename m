From: Y Song <ys114321@gmail.com>
Subject: Re: [PATCH net-next] bpf/verifier: improve disassembly of BPF_END instructions
Date: Thu, 21 Sep 2017 09:30:48 -0700
Message-ID: <CAH3MdRWrNRzMMfADin-Cv172kFOjfE=y_g7pqMXPx6BjKiBoug@mail.gmail.com>
References: <7013ee9d-a8e6-13fd-cc5f-86cf3d8bf4e0@solarflare.com> <20170921155215.jta52sesbiq54vri@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Edward Cree <ecree@solarflare.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f65.google.com ([209.85.213.65]:36111 "EHLO
        mail-vk0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751531AbdIUQba (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 12:31:30 -0400
Received: by mail-vk0-f65.google.com with SMTP id w23so1610180vkw.3
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 09:31:29 -0700 (PDT)
In-Reply-To: <20170921155215.jta52sesbiq54vri@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 21, 2017 at 8:52 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Thu, Sep 21, 2017 at 04:09:34PM +0100, Edward Cree wrote:
>> print_bpf_insn() was treating all BPF_ALU[64] the same, but BPF_END has a
>>  different structure: it has a size in insn->imm (even if it's BPF_X) and
>>  uses the BPF_SRC (X or K) to indicate which endianness to use.  So it
>>  needs different code to print it.
>>
>> Signed-off-by: Edward Cree <ecree@solarflare.com>
>> ---
>> It's not the same format as the new LLVM asm uses, does that matter?
>> AFAIK the LLVM format doesn't comprehend BPF_TO_LE, just assumes that all
>>  endian ops are necessarily swaps (rather than sometimes nops).
>
> that is being fixed and we will fix asm format too.
> Let's pick good format first.
>
>>  kernel/bpf/verifier.c | 13 +++++++++++--
>>  1 file changed, 11 insertions(+), 2 deletions(-)
>>
>> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
>> index 799b245..e7657a4 100644
>> --- a/kernel/bpf/verifier.c
>> +++ b/kernel/bpf/verifier.c
>> @@ -331,20 +331,29 @@ static void print_bpf_insn(const struct bpf_verifier_env *env,
>>       u8 class = BPF_CLASS(insn->code);
>>
>>       if (class == BPF_ALU || class == BPF_ALU64) {
>> -             if (BPF_SRC(insn->code) == BPF_X)
>> +             if (BPF_OP(insn->code) == BPF_END) {
>> +                     if (class == BPF_ALU64)
>> +                             verbose("BUG_alu64_%02x\n", insn->code);
>> +                     else
>> +                             verbose("(%02x) (u%d) r%d %s %s\n",
>> +                                     insn->code, insn->imm, insn->dst_reg,
>> +                                     bpf_alu_string[BPF_END >> 4],
>> +                                     BPF_SRC(insn->code) == BPF_X ? "be" : "le");
>
> yes the bit the same, but please use BPF_SRC(insn->code) == BPF_TO_BE.
> imo
> (u16) r4 endian be
> isn't intuitive.
> Can we come up with some better syntax?
> Like
> bswap16be r4
> bswap32le r4
>
> or
>
> to_be16 r4
> to_le32 r4

Currently, llvm bpf backend uses "bswap16 r4" "bswap32 r2" "bswap64 r2" syntax.

I prefer something like "to_be16 r4" "to_le32 r4", or "bswap2be16"
"bswap2le32" or something similar.
This captures what the operation really is.

Right the support to bswap2le will be added to LLVM soon.

>
> It will be more obvious what's happening.
>
