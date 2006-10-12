From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] reduce sizeof(struct inet_peer), cleanup, change
 in peer_check_expire()
Date: Thu, 12 Oct 2006 15:15:29 -0700 (PDT)
Message-ID: <20061012.151529.95506153.davem@davemloft.net>
References: <43CCBF3D.2070900@cosmosbay.com>
	<4415A4C1.1030906@cosmosbay.com>
	<452EA214.7080905@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:697
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751191AbWJLWP3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 18:15:29 -0400
To: dada1@cosmosbay.com
In-Reply-To: <452EA214.7080905@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Thu, 12 Oct 2006 22:14:12 +0200

> 1) shrink struct inet_peer on 64 bits platforms.
> ------------------------------------------------
> I noticed sizeof(struct inet_peer) was 64+8 on x86_64
> 
> As we dont really need 64 bits timestamps (we only care for garbage 
> collection), we can use 32bits ones and reduce sizeof(struct inet_peer) to 64 
> bytes : Because of SLAB_HWCACHE_ALIGN constraint, final allocation is 64 bytes 
> instead of 128 bytes per inet_peer structure.

I'm not convinced this is %100 correct.  There are wrapping
cases that I think aren't covered.

Consider an entry that lives long enough for the lower 32-bits
of jiffies to wrap, then we kill it, but we won't purge it
properly if the wrapped jiffie is close to dtime.

I'm sure there are other similar cases as well.

> 2) Cleanup
> ----------
>   inet_putpeer() is not anymore inlined in inetpeer.h, as this is not called 
> in fast paths, to reduce text size. Some exports are not anymore needed 
> (inet_peer_unused_lock, inet_peer_unused_tailp) and can be declared static.
> 
> 3) No more hard limit (PEER_MAX_CLEANUP_WORK = 30)
> --------------------------------------------------
>   peer_check_expire() try to delete entries for at most one timer tick. CPUS 
> are going faster, hard limits are becoming useless... Similar thing is done in 
> net/ipv4/route.c garbage collector.

These parts are fine.
