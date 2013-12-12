From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2 1/2] lib: introduce arch optimized hash library
Date: Thu, 12 Dec 2013 18:54:23 +0100
Message-ID: <52A9F84F.8060500@6wind.com>
References: <1386860946-1621-1-git-send-email-ffusco@redhat.com> <1386860946-1621-2-git-send-email-ffusco@redhat.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Daniel Borkmann <dborkman@redhat.com>,
	Thomas Graf <tgraf@redhat.com>, linux-kernel@vger.kernel.org
To: Francesco Fusco <ffusco@redhat.com>, jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:44999 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079Ab3LLRy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 12:54:26 -0500
Received: by mail-we0-f175.google.com with SMTP id t60so808437wes.34
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 09:54:25 -0800 (PST)
In-Reply-To: <1386860946-1621-2-git-send-email-ffusco@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/12/2013 16:09, Francesco Fusco a =C3=A9crit :
> We introduce a new hashing library that is meant to be used in
> the contexts where speed is more important than uniformity of the
> hashed values. The hash library leverages architecture specific
> implementation to achieve high performance and fall backs to
> jhash() for the generic case.
>
> On Intel-based x86 architectures, the library can exploit the crc32l
> instruction, part of the Intel SSE4.2 instruction set, if the
> instruction is supported by the processor. This implementation
> is twice as fast as the jhash() implementation on an i7 processor.
>
> Additional architectures, such as Arm64 provide instructions for
> accelerating the computation of CRC, so they could be added as well
> in follow-up work.
>
> Signed-off-by: Francesco Fusco <ffusco@redhat.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Thomas Graf <tgraf@redhat.com>
> Cc: linux-kernel@vger.kernel.org
> ---
>   arch/x86/include/asm/hash.h |  7 ++++
>   arch/x86/lib/Makefile       |  2 +-
>   arch/x86/lib/hash.c         | 88 ++++++++++++++++++++++++++++++++++=
+++++++++++
>   include/asm-generic/hash.h  |  9 +++++
>   include/linux/hash.h        | 36 +++++++++++++++++++
>   lib/Makefile                |  2 +-
>   lib/hash.c                  | 38 ++++++++++++++++++++
>   7 files changed, 180 insertions(+), 2 deletions(-)
>   create mode 100644 arch/x86/include/asm/hash.h
>   create mode 100644 arch/x86/lib/hash.c
>   create mode 100644 include/asm-generic/hash.h
>   create mode 100644 lib/hash.c
>
> diff --git a/arch/x86/include/asm/hash.h b/arch/x86/include/asm/hash.=
h
> new file mode 100644
> index 0000000..e8c58f8
> --- /dev/null
> +++ b/arch/x86/include/asm/hash.h
> @@ -0,0 +1,7 @@
> +#ifndef _ASM_X86_HASH_H
> +#define _ASM_X86_HASH_H
> +
> +struct fast_hash_ops;
> +extern void setup_arch_fast_hash(struct fast_hash_ops *ops);
> +
> +#endif /* _ASM_X86_HASH_H */
> diff --git a/arch/x86/lib/Makefile b/arch/x86/lib/Makefile
> index 992d63b..eabcb6e 100644
> --- a/arch/x86/lib/Makefile
> +++ b/arch/x86/lib/Makefile
> @@ -24,7 +24,7 @@ lib-$(CONFIG_SMP) +=3D rwlock.o
>   lib-$(CONFIG_RWSEM_XCHGADD_ALGORITHM) +=3D rwsem.o
>   lib-$(CONFIG_INSTRUCTION_DECODER) +=3D insn.o inat.o
>
> -obj-y +=3D msr.o msr-reg.o msr-reg-export.o
> +obj-y +=3D msr.o msr-reg.o msr-reg-export.o hash.o
>
>   ifeq ($(CONFIG_X86_32),y)
>           obj-y +=3D atomic64_32.o
> diff --git a/arch/x86/lib/hash.c b/arch/x86/lib/hash.c
> new file mode 100644
> index 0000000..3056702
> --- /dev/null
> +++ b/arch/x86/lib/hash.c
> @@ -0,0 +1,88 @@
> +/*
> + * Some portions derived from code covered by the following notice:
> + *
> + * Copyright (c) 2010-2013 Intel Corporation. All rights reserved.
> + * All rights reserved.
Is it possible to trace that this comes from the DPDK?
At least in the commit log, like it was done in the v1.

> + *
> + * Redistribution and use in source and binary forms, with or withou=
t
> + * modification, are permitted provided that the following condition=
s
> + * are met:
> + *
> + *   * Redistributions of source code must retain the above copyrigh=
t
> + *     notice, this list of conditions and the following disclaimer.
> + *   * Redistributions in binary form must reproduce the above copyr=
ight
> + *     notice, this list of conditions and the following disclaimer =
in
> + *     the documentation and/or other materials provided with the
> + *     distribution.
> + *   * Neither the name of Intel Corporation nor the names of its
> + *     contributors may be used to endorse or promote products deriv=
ed
> + *     from this software without specific prior written permission.
> + *
> + * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTO=
RS
> + * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
> + * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS=
 FOR
> + * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRI=
GHT
> + * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDEN=
TAL,
> + * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
> + * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF =
USE,
> + * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON=
 ANY
> + * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TO=
RT
> + * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE=
 USE
> + * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMA=
GE.
> + */
> +
> +#include <linux/hash.h>
> +
> +#include <asm/processor.h>
> +#include <asm/cpufeature.h>
> +#include <asm/hash.h>
> +
> +static inline u32 crc32_u32(u32 crc, u32 val)
> +{
> +	asm ("crc32l %1,%0\n" : "+r" (crc) : "rm" (val));
I'm not an expert, but is it not possible to use intrisics functions, l=
ike it is
done in the original code?


Regards,
Nicolas
