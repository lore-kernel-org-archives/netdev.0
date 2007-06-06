From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 06 Jun 2007 19:32:46 -0400
Message-ID: <1181172766.4064.83.camel@localhost>
References: <1181082517.4062.31.camel@localhost>
	 <4666CEB7.6030804@trash.net> <1181168020.4064.46.camel@localhost>
	 <20070606.153530.48530367.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.181]:35824 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472AbXFFXct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 19:32:49 -0400
Received: by py-out-1112.google.com with SMTP id a29so561193pyi
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2007 16:32:49 -0700 (PDT)
In-Reply-To: <20070606.153530.48530367.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-06-06 at 15:35 -0700, David Miller wrote:
> From: jamal <hadi@cyberus.ca>
> Date: Wed, 06 Jun 2007 18:13:40 -0400

> There are other reasons to do interesting things in this area,
> purely for parallelization reasons.
> 
> For example, consider a chip that has N totally independant TX packet
> queues going out to the same ethernet port.  You can lock and transmit
> on them independantly, and the chip internally arbitrates using DRR or
> whatever to blast the queues out to the physical port in some fair'ish
> manner.
> 
> In that case you'd want to be able to do something like:
> 
> 	struct mydev_tx_queue *q = &mydev->tx_q[smp_processor_id() % N];
> 
> or similar in the ->hard_start_xmit() driver.  But something generic
> to support this kind of parallelization would be great (and necessary)
> because the TX lock is unary per netdev and destroys all of the
> parallelization possible with something like the above.
> 

I cant think of any egress scheduler that will benefit from that
approach. The scheduler is the decider of which packet goes out next
on the wire.

> With the above for transmit, and having N "struct napi_struct"
> instances for MSI-X directed RX queues, we'll have no problem keeping
> a 10gbit (or even faster) port completely full with lots of cpu to
> spare on multi-core boxes.
> 

RX queues - yes, I can see;  TX queues, it doesnt make sense to put
different rings on different CPUs.

> However, I have to disagree with your analysis of the multi-qdisc
> situation, and I tend to agree with Patrick.
> If you only have one qdisc to indicate status on, when is the queue
> full?  That is the core issue. 

I just described why it is not an issue. If you make the assumption it
is an issue, then it becomes one. 


>  Indicating full status when any of
> the hardware queues are full is broken, because we should never
> block out queuing of higher priority packets just because the
> low priority queue can't take any more frames, _and_ vice versa.

Dave, you didnt read anything i said ;-> The situation you describe is
impossible. low prio will never block high prio.

> I really want to believe your proofs but they are something out of
> a fairy tale :-)

They are a lot real than it seems. Please read again what i typed in ;->
And i will produce patches since this seems to be complex to explain.

> > The only way PHL will ever shutdown the path to the hardware is when
> > there are sufficient PHL packets.
> > Corrollary,
> > The only way PSL will ever shutdown the path to the hardware is when
> > there are _NO_ PSH packets.
> 
> The problem with this line of thinking is that it ignores the fact
> that it is bad to not queue to the device when there is space
> available, _even_ for lower priority packets.

So use a different scheduler. Dont use strict prio. Strict prio will
guarantee starvation of low prio packets as long as there are high prio
packets. Thats the intent.

> The more you keep all available TX queues full, the less likely
> delays in CPU processing will lead to a device with nothing to
> do.

It is design intent - thats how the specific scheduler works. 

cheers,
jamal

