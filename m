From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: don't let ldimm64 leak map addresses on unprivileged
Date: Mon, 08 May 2017 00:51:02 +0200
Message-ID: <590FA4D6.4060206@iogearbox.net>
References: <793c517a7d163c613ab886eb02d32efea9f902fd.1494194233.git.daniel@iogearbox.net> <CAG48ez0S92fLmX5fEa1=HNC3wF+SYizske5MjiJDpW4=tLg6Uw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        kafai@fb.com, netdev@vger.kernel.org
To: Jann Horn <jannh@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56172 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750815AbdEGWvN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 7 May 2017 18:51:13 -0400
In-Reply-To: <CAG48ez0S92fLmX5fEa1=HNC3wF+SYizske5MjiJDpW4=tLg6Uw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/08/2017 12:26 AM, Jann Horn wrote:
> On Mon, May 8, 2017 at 12:04 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> The patch fixes two things at once:
>>
>> 1) It checks the env->allow_ptr_leaks and only prints the map address to
>>     the log if we have the privileges to do so, otherwise it just dumps 0
>>     as we would when kptr_restrict is enabled on %pK. Given the latter is
>>     off by default and not every distro sets it, I don't want to rely on
>>     this, hence the 0 by default for unprivileged.
>>
>> 2) Printing of ldimm64 in the verifier log is currently broken in that
>>     we don't print the full immediate, but only the 32 bit part of the
>>     first insn part for ldimm64. Thus, fix this up as well; it's okay to
>>     access, since we verified all ldimm64 earlier already (including just
>>     constants) through replace_map_fd_with_map_ptr().
>>
>> Fixes: cbd357008604 ("bpf: verifier (add ability to receive verification log)")
>> Reported-by: Jann Horn <jannh@google.com>
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> [...]
>> @@ -362,9 +363,19 @@ static void print_bpf_insn(struct bpf_insn *insn)
>>                                  insn->code,
>>                                  bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
>>                                  insn->src_reg, insn->imm);
>> -               } else if (BPF_MODE(insn->code) == BPF_IMM) {
>> -                       verbose("(%02x) r%d = 0x%x\n",
>> -                               insn->code, insn->dst_reg, insn->imm);
>> +               } else if (BPF_MODE(insn->code) == BPF_IMM &&
>> +                          BPF_SIZE(insn->code) == BPF_DW) {
>> +                       /* At this point, we already made sure that the second
>> +                        * part of the ldimm64 insn is accessible.
>> +                        */
>> +                       u64 imm = ((u64)(insn + 1)->imm << 32) | (u32)insn->imm;
>> +                       bool map_ptr = insn->src_reg == BPF_PSEUDO_MAP_FD;
>> +
>> +                       if (map_ptr && !env->allow_ptr_leaks)
>> +                               imm = 0;
>> +
>> +                       verbose("(%02x) r%d = 0x%llx\n", insn->code,
>> +                               insn->dst_reg, (unsigned long long)imm);
>>                  } else {
>>                          verbose("BUG_ld_%02x\n", insn->code);
>>                          return;
>
> You replaced the `BPF_MODE(insn->code) == BPF_IMM` branch with a
> `BPF_MODE(insn->code) == BPF_IMM && BPF_SIZE(insn->code) == BPF_DW`
> branch. Doesn't that break printing normal immediates?

What do you mean by 'normal' immediates? You mean loads of imm into
register, right? The ldimm64 is kind of special treated; for imms
fitting into 32 bit, there is BPF_MOV64_IMM() and BPF_MOV32_IMM()
otherwise.

F.e. see the jumptable in __bpf_prog_run(), which is the interpreter.
All BPF_LD instructions that we have are:

static const void *jumptable[256] = {
   [...]
   [BPF_LD | BPF_ABS | BPF_W] = &&LD_ABS_W,
   [BPF_LD | BPF_ABS | BPF_H] = &&LD_ABS_H,
   [BPF_LD | BPF_ABS | BPF_B] = &&LD_ABS_B,
   [BPF_LD | BPF_IND | BPF_W] = &&LD_IND_W,
   [BPF_LD | BPF_IND | BPF_H] = &&LD_IND_H,
   [BPF_LD | BPF_IND | BPF_B] = &&LD_IND_B,
   [BPF_LD | BPF_IMM | BPF_DW] = &&LD_IMM_DW,
};

In the print_bpf_insn() under class == BPF_LD, the BPF_ABS and BPF_IND
are separately handled (load of packet data from skb), and the BPF_IMM
is the one we're fixing, which only has BPF_DW as an option. I added it
there since we really only want to see BPF_DW in this branch due to the
double imm access.
