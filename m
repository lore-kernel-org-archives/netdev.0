From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: reduce number of reference taken on sk_refcnt
Date: Fri, 08 May 2009 14:48:59 -0700 (PDT)
Message-ID: <20090508.144859.152310605.davem@davemloft.net>
References: <m31vqzwzae.fsf@intrepid.localdomain>
	<4A044BE7.3070308@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49034
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757165AbZEHVtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 17:49:03 -0400
In-Reply-To: <4A044BE7.3070308@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 08 May 2009 17:12:39 +0200

> For example, we can avoid the dst_release() cache miss if this
> is done in start_xmit(), and not later in TX completion while freeing skb.
> I tried various patches in the past but unfortunatly it seems
> only safe way to do this is in the driver xmit itself, not in core
> network stack. This would need many patches, one for each driver.

There might be a way around having to hit every driver.

The case we can't muck with is when the route will be used.
Devices which create this kind of situation can be marked with
a flag bit in struct netdevice.  If that flag bit isn't set,
you can drop the DST in dev_hard_start_xmit().

> [PATCH] net: reduce number of reference taken on sk_refcnt
> 
> Current sk_wmem_alloc schema uses a sk_refcnt taken for each packet
> in flight. This hurts some workloads at TX completion time, because
> sock_wfree() has three cache lines to touch at least.
> (one for sk_wmem_alloc, one for testing sk_flags, one
>  to decrement sk_refcnt)
> 
> We could use only one reference count, taken only when sk_wmem_alloc
> is changed from or to ZERO value (ie one reference count for any number
> of in-flight packets)
> 
> Not all atomic_add() must be changed to atomic_add_return(), if we
> know current sk_wmem_alloc is already not null.
> 
> This patch reduces by one number of cache lines dirtied in sock_wfree()
> and number of atomic operation in some workloads. 
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

I like this idea.  Let me know when you have some at least
basic performance numbers and wish to submit this formally.
