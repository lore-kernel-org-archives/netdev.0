From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH net-next 09/10] net: Add a hardware buffer management helper API
Date: Fri, 29 Jan 2016 19:36:16 +0100
Message-ID: <87twlw6xnj.fsf@free-electrons.com>
References: <1452625834-22166-1-git-send-email-gregory.clement@free-electrons.com>
	<1452625834-22166-10-git-send-email-gregory.clement@free-electrons.com>
	<56A92246.7010807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Simon Guinot <simon.guinot@sequanux.org>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>, Arnd Bergmann <arnd@arndb.de>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

thanks for your review!
 
 On mer., janv. 27 2016, Florian Fainelli <f.fainelli@gmail.com> wrote:

> On 12/01/16 11:10, Gregory CLEMENT wrote:
>> This basic implementation allows to share code between driver using
>> hardware buffer management. As the code is hardware agnostic, there is
>> few helpers, most of the optimization brought by the an HW BM has to be
>> done at driver level.
>> 
>> Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
>> ---
>>  include/net/hwbm.h | 19 +++++++++++++
>>  net/core/Makefile  |  2 +-
>>  net/core/hwbm.c    | 78 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>>  3 files changed, 98 insertions(+), 1 deletion(-)
>>  create mode 100644 include/net/hwbm.h
>>  create mode 100644 net/core/hwbm.c
>> 
>> diff --git a/include/net/hwbm.h b/include/net/hwbm.h
>> new file mode 100644
>> index 000000000000..898ccd2fb58d
>> --- /dev/null
>> +++ b/include/net/hwbm.h
>> @@ -0,0 +1,19 @@
>> +#ifndef _HWBM_H
>> +#define _HWBM_H
>> +
>> +struct hwbm_pool {
>> +	/* Size of the buffers managed */
>> +	int size;
>> +	/* Number of buffers currently used by this pool */
>> +	int buf_num;
>> +	/* constructor called during alocation */
>> +	int (*construct)(struct hwbm_pool *bm_pool, void *buf);
>
> Having the buffer size might be handy too.
>
>> +	/* private data */
>> +	void *priv;
>> +};
>> +
>> +void hwbm_buf_free(struct hwbm_pool *bm_pool, void *buf);
>> +int hwbm_pool_refill(struct hwbm_pool *bm_pool);
>> +int hwbm_pool_add(struct hwbm_pool *bm_pool, int buf_num);
>> +
>> +#endif /* _HWBM_H */
>> diff --git a/net/core/Makefile b/net/core/Makefile
>> index 0b835de04de3..df81bf11f072 100644
>> --- a/net/core/Makefile
>> +++ b/net/core/Makefile
>> @@ -9,7 +9,7 @@ obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
>>  
>>  obj-y		     += dev.o ethtool.o dev_addr_lists.o dst.o netevent.o \
>>  			neighbour.o rtnetlink.o utils.o link_watch.o filter.o \
>> -			sock_diag.o dev_ioctl.o tso.o sock_reuseport.o
>> +			sock_diag.o dev_ioctl.o tso.o sock_reuseport.o hwbm.o
>
> Not everybody will want this built in by default, we probably need a
> hidden config symbol here.

I copied what was done for TSO, but I agree to not build it by default.

>
>>  
>>  obj-$(CONFIG_XFRM) += flow.o
>>  obj-y += net-sysfs.o
>> diff --git a/net/core/hwbm.c b/net/core/hwbm.c
>> new file mode 100644
>> index 000000000000..d5d40d63cb34
>> --- /dev/null
>> +++ b/net/core/hwbm.c
>> @@ -0,0 +1,78 @@
>> +/* Support for hardware buffer manager.
>> + *
>> + * Copyright (C) 2016 Marvell
>> + *
>> + * Gregory CLEMENT <gregory.clement@free-electrons.com>
>> + *
>> + *  This program is free software; you can redistribute it and/or modify
>> + *  it under the terms of the GNU General Public License as published by
>> + *  the Free Software Foundation; either version 2 of the License, or
>> + *  (at your option) any later version.
>> + */
>> +#include <linux/kernel.h>
>> +#include <linux/printk.h>
>> +#include <linux/skbuff.h>
>> +#include <net/hwbm.h>
>> +
>> +void hwbm_buf_free(struct hwbm_pool *bm_pool, void *buf)
>> +{
>> +	if (likely(bm_pool->size <= PAGE_SIZE))
>> +		skb_free_frag(buf);
>> +	else
>> +		kfree(buf);
>> +}
>> +EXPORT_SYMBOL_GPL(hwbm_buf_free);
>> +
>> +/* Refill processing for HW buffer management */
>> +int hwbm_pool_refill(struct hwbm_pool *bm_pool)
>> +{
>> +	void *buf;
>> +	int frag_size = bm_pool->size;
>
> Reverse christmas tree declaration looks a bit nicer.

First time I heard about it :) I though it was something related to the
tree algorithms until I visualized it!

My logical here was first uninitialized variable then the initialized
ones. But I don't have a strong opinion about it so I can change it.

>
>> +
>> +	if (likely(frag_size <= PAGE_SIZE))
>> +		buf = netdev_alloc_frag(frag_size);
>> +	else
>> +		buf = kmalloc(frag_size, GFP_ATOMIC);
>
> Maybe we should allow the caller to specify a gfp_t, just in case
> GFP_ATOMIC is not good enough.

Good idea.

>
>> +
>> +	if (!buf)
>> +		return -ENOMEM;
>> +
>> +	if (bm_pool->construct)
>> +		if (bm_pool->construct(bm_pool, buf)) {
>> +			hwbm_buf_free(bm_pool, buf);
>> +			return -ENOMEM;
>> +		}
>> +
>> +	return 0;
>> +}
>> +EXPORT_SYMBOL_GPL(hwbm_pool_refill);
>> +
>> +int hwbm_pool_add(struct hwbm_pool *bm_pool, int buf_num)
>
> unsigned int buf_num

OK

>
>> +{
>> +	int err, i;
>> +
>> +	if (bm_pool->buf_num == bm_pool->size) {
>> +		pr_debug("pool already filled\n");
>> +		return bm_pool->buf_num;
>> +	}
>> +
>> +	if (buf_num + bm_pool->buf_num > bm_pool->size) {
>> +		pr_debug("cannot allocate %d buffers for pool\n",
>> +			 buf_num);
>> +		return 0;
>> +	}
>
> buf_num is under caller control, and potentially hardware control
> indirectly, what if I make this arbitrary big and wrap around?

We could test if ((buf_num + bm_pool->buf_num)<bm_pool->buf_num. I
failed to find a better way to detect a wrapping.


>
>> +
>> +	for (i = 0; i < buf_num; i++) {
>> +		err = hwbm_pool_refill(bm_pool);
>> +		if (err < 0)
>> +			break;
>> +	}
>
> If we fail refiling here, should not we propagate the error back to the
> caller?

We return the number of we actually managed to add. So, if it fails we
return less buffer than expected, as for a read in userspace. Is it not
a good indication of what happened?

>
>> +
>> +	/* Update BM driver with number of buffers added to pool */
>> +	bm_pool->buf_num += i;
>> +
>> +	pr_debug("hwpm pool: %d of %d buffers added\n", i, buf_num);
>
> No locking or atomic operations here? What if two CPUs call into this
> function?

Indeed it could be a problem, I will see how to handle this in the next
version.

Thanks again,

Gregory

>
>> +
>> +	return i;
>> +}
>> +EXPORT_SYMBOL_GPL(hwbm_pool_add);
>> 
>
>
> -- 
> Florian

-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
