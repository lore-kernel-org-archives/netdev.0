From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: Fix inconsistent rtnl_lock usage on
 dev_get_stats().
Date: Fri, 06 Jan 2017 13:01:34 -0500 (EST)
Message-ID: <20170106.130134.50153126758574257.davem@davemloft.net>
References: <1483676478-14228-1-git-send-email-michael.chan@broadcom.com>
        <1483723976.9712.19.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michael.chan@broadcom.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35884 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756689AbdAFSBi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 13:01:38 -0500
In-Reply-To: <1483723976.9712.19.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 06 Jan 2017 09:32:56 -0800

> This makes no sense to me.
> 
> RTNL is absolutely not needed to get device stats.
> 
> We try to not add RTNL, especially when not required.
> 
> Sure, RTNETLINK dumps currently hold RTNL, but we had various attempts
> in the past to get rid of this behavior.
> 
> If a device driver expects RTNL being locked, it is clearly a bug that
> needs a fix anyway.

This is extremely problematic when the driver has to synchronize some
piece of state between the get stats method and open/close.  It is
exactly the case we are trying to solve in tg3, and lots of drivers
end up hitting the same exact issue.

If open/close can happen asynchronously to get stats, it is very hard
to make dynamically allocated data structures or DMA buffers usable
from the stats call.

Drivers in this situation will just add a mutex specifically for this
situation if we don't consistently apply RTNL locking here.
