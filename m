From: James Yonan <james@openvpn.net>
Subject: GSO/GRO and UDP performance
Date: Wed, 04 Sep 2013 04:07:21 -0600
Message-ID: <52270659.1090208@openvpn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from magnetar.openvpn.net ([74.52.27.18]:40570 "EHLO
	magnetar.openvpn.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762244Ab3IDKum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 06:50:42 -0400
Received: from moab.lan (c-24-9-78-222.hsd1.co.comcast.net [24.9.78.222])
	(authenticated bits=0)
	by magnetar.openvpn.net (8.13.1/8.13.1) with ESMTP id r84A7BaF023357
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 4 Sep 2013 04:07:12 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm looking at ways to improve UDP performance in the kernel. 
Specifically I'd like to take some of the ideas in GSO/GRO for TCP and 
apply them to UDP as well.  Our use case is OpenVPN, but these methods 
should apply to any UDP-based app.

AS I understand GSO/GRO for TCP, there are essentially two central features:

(a) it's a way of batching packets with similar headers together so that 
they can efficiently traverse the network stack as a single unit

(b) it explicitly maps the batching of packets to the L4 segmenting 
features of TCP, so that batched packets can be coalesced into TCP segments.

This approach works great for TCP because of its built-in L4 segmenting 
features, but it tends to break down for UDP because of (b) in 
particular -- UDP doesn't have an L4 segmenting model, so the 
gso_segment method for UDP resorts to segmenting the packets with L3 IP 
fragmentation (i.e. UFO).  The problem is that IP fragmentation is 
broken on so many different levels that it can't be relied on for apps 
that need to communicate over the open internet (*).  Most UDP apps do 
their own app-level fragmentation and wouldn't want to be forced to buy 
into IP fragmentation in order to get the performance benefits of GSO/GRO.

So I would like to propose a GSO/GRO implementation for UDP that works 
by batching together separate UDP packets with similar headers into a 
single skb.  There is no-tie in with L3 IP fragmentation -- the packets 
are sent over the wire and received as individual UDP packets.

Here is an example of how this might work in practice:

When I call sendmmsg from userspace with a bunch of UDP packets having 
the same header, the kernel would assemble these packets into a single 
skb via shinfo(skb)->frag_list.  There would need to be a new gso_type 
indicating that frag_list is simply a list of UDP packets having the 
same header that should be transmitted separately.  No IP fragmentation 
would be necessary as long as the app has correctly sized the packets 
for the link MTU.

Once this skb is about to reach the driver, dev_hard_start_xmit could do 
the usual GSO thing and separate out the packets in 
shinfo(skb)->frag_list and pass them individually to the driver's 
ndo_start_xmit method, if the driver doesn't support batched UDP 
packets.  There would need to be a new gso_type for this batching model, 
e.g. "SKB_GSO_UDP_BUNDLE" that drivers could optionally support.

On the receive side, we would define a gro_receive method for UDP (none 
currently exists) that does the same batching in reverse:  UDP packets 
with the same header would be collected into shinfo(skb)->frag_list and 
gso_type would be set to SKB_GSO_UDP_BUNDLE.

The bundle of UDP packets would traverse the stack as a unit until it 
reaches the socket layer, where recvmmsg could pass the whole bundle up 
to userspace in a single transaction (or recvmsg could disaggregate the 
bundle and pass each datagram individually).

This approach should also significantly speed up UDP apps running on VM 
guests, because the skbs of bundled UDP packets could be passed across 
the hypervisor/guest barrier in a single transaction.

Because this technique bundles UDP packets without coalescing or 
modifying them, the approach should be lossless with respect to 
bridging, hypervisor/guest communication, routing, etc.  It also doesn't 
interfere with existing hardware support for L4 checksum offloading 
(unlike UFO).

Could this work?  Are there problems with this that I'm not considering? 
  Are there better or existing ways of doing this?

Thanks,
James

---------------------

(*) Well-known issues of UDP/IP fragmentation:

1. Relies on PMTU discovery, which often doesn't work in the real world 
because of inconsistent ICMP forwarding policies.

2. Breaks down on high-bandwidth links because the IPv4 16-bit packet ID 
value can wrap around, causing data corruption.

3. One fragment lost in transit means that the whole superpacket is lost.

James
