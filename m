From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: L2L3 xmit doesn't support IPv6
Date: Tue, 11 Oct 2011 08:58:59 -0700
Message-ID: <23119.1318348739@death>
References: <1318052205-21991-1-git-send-email-Yinglin.Sun@emc.com> <20111011143348.GA20605@gospo.rdu.redhat.com>
Cc: Yinglin Sun <Yinglin.Sun@emc.com>, netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:44374 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754844Ab1JKQBe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 12:01:34 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p9BEe4ke007596
	for <netdev@vger.kernel.org>; Tue, 11 Oct 2011 10:40:04 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9BG1NXO145198
	for <netdev@vger.kernel.org>; Tue, 11 Oct 2011 12:01:33 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9BFx3dk014141
	for <netdev@vger.kernel.org>; Tue, 11 Oct 2011 11:59:03 -0400
In-reply-to: <20111011143348.GA20605@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:

>On Fri, Oct 07, 2011 at 10:36:45PM -0700, Yinglin Sun wrote:
>> Add IPv6 support in L2L3 xmit policy.
>> L3L4 doesn't support IPv6 either, and I'll try to fix that later.
>> 
>> Signed-off-by: Yinglin Sun <Yinglin.Sun@emc.com>
>> ---
>>  drivers/net/bonding/bond_main.c |    7 +++++++
>>  1 files changed, 7 insertions(+), 0 deletions(-)
>> 
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 6d79b78..d6fd282 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -41,8 +41,10 @@
>>  #include <linux/ptrace.h>
>>  #include <linux/ioport.h>
>>  #include <linux/in.h>
>> +#include <linux/in6.h>
>>  #include <net/ip.h>
>>  #include <linux/ip.h>
>> +#include <linux/ipv6.h>
>>  #include <linux/tcp.h>
>>  #include <linux/udp.h>
>>  #include <linux/slab.h>
>> @@ -3372,10 +3374,15 @@ static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count)
>>  {
>>  	struct ethhdr *data = (struct ethhdr *)skb->data;
>>  	struct iphdr *iph = ip_hdr(skb);
>> +	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
>>  
>>  	if (skb->protocol == htons(ETH_P_IP)) {
>>  		return ((ntohl(iph->saddr ^ iph->daddr) & 0xffff) ^
>>  			(data->h_dest[5] ^ data->h_source[5])) % count;
>> +	} else if (skb->protocol == htons(ETH_P_IPV6)) {
>> +		return ((ntohl(ipv6h->saddr.s6_addr32[3] ^
>> +			       ipv6h->daddr.s6_addr32[3]) & 0xffff) ^
>> +			(data->h_dest[5] ^ data->h_source[5])) % count;
>>  	}
>>  
>
>There have been some attempts to add support for ipv6 hashing this in
>the past, but none have been committed.  The best one I had seen was one
>that did some extensive testing one a wide variety of ipv6 traffic and
>it showed nice traffic distribution.  I'm not sure if it was ever posted
>upstream, so I will see if I can dig it up.
>
>Can you quantify how traffic was distributed with this algorithm?

	As I recall, the IPv6 issues had to do with the "layer3+4" hash,
because the IPv6 TCP or UDP port numbers can be harder to get at than in
IPv4 (which typically has a fixed size header).  The above is just for
layer 2, so it only hits the IPv6 addresses, which don't move around.

	That said, I believe that many IPv6 addresses are derived from
the MAC address, the autoconf addresses in particular, so s6_addr32[3]
may not show a lot more variation than just the MAC address.  I don't
know for sure though, since I haven't tested it.

	I don't recall seeing the patch you mention, Andy, that checks
ipv6 traffic; can you post it?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
