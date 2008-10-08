From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: send IPv6 neighbor advertisement on failover
Date: Wed, 08 Oct 2008 12:36:37 -0700
Message-ID: <26501.1223494597@death.nxdomain.ibm.com>
References: <48EC091D.7080207@hp.com> <48ECF8AA.2020205@hp.com> <17192.1223490884@death.nxdomain.ibm.com> <48ED0507.30002@hp.com>
Cc: Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:40811 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754718AbYJHTgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 15:36:51 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e38.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id m98JaG9k017924
	for <netdev@vger.kernel.org>; Wed, 8 Oct 2008 13:36:17 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m98JaeIT187424
	for <netdev@vger.kernel.org>; Wed, 8 Oct 2008 13:36:40 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m98JadME018584
	for <netdev@vger.kernel.org>; Wed, 8 Oct 2008 13:36:40 -0600
In-reply-to: <48ED0507.30002@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad Yasevich <vladislav.yasevich@hp.com> wrote:

>Jay Vosburgh wrote:
>> Vlad Yasevich <vladislav.yasevich@hp.com> wrote:
>> 
>>>> +
>>>> +	list_for_each_entry(bond, &bond_dev_list, bond_list) {
>>>> +		if (bond->dev == event_dev) {
>>>> +			switch (event) {
>>>> +			case NETDEV_UP:
>>>> +				ipv6_addr_copy(&bond->master_ipv6, &ifa->addr);
>>>> +				return NOTIFY_OK;
>>> I think you want to store the first address configured on the device (most
>>> likely link-local), and not overwrite it every time  a new address is
>>> configured.  Since new addresses can be configured rather often (think
>>> temporary, new RAs, etc) we really want the most stable address we can have.
>>> Also, since ND is a link protocol, link-local is sufficient.
>> 
>> 	That depends upon how the IPv6 unsolicited NAs are handled by
>> the switch.  For IPv4, we issue a gratuitous ARP for one of the IP
>> addresses on the interface to update the switch's MAC table; for this
>> case, it doesn't matter which IP address is used.
>> 
>> 	If IPv6-smart switches snoop the same way, then it again doesn't
>> matter which IPv6 address is used; this is just to update the MAC table.
>> I'll agree that it's logically sensible to use a link-local, though.
>> If, on the other hand, IPv6 needs an update for each configured address,
>> then storing just one IPv6 address is insufficient (as we'd need an NA
>> for each address).
>> 
>
>Yes, but the unsolicited NA for the global address just looks rather strange
>when the link local one is provide.  Also, with temporaries that can come and
>go, it's better to use a stable address.

	As I said, I'll agree that it's logically sensible to use a
link-local address.  This appears to be just cosmetic, though, and
(apparently, from what Brian Haley says) doesn't affect the switch
response to the update.  But, wait, there's more...

>We are simply using it to refresh the MAC tables and for a while I thought it
>would be sufficient to do just one ARP or ND, but then I realized that in an
>environment where 2 systems are connected back-to-back, you would potentially
>need to do both.  Need to play with this config...

	Yah, I've been thinking about that in the background, too,
specifically for cases with devices that cannot change their MAC address
(bonding fail_over_mac enabled); in those cases, the MAC changes during
a failover, so the gratuitous update is particularly important.  The
fail_over_mac is used for Infiniband (fixed MAC) and a few ethernet
multiport devices that are confused by having more than one of their
ports set to the same MAC.

	If those devices (when run back to back without a switch) need a
gratutious for each address, they'll need it for IPv4 and IPv6, I
suspect.  I've not heard of any problems of this sort with Infiniband,
but I'm not sure how common back to back is with Infiniband (not very, I
suspect).

	I think the non-fail_over_mac back to back connect case is ok,
at least for linux, because ARP already connects the MAC address to the
bonding device, not the underlying slave.

	As you say, something to play with (but not today, alas, as my
office space is being remodeled).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
