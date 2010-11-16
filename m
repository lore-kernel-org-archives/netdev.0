From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] filter: Optimize instruction revalidation code.
Date: Tue, 16 Nov 2010 17:30:55 +0100
Message-ID: <1289925055.5372.484.camel@edumazet-laptop>
References: <20101110.102129.112602843.davem@davemloft.net>
	 <1289414024.2469.20.camel@edumazet-laptop>
	 <20101110.103807.39173013.davem@davemloft.net>
	 <201011162208.BHC17628.SVtFMJOOLFQFOH@I-love.SAKURA.ne.jp>
	 <1289915053.5372.183.camel@edumazet-laptop>
	 <201011162331.CGH00026.OFOSFVMFQtLHOJ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mjt@tls.msk.ru, davem@davemloft.net, drosenberg@vsecurity.com,
	netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:37002 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316Ab0KPQbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 11:31:00 -0500
Received: by eye27 with SMTP id 27so403462eye.19
        for <netdev@vger.kernel.org>; Tue, 16 Nov 2010 08:30:59 -0800 (PST)
In-Reply-To: <201011162331.CGH00026.OFOSFVMFQtLHOJ@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 16 novembre 2010 =C3=A0 23:31 +0900, Tetsuo Handa a =C3=A9crit=
 :
> Eric Dumazet wrote:
> > Patch seems fine to me, with the 'const' codes[] Michael Tokarev al=
ready
> > spotted.
>=20
> Sorry, I forgot to evaluate
>=20
> 	default:
> 		return -EINVAL;
> 	}
>=20
> case. If caller passed ftest->code =3D=3D BPF_S_ALU_DIV_K (translated=
 value)
> rather than ftest->code =3D=3D BPF_ALU|BPF_DIV|BPF_K (original value)=
, the check
>=20
> 	case BPF_ALU|BPF_DIV|BPF_K:
> 		if (ftest->k =3D=3D 0)
> 			return -EINVAL;
> 		ftest->code =3D BPF_S_ALU_DIV_K;
> 		break;
>=20
> is bypassed. The problem is that original value and translated value =
overwraps.
> Can we change translated value in order to guarantee that these value=
s never
> overwraps?


I dont understand the problem...
Once translated, you have to test the translated code, not the original
one ;)


> ----------------------------------------
>  From 7b6a7b784fa096383aadc86d32bff6b8329a2e66 Mon Sep 17 00:00:00 20=
01
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Tue, 16 Nov 2010 22:37:45 +0900
> Subject: [PATCH v2] filter: optimize instruction revalidation code.
>=20
> Since repeating small value to small value conversion using switch() =
clause's
> case statement is wasteful, this patch instroduces u16 to u16 mapping=
 table
> and removes most of case statements. As a result, the size of net/cor=
e/filter.o
> is reduced by about 27% on x86.
>=20
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  net/core/filter.c |  223 ++++++++++++++++---------------------------=
----------
>  1 files changed, 68 insertions(+), 155 deletions(-)
>=20
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 23e9b2a..ef1d226 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -383,7 +383,57 @@ EXPORT_SYMBOL(sk_run_filter);
>   */
>  int sk_chk_filter(struct sock_filter *filter, int flen)
>  {
> -	struct sock_filter *ftest;
> +	/*
> +	 * Valid instructions are initialized to non-0.
> +	 * Invalid instructions are initialized to 0.
> +	 */
> +	static const u16 codes[] =3D {


why u16 ?=20

You store translated instructions, so u8 is OK

> +		[BPF_ALU|BPF_ADD|BPF_K]  =3D BPF_S_ALU_ADD_K + 1,
> +		[BPF_ALU|BPF_ADD|BPF_X]  =3D BPF_S_ALU_ADD_X + 1,
> +		[BPF_ALU|BPF_SUB|BPF_K]  =3D BPF_S_ALU_SUB_K + 1,
> +		[BPF_ALU|BPF_SUB|BPF_X]  =3D BPF_S_ALU_SUB_X + 1,
> +		[BPF_ALU|BPF_MUL|BPF_K]  =3D BPF_S_ALU_MUL_K + 1,



Also fix the indentation at the end of sk_chk_filter()

You have 3 extra tabulations :

        /* last instruction must be a RET code */
        switch (filter[flen - 1].code) {
        case BPF_S_RET_K:
        case BPF_S_RET_A:
                return 0;
                break;
!here!          default:
!here!                   return -EINVAL;
!here!          }
}
EXPORT_SYMBOL(sk_chk_filter);


