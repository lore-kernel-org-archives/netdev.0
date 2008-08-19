From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 18:50:53 +1000
Message-ID: <20080819085052.GA29038@gondor.apana.org.au>
References: <20080819080557.GA17977@gondor.apana.org.au> <20080819081713.GF4376@ff.dom.local> <20080819082355.GA28869@gondor.apana.org.au> <20080819.013205.72459707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, denys@visp.net.lb
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51501 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751455AbYHSIu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 04:50:58 -0400
Content-Disposition: inline
In-Reply-To: <20080819.013205.72459707.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 01:32:05AM -0700, David Miller wrote:
> 
> Jarek may have a point about the u32 classifier.  So we
> should think about it.
> 
> The hash tables and tp_u_common objects are shared, and
> it does non-atomic refcounting during destruction, see
> u32_destroy().

I had a look and it seems to be OK to me.  Essentially we have
two sides in all this, the read side which is the path that
transmits packets, and the write side which is the control path.

As with a qdisc_destroy, u32_destroy can only be called once all
read sides have exited so we won't be racing against that.  In
fact if we were able to race against it then holding the lock is
no good anyway because this implies the u32 object is still
referenced by a qdisc tree and as such once we release the lock
the read side can get back to a destroyed u32 object.

> However, this all might be OK because all of this management
> is performed only under the RTNL semaphore.

Right, all other writers have been excluded by RTNL so we should
be the only thread with a reference to the u32 and we can decrement
the ref count non-atomically.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
