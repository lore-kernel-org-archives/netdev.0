From: Eric Biggers <ebiggers3@gmail.com>
Subject: Re: [PATCH net-next 1/4] siphash: add cryptographically secure PRF
Date: Fri, 6 Jan 2017 20:04:59 -0800
Message-ID: <20170107040459.GA575@zzz>
References: <20170106.145737.1436197697379516563.davem@davemloft.net>
 <20170106201055.13765-1-Jason@zx2c4.com>
 <20170106201055.13765-2-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        David Laight <David.Laight@aculab.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35663 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934061AbdAGEFD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 23:05:03 -0500
Content-Disposition: inline
In-Reply-To: <20170106201055.13765-2-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jason, just a few comments:

On Fri, Jan 06, 2017 at 09:10:52PM +0100, Jason A. Donenfeld wrote:
> +#define SIPHASH_ALIGNMENT __alignof__(u64)
> +typedef u64 siphash_key_t[2];

I was confused by all the functions passing siphash_key_t "by value" until I saw
that it's actually typedefed to u64[2].  Have you considered making it a struct
instead, something like this?

typedef struct {
	u64 v[2];
} siphash_key_t;

Then it would be strongly typed and thus harder to misuse, and all the functions
would take 'const siphash_key_t *' instead of 'const siphash_key_t' which would
make it clear that the key is passed by pointer not by value.

> +static inline u64 ___siphash_aligned(const __le64 *data, size_t len, const siphash_key_t key)
> +{
> +	if (__builtin_constant_p(len) && len == 4)
> +		return siphash_1u32(le32_to_cpu(data[0]), key);

Small bug here: data[0] is not valid if len is 4.  This can be fixed by casting
to a le32 pointer:

		return siphash_1u32(le32_to_cpup((const __le32 *)data), key);
	
> +static int __init siphash_test_init(void)
> +{
> +	u8 in[64] __aligned(SIPHASH_ALIGNMENT);
> +	u8 in_unaligned[65];

It seems that in_unaligned+1 is meant to be misaligned, but that's not
guaranteed because in_unaligned has no alignment restriction, so it could
theoretically be misaligned in a way that makes in_unaligned+1 aligned.  So it
should be 'in_unaligned[65] __aligned(SIPHASH_ALIGNMENT)'.

There are also a lot of checkpatch warnings produced by this patch.  It looks
like many of them can be ignored, but there may be some that should be
addressed.

- Eric
