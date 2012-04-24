From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 3/5] change number_of_cpusets to an atomic
Date: Tue, 24 Apr 2012 13:27:09 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1204241318020.26005@router.home>
References: <1335209867-1831-1-git-send-email-glommer@parallels.com> <1335209867-1831-4-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1204241001050.26005@router.home> <4F96D1A8.6040604@parallels.com> <alpine.DEB.2.00.1204241120130.26005@router.home>
 <4F96D50D.4020804@parallels.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F96D50D.4020804-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Apr 2012, Glauber Costa wrote:

> > > It doesn't seem to be the case here.
> >
> > How did you figure that? number_of_cpusets was introduced exactly because
> > the functions are used in places where we do not pay the cost of calling
> > __cpuset_node_allowed_soft/hardwall. Have a look at these. They may take
> > locks etc etc in critical allocation paths
> I am not arguing that.
>
> You want to avoid the cost of processing a function, that's fair.
> (Note that by "function call cost" I don't mean the cost of processing a
> function, but the cost of a (potentially empty) function call.)
> The real question is: Are you okay with the cost of a branch + a global
> variable (which is almost read only) fetch?

No and that is why the static branching comes in. It takes away the global
read of the number_of_cpusets variable in the critical paths.

> The test of a global variable can - and do as of right now - avoid all the
> expensive operations like locking, sleeping, etc, and if you don't need to
> squeeze every nanosecond you can, they are often simpler - and therefore
> better - than static branching.

Better than static branching? This is in critical VM functions and
reducing the cache footprint there is good for everyone.

> Just to mention one point I am coming across these days - that initiated all
> this: static patching holds the cpu_hotplug.lock. So it can't be called if you
> hold any lock that has been already held under the cpu_hotplug.lock. This will
> probably mean any lock the cpuset cgroup needs to take, because it is called -
> and to do a lot of things - from the cpu hotplug handler, that holds the
> cpu_hotplug.lock.

Transitions from one to two cpusets are rare and are only done when a
cpuset is created in the /dev/cpuset hierachy). You could move the
code modification outside of locks or defer action into an event
thread if there are locks in the way.
