From: "Chris Friesen" <cfriesen@nortel.com>
Subject: arp monitor chicken and egg problem
Date: Fri, 25 Jul 2008 01:09:48 -0400
Message-ID: <4889601C.6030302@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kn.nortel.com ([47.140.192.55]:37431 "EHLO
	zrtps0kn.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943AbYGYFrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 01:47:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We've recently run into an interesting chicken-and-egg problem with 
bonding, arp monitoring, and DHCP.

We have a blade-based system with a pair of disk server blades, a pair 
of network switch blades, and a bunch of app blades.

The disk server blades act as DHCP servers to all the other blades.  The 
switch blades boot from flash, but then obtain their IP address and 
other config info from the server blades via DHCP a bonded link.

We would like to use something other than simple carrier sense because 
the firmware on the switch cards has the nasty habit of bringing up 
carrier way before the switches are actually ready to handle traffic.

We've run into the following scenario:

1) server blade is up, switch blades are down
2) switch blades start to boot, carrier comes up (detected on server)
3) switch blades issue DHCP request
4) server blade attempts to reply to request, but has no active link 
because arp monitoring hasn't received a reply yet
5) several hundred ms later, arp monitoring notices we received a packet 
(the DHCP request) and brings the link up
6) several hundred ms after that, arp monitoring notices we haven't 
received any arp responses, and brings the link down
7) several hundred ms after this, the switch blade issues another DHCP 
request (jump to step 4)

There are other sources of packets on the system, and eventually the 
timing is such that the DHCP request arrives during the window that the 
link is up, and the system comes up.

I've been asked to consider a hack to attempt sending a packet out 
any/all (not sure yet) links with carrier signal if we've failed to find 
a suitable active link.  I suppose we could also set the DHCP retry 
interval to be smaller than the bonding arp interval.

Both of these options seem fairly hackish, so can anyone suggest a 
better way to handle the above scenario?

Thanks,

Chris
