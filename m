From: Jesse Gross <jesse@kernel.org>
Subject: Re: [ovs-dev] [PATCH net 0/2] vxlan: Set a large MTU on ovs-created
 vxlan devices
Date: Wed, 6 Jan 2016 16:46:30 -0800
Message-ID: <CAEh+42h_dH5-AYBN+L=+LMfNLXhSfs-AwWh_aZ_oLfZ1NV48Zg@mail.gmail.com>
References: <1452087186-12926-1-git-send-email-david@weave.works>
 <20160106.155950.1007160228570301281.davem@davemloft.net> <8660z6qohn.fsf@weave.works>
 <CAEh+42iWSZOyikNydU2Bs8meqYfrKfUJLDGFJ8HzQ06k64LP0g@mail.gmail.com> <568DADEE.1050206@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Wragg <david@weave.works>,
	David Miller <davem@davemloft.net>, dev@openvswitch.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:47849 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752111AbcAGAqs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 19:46:48 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 51494201C0
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2016 00:46:47 +0000 (UTC)
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D351320138
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2016 00:46:45 +0000 (UTC)
Received: by mail-qg0-f45.google.com with SMTP id e32so226652830qgf.3
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 16:46:45 -0800 (PST)
In-Reply-To: <568DADEE.1050206@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 6, 2016 at 4:14 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hi,
>
>
> On 07.01.2016 00:57, Jesse Gross wrote:
>>
>> On Wed, Jan 6, 2016 at 3:25 PM, David Wragg <david@weave.works> wrote:
>>>
>>> David Miller <davem@davemloft.net> writes:
>>>>>
>>>>> Prior to 4.3, openvswitch vxlan vports could transmit vxlan packets of
>>>>> any size, constrained only by the ability to transmit the resulting
>>>>> UDP packets.  4.3 introduced vxlan netdevs corresponding to vxlan
>>>>> vports.  These netdevs have an MTU, which limits the size of a packet
>>>>> that can be successfully vxlan-encapsulated.  The default value for
>>>>> this MTU is 1500, which is awkwardly small, and leads to a conspicuous
>>>>> change in behaviour for userspace.
>>>>>
>>>>> These two patches set the MTU on openvswitch-crated vxlan devices to
>>>>> be 65465 (the maximum IP packet size minus the vxlan-on-IPv6
>>>>> overhead), effectively restoring the behaviour prior to 4.3.  In order
>>>>> to accomplish this, the first patch removes the MTU constraint of 1500
>>>>> for vxlan netdevs without an underlying device.
>>>>
>>>>
>>>> Is this really the right thing to do?
>>>
>>>
>>> I'm certainly open to suggestions of better ways to solve the problem.
>>
>>
>> One option is to simply set the MTU on the device from userspace.
>>
>> The reality is that the code you're modifying is compatibility code.
>> Maybe we should make this change to preserve the old behavior for old
>> callers (although, again, it should not be just for VXLAN). But no new
>> features or tunnel types will be supported in this manner.
>>
>> New or updated userspace programs should work by simply creating and
>> adding tunnel devices to OVS. That won't go through this path at all
>> so you're going to need to find another approach in the near future in
>> any case.
>
>
> I don't see any other way as to make MTUs part of the flow if we want to
> have correct ip_local_error notifications. And those must also work across
> VMs, so openvswitch in quasi brouting mode would need to emit ICMP PtBs
> (hopefully with a correct source address, otherwise uRPF kills them before
> reaching the applications) or do error signaling via virtio_net.

I actually implemented this a long time ago and then there was some
additional discussion on this about a year ago. I agree it's the right
solution overall but it's not entirely clearly to me how to get the
details correct.

> Either the openvswitch user space can feed those information to the datapath
> or the ovs dataplane can do a lookup on the outer ip address while filling
> out the metadata_dst and caching it in the flow or we just keep the dst in
> the flow anyway. So a net_device used by ovs has no real mtu anymore.

I agree that the concept of MTU is much more complicated than a single
number on a device, we just have to find the right way to model it.
