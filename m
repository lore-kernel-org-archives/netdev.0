From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [RFC] bonding: add better ipv6 failover support
Date: Fri, 26 Sep 2008 15:55:13 -0400
Message-ID: <48DD3E21.2030300@hp.com>
References: <OFE12AA65F.345E597C-ON882574D0.00637542-882574D0.00679AFC@us.ibm.com> <48DD37C8.1010205@hp.com>
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
Received: from g4t0014.houston.hp.com ([15.201.24.17]:23720 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762AbYIZTzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2008 15:55:16 -0400
In-Reply-To: <48DD37C8.1010205@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley wrote:
> David Stevens wrote:
>> 1) You're calling mld_send_report() directly, which will send the MLD
>>         report synchronously. It should use the randomized timer (see
>> igmp6_join_group).
>>         A mass failover (e.g., a power event in a cluster) would blast
>> all of these at once,
>>         which is why the randomized timer is required for gratuitous
>> reports. This
>>         should use a randomized timer, like mld_ifc_start_timer(), but
>> joining the
>>         group all by itself will do that.
> 
> Ok, I'll try and change this code to spin through all the multicast
> addresses on the master and call igmp6_join_group() instead.

I think you would need to call igmp6_leave_group before switching the active
and then join group on the new active.

> 
>> 2) There is already a configurable and code for unsolicited neighbor
>> advertisements
>>         when adding an address-- why not use that? In fact, wouldn't
>> just moving the
>>         failing device's address list to the new device do everything
>> you want, since
>>         adding an address already sends unsolicited neighbor
>> advertisements,
>>         joins the solicited node address, etc.? Or am I missing
>> something?
> 
> In this case the address is configured on the bond master, each slave is
> just used for transmit/receive.  While I could have sent an unsolicited
> NA, sending an NS is much easier, especially since it's only notifying
> the switch that the address has moved.

Why?  NS and NA take exactly the same code paths.  The only difference
appears to be source address lookup, but you don't need to worry about it
since you know the source address ahead of time.

-vlad
