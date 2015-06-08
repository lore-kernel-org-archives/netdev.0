From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC net-next 3/3] rcv path changes for vrf traffic
Date: Mon, 08 Jun 2015 22:33:38 +0200
Message-ID: <1433795618.1990780.290127633.2EC447D9@webmail.messagingengine.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com>
 <87eae7a7a03708bda5560a5ea43b0fcac705c80d.1433561681.git.shm@cumulusnetworks.com>
 <1433793517.4616.4.camel@stressinduktion.org>
 <CAJmoNQG7vfuQAnZKN4+=NO7VQywC1=eXnumj2yG14KK5HS+TZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Ahern <dsahern@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jon Toppins <jtoppins@cumulusnetworks.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Shrijeet Mukherjee <shm@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:37691 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752957AbbFHUdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 16:33:38 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 5042320E01
	for <netdev@vger.kernel.org>; Mon,  8 Jun 2015 16:33:38 -0400 (EDT)
In-Reply-To: <CAJmoNQG7vfuQAnZKN4+=NO7VQywC1=eXnumj2yG14KK5HS+TZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 8, 2015, at 22:22, Shrijeet Mukherjee wrote:
> On Mon, Jun 8, 2015 at 12:58 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > Hi Shrijeet,
> >
> > From an architectural level I think the output path looks good. For the
> > input path I would also to propose my (I think) more flexible solution:
> >
> > For rx layer I want to also propose my try:
> >
> > [PATCH net-next RFC] net: ipv4: arp: strong end system model semantics by per-interface local table override
> >
> > By allowing to direct routing table lookups to a specific table based
> > on the incoming interface for IPv4 and ARP, we start to behave like a
> > strong end host system without tweaking arp_* sysctl settings.
> >
> > The main motivation behind this patch was input and forwarding support
> > in a VRF like model. Maybe it also helps for hardware offloading by
> > allowing reducing rule complexity.
> >
> > An example:
> >
> > $ ip rule flush
> > $ ip rule del
> > $ ip rule del
> > $ ip rule add inherit-table
> > 0:      from all inherit-table
> >
> > This by default still uses RT_TABLE_LOCAL until we set up per interface
> > route tables:
> >
> > $ ip link set dev enp0s25 ipv4-rt-table-id 100
> > $ ip -d link ls dev enp0s25
> > 2: enp0s25: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
> >     link/ether e4:7f:b2:1b:4c:61 brd ff:ff:ff:ff:ff:ff promiscuity 0 ipv4-rt-table-id 100 addrgenmode none
> >
> > This let's incoming and arp requests use routing table 100. The system
> > will stop responding to arp requests as we don't have any entries in
> > this routing table.
> 
> 
> I like this model in general, as it addresses the issue that I have
> not addressed around connected routes.
> 
> This would force local and directly connected host routes to be learnt
> into the correct table.
> 
> It does bring the question up then.
> 
> 1. The driver already knows the vrf device to table map
> 2. If the device also knows the final device to table map
> 
> then do we need to use fib_rules and just lookup the table directly.
> It does make the configuration a little longer since each component
> device now needs configuration when you add/del a member from a vrf.

This model is usable on its own, especially if one does not need routing
daemons
or user space software dealing with VRFs and sending out packets.

> If people generally agree and we want to skip the fib_rule lookup,
> then I can make it such that enslaving already takes the dev-table id
> as well, and then the process of enslaving in the nominal VRF case
> becomes
> 
> ip link add vrf-dev type vrf table foo ipv4-rt-table-id bar
> ip link set eth2 master vrf-dev

I think this would be great.

Last time I looked into the patches it was not yet clear if we can do
that
without holding strong references to the other interfaces. Hopefully
this can
be done by just passing down the table ids to the slaves during
initializing
and teardown of the master vrf interface.

Bye,
Hannes
