From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: AF_NETDEV - device specific sockets
Date: Mon, 02 Feb 2015 10:04:04 -0800
Message-ID: <54CFBC14.9080908@gmail.com>
References: <FC8E8D0ECC753F45808079B18C3203FE1CCA0C@G4W3293.americas.hpqcorp.net> <54CDAE61.60100@gmail.com> <FC8E8D0ECC753F45808079B18C3203FE1CCAF4@G4W3293.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	dborkman <dborkman@redhat.com>
To: "Zayats, Michael" <michael.zayats@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:61320 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753834AbbBBSEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 13:04:15 -0500
Received: by mail-ob0-f176.google.com with SMTP id wo20so9352540obc.7
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2015 10:04:14 -0800 (PST)
In-Reply-To: <FC8E8D0ECC753F45808079B18C3203FE1CCAF4@G4W3293.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/2015 09:04 PM, Zayats, Michael wrote:
> More specific example would be when NIC performs certain fast path processing,
> while punting to the CPU for a slow path.
> Slow path would be interested to know the punt reason.
>
> Another example would be if specific NIC strips S-tag in QinQ case and would like to communicate the stripped
> Tag to the client.
>

Right, maybe we need some sort of TLV scheme to pass up the relevant
info. I'm not sure we want to necessarily bury it in the driver though.
Perhaps passing auxdata in a TLV format is worth considering.

Just curious do you have NICs that are stripping or inserting more then
a single tag?

For tagging my current scheme is to strip outer tags using this
experimental Flow  API

	http://www.spinics.net/lists/netdev/msg313071.html

and then only report the inner tag to the stack. At the moment I haven't
found any use cases this is not sufficient.

> There might be many types of custom functionality, agreed between the NIC and the clients,
> which is not generic or not practical enough for inclusion in the kernel.
>
> That's why I am looking for a generic, socket like mechanism of device<->client, packet + metadata communication,
> which wouldn't require core kernel modification.

hmm the question is how do the NIC and client "agree" on the
format of the data and its meaning? If you follow the thread
above and also our af_packet direct DMA work we are struggling
with similar questions,

	http://www.spinics.net/lists/netdev/msg311862.html

I think we need some way to "describe" the meta-data or we
need to build some kernel/uapi standard that defines them.

.John

>
> Thanks,
>
> Michael
>
>
>
>
>
> -----Original Message-----
> From: John Fastabend [mailto:john.fastabend@gmail.com]
> Sent: Saturday, January 31, 2015 8:41 PM
> To: Zayats, Michael
> Cc: netdev@vger.kernel.org
> Subject: Re: AF_NETDEV - device specific sockets
>
> On 01/31/2015 08:20 PM, Zayats, Michael wrote:
>> Hi,
>>
>> I am looking for a generic mechanism that would allow network device
>> drivers to provide socket interface to user and kernel space clients.
>>
>> Such an interface might be used to provide access to important
>> sub-streams of packets, alongside with device specific packet
>> metadata, provided through msg_control fields of recv/sendmsg.
>>
>> RX Metadata might include device specific information, such as queuing
>> priorities applied, potential destination interface in case of
>> switching hardware etc.
>>
>> On the transmission, metadata might be used to indicate hardware
>> specific required optimizations, as well as any other transformation
>> or accounting required on the packet.
>>
>> AF_PACKET based mechanism doesn't allow metadata to be exchanged
>> between the client and the device driver. Extending it would require
>> extending of sk_buff and potentially additional per packet operations.
>> Generic Netlink is not intended to pass packets.
>>
>> As I am trying to validate generic applicability of such a mechanism,
>> I see that TUN driver is providing custom socket interface, in order
>> to deal with user information through msg_control. Only usable inside
>> the kernel, through custom interface.
>
>> Proposed interface
>> ------------------
>> Kernel side:
>> (struct proto *) should be added to struct net_device.
>> Device driver that is interested to support socket interface would populate the pointer.
>>
>
>> User space: After creating AF_NETDEV socket, the only successful
>> operation would be setting SO_BINDTODEVICE option. Once set, all
>> socket operations would be implemented by calling functions, that are
>> registered at struct proto on the appropriate net_device.
>>
>> What do you think?
>> Would you see a better approach?
>> Some other mechanism that already exists for such a purpose?
>
> It might help to come up with specific examples but an alternate proposal would be to use skb->priority field and then mqprio to steer the traffic to a specific queue and then bind attributes to the queue.
>
> For example the NIC offloaded QOS can be mapped on to queues and then sockets mapped to the queues.
>
> Another example would be to forward all traffic from one queue to a virtual fuction in SR-IOV use case. We don't have an interface to do this but I have been working on an API that could be used for this.
>
> In this case you don't need to modify AF_PACKET interface but configure the device correctly. If you need per-packet control you could use 'tc' or 'nftables' to do the steering.
>
> .John
>


-- 
John Fastabend         Intel Corporation
