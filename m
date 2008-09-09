From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_state locking regression...
Date: Mon, 08 Sep 2008 17:25:13 -0700 (PDT)
Message-ID: <20080908.172513.162820960.davem@davemloft.net>
References: <48BE329C.2010209@iki.fi>
	<20080902.234723.163403187.davem@davemloft.net>
	<20080905115506.GA26179@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44395
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753864AbYIIAZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 20:25:19 -0400
In-Reply-To: <20080905115506.GA26179@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 5 Sep 2008 21:55:07 +1000

> ipsec: Use RCU-like construct for saved state within a walk

Ok, now that I finally understand how this works I like it.

The only comment I would make is that maybe it's a bit excessive
to trigger the GC worker every time we walk the states.

Instead you could expose the GC task's local list go:

	xfrm_state_walk_completed++;
	smp_wmb();
	if (!list_empty(&xfrm_state_gc_work_list))
		schedule_work(&xfrm_state_gc_work);

in xfrm_state_walk_done().
