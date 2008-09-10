From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_state locking regression...
Date: Tue, 09 Sep 2008 21:52:13 -0700 (PDT)
Message-ID: <20080909.215213.231335592.davem@davemloft.net>
References: <20080910042247.GA2544@gondor.apana.org.au>
	<20080909.212426.193696271.davem@davemloft.net>
	<20080909.214829.193700357.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39454
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750824AbYIJEwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 00:52:19 -0400
In-Reply-To: <20080909.214829.193700357.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 09 Sep 2008 21:48:29 -0700 (PDT)

> The list iteration is:
> 
> 	list_for_each_entry_safe(x, tmp, &xfrm_state_gc_leftovers, gclist) {
> 		if ((long)(x->lastused - completed) > 0)
> 			break;
> 		xfrm_state_gc_destroy(x);
> 	}
> 
> And xfrm_state_gc_destroy() doesn't do a list_del(&x->gclist) or similar.

I'm now testing the following fix:

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index aaafcee..abbe270 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -423,6 +423,7 @@ static void xfrm_state_gc_task(struct work_struct *data)
 	list_for_each_entry_safe(x, tmp, &xfrm_state_gc_leftovers, gclist) {
 		if ((long)(x->lastused - completed) > 0)
 			break;
+		list_del(&x->gclist);
 		xfrm_state_gc_destroy(x);
 	}
 
