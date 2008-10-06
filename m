From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
	gc_elasticity is exceeded
Date: Mon, 6 Oct 2008 09:14:02 -0400
Message-ID: <20081006131402.GC16939@hmsreliant.think-freely.org>
References: <48E1C104.2080801@cosmosbay.com> <20080930.071023.07946874.davem@davemloft.net> <48E25F02.8030303@cosmosbay.com> <20081001180846.GB3566@hmsreliant.think-freely.org> <20081002010101.6f0a1fa5.billfink@mindspring.com> <48E470AC.10305@cosmosbay.com> <48E4832A.3070804@cosmosbay.com> <20081003003158.GA19230@localhost.localdomain> <20081003203640.GA13354@hmsreliant.think-freely.org> <48E9ED3D.2020005@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bill Fink <billfink@mindspring.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60828 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752927AbYJFNQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 09:16:15 -0400
Content-Disposition: inline
In-Reply-To: <48E9ED3D.2020005@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 06, 2008 at 12:49:33PM +0200, Eric Dumazet wrote:
>
> Empty chains should be accounted for, or average and standard
> deviation are not correct.

Fair enough, although for such a large hash table, I would assume that this
would unfairly bias our average to zero, although as I think about that, our
standard deviation would make up for that.

>
>> +		if (unlikely(temp))
>> +			sd += (temp-average)^2;
>
> Out of curiosity, what do you expect to do here ?
>

Doh!  Show off how stupid I can be apparently.  I was doing too much at once,
and was thinking exponentiation there, rather than bitwise XOR.  My bad.

> (temp-average) XOR 2
> or (temp-average) * (temp-average) 
>
> Also, your computations use integer arithmetic.
>
> If avg = 2.5 and sd = 1.9, avg+4*sd you'll find 6 instead of 10 
>
Yes, but I think we're going to have to tolerate some error, since we're using
integer arithmatic here.

> Anyway, we wont add so many atomic operations and double
> hash table size in order to be able to compute sd.
>
That I have to agree with.  The growth in size at the very least doesn't look
overly acceptible.

> If we really want to be smart, we can have a pretty good
> estimate of average and sd for free in rt_check_expire()
>
> Something like this untested patch. (We should make sure
> we dont overflow sum2 for example)
>

> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 6ee5354..85182d9 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -125,6 +125,7 @@ static int ip_rt_redirect_silence __read_mostly	= ((HZ / 50) << (9 + 1));
>  static int ip_rt_error_cost __read_mostly	= HZ;
>  static int ip_rt_error_burst __read_mostly	= 5 * HZ;
>  static int ip_rt_gc_elasticity __read_mostly	= 8;
> +static int rt_chain_length_max __read_mostly    = 32;
>  static int ip_rt_mtu_expires __read_mostly	= 10 * 60 * HZ;
>  static int ip_rt_min_pmtu __read_mostly		= 512 + 20 + 20;
>  static int ip_rt_min_advmss __read_mostly	= 256;
> @@ -748,11 +749,24 @@ static void rt_do_flush(int process_context)
>  	}
>  }
>  
> +/*
> + * While freeing expired entries, we compute average chain length
> + * and standard deviation, using fixed-point arithmetic.
> + * This to have an estimation of rt_chain_length_max
> + *  rt_chain_length_max = max(elasticity, AVG + 4*SD)
> + * We use 3 bits for frational part, and 29 (or 61) for magnitude.
> + */
> +
> +#define FRACT_BITS 3
> +#define ONE (1UL << FRACT_BITS)
> +
>  static void rt_check_expire(void)
>  {
>  	static unsigned int rover;
>  	unsigned int i = rover, goal;
>  	struct rtable *rth, **rthp;
> +	unsigned long sum = 0, sum2 = 0;
> +	unsigned long length, samples = 0;
>  	u64 mult;
>  
>  	mult = ((u64)ip_rt_gc_interval) << rt_hash_log;
> @@ -770,8 +784,10 @@ static void rt_check_expire(void)
>  		if (need_resched())
>  			cond_resched();
>  
> +		samples++;
>  		if (*rthp == NULL)
>  			continue;
> +		length = 0;
>  		spin_lock_bh(rt_hash_lock_addr(i));
>  		while ((rth = *rthp) != NULL) {
>  			if (rt_is_expired(rth)) {
> @@ -784,11 +800,13 @@ static void rt_check_expire(void)
>  				if (time_before_eq(jiffies, rth->u.dst.expires)) {
>  					tmo >>= 1;
>  					rthp = &rth->u.dst.rt_next;
> +					length += ONE;
>  					continue;
>  				}
>  			} else if (!rt_may_expire(rth, tmo, ip_rt_gc_timeout)) {
>  				tmo >>= 1;
>  				rthp = &rth->u.dst.rt_next;
> +				length += ONE;
>  				continue;
>  			}
>  
> @@ -797,6 +815,15 @@ static void rt_check_expire(void)
>  			rt_free(rth);
>  		}
>  		spin_unlock_bh(rt_hash_lock_addr(i));
> +		sum += length;
> +		sum2 += length*length;
> +	}
> +	if (samples) {
> +		unsigned long avg = sum / samples;
> +		unsigned long sd = int_sqrt(sum2 / samples - avg*avg);
> +		rt_chain_length_max = max_t(unsigned long,
> +					    ip_rt_gc_elasticity,
> +					    (avg + 4*sd) >> FRACT_BITS);

Oh!  Thats pretty nifty, I hadn't considered breaking the interger up like that
to avoid round off error.

Although Like computing sd during garbage collection, this method leaves a hole
during which the addition of several entries to one chain may provide a false
positive before the next run of rt_check_expire.  Or is the likelyhood of that
low enough that its not particularly relevant?

Regards
Neil


-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
