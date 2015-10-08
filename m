From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v2 net-next 3/3] bpf: add unprivileged bpf tests
Date: Thu, 8 Oct 2015 10:46:34 -0700
Message-ID: <CAGXu5j+QA2uyvrNteoP1zQ5Cx6tAjVxR2zqmCi8148jS+_YW4w@mail.gmail.com>
References: <1444281803-24274-1-git-send-email-ast@plumgrid.com>
	<1444281803-24274-4-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Andy Lutomirski <luto@amacapital.net>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:33807 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933131AbbJHRqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 13:46:35 -0400
Received: by iow1 with SMTP id 1so66668714iow.1
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 10:46:35 -0700 (PDT)
In-Reply-To: <1444281803-24274-4-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 7, 2015 at 10:23 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> Add new tests samples/bpf/test_verifier:
>
> unpriv: return pointer
>   checks that pointer cannot be returned from the eBPF program
>
> unpriv: add const to pointer
> unpriv: add pointer to pointer
> unpriv: neg pointer
>   checks that pointer arithmetic is disallowed
>
> unpriv: cmp pointer with const
> unpriv: cmp pointer with pointer
>   checks that comparison of pointers is disallowed
>   Only one case allowed 'void *value = bpf_map_lookup_elem(..); if (value == 0) ...'
>
> unpriv: check that printk is disallowed
>   since bpf_trace_printk is not available to unprivileged
>
> unpriv: pass pointer to helper function
>   checks that pointers cannot be passed to functions that expect integers
>   If function expects a pointer the verifier allows only that type of pointer.
>   Like 1st argument of bpf_map_lookup_elem() must be pointer to map.
>   (applies to non-root as well)
>
> unpriv: indirectly pass pointer on stack to helper function
>   checks that pointer stored into stack cannot be used as part of key
>   passed into bpf_map_lookup_elem()
>
> unpriv: mangle pointer on stack 1
> unpriv: mangle pointer on stack 2
>   checks that writing into stack slot that already contains a pointer
>   is disallowed
>
> unpriv: read pointer from stack in small chunks
>   checks that < 8 byte read from stack slot that contains a pointer is
>   disallowed
>
> unpriv: write pointer into ctx
>   checks that storing pointers into skb->fields is disallowed
>
> unpriv: write pointer into map elem value
>   checks that storing pointers into element values is disallowed
>   For example:
>   int bpf_prog(struct __sk_buff *skb)
>   {
>     u32 key = 0;
>     u64 *value = bpf_map_lookup_elem(&map, &key);
>     if (value)
>        *value = (u64) skb;
>   }
>   will be rejected.
>
> unpriv: partial copy of pointer
>   checks that doing 32-bit register mov from register containing
>   a pointer is disallowed
>
> unpriv: pass pointer to tail_call
>   checks that passing pointer as an index into bpf_tail_call
>   is disallowed
>
> unpriv: cmp map pointer with zero
>   checks that comparing map pointer with constant is disallowed
>
> unpriv: write into frame pointer
>   checks that frame pointer is read-only (applies to root too)
>
> unpriv: cmp of frame pointer
>   checks that R10 cannot be using in comparison
>
> unpriv: cmp of stack pointer
>   checks that Rx = R10 - imm is ok, but comparing Rx is not
>
> unpriv: obfuscate stack pointer
>   checks that Rx = R10 - imm is ok, but Rx -= imm is not
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
> v1-v2:
> - split tests into separate patch
> - add tail_call and other tests and explain tests in commit log
> ---
>  samples/bpf/libbpf.h        |    8 +
>  samples/bpf/test_verifier.c |  357 +++++++++++++++++++++++++++++++++++++++++--

Instead of living in samples/ could these be moved and hooked up to
tools/testing/selftests/ instead?

-Kees

>  2 files changed, 355 insertions(+), 10 deletions(-)
>
> diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
> index 7235e292a03b..b7f63c70b4a2 100644
> --- a/samples/bpf/libbpf.h
> +++ b/samples/bpf/libbpf.h
> @@ -64,6 +64,14 @@ extern char bpf_log_buf[LOG_BUF_SIZE];
>                 .off   = 0,                                     \
>                 .imm   = 0 })
>
> +#define BPF_MOV32_REG(DST, SRC)                                        \
> +       ((struct bpf_insn) {                                    \
> +               .code  = BPF_ALU | BPF_MOV | BPF_X,             \
> +               .dst_reg = DST,                                 \
> +               .src_reg = SRC,                                 \
> +               .off   = 0,                                     \
> +               .imm   = 0 })
> +
>  /* Short form of mov, dst_reg = imm32 */
>
>  #define BPF_MOV64_IMM(DST, IMM)                                        \
> diff --git a/samples/bpf/test_verifier.c b/samples/bpf/test_verifier.c
> index ee0f110c9c54..563c507c0a09 100644
> --- a/samples/bpf/test_verifier.c
> +++ b/samples/bpf/test_verifier.c
> @@ -15,20 +15,27 @@
>  #include <string.h>
>  #include <linux/filter.h>
>  #include <stddef.h>
> +#include <stdbool.h>
> +#include <sys/resource.h>
>  #include "libbpf.h"
>
>  #define MAX_INSNS 512
>  #define ARRAY_SIZE(x) (sizeof(x) / sizeof(*(x)))
>
> +#define MAX_FIXUPS 8
> +
>  struct bpf_test {
>         const char *descr;
>         struct bpf_insn insns[MAX_INSNS];
> -       int fixup[32];
> +       int fixup[MAX_FIXUPS];
> +       int prog_array_fixup[MAX_FIXUPS];
>         const char *errstr;
> +       const char *errstr_unpriv;
>         enum {
> +               UNDEF,
>                 ACCEPT,
>                 REJECT
> -       } result;
> +       } result, result_unpriv;
>         enum bpf_prog_type prog_type;
>  };
>
> @@ -96,6 +103,7 @@ static struct bpf_test tests[] = {
>                         BPF_EXIT_INSN(),
>                 },
>                 .errstr = "invalid BPF_LD_IMM insn",
> +               .errstr_unpriv = "R1 pointer comparison",
>                 .result = REJECT,
>         },
>         {
> @@ -109,6 +117,7 @@ static struct bpf_test tests[] = {
>                         BPF_EXIT_INSN(),
>                 },
>                 .errstr = "invalid BPF_LD_IMM insn",
> +               .errstr_unpriv = "R1 pointer comparison",
>                 .result = REJECT,
>         },
>         {
> @@ -219,6 +228,7 @@ static struct bpf_test tests[] = {
>                         BPF_EXIT_INSN(),
>                 },
>                 .errstr = "R0 !read_ok",
> +               .errstr_unpriv = "R1 pointer comparison",
>                 .result = REJECT,
>         },
>         {
> @@ -294,7 +304,9 @@ static struct bpf_test tests[] = {
>                         BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
>                         BPF_EXIT_INSN(),
>                 },
> +               .errstr_unpriv = "R0 leaks addr",
>                 .result = ACCEPT,
> +               .result_unpriv = REJECT,
>         },
>         {
>                 "check corrupted spill/fill",
> @@ -310,6 +322,7 @@ static struct bpf_test tests[] = {
>
>                         BPF_EXIT_INSN(),
>                 },
> +               .errstr_unpriv = "attempt to corrupt spilled",
>                 .errstr = "corrupted spill",
>                 .result = REJECT,
>         },
> @@ -473,6 +486,7 @@ static struct bpf_test tests[] = {
>                 },
>                 .fixup = {3},
>                 .errstr = "R0 invalid mem access",
> +               .errstr_unpriv = "R0 leaks addr",
>                 .result = REJECT,
>         },
>         {
> @@ -495,6 +509,8 @@ static struct bpf_test tests[] = {
>                         BPF_MOV64_IMM(BPF_REG_0, 0),
>                         BPF_EXIT_INSN(),
>                 },
> +               .errstr_unpriv = "R1 pointer comparison",
> +               .result_unpriv = REJECT,
>                 .result = ACCEPT,
>         },
>         {
> @@ -521,6 +537,8 @@ static struct bpf_test tests[] = {
>                         BPF_MOV64_IMM(BPF_REG_0, 0),
>                         BPF_EXIT_INSN(),
>                 },
> +               .errstr_unpriv = "R1 pointer comparison",
> +               .result_unpriv = REJECT,
>                 .result = ACCEPT,
>         },
>         {
> @@ -555,6 +573,8 @@ static struct bpf_test tests[] = {
>                         BPF_EXIT_INSN(),
>                 },
>                 .fixup = {24},
> +               .errstr_unpriv = "R1 pointer comparison",
> +               .result_unpriv = REJECT,
>                 .result = ACCEPT,
>         },
>         {
> @@ -603,6 +623,8 @@ static struct bpf_test tests[] = {
>                         BPF_MOV64_IMM(BPF_REG_0, 0),
>                         BPF_EXIT_INSN(),
>                 },
> +               .errstr_unpriv = "R1 pointer comparison",
> +               .result_unpriv = REJECT,
>                 .result = ACCEPT,
>         },
>         {
> @@ -642,6 +664,8 @@ static struct bpf_test tests[] = {
>                         BPF_MOV64_IMM(BPF_REG_0, 0),
>                         BPF_EXIT_INSN(),
>                 },
> +               .errstr_unpriv = "R1 pointer comparison",
> +               .result_unpriv = REJECT,
>                 .result = ACCEPT,
>         },
>         {
> @@ -699,6 +723,7 @@ static struct bpf_test tests[] = {
>                 },
>                 .fixup = {4},
>                 .errstr = "different pointers",
> +               .errstr_unpriv = "R1 pointer comparison",
>                 .result = REJECT,
>         },
>         {
> @@ -720,6 +745,7 @@ static struct bpf_test tests[] = {
>                 },
>                 .fixup = {6},
>                 .errstr = "different pointers",
> +               .errstr_unpriv = "R1 pointer comparison",
>                 .result = REJECT,
>         },
>         {
> @@ -742,6 +768,7 @@ static struct bpf_test tests[] = {
>                 },
>                 .fixup = {7},
>                 .errstr = "different pointers",
> +               .errstr_unpriv = "R1 pointer comparison",
>                 .result = REJECT,
>         },
>         {
> @@ -752,6 +779,7 @@ static struct bpf_test tests[] = {
>                         BPF_EXIT_INSN(),
>                 },
>                 .errstr = "invalid bpf_context access",
> +               .errstr_unpriv = "R1 leaks addr",
>                 .result = REJECT,
>         },
>         {
> @@ -762,6 +790,7 @@ static struct bpf_test tests[] = {
>                         BPF_EXIT_INSN(),
>                 },
>                 .errstr = "invalid bpf_context access",
> +               .errstr_unpriv = "R1 leaks addr",
>                 .result = REJECT,
>         },
>         {
> @@ -772,16 +801,18 @@ static struct bpf_test tests[] = {
>                         BPF_EXIT_INSN(),
>                 },
>                 .errstr = "invalid bpf_context access",
> +               .errstr_unpriv = "R1 leaks addr",
>                 .result = REJECT,
>         },
>         {
>                 "check out of range skb->cb access",
>                 .insns = {
>                         BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
> -                                   offsetof(struct __sk_buff, cb[60])),
> +                                   offsetof(struct __sk_buff, cb[0]) + 256),
>                         BPF_EXIT_INSN(),
>                 },
>                 .errstr = "invalid bpf_context access",
> +               .errstr_unpriv = "",
>                 .result = REJECT,
>                 .prog_type = BPF_PROG_TYPE_SCHED_ACT,
>         },
> @@ -803,6 +834,8 @@ static struct bpf_test tests[] = {
>                         BPF_EXIT_INSN(),
>                 },
>                 .result = ACCEPT,
> +               .errstr_unpriv = "R1 leaks addr",
> +               .result_unpriv = REJECT,
>         },
>         {
>                 "write skb fields from tc_cls_act prog",
> @@ -819,6 +852,8 @@ static struct bpf_test tests[] = {
>                                     offsetof(struct __sk_buff, cb[3])),
>                         BPF_EXIT_INSN(),
>                 },
> +               .errstr_unpriv = "",
> +               .result_unpriv = REJECT,
>                 .result = ACCEPT,
>                 .prog_type = BPF_PROG_TYPE_SCHED_CLS,
>         },
> @@ -881,6 +916,270 @@ static struct bpf_test tests[] = {
>                 .result = REJECT,
>                 .errstr = "invalid stack off=0 size=8",
>         },
> +       {
> +               "unpriv: return pointer",
> +               .insns = {
> +                       BPF_MOV64_REG(BPF_REG_0, BPF_REG_10),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .result = ACCEPT,
> +               .result_unpriv = REJECT,
> +               .errstr_unpriv = "R0 leaks addr",
> +       },
> +       {
> +               "unpriv: add const to pointer",
> +               .insns = {
> +                       BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 8),
> +                       BPF_MOV64_IMM(BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .result = ACCEPT,
> +               .result_unpriv = REJECT,
> +               .errstr_unpriv = "R1 pointer arithmetic",
> +       },
> +       {
> +               "unpriv: add pointer to pointer",
> +               .insns = {
> +                       BPF_ALU64_REG(BPF_ADD, BPF_REG_1, BPF_REG_10),
> +                       BPF_MOV64_IMM(BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .result = ACCEPT,
> +               .result_unpriv = REJECT,
> +               .errstr_unpriv = "R1 pointer arithmetic",
> +       },
> +       {
> +               "unpriv: neg pointer",
> +               .insns = {
> +                       BPF_ALU64_IMM(BPF_NEG, BPF_REG_1, 0),
> +                       BPF_MOV64_IMM(BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .result = ACCEPT,
> +               .result_unpriv = REJECT,
> +               .errstr_unpriv = "R1 pointer arithmetic",
> +       },
> +       {
> +               "unpriv: cmp pointer with const",
> +               .insns = {
> +                       BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 0),
> +                       BPF_MOV64_IMM(BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .result = ACCEPT,
> +               .result_unpriv = REJECT,
> +               .errstr_unpriv = "R1 pointer comparison",
> +       },
> +       {
> +               "unpriv: cmp pointer with pointer",
> +               .insns = {
> +                       BPF_JMP_REG(BPF_JEQ, BPF_REG_1, BPF_REG_10, 0),
> +                       BPF_MOV64_IMM(BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .result = ACCEPT,
> +               .result_unpriv = REJECT,
> +               .errstr_unpriv = "R10 pointer comparison",
> +       },
> +       {
> +               "unpriv: check that printk is disallowed",
> +               .insns = {
> +                       BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
> +                       BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
> +                       BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -8),
> +                       BPF_MOV64_IMM(BPF_REG_2, 8),
> +                       BPF_MOV64_REG(BPF_REG_3, BPF_REG_1),
> +                       BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_trace_printk),
> +                       BPF_MOV64_IMM(BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .errstr_unpriv = "unknown func 6",
> +               .result_unpriv = REJECT,
> +               .result = ACCEPT,
> +       },
> +       {
> +               "unpriv: pass pointer to helper function",
> +               .insns = {
> +                       BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
> +                       BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
> +                       BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
> +                       BPF_LD_MAP_FD(BPF_REG_1, 0),
> +                       BPF_MOV64_REG(BPF_REG_3, BPF_REG_2),
> +                       BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
> +                       BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_update_elem),
> +                       BPF_MOV64_IMM(BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .fixup = {3},
> +               .errstr_unpriv = "R4 leaks addr",
> +               .result_unpriv = REJECT,
> +               .result = ACCEPT,
> +       },
> +       {
> +               "unpriv: indirectly pass pointer on stack to helper function",
> +               .insns = {
> +                       BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_10, -8),
> +                       BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
> +                       BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
> +                       BPF_LD_MAP_FD(BPF_REG_1, 0),
> +                       BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
> +                       BPF_MOV64_IMM(BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .fixup = {3},
> +               .errstr = "invalid indirect read from stack off -8+0 size 8",
> +               .result = REJECT,
> +       },
> +       {
> +               "unpriv: mangle pointer on stack 1",
> +               .insns = {
> +                       BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_10, -8),
> +                       BPF_ST_MEM(BPF_W, BPF_REG_10, -8, 0),
> +                       BPF_MOV64_IMM(BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .errstr_unpriv = "attempt to corrupt spilled",
> +               .result_unpriv = REJECT,
> +               .result = ACCEPT,
> +       },
> +       {
> +               "unpriv: mangle pointer on stack 2",
> +               .insns = {
> +                       BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_10, -8),
> +                       BPF_ST_MEM(BPF_B, BPF_REG_10, -1, 0),
> +                       BPF_MOV64_IMM(BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .errstr_unpriv = "attempt to corrupt spilled",
> +               .result_unpriv = REJECT,
> +               .result = ACCEPT,
> +       },
> +       {
> +               "unpriv: read pointer from stack in small chunks",
> +               .insns = {
> +                       BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_10, -8),
> +                       BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_10, -8),
> +                       BPF_MOV64_IMM(BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .errstr = "invalid size",
> +               .result = REJECT,
> +       },
> +       {
> +               "unpriv: write pointer into ctx",
> +               .insns = {
> +                       BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_1, 0),
> +                       BPF_MOV64_IMM(BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .errstr_unpriv = "R1 leaks addr",
> +               .result_unpriv = REJECT,
> +               .errstr = "invalid bpf_context access",
> +               .result = REJECT,
> +       },
> +       {
> +               "unpriv: write pointer into map elem value",
> +               .insns = {
> +                       BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
> +                       BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
> +                       BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
> +                       BPF_LD_MAP_FD(BPF_REG_1, 0),
> +                       BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
> +                       BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
> +                       BPF_STX_MEM(BPF_DW, BPF_REG_0, BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .fixup = {3},
> +               .errstr_unpriv = "R0 leaks addr",
> +               .result_unpriv = REJECT,
> +               .result = ACCEPT,
> +       },
> +       {
> +               "unpriv: partial copy of pointer",
> +               .insns = {
> +                       BPF_MOV32_REG(BPF_REG_1, BPF_REG_10),
> +                       BPF_MOV64_IMM(BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .errstr_unpriv = "R10 partial copy",
> +               .result_unpriv = REJECT,
> +               .result = ACCEPT,
> +       },
> +       {
> +               "unpriv: pass pointer to tail_call",
> +               .insns = {
> +                       BPF_MOV64_REG(BPF_REG_3, BPF_REG_1),
> +                       BPF_LD_MAP_FD(BPF_REG_2, 0),
> +                       BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_tail_call),
> +                       BPF_MOV64_IMM(BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .prog_array_fixup = {1},
> +               .errstr_unpriv = "R3 leaks addr into helper",
> +               .result_unpriv = REJECT,
> +               .result = ACCEPT,
> +       },
> +       {
> +               "unpriv: cmp map pointer with zero",
> +               .insns = {
> +                       BPF_MOV64_IMM(BPF_REG_1, 0),
> +                       BPF_LD_MAP_FD(BPF_REG_1, 0),
> +                       BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 0),
> +                       BPF_MOV64_IMM(BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .fixup = {1},
> +               .errstr_unpriv = "R1 pointer comparison",
> +               .result_unpriv = REJECT,
> +               .result = ACCEPT,
> +       },
> +       {
> +               "unpriv: write into frame pointer",
> +               .insns = {
> +                       BPF_MOV64_REG(BPF_REG_10, BPF_REG_1),
> +                       BPF_MOV64_IMM(BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .errstr = "frame pointer is read only",
> +               .result = REJECT,
> +       },
> +       {
> +               "unpriv: cmp of frame pointer",
> +               .insns = {
> +                       BPF_JMP_IMM(BPF_JEQ, BPF_REG_10, 0, 0),
> +                       BPF_MOV64_IMM(BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .errstr_unpriv = "R10 pointer comparison",
> +               .result_unpriv = REJECT,
> +               .result = ACCEPT,
> +       },
> +       {
> +               "unpriv: cmp of stack pointer",
> +               .insns = {
> +                       BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
> +                       BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
> +                       BPF_JMP_IMM(BPF_JEQ, BPF_REG_2, 0, 0),
> +                       BPF_MOV64_IMM(BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .errstr_unpriv = "R2 pointer comparison",
> +               .result_unpriv = REJECT,
> +               .result = ACCEPT,
> +       },
> +       {
> +               "unpriv: obfuscate stack pointer",
> +               .insns = {
> +                       BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
> +                       BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
> +                       BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
> +                       BPF_MOV64_IMM(BPF_REG_0, 0),
> +                       BPF_EXIT_INSN(),
> +               },
> +               .errstr_unpriv = "R2 pointer arithmetic",
> +               .result_unpriv = REJECT,
> +               .result = ACCEPT,
> +       },
>  };
>
>  static int probe_filter_length(struct bpf_insn *fp)
> @@ -896,13 +1195,24 @@ static int probe_filter_length(struct bpf_insn *fp)
>
>  static int create_map(void)
>  {
> -       long long key, value = 0;
>         int map_fd;
>
> -       map_fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value), 1024);
> -       if (map_fd < 0) {
> +       map_fd = bpf_create_map(BPF_MAP_TYPE_HASH,
> +                               sizeof(long long), sizeof(long long), 1024);
> +       if (map_fd < 0)
>                 printf("failed to create map '%s'\n", strerror(errno));
> -       }
> +
> +       return map_fd;
> +}
> +
> +static int create_prog_array(void)
> +{
> +       int map_fd;
> +
> +       map_fd = bpf_create_map(BPF_MAP_TYPE_PROG_ARRAY,
> +                               sizeof(int), sizeof(int), 4);
> +       if (map_fd < 0)
> +               printf("failed to create prog_array '%s'\n", strerror(errno));
>
>         return map_fd;
>  }
> @@ -910,13 +1220,17 @@ static int create_map(void)
>  static int test(void)
>  {
>         int prog_fd, i, pass_cnt = 0, err_cnt = 0;
> +       bool unpriv = geteuid() != 0;
>
>         for (i = 0; i < ARRAY_SIZE(tests); i++) {
>                 struct bpf_insn *prog = tests[i].insns;
>                 int prog_type = tests[i].prog_type;
>                 int prog_len = probe_filter_length(prog);
>                 int *fixup = tests[i].fixup;
> -               int map_fd = -1;
> +               int *prog_array_fixup = tests[i].prog_array_fixup;
> +               int expected_result;
> +               const char *expected_errstr;
> +               int map_fd = -1, prog_array_fd = -1;
>
>                 if (*fixup) {
>                         map_fd = create_map();
> @@ -926,13 +1240,31 @@ static int test(void)
>                                 fixup++;
>                         } while (*fixup);
>                 }
> +               if (*prog_array_fixup) {
> +                       prog_array_fd = create_prog_array();
> +
> +                       do {
> +                               prog[*prog_array_fixup].imm = prog_array_fd;
> +                               prog_array_fixup++;
> +                       } while (*prog_array_fixup);
> +               }
>                 printf("#%d %s ", i, tests[i].descr);
>
>                 prog_fd = bpf_prog_load(prog_type ?: BPF_PROG_TYPE_SOCKET_FILTER,
>                                         prog, prog_len * sizeof(struct bpf_insn),
>                                         "GPL", 0);
>
> -               if (tests[i].result == ACCEPT) {
> +               if (unpriv && tests[i].result_unpriv != UNDEF)
> +                       expected_result = tests[i].result_unpriv;
> +               else
> +                       expected_result = tests[i].result;
> +
> +               if (unpriv && tests[i].errstr_unpriv)
> +                       expected_errstr = tests[i].errstr_unpriv;
> +               else
> +                       expected_errstr = tests[i].errstr;
> +
> +               if (expected_result == ACCEPT) {
>                         if (prog_fd < 0) {
>                                 printf("FAIL\nfailed to load prog '%s'\n",
>                                        strerror(errno));
> @@ -947,7 +1279,7 @@ static int test(void)
>                                 err_cnt++;
>                                 goto fail;
>                         }
> -                       if (strstr(bpf_log_buf, tests[i].errstr) == 0) {
> +                       if (strstr(bpf_log_buf, expected_errstr) == 0) {
>                                 printf("FAIL\nunexpected error message: %s",
>                                        bpf_log_buf);
>                                 err_cnt++;
> @@ -960,6 +1292,8 @@ static int test(void)
>  fail:
>                 if (map_fd >= 0)
>                         close(map_fd);
> +               if (prog_array_fd >= 0)
> +                       close(prog_array_fd);
>                 close(prog_fd);
>
>         }
> @@ -970,5 +1304,8 @@ fail:
>
>  int main(void)
>  {
> +       struct rlimit r = {1 << 20, 1 << 20};
> +
> +       setrlimit(RLIMIT_MEMLOCK, &r);
>         return test();
>  }
> --
> 1.7.9.5
>



-- 
Kees Cook
Chrome OS Security
