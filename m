From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
 dev_deactivate() race
Date: Sun, 21 Sep 2008 00:03:01 -0700 (PDT)
Message-ID: <20080921.000301.198672963.davem@davemloft.net>
References: <20080920.223538.130375517.davem@davemloft.net>
	<20080920.225033.261544815.davem@davemloft.net>
	<20080921063821.GA8677@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, kaber@trash.net,
	alexander.h.duyck@intel.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56112
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751190AbYIUHDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2008 03:03:13 -0400
In-Reply-To: <20080921063821.GA8677@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 21 Sep 2008 15:38:21 +0900

> Going back to the case of prio, I think what we should do is to
> create a separate qdisc queue for each band.  The qdisc selection
> should be done before the packet is queued, just as we do in the
> TX hashing case.

That's a very interesting idea.

This works if you want it at the root, but what if you only wanted to
prio at a leaf?  I think that case has value too.

I tend to also disagree with another mentioned assertion.  The one
where having a shared qdisc sucks on SMP.  It doesn't.  The TX queue
lock is held much longer than the qdisc lock.

The ->hard_start_xmit() TXQ lock has to be held while:

1) DMA mapping the SKB
2) building TX descriptors
3) doing at least one PIO to the hardware

These operations, each, can be on the order of few thousands of
cycles.

Whereas a qdisc dequeue is perhaps a few hundred, maybe on the order
of a thousand, except in very elaborate classful qdisc configs.

