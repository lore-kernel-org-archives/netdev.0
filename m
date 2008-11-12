From: David Miller <davem@davemloft.net>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Wed, 12 Nov 2008 03:52:40 -0800 (PST)
Message-ID: <20081112.035240.226243372.davem@davemloft.net>
References: <1226482593.6834.43.camel@localhost.localdomain>
	<20081112.014923.68124784.davem@davemloft.net>
	<1226487710.6834.53.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36398
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751698AbYKLLwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 06:52:40 -0500
In-Reply-To: <1226487710.6834.53.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <jdb@comx.dk>
Date: Wed, 12 Nov 2008 12:01:50 +0100

> On Wed, 2008-11-12 at 01:49 -0800, David Miller wrote:
> > Oddly, you tried without MSI enabled (do I remember right ?) and that
> > still failed, so it doesn't seem like it could be a MSI specific
> > problem.
> 
> Just to be absolutly sure that MSI got disabled, I have compiled a
> kernel without SMP and without MSI support.

Thanks for the additional checks.

niu 0000:0b:00.0: niu: eth2: TX_RING[ 4] CHANNEL 4 LDN 36
niu 0000:0b:00.0: niu: eth2: TX_RING[ 4] parent->lgd_map[ldn] 0
niu 0000:0b:00.0: niu: eth2: TX_RING[ 4] Num pending TX SKBs: 237
niu 0000:0b:00.0: niu: eth2: TX_RING[ 4] TX_CS sw[00c000bf00000000] hw[00ed00bf00000000]

So what's supposed to happen is that, in the TX ring, we periodically
set the MARK bit in the TX descriptors.

MARK bits are what trigger TX ring interrupts.

The TX ring is full (237 ~= TX_RING_SIZE [256] - MAX_SKB_FRAGS [18]).

What's supposed to happen is that when a MARK bit is seen, the completion
of sending that packet causes the TX_CS_MK bit to be set (or, alternatively,
the TX_CS_MMK bit if TX_CS_MK is already set) and then the interrupt
is signaled.

Reading the TX_CS register clears the TX_CS_MK bit.

But in all of these traces the TX_CS_MK bit is not set, but we DID
sample the TX_CS register which means we did get an interrupt signaled
for that TX ring.

niu_tx_work() never runs because it doesn't see the TX_CS_MK bit set.
I don't see any error bits set and there are no TX error dumps in your
logs.

Ok, Jesper, please try two things for me, leave the debugging patch
in there for all the tests:

1) Retrigger the problem (with or without MSI, doesn't matter) but
   add back in that test I asked you to try last week.  The one
   where the "if (++rp->mark_counter == rp->mark_freq)" condition
   test in niu_start_xmit() is commented out, so that the
   "mrk |= TX_DESC_MARK;" statement always runs.

   Get me the log dump produced by that scenerio.

2) Next, simply comment out the:

	if (unlikely(!(cs & (TX_CS_MK | TX_CS_MMK))))
		goto out;

   lines in niu_tx_work().

Let's see what new info we can get out of this.

Thanks.

