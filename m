From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: iproute2: removing primary address removes secondaries
Date: Fri, 11 Jan 2008 18:13:15 +0100
Message-ID: <4787A3AB.4000205@fr.ibm.com>
References: <20080111163155.GA17637@piper.oerlikon.madduck.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev discussion list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:63602 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757310AbYAKRNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 12:13:24 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id m0BHDMun088428
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 17:13:22 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0BHDLKl2986124
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 18:13:21 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0BHDLWD006051
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 18:13:21 +0100
Received: from [9.101.17.27] (mai.toulouse-stg.fr.ibm.com [9.101.17.27])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id m0BHDJe2006019
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 11 Jan 2008 18:13:21 +0100
In-Reply-To: <20080111163155.GA17637@piper.oerlikon.madduck.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

martin f krafft wrote:
> Dear list,
> 
> When I add an address to an interface whose network prefix is the
> same as that of an address already bound to the interface, the new
> address becomes a secondary address. As per
> http://www.policyrouting.org/iproute2.doc.html:
> 
>   "secondary --- this address is not used when selecting the default
>   source address for outgoing packets. An IP address becomes
>   secondary if another address within the same prefix (network)
>   already exists. The first address within the prefix is primary and
>   is the tag address for the group of all the secondary addresses.
>   When the primary address is deleted all of the secondaries are
>   purged too."
> 
> In the following, I want to argue that this is not necessary.
> I think that removal of a primary address should cause the next
> address to be promoted to be the default source address and the
> link-scoped route to be retained. This is basically out of
> http://bugs.debian.org/429689, the maintainer asked me to turn
> directly to this list.
> 
> If I add an address to a device with 'ip add', ip also implicitly
> adds a link-scoped route according to the netmask. It only does this
> for primary addresses, so if I add a second address within the same
> network, the route is not duplicated.
> 
> Thus, the net effect on the routing table is the same for the
> following two commands:
> 
>   ip a a 172.16.0.100/12 dev eth0 && ip a a 172.16.0.200/12 dev eth0
>   ip a a 172.16.0.100/12 dev eth0 && ip a a 172.16.0.200/32 dev eth0
>                                                         ^^^^
> In the first case, the .200 address becomes a secondary of the .100
> address. In the second case, they are both primaries. In both cases,
> only one /12 link-scoped route will be created.
> 
> However, in both cases, if I remove the .100 address, the .200 is
> affected: if it's secondary, it ceases to exist, and if it's
> primary (i.e. in the /32 case), then the host can no longer use it
> to communicate to hosts in the same link segment, only to hosts on
> the other side of the default gateway.
> 
> I thus question the point of purging secondary addresses. Obviously,
> only one address can be primary (it is used as source address for
> packets leaving the machine by the respective route). But if the
> primary address is removed, the next secondary should be promoted
> and the route should *not* be deleted.
> 
> Comments?
> 
> Cheers,

There is a tweak in /proc/sys which activate secondaries promotion when 
a primary is deleted.

/proc/sys/net/ipv4/conf/all/promote_secondaries

I think it changes the behavior to the one you wish.

Regards
