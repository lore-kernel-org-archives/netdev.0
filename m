From: Glen Turner <gdt@gdt.id.au>
Subject: Re: tcp wifi upload performance and lots of ACKs
Date: Tue, 5 Jun 2012 23:58:02 +0930
Message-ID: <DF88DB84-3F8C-4410-8101-3066F134C560@gdt.id.au>
References: <4FCCFE76.3060304@candelatech.com>
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:57504 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750952Ab2FEOnS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 10:43:18 -0400
In-Reply-To: <4FCCFE76.3060304@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 05/06/2012, at 3:59 AM, Ben Greear wrote:
> 
> Anyone know of any tuning parameters that would let the receiving socket wait a
> bit longer and send more ACK data in fewer packets?

It's perhaps better to think of Acks as offering an opportunity for the transmitting TCP algorithm to sample the congestion of the path. That's particularly important in Slow Start (when the transmitting algorithm is trying to send data exponentially faster) and both traditional TCP and Linux's CUBIC+Hystart will not ramp up transmission as quickly as they otherwise would when starved of samples.

Of course you've got to weigh slower ramp up in transmission rate against the loss in throughput due to the  turn-around time on the half-duplex wireless media. But I don't see the proposed patch doing any weighing of considerations at all, but punting that to user space which has even less information about the condition of TCP (particularly the receiver's guess as to the slow-start/congestion-avoidance mode of the transmitter) and less information about the attributes of the media (particularly the turn-around time of half-duplex media on the path) to make a decision with.

There's a nice summary of the tradeoffs of delayed Acks in RFC2525 section 2.13, although the discussion is dated (pre-ABC, pre-HyStart).

Note the firm requirement in RFC2581 section 4.2 that an Ack be sent within 500ms. There are implementations in the field which have delayed Acks out to 2s, these are  notoriously painful and many modern algorithms drop back into a low performance mode when facing those receivers.

- Glen