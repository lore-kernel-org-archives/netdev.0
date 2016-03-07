From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/11] rxrpc: Add a common object cache
Date: Mon, 07 Mar 2016 13:42:33 -0500 (EST)
Message-ID: <20160307.134233.201526978853409580.davem@davemloft.net>
References: <20160307143759.18567.8234.stgit@warthog.procyon.org.uk>
	<20160307143806.18567.30020.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: dhowells@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160307143806.18567.30020.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Mon, 07 Mar 2016 14:38:06 +0000

> Add a common object cache implementation for RxRPC.  This will be used to
> cache objects of various types (calls, connections, local and remote
> endpoint records).  Each object that would be cached must contain an
> obj_node struct for the cache to use.  The object's usage count and link
> pointers are here, plus other internal metadata.
> 
> Each object cache consists of a primary hash to which all objects of that
> type must be added and a secondary hash to which objects may also be added
> and removed a single time.  Objects are automatically removed from both
> hashes when they expire.
> 
> Objects start off life with a usage count of 2 - one for the cache and one
> for the caller.  When an object's usage count is reduced to 1, it sits in
> the cache until its expiry time is reached, at which point the cache
> attempts to reduce the count to 0 and, if successful, clean it up.  An
> object with a usage count of 1 in the cache can be looked up and have its
> usage count increased, thereby stopping the expiry process.
> 
> Objects are looked up, unlinked and destroyed under RCU-safe conditions.
> 
> A garbage collector cycles through all the hash buckets in the primary hash
> and compares the expiry times of the usage-count-1 objects to the current
> time, removing any that have expired.  This is kicked by a single timer for
> the whole cache rather than having a timer per object.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

I know you put a lot of time and effort into this, but I want to strongly
recommend against a garbage collected hash table for anything whatsoever.

Especially if the given objects are in some way created/destroyed/etc. by
operations triggerable remotely.

This can be DoS'd quite trivially, and that's why we have removed the ipv4
routing cache which did the same.
