From: Patrick McHardy <kaber@trash.net>
Subject: Re: Multiqueue and virtualization WAS(Re: [PATCH 3/3] NET: [SCHED]
 Qdisc changes and sch_rr added for multiqueue
Date: Fri, 29 Jun 2007 15:08:32 +0200
Message-ID: <46850450.6040608@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC329031F0648@orsmsx414.amr.corp.intel.com>	 <46840AF5.4020209@trash.net>	 <20070628.212032.108743475.davem@davemloft.net>	 <1183117415.5156.61.camel@localhost>  <4684F41B.9080309@trash.net> <1183121670.5188.16.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44381 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830AbXF2NIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 09:08:45 -0400
In-Reply-To: <1183121670.5188.16.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Fri, 2007-29-06 at 13:59 +0200, Patrick McHardy wrote:
> 
> 
>>The difference to a real bridge is that the
>>all addresses are completely known in advance, so it doesn't need
>>promiscous mode for learning.
> 
> 
> You mean the per-virtual MAC addresses are known in advance, right?

Yes.

> This is fine. The bridging or otherwise (like L3 etc) is for
> interconnecting once you have the provisioning done. And you could build
> different "broadcast domains" by having multiple bridges.


Right, but the current bridging code always uses promiscous mode
and its nice to avoid that if possible. Looking at the code, it
should be easy to avoid though by disabling learning (and thus
promisous mode) and adding unicast filters for all static fdb entries.

> To go off on a slight tangent:
> I think you have to look at the two types of NICs separately 
> 1) dumb ones where you may have to use the mcast filters in hardware to
> pretend you have a unicast address per virtual device - those will be
> really hard to simulate using a separate netdevice per MAC address.
> Actually your bigger problem on those is tx MAC address selection
> because that is not built into the hardware. I still think even for
> these types something above netdevice (bridge, L3 routing, tc action
> redirect etc) will do.


Have a look at my secondary unicast address patches in case you didn't
notice them before (there's also a driver example for e1000 on netdev):

http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.23.git;a=commit;h=306890b54dcbd168cdeea64f1630d2024febb5c7

You still need to do filtering in software, but you can have the NIC
pre-filter in case it supports it, otherwise it goes to promiscous mode.

> 2) The new NICs being built for virtualization; those allow you to
> explicitly have clean separation of IO where the only thing that is
> shared between virtual devices is the wire and the bus (otherwise
> each has its own registers etc) i.e the hardware is designed with this
> in mind. In such a case, i think a separate netdevice per single MAC
> address - possibly tied to a separate CPU should work.


Agreed, that could also be useful for non-virtualized use.
