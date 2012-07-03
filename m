From: John Eaglesham <linux@8192.net>
Subject: Re: [PATCH v6] bonding support for IPv6 transmit hashing
Date: Mon, 02 Jul 2012 22:01:20 -0700
Message-ID: <4FF27CA0.7030708@8192.net>
References: <c390ff662ede0f304398a88ca1a96e3773065c60.1341129744.git.linux@8192.net> <eb20e8f67e6aad94c233219e058c3e793ed755cb.1341167171.git.linux@8192.net> <18390.1341272010@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp111.dfw.emailsrvr.com ([67.192.241.111]:40212 "EHLO
	smtp111.dfw.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998Ab2GCFBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 01:01:21 -0400
In-Reply-To: <18390.1341272010@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/2/2012 4:33 PM, Jay Vosburgh wrote:
>> +
>> +		(((hash >> 24) XOR (hash >> 16) XOR (hash >> 8) XOR hash)
>> +			(source MAC XOR destination MAC))
>> +				modulo slave count
>
> 	This seems to be missing an XOR, between the end of "XOR hash)"
> and the start of "(source MAC".
>

You're correct.

>> 	if (skb->protocol == htons(ETH_P_IP)) {
>> +		iph = ip_hdr(skb);
>> 		if (!ip_is_fragment(iph) &&
>> -		    (iph->protocol == IPPROTO_TCP ||
>> -		     iph->protocol == IPPROTO_UDP)) {
>> +			(iph->protocol == IPPROTO_TCP ||
>> +			iph->protocol == IPPROTO_UDP)) {
>
> 	Why did these two lines change?
>

I replaced the mixed tabs and spaces with all tabs when I updated that 
function, but in retrospect the tabs and spaces were likely intentional. 
I will revert.

>> +			layer4hdr = (__be16 *)((u32 *)iph + iph->ihl);
>> +			if (iph->ihl * sizeof(u32) + sizeof(__be16) * 2 >
>> +				skb_headlen(skb) - skb_network_offset(skb))
>> +				goto short_header;
>> 			layer4_xor = ntohs((*layer4hdr ^ *(layer4hdr + 1)));
>> +		} else if (skb_network_header_len(skb) < sizeof(struct iphdr)) {
>> +			goto short_header;
>> 		}
>> -		return (layer4_xor ^
>> -			((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;
>> -
>> +		return (layer4_xor ^ ((ntohl(iph->saddr ^ iph->daddr)) & 0xffff)) % count;
>
> 	This line runs past 80 columns.  There are a few more of these
> further down.
>

I will double-check this.

>> +	} else if (skb->protocol == htons(ETH_P_IPV6)) {
>> +		ipv6h = ipv6_hdr(skb);
>> +		if (ipv6h->nexthdr == IPPROTO_TCP || ipv6h->nexthdr == IPPROTO_UDP) {
>> +			layer4hdr = (__be16 *)((u8 *)ipv6h + sizeof(struct ipv6hdr));
>
> 	Could this be written as
>
> 			layer4hdr = (__be16 *)(ipv6h + 1);
>
> 	instead?
>
> 	-J
>

Yes, I can make that change. Thanks.

John
