From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: fix slab_pad_check()
Date: Thu, 3 Sep 2009 16:17:57 -0700
Message-ID: <20090903231757.GP6761@linux.vnet.ibm.com>
References: <4A9F1620.2080105@gmail.com> <84144f020909022331x2b275aa5n428f88670e0ae8bc@mail.gmail.com> <4A9F7283.1090306@gmail.com> <alpine.DEB.1.10.0909031244230.27903@V090114053VZO-1> <4A9FCDC6.3060003@gmail.com> <alpine.DEB.1.10.0909031335430.29881@V090114053VZO-1> <4A9FDA72.8060001@gmail.com> <alpine.DEB.1.10.0909031414310.29881@V090114053VZO-1> <4AA00400.1030005@gmail.com> <alpine.DEB.1.10.0909031731540.24199@V090114053VZO-1>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Patrick McHardy <kaber@trash.net>, Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0909031731540.24199@V090114053VZO-1>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 03, 2009 at 05:44:54PM -0500, Christoph Lameter wrote:
> On Thu, 3 Sep 2009, Eric Dumazet wrote:
> 
> > It seems very smart, but needs review of all callers to make sure no slabs
> > are waiting for final freeing in call_rcu queue on some cpu.
> 
> Yes. Again this is the first time we encounter a situation where a
> DESTROY_BY_RCU slab has to be destroyed. So the review is quite short.
> 
> > I suspect most of them will then have to use rcu_barrier() before calling
> > kmem_cache_destroy(), so why not factorizing code in one place ?
> 
> There are different forms of RCU which require different forms of
> barriers. Its best to leave that up to the user. Again the user must make
> sure that no objects are in use before a slab is destroyed. For
> SLAB_DESTROY_BY_RCU this means that there are no potential outstanding
> reads on the structure. You may need an rcu_barrier() to accomplish that.
> 
> Slight variations in the use of RCU could require different method. Better
> reduce the entanglement of slabs to RCU to a mininum possible.

If it were the user of the slab who was invoking some variant of
call_rcu(), then I would agree with you.

However, call_rcu() is instead being invoked by the slab itself in the
case of SLAB_DESTROY_BY_RCU, so that there is no variation in usage.
Requiring that the user call rcu_barrier() is asking for subtle bugs.
Therefore, the best approach is to have kmem_cache_destroy() handle
the RCU cleanup, given that this cleanup is for actions taken by
kmem_cache_free(), not by the user.

							Thanx, Paul
