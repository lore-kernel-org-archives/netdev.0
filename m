From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 1/2] flow: virtualize get and entry deletion methods
Date: Thu, 25 Mar 2010 12:26:11 -0700 (PDT)
Message-ID: <20100325.122611.267401605.davem@davemloft.net>
References: <1269509091-6440-1-git-send-email-timo.teras@iki.fi>
	<1269509091-6440-2-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56830
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754300Ab0CYTZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 15:25:48 -0400
In-Reply-To: <1269509091-6440-2-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timo Teras <timo.teras@iki.fi>
Date: Thu, 25 Mar 2010 11:24:50 +0200

> This allows to validate the cached object before returning it.
> It also allows to destruct object properly, if the last reference
> was held in flow cache. This is also a prepartion for caching
> bundles in the flow cache.
> 
> In return for virtualizing the methods, we save on:
> - not having to regenerate the whole flow cache on policy removal:
>   each flow matching a killed policy gets refreshed as the getter
>   function notices it smartly.
> - we do not have to call flow_cache_flush from policy gc, since the
>   flow cache now properly deletes the object if it had any references
> 
> This also means the flow cache entry deletion does more work. If
> it's too slow now, may have to implement delayed deletion of flow
> cache entries. But this is a save because this enables immediate
> deletion of policies and bundles.
> 
> Signed-off-by: Timo Teras <timo.teras@iki.fi>

I'm concerned about the new costs being added here.

We have to now take the policy lock as a reader every time the flow
cache wants to grab a reference.  So we now have this plus the
indirect function call new overhead.

Maybe we can make the dead state check safe to do asynchronously
somehow?  I wonder if the policy layer is overdue for an RCU
conversion or similar.

Anyways, something to think about.  Otherwise I don't mind these
changes.

