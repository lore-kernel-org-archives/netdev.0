From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: Page allocator bottleneck
Date: Fri, 15 Sep 2017 11:23:20 +0100
Message-ID: <20170915102320.zqceocmvvkyybekj@techsingularity.net>
References: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexei Starovoitov <ast@fb.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>, linux-mm <linux-mm@kvack.org>
To: Tariq Toukan <tariqt@mellanox.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <cef85936-10b2-5d76-9f97-cb03b418fd94@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 14, 2017 at 07:49:31PM +0300, Tariq Toukan wrote:
> Insights:
> Major degradation between #1 and #2, not getting any close to linerate!
> Degradation is fixed between #2 and #3.
> This is because page allocator cannot stand the higher allocation rate.
> In #2, we also see that the addition of rings (cores) reduces BW (!!), as
> result of increasing congestion over shared resources.
> 

Unfortunately, no surprises there. 

> Congestion in this case is very clear.
> When monitored in perf top:
> 85.58% [kernel] [k] queued_spin_lock_slowpath
> 

While it's not proven, the most likely candidate is the zone lock and
that should be confirmed using a call-graph profile. If so, then the
suggestion to tune to the size of the per-cpu allocator would mitigate
the problem.

> I think that page allocator issues should be discussed separately:
> 1) Rate: Increase the allocation rate on a single core.
> 2) Scalability: Reduce congestion and sync overhead between cores.
> 
> This is clearly the current bottleneck in the network stack receive flow.
> 
> I know about some efforts that were made in the past two years.
> For example the ones from Jesper et al.:
> - Page-pool (not accepted AFAIK).

Indeed not and it would also need driver conversion.

> - Page-allocation bulking.

Prototypes exist but it's pointless without the pool or driver
conversion so it's in the back burner for the moment.

> - Optimize order-0 allocations in Per-Cpu-Pages.
> 

This had a prototype that was reverted as it must be able to cope with
both irq and noirq contexts. Unfortunately I never found the time to
revisit it but a split there to handle both would mitigate the problem.
Probably not enough to actually reach line speed though so tuning of the
per-cpu allocator sizes would still be needed. I don't know when I'll
get the chance to revisit it. I'm travelling all next week and am mostly
occupied with other work at the moment that is consuming all my
concentration.

> I am not an mm expert, but wanted to raise the issue again, to combine the
> efforts and hear from you guys about status and possible directions.

The recent effort to reduce overhead from stats will help mitigate the
problem. Finishing the page pool, the bulk allocator and converting drivers
would be the most likely successful path forward but it's currently stalled
as everyone that was previously involved is too busy.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
