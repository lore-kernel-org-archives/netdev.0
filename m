From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 17:32:29 +0100
Message-ID: <1380040349.2736.31.camel@bwh-desktop.uk.level5networks.com>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<jesse.brandeburg@intel.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:39881 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988Ab3IXQcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 12:32:33 -0400
In-Reply-To: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-23 at 15:41 -0700, Tom Herbert wrote:
> Introduce Toeplitz hash functions. Toeplitz is a hash used primarily in
> NICs to performan RSS flow steering.  This is a software implemenation
> of that. In order to make the hash calculation efficient, we precompute
> the possible hash values for each inidividual byte of input. The input
> length is up to 40 bytes, so we make an array of cache[40][256].

The input length is up to 36 bytes, but we need an extra 31 bits in the
key so that each bit of input is multiplied by 32 bits of the key.  The
first dimension should therefore be 36.

But this is still pretty big. :-/

> The implemenation was verified against MSDN "Verify RSS hash" sample
> values.
[...]
> --- /dev/null
> +++ b/lib/toeplitz.c

I'm not convinced that this is going to be useful outside of net.

> @@ -0,0 +1,66 @@
> +/*
> + * Toeplitz hash implemenation. See include/linux/toeplitz.h
> + *
> + * Copyright (c) 2011, Tom Herbert <therbert@google.com>
> + */
> +#include <linux/types.h>
> +#include <linux/kernel.h>
> +#include <linux/slab.h>
> +#include <linux/random.h>
> +#include <linux/toeplitz.h>
> +
> +struct toeplitz *toeplitz_alloc(void)
> +{
> +	return kmalloc(sizeof(struct toeplitz), GFP_KERNEL);
> +}
> +
> +static u32 toeplitz_get_kval(unsigned char *key, int idx)

unsigned int idx

> +{
> +	u32 v, r;
> +	int off, rem;
> +
> +	off = idx / 8;
> +	rem = idx % 8;

Otherwise this requires a 'real' division if the compiler doesn't work
out that idx >= 0.

> +	v = (((unsigned int)key[off]) << 24) +
> +	    (((unsigned int)key[off + 1]) << 16) +
> +	    (((unsigned int)key[off + 2]) << 8) +
> +	    (((unsigned int)key[off + 3]));
> +
> +	r = v << rem | (unsigned int)key[off + 4] >> (8 - rem);
> +	return r;
> +}
> +
> +static inline int idx8(int idx)
> +{
> +#ifdef __LITTLE_ENDIAN
> +        idx = (idx / 8) * 8 + (8 - (idx % 8 + 1));

Or in short: idx ^= 7

> +#endif
> +        return idx;
> +}
> +
> +void toeplitz_init(struct toeplitz *toeplitz, u8 *key_vals)
> +{
> +	int i;
> +	unsigned long a, j;
> +	unsigned int result = 0;
> +
> +	/* Set up key val table */
> +	if (key_vals)
> +		for (i = 0; i < TOEPLITZ_KEY_LEN; i++)
> +			toeplitz->key_vals[i] = key_vals[i];
> +	else
> +		prandom_bytes(toeplitz->key_vals, TOEPLITZ_KEY_LEN);

Should have braces around the if and else bodies.

Is it worth sacrificing a little randomness here by avoiding long runs
of zeroes in the key?

> +       /* Set up key cache table */
> +       for (i = 0; i < TOEPLITZ_KEY_LEN; i++) {
[...]

As I said above, the outer dimension of key_cache should be 36.  The
current loop causes toeplitz_get_kval() to over-run the bounds of the
key_vals array.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
