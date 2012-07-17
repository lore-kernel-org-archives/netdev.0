From: Zhong Hongbo <hongbo.zhong@windriver.com>
Subject: Re: [PATCH 1/4] pch_gbe: Fix the checksum fill to the error location
Date: Tue, 17 Jul 2012 16:04:19 +0800
Message-ID: <50051C83.7020504@windriver.com>
References: <40680C535D6FE6498883F1640FACD44D011432D4@ka-exchange-1.kontronamerica.local> <1342508968.2626.148.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Cress <andy.cress@us.kontron.com>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:58021 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891Ab2GQIEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 04:04:12 -0400
In-Reply-To: <1342508968.2626.148.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/17/2012 03:09 PM, Eric Dumazet wrote:
> On Mon, 2012-07-16 at 13:03 -0700, Andy Cress wrote:
>> Author: Zhong Hongbo <hongbo.zhong@windriver.com>
>>
>> Due to some unknown hardware limitations the pch_gbe hardware cannot
>> calculate checksums when the length of network package is less
>> than 64 bytes, where we will surprisingly encounter a problem of
>> the destination IP incorrectly changed.
>>
>> When forwarding network packages at the network layer the IP packages
>> won't be relayed to the upper transport layer and analyzed there,
>> consequently, skb->transport_header pointer will be mistakenly remained
>> the same as that of skb->network_header, resulting in TCP checksum
>> wrongly
>> filled into the field of destination IP in IP header.
>>
>> We can fix this issue by manually calculate the offset of the TCP
>> checksum
>>  and update it accordingly.
>>
>> We would normally use the skb_checksum_start_offset(skb) here, but in
>> this
>> case it is sometimes -2 (csum_start=0 - skb_headroom=2 => -2), hence the
>> manual calculation.
>>
>> Signed-off-by: Zhong Hongbo <hongbo.zhong@windriver.com>
>> Merged-by: Andy Cress <andy.cress@us.kontron.com>
>
> Hmm... I fail to understand why you care about NIC doing checksums,

Hi Eric,

When forwarding network packages at the network layer, the variable value of skb->transport_header is unknown. In my test, the variable value of skb->transport_header is equal to skb->network_header. So When you count the checksum as following:

offset = skb_transport_offset(skb);

skb->csum = skb_checksum(skb, offset, skb->len - offset, 0);
We should only count the TCP checksum, But it maybe include IP part.

tcp_hdr(skb)->check = csum_tcpudp_magic(iph->saddr, iph->daddr, skb->len - offset, IPPROTO_TCP, skb->csum);
We should fill the checksum in TCP package, But maybe fill it in other location and cover the useful information, such as source ip.

So We should count the TCP checksum and fill it in the correct location. Or else the forwarding network package will be drop for the error checksum.


> while pch_gbe_tx_queue() make a _copy_ of each outgoing
> packets.
>
> There _must_ be a way to avoid most of these copies (ie not touching
> payload), only mess with the header to insert these 2 nul bytes ?

This is other fix, my patch just fix checksum error issue.

Thanks,
hongbo

>
> /* [Header:14][payload] ---> [Header:14][paddong:2][payload]    */
>
> So at device setup : dev->needed_headroom = 2;
>
> and in xmit,
>
> 	if (skb_headroom(skb) < 2) {
> 		struct sk_buff *skb_new;
>
> 		skb_new = skb_realloc_headroom(skb, 2);
> 		if (!skb_new) { handle error }
> 		consume_skb(skb);
> 		skb = skb_new;
> 	}
> 	ptr = skb_push(skb, 2);
> 	memmove(ptr, ptr + 2, ETH_HLEN);
> 	ptr[ETH_HLEN] = 0;
> 	ptr[ETH_HLEN + 1] = 0;
>
>
>
>
>
