From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 01:48:38 -0700 (PDT)
Message-ID: <20080819.014838.69433564.davem@davemloft.net>
References: <20080819082355.GA28869@gondor.apana.org.au>
	<20080819.013205.72459707.davem@davemloft.net>
	<20080819084147.GH4376@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	denys@visp.net.lb
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36007
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752599AbYHSIsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 04:48:38 -0400
In-Reply-To: <20080819084147.GH4376@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 19 Aug 2008 08:41:48 +0000

> On Tue, Aug 19, 2008 at 01:32:05AM -0700, David Miller wrote:
> > Jarek may have a point about the u32 classifier.  So we
> > should think about it.
> > 
> > The hash tables and tp_u_common objects are shared, and
> > it does non-atomic refcounting during destruction, see
> > u32_destroy().
> > 
> > However, this all might be OK because all of this management
> > is performed only under the RTNL semaphore.
> 
> Sure, this all should be write protected. I'm concerned only about
> the read side here.

If reference count hits zero, nobody can reference the object.
Reference counts only change under RTNL, which is my point.

The old qdisc object is taken away from global visibility inside of
the cops->graft() call done by qdisc_graft().  This handler already
must do whatever locking is necessary while removing the qdisc from
visibility from the packet path.

And by virtue of that, the old qdisc and anything it references will
no longer be visible to the packet processing path after cops->graft()
returns.
