From: David Miller <davem@davemloft.net>
Subject: GRO after RPS?
Date: Sun, 25 Apr 2010 17:09:33 -0700 (PDT)
Message-ID: <20100425.170933.190068177.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41927
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753225Ab0DZAJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 20:09:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Herbert, after thinking about some ideas we've been discussing and
some suggestions from folks like Tom Herbert, I'm thinking of changing
it such that we do GRO after RPS sends the packet to a remove cpu.

The idea being that, this way, if we have a device provided ->rxhash
we can elide touching the packet headers entirely.

Initially I wanted to defer the eth_type_trans() by adding a state bit
to sk_buff, and making ->ndo_type_trans() a new netdev op.  The state
bit exists so that we can have a transition period and avoid doing
the type_trans multiple times if the driver still does it early.

So, in this way, when RPS doesn't even need to touch the packet
headers, due to a device provided skb->rxhash, we can defer the
type_trans all the way to the remote cpu.

The only thing getting in the way of this is GRO, since it wants to
parse the packet headers too for flow matching.

At first I thought this was a bad idea to defer GRO to the remote cpu,
since if we do batch things up it means we have less packets to queue
up to the remote cpu.

But upon further consideration it doesn't matter, because GRO is going
to fuddle with the packets and link them up into a list anyways.

So if the list handling is a wash, then it's a real win to defer GRO
and thus potentially all packet header touching to the remote cpu.

Also, we can add the quick ->rxhash check to the GRO flow matcher
like we discussed several times in the past.  And guess what?  Now
that RPS runs first, we'll always have a valid skb->rhash available
for this purpose since RPS will compute one in software for us :-)

So Herbert, any objections before I start hacking on this?
