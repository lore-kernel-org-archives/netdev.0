From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Bug in random32.c: all-zero outputs with probability 1/2^32,
 other seeding bugs
Date: Tue, 1 Jul 2008 17:34:05 -0700
Message-ID: <20080701173405.cb28db84.akpm@linux-foundation.org>
References: <20080619153045.GC1455@randombit.net>
	<20080701231927.GW7647@pirzuine>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, lloyd@randombit.net,
	"Theodore Ts'o" <tytso@mit.edu>, Matt Mackall <mpm@selenic.com>,
	netdev@vger.kernel.org
To: Benoit Boissinot <bboissin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59964 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751005AbYGBAek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 20:34:40 -0400
In-Reply-To: <20080701231927.GW7647@pirzuine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Jul 2008 01:19:27 +0200
Benoit Boissinot <bboissin@gmail.com> wrote:

> [who maintains random32.c ?]

ah.  I think it's ancient net code which was recently hoisted into lib/.
So: not really anybody.

I've been hopefully cc'ing Matt and Ted in the hope of fooling them
into looking at it.  But a netdev cc is appropriate also.

> On Thu, Jun 19, 2008 at 5:30 PM, Jack Lloyd <lloyd@randombit.net> wrote:
> > Hi,
> >
> > There appears to be an error in how random seeding is done in the
> > random32.c RNG. I am looking at 2.6.25.7.
> >
> [snip]
> >
> > An easy and straightforward fix for this that doesn't require changing
> > any interfaces is to add
> >  s &= 0xFFFFFFFF;
> > before the check in __set_random32, which ensures this condition will
> > be caught by the check. Alternately, you could replace the check for
> > s == 0 with some logic like:
> >  if((s & 0xFFFFFFFF) == 0)
> >     s += 1;
> > since just chopping the seed to 32 bits does throw away some of your
> > seed input (with sizeof(long) == 8, at least; doesn't make any
> > difference for sizeof(long) == 4)
> >
> 
> I think it is cleaner to change the interface to account for long != u32
> 
> The rest of your patch (ensuring values are big enough) looks valid to me.
> 
> Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
> 
> diff -r ced66ca0044f lib/random32.c
> --- a/lib/random32.c	Mon Jun 30 08:58:09 2008 -0700
> +++ b/lib/random32.c	Wed Jul 02 01:13:12 2008 +0200
> @@ -56,7 +56,7 @@
>  	return (state->s1 ^ state->s2 ^ state->s3);
>  }
> 
> -static void __set_random32(struct rnd_state *state, unsigned long s)
> +static void __set_random32(struct rnd_state *state, u32 s)
>  {
>  	if (s == 0)
>  		s = 1;      /* default seed is 1 */
> @@ -84,7 +84,7 @@
>   */
>  u32 random32(void)
>  {
> -	unsigned long r;
> +	u32 r;
>  	struct rnd_state *state = &get_cpu_var(net_rand_state);
>  	r = __random32(state);
>  	put_cpu_var(state);
> @@ -122,7 +122,7 @@
> 
>  	for_each_possible_cpu(i) {
>  		struct rnd_state *state = &per_cpu(net_rand_state,i);
> -		__set_random32(state, i + jiffies);
> +		__set_random32(state, (u32) i + jiffies);
>  	}
>  	return 0;
>  }
> @@ -135,7 +135,7 @@
>  static int __init random32_reseed(void)
>  {
>  	int i;
> -	unsigned long seed;
> +	u32 seed;
> 
>  	for_each_possible_cpu(i) {
>  		struct rnd_state *state = &per_cpu(net_rand_state,i);
