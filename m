From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 8/8] mm: memcontrol: hook up vmpressure to socket pressure
Date: Thu, 22 Oct 2015 21:57:47 +0300
Message-ID: <20151022185747.GQ18351@esperanza>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-9-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>,
	<netdev@vger.kernel.org>, <linux-mm@kvack.org>,
	<cgroups@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1445487696-21545-9-git-send-email-hannes@cmpxchg.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 22, 2015 at 12:21:36AM -0400, Johannes Weiner wrote:
...
> @@ -185,8 +183,29 @@ static void vmpressure_work_fn(struct work_struct *work)
>  	vmpr->reclaimed = 0;
>  	spin_unlock(&vmpr->sr_lock);
>  
> +	level = vmpressure_calc_level(scanned, reclaimed);
> +
> +	if (level > VMPRESSURE_LOW) {

So we start socket_pressure at MEDIUM. Why not at LOW or CRITICAL?

> +		struct mem_cgroup *memcg;
> +		/*
> +		 * Let the socket buffer allocator know that we are
> +		 * having trouble reclaiming LRU pages.
> +		 *
> +		 * For hysteresis, keep the pressure state asserted
> +		 * for a second in which subsequent pressure events
> +		 * can occur.
> +		 *
> +		 * XXX: is vmpressure a global feature or part of
> +		 * memcg? There shouldn't be anything memcg-specific
> +		 * about exporting reclaim success ratios from the VM.
> +		 */
> +		memcg = container_of(vmpr, struct mem_cgroup, vmpressure);
> +		if (memcg != root_mem_cgroup)
> +			memcg->socket_pressure = jiffies + HZ;

Why 1 second?

Thanks,
Vladimir

> +	}
> +
>  	do {
> -		if (vmpressure_event(vmpr, scanned, reclaimed))
> +		if (vmpressure_event(vmpr, level))
>  			break;
>  		/*
>  		 * If not handled, propagate the event upward into the
