From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 06 Jun 2007 15:35:30 -0700 (PDT)
Message-ID: <20070606.153530.48530367.davem@davemloft.net>
References: <1181082517.4062.31.camel@localhost>
	<4666CEB7.6030804@trash.net>
	<1181168020.4064.46.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47402
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S936487AbXFFWfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 18:35:15 -0400
In-Reply-To: <1181168020.4064.46.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Wed, 06 Jun 2007 18:13:40 -0400

> From the above you can see they are simple. I am working on a couple of
> things (batching and recovering pktgen ipsec patches)- I will work on
> those patches soon after.
> 
> Iam actually not against the subqueue control - i know Peter needs it
> for certain hardware; i am just against the mucking around of the common
> case (single ring NIC) just to get that working. 

There are other reasons to do interesting things in this area,
purely for parallelization reasons.

For example, consider a chip that has N totally independant TX packet
queues going out to the same ethernet port.  You can lock and transmit
on them independantly, and the chip internally arbitrates using DRR or
whatever to blast the queues out to the physical port in some fair'ish
manner.

In that case you'd want to be able to do something like:

	struct mydev_tx_queue *q = &mydev->tx_q[smp_processor_id() % N];

or similar in the ->hard_start_xmit() driver.  But something generic
to support this kind of parallelization would be great (and necessary)
because the TX lock is unary per netdev and destroys all of the
parallelization possible with something like the above.

With the above for transmit, and having N "struct napi_struct"
instances for MSI-X directed RX queues, we'll have no problem keeping
a 10gbit (or even faster) port completely full with lots of cpu to
spare on multi-core boxes.

However, I have to disagree with your analysis of the multi-qdisc
situation, and I tend to agree with Patrick.

If you only have one qdisc to indicate status on, when is the queue
full?  That is the core issue.  Indicating full status when any of
the hardware queues are full is broken, because we should never
block out queuing of higher priority packets just because the
low priority queue can't take any more frames, _and_ vice versa.

I really want to believe your proofs but they are something out of
a fairy tale :-)

> The only way PHL will ever shutdown the path to the hardware is when
> there are sufficient PHL packets.
> Corrollary,
> The only way PSL will ever shutdown the path to the hardware is when
> there are _NO_ PSH packets.

The problem with this line of thinking is that it ignores the fact
that it is bad to not queue to the device when there is space
available, _even_ for lower priority packets.

The more you keep all available TX queues full, the less likely
delays in CPU processing will lead to a device with nothing to
do.
