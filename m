From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][NET_SCHED] explict hold dev tx lock
Date: Mon, 17 Sep 2007 19:01:33 -0700 (PDT)
Message-ID: <20070917.190133.79431533.davem@davemloft.net>
References: <1189959274.4241.30.camel@localhost>
	<20070916.123158.92582301.davem@davemloft.net>
	<1189975284.4230.14.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net, dada1@cosmosbay.com, johnpol@2ka.mipt.ru
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35407
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752616AbXIRCBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 22:01:34 -0400
In-Reply-To: <1189975284.4230.14.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Sun, 16 Sep 2007 16:41:24 -0400

> Ok, maybe i am thinking too hard with that patch, so help me out:->
> When i looked at that code path as it is today: i felt the softirq could
> be interupted on the same CPU it is running on while it already grabbed
> that tx lock (if the trylock succeeds) and that the hardirq code when
> attempting to grab the lock would result in a deadlock.

Hardirq should never try to grab the netif_tx_lock(), it is
only for base and softirq context.

Any hardirq context code taking that lock needs to be fixed.
We could assert this if we don't already.

It's the only way that it works that we can invoke ->hard_start_xmit()
with interrupts fully enabled.

I notice that your patch bypasses the LLTX logic (I think) and this
isn't kosher, it might introduce deadlocks or similar as when we
are doing LLTX the driver determines the locking and IRQ context
semantics.
