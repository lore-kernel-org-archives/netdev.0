From: Arend van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCHv2 1/2] add basic register-field manipulation macros
Date: Tue, 14 Jun 2016 20:53:28 +0200
Message-ID: <576052A7.2030503@broadcom.com>
References: <1465904660-22242-1-git-send-email-jakub.kicinski@netronome.com>
 <1465904660-22242-2-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, nbd@nbd.name,
	linux-kernel@vger.kernel.org, kvalo@codeaurora.org,
	linux-wireless@vger.kernel.org
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465904660-22242-2-git-send-email-jakub.kicinski@netronome.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14-06-16 13:44, Jakub Kicinski wrote:
> C bitfields are problematic and best avoided.  Developers
> interacting with hardware registers find themselves searching
> for easy-to-use alternatives.  Common approach is to define
> structures or sets of macros containing mask and shift pair.
> Operations on the register are then performed as follows:

[...]

> Compared to Felix Fietkau's implementation from mt76 this one
> uses standard Linux and GCC functions such as is_power_of_2()
> and __builtin_ffsll().
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
> v2:
>  - change Felix's email address.
> 
>  include/linux/bitfield.h | 58 ++++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/log2.h     |  6 +++++
>  2 files changed, 64 insertions(+)
>  create mode 100644 include/linux/bitfield.h
> 
> diff --git a/include/linux/bitfield.h b/include/linux/bitfield.h
> new file mode 100644
> index 000000000000..9560d1877cbc
> --- /dev/null
> +++ b/include/linux/bitfield.h
> @@ -0,0 +1,58 @@
> +/*
> + * Copyright (C) 2014 Felix Fietkau <nbd@nbd.name>
> + * Copyright (C) 2004 - 2009 Ivo van Doorn <IvDoorn@gmail.com>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + */
> +
> +#ifndef _LINUX_BITFIELD_H
> +#define _LINUX_BITFIELD_H
> +
> +#include <asm/types.h>
> +#include <linux/bug.h>
> +#include <linux/log2.h>
> +
> +#define _bf_shf(x) (__builtin_ffsll(x) - 1)
> +
> +#define _BF_FIELD_CHECK(_mask, _val)					\
> +	({								\
> +		const u64 hi = (_mask) + (1ULL << _bf_shf(_mask));	\
> +									\
> +		BUILD_BUG_ON(!(_mask) || (hi && !is_power_of_2_u64(hi))); \
> +		BUILD_BUG_ON(__builtin_constant_p(_val) ?		\
> +			     ~((_mask) >> _bf_shf(_mask)) & (_val) :	\
> +			     0);					\
> +	})

I am sceptic whether it is useful to have 64-bit used here and there is
a price to pay on (many) 32-bit architectures for using 64-bit
operations. Maybe it is not an issue because it is inside BUILD_BUG_ON()
macro.

> +#define FIELD_PUT(_mask, _val)					\
> +	({							\
> +		_BF_FIELD_CHECK(_mask, _val);			\
> +		((u32)(_val) << _bf_shf(_mask)) & (_mask);	\
> +	})
> +
> +#define FIELD_GET(_mask, _val)					\
> +	({							\
> +		_BF_FIELD_CHECK(_mask, 0);			\
> +		(u32)(((_val) & (_mask)) >> _bf_shf(_mask));	\
> +	})
> +
> +#define FIELD_PUT64(_mask, _val)				\
> +	({							\
> +		_BF_FIELD_CHECK(_mask, _val);			\
> +		((u64)(_val) << _bf_shf(_mask)) & (_mask);	\
> +	})
> +
> +#define FIELD_GET64(_mask, _val)				\
> +	({							\
> +		_BF_FIELD_CHECK(_mask, 0);			\
> +		(u64)(((_val) & (_mask)) >> _bf_shf(_mask));	\
> +	})

Is there really hardware out there that exposes 64-bit wide hardware
registers?

Regards,
Arend
