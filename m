From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [ovs-dev] [PATCH net 0/2] vxlan: Set a large MTU on ovs-created
 vxlan devices
Date: Thu, 7 Jan 2016 01:14:38 +0100
Message-ID: <568DADEE.1050206@stressinduktion.org>
References: <1452087186-12926-1-git-send-email-david@weave.works>
 <20160106.155950.1007160228570301281.davem@davemloft.net>
 <8660z6qohn.fsf@weave.works>
 <CAEh+42iWSZOyikNydU2Bs8meqYfrKfUJLDGFJ8HzQ06k64LP0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dev@openvswitch.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jesse Gross <jesse@kernel.org>, David Wragg <david@weave.works>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:53163 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752163AbcAGAOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 19:14:43 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 22B18207D3
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 19:14:41 -0500 (EST)
In-Reply-To: <CAEh+42iWSZOyikNydU2Bs8meqYfrKfUJLDGFJ8HzQ06k64LP0g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 07.01.2016 00:57, Jesse Gross wrote:
> On Wed, Jan 6, 2016 at 3:25 PM, David Wragg <david@weave.works> wrote:
>> David Miller <davem@davemloft.net> writes:
>>>> Prior to 4.3, openvswitch vxlan vports could transmit vxlan packets of
>>>> any size, constrained only by the ability to transmit the resulting
>>>> UDP packets.  4.3 introduced vxlan netdevs corresponding to vxlan
>>>> vports.  These netdevs have an MTU, which limits the size of a packet
>>>> that can be successfully vxlan-encapsulated.  The default value for
>>>> this MTU is 1500, which is awkwardly small, and leads to a conspicuous
>>>> change in behaviour for userspace.
>>>>
>>>> These two patches set the MTU on openvswitch-crated vxlan devices to
>>>> be 65465 (the maximum IP packet size minus the vxlan-on-IPv6
>>>> overhead), effectively restoring the behaviour prior to 4.3.  In order
>>>> to accomplish this, the first patch removes the MTU constraint of 1500
>>>> for vxlan netdevs without an underlying device.
>>>
>>> Is this really the right thing to do?
>>
>> I'm certainly open to suggestions of better ways to solve the problem.
>
> One option is to simply set the MTU on the device from userspace.
>
> The reality is that the code you're modifying is compatibility code.
> Maybe we should make this change to preserve the old behavior for old
> callers (although, again, it should not be just for VXLAN). But no new
> features or tunnel types will be supported in this manner.
>
> New or updated userspace programs should work by simply creating and
> adding tunnel devices to OVS. That won't go through this path at all
> so you're going to need to find another approach in the near future in
> any case.

I don't see any other way as to make MTUs part of the flow if we want to 
have correct ip_local_error notifications. And those must also work 
across VMs, so openvswitch in quasi brouting mode would need to emit 
ICMP PtBs (hopefully with a correct source address, otherwise uRPF kills 
them before reaching the applications) or do error signaling via virtio_net.

Either the openvswitch user space can feed those information to the 
datapath or the ovs dataplane can do a lookup on the outer ip address 
while filling out the metadata_dst and caching it in the flow or we just 
keep the dst in the flow anyway. So a net_device used by ovs has no real 
mtu anymore.

Bye,
Hannes
