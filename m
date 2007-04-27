From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Fri, 27 Apr 2007 10:58:38 -0400
Message-ID: <1177685918.4059.67.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902B96813@orsmsx414.amr.corp.intel.com>
	 <1177594079.4077.37.camel@localhost>  <4630CBF3.9030202@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	davem@davemloft.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.224]:14326 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755967AbXD0O6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 10:58:48 -0400
Received: by wx-out-0506.google.com with SMTP id h31so928173wxd
        for <netdev@vger.kernel.org>; Fri, 27 Apr 2007 07:58:44 -0700 (PDT)
In-Reply-To: <4630CBF3.9030202@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-26-04 at 17:57 +0200, Patrick McHardy wrote:

> The reason for suggesting to add a TC option was that these patches
> move (parts of) the scheduling policy into the driver since it can
> start and stop individual subqueues, which in turn cause single
> bands of prio not to be dequeued anymore. 

I see.

> To avoid surprising users
> by this it should be explicitly enabled. Another reason is that
> prio below a classful qdisc should most likely not care about
> multiqueue.

Heres the way i see it from a user perspective:
If a NIC has 3 hardware queues; if that NIC supports strict priority
(i.e the prio qdisc) which we already support, there should be no need
for the user to really explicitly enable that support. 
It should be transparent to them - because by configuring a multi queue
prio qdisc (3 bands/queues default), they are already doing multiqueues.
i.e when i say "tc qdisc add root prio bands 4" on eth0, i am already
asking explicitly for 4 strict priority queues on eth0.
This in my opinion is separate from enabling the hardware to do 4
queues - which is a separate abstraction layer (and ethtool would
do fine there).

> We need to change the qdisc layer as well so it knows about the state
> of subqueues and can dequeue individual (active) subqueues. 

The alternative approach is to change the drivers tx state
machine netif_XX to act as well on a per hardware queue level. This is
what i have in mind working with Ashwin.

> The
> alternative to adding it to prio (or a completely new qdisc) is to add
> something very similar to qdisc_restart and have it pass the subqueue
> it wishes to dequeue to ->dequeue, but that would be less flexible
> and doesn't seem to offer any advantages.
> 

Another approach is to add between the qdisc restart and driver tx
a think layer.
You pass the skb->prio and use that as a "classification key"  to select
the correct hardware ring and dont have to change any qdisc since that
layer is between the driver and qdisc.
The challenge then becomes how to throttle/unthrottle a software queue.
But you leave that brunt work to the driver.

> I wouldn't object to putting this into a completely new scheduler
> (sch_multiqueue) though since the scheduling policy might be something
> completely different than strict priority.

I think the wireless work is already in the kernel?
The way i see it is the software scheduler should match the hardware
scheduler. The majority of these hardware scheduling approaches I have
seen match precisely to prio qdisc. i.e there is no need to write a new
scheduler ( for that matter touch an existing scheduler that matches).
Others I have seen may require some work conserving schedulers that dont
have a precise match in Linux today; i think those may have to be
written from scratch.

> The wireless multiqueue scheduler is pratically identical to this one,
> modulo the wireless classifier that should be a seperate module anyway.

The wireless folks seemed to have created an extra netdev to provide the
hierachy. I think that is a sane interim approach, just a little dirty.

cheers,
jamal

