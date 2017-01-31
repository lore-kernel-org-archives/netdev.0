From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next] mpls: allow TTL propagation to/from IP packets
 to be configured
Date: Tue, 31 Jan 2017 12:01:17 +0000
Message-ID: <246db51e-1e78-8020-27aa-1707586aa860@brocade.com>
References: <1485808575-16852-1-git-send-email-rshearma@brocade.com>
 <8e29e6cc-c612-976a-b819-c9ddb8d5c27a@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
        <ebiederm@xmission.com>
To: David Ahern <dsa@cumulusnetworks.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37092 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751841AbdAaMBc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 07:01:32 -0500
In-Reply-To: <8e29e6cc-c612-976a-b819-c9ddb8d5c27a@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31/01/17 01:09, David Ahern wrote:
> On 1/30/17 1:36 PM, Robert Shearman wrote:
>> @@ -243,24 +245,29 @@ static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
>>  		payload_type = ip_hdr(skb)->version;
>>
>>  	switch (payload_type) {
>> -	case MPT_IPV4: {
>> -		struct iphdr *hdr4 = ip_hdr(skb);
>> -		skb->protocol = htons(ETH_P_IP);
>> -		csum_replace2(&hdr4->check,
>> -			      htons(hdr4->ttl << 8),
>> -			      htons(dec.ttl << 8));
>> -		hdr4->ttl = dec.ttl;
>> +	case MPT_IPV4:
>> +		if (net->mpls.ip_ttl_propagate) {
>> +			struct iphdr *hdr4 = ip_hdr(skb);
>> +
>> +			skb->protocol = htons(ETH_P_IP);
>
> The protocol setting here and ...
>
>> +			csum_replace2(&hdr4->check,
>> +				      htons(hdr4->ttl << 8),
>> +				      htons(dec.ttl << 8));
>> +			hdr4->ttl = dec.ttl;
>> +		}
>>  		success = true;
>>  		break;
>> -	}
>> -	case MPT_IPV6: {
>> -		struct ipv6hdr *hdr6 = ipv6_hdr(skb);
>> -		skb->protocol = htons(ETH_P_IPV6);
>> -		hdr6->hop_limit = dec.ttl;
>> +	case MPT_IPV6:
>> +		if (net->mpls.ip_ttl_propagate) {
>> +			struct ipv6hdr *hdr6 = ipv6_hdr(skb);
>> +
>> +			skb->protocol = htons(ETH_P_IPV6);
>
> here need to be done outside of net->mpls.ip_ttl_propagate otherwise ...
>
>> +			hdr6->hop_limit = dec.ttl;
>> +		}
>>  		success = true;
>>  		break;
>> -	}
>>  	case MPT_UNSPEC:
>> +		/* Should have decided which protocol it is by now */
>>  		break;
>>  	}
>>
>
> disabling ip_ttl_propagate causes a corrupted packet to show up at the end host (after the LSP):

Oops, good catch. Will fix in v2.

Thanks,
Rob
