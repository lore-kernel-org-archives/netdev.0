From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] IPv6: DAD from bonding iface is treated as dup address from others
Date: Thu, 06 Oct 2011 12:05:33 -0700
Message-ID: <27199.1317927933@death>
References: <1317873550-1677-1-git-send-email-Yinglin.Sun@emc.com> <20111006110047.GA22462@hmsreliant.think-freely.org>
Cc: Yinglin Sun <Yinglin.Sun@emc.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:45358 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759098Ab1JFTGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 15:06:00 -0400
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 6 Oct 2011 13:05:51 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p96J5fcH063918
	for <netdev@vger.kernel.org>; Thu, 6 Oct 2011 13:05:43 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p96J5cir012609
	for <netdev@vger.kernel.org>; Thu, 6 Oct 2011 13:05:40 -0600
In-reply-to: <20111006110047.GA22462@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman <nhorman@tuxdriver.com> wrote:

>On Wed, Oct 05, 2011 at 08:59:10PM -0700, Yinglin Sun wrote:
>> Steps to reproduce this issue:
>> 1. create bond0 over eth0 and eth1, set the mode to balance-xor
>> 2. add an IPv6 address to bond0
>> 3. DAD packet is sent out from one slave and then is looped back from
>> the other slave. Therefore, it is treated as a duplicate address and
>> stays tentative afterwards:
>>    kern.info:
>>        Oct  5 11:50:18 testvm1 kernel: [  129.224353] bond0: IPv6 duplicate address 1234::1 detected!
>> 
>> Signed-off-by: Yinglin Sun <Yinglin.Sun@emc.com>
>> ---
>>  net/ipv6/ndisc.c |   15 +++++++++++++--
>>  1 files changed, 13 insertions(+), 2 deletions(-)
>> 
>> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
>> index 9da6e02..c82f4c7 100644
>> --- a/net/ipv6/ndisc.c
>> +++ b/net/ipv6/ndisc.c
>> @@ -809,9 +809,10 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>>  
>>  		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
>>  			if (dad) {
>> +				const unsigned char *sadr;
>> +				sadr = skb_mac_header(skb);
>> +
>>  				if (dev->type == ARPHRD_IEEE802_TR) {
>> -					const unsigned char *sadr;
>> -					sadr = skb_mac_header(skb);
>>  					if (((sadr[8] ^ dev->dev_addr[0]) & 0x7f) == 0 &&
>>  					    sadr[9] == dev->dev_addr[1] &&
>>  					    sadr[10] == dev->dev_addr[2] &&
>> @@ -821,6 +822,16 @@ static void ndisc_recv_ns(struct sk_buff *skb)
>>  						/* looped-back to us */
>>  						goto out;
>>  					}
>> +				} else if (dev->type == ARPHRD_ETHER) {
>> +					if (sadr[6] == dev->dev_addr[0] &&
>> +					    sadr[7] == dev->dev_addr[1] &&
>> +					    sadr[8] == dev->dev_addr[2] &&
>> +					    sadr[9] == dev->dev_addr[3] &&
>> +					    sadr[10] == dev->dev_addr[4] &&
>> +					    sadr[11] == dev->dev_addr[5]) {
>> +						/* looped-back to us */
>> +						goto out;
>> +					}
>>  				}
>>  
>>  				/*
>> -- 
>> 1.7.4.1
>> 
>Nack, This seems like it will just completely break DAD.  What if theres another
>system out there with the same mac address.  A response from that system would
>get dropped by this filter, instead of causing The local system to stop using
>the address.  What you really want to do is modify
>bond_should_deliver_exact_match to detect this frame on the inactive slave or
>some such, and drop the frame there.

	Also NACK; and adding a bit of information.  The balance-xor
mode is nominally expecting to interact with a switch whose ports are
set for etherchannel ("static link aggregation"), in which case the
switch will not loop the packet back around.

	If your switch can do etherchannel, then enable it and the
problem should go away.  If your switch cannot do this, then you may
have other issues, because all of the multicast or broadcast packets
going out any bonding slave will loop around to another slave.  You
could also use 802.3ad / LACP if you switch supports that.

	For balance-xor (or balance-rr, for that matter) mode to a
non-etherchannel switch, it's going to be difficult, if not impossible,
to modify bond_should_deliver_exact_match, because there are no inactive
slaves.  In this mode, bonding is expecting the switch to balance
incoming traffic across the ports, and not deliver looped back packets
or duplicates.  There are no restrictions on what type of traffic
(mcast, bcast, ucast) may arrive on any given port.

	I can't think of a way to make the non-etherchannel case work
for balance-xor (or balance-rr) without breaking the DAD functionality
in the case of an actual duplicate.  I'm not aware of a way to
distinguish a looped back DAD probe from an actual duplicate address
probe elsewhere on the network.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
