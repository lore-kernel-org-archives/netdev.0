From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/6] hash: Introduce ptr_hash_mix routine
Date: Mon, 06 Aug 2012 13:44:59 -0700 (PDT)
Message-ID: <20120806.134459.954167716448843820.davem@davemloft.net>
References: <501FD0F2.4040609@parallels.com>
	<501FD11B.6000006@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, ebiederm@xmission.com,
	netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39170 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755974Ab2HFUpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 16:45:00 -0400
In-Reply-To: <501FD11B.6000006@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Mon, 06 Aug 2012 18:13:47 +0400

> @@ -67,4 +68,13 @@ static inline unsigned long hash_ptr(const void *ptr, unsigned int bits)
>  {
>  	return hash_long((unsigned long)ptr, bits);
>  }
> +
> +static inline u32 ptr_hash_mix(const void *ptr)
> +{
> +#if BITS_PER_LONG == 32
> +	return (u32)(unsigned long)ptr;
> +#else
> +	return (u32)((unsigned long)ptr >> L1_CACHE_SHIFT);
> +#endif
> +}
>  #endif /* _LINUX_HASH_H */

This doesn't make much sense to me.

If the whole 32-bits of the pointer is useful for entropy on 32-bit
why isn't the whole 64-bits useful on 64-bit?

I would, instead, expect something like:

	ptr ^ (ptr >> 32)

for the 64-bit case.

Also, that L1_CACHE_SHIFT is something callers can decide to do.

Only they know the size of their structure, the alignment used to
allocate such objects, and thus what bits are "less relevant" and
therefore profitable to elide from the bottom of the value.
