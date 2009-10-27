From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] dcache: better name hash function
Date: Tue, 27 Oct 2009 03:45:50 +0100
Message-ID: <4AE65EDE.8080605@gmail.com>
References: <200910252158.53921.opurdila@ixiacom.com>	<20091025214357.666350d2@nehalam> <20091026153656.25be4369@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>,
	Al Viro <viro@zeniv.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37267 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753509AbZJ0Cpy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 22:45:54 -0400
In-Reply-To: <20091026153656.25be4369@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com>, Al Viro a =E9crit :
> --- a/include/linux/dcache.h	2009-10-26 14:58:45.220347300 -0700
> +++ b/include/linux/dcache.h	2009-10-26 15:12:15.004160122 -0700
> @@ -45,15 +45,28 @@ struct dentry_stat_t {
>  };
>  extern struct dentry_stat_t dentry_stat;
> =20
> -/* Name hashing routines. Initial hash value */
> -/* Hash courtesy of the R5 hash in reiserfs modulo sign bits */
> -#define init_name_hash()		0
> +/*
> + * Fowler / Noll / Vo (FNV) Hash
> + * see: http://www.isthe.com/chongo/tech/comp/fnv/
> + */
> +#ifdef CONFIG_64BIT
> +#define FNV_PRIME  1099511628211ull
> +#define FNV1_INIT  14695981039346656037ull
> +#else
> +#define FNV_PRIME  16777619u
> +#define FNV1_INIT  2166136261u
> +#endif
> +
> +#define init_name_hash()	FNV1_INIT
> =20
> -/* partial hash update function. Assume roughly 4 bits per character=
 */
> +/* partial hash update function. */
>  static inline unsigned long
> -partial_name_hash(unsigned long c, unsigned long prevhash)
> +partial_name_hash(unsigned char c, unsigned long prevhash)
>  {
> -	return (prevhash + (c << 4) + (c >> 4)) * 11;
> +	prevhash ^=3D c;
> +	prevhash *=3D FNV_PRIME;
> +
> +	return prevhash;
>  }
> =20
>  /*

OK, but thats strlen(name) X (long,long) multiplies.

I suspect you tested on recent x86_64 cpu.

Some arches might have slow multiplies, no ?

jhash() (and others) are optimized by compiler to use basic and fast op=
erations.
jhash operates on blocs of 12 chars per round, so it might be a pretty =
good choice once
out-of-line (because its pretty large and full_name_hash() is now used =
by
a lot of call sites)

Please provide your test program source, so that other can test on vari=
ous arches.

Thanks
