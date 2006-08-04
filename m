From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Thu, 03 Aug 2006 18:01:35 -0700
Message-ID: <200608040101.k7411ZZt013801@death.nxdomain.ibm.com>
References: <44CA87C5.1060905@candelatech.com> <20060730.205032.130618331.davem@davemloft.net> <200607311015.40255.Christophe.Devriese@eurid.eu> <20060802.135859.91441473.davem@davemloft.net>
Cc: Christophe.Devriese@eurid.eu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:54169 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1030271AbWHDBBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 21:01:39 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7411cje004015
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 3 Aug 2006 21:01:38 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k7411c76266502
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 3 Aug 2006 21:01:38 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7411bel014018
	for <netdev@vger.kernel.org>; Thu, 3 Aug 2006 21:01:38 -0400
To: David Miller <davem@davemloft.net>
In-reply-to: <20060802.135859.91441473.davem@davemloft.net> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

>> The same struct vlan_group is assigned to all slave devices and so the only 
>> vlan subinterfaces that exist in this case are the bond<x>.<vlan> 
>> subinterfaces, and the vlan path for both slaves will assign the 
>> bond<x>.<vlan> interface to skb->dev, thereby erasing the information about 
>> where the packet came from.
>
>Assuming it is correct to do the skb_bond() here in the VLAN hwaccel
>RX path, then there is still one piece missing from what I can see.

	I'm not sure it's correct to do everything that skb_bond() does
(I've been away on family business, and I'm a bit rusty coming back to
this), but it is correct to do the "should we drop this packet because
it's a duplicate because bonding is involved" logic (because the VLAN
acceleration processing is indavertently bypassing that step).

>Notice that in the netif_receive_skb() path, the return value from
>skb_bond() is used as the third argument to the deliver_skb() routine
>and friends which in turn gets passed to the packet_type functions.
>
>Bonding, in particular, makes use of this third argument, see:
>
>bond_3ad_lacpdu_recv()

	This function expects the third argument to be the the device
that is actually enslaved to the bond and is acting as the endpoint for
the 802.3ad protocol negotiations.  If it's a VLAN interface under
there, that's what it needs.

>rlb_arp_recv()

	This function doesn't actually use the third argument that I'm
seeing.

>So if the new "orig_dev" you are computing in the VLAN hwaccel RX path
>is the correct one, somehow this has to propagate down to the third
>argument of the packet type ->func() invocations, right?
>
>Finally, I'm still a little stumped about why this change is necessary
>still, to be honest.  When you configure the bond, the slaves should
>be the VLAN devices as far as I can tell.  Therefore it should be the
>"vlan_device->masster" that we are interested in not the top-level
>"dev->master".
>
>If the ethernet is on a VLAN, and the administrator configures the
>underlying ethernet device as the slaves of the bond, this to me seems
>like a misconfiguration rather than something we should put hacks in
>to support.

	Not necessarily.  For a configuration with redundant paths
(either multiple ports or multiple switches) or multiple VLANs over the
same physical ports, it's also plausible to configure the vlan
interfaces above bonding, and make the ethernet devices direct slaves of
bonding.  In that configuration, the vlan interfaces are on top,
followed by the bonding device, and the ethernet devices at the bottom.

	In this case (bond0.555 above bond0 above eth0,eth1,etc),
skb_bond doesn't suppress duplicates because skb_bond is called with the
skb->dev set to the bond0.555 dev, not the ethX dev.  Non-accelerated
VLAN devices don't do this; they'll come in with skb->dev set to ethX
and will go through skb_bond as expected.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
