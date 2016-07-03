From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCHv3 wl-drv-next 1/2] add basic register-field manipulation
 macros
Date: Sun, 3 Jul 2016 21:54:45 +0200
Message-ID: <90392b12-b953-10fa-4bb0-ceb7e099d144@stressinduktion.org>
References: <1467408409-24224-1-git-send-email-jakub.kicinski@netronome.com>
 <1467408409-24224-2-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nbd@nbd.name, linux-kernel@vger.kernel.org
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
	kvalo@codeaurora.org, linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:38257 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752850AbcGCTyv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jul 2016 15:54:51 -0400
In-Reply-To: <1467408409-24224-2-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.07.2016 23:26, Jakub Kicinski wrote:
> C bitfields are problematic and best avoided.  Developers
> interacting with hardware registers find themselves searching
> for easy-to-use alternatives.  Common approach is to define
> structures or sets of macros containing mask and shift pair.
> Operations on the register are then performed as follows:
> 
>  field = (reg >> shift) & mask;
> 
>  reg &= ~(mask << shift);
>  reg |= (field & mask) << shift;
> 
> Defining shift and mask separately is tedious.  Ivo van Doorn
> came up with an idea of computing them at compilation time
> based on a single shifted mask (later refined by Felix) which
> can be used like this:
> 
>  #define REG_FIELD 0x000ff000
> 
>  field = FIELD_GET(REG_FIELD, reg);
> 
>  reg &= ~REG_FIELD;
>  reg |= FIELD_PUT(REG_FIELD, field);
> 
> FIELD_{GET,PUT} macros take care of finding out what the
> appropriate shift is based on compilation time ffs operation.
> 
> GENMASK can be used to define registers (which is usually
> less error-prone and easier to match with datasheets).
> 
> This approach is the most convenient I've seen so to limit code
> multiplication let's move the macros to a global header file.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
>  include/linux/bitfield.h | 58 ++++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/bug.h      |  3 +++
>  2 files changed, 61 insertions(+)
>  create mode 100644 include/linux/bitfield.h
> 
> diff --git a/include/linux/bitfield.h b/include/linux/bitfield.h
> new file mode 100644
> index 000000000000..d6a36c3c1775
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
> +		BUILD_BUG_ON(!(_mask));					\
> +		BUILD_BUG_ON(__builtin_constant_p(_val) ?		\
> +			     ~((_mask) >> _bf_shf(_mask)) & (_val) :	\
> +			     0);					\
> +		__BUILD_BUG_ON_NOT_POWER_OF_2((_mask) +			\
> +					      (1ULL << _bf_shf(_mask))); \
> +	})
> +
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
> +
> +#endif

Cool! I think this is totally fine. Albeit one point: can you put your
commit comment into the header itself. People check header files more
often than git commits for documentation and it should be quickly
graspable by a developer if someone looks them up.

Thanks,
Hannes
