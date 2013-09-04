From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v2 1/2] random: add prandom_u32_range and
 prandom_u32_max helpers
Date: Wed, 04 Sep 2013 08:54:59 -0700
Message-ID: <1378310099.1787.9.camel@joe-AO722>
References: <1378298247-29364-1-git-send-email-dborkman@redhat.com>
	 <1378298247-29364-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378298247-29364-2-git-send-email-dborkman@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-09-04 at 14:37 +0200, Daniel Borkmann wrote:
> We have implemented the same function over and over, so introduce
> generic helpers that unify these implementations in order to migrate
> such code to use them. Make the API similarly to randomize_range()
> for consistency. prandom_u32_range() generates numbers in [start, end]
> interval and prandom_u32_max() generates numbers in [0, end] interval.

I think these helpers can in many cases cause
poorer compiler generated object code.

> +/**
> + * prandom_u32_range - return a random number in interval [start, end]
> + * @start: lower interval endpoint
> + * @end: higher interval endpoint
> + *
> + * Returns a number that is in the given interval:
> + *
> + *     [...... <range> .....]
> + *   start                  end
> + *
> + * Callers need to make sure that start <= end. Note that the result
> + * depends on PRNG being well distributed in [0, ~0U] space. Here we
> + * use maximally equidistributed combined Tausworthe generator.
> + */
> +static inline u32 prandom_u32_range(u32 start, u32 end)
> +{
> +	return (u32)(((u64) prandom_u32() * (end + 1 - start)) >> 32) + start;
> +}

This is effectively:

	return (prandom_u32() % (end - start)) + start;

and if start and end are constant, gcc can optimize the
division by constant to a 32 bit multiply/shift/add.

I think if you add __builtin_constant_p tests for start
and end and expand the code a little you can still get
the optimizations done.
