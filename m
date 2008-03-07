From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 2/3] slab: introduce SMP alignment
Date: Fri, 7 Mar 2008 06:19:44 +0100
Message-ID: <20080307051944.GJ21185@wotan.suse.de>
References: <20080303093529.GB15091@wotan.suse.de> <Pine.LNX.4.64.0803031104570.6917@schroedinger.engr.sgi.com> <20080303200355.GB8974@wotan.suse.de> <Pine.LNX.4.64.0803031208400.16049@schroedinger.engr.sgi.com> <20080303201211.GE8974@wotan.suse.de> <Pine.LNX.4.64.0803031216430.3110@schroedinger.engr.sgi.com> <20080303202411.GH8974@wotan.suse.de> <Pine.LNX.4.64.0803031327330.4375@schroedinger.engr.sgi.com> <20080307043700.GI21185@wotan.suse.de> <Pine.LNX.4.64.0803062108210.1143@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:43188 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752364AbYCGFTq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2008 00:19:46 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803062108210.1143@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 06, 2008 at 09:11:39PM -0800, Christoph Lameter wrote:
> On Fri, 7 Mar 2008, Nick Piggin wrote:
> 
> > > No the slab allocators were optimized for VSMP so that the 
> > > internode_alignment is not necessary there. That was actually one of the 
> > > requirements that triggered the slab numa work.
> > 
> > BTW. can you explain this incredible claim that the slab allocators
> > do not need internode_alignment to avoid false sharing of allocated
> > objects on VSMP? I don't understand how that would work at all.
> 
> The queues are per node which means that pages from which we allocate are 
> distinct per node. As long as processes allocate and free object on a 
> single node all is fine. Problems can arise though if objects are used 
> across node.

This does not solve the problem. Say if you have 2 objects allocated
from a given slab and you want to avoid cacheline contention between
them, then you have to always ensure they don't overlap on the same
cacheline. The fact this happens naturally when you allocate 2 objects
from 2 different nodes doesn't really help: the same single CPU can
allocate objects that you want to avoid false sharing with. Consider
a task struct for example: if you start up a whole lot of worker threads
from a single CPU, then you will allocate them all from that one CPU.
Then they are spread over all CPUs and you get cacheline contention.

Which is why VSMP would legitimately want to use internode alignment
on some structures. And internode alignment is total overkill on any
other type of system, so you can't go around annotating all your
structures with it and hope KMEM_CACHE does the right thing.

