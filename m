From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Fix routing metrics
Date: Thu, 09 Feb 2012 13:40:10 -0500 (EST)
Message-ID: <20120209.134010.832064360325335834.davem@davemloft.net>
References: <20120208073037.GI23142@secunet.com>
	<20120208.151837.75403230557283008.davem@davemloft.net>
	<20120209124411.GJ23142@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57170 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758235Ab2BISki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 13:40:38 -0500
In-Reply-To: <20120209124411.GJ23142@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 9 Feb 2012 13:44:11 +0100

> On Wed, Feb 08, 2012 at 03:18:37PM -0500, David Miller wrote:
>> From: Steffen Klassert <steffen.klassert@secunet.com>
>> Date: Wed, 8 Feb 2012 08:30:37 +0100
>> 
>> > On Mon, Feb 06, 2012 at 03:29:16PM -0500, David Miller wrote:
>> >> 
>> >> Thinking about this, it seems overkill to check this on every metric
>> >> access.
>> >> 
>> >> You have an opportunity to validate metrics when the peer is bound to
>> >> the route.
>> >> 
>> >> This is because any change to the FIB metrics, is in turn a change
>> >> to the FIB, which therefore invalidates the entire routing cache.
>> >> 
>> >> So you can be sure that a new route cache entry will be created, and
>> >> at that creation time you can ensure that we'll respect the updated
>> >> FIB metrics if encessary.
>> > 
>> > Not sure if I get you right here, but that's what this patchset
>> > does. It invalidates the metrics on the peer by incrementing
>> > peer_genid in rt_cache_invalidate() which is invoked on every FIB
>> > change. Then, on slowpath route lookup it checks in rt_init_metrics()
>> > whether the peer_genid changed. If it changed, it exchanges the
>> > invalidated merics with new ones and copies the informations from
>> > the FIB into it.
>> 
>> If the routing cache is invalided, you'll "see" this updated inetpeer
>> because every single routing cache entry will get rebuilt.
> 
> Hm, I still don't get your point. Could you specify this please?
> 
> When a route cache entry is created and the peer_genid does not match
> the genid on the inetpeer, fresh inetpeer metrics are allocated  and
> then published. After that, the new metrics are in proper state and
> ready to use.

Right, which is exactly what you want to happen.

Checking on every metric access is therefore pointless and needless.

The peer_genid only increments when the routing cache is flushed,
therefore every subsequent access to the metrics will go through the
route cache entry creation path first, and therefore that will make
sure fresh inetpeer metrics will be allocated since the peer_genid
does not match.
