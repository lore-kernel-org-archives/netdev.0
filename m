From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [REGRESSION][PATCH] bpf_jit drops the ball on indirect negative
 mem references
Date: Fri, 30 Mar 2012 11:11:51 +0200
Message-ID: <1333098711.19659.9.camel@edumazet-laptop>
References: <CAPwCz79wO=5zTZmCG+ePfRuEu-p_Vosi18bYZ-MVNZGOdbE3aQ@mail.gmail.com>
	  <1332965129.2325.12.camel@edumazet-glaptop>
	  <CAPwCz7_tnjq32duJSDj21LpRe5TFvGGszH4joQr1DGTjNd7GcA@mail.gmail.com>
	 <1332967172.2325.22.camel@edumazet-glaptop>
	 <4F744D58.3070009@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Matt Evans <matt@ozlabs.org>
To: Jan Seiffert <kaffeemonster@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:36012 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759799Ab2C3JLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Mar 2012 05:11:55 -0400
In-Reply-To: <4F744D58.3070009@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 29 mars 2012 =C3=A0 13:54 +0200, Jan Seiffert a =C3=A9crit :

>=20
> +	.p2align 1
>  bpf_slow_path_word:
>  	bpf_slow_path_common(4)
>  	js	bpf_error
> @@ -115,6 +116,7 @@ bpf_slow_path_word:
>  	bswap	%eax
>  	ret
> =20
> +	.p2align 1
>  bpf_slow_path_half:
>  	bpf_slow_path_common(2)
>  	js	bpf_error
> @@ -123,12 +125,14 @@ bpf_slow_path_half:
>  	movzwl	%ax,%eax
>  	ret

All these ".p2align 1" are noise for this patch.

This should be done as separate patch, explaining the rationale.

=2E..

>  			case BPF_S_LD_W_IND:
> -				func =3D sk_load_word_ind;
> +				func =3D sk_load_word;
>  common_load_ind:		seen |=3D SEEN_DATAREF | SEEN_XREG;
>  				t_offset =3D func - (image + addrs[i]);
> -				EMIT1_off32(0xbe, K);	/* mov imm32,%esi   */
> +				if (K) {
> +					EMIT2(0x8d, 0xb3); /* lea imm32(%rbx),%esi */
> +					EMIT(K, 4);
> +				} else {
> +					EMIT2(0x89,0xde); /* mov %ebx,%esi */
> +				}
>  				EMIT1_off32(0xe8, t_offset);	/* call sk_load_xxx_ind */
>  				break;


Please add the code for imm8 offsets as well ?

if (is_imm8(K))
	EMIT3(0x8d, 0x73, K); /* lea imm8(%rbx),%esi */
else
	EMIT2_off32(0x8d, 0xb3, K); /* lea imm32(%rbx),%esi */

Thanks
