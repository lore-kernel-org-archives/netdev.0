From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] slub: fix slab_pad_check()
Date: Thu, 3 Sep 2009 17:43:12 -0500 (CDT)
Message-ID: <alpine.DEB.1.10.0909031736340.24199@V090114053VZO-1>
References: <4A9EEF07.5070800@gmail.com> <c4e36d110909021531v324a9ce2x3ff2c93b7c5a57de@mail.gmail.com> <4A9F1620.2080105@gmail.com> <84144f020909022331x2b275aa5n428f88670e0ae8bc@mail.gmail.com> <4A9F7283.1090306@gmail.com> <alpine.DEB.1.10.0909031244230.27903@V090114053VZO-1>
 <4A9FCDC6.3060003@gmail.com> <alpine.DEB.1.10.0909031335430.29881@V090114053VZO-1> <4A9FDA72.8060001@gmail.com> <alpine.DEB.1.10.0909031414310.29881@V090114053VZO-1> <20090903174435.GF6761@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Patrick McHardy <kaber@trash.net>, Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090903174435.GF6761@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 3 Sep 2009, Paul E. McKenney wrote:

> 2.	CPU 0 discovers that the slab cache can now be destroyed.
>
> 	It determines that there are no users, and has guaranteed
> 	that there will be no future users.  So it knows that it
> 	can safely do kmem_cache_destroy().
>
> 3.	In absence of rcu_barrier(), kmem_cache_destroy() would
> 	immediately tear down the slab data structures.

Of course. This has been discussed before.

You need to ensure that no objects are in use before destroying a slab. In
case of DESTROY_BY_RCU you must ensure that there are no potential
readers. So use a suitable rcu barrier or something else like a
synchronize_rcu...

> > But going through the RCU period is pointless since no user of the cache
> > remains.
>
> Which is irrelevant.  The outstanding RCU callback was posted by the
> slab cache itself, -not- by the user of the slab cache.

There will be no rcu callbacks generated at kmem_cache_destroy with the
patch I posted.

> > The dismantling does not need RCU since there are no operations on the
> > objects in progress. So simply switch DESTROY_BY_RCU off for close.
>
> Unless I am missing something, this patch re-introduces the bug that
> the rcu_barrier() was added to prevent.  So, in absence of a better
> explanation of what I am missing:

The "fix" was ill advised. Slab users must ensure that no objects are in
use before destroying a slab. Only the slab users know how the objects
are being used. The slab allocator itself cannot know how to ensure that
there are no pending references. Putting a rcu_barrier in there creates an
inconsistency in the operation of kmem_cache_destroy() and an expectation
of functionality that the function cannot provide.

