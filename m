From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: filter: BPF 'JIT' compiler for PPC64
Date: Mon, 18 Jul 2011 10:39:35 +0200
Message-ID: <1310978375.5756.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4E23E5C3.1070209@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
To: Matt Evans <matt@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54229 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745Ab1GRIjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:39:45 -0400
Received: by wyg8 with SMTP id 8so1910550wyg.19
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2011 01:39:44 -0700 (PDT)
In-Reply-To: <4E23E5C3.1070209@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 18 juillet 2011 =C3=A0 17:50 +1000, Matt Evans a =C3=A9crit :
> An implementation of a code generator for BPF programs to speed up pa=
cket
> filtering on PPC64, inspired by Eric Dumazet's x86-64 version.
>=20
> Filter code is generated as an ABI-compliant function in module_alloc=
()'d mem
> with stackframe & prologue/epilogue generated if required (simple fil=
ters don't
> need anything more than an li/blr).  The filter's local variables, M[=
], live in
> registers.  Supports all BPF opcodes, although "complicated" loads fr=
om negative
> packet offsets (e.g. SKF_LL_OFF) are not yet supported.
>=20
> There are a couple of further optimisations left for future work; man=
y-pass
> assembly with branch-reach reduction and a register allocator to push=
 M[]
> variables into volatile registers would improve the code quality furt=
her.
>=20
> This currently supports big-endian 64-bit PowerPC only (but is fairly=
 simple
> to port to PPC32 or LE!).
>=20
> Enabled in the same way as x86-64:
>=20
> 	echo 1 > /proc/sys/net/core/bpf_jit_enable
>=20
> Or, enabled with extra debug output:
>=20
> 	echo 2 > /proc/sys/net/core/bpf_jit_enable
>=20
> Signed-off-by: Matt Evans <matt@ozlabs.org>
> ---
>=20
> Since the RFC post, this has incorporated the bugfixes/tidies from re=
view plus a
> couple more found in further testing, plus some general/comment tidie=
s.

Hi Matt

A small note about SEEN_XREG usage in PPC against x86_64 :

In x86_64, XREG is stored in EBX : I had to save/restore it in function
prologue epilogue. And set it to zero in prologue to avoid leak of
kernel information.

In PPC, you chose a scratch register, so you only have to zero it in
function prologue, if X is ever read.

So in PPC SEEN_XREG only is to be set of X is read, not if written.

So you dont have to set SEEN_XREG bit in this part :

> +		case BPF_S_MISC_TAX: /* X =3D A */
> +			ctx->seen |=3D SEEN_XREG;
> +			PPC_MR(r_X, r_A);
> +			break;

and in this part :

> +		case BPF_S_LDX_IMM: /* X =3D K */
> +			ctx->seen |=3D SEEN_XREG;
> +			PPC_LI32(r_X, K);
> +			break;

and :

> +		case BPF_S_LDX_MEM: /* X =3D mem[K] */
> +			PPC_MR(r_X, r_M + (K & 0xf));
> +			ctx->seen |=3D SEEN_XREG | SEEN_MEM | (1<<(K & 0xf));
> +			break;

and :

> +		case BPF_S_LDX_W_LEN: /* X =3D skb->len; */
> +			ctx->seen |=3D SEEN_XREG;
> +			PPC_LWZ_OFFS(r_X, r_skb, offsetof(struct sk_buff, len));
> +			break;
> +



