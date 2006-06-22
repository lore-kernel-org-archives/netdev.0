From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: [PATCH 0/2][RFC] Network Event Notifier Mechanism
Date: Thu, 22 Jun 2006 15:39:19 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F15F55EE@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:41230 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S932663AbWFVWjj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 18:39:39 -0400
Content-class: urn:content-classes:message
To: hadi@cyberus.ca, "Steve Wise" <swise@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev-owner@vger.kernel.org wrote:
> On Thu, 2006-22-06 at 15:58 -0500, Steve Wise wrote:
>> On Thu, 2006-06-22 at 16:36 -0400, jamal wrote:
> 
>> I created a new notifier block in my patch for these network events.
>> I guess I thought I was using the existing infrastructure to provide
>> this notification service. (I thought my patch was lovely :)  But I
>> didn't integrate with netlink for user space notification. Mainly cuz
>> I didn't think these events should be propagated up to users unless
>> there was a need.
> 
> I think they will be useful in user space. Typically you only
> propagate them if there's a user space program subscribed to
> listening (there are hooks which will tell you if there's
> anyone listening).
> The netdevice events tend to be a lot more usable in a few
> other blocks because they are lower in the hierachy (i.e
> routing depends on ip addresses which depend on netdevices)
> within the kernel unlike in this case where you are the only
> consumer; so it does sound logical to me to do it in user
> space; however, not totally unreasonable to do it in the kernel.
> 


These services are relevant to any RDMA connection. The user-space
consumer of RDMA services is no more interested in tracking the
routing of the remote IP address than the consumer of socket
services is.


>> 
>> 
>> Another issue I see with netlink is that the event notifications
>> aren't reliable.  Especially the CONFIG_ARPD stuff because it allocs
>> an sk_buff with ATOMIC.  A lost neighbour macaddr change is perhaps
>> fatal for an RDMA connection...
>> 
> 
> This would happen in the cases where you are short on memory;
> i would suspect you will need to allocate memory in your
> driver as well to update something in the hardware as well -
> so same problem.
> You can however work around issues like these in netlink.
>

A direct notification call to the driver makes the driver responsible
for providing whatever buffering it requires to save the information.
And if there is insufficient memory available at least the driver
is aware of the failure.

Allowing a third component to fail to relay information means that
the driver can no longer be responsible for maintaining its own
consistency with kernel routing, ARP and neighbor tables.

Maintaining that consistency is a matter of correct network
behaviour, not doing status reports. obviously we cannot have
hardware looking at and interpreting these tables directly.
So a *reliable* subscription would seem to be the only option.

If the only subscribers who require reliable notifications are
kernel drivers, does it really mamke sense to make those changes
in code that also supports user space?
 

> 
> I am still unclear:
> You have destination IP address, the dstMAC of the nexthop to
> get the packet to this IP address and i suspect some srcMAC
> address you will use sending out as well as the pathMTU to
> get there correct?
> Because of the IP address it sounds to me like you are
> populating an L3 table How is this info used in hardware? Can
> you explain how an arriving packet would be used by the RDMA
> in conjunction with this info once it is in the hardware?
>

Some packets are associated with established RDMA (or iSCSI)
connections, and are processed on the RDMA (or iSCSI) device.
These packets will also pass through other packets to the
host stack for processing (non-matched Ethernet frames for
IP networks, and IPoIB tunneled frames for IB networks).

The device provides L5 services (RDMA and/or iSCSI) in addition
to L2 services (as an Ethernet device). The rest of the network
rightfully demands that the left hand knows what the right hand
is doing. So information that is provided to a host, ARP/ICMP,
should affect the behaviour of *all* connections from that host.

Do you agree that having the device subsribe to the kernel
maintained tables is a better solution than having it attempt
to guess the correct values in parallel?
 

