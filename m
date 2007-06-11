From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 13:58:07 +0200
Message-ID: <466D38CF.9060709@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>	 <1181082517.4062.31.camel@localhost>  <4666CEB7.6030804@trash.net> <1181168020.4064.46.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40749 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233AbXFKMAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 08:00:34 -0400
In-Reply-To: <1181168020.4064.46.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2007-06-06 at 17:11 +0200, Patrick McHardy wrote:
> 
> 
>>[...]
> The problem is the premise is _innacurate_.
> Since you havent followed the discussion, i will try to be brief (which
> is hard).
> If you want verbosity it is in my previous emails:
> 
> Consider a simple example of strict prio qdisc which is mirror
> configuration of a specific hardware. 
> Then for sake of discussion, assume two prio queues in the qdisc - PSL
> and PSH and two hardware queues/rings in a NIC which does strict prio
> with queues PHL and PHH.
> The mapping is as follows:
> PSL --- maps to --- PHL
> PSH --- maps to --- PHH
> 
> Assume the PxH has a higher prio than PxL.
> Strict prio will always favor H over L.
> 
> Two scenarios:
> a) a lot of packets for PSL arriving on the stack.
> They only get sent from PSL -> PHL if and only if there are no
> packets from PSH->PHH.
> b)a lot of packets for PSH arriving from the stack.
> They will always be favored over PSL in sending to the hardware.
> 
>>From the above:
> The only way PHL will ever shutdown the path to the hardware is when
> there are sufficient PHL packets.
> Corrollary,
> The only way PSL will ever shutdown the path to the hardware is when
> there are _NO_ PSH packets.


Thats not true. Assume PSL has lots of packets, PSH is empty. We
fill the PHL queue until their is no room left, so the driver
has to stop the queue. Now some PSH packets arrive, but the queue
is stopped, no packets will be sent. Now, you can argue that as
soon as the first PHL packet is sent there is room for more and
the queue will be activated again and we'll take PSH packets,
so it doesn't matter because we can't send two packets at once
anyway. Fine. Take three HW queues, prio 0-2. The prio 2 queue
is entirely full, prio 1 has some packets queued and prio 0 is
empty. Now, because prio 2 is completely full, the driver has to
stop the queue. Before it can start it again it has to send all
prio 1 packets and then at least one packet of prio 2. Until
this happens, no packets can be queued to prio 0.

