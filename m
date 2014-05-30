From: Chema Gonzalez <chema@berkeley.edu>
Subject: Re: [PATCH net-next 1/4] net: filter: add slot overlapping test with
 fully filled M[]
Date: Fri, 30 May 2014 15:54:40 -0700
Message-ID: <CAEb0MfehUO+qb3Uosk-KS1LsgE4jkmcXu4XVPaAsa-8h6VbONg@mail.gmail.com>
References: <1401351771-5367-1-git-send-email-dborkman@redhat.com>
	<1401351771-5367-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, ast@plumgrid.com,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:42317 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934343AbaE3Wyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 18:54:41 -0400
Received: by mail-qg0-f46.google.com with SMTP id q108so7075133qgd.5
        for <netdev@vger.kernel.org>; Fri, 30 May 2014 15:54:40 -0700 (PDT)
In-Reply-To: <1401351771-5367-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 29, 2014 at 1:22 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> Also add a test for the scratch memory store that first fills
> all slots and then sucessively reads all of them back adding
> up to A, and eventually returning A. This and the previous
> M[] test with alternating fill/spill will detect possible JIT
> errors on M[].
>
> Suggested-by: Alexei Starovoitov <ast@plumgrid.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
> ---
>  lib/test_bpf.c | 75 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 74 insertions(+), 1 deletion(-)
>
> diff --git a/lib/test_bpf.c b/lib/test_bpf.c
> index 3c4a1e3..2d0a0d1 100644
> --- a/lib/test_bpf.c
> +++ b/lib/test_bpf.c
> @@ -1493,7 +1493,7 @@ static struct bpf_test tests[] = {
>                 { },
>         },
>         {       /* Mainly checking JIT here. */
> -               "M[]: STX + LDX",
> +               "M[]: alt STX + LDX",
>                 .u.insns = {
>                         BPF_STMT(BPF_LDX | BPF_IMM, 100),
>                         BPF_STMT(BPF_STX, 0),
> @@ -1582,6 +1582,79 @@ static struct bpf_test tests[] = {
>                 { },
>                 { { 0, 116 } },
>         },
> +       {       /* Mainly checking JIT here. */
> +               "M[]: full STX + full LDX",
> +               .u.insns = {
> +                       BPF_STMT(BPF_LDX | BPF_IMM, 0xbadfeedb),
This is a nit: Could you please use numbers that are easily addable by
a 2-legged computer? For example, you could add 0x00000001,
0x00000004, 0x00000010, 0x00000040, 0x00000100, ..., and then the
addition should be 0x55555555.

-Chema

> +                       BPF_STMT(BPF_STX, 0),
> +                       BPF_STMT(BPF_LDX | BPF_IMM, 0xecabedae),
> +                       BPF_STMT(BPF_STX, 1),
> +                       BPF_STMT(BPF_LDX | BPF_IMM, 0xafccfeaf),
> +                       BPF_STMT(BPF_STX, 2),
> +                       BPF_STMT(BPF_LDX | BPF_IMM, 0xbffdcedc),
> +                       BPF_STMT(BPF_STX, 3),
> +                       BPF_STMT(BPF_LDX | BPF_IMM, 0xfbbbdccb),
> +                       BPF_STMT(BPF_STX, 4),
> +                       BPF_STMT(BPF_LDX | BPF_IMM, 0xfbabcbda),
> +                       BPF_STMT(BPF_STX, 5),
> +                       BPF_STMT(BPF_LDX | BPF_IMM, 0xaedecbdb),
> +                       BPF_STMT(BPF_STX, 6),
> +                       BPF_STMT(BPF_LDX | BPF_IMM, 0xadebbade),
> +                       BPF_STMT(BPF_STX, 7),
> +                       BPF_STMT(BPF_LDX | BPF_IMM, 0xfcfcfaec),
> +                       BPF_STMT(BPF_STX, 8),
> +                       BPF_STMT(BPF_LDX | BPF_IMM, 0xbcdddbdc),
> +                       BPF_STMT(BPF_STX, 9),
> +                       BPF_STMT(BPF_LDX | BPF_IMM, 0xfeefdfac),
> +                       BPF_STMT(BPF_STX, 10),
> +                       BPF_STMT(BPF_LDX | BPF_IMM, 0xcddcdeea),
> +                       BPF_STMT(BPF_STX, 11),
> +                       BPF_STMT(BPF_LDX | BPF_IMM, 0xaccfaebb),
> +                       BPF_STMT(BPF_STX, 12),
> +                       BPF_STMT(BPF_LDX | BPF_IMM, 0xbdcccdcf),
> +                       BPF_STMT(BPF_STX, 13),
> +                       BPF_STMT(BPF_LDX | BPF_IMM, 0xaaedecde),
> +                       BPF_STMT(BPF_STX, 14),
> +                       BPF_STMT(BPF_LDX | BPF_IMM, 0xfaeacdad),
> +                       BPF_STMT(BPF_STX, 15),
> +                       BPF_STMT(BPF_LDX | BPF_MEM, 0),
> +                       BPF_STMT(BPF_MISC | BPF_TXA, 0),
> +                       BPF_STMT(BPF_LDX | BPF_MEM, 1),
> +                       BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
> +                       BPF_STMT(BPF_LDX | BPF_MEM, 2),
> +                       BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
> +                       BPF_STMT(BPF_LDX | BPF_MEM, 3),
> +                       BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
> +                       BPF_STMT(BPF_LDX | BPF_MEM, 4),
> +                       BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
> +                       BPF_STMT(BPF_LDX | BPF_MEM, 5),
> +                       BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
> +                       BPF_STMT(BPF_LDX | BPF_MEM, 6),
> +                       BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
> +                       BPF_STMT(BPF_LDX | BPF_MEM, 7),
> +                       BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
> +                       BPF_STMT(BPF_LDX | BPF_MEM, 8),
> +                       BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
> +                       BPF_STMT(BPF_LDX | BPF_MEM, 9),
> +                       BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
> +                       BPF_STMT(BPF_LDX | BPF_MEM, 10),
> +                       BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
> +                       BPF_STMT(BPF_LDX | BPF_MEM, 11),
> +                       BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
> +                       BPF_STMT(BPF_LDX | BPF_MEM, 12),
> +                       BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
> +                       BPF_STMT(BPF_LDX | BPF_MEM, 13),
> +                       BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
> +                       BPF_STMT(BPF_LDX | BPF_MEM, 14),
> +                       BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
> +                       BPF_STMT(BPF_LDX | BPF_MEM, 15),
> +                       BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
> +                       BPF_STMT(BPF_RET | BPF_A, 0),
> +               },
> +               CLASSIC | FLAG_NO_DATA,
> +               { },
> +               { { 0, 0x2a5a5e5 } },
> +       },
>  };
>
>  static struct net_device dev;
> --
> 1.7.11.7
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
