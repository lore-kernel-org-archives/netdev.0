From: David Miller <davem@davemloft.net>
Subject: Re: qdisc_enqueue, NET_XMIT_SUCCESS and kfree_skb
Date: Thu, 07 Aug 2008 03:10:58 -0700 (PDT)
Message-ID: <20080807.031058.193703340.davem@davemloft.net>
References: <20080806.202636.246995904.davem@davemloft.net>
	<20080806.220911.91192536.davem@davemloft.net>
	<20080807100910.GA12391@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jussi.kivilinna@mbnet.fi, kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37344
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757946AbYHGNPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 09:15:04 -0400
In-Reply-To: <20080807100910.GA12391@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 7 Aug 2008 10:09:10 +0000

> On Wed, Aug 06, 2008 at 10:09:11PM -0700, David Miller wrote:
> > From: David Miller <davem@davemloft.net>
> > Date: Wed, 06 Aug 2008 20:26:36 -0700 (PDT)
> > 
> > > 
> > > I still haven't seen anyone suggest creating a __NET_XMIT_KFREE_SKB to
> > > fix this most rediculious problem.
> > > 
> > > I'm still waiting...
> > 
> > Here is what it might look like.  I haven't tried to boot this,
> > but the only non-trivial case was SFQ's congestion drop code.
> 
> After some checking it looks mostly OK to me, but one thing: in
> sch_gred gred_drop() calls qdisc_drop(), so now it needs kfree_skb().
> BTW, maybe it would be nicer to add __qdisc_drop() for these new
> things?

qdisc_drop() sets the new __NET_XMIT_KFREE bit, but sch_gred wants to
return NET_XMIT_CN, so I OR'd in the __NET_XMIT_KFREE bit there.

> There is also some doubt about differences between ->enqueue() and
> ->requeue() wrt. kfree_skb() and returning codes: maybe it would be
> better (for uniformity) to add similar changes to requeues (and
> dev_requeue_skb()) as well?

I did not annotate ->requeue() nor remove kfree_skb() calls there
and this was intentional.

The lifetime issue only exists in the ->enqueue() path.

In the long term we could add a wrapper around root level ->requeue()
and do the bit handling just like ->enqueue(), sure.

> I don't know if it's worth to mention, but now, if somebody really
> uses this sch_blackhole under some upper qdiscs the stats will change.

That might even be useful.

As it stands it was borderline buggy.
