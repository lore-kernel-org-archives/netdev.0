From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] repairing rtcache killer
Date: Wed, 6 Aug 2003 00:52:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030806005224.4798f744.davem@redhat.com>
References: <200308051340.RAA28267@dub.inr.ac.ru>
	<16175.58503.134543.310459@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, Robert.Olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16175.58503.134543.310459@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 5 Aug 2003 19:08:23 +0200
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

> 
> kuznet@ms2.inr.ac.ru writes:
>  > #   Two serious and interesting mistakes were made in the patch of 2003-06-16.

Mama mia!  This patch exists in 2.4.22-preX too, so full fix
becomes more urgent.

>  For autotuning I think we can have help from a ratio of warm cache
>  hits (in_hit) and misses (in_slow_tot) to set threshhold to trim
>  hash chain lengths.

Yes, I agree, and algorithm can be even not too smart, something like
the following.

Before scan loop, we compute:

	in_hit = in_slow_tot = 0;
	for (i = 0; i < NR_CPUS; i++) {
		if (!cpu_possible(i))
			continue;
		in_hit += per_cpu_ptr(rt_cache_stat, i)->in_hit;
		in_slow_tot += per_cpu_ptr(rt_cache_stat, i)->in_slow_tot;
	}

	aggressive = 0;
	if (in_hit < (in_slow_tot >> 2))
		aggressive = 1;

	thresh = ip_rt_gc_elasticity;
	if (!aggressive)
		thresh <<= 1;

Then the purging test becomes:

	if (chain_length > thresh ||
	    (aggressive &&
	     chain_length > 1 &&
	     !(min_score & (1<<31)))) {
		*candp = cand->u.rt_next;
		rt_free(cand);
	}

To make algorithm cheaper, we can even use only the current
cpu's rt_cache_stat in order to make our decisions about whether
to enter agressive mode or not.

Alexey, given all this what would you like to do?  Should I push
your patch urgently into 2.4.x or spend some more time trying to
solve this issue?
