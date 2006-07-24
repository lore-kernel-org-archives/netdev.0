From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Help with bugfix for bond active-backup mode + vlans
Date: Mon, 24 Jul 2006 10:49:01 -0700
Message-ID: <200607241749.k6OHn1hg030011@death.nxdomain.ibm.com>
References: <200607241837.42626.Christophe.Devriese@eurid.eu>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:22964 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932241AbWGXRtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 13:49:09 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6OHn8xP026728
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 24 Jul 2006 13:49:08 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6OHn75m234384
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 24 Jul 2006 13:49:08 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6OHn79A012897
	for <netdev@vger.kernel.org>; Mon, 24 Jul 2006 13:49:07 -0400
To: Christophe Devriese <Christophe.Devriese@eurid.eu>
In-reply-to: <200607241837.42626.Christophe.Devriese@eurid.eu> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christophe Devriese <Christophe.Devriese@eurid.eu> wrote:

[...]
>Would it be acceptable to have an interface flag IFF_SILENT that can be set on 
>an interface, which prevents it from receiving packets in both forwarding 
>paths ?

	Starting with kernel version 2.6.17, there is code in skb_bond()
to suppress traffic on inactive slaves, but it looks like that will
bypassed by hardware accelerated VLAN packets (which, if I'm reading the
code correctly, have their skb->dev directly assigned to the VLAN
interface, so they go into netif_receive_skb with skb->dev not set to
the slave device, which will bypass the stuff in skb_bond).

	An IFF_SILENT type of flag would work fine (if checked in both
input paths) for the active-backup mode, but the 802.3ad and balance-alb
modes need differing types of traffic dropping, e.g., the balance-alb
mode just needs to suppress broadcast and multicasts.

	One possible solution for this would be to have bonding remove
the vlan registration for inactive slaves, which would cause the errant
packets to pass through skb_bond() normally and presumably be dropped.
That would work for the active-backup case, but would cause balance-alb
mode to lose VLAN acceleration on all interfaces except for one.

	Another possibility would be to have __vlan_hwaccel_rx check the
VLAN_DEV_INFO(skb->dev)->real_dev, and if that's a bonding device, apply
the same logic found in skb_bond().  Or, if there's some way to ask the
question "is dev a VLAN device?", then that same test could be put into
skb_bond() and all of the packet suppression fru fru could stay there.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
