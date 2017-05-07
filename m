From: Jann Horn <jannh@google.com>
Subject: Re: [PATCH net] bpf: don't let ldimm64 leak map addresses on unprivileged
Date: Mon, 8 May 2017 00:26:10 +0200
Message-ID: <CAG48ez0S92fLmX5fEa1=HNC3wF+SYizske5MjiJDpW4=tLg6Uw@mail.gmail.com>
References: <793c517a7d163c613ab886eb02d32efea9f902fd.1494194233.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        kafai@fb.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:38088 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757091AbdEGW0c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 7 May 2017 18:26:32 -0400
Received: by mail-it0-f45.google.com with SMTP id e65so30673738ita.1
        for <netdev@vger.kernel.org>; Sun, 07 May 2017 15:26:32 -0700 (PDT)
In-Reply-To: <793c517a7d163c613ab886eb02d32efea9f902fd.1494194233.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 8, 2017 at 12:04 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> The patch fixes two things at once:
>
> 1) It checks the env->allow_ptr_leaks and only prints the map address to
>    the log if we have the privileges to do so, otherwise it just dumps 0
>    as we would when kptr_restrict is enabled on %pK. Given the latter is
>    off by default and not every distro sets it, I don't want to rely on
>    this, hence the 0 by default for unprivileged.
>
> 2) Printing of ldimm64 in the verifier log is currently broken in that
>    we don't print the full immediate, but only the 32 bit part of the
>    first insn part for ldimm64. Thus, fix this up as well; it's okay to
>    access, since we verified all ldimm64 earlier already (including just
>    constants) through replace_map_fd_with_map_ptr().
>
> Fixes: cbd357008604 ("bpf: verifier (add ability to receive verification log)")
> Reported-by: Jann Horn <jannh@google.com>
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
[...]
> @@ -362,9 +363,19 @@ static void print_bpf_insn(struct bpf_insn *insn)
>                                 insn->code,
>                                 bpf_ldst_string[BPF_SIZE(insn->code) >> 3],
>                                 insn->src_reg, insn->imm);
> -               } else if (BPF_MODE(insn->code) == BPF_IMM) {
> -                       verbose("(%02x) r%d = 0x%x\n",
> -                               insn->code, insn->dst_reg, insn->imm);
> +               } else if (BPF_MODE(insn->code) == BPF_IMM &&
> +                          BPF_SIZE(insn->code) == BPF_DW) {
> +                       /* At this point, we already made sure that the second
> +                        * part of the ldimm64 insn is accessible.
> +                        */
> +                       u64 imm = ((u64)(insn + 1)->imm << 32) | (u32)insn->imm;
> +                       bool map_ptr = insn->src_reg == BPF_PSEUDO_MAP_FD;
> +
> +                       if (map_ptr && !env->allow_ptr_leaks)
> +                               imm = 0;
> +
> +                       verbose("(%02x) r%d = 0x%llx\n", insn->code,
> +                               insn->dst_reg, (unsigned long long)imm);
>                 } else {
>                         verbose("BUG_ld_%02x\n", insn->code);
>                         return;

You replaced the `BPF_MODE(insn->code) == BPF_IMM` branch with a
`BPF_MODE(insn->code) == BPF_IMM && BPF_SIZE(insn->code) == BPF_DW`
branch. Doesn't that break printing normal immediates?
