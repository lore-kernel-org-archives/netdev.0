From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix panic in __d_lookup with high dentry hashtable
 counts
Date: Tue, 17 Jan 2012 12:22:29 -0500 (EST)
Message-ID: <20120117.122229.323838457367599504.davem@davemloft.net>
References: <20120113155237.GA25103@sgi.com>
	<20120113162236.GK23916@ZenIV.linux.org.uk>
	<20120117171352.GA18738@sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, viro@ZenIV.linux.org.uk,
	eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, paul.gortmaker@windriver.com,
	akpm@linux-foundation.org, jkosina@suse.cz, avi@redhat.com,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: sivanich@sgi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120117171352.GA18738@sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dimitri Sivanich <sivanich@sgi.com>
Date: Tue, 17 Jan 2012 11:13:52 -0600

> When the number of dentry cache hash table entries gets too high
> (2147483648 entries), as happens by default on a 16TB system, use
> of a signed integer in the dcache_init() initialization loop prevents
> the dentry_hashtable from getting initialized, causing a panic in
> __d_lookup().
> 
> In addition, the _hash_mask returned from alloc_large_system_hash() does
> not support more than a 32 bit hash table size.
> 
> Changing the _hash_mask size returned from alloc_large_system_hash() to
> support larger hash table sizes in the future, and changing loop counter
> sizes appropriately.
> 
> Signed-off-by: Dimitri Sivanich <sivanich@sgi.com>

To be honest I think this is overkill.

Supporting anything larger than a 32-bit hash mask is not even close
to being reasonable.  Nobody needs a 4GB hash table, not for anything.

Instead I would just make sure everything is "unsigned int" or "u32"
and calculations use things like "((u32) 1) << shift", and enforce an
upper bounds of 0x80000000 or similar unconditionally in the hash
allocator itself (rather than conditionally in the networking code).

All of this "long" stuff is madness, what the heck is a long?  It's a
non-fixed type, yet you put constants in your code (0x80000000) which
depend upon that type's size.
