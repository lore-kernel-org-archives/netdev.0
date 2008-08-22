From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Fri, 22 Aug 2008 03:27:33 -0700 (PDT)
Message-ID: <20080822.032733.155458803.davem@davemloft.net>
References: <20080822084931.GB2645@ff.dom.local>
	<20080822.015513.194132430.davem@davemloft.net>
	<20080822100708.GA14345@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, denys@visp.net.lb
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53468
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753800AbYHVK1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 06:27:34 -0400
In-Reply-To: <20080822100708.GA14345@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 22 Aug 2008 20:07:08 +1000

> Yes the ingress hierachy has a single root, i.e., it's a tree.  But
> that has nothing to do with what I was talking about.  I'm talking
> about the list at dev->rx_queue.qdisc_sleeping->list which is
> certainly not guaranteed to be empty.

It is guarenteed to be empty.

Only root qdiscs go to rx_queue.qdisc_sleeping, and such qdiscs
will always have an empty list.

> If you look at qdisc_create you'll find that every time we create
> a non-root ingress qdisc we add it to that list (we have to,
> otherwise qdisc_lookup doesn't work at all for ingress qdiscs).

We don't allow non-root ingress qdiscs.  All ingress qdiscs
always take the device graft path, and always have a parent
of TC_H_INGRESS, and always operate on rx_queue.

> So when somebody on the TX side does a qdisc_lookup they may be
> walking the RX list without any protection.  Similarly, if somebody
> on the ingress side does qdisc_lookup they may walk the TX lists
> without protection.

Ingress data paths do not do qdisc_lookup().  There is only root
allowed for ingress and thus rx_queue's non-default qdiscs.

Add some assertions and run some test tc commands if you don't believe
me :)
