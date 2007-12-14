From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][XFRM] Fix potential race vs xfrm_state(only)_find and
 xfrm_hash_resize.
Date: Fri, 14 Dec 2007 11:39:51 -0800 (PST)
Message-ID: <20071214.113951.114866674.davem@davemloft.net>
References: <47610FCE.2000100@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43629
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756590AbXLNTkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 14:40:09 -0500
In-Reply-To: <47610FCE.2000100@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 13 Dec 2007 13:56:14 +0300

> The _find calls calculate the hash value using the 
> xfrm_state_hmask, without the xfrm_state_lock. But the 
> value of this mask can change in the _resize call under
> the state_lock, so we risk to fail in finding the desired 
> entry in hash.
> 
> I think, that the hash value is better to calculate
> under the state lock.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Thanks for the bug fix.

I know why I coded it this way, I wanted to give GCC more
room to schedule the loads away from the uses in the hash
calculation.

Once you cram it after the spin lock acquire, it can't load unrelated
values earlier to soften the load/use cost on cache misses.

Of course it's invalid because the hash mask can change as you
noticed.

I wish there was a way to conditionally clobber memory, then we could
tell GCC exactly what memory objects are protected by the lock and
thus help in situations like this so much.
