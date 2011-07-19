From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: filter: BPF 'JIT' compiler for PPC64
Date: Tue, 19 Jul 2011 08:51:00 +0200
Message-ID: <1311058260.16961.12.camel@edumazet-laptop>
References: <4E23E5C3.1070209@ozlabs.org>  <4E24E867.9050909@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: Matt Evans <matt@ozlabs.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63846 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045Ab1GSGvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 02:51:07 -0400
Received: by wyg8 with SMTP id 8so2558509wyg.19
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2011 23:51:05 -0700 (PDT)
In-Reply-To: <4E24E867.9050909@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 juillet 2011 =C3=A0 12:13 +1000, Matt Evans a =C3=A9crit :
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
> V2: Removed some cut/paste woe in setting SEEN_X even on writes.
>     Merci for le review, Eric!
>=20
>  arch/powerpc/Kconfig                  |    1 +
>  arch/powerpc/Makefile                 |    3 +-
>  arch/powerpc/include/asm/ppc-opcode.h |   40 ++
>  arch/powerpc/net/Makefile             |    4 +
>  arch/powerpc/net/bpf_jit.S            |  138 +++++++
>  arch/powerpc/net/bpf_jit.h            |  227 +++++++++++
>  arch/powerpc/net/bpf_jit_comp.c       |  690 +++++++++++++++++++++++=
++++++++++
>  7 files changed, 1102 insertions(+), 1 deletions(-)
>=20

> +		case BPF_S_ANC_CPU:
> +#ifdef CONFIG_SMP
> +			/*
> +			 * PACA ptr is r13:
> +			 * raw_smp_processor_id() =3D local_paca->paca_index
> +			 */

This could break if one day linux supports more than 65536 cpus :)

> +			PPC_LHZ_OFFS(r_A, 13,
> +				     offsetof(struct paca_struct, paca_index));
> +#else
> +			PPC_LI(r_A, 0);
> +#endif
> +			break;
> +
> +
> +		case BPF_S_LDX_B_MSH:
> +			/*
> +			 * x86 version drops packet (RET 0) when K<0, whereas
> +			 * interpreter does allow K<0 (__load_pointer, special
> +			 * ancillary data).
> +			 */

Hmm, thanks I'll take a look at this.

> +			func =3D sk_load_byte_msh;
> +			goto common_load;
> +			break;
> +
> +			/*** Jump and branches ***/

> +		default:
> +			/* The filter contains something cruel & unusual.
> +			 * We don't handle it, but also there shouldn't be
> +			 * anything missing from our list.
> +			 */
> +			pr_err("BPF filter opcode %04x (@%d) unsupported\n",
> +			       filter[i].code, i);

You should at least ratelimit this message ?

On x86_64 I chose to silently fall back to interpretor for a "complex
filter" or "unsupported opcode".

> +			return -ENOTSUPP;
> +		}
> +
> +	}
> +	/* Set end-of-body-code address for exit. */
> +	addrs[i] =3D ctx->idx * 4;
> +
> +	return 0;
> +}
> +


