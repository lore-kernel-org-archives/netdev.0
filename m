From: Chris Friesen <chris.friesen@genband.com>
Subject: discussion questions: SR-IOV, virtualization, and bonding
Date: Thu, 02 Aug 2012 13:21:34 -0600
Message-ID: <501AD33E.5090308@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og108.obsmtp.com ([64.18.2.169]:38639 "EHLO
	exprod7og108.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751017Ab2HBTWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 15:22:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi all,

I wanted to just highlight some issues that we're seeing and see what 
others are doing in this area.

Our configuration is that we have a host with SR-IOV-capable NICs with 
bonding enabled on the PF.  Depending on the exact system it could be 
active/standby or some form of active/active.

In the guests we generally have several VFs (corresponding to several 
PFs) and we want to bond them for reliability.

We're seeing a number of issues:

1) If the guests use arp monitoring then broadcast arp packets from the 
guests are visible on the other guests and on the host, and can cause 
them to think the link is good even if we aren't receiving arp packets 
from the external network.  (I'm assuming carrier is up.)

2) If both the host and guest use active/backup but pick different 
devices as the active, there is no traffic between host/guest over the 
bond link.  Packets are sent out the active and looped back internally 
to arrive on the inactive, then skb_bond_should_drop() suppresses them.

3) For active/standby the default is to set the standby to the MAC 
address of the bond.  If the host has already set the MAC address (using 
some algorithm to ensure uniqueness within the local network) then the 
guest is not allowed to change it.


So far the solutions to 1 seem to be either using arp validation (which 
currently doesn't exist for loadbalancing modes) or else have the 
underlying ethernet driver distinguish between packets coming from the 
wire vs being looped back internally and have the bonding driver only 
set last_rx for external packets.

For issue 2, it would seem beneficial for the host to be able to ensure 
that the guest uses the same link as the active.  I don't see a tidy 
solution here.  One somewhat messy possibility here is to have bonding 
send a message to the standby PF which then tells all its VFs to fake 
loss of carrier.

For issue 3, the logical solution would seem to be some way of assigning 
a list of "valid" mac addresses to a given VF--like maybe all MAC 
addresses assigned to a VM or something.  Anyone have any bright ideas?


I'm sure we're not the only ones running into this, so what are others 
doing?  Is the only current option to use active/active with miimon?

Chris

-- 

Chris Friesen
Software Designer

3500 Carling Avenue
Ottawa, Ontario K2H 8E9
www.genband.com
