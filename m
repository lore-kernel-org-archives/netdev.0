From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 5/5] net: filter: optimize BPF migration for
 ARG1/CTX handling
Date: Wed, 23 Apr 2014 14:59:15 -0700
Message-ID: <CAMEtUux3YZW9G80Da2B3pBB2Sq7C7eC62ntnrVifN8_RJugzHw@mail.gmail.com>
References: <1398286621-3591-1-git-send-email-dborkman@redhat.com>
	<1398286621-3591-6-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:55339 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178AbaDWV7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 17:59:16 -0400
Received: by mail-we0-f177.google.com with SMTP id u57so1414227wes.8
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2014 14:59:15 -0700 (PDT)
In-Reply-To: <1398286621-3591-6-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 23, 2014 at 1:57 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
> Currently, at initial setup in __sk_run_filter() we initialize the
> BPF stack's frame-pointer and CTX register. However, instead of the
> CTX register, we initialize context to ARG1, and during user filter
> migration we emit *always* an instruction that copies the content
> from ARG1 to CTX. ARG1 is needed in BPF_CALL instructions to setup
> ctx, A, X for call emission. However, we nevertheless copy CTX over
> to ARG1 in these cases. So all in all, we always emit one instruction
> at BPF program beginning that should have actually been avoided to
> spare this overhead.
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>

First 4 patches look great, but this one I have to disagree.
See below.

> ---
>  net/core/filter.c | 10 +---------
>  1 file changed, 1 insertion(+), 9 deletions(-)
>
> diff --git a/net/core/filter.c b/net/core/filter.c
> index eada3d5..6fed231 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -62,7 +62,6 @@
>  #define A      regs[insn->a_reg]
>  #define X      regs[insn->x_reg]
>  #define FP     regs[BPF_REG_FP]
> -#define ARG1   regs[BPF_REG_ARG1]
>  #define CTX    regs[BPF_REG_CTX]
>  #define K      insn->imm
>
> @@ -257,7 +256,7 @@ unsigned int __sk_run_filter(void *ctx, const struct sock_filter_int *insn)
>  #define CONT_JMP ({ insn++; goto select_insn; })
>
>         FP = (u64) (unsigned long) &stack[ARRAY_SIZE(stack)];
> -       ARG1 = (u64) (unsigned long) ctx;
> +       CTX = (u64) (unsigned long) ctx;

R1 (ARG1) is the register that used to pass first argument to the function.
For seamless kernel->bpf->kernel transition we have to follow calling
convention, so 'void *ctx' has to go into R1 by design.
Storing it into R6 (CTX) will only work for classic filters converted
to extended.
all native ebpf filters will be broken.
In documentation we say:
    * R1 - R5   - arguments from BPF program to in-kernel function
so llvm/gcc are following this ebpf ABI.
Calling convention is the same whether to call kernel function from ebpf
or ebpf from kernel. So 1st argument (void *ctx) has to go into R1.

By convention ld_abs/ld_ind insns are using implicit input register 'ctx' (R6),
that's why we do a copy from R1 into R6 as a first insn of the
_converted_ filter.
The cost of one insn is not zero, yes, but cost of imbalanced ABI is huge.
For example, I don't know how to teach llvm/gcc to have different ABIs
in such cases.

This dual ABI makes JITs ugly too, since now they must remember to
emit R6=R1 copy. I would like JITs to worry about instructions only
and not to deal with such discrepancies.

The whole thing becomes unclean when kernel to ebpf passes
1st argument in R6, but ebpf to kernel passes 1st argument in R1.

So I would suggest to drop this one for now.

I also want to avoid extra generated R6=R1 for converted filters.
Let's think it through first.

>         /* Register for user BPF programs need to be reset first. */
>         regs[BPF_REG_A] = 0;
> @@ -896,13 +895,6 @@ do_pass:
>         new_insn = new_prog;
>         fp = prog;
>
> -       if (new_insn) {
> -               new_insn->code = BPF_ALU64 | BPF_MOV | BPF_X;
> -               new_insn->a_reg = BPF_REG_CTX;
> -               new_insn->x_reg = BPF_REG_ARG1;
> -       }
> -       new_insn++;
> -
>         for (i = 0; i < len; fp++, i++) {
>                 struct sock_filter_int tmp_insns[6] = { };
>                 struct sock_filter_int *insn = tmp_insns;
> --
> 1.7.11.7
>
