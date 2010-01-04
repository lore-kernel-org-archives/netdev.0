From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] Improve hash function used for full_name_hash()
Date: Mon, 04 Jan 2010 12:46:12 -0800 (PST)
Message-ID: <20100104.124612.158883690.davem@davemloft.net>
References: <1262635784.8178.253.camel@groeck-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: guenter.roeck@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48337
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750770Ab0ADUqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 15:46:09 -0500
In-Reply-To: <1262635784.8178.253.camel@groeck-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <guenter.roeck@ericsson.com>
Date: Mon, 04 Jan 2010 12:09:44 -0800

> Please comment on this proposed patch. It is similar but more generic than 
> a previously proposed change to dev_name_hash() which tried to address 
> the same problem.

Since this changes a filesystem subsystem header file and effects
parts of the kernel outside of networking, you really do need to
CC: linux-kernel at a minimum.  Added...

> The hash function currently used for full_name_hash() produces a large number
> of collisions if hashed names are similar. This can cause performance problems
> if a large number of similar names exist in the kernel (e.g., if there is
> a large number of virtual interfaces).
> 
> For example, when hashing "eth0" .. "eth9999" with a hash table size of 256,
> the resulting minimum hash bucket depth is 0, the maximum depth is 563,
> and the standard deviation is ~136.
> 
> With this patch applied, the same test results in a minimum bucket depth
> of 37, a maximum bucket depth of 42, and a standard deviation of ~1.02.
> 
> The hash factor of 41 was chosen for the following reasons:
> - The resulting standard deviation is significantly better than the standard
>   deviation of the original hash function for all tested hash table sizes
>   (2^x, x=4..16).
> - The hash function is simple.
> - The resulting code does not require a multiply instruction
>   (tested: x86, mips, powerpc).
> - The resulting code is more efficient than the code generated for the
>   original hash (x86, gcc -O2: 3 instead of 7 instructions).
> - The resulting code also works well with more random strings
>   (tested with all file names in a given Linux system).
> 
> Signed-off-by: Guenter Roeck <guenter.roeck@ericsson.com>
> ---
>  include/linux/dcache.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/dcache.h b/include/linux/dcache.h
> index 30b93b2..772755d 100644
> --- a/include/linux/dcache.h
> +++ b/include/linux/dcache.h
> @@ -53,7 +53,7 @@ extern struct dentry_stat_t dentry_stat;
>  static inline unsigned long
>  partial_name_hash(unsigned long c, unsigned long prevhash)
>  {
> -	return (prevhash + (c << 4) + (c >> 4)) * 11;
> +	return (prevhash + c) * 41;
>  }
>  
>  /*
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
