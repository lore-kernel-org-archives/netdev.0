From: "Mr. Berkley Shands" <berkley@seas.wustl.edu>
Subject: IGMP when multiple interfaces share a subnet (2.6.32-2.6.35+)
Date: Thu, 30 Sep 2010 16:24:36 -0500
Message-ID: <4CA50014.6040307@seas.wustl.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Net Dev <netdev@vger.kernel.org>, Dave Lloyd <dlloyd@exegy.com>,
	Ed Spitznagel <espitznagel@exegy.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.seas.wustl.edu ([128.252.21.108]:58265 "EHLO
	POSTOFFICE.seas.wustl.edu" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751515Ab0I3Vjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 17:39:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When there are multiple interfaces on the same subnet
(I.E. 10.19.20.21 on eth1, 10.19.20.22 on eth2, ...)
and the subnet mask is 255.255.255.0
The Cicso Layer 3 sends out IGMP queries, both eth1, eth2 see them.
If a multicast group is subscribed on eth1, all is fine.
But if another multicast group is subscribed off eth2 at the same time,
then the IGMP reports for eth2 go back out eth1, or don't go out at all.
Worse, if you ifdown eth1, eth2 and then ifup them (service network 
restart)
then neither interface will respond to IGMP reports/requests.

We tried forcing all the IGMP traffic to V2, no luck.
the kernel's responses go out the lowest interface index, or not at all
once the second interface does a multicast join.
Hacking the kernel to continuously send IGMP reports works
until the window of the report times overlaps the routers pings.
then the router assumes a drop.

This did not happen under 2.6.22 (centos-5.2 through centos 5.5 on X86_64)
with Intel igb based nics.

We do not control the IP addresses.
We see this with VLANs as well. tcpdump sees the request come in
every 60 seconds or so, but nothing responds back.

Would using a 32-bit netmask on those ports force the kernel to
respond on the correct interface?

Why does bouncing an interface completely disable IGMP reports?
We currently have 2.5.35.2 running. Did the setsockopt() code
change from "struct ip_mreq" to "struct ip_mreqn" to throw in an 
interface index?

Any suggestions as to what to poke?

Berkley Shands
