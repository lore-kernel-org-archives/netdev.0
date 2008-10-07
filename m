From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 07 Oct 2008 10:17:59 +0200
Message-ID: <1223367480.26330.7.camel@lappy.programming.kicks-ass.net>
References: <20081006185026.GA10383@minyard.local>
	 <48EA8197.6080502@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: minyard@acm.org, Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	paulmck@linux.vnet.ibm.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756358AbYJGISp@vger.kernel.org>
In-Reply-To: <48EA8197.6080502@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2008-10-06 at 23:22 +0200, Eric Dumazet wrote:

> Or just add SLAB_DESTROY_BY_RCU to slab creation in proto_register()
> for "struct proto udp_prot/udpv6_prot" so that kmem_cache_free() 
> done in sk_prot_free() can defer freeing to RCU...

Be careful!, SLAB_DESTROY_BY_RCU just means the slab page gets
RCU-freed, this means that slab object pointers stay pointing to valid
memory, but it does _NOT_ mean those slab objects themselves remain
valid.

The slab allocator is free to re-use those objects at any time -
irrespective of the rcu-grace period. Therefore you will have to be able
to validate that the object you point to is indeed the object you
expect, otherwise strange and wonderful things will happen.
