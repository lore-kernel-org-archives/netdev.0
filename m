From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Fri, 06 Feb 2015 14:50:54 -0600
Message-ID: <87k2zubw7l.fsf@x220.int.ebiederm.org>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	roopa <roopa@cumulusnetworks.com>, hannes@stressinduktion.org,
	Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Vipin Kumar <vipin@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:43575 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756693AbbBFUyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 15:54:11 -0500
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com> (David
	Ahern's message of "Wed, 4 Feb 2015 18:34:01 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David looking at your patches and reading through your code I think I
understand what you are proposing, let me see if I can sum it up.

Semantics:
   - The same as a network namespace.
   - Addition of a VRF-ANY context
   - No per VRF settings
   - No creation or removal operation.

Implementation:
   - Add a VRF-id to every affected data structure.

This implies that you see the current implementation of network
namespaces to be space inefficient, and that you think you can remove
this inefficiency by simply removing the settings and the associated
proc files. 

Given that you have chosen to keep the same semantics as network
namespaces for everything except for settings this raises the questions:
- Are the settings and their associated proc files what actually cause
  the size cost you see in network namespaces?
- Can we instead of reimplementing network namespaces instead optimize
  the current implementation?

We need measurements to answer either of those questions and I think
before proceeding we need to answer those questions.


Beyond that I want to point out that in general a data structure that
has a tag on every member is going to have a larger memory foot print
per entry, contain more entries, and by virtue of both of those be less
memory efficient and less time efficient to use.   So it is not clear
that a implementation that tags everything with a vrf-id will actually
be lighter weight.

Also there is a concern that placing tags in every data structure may be
significantly more error prone to implement (as it is more more thing to
keep trace of), and that can impact the maintainability and the
correctness of the code for everyone.


The standard that was applied to the network namespace was that
it did not have any measurable performance impact when enabled.  The
measurments taken at the time did not show a slow down when a 1Gig
interface was place in a network namespace.  Compared to running an
unpatched kernel.

I suspect your extra layer of indirection to get to struct net in
addition to touching struct skb will give you a noticable performance
impact.


I have another concern.  I don't think it is wise to have a data
structure modified two different ways to deal with network namespaces
and vrfs.  For maintainability and our own sanity we should pick which
version that we judge to be the most efficient implementation and go
with it.



The architecture I imagine for using network namespaces as vrfs for
devices that perform layer 2 bridging and layer 3 routing.

port1 port2 port3 port4 port5 port6 port7 port8 port9 port10
  |     |     |     |     |     |     |     |     |     |
  +-----+-----+-----+-----+-----+-----+-----+-----+-----+
 /                   Link Aggregation                    \
+                                                         +
|                        Bridging                         |
+----------------------------+----------------------------+
                             |
                          cpu port
                             |
       +---------------------+---------------------+
      /     +---------------/ \---------------+     \
     /     /     +---------/   \---------+     \     \
    /     /     /     +---/     \---+     \     \     \
   /     /     /     /    |     |    \     \     \     \
  |     |     |     |     |     |     |     |     |     |
vlan1 vlan2 vlan3 vlan4 vlan5 vlan6 vlan7 vlan8 vlan9 vlan10
  |     |     |     |     |     |     |     |     |     |   
+-+-----+-----+-----+-----+-+ +-+-----+-----+-----+-----+-+ 
|    network namespace 1    | |    network namespace2     |
+---------------------------+ +---------------------------+

Traffic to and from the rest of the world comes through the
external ports.  

The traffic is then processed at layer two including link
aggregation, bridging and classifying which vlan the traffic
belongs in.

If the traffic needs to be routed it then comes up to the cpu port.
The cpu port looks at the tags on the traffic and places it into
the appropriate vlan device.

>From the various vlans the traffic is then routed according
to the routing table of whichever network namespace the vlan
device is in.

There are stateless offloads to this in modern hardware but this is a
reasonable model how all of this works semantically.

As such the vlan devices can be moved between network namespaces without
affecting any layer two monitoring or work that happens on the lower
level devices.  The practical restriction is that L2 and L3 need to be
handled on different network devices.

This split of network devices ensures that L2 code that works today
should not need any changes or in any way be concerned about network
namespaces or that the parent devices are in.

Eric












 
