From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] ARM: net: JIT compiler for packet filters
Date: Fri, 23 Dec 2011 05:44:17 +0100
Message-ID: <1324615457.2674.6.camel@edumazet-laptop>
References: <1324601625-20351-1-git-send-email-mgherzan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux@arm.linux.org.uk
To: Mircea Gherzan <mgherzan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:44261 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753355Ab1LWEoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 23:44:22 -0500
Received: by werm1 with SMTP id m1so3742407wer.19
        for <netdev@vger.kernel.org>; Thu, 22 Dec 2011 20:44:21 -0800 (PST)
In-Reply-To: <1324601625-20351-1-git-send-email-mgherzan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 23 d=C3=A9cembre 2011 =C3=A0 01:53 +0100, Mircea Gherzan a =
=C3=A9crit :
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
>=20
> Changes in v5:
>  * replace SEEN_LEN with SEEN_SKB
>  * set ctx->seen when handling some ancillary data opcodes

> +		case BPF_S_ANC_CPU:
> +			/* A =3D current_thread_info()->cpu */
> +			emit_mov_i(r_scratch, (~(THREAD_SIZE - 1)), ctx);
> +			emit(ARM_ADD_R(r_scratch, ARM_SP, r_scratch), ctx);

This cant be right ;)

> +
> +			BUILD_BUG_ON(FIELD_SIZEOF(struct thread_info, cpu) !=3D 4);
> +			off =3D offsetof(struct thread_info, cpu);
> +			emit(ARM_LDR_I(r_A, r_scratch, off), ctx);
> +			break;

code for r_A =3D raw_smp_processor_id(); should be something like :

mov r0, sp
bic r0, r0, #8128   ; 0x1fc0
bic r0, r0, #63 ; 0x3f
ldr r4, [r0, #20]=20
