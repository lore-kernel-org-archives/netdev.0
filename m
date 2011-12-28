From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6] ARM: net: JIT compiler for packet filters
Date: Wed, 28 Dec 2011 19:42:52 +0100
Message-ID: <1325097772.2607.4.camel@edumazet-laptop>
References: <1325086527-14277-1-git-send-email-mgherzan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux@arm.linux.org.uk, Rabin Vincent <rabin@rab.in>
To: Mircea Gherzan <mgherzan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:40263 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752649Ab1L1Sm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 13:42:56 -0500
Received: by wibhm6 with SMTP id hm6so5787719wib.19
        for <netdev@vger.kernel.org>; Wed, 28 Dec 2011 10:42:55 -0800 (PST)
In-Reply-To: <1325086527-14277-1-git-send-email-mgherzan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 28 d=C3=A9cembre 2011 =C3=A0 16:35 +0100, Mircea Gherzan a =
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
> Changes in v6:
>  * fix the code generation for the ANC_CPU opcode
>=20
> Changes in v5:
>  * replace SEEN_LEN with SEEN_SKB
>  * set ctx->seen when handling some ancillary data opcodes
>=20
> Changes in v4:
>  * first check if the JIT compiler is enabled
>  * fix the code generation for the LDX_MSH opcode
>=20
> Changes in v3:
>  * no longer depend on EABI and !Thumb2
>  * add BLX "emulation" for ARMv4 without Thumb
>  * use the integer divide instruction on Cortex-A15
>  * fix the handling of the DIV_K opcode
>  * use a C wrapper for __aeabi_uidiv
>  * fix the generation of the epilogue (non-FP case)
>=20
> Changes in v2:
>  * enable the compiler only for ARMv5+ because of the BLX instruction
>  * use the same comparison for the ARM version checks
>  * use misaligned accesses on ARMv6
>  * fix the SEEN_MEM
>  * fix the mem_words_used()
>=20

> +
> +static void build_epilogue(struct jit_ctx *ctx)
> +{
> +	u16 reg_set =3D saved_regs(ctx);
> +
> +	if (ctx->seen & SEEN_MEM)
> +		emit(ARM_ADD_I(ARM_SP, ARM_SP, mem_words_used(ctx) * 4), ctx);
> +
> +	reg_set &=3D ~(1 << ARM_LR);
> +
> +#ifdef CONFIG_FRAME_POINTER
> +	/* the first instruction of the prologue was: mov ip, sp */
> +	reg_set &=3D ~(1 << ARM_IP);
> +	reg_set |=3D (1 << ARM_SP);
> +	emit(ARM_LDM(ARM_SP, reg_set), ctx);
> +#else
> +	if (ctx->seen) {
> +		if (ctx->seen & SEEN_CALL)
> +			reg_set |=3D 1 << ARM_PC;
> +		emit(ARM_POP(reg_set), ctx);
> +	}
> +
> +	if (!(ctx->seen & SEEN_CALL))
> +		emit(ARM_BX(ARM_LR), ctx);
> +#endif
> +}
> +

It seems you missed Rabin Vincent feedback ?

TEST 9 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
BPF_STMT(BPF_ALU+BPF_ADD+BPF_K, 1000),
BPF_STMT(BPF_RET+BPF_A, 0)
Code: e92d0010 e3a04000 e2844ffa e1a00004 e12fff1e (0000000000)
(0) retinterp 0x3e8 retjit 0x3e8
+OK
qemu: uncaught target signal 11 (Segmentation fault) - core dumped

All code
=3D=3D=3D=3D=3D=3D=3D=3D
   0:   e92d0010        push    {r4}
   4:   e3a04000        mov     r4, #0
   8:   e2844ffa        add     r4, r4, #1000   ; 0x3e8
   c:   e1a00004        mov     r0, r4
  10:   e12fff1e        bx      lr              <-- no pop
