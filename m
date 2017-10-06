From: Alexey Kodanev <alexey.kodanev@oracle.com>
Subject: Re: [PATCH] ipv6: gso: fix payload length when gso_size is zero
Date: Fri, 6 Oct 2017 15:16:47 +0300
Message-ID: <69f9c96f-e83c-62a7-8294-86a85a77e44d@oracle.com>
References: <1507223207-17557-1-git-send-email-alexey.kodanev@oracle.com>
 <1507229878.2098.56.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "steffen.klassert@secunet.com" <steffen.klassert@secunet.com>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42913 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751901AbdJFMIY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 08:08:24 -0400
In-Reply-To: <1507229878.2098.56.camel@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2017 09:58 PM, Duyck, Alexander H wrote:
> On Thu, 2017-10-05 at 20:06 +0300, Alexey Kodanev wrote:
>> When gso_size reset to zero for the tail segment in skb_segment(), later
>> in ipv6_gso_segment(), we will get incorrect payload_len for that segment.
>> inet_gso_segment() already has a check for gso_size before calculating
>> payload so fixing only IPv6 part.
>>
>> The issue was found with LTP vxlan & gre tests over ixgbe NIC.
>>
>> Fixes: 07b26c9454a2 ("gso: Support partial splitting at the frag_list pointer")
>> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
>> ---
>>  net/ipv6/ip6_offload.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
>> index cdb3728..4a87f94 100644
>> --- a/net/ipv6/ip6_offload.c
>> +++ b/net/ipv6/ip6_offload.c
>> @@ -105,7 +105,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
>>  
>>  	for (skb = segs; skb; skb = skb->next) {
>>  		ipv6h = (struct ipv6hdr *)(skb_mac_header(skb) + nhoff);
>> -		if (gso_partial)
>> +		if (gso_partial && skb_is_gso(skb))
>>  			payload_len = skb_shinfo(skb)->gso_size +
>>  				      SKB_GSO_CB(skb)->data_offset +
>>  				      skb->head - (unsigned char *)(ipv6h + 1);
> So looking over this change it looks good to me. I'm just wondering if
> you have looked at the code in __skb_udp_tunnel_segment or
> gre_gso_segment? It seems like if you needed this change here you
> should need to make similar changes to those functions as well. I'm
> wondering if we just aren't seeing issues due to the segments already
> being MSS sized before being handed to us for segmentation.

Right, it can happen in __skb_udp_tunnel_segment as well. I wasn't able
to reproduce with gre, it looks like it doesn't go to that part of code,
skipping it, possibly, on gso_type & SKB_GSO_GRE_CSUM check, though the
NIC has tx-gre-csum-segmentation enabled...

I'll send new version after testing completed.

Thanks,
Alexey
