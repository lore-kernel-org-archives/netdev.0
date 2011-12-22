From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] ARM: net: JIT compiler for packet filters
Date: Thu, 22 Dec 2011 14:43:26 +0100
Message-ID: <1324561406.2153.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1324558747-15325-1-git-send-email-mgherzan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux@arm.linux.org.uk
To: Mircea Gherzan <mgherzan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:59857 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab1LVNna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 08:43:30 -0500
Received: by wibhm6 with SMTP id hm6so2534897wib.19
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 05:43:29 -0800 (PST)
In-Reply-To: <1324558747-15325-1-git-send-email-mgherzan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 d=C3=A9cembre 2011 =C3=A0 13:59 +0100, Mircea Gherzan a =C3=
=A9crit :
> Based of Matt Evans's PPC64 implementation.
>=20
> The compiler generates ARM instructions but interworking is
> supported for Thumb2 kernels.
>=20
> Supports both little and big endian. Unaligned loads are emitted
> for ARMv6+. Not all the BPF opcodes that deal with ancillary data
> are supported. The scratch memory of the filter lives on the stack.
> Hardware integer division is used if it is available.
>=20
> Enabled in the same way as for x86-64 and PPC64:
>=20
> 	echo 1 > /proc/sys/net/core/bpf_jit_enable
>=20
> A value greater than 1 enables opcode output.
>=20
> Signed-off-by: Mircea Gherzan <mgherzan@gmail.com>
> ---

=2E..

> +/*
> + * ABI:
> + *
> + * r0	scratch register
> + * r4	BPF register A
> + * r5	BPF register X
> + * r6	pointer to the skb
> + * r7	skb->data
> + * r8	skb_headlen(skb)
> + */
> +
> +#define r_scratch	ARM_R0
> +/* r1-r3 are (also) used for the unaligned loads on the non-ARMv7 sl=
owpath */
> +#define r_off		ARM_R1
> +#define r_A		ARM_R4
> +#define r_X		ARM_R5
> +#define r_skb		ARM_R6
> +#define r_skb_data	ARM_R7
> +#define r_skb_hl	ARM_R8
> +
> +#define SCRATCH_SP_OFFSET	0
> +#define SCRATCH_OFF(k)		(SCRATCH_SP_OFFSET + (k))
> +
> +#define SEEN_MEM		((1 << BPF_MEMWORDS) - 1)
> +#define SEEN_MEM_WORD(k)	(1 << (k))
> +#define SEEN_X			(1 << BPF_MEMWORDS)
> +#define SEEN_CALL		(1 << (BPF_MEMWORDS + 1))
> +#define SEEN_DATA		(1 << (BPF_MEMWORDS + 2))


> +#define SEEN_LEN		(1 << (BPF_MEMWORDS + 3))

This seems wrong. skb->len has nothing special, its a particular case o=
f
skb dereferencing.

You should rename this to SEEN_SKB_REF, and use it for everything
needing r_skb :




> +	if (ctx->seen & (SEEN_DATA | SEEN_LEN))
> +		emit(ARM_MOV_R(r_skb, ARM_R0), ctx);
> +

here you handled the thing correctly.

> +		case BPF_S_LD_W_LEN:
> +			ctx->seen |=3D SEEN_LEN;
> +			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, len) !=3D 4);
> +			emit(ARM_LDR_I(r_A, r_skb,
> +				       offsetof(struct sk_buff, len)), ctx);
> +			break;


but here there is a problem :
> +		case BPF_S_ANC_PROTOCOL:
> +			/* A =3D ntohs(skb->protocol) */
> +			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
> +						  protocol) !=3D 2);
> +			off =3D offsetof(struct sk_buff, protocol);
> +			emit(ARM_LDRH_I(r_scratch, r_skb, off), ctx);
> +			emit_swap16(r_A, r_scratch, ctx);
> +			break;

here too :
> +		case BPF_S_ANC_IFINDEX:
> +			/* A =3D skb->dev->ifindex */
> +			off =3D offsetof(struct sk_buff, dev);
> +			emit(ARM_LDR_I(r_scratch, r_skb, off), ctx);
> +
> +			emit(ARM_CMP_I(r_scratch, 0), ctx);
> +			emit_err_ret(ARM_COND_EQ, ctx);
> +
> +			BUILD_BUG_ON(FIELD_SIZEOF(struct net_device,
> +						  ifindex) !=3D 4);
> +			off =3D offsetof(struct net_device, ifindex);
> +			emit(ARM_LDR_I(r_A, r_scratch, off), ctx);
> +			break;

here too :
> +		case BPF_S_ANC_MARK:
> +			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, mark) !=3D 4);
> +			off =3D offsetof(struct sk_buff, mark);
> +			emit(ARM_LDR_I(r_A, r_skb, off), ctx);
> +			break;

here too :
> +		case BPF_S_ANC_RXHASH:
> +			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, rxhash) !=3D 4);
> +			off =3D offsetof(struct sk_buff, rxhash);
> +			emit(ARM_LDR_I(r_A, r_skb, off), ctx);
> +			break;

and also here :
> +		case BPF_S_ANC_QUEUE:
> +			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
> +						  queue_mapping) !=3D 2);
> +			BUILD_BUG_ON(offsetof(struct sk_buff,
> +					      queue_mapping) > 0xff);
> +			off =3D offsetof(struct sk_buff, queue_mapping);
> +			emit(ARM_LDRH_I(r_A, r_skb, off), ctx);
> +			break;
