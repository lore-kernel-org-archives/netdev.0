From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH 0/8] mm: memcontrol: account socket memory in unified
 hierarchy
Date: Mon, 26 Oct 2015 13:22:16 -0400
Message-ID: <20151026172216.GC2214@cmpxchg.org>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <20151022184509.GM18351@esperanza>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Vladimir Davydov <vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151022184509.GM18351@esperanza>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 22, 2015 at 09:45:10PM +0300, Vladimir Davydov wrote:
> Hi Johannes,
> 
> On Thu, Oct 22, 2015 at 12:21:28AM -0400, Johannes Weiner wrote:
> ...
> > Patch #5 adds accounting and tracking of socket memory to the unified
> > hierarchy memory controller, as described above. It uses the existing
> > per-cpu charge caches and triggers high limit reclaim asynchroneously.
> > 
> > Patch #8 uses the vmpressure extension to equalize pressure between
> > the pages tracked natively by the VM and socket buffer pages. As the
> > pool is shared, it makes sense that while natively tracked pages are
> > under duress the network transmit windows are also not increased.
> 
> First of all, I've no experience in networking, so I'm likely to be
> mistaken. Nevertheless I beg to disagree that this patch set is a step
> in the right direction. Here goes why.
> 
> I admit that your idea to get rid of explicit tcp window control knobs
> and size it dynamically basing on memory pressure instead does sound
> tempting, but I don't think it'd always work. The problem is that in
> contrast to, say, dcache, we can't shrink tcp buffers AFAIU, we can only
> stop growing them. Now suppose a system hasn't experienced memory
> pressure for a while. If we don't have explicit tcp window limit, tcp
> buffers on such a system might have eaten almost all available memory
> (because of network load/problems). If a user workload that needs a
> significant amount of memory is started suddenly then, the network code
> will receive a notification and surely stop growing buffers, but all
> those buffers accumulated won't disappear instantly. As a result, the
> workload might be unable to find enough free memory and have no choice
> but invoke OOM killer. This looks unexpected from the user POV.

I'm not getting rid of those knobs, I'm just reusing the old socket
accounting infrastructure in an attempt to make the memory accounting
feature useful to more people in cgroups v2 (unified hierarchy).

We can always come back to think about per-cgroup tcp window limits in
the unified hierarchy, my patches don't get in the way of this. I'm
not removing the knobs in cgroups v1 and I'm not preventing them in v2.

But regardless of tcp window control, we need to account socket memory
in the main memory accounting pool where pressure is shared (to the
best of our abilities) between all accounted memory consumers.

>From an interface standpoint alone, I don't think it's reasonable to
ask users per default to limit different consumers on a case by case
basis. I certainly have no problem with finetuning for scenarios you
describe above, but with memory.current, memory.high, memory.max we
are providing a generic interface to account and contain memory
consumption of workloads. This has to include all major memory
consumers to make semantical sense.

But also, there are people right now for whom the socket buffers cause
system OOM, but the existing memcg's hard tcp window limitq that
exists absolutely wrecks network performance for them. It's not usable
the way it is. It'd be much better to have the socket buffers exert
pressure on the shared pool, and then propagate the overall pressure
back to individual consumers with reclaim, shrinkers, vmpressure etc.
