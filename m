From: Brian Haley <brian.haley@hp.com>
Subject: Re: [RFC] bonding: add better ipv6 failover support
Date: Fri, 26 Sep 2008 15:28:08 -0400
Message-ID: <48DD37C8.1010205@hp.com>
References: <OFE12AA65F.345E597C-ON882574D0.00637542-882574D0.00679AFC@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alex Sidorenko <alexandre.sidorenko@hp.com>,
	fubar@linux.vnet.ibm.com, Jeff Garzik <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:18125 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752729AbYIZT2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2008 15:28:11 -0400
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

Ok, I'll try and change this code to spin through all the multicast 
addresses on the master and call igmp6_join_group() instead.

> 2) There is already a configurable and code for unsolicited neighbor 
> advertisements
>         when adding an address-- why not use that? In fact, wouldn't just 
> moving the
>         failing device's address list to the new device do everything you 
> want, since
>         adding an address already sends unsolicited neighbor 
> advertisements,
>         joins the solicited node address, etc.? Or am I missing something?

In this case the address is configured on the bond master, each slave is 
just used for transmit/receive.  While I could have sent an unsolicited 
NA, sending an NS is much easier, especially since it's only notifying 
the switch that the address has moved.

> 3) MLD has a lot of state and it's all associated with the device. 
> Changing the sending
>         device out from under it seems risky to me. I don't know enough 
> about
>         bonding, but I think you really just want all the group 
> memberships and
>         MLD state to be with the master device and the master should just 
> go
>         through the multicast list for the master and join those groups on 
> the
>         new slave. The MLD code will already resolve the filters 
> appropriately
>         for joins and filters already done directly on the new slave that 
> way.
>                 Actually, I thought that's what Jay's prior patch was all 
> about, and
>         those joins should trigger MLD reports where needed, so I'm 
> definitely
>         confused on what the problem with multicasts is beyond the 
> solicited-node
>         addresses (which just needs to mimic the address add code, or use 
> it
>         directly).

Like #1, I'll try changing the code.

Thanks for the comments.

-Brian
