From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 7 Oct 2008 07:38:18 -0700
Message-ID: <20081007143818.GC6384@linux.vnet.ibm.com>
References: <20081006185026.GA10383@minyard.local> <48EA8197.6080502@cosmosbay.com> <1223367480.26330.7.camel@lappy.programming.kicks-ass.net> <48EB2AE3.3080200@cosmosbay.com> <48EB6EE4.8030703@linux-foundation.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>, minyard@acm.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, shemminger@vyatta.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:59885 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752640AbYJGOpJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2008 10:45:09 -0400
Content-Disposition: inline
In-Reply-To: <48EB6EE4.8030703@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 07, 2008 at 09:15:00AM -0500, Christoph Lameter wrote:
> Eric Dumazet wrote:
> >>> Or just add SLAB_DESTROY_BY_RCU to slab creation in proto_register()
> >>> for "struct proto udp_prot/udpv6_prot" so that kmem_cache_free() done
> >>> in sk_prot_free() can defer freeing to RCU...
> >>
> >> Be careful!, SLAB_DESTROY_BY_RCU just means the slab page gets
> >> RCU-freed, this means that slab object pointers stay pointing to valid
> >> memory, but it does _NOT_ mean those slab objects themselves remain
> >> valid.
> >>
> >> The slab allocator is free to re-use those objects at any time -
> >> irrespective of the rcu-grace period. Therefore you will have to be able
> >> to validate that the object you point to is indeed the object you
> >> expect, otherwise strange and wonderful things will happen.
> >>
> > Thanks for this clarification. I guess we really need a rcu head then :)
> 
> No you just need to make sure that the object you located is still active
> (f.e. refcount > 0) and that it is really a match (hash pointers may be
> updated asynchronously and therefore point to the object that has been reused
> for something else).

In some cases, you might be able to not care, but yes, most of the time,
you will need to validate the object.

> Generally it is advisable to use SLAB_DESTROY_BY_RCU because it preserves the
> cache hot advantages of the objects. Regular RCU freeing will let the object
> expire for a tick or so which will result in the cacheline cooling down.

And SLAB_DESTROY_BY_RCU guarantees that the type of the object will
remain the same during any given RCU read-side critical section.

							Thanx, Paul
