From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : change layout of ehash table
Date: Thu, 08 Feb 2007 14:56:32 -0800 (PST)
Message-ID: <20070208.145632.74749802.davem@davemloft.net>
References: <20061219224726.GC4274@sortiz.org>
	<20070207.001226.63510892.davem@davemloft.net>
	<200702071159.34935.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@horizon.com, akepner@sgi.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39538
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423323AbXBHW4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 17:56:34 -0500
In-Reply-To: <200702071159.34935.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 7 Feb 2007 11:59:34 +0100

> ehash table layout is currently this one :
> 
> First half of this table is used by sockets not in TIME_WAIT state
> Second half of it is used by sockets in TIME_WAIT state.
> 
> This is non optimal because of for a given hash or socket, the two chain heads 
> are located in separate cache lines.
> Moreover the locks of the second half are never used.
> 
> If instead of this halving, we use two list heads in inet_ehash_bucket instead 
> of only one, we probably can avoid one cache miss, and reduce ram usage, 
> particularly if sizeof(rwlock_t) is big (various CONFIG_DEBUG_SPINLOCK, 
> CONFIG_DEBUG_LOCK_ALLOC settings). So we still halves the table but we keep 
> together related chains to speedup lookups and socket state change.
> 
> In this patch I did not try to align struct inet_ehash_bucket, but a future 
> patch could try to make this structure have a convenient size (a power of two 
> or a multiple of L1_CACHE_SIZE).
> I guess rwlock will just vanish as soon as RCU is plugged into ehash :) , so 
> maybe we dont need to scratch our heads to align the bucket...
> 
> Note : In case struct inet_ehash_bucket is not a power of two, we could 
> probably change alloc_large_system_hash() (in case it use __get_free_pages()) 
> to free the unused space. It currently allocates a big zone, but the last 
> quarter of it could be freed. Again, this should be a temporary 'problem'.
> 
> Patch tested on ipv4 tcp only, but should be OK for IPV6 and DCCP.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

I've applied this, but I _REALLY_ don't like the new multiply
instructions that are used now in the hash indexing paths when
CONFIG_SMP is set.

I think that's a higher cost than the memory waste.
