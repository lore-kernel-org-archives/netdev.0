From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [RFC] bonding: add better ipv6 failover support
Date: Fri, 26 Sep 2008 15:46:37 -0400
Message-ID: <48DD3C1D.3020403@hp.com>
References: <OFE12AA65F.345E597C-ON882574D0.00637542-882574D0.00679AFC@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	fubar@linux.vnet.ibm.com, Jeff Garzik <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:20972 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753106AbYIZTqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2008 15:46:40 -0400
In-Reply-To: <OFE12AA65F.345E597C-ON882574D0.00637542-882574D0.00679AFC@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Stevens wrote:
> 1) You're calling mld_send_report() directly, which will send the MLD
>         report synchronously. It should use the randomized timer (see 
> igmp6_join_group).
>         A mass failover (e.g., a power event in a cluster) would blast all 
> of these at once,
>         which is why the randomized timer is required for gratuitous 
> reports. This
>         should use a randomized timer, like mld_ifc_start_timer(), but 
> joining the
>         group all by itself will do that.

To add to what David said, looks like mld_send_report will always send a
Version 2 report.  This should honor correctly V1 or v2 configuration.

However, to address the random delay, this would have to be static delay
of at most 1 sec.  Otherwise any NUD probes would be lost.


> 3) MLD has a lot of state and it's all associated with the device. 
> Changing the sending device out from under it seems risky to me. I don't know enough 
> about bonding, but I think you really just want all the group 
> memberships and MLD state to be with the master device and the master should just 
> go through the multicast list for the master and join those groups on 
> the new slave. The MLD code will already resolve the filters 
> appropriately for joins and filters already done directly on the new slave that 
> way.  Actually, I thought that's what Jay's prior patch was all 
> about, and those joins should trigger MLD reports where needed, so I'm 
> definitely confused on what the problem with multicasts is beyond the 
> solicited-node addresses (which just needs to mimic the address add code, or use 
> it directly).

Yes, I think this needs a little more thought.  The multicast addresses are
already on the master and also on the active slave.  However, at failover time,
I think those memberships needs to be removed from the old slave, and added
to the new slave.  Alex mentioned that there were some refcounts that didn't
allow for this to happen, but I don't see any.

The trouble I see is that the MLD/IGMPv6 is only sent when an IPv6 multicast
address is added.  In the failover scenario, since IPv6 address is joined on
the bond, we only move the link multicast address from one interface to
another.  This doesn't normally trigger and new report, but this is just what
we want.

Additionally, I think the code should be using an unsolicited NA instead of the
NS, since we do really want to trigger a rediscovery the address and
the associated MAC to make sure that all forwarding state is updated on link.

-vlad
