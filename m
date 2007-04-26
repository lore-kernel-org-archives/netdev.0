From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Thu, 26 Apr 2007 17:57:39 +0200
Message-ID: <4630CBF3.9030202@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32902B96813@orsmsx414.amr.corp.intel.com> <1177594079.4077.37.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	davem@davemloft.net
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59896 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754829AbXDZP6u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 11:58:50 -0400
In-Reply-To: <1177594079.4077.37.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2007-25-04 at 10:45 -0700, Waskiewicz Jr, Peter P wrote:
> 
>>The previous version of my multiqueue patches I sent for consideration
>>had feedback from Patrick McHardy asking that the user be able to
>>configure the PRIO qdisc to run with multiqueue support or not.  That is
>>why TC needed a modification, since I agreed with Patrick that this
>>would be a useful option.
> 
> 
> Patrick is a smart guy and I am almost sure he gave you that advice
> based on how your kernel patches work. Since i havent looked at your
> patches, I cant swear to that as a fact - hence the "almost"


The reason for suggesting to add a TC option was that these patches
move (parts of) the scheduling policy into the driver since it can
start and stop individual subqueues, which in turn cause single
bands of prio not to be dequeued anymore. To avoid surprising users
by this it should be explicitly enabled. Another reason is that
prio below a classful qdisc should most likely not care about
multiqueue.

>>All the versions of multiqueue network device support I've sent for
>>consideration had PRIO modified to support multiqueue devices, since it
>>lends itself well for the model of multiple, independent flows.
> 
> 
> So it seems your approach is to make changes to every qdisc so you can
> support device-multiq, no? This is what i suspected and was questioning
> earlier, not the fact you had it in tc (which is a consequence).
> 
> My view is:
> - the burden of the changes should be on the driver. A thin layer
> between the qdisc and driver hw tx should help hide those changes from
> the qdiscs; i.e i dont see why the kernel side qdisc needs to change.
> The rest you leave to the user; if the user configures HTB for a
> hardware that does multiq which is WRR, then that is their problem.


We need to change the qdisc layer as well so it knows about the state
of subqueues and can dequeue individual (active) subqueues. The
alternative to adding it to prio (or a completely new qdisc) is to add
something very similar to qdisc_restart and have it pass the subqueue
it wishes to dequeue to ->dequeue, but that would be less flexible
and doesn't seem to offer any advantages.

I wouldn't object to putting this into a completely new scheduler
(sch_multiqueue) though since the scheduling policy might be something
completely different than strict priority.

> The driver should be configurable to be X num of queues via probably
> ethtool. It should default to single ring to maintain old behavior.


That would probably make sense in either case.

> Ok, i see; none of those other intel people put you through the hazing
> yet? ;-> This is a netdev matter - so i have taken off lkml
> 
> I will try to talk to the other gent to see if we can join into this
> effort instead of a parallel one; the wireless cards have similar needs.
> I plan to spend time looking at your approach (sorry, my brain likes to
> work that way; otherwise i would have looked at it by now).


The wireless multiqueue scheduler is pratically identical to this one,
modulo the wireless classifier that should be a seperate module anyway.
