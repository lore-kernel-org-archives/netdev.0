From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: AF_NETDEV - device specific sockets
Date: Sat, 31 Jan 2015 20:41:05 -0800
Message-ID: <54CDAE61.60100@gmail.com>
References: <FC8E8D0ECC753F45808079B18C3203FE1CCA0C@G4W3293.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Zayats, Michael" <michael.zayats@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:34481 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751581AbbBAElQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 23:41:16 -0500
Received: by mail-ob0-f182.google.com with SMTP id nt9so8568547obb.13
        for <netdev@vger.kernel.org>; Sat, 31 Jan 2015 20:41:15 -0800 (PST)
In-Reply-To: <FC8E8D0ECC753F45808079B18C3203FE1CCA0C@G4W3293.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/2015 08:20 PM, Zayats, Michael wrote:
> Hi,
>
> I am looking for a generic mechanism that would allow network device
> drivers to provide socket interface to user and kernel space
> clients.
>
> Such an interface might be used to provide access to important
> sub-streams of packets, alongside with device specific packet
> metadata, provided through msg_control fields of recv/sendmsg.
>
> RX Metadata might include device specific information, such as
> queuing priorities applied, potential destination interface in case
> of switching hardware etc.
>
> On the transmission, metadata might be used to indicate hardware
> specific required optimizations, as well as any other transformation
> or accounting required on the packet.
>
> AF_PACKET based mechanism doesn't allow metadata to be exchanged
> between the client and the device driver. Extending it would require
> extending of sk_buff and potentially additional per packet
> operations. Generic Netlink is not intended to pass packets.
>
> As I am trying to validate generic applicability of such a mechanism,
> I see that TUN driver is providing custom socket interface, in order
> to deal with user information through msg_control. Only usable inside
> the kernel, through custom interface.

> Proposed interface
> ------------------
> Kernel side:
> (struct proto *) should be added to struct net_device.
> Device driver that is interested to support socket interface would populate the pointer.
>

> User space: After creating AF_NETDEV socket, the only successful
> operation would be setting SO_BINDTODEVICE option. Once set, all
> socket operations would be implemented by calling functions, that are
> registered at struct proto on the appropriate net_device.
>
> What do you think?
> Would you see a better approach?
> Some other mechanism that already exists for such a purpose?

It might help to come up with specific examples but an alternate
proposal would be to use skb->priority field and then mqprio to
steer the traffic to a specific queue and then bind attributes to
the queue.

For example the NIC offloaded QOS can be mapped on to queues and
then sockets mapped to the queues.

Another example would be to forward all traffic from one queue
to a virtual fuction in SR-IOV use case. We don't have an interface
to do this but I have been working on an API that could be used
for this.

In this case you don't need to modify AF_PACKET interface but
configure the device correctly. If you need per-packet control
you could use 'tc' or 'nftables' to do the steering.

.John

-- 
John Fastabend         Intel Corporation
