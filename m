From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Using gretap to tunnel layer 2 traffic
Date: Fri, 09 Sep 2011 20:19:09 +0100
Message-ID: <1315595949.2808.65.camel@bwh-desktop>
References: <1315589104.22676.YahooMailNeo@web45104.mail.sp1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: John H <uothrawn@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:56092 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759816Ab1IITTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2011 15:19:12 -0400
In-Reply-To: <1315589104.22676.YahooMailNeo@web45104.mail.sp1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-09-09 at 10:25 -0700, John H wrote:
> I am attempting to tunnel Layer 2 traffic through a gretap device, 
> while encrypting the GRE tunnel with IPsec. My test environment is as follows:
> 
> 10.0.1.1                                          10.0.1.2
> client_a <--> server_left <==> server_right <---> client_b
>                       gretap/IPsec
>                       
> 
> On the servers, I have two VLANs per server, corresponding to the unencrypted
> and encrypted interfaces.  On each server, the unencrypted VLAN is 
> bridged with the gretap device.  All VLANs and physical devices have MTUs of 
> 1500.  The gretap device has a resultant MTU of 1462, thereby causing the 
> bridge device to have an MTU of 1462.
> 
> Traffic for the most part works as it is expected to behave. However, 
> packets are dropped when client_a sends an ICMP packet to client_b which 
> has an MTU less than client_a's device MTU but larger than server_left's 
> MTU. I suspect other protocols would behave similarly (silently dropping
> packets).  I an running "ping -c 1 -s 1450 10.0.1.2" on client_a, this results
> in an ICMP packet being sent with an MTU of 1478.
> 
> An MTU of 1478 is larger than the bridge device's MTU of 1462, causing the 
> packet to be silently discarded per net/bridge/br_forward.c 
> in function br_dev_queue_push_xmit:
>
> int br_dev_queue_push_xmit(struct sk_buff *skb)
> {
>     /* drop mtu oversized packets except gso */
>     if (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))
>         kfree_skb(skb);
>     else {
>     ....
>     
> If the gretap device supported GSO, I suspect that this would not be a
> problem. (ethtool -k gretapLeftRight states that GSO/GRO/LRO is not 
> supported)

GRO+GSO may generally be used when forwarding TCP packets.  But aside
from that, none of these have any effect on forwarded packets.

> Function br_dev_queue_push_xmit eventually calls ipgre_tunnel_xmit, if the 
> packet is not dropped.
> 
> I would think that br_dev_queue_push_xmit should call ipgre_tunnel_xmit
> regardless of the device MTU and ipgre_tunnel_xmit would handle packet
> fragmentation internally, but it never has the chance.
> 
> I have tried allowing all packets through br_dev_queue_push_xmit
> and explicitly setting the Don't Frament field to 0 in ipgre_tunnel_xmit,
> but this didn't solve problem.
> 
> Given that this would be tunneling Layer 2 traffic, it wouldn't make sense
> to send an ICMP_FRAG_NEEDED response from the bridge.

Right.

> The real question is, however, why is any client able to send a single ICMP
> packet with size 1478 bytes when one of the hops along the way only 
> supports 1462 bytes per its MTU? Shouldn't this have been negotiated 
> beforehand?

The DHCP and/or route advertisement daemons should tell hosts what the
correct MTU is for the subnet they are on.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
