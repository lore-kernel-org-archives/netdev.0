From: Vladimir Davydov <vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Subject: Re: [PATCH 13/13] mm: memcontrol: hook up vmpressure to socket
 pressure
Date: Mon, 30 Nov 2015 14:36:28 +0300
Message-ID: <20151130113628.GB24704@esperanza>
References: <1448401925-22501-1-git-send-email-hannes@cmpxchg.org>
 <20151124215940.GB1373@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	<cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<kernel-team-b10kYP2dOMg@public.gmane.org>
To: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151124215940.GB1373-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 24, 2015 at 04:59:40PM -0500, Johannes Weiner wrote:
...
> @@ -2396,6 +2396,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  		memcg = mem_cgroup_iter(root, NULL, &reclaim);
>  		do {
>  			unsigned long lru_pages;
> +			unsigned long reclaimed;
>  			unsigned long scanned;
>  			struct lruvec *lruvec;
>  			int swappiness;
> @@ -2408,6 +2409,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  
>  			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
>  			swappiness = mem_cgroup_swappiness(memcg);
> +			reclaimed = sc->nr_reclaimed;
>  			scanned = sc->nr_scanned;
>  
>  			shrink_lruvec(lruvec, swappiness, sc, &lru_pages);
> @@ -2418,6 +2420,11 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  					    memcg, sc->nr_scanned - scanned,
>  					    lru_pages);
>  
> +			/* Record the group's reclaim efficiency */
> +			vmpressure(sc->gfp_mask, memcg, false,
> +				   sc->nr_scanned - scanned,
> +				   sc->nr_reclaimed - reclaimed);
> +

Suppose we have the following cgroup configuration.

A __ B
  \_ C

A is empty (which is natural for the unified hierarchy AFAIU). B has
some workload running in it, and C generates socket pressure. Due to the
socket pressure coming from C we start reclaim in A, which results in
thrashing of B, but we might not put sockets under pressure in A or C,
because vmpressure does not account pages scanned/reclaimed in B when
generating a vmpressure event for A or C. This might result in
aggressive reclaim and thrashing in B w/o generating a signal for C to
stop growing socket buffers.

Do you think such a situation is possible? If so, would it make sense to
switch to post-order walk in shrink_zone and pass sub-tree
scanned/reclaimed stats to vmpressure for each scanned memcg?

Thanks,
Vladimir

>  			/*
>  			 * Direct reclaim and kswapd have to scan all memory
>  			 * cgroups to fulfill the overall scan target for the
> @@ -2449,7 +2456,8 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
>  			reclaim_state->reclaimed_slab = 0;
>  		}
>  
> -		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
> +		/* Record the subtree's reclaim efficiency */
> +		vmpressure(sc->gfp_mask, sc->target_mem_cgroup, true,
>  			   sc->nr_scanned - nr_scanned,
>  			   sc->nr_reclaimed - nr_reclaimed);
>  
