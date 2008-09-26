From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [RFC] bonding: add better ipv6 failover support
Date: Fri, 26 Sep 2008 11:51:38 -0700
Message-ID: <OFE12AA65F.345E597C-ON882574D0.00637542-882574D0.00679AFC@us.ibm.com>
References: <48DAFB92.7040904@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Alex Sidorenko <alexandre.sidorenko@hp.com>,
	fubar@linux.vnet.ibm.com, Jeff Garzik <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:51689 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428AbYIZSvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2008 14:51:52 -0400
In-Reply-To: <48DAFB92.7040904@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) You're calling mld_send_report() directly, which will send the MLD
        report synchronously. It should use the randomized timer (see 
igmp6_join_group).
        A mass failover (e.g., a power event in a cluster) would blast all 
of these at once,
        which is why the randomized timer is required for gratuitous 
reports. This
        should use a randomized timer, like mld_ifc_start_timer(), but 
joining the
        group all by itself will do that.
2) There is already a configurable and code for unsolicited neighbor 
advertisements
        when adding an address-- why not use that? In fact, wouldn't just 
moving the
        failing device's address list to the new device do everything you 
want, since
        adding an address already sends unsolicited neighbor 
advertisements,
        joins the solicited node address, etc.? Or am I missing something?
3) MLD has a lot of state and it's all associated with the device. 
Changing the sending
        device out from under it seems risky to me. I don't know enough 
about
        bonding, but I think you really just want all the group 
memberships and
        MLD state to be with the master device and the master should just 
go
        through the multicast list for the master and join those groups on 
the
        new slave. The MLD code will already resolve the filters 
appropriately
        for joins and filters already done directly on the new slave that 
way.
                Actually, I thought that's what Jay's prior patch was all 
about, and
        those joins should trigger MLD reports where needed, so I'm 
definitely
        confused on what the problem with multicasts is beyond the 
solicited-node
        addresses (which just needs to mimic the address add code, or use 
it
        directly).

                                                        +-DLS

