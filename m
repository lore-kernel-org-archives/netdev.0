From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Fix routing metrics
Date: Tue, 21 Feb 2012 01:36:23 -0500 (EST)
Message-ID: <20120221.013623.263612018908941497.davem@davemloft.net>
References: <20120210084424.GM23142@secunet.com>
	<20120210.132557.396788563105190450.davem@davemloft.net>
	<20120221061922.GE31660@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53020 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804Ab2BUGgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 01:36:42 -0500
In-Reply-To: <20120221061922.GE31660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 21 Feb 2012 07:19:22 +0100

> On Fri, Feb 10, 2012 at 01:25:57PM -0500, David Miller wrote:
>> From: Steffen Klassert <steffen.klassert@secunet.com>
>> Date: Fri, 10 Feb 2012 09:44:25 +0100
>> 
>> > On Fri, Feb 10, 2012 at 03:12:11AM -0500, David Miller wrote:
>> >> 
>> >> So since this happens, you don't need to check the inetpeer at every
>> >> metric access.  The fact that all routing cache entries get recreated
>> >> will do it for you.
>> > 
>> > So if rt_init_metrics() is not the right place to check for genid
>> > changes, where would you suggest to do it?
>> 
>> It is the right place, and since it will happen there for every routing
>> cache entry we use after a flush, the inetpeer issues will be taken
>> care of by it.  Therefore you don't need to check anything at metrics
>> access time.
> 
> Ok, apparently I looked at the wrong place. The only checks at metrics
> access that might be superfluous are the inet_metrics_new() checks in
> ipv4_metrics() and ipv6_metrics(). If these are the checks you mean,
> I'd remove them and resend the patchset.

I'm saying you shouldn't need a metrics access callback nor the rest
of your patch at all.

Look, when routes change, the routing cache is flushed and the gen ID
is incremented.

Every single existing routing cache entry is therefore instantly
invalid, and will not be used another time.

Therefore every route usage afterwards will go through the routing
cache entry creation path.  And in this path the inetpeer and it's
metrics can be validated, out of date metrics freed and replaced with
new ones, etc.  Whatever might be necessary can all be done here.

There is no need to every have special handling at metric access time
on a valid routing cache entry, the fact that it's valid and it's gen
ID matches up, means there has been no route table changes meanwhile
and that the inetpeer metrics have been validated since the last route
table change.
