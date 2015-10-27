From: Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Date: Tue, 27 Oct 2015 11:41:38 -0400
Message-ID: <20151027154138.GA4665@cmpxchg.org>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-6-git-send-email-hannes@cmpxchg.org>
 <20151023131956.GA15375@dhcp22.suse.cz>
 <20151023.065957.1690815054807881760.davem@davemloft.net>
 <20151026165619.GB2214@cmpxchg.org>
 <20151027122647.GG9891@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	vdavydov-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20151027122647.GG9891-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 27, 2015 at 01:26:47PM +0100, Michal Hocko wrote:
> On Mon 26-10-15 12:56:19, Johannes Weiner wrote:
> [...]
> > Now you could argue that there might exist specialized workloads that
> > need to account anonymous pages and page cache, but not socket memory
> > buffers.
> 
> Exactly, and there are loads doing this. Memcg groups are also created to
> limit anon/page cache consumers to not affect the others running on
> the system (basically in the root memcg context from memcg POV) which
> don't care about tracking and they definitely do not want to pay for an
> additional overhead. We should definitely be able to offer a global
> disable knob for them. The same applies to kmem accounting in general.

I don't see how you make such a clear distinction between, say, page
cache and the dentry cache, and call one user memory and the other
kernel memory. That just doesn't make sense to me. They're both kernel
memory allocated on behalf of the user, the only difference being that
one is tracked on the page level and the other on the slab level, and
we started accounting one before the other.

IMO that's an implementation detail and a historical artifact that
should not be exposed to the user. And that's the thing I hate about
the current opt-out knob.

> > I don't think there is a compelling case for an elaborate interface
> > to make individual memory consumers configurable inside the memory
> > controller.
> 
> I do not think we need an elaborate interface. We just want to have
> a global boot time knob to overwrite the default behavior. This is
> few lines of code and it should give the sufficient flexibility.

Okay, then let's add this for the socket memory to start with. I'll
have to think more about how to distinguish the slab-based consumers.
Or maybe you have an idea.

For now, something like this as a boot commandline?

cgroup.memory=nosocket

So again in summary, no default overhead until you create a cgroup to
specifically track and account memory. And then, when you know what
you are doing and have a specialized workload, you can disable socket
memory as a specific consumer to remove that particular overhead while
still being able to contain page cache, anon, kmem, whatever.

Does that sound like reasonable userinterfacing to everyone?
