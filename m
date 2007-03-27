From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/5 2.6.21-rc4] l2tp: pppol2tp core
Date: Tue, 27 Mar 2007 16:37:31 +0200
Message-ID: <46092C2B.9020804@trash.net>
References: <200703232307.l2NN7Rtg010808@quickie.katalix.com> <46052FC0.8080804@trash.net> <4605758F.90205@katalix.com> <4605908C.6050205@trash.net> <46069CAB.9050807@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60006 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753872AbXC0Oih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2007 10:38:37 -0400
In-Reply-To: <46069CAB.9050807@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Chapman wrote:
>>> Wouldn't that effectively duplicate the code in udp_sendmsg()? If I
>>> don't use a socket, I'd also have to build an IP header and feed the
>>> frame into the IP stack for outbound routing. It doesn't feel like the
>>> right thing to do.
>>
>>
>> Thats what other tunnel drivers do. Sending UDP is pretty simple, I'd
>> expect that it comes down to less code than now.
> 
> 
> I'm still not getting this. :( What other tunnel drivers do this?


Building their own IP-header: ipip, ip_gre.
Building their own UDP-header: esp[46].c

> I've looked at other socket code examples. I see sendmsg code like pppoe
> which builds a skb and does a dev_queue_xmit() or code like cifs that
> uses kernel_sendmsg() which does the set_fs hack internally.


I don't think CIFS is an example that should be copied from. PPPoE
is a bit different since it wants to transmit directly to an ethernet
device and takes care of building the ethernet header itself.

> ESP does build its own UDP header. But ESP is working at a different
> level (IP packet type) rather than L2TP which is really just UDP data.


I don't see the difference. Both receive packets from somewhere,
encapsulate them and send them out.

> Most of the stuff done in udp_sendmsg() is relevant for L2TP, i.e.
> socket param checks, UDP checksum, flow classification, route lookup, IP
> output, MIB counter updates etc. If I do all of this in
> pppol2tp_sendmsg() and insert the IP and UDP header, should I also
> insert the netdevice's MAC address and then dev_queue_xmit()? I'd just
> like to be clear in my own mind what you are recommending before I code
> it up. :)


On the send-side you can simply add an UDP- and IP-header, compute the
checksums, route the packet and send it out using dst_output. The MAC
address is automatically inserted by the IP layer. You could also
(internally) use a socket per tunnel and use ip_queue_xmit, which takes
care of building the IP header, routing the packet, so all you need to
do is add the UDP header and compute the checksum. The advantages are:

- no set_fs hacks
- no need for a seperate TX thread
- probably a lot less and cleaner code

> My understanding is that encapsulation is used where a header is
> inserted _before_ UDP/TCP headers, not after. In the L2TP case, the
> kernel has some data that it wants to send over UDP. The UDP socket
> doesn't need to be special.


The name encapsulation socket may be misleading since its only
used on the receive side, decapsulation socket might be better
fitting. What it does is allow you to receive packets from a
UDP socket without going through the socket queue and using
recvmsg and to process it immediately while in NET_RX_SOFTIRQ.

