From: Christian Engelmayer <christian.engelmayer@frequentis.com>
Subject: Re: [RFC] CPSW: dual standalone emac mode / bonding
Date: Thu, 6 Mar 2014 18:15:27 +0100
Message-ID: <20140306181527.3b436153@frequentis.com>
References: <20140305183318.16f5dafa@frequentis.com>
	<53183051.7080801@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.frequentis.com ([195.20.158.50]:51006 "EHLO
	mail1.frequentis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbaCFRP3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 12:15:29 -0500
In-Reply-To: <53183051.7080801@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 6 Mar 2014 13:52:41 +0530, Mugunthan V N <mugunthanvnm@ti.com> wrote:
> It seems that some other system in the network is using the same mac in
> your EVM or there is a loop detected in your network which leads that
> ALE is learning that there is  system with your MAC and updating the ALE
> table that the mac is there and which leads your own packet will be
> forwarded to that port and not to host port.
> 
> When ever you start a transmission the ALE learns the host port MAC is x
> and updates ALE table with that port number and so there in your network
> is working.

Regarding the duplicate mac address please consider the following scenario:
2 switches are interconnected via a single crosslink. There is no loop
in the system. The EVM is configured for dual emac mode and each external
port is connected to one of the 2 switches.

The 2 ethernet interfaces are enslaved by the bonding driver and setup in
active-backup mode - from Documentation/networking/bonding.txt:

    "Active-backup policy: Only one slave in the bond is
    active.  A different slave becomes active if, and only
    if, the active slave fails.  The bond's MAC address is
    externally visible on only one port (network adapter)
    to avoid confusing the switch."

The default mac failover is used - all slave interfaces are set to the
same mac address, so in case of a failure of the active slave the switches
have to relearn ports due to issued gratuitous arp, but device caches are
not affected.

In case the EVM generates an arp request from the active interface the
frame is also propagated through the system and received by the backup
interfaces as it is a broadcast. Where an actual NIC would not be affected
and the stack drops frames received on backup interfaces, I understood
from You that the CPSW in dual emac mode is still a switch and relearns.

>From some of the TI wikis one might assume that that is not the case

    http://processors.wiki.ti.com/index.php/SK_ETH

    "MAC mode disables the ALE in the AM335x and each of the external
     Ethernet ports communicates using different MAC addresses."

However, the following seems to be more correct and resemble the implementation:

    http://processors.wiki.ti.com/index.php/AM335x_CPSW_(Ethernet)_Driver's_Guide
    http://processors.wiki.ti.com/index.php/Linux_Core_CPSW_User's_Guide

    "Both the interfaces should not be connected to the same subnet
     unless only configuring bridging, and not doing IP routing, then
     you can configure the two interfaces on the same subnet."

Whereas from the observed behaviour I would assume that both interfaces
should not only be in different subnets, but also connected to different
broadcast domains.

It is not obvious to me why the CPSW learns per vlan, but got the persistant
addresses configured differently - eg. snippet from /sys/class/net/eth0/ale_table

    type: vlan+addr(3), vlan: 3, addr: 00:12:3f:5d:96:17, uctype: touched(3), port: 2
    type: vlan+addr(3), vlan: 2, addr: 00:12:3f:5d:96:17, uctype: touched(3), port: 1
    type: vlan+addr(3), vlan: 3, addr: 34:db:fd:76:7f:be, uctype: untouched(1), port: 2
    type: vlan+addr(3), vlan: 2, addr: 34:db:fd:76:7f:be, uctype: untouched(1), port: 1

    type: addr(1), addr: 00:18:31:e0:06:69, uctype: persistant(0), port: 0
    type: addr(1), addr: 00:18:31:e0:06:6a, uctype: persistant(0), port: 0

Due to this I currently see no change in the behaviour in case I configure the
bond to use the interface assigned mac addresses without change or swap the
macs just in case of a failover.

It might be a solution to this setup if the CPSW would not be able to
relearn it's own host macs, or if the learning would be completly separated
per port/vlan.

I admit that the affected EVM is still on the TI 3.2 Kernel and I have
to upgrade the scenario, but as both pieces of code are from You: I
saw that the setup of mac addresses has been changed in the current
mainline version. cpsw_ale_add_ucast() seems to be merged with the
previously split functionality of cpsw_ale_vlan_add_ucast() and in case
of priv->data.dual_emac I see vid handling eg. in function
cpsw_ndo_set_mac_address() and others.

Could this result in a different setup of the ALE that allows relearning of
the mac address set on both interfaces on the VLAN used for external backup
port 2 without affecting the communication on external active port 1?

Regards,
Christian
