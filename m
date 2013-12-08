From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next] 6lowpan: Moving generic compression code into
 6lowpan_iphc.c
Date: Sun, 8 Dec 2013 17:00:40 +0100
Message-ID: <20131208160039.GA25554@omega>
References: <1386439370-14549-1-git-send-email-jukka.rissanen@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:57021 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412Ab3LHQAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 11:00:46 -0500
Received: by mail-wi0-f174.google.com with SMTP id z2so2768444wiv.1
        for <netdev@vger.kernel.org>; Sun, 08 Dec 2013 08:00:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1386439370-14549-1-git-send-email-jukka.rissanen@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jukka,

there is something wrong with the debug output. :-)

On Sat, Dec 07, 2013 at 08:02:50PM +0200, Jukka Rissanen wrote:
> Because the IEEE 802154 and Bluetooth share the IP header compression
> and uncompression code, the common code is moved to 6lowpan_iphc.c
> file.
> 
> Signed-off-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>
> ---
> Hi,
> 
> this is just refactoring code so that Bluetooth LE 6LoWPAN
> patches (sent to bluetooth mailing list) can use it.
> No functionality changes by this patch.
> 
> Cheers,
> Jukka
> 
>  net/ieee802154/6lowpan.c      | 753 ++-------------------------------------
>  net/ieee802154/6lowpan.h      |  32 ++
>  net/ieee802154/6lowpan_iphc.c | 807 ++++++++++++++++++++++++++++++++++++++++++
>  net/ieee802154/Makefile       |   2 +-
>  4 files changed, 875 insertions(+), 719 deletions(-)
>  create mode 100644 net/ieee802154/6lowpan_iphc.c
> 
...
> diff --git a/net/ieee802154/6lowpan_iphc.c b/net/ieee802154/6lowpan_iphc.c
> new file mode 100644
> index 0000000..57c0b7a
> --- /dev/null
> +++ b/net/ieee802154/6lowpan_iphc.c
> @@ -0,0 +1,807 @@
> +/*
> + * Copyright 2011, Siemens AG
> + * written by Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
> + */
> +
> +/*
> + * Based on patches from Jon Smirl <jonsmirl@gmail.com>
> + * Copyright (c) 2011 Jon Smirl <jonsmirl@gmail.com>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License along
> + * with this program; if not, write to the Free Software Foundation, Inc.,
> + * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
> + */
> +
> +/* Jon's code is based on 6lowpan implementation for Contiki which is:
> + * Copyright (c) 2008, Swedish Institute of Computer Science.
> + * All rights reserved.
> + *
> + * Redistribution and use in source and binary forms, with or without
> + * modification, are permitted provided that the following conditions
> + * are met:
> + * 1. Redistributions of source code must retain the above copyright
> + *    notice, this list of conditions and the following disclaimer.
> + * 2. Redistributions in binary form must reproduce the above copyright
> + *    notice, this list of conditions and the following disclaimer in the
> + *    documentation and/or other materials provided with the distribution.
> + * 3. Neither the name of the Institute nor the names of its contributors
> + *    may be used to endorse or promote products derived from this software
> + *    without specific prior written permission.
> + *
> + * THIS SOFTWARE IS PROVIDED BY THE INSTITUTE AND CONTRIBUTORS ``AS IS'' AND
> + * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
> + * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
> + * ARE DISCLAIMED.  IN NO EVENT SHALL THE INSTITUTE OR CONTRIBUTORS BE LIABLE
> + * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
> + * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
> + * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
> + * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
> + * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
> + * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
> + * SUCH DAMAGE.
> + */
> +
> +#include <linux/bitops.h>
> +#include <linux/if_arp.h>
> +#include <linux/netdevice.h>
> +#include <net/ipv6.h>
> +#include <net/af_ieee802154.h>
> +
> +#include "6lowpan.h"
> +
> +/* print data in line */
> +static inline void raw_dump_inline(const char *caller, char *msg,
> +				   unsigned char *buf, int len)
> +{
> +	if (msg)
> +		pr_debug("%s():%s: ", caller, msg);
> +	print_hex_dump_debug("", DUMP_PREFIX_NONE,
> +		       16, 1, buf, len, false);
> +}
> +
You should set here a:
#ifdef DEBUG
...
#endif
> +/*
> + * print data in a table format:
> + *
> + * addr: xx xx xx xx xx xx
> + * addr: xx xx xx xx xx xx
> + * ...
> + */
> +static inline void raw_dump_table(const char *caller, char *msg,
> +				unsigned char *buf, int len)
> +{
> +	if (msg)
> +		pr_debug("%s():%s:\n", caller, msg);
> +	print_hex_dump_debug("\t", DUMP_PREFIX_OFFSET,
> +		       16, 1, buf, len, false);
> +}
> +
here too...

I get many debug output and I don't set any debug options. That's
something which should fixed in this patch.

- Alex
