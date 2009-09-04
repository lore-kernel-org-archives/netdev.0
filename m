From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] slub: fix slab_pad_check()
Date: Fri, 4 Sep 2009 11:38:53 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909041133440.9781@V090114053VZO-1>
References: <4A9EEF07.5070800@gmail.com> <c4e36d110909021531v324a9ce2x3ff2c93b7c5a57de@mail.gmail.com> <4A9F1620.2080105@gmail.com> <84144f020909022331x2b275aa5n428f88670e0ae8bc@mail.gmail.com> <4A9F7283.1090306@gmail.com> <alpine.DEB.1.10.0909031244230.27903@V090114053VZO-1>
 <4A9FCDC6.3060003@gmail.com> <alpine.DEB.1.10.0909031335430.29881@V090114053VZO-1> <4A9FDA72.8060001@gmail.com> <alpine.DEB.1.10.0909031414310.29881@V090114053VZO-1> <20090903174435.GF6761@linux.vnet.ibm.com> <alpine.DEB.1.10.0909031736340.24199@V090114053VZO-1>
 <4AA03E6A.7070800@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Patrick McHardy <kaber@trash.net>, Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:40179 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757211AbZIDTGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 15:06:51 -0400
In-Reply-To: <4AA03E6A.7070800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 4 Sep 2009, Eric Dumazet wrote:

> Problem is not _objects_ Christoph, but _slabs_, and your patch is not working.

Why?

> Its true that when User calls kmem_cache_destroy(), all _objects_ were
> previously freed. This is mandatory, with or withou SLAB_DESTROY_BY_RCU
> thing

Right.

> Problem is that slub has some internal state, including some to-be-freed _slabs_,
> that User have no control at all on it.

Those are going to be freed without calls to rcu with my patch. The only
reason for earlier rcu frees are user calls to kfree.

> Face it, SLAB_DESTROY_BY_RCU is internal affair (to slub/slab/... allocators)

Nope the user must follow RCU guidelines when using objects.

> We absolutely need a rcu_barrier() somewhere, believe it or not. You can
> argue that it should be done *before*, but it gives no speedup, only
> potential bugs.

I never said that you do not need an rcu_barrier() for this particular
situation? Why suggest such a thing?

The insertion of rcu stuff in the slab code will lead to future bugs since
now the slab logic is tied to the semantics of a particular rcu
implementatin.

> Only case User should do its rcu_barrier() itself is if it knows some
> call_rcu() are pending and are delaying _objects_ freeing (typical
> !SLAB_DESTROY_RCU usage in RCU algos).

Ok then the user already has to deal with the barriers. The API is
inconsistent if you put this into kmem_cache_destroy.

> I dont even understand why you care so much about
> kmem_cache_destroy(SLAB_DESTROY_BY_RCU), given that almost nobody use
> it. We took almost one month to find out what the bug was in first
> place...

This is already the second bug on this issue. Given the complexity of rcu
it is to be experted that inserting more RCU semantics into the slab
allocators is likely to cause future chains of new features and
bugs in slab allocators.

