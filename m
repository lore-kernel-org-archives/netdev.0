From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net: skb_orphan on dev_hard_start_xmit
Date: Mon, 17 Aug 2009 18:47:12 -0700 (PDT)
Message-ID: <20090817.184712.180559154.davem@davemloft.net>
References: <20090704090910.GA2185@gondor.apana.org.au>
	<20090705032658.GA7430@gondor.apana.org.au>
	<20090705033408.GB7430@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, patrick.ohly@intel.com,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	divy@chelsio.com, rolandd@cisco.com, xemul@openvz.org,
	dcbw@redhat.com, libertas-dev@lists.infradead.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56493
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758582AbZHRBrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 21:47:01 -0400
In-Reply-To: <20090705033408.GB7430@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 5 Jul 2009 11:34:08 +0800

> Here's an even crazier idea that doesn't use dummy descriptors.
> 
> xmit(skb)
> 
> 	if (TX queue contains no interrupting descriptor &&
> 	    qdisc is empty)
> 		mark TX descriptor as interrupting
> 
> 	if (TX queue now contains an interrupting descriptor &&
> 	    qdisc len < 2)
> 		stop queue
> 
> 	if (TX ring full)
> 		stop queue
> 
> clean()
> 
>  	do work
> 	wake queue as per usual

I'm pretty sure that for normal TCP and UDP workloads, this is just
going to set the interrupt bit on the first packet that gets into the
queue, and then not in the rest.

TCP just loops over packets in the send queue, and at initial state
the qdisc will be empty.

It's very hard to get this to work as well as if we had a real
queue empty interrupt status event.

Even if you get upstream status from the protocols saying "there's
more packets coming" via some flag in the SKB, that only says what one
client feeding the TX ring is about to do.

It says nothing about other threads of control which are about to start
feeding packets to the same device.
