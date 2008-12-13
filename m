From: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH v3 6/7] fs: struct file move from call_rcu() to
 SLAB_DESTROY_BY_RCU
Date: Fri, 12 Dec 2008 19:41:33 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0812121934510.14878@quilx.com>
References: <Pine.LNX.4.64.0811201727070.9089@quilx.com> <493100B0.6090104@cosmosbay.com>
 <494196DD.5070600@cosmosbay.com> <200707241113.46834.nickpiggin@yahoo.com.au>
 <4941EC65.5040903@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Nick Piggin <nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org >> Kernel Testers List"
	<kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	"Paul E. McKenney" <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
To: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4941EC65.5040903-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 12 Dec 2008, Eric Dumazet wrote:


> > This is a non-trivial change, because that put_filp may drop the last
> > reference to the file. So now we have the case where we free the file
> > from a context in which it had never been allocated.
>
> If we got at this point, we :
>
> Found a non NULL pointer in our fd table.
> Then, another thread came, closed the file while we not yet added our reference.
> This file was freed (kmem_cache_free(filp_cachep, file))
> This file was reused and inserted on another thread fd table.
> We added our reference on refcount.
> We checked if this file is still ours (in our fd tab).
> We found this file is not anymore the file we wanted.
> Calling put_filp() here is our only choice to safely remove the reference on
> a truly allocated file. At this point the file is
> a truly allocated file but not anymore ours.
> Unfortunatly we added a reference on it : we must release it.
> If the other thread already called put_filp() because it wanted to close its new file,
> we must see f_refcnt going to zero, and we must call __fput(), to perform
> all the relevant file cleanup ourself.

Correct. That was the idea.

> A final point is that SLUB doesnt need to allocate or free a slab in many cases.
> (This is probably why Christoph needed this patch in 2006 :) )

We needed this patch in 2006 because the AIM9 creat-clo test showed
regressions after the rcu free was put in (discovered during SLES11
verification cycle). All slab allocators do at least defer frees until all
objects in the page are freed if not longer.

> In my case, I need all these patches to speedup http servers.
> They obviously open and close many files per second.

Run AIM9 creat-close tests....

> SLAB_DESTROY_BY_RCU is a must on current hardware, where memory cache line
> misses costs become really problematic. This patch series clearly demonstrate
> it.

Well the issue becomes more severe as accesses to cold memory become more
extensive. Thanks for your work on this.
