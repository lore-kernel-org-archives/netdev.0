From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] filter: Optimize instruction revalidation code.
Date: Wed, 17 Nov 2010 07:24:15 +0800
Message-ID: <AANLkTins3+ka-Y9U1opEVSbGBkk6+ViTOPvJ5aFa=J0u@mail.gmail.com>
References: <1695276347-1289413089-cardhu_decombobulator_blackberry.rim.net-434693855-@bda083.bisx.prod.on.blackberry>
 <20101110.102129.112602843.davem@davemloft.net> <1289414024.2469.20.camel@edumazet-laptop>
 <20101110.103807.39173013.davem@davemloft.net> <201011162208.BHC17628.SVtFMJOOLFQFOH@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	drosenberg@vsecurity.com, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:44869 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932134Ab0KPXYh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 18:24:37 -0500
Received: by eye27 with SMTP id 27so796732eye.19
        for <netdev@vger.kernel.org>; Tue, 16 Nov 2010 15:24:36 -0800 (PST)
In-Reply-To: <201011162208.BHC17628.SVtFMJOOLFQFOH@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 16, 2010 at 9:08 PM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> In the wake of commit 57fe93b3 "filter: make sure filters dont read
> uninitialized memory", I came up with this patch. I don't know how to=
 test.
> Please review and do tests.
>
> This patch optimizes sk_chk_filter(). Using gcc 4.1.2 on x86_32, the =
size of
> net/core/filter.o changed from 7416 bytes to 5260 bytes
> ("make allnoconfig" + CONFIG_NET=3Dy).
>
> By the way, if "struct sock_filter *filter" argument of sk_run_filter=
() does
> not change after it was revalidated at sk_chk_filter(), can't we dete=
ct and
> reject "BPF_S_LD_MEM/BPF_S_LDX_MEM before BPF_S_ST/BPF_S_STX" at
> sk_chk_filter()?
> ----------------------------------------
> =A0From 2bf36130bd4912590b409b47a6a9a82e2884e035 Mon Sep 17 00:00:00 =
2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Tue, 16 Nov 2010 21:39:50 +0900
> Subject: [PATCH] filter: Optimize instruction revalidation code.
>
> Since repeating small value to small value conversion using switch() =
clause's
> case statement is wasteful, this patch instroduces u16 to u16 mapping=
 table
> and removes most of case statements. As a result, the size of net/cor=
e/filter.o
> is reduced by about 30% on x86.
>
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
> =A0net/core/filter.c | =A0214 ++++++++++++++++-----------------------=
--------------
> =A01 files changed, 65 insertions(+), 149 deletions(-)
>
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 23e9b2a..85be3d8 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -383,7 +383,57 @@ EXPORT_SYMBOL(sk_run_filter);
> =A0*/
> =A0int sk_chk_filter(struct sock_filter *filter, int flen)
> =A0{
> - =A0 =A0 =A0 struct sock_filter *ftest;
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Valid instructions are initialized to non-0.
> + =A0 =A0 =A0 =A0* Invalid instructions are initialized to 0.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 static u16 codes[] =3D {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_ADD|BPF_K] =A0=3D BPF_S_AL=
U_ADD_K + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_ADD|BPF_X] =A0=3D BPF_S_AL=
U_ADD_X + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_SUB|BPF_K] =A0=3D BPF_S_AL=
U_SUB_K + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_SUB|BPF_X] =A0=3D BPF_S_AL=
U_SUB_X + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_MUL|BPF_K] =A0=3D BPF_S_AL=
U_MUL_K + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_MUL|BPF_X] =A0=3D BPF_S_AL=
U_MUL_X + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_DIV|BPF_X] =A0=3D BPF_S_AL=
U_DIV_X + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_AND|BPF_K] =A0=3D BPF_S_AL=
U_AND_K + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_AND|BPF_X] =A0=3D BPF_S_AL=
U_AND_X + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_OR|BPF_K] =A0 =3D BPF_S_AL=
U_OR_K + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_OR|BPF_X] =A0 =3D BPF_S_AL=
U_OR_X + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_LSH|BPF_K] =A0=3D BPF_S_AL=
U_LSH_K + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_LSH|BPF_X] =A0=3D BPF_S_AL=
U_LSH_X + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_RSH|BPF_K] =A0=3D BPF_S_AL=
U_RSH_K + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_RSH|BPF_X] =A0=3D BPF_S_AL=
U_RSH_X + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_NEG] =A0 =A0 =A0 =A0=3D BP=
=46_S_ALU_NEG + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_W|BPF_ABS] =A0 =3D BPF_S_LD=
_W_ABS + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_H|BPF_ABS] =A0 =3D BPF_S_LD=
_H_ABS + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_B|BPF_ABS] =A0 =3D BPF_S_LD=
_B_ABS + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_W|BPF_LEN] =A0 =3D BPF_S_LD=
_W_LEN + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_W|BPF_IND] =A0 =3D BPF_S_LD=
_W_IND + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_H|BPF_IND] =A0 =3D BPF_S_LD=
_H_IND + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_B|BPF_IND] =A0 =3D BPF_S_LD=
_B_IND + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_IMM] =A0 =A0 =A0 =A0 =3D BP=
=46_S_LD_IMM + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LDX|BPF_W|BPF_LEN] =A0=3D BPF_S_LD=
X_W_LEN + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LDX|BPF_B|BPF_MSH] =A0=3D BPF_S_LD=
X_B_MSH + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LDX|BPF_IMM] =A0 =A0 =A0 =A0=3D BP=
=46_S_LDX_IMM + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_MISC|BPF_TAX] =A0 =A0 =A0 =3D BPF_=
S_MISC_TAX + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_MISC|BPF_TXA] =A0 =A0 =A0 =3D BPF_=
S_MISC_TXA + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_RET|BPF_K] =A0 =A0 =A0 =A0 =A0=3D =
BPF_S_RET_K + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_RET|BPF_A] =A0 =A0 =A0 =A0 =A0=3D =
BPF_S_RET_A + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ALU|BPF_DIV|BPF_K] =A0=3D BPF_S_AL=
U_DIV_K + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LD|BPF_MEM] =A0 =A0 =A0 =A0 =3D BP=
=46_S_LD_MEM + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_LDX|BPF_MEM] =A0 =A0 =A0 =A0=3D BP=
=46_S_LDX_MEM + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_ST] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =3D BPF_S_ST + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_STX] =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
=3D BPF_S_STX + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JA] =A0 =A0 =A0 =A0 =3D BP=
=46_S_JMP_JA + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JEQ|BPF_K] =A0=3D BPF_S_JM=
P_JEQ_K + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JEQ|BPF_X] =A0=3D BPF_S_JM=
P_JEQ_X + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JGE|BPF_K] =A0=3D BPF_S_JM=
P_JGE_K + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JGE|BPF_X] =A0=3D BPF_S_JM=
P_JGE_X + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JGT|BPF_K] =A0=3D BPF_S_JM=
P_JGT_K + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JGT|BPF_X] =A0=3D BPF_S_JM=
P_JGT_X + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JSET|BPF_K] =3D BPF_S_JMP_=
JSET_K + 1,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 [BPF_JMP|BPF_JSET|BPF_X] =3D BPF_S_JMP_=
JSET_X + 1,
> + =A0 =A0 =A0 };
> =A0 =A0 =A0 =A0int pc;
>
> =A0 =A0 =A0 =A0if (flen =3D=3D 0 || flen > BPF_MAXINSNS)
> @@ -391,135 +441,26 @@ int sk_chk_filter(struct sock_filter *filter, =
int flen)
>
> =A0 =A0 =A0 =A0/* check the filter code now */
> =A0 =A0 =A0 =A0for (pc =3D 0; pc < flen; pc++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest =3D &filter[pc];
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Only allow valid instructions */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (ftest->code) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_ALU|BPF_ADD|BPF_K:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_A=
LU_ADD_K;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_ALU|BPF_ADD|BPF_X:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_A=
LU_ADD_X;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_ALU|BPF_SUB|BPF_K:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_A=
LU_SUB_K;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_ALU|BPF_SUB|BPF_X:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_A=
LU_SUB_X;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_ALU|BPF_MUL|BPF_K:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_A=
LU_MUL_K;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_ALU|BPF_MUL|BPF_X:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_A=
LU_MUL_X;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_ALU|BPF_DIV|BPF_X:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_A=
LU_DIV_X;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_ALU|BPF_AND|BPF_K:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_A=
LU_AND_K;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_ALU|BPF_AND|BPF_X:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_A=
LU_AND_X;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_ALU|BPF_OR|BPF_K:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_A=
LU_OR_K;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_ALU|BPF_OR|BPF_X:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_A=
LU_OR_X;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_ALU|BPF_LSH|BPF_K:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_A=
LU_LSH_K;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_ALU|BPF_LSH|BPF_X:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_A=
LU_LSH_X;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_ALU|BPF_RSH|BPF_K:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_A=
LU_RSH_K;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_ALU|BPF_RSH|BPF_X:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_A=
LU_RSH_X;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_ALU|BPF_NEG:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_A=
LU_NEG;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_LD|BPF_W|BPF_ABS:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_L=
D_W_ABS;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_LD|BPF_H|BPF_ABS:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_L=
D_H_ABS;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_LD|BPF_B|BPF_ABS:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_L=
D_B_ABS;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_LD|BPF_W|BPF_LEN:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_L=
D_W_LEN;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_LD|BPF_W|BPF_IND:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_L=
D_W_IND;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_LD|BPF_H|BPF_IND:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_L=
D_H_IND;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_LD|BPF_B|BPF_IND:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_L=
D_B_IND;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_LD|BPF_IMM:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_L=
D_IMM;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_LDX|BPF_W|BPF_LEN:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_L=
DX_W_LEN;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_LDX|BPF_B|BPF_MSH:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_L=
DX_B_MSH;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_LDX|BPF_IMM:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_L=
DX_IMM;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_MISC|BPF_TAX:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_M=
ISC_TAX;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_MISC|BPF_TXA:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_M=
ISC_TXA;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_RET|BPF_K:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_R=
ET_K;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_RET|BPF_A:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_R=
ET_A;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sock_filter *ftest =3D &filter[p=
c];

Why move the define here?

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 code =3D ftest->code;
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (code >=3D ARRAY_SIZE(codes))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;

return -EINVAL;

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Some instructions need special chec=
ks */
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* check for division b=
y zero */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (code) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_ALU|BPF_DIV|BPF_K:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* check for division b=
y zero */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ftest->k =3D=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 -EINVAL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_A=
LU_DIV_K;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* check for invalid memory addresses *=
/
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_LD|BPF_MEM:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ftest->k >=3D BPF_M=
EMWORDS)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
-EINVAL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_L=
D_MEM;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_LDX|BPF_MEM:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ftest->k >=3D BPF_M=
EMWORDS)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
-EINVAL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_L=
DX_MEM;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_ST:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ftest->k >=3D BPF_M=
EMWORDS)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
-EINVAL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_S=
T;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_STX:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* check for invalid me=
mory addresses */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ftest->k >=3D BPF_=
MEMWORDS)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 -EINVAL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_S=
TX;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> -
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_JMP|BPF_JA:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Note, the large fte=
st->k might cause loops.
> @@ -528,40 +469,14 @@ int sk_chk_filter(struct sock_filter *filter, i=
nt flen)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ftest->k >=3D (uns=
igned)(flen-pc-1))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 -EINVAL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_J=
MP_JA;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_JMP|BPF_JEQ|BPF_K:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_J=
MP_JEQ_K;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_JMP|BPF_JEQ|BPF_X:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_J=
MP_JEQ_X;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_JMP|BPF_JGE|BPF_K:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_J=
MP_JGE_K;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_JMP|BPF_JGE|BPF_X:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_J=
MP_JGE_X;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_JMP|BPF_JGT|BPF_K:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_J=
MP_JGT_K;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_JMP|BPF_JGT|BPF_X:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_J=
MP_JGT_X;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_JMP|BPF_JSET|BPF_K:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_J=
MP_JSET_K;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_JMP|BPF_JSET|BPF_X:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_J=
MP_JSET_X;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 default:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* for conditionals bot=
h must be safe */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (ftest->code) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 code =3D codes[code];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!code--)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* for conditionals both must be safe *=
/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (code) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_JMP_JEQ_K:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_JMP_JEQ_X:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_JMP_JGE_K:
> @@ -574,6 +489,7 @@ int sk_chk_filter(struct sock_filter *filter, int=
 flen)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pc + ftest->jf=
 + 1 >=3D flen)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 -EINVAL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D code;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/* last instruction must be a RET code */
> --
> 1.6.1
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
