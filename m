From: Scott Wood <oss@buserror.net>
Subject: Re: [9/9] powerpc: optimise csum_partial() call when len is constant
Date: Fri, 4 Mar 2016 23:29:00 -0600
Message-ID: <20160305052900.GA5742@home.buserror.net>
References: <df593a56e52ccd24b758b9d40ae3b414cb4e5372.1442876807.git.christophe.leroy@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, scottwood@freescale.com,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org
To: Christophe Leroy <christophe.leroy@c-s.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <df593a56e52ccd24b758b9d40ae3b414cb4e5372.1442876807.git.christophe.leroy@c-s.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 22, 2015 at 04:34:36PM +0200, Christophe Leroy wrote:
> +/*
> + * computes the checksum of a memory block at buff, length len,
> + * and adds in "sum" (32-bit)
> + *
> + * returns a 32-bit number suitable for feeding into itself
> + * or csum_tcpudp_magic
> + *
> + * this function must be called with even lengths, except
> + * for the last fragment, which may be odd
> + *
> + * it's best to have buff aligned on a 32-bit boundary
> + */
> +__wsum __csum_partial(const void *buff, int len, __wsum sum);
> +
> +static inline __wsum csum_partial(const void *buff, int len, __wsum sum)
> +{
> +	if (__builtin_constant_p(len) && len == 0)
> +		return sum;
> +
> +	if (__builtin_constant_p(len) && len <= 16 && (len & 1) == 0) {
> +		__wsum sum1;
> +
> +		if (len == 2)
> +			sum1 = (__force u32)*(u16 *)buff;
> +		if (len >= 4)
> +			sum1 = *(u32 *)buff;
> +		if (len == 6)
> +			sum1 = csum_add(sum1, (__force u32)*(u16 *)(buff + 4));
> +		if (len >= 8)
> +			sum1 = csum_add(sum1, *(u32 *)(buff + 4));
> +		if (len == 10)
> +			sum1 = csum_add(sum1, (__force u32)*(u16 *)(buff + 8));
> +		if (len >= 12)
> +			sum1 = csum_add(sum1, *(u32 *)(buff + 8));
> +		if (len == 14)
> +			sum1 = csum_add(sum1, (__force u32)*(u16 *)(buff + 12));
> +		if (len >= 16)
> +			sum1 = csum_add(sum1, *(u32 *)(buff + 12));
> +
> +		sum = csum_add(sum1, sum);

Why the final csum_add instead of s/sum1/sum/ and putting csum_add in the
"len == 2" and "len >= 4" cases?

The (__force u32) casts are unnecessary.  Or rather, it should be
(__force __wsum) -- on all of them, not just the 16-bit ones.

The pointer casts should be const.

> +	} else if (__builtin_constant_p(len) && (len & 3) == 0) {
> +		sum = csum_add(ip_fast_csum_nofold(buff, len >> 2), sum);

It may not make a functional difference, but based on the csum_add()
argument names and other csum_add() usage, sum should come first
and the new content second.

-Scott
