From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH 14/14] mm: memcontrol: hook up vmpressure to socket
 pressure
Date: Tue, 17 Nov 2015 17:22:17 -0500
Message-ID: <20151117222217.GA20394@cmpxchg.org>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-15-git-send-email-hannes@cmpxchg.org>
 <20151115135457.GM31308@esperanza>
 <20151116185316.GC32544@cmpxchg.org>
 <20151117201849.GQ31308@esperanza>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-team-b10kYP2dOMg@public.gmane.org
To: Vladimir Davydov <vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151117201849.GQ31308@esperanza>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 17, 2015 at 11:18:50PM +0300, Vladimir Davydov wrote:
> AFAIK vmpressure was designed to allow userspace to tune hard limits of
> cgroups in accordance with their demands, in which case the way how
> vmpressure notifications work makes sense.

You can still do that when the reporting happens on the reclaim level,
it's easy to figure out where the pressure comes from once a group is
struggling to reclaim its LRU pages.

Reporting on the pressure level does nothing but destroy valuable
information that would be useful in scenarios other than tuning a
hierarchical memory limit.

> > But you guys were wary about the patch that changed it, and this
> 
> Changing vmpressure semantics as you proposed in v1 would result in
> userspace getting notifications even if cgroup does not hit its limit.
> May be it could be useful to someone (e.g. it could help tuning
> memory.low), but I am pretty sure this would also result in breakages
> for others.

Maybe. I'll look into a two-layer vmpressure recording/reporting model
that would give us reclaim-level events internally while retaining
pressure-level events for the existing userspace interface.

> > series has kicked up enough dust already, so I backed it out.
> > 
> > But this will still be useful. Yes, it won't help in rebalancing an
> > regularly working system, which would be cool, but it'll still help
> > contain a worklad that is growing beyond expectations, which is the
> > scenario that kickstarted this work.
> 
> I haven't looked through all the previous patches in the series, but
> AFAIU they should do the trick, no? Notifying sockets about vmpressure
> is rather needed to protect a workload from itself.

No, the only critical thing is to protect the system from OOM
conditions caused by what should be containerized processes.

That's a correctness issue.

How much we mitigate the consequences inside the container when the
workload screws up is secondary. But even that is already much better
in this series compared to memcg v1, while leaving us with all the
freedom to continue improving this internal mitigation in the future.

> And with this patch it will work this way, but only if sum limits <
> total ram, which is rather rare in practice. On tightly packed
> systems it does nothing.

That's not true, it's still useful when things go south inside a
cgroup, even with overcommitted limits. See above.

We can optimize the continuous global pressure rebalancing later on;
whether that'll be based on a modified vmpressure implementation, or
adding reclaim efficiency to the shrinker API or whatever.

> That said, I don't think we should commit this particular patch. Neither
> do I think socket accounting should be enabled by default in the unified
> hierarchy for now, since the implementation is still incomplete. IMHO.

I don't see a technical basis for either of those suggestions.
