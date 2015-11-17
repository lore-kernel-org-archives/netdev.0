From: Vladimir Davydov <vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Subject: Re: [PATCH 14/14] mm: memcontrol: hook up vmpressure to socket
 pressure
Date: Tue, 17 Nov 2015 23:18:50 +0300
Message-ID: <20151117201849.GQ31308@esperanza>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-15-git-send-email-hannes@cmpxchg.org>
 <20151115135457.GM31308@esperanza>
 <20151116185316.GC32544@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	<cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<kernel-team-b10kYP2dOMg@public.gmane.org>
To: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151116185316.GC32544-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 16, 2015 at 01:53:16PM -0500, Johannes Weiner wrote:
> On Sun, Nov 15, 2015 at 04:54:57PM +0300, Vladimir Davydov wrote:
> > On Thu, Nov 12, 2015 at 06:41:33PM -0500, Johannes Weiner wrote:
> > > Let the networking stack know when a memcg is under reclaim pressure
> > > so that it can clamp its transmit windows accordingly.
> > > 
> > > Whenever the reclaim efficiency of a cgroup's LRU lists drops low
> > > enough for a MEDIUM or HIGH vmpressure event to occur, assert a
> > > pressure state in the socket and tcp memory code that tells it to curb
> > > consumption growth from sockets associated with said control group.
> > > 
> > > vmpressure events are naturally edge triggered, so for hysteresis
> > > assert socket pressure for a second to allow for subsequent vmpressure
> > > events to occur before letting the socket code return to normal.
> > 
> > AFAICS, in contrast to v1, now you don't modify vmpressure behavior,
> > which means socket_pressure will only be set when cgroup hits its
> > high/hard limit. On tightly packed system, this is unlikely IMO -
> > cgroups will mostly experience pressure due to memory shortage at the
> > global level and/or their low limit configuration, in which case no
> > vmpressure events will be triggered and therefore tcp window won't be
> > clamped accordingly.
> 
> Yeah, this is an inherent problem in the vmpressure design and it
> makes the feature significantly less useful than it could be IMO.

AFAIK vmpressure was designed to allow userspace to tune hard limits of
cgroups in accordance with their demands, in which case the way how
vmpressure notifications work makes sense.

> 
> But you guys were wary about the patch that changed it, and this

Changing vmpressure semantics as you proposed in v1 would result in
userspace getting notifications even if cgroup does not hit its limit.
May be it could be useful to someone (e.g. it could help tuning
memory.low), but I am pretty sure this would also result in breakages
for others.

> series has kicked up enough dust already, so I backed it out.
> 
> But this will still be useful. Yes, it won't help in rebalancing an
> regularly working system, which would be cool, but it'll still help
> contain a worklad that is growing beyond expectations, which is the
> scenario that kickstarted this work.

I haven't looked through all the previous patches in the series, but
AFAIU they should do the trick, no? Notifying sockets about vmpressure
is rather needed to protect a workload from itself. And with this patch
it will work this way, but only if sum limits < total ram, which is
rather rare in practice. On tightly packed systems it does nothing.

That said, I don't think we should commit this particular patch. Neither
do I think socket accounting should be enabled by default in the unified
hierarchy for now, since the implementation is still incomplete. IMHO.

Thanks,
Vladimir

> 
> > May be, we could use a per memcg slab shrinker to detect memory
> > pressure? This looks like abusing shrinkers API though.
> 
> Actually, I thought about doing this long-term.
> 
> Shrinkers are a nice way to export VM pressure to auxiliary allocators
> and caches. But currently, the only metric we export is LRU scan rate,
> whose application is limited to ageable caches: it doesn't make sense
> to cause auxiliary workingsets to shrink when the VM is merely picking
> up the drop-behind pages of a one-off page cache stream. I think it
> would make sense for shrinkers to include reclaim efficiency so that
> they can be used by caches that don't have 'accessed' bits and object
> rotation, but are able to shrink based on the cost they're imposing.
> 
> But a change like this is beyond the scope of this series, IMO.
> 
