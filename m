From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ARM: net: JIT compiler for packet filters
Date: Mon, 19 Dec 2011 02:26:57 +0000
Message-ID: <1324261617.2844.103.camel@deadeye>
References: <1324252185-15894-1-git-send-email-mgherzan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
To: Mircea Gherzan <mgherzan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:31457 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752086Ab1LSC1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Dec 2011 21:27:08 -0500
In-Reply-To: <1324252185-15894-1-git-send-email-mgherzan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-12-19 at 00:49 +0100, Mircea Gherzan wrote:
> Based of Matt Evans's PPC64 implementation.
> 
> Supports only ARM mode with EABI.
> 
> Supports both little and big endian. Depends on the support for
> unaligned loads on ARMv7. Does not support all the BPF opcodes
> that deal with ancillary data. The scratch memory of the filter
> lives on the stack.
> 
> Enabled in the same way as for x86-64 and PPC64:
> 
> 	echo 1 > /proc/sys/net/core/bpf_jit_enable
> 
> A value greater than 1 enables opcode output.
> 
> Signed-off-by: Mircea Gherzan <mgherzan@gmail.com>
> ---
>  arch/arm/Kconfig          |    1 +
>  arch/arm/Makefile         |    1 +
>  arch/arm/net/Makefile     |    3 +
>  arch/arm/net/bpf_jit_32.c |  840 +++++++++++++++++++++++++++++++++++++++++++++
>  arch/arm/net/bpf_jit_32.h |  174 ++++++++++
>  5 files changed, 1019 insertions(+), 0 deletions(-)
>  create mode 100644 arch/arm/net/Makefile
>  create mode 100644 arch/arm/net/bpf_jit_32.c
>  create mode 100644 arch/arm/net/bpf_jit_32.h
> 
> diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> index abba5b8..ea65c41 100644
> --- a/arch/arm/Kconfig
> +++ b/arch/arm/Kconfig
> @@ -30,6 +30,7 @@ config ARM
>  	select HAVE_SPARSE_IRQ
>  	select GENERIC_IRQ_SHOW
>  	select CPU_PM if (SUSPEND || CPU_IDLE)
> +	select HAVE_BPF_JIT if (!THUMB2_KERNEL && AEABI)
>  	help
>  	  The ARM series is a line of low-power-consumption RISC chip designs
>  	  licensed by ARM Ltd and targeted at embedded applications and
> diff --git a/arch/arm/Makefile b/arch/arm/Makefile
> index dfcf3b0..8810a10 100644
> --- a/arch/arm/Makefile
> +++ b/arch/arm/Makefile
> @@ -255,6 +255,7 @@ core-$(CONFIG_VFP)		+= arch/arm/vfp/
>  
>  # If we have a machine-specific directory, then include it in the build.
>  core-y				+= arch/arm/kernel/ arch/arm/mm/ arch/arm/common/
> +core-y				+= arch/arm/net/
>  core-y				+= $(machdirs) $(platdirs)
>  
>  drivers-$(CONFIG_OPROFILE)      += arch/arm/oprofile/
> diff --git a/arch/arm/net/Makefile b/arch/arm/net/Makefile
> new file mode 100644
> index 0000000..c2c1084
> --- /dev/null
> +++ b/arch/arm/net/Makefile
> @@ -0,0 +1,3 @@
> +# ARM-specific networking code
> +
> +obj-$(CONFIG_BPF_JIT) += bpf_jit_32.o
> diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
> new file mode 100644
> index 0000000..4d4c2a0
> --- /dev/null
> +++ b/arch/arm/net/bpf_jit_32.c
> @@ -0,0 +1,840 @@
> +/*
> + * Just-In-Time compiler for BPF filters on 32bit ARM
> + *
> + * Copyright (c) 2011 Mircea Gherzan <mgherzan@gmail.com>
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License as published by the
> + * Free Software Foundation; version 2 of the License.
> + */
> +
> +#include <linux/bitops.h>
> +#include <linux/compiler.h>
> +#include <linux/filter.h>
> +#include <linux/moduleloader.h>
> +#include <linux/netdevice.h>
> +#include <linux/string.h>
> +#include <linux/slab.h>
> +#include <asm/cacheflush.h>
> +
> +#include "bpf_jit_32.h"
> +
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
> +/* r1-r3 are (also) used for the unaligned loads on the non-ARMv7 slowpath */
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
> +#define SEEN_MEM		0xff

There are 16 words of memory, so I think this should be defined as
0xffff or as (1 << BPF_MEMWORDS) - 1.

[...]
> +static inline int mem_words_used(struct jit_ctx *ctx)
> +{
> +	u32 words = ctx->seen & SEEN_MEM;
> +	/* yes, we do waste some stack space IF there are "holes" in the set" */
> +	return (words) ? 16 - __builtin_clz(words) : 0;
> +}
[...]

Since the memory words are represented by the low bits in seen, surely
this should be:
	return 32 - __builtin_clz(words);

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
