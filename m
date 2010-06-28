From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [RFC][BUG-FIX] the problem of checksum checking in UDP protocol
Date: Mon, 28 Jun 2010 18:49:36 +0800
Message-ID: <4C287E40.40906@cn.fujitsu.com>
References: <4C19E634.3030703@cn.fujitsu.com> <1277530086.2481.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Ronciak, John" <john.ronciak@intel.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53758 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751589Ab0F1KvU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jun 2010 06:51:20 -0400
In-Reply-To: <1277530086.2481.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote, at 06/26/2010 01:28 PM:
>> (This patch is not complete, it's just for my idea.)
>> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
>> index 1dd1aff..47f7e86 100644
>> --- a/net/ipv6/udp.c
>> +++ b/net/ipv6/udp.c
>> @@ -723,6 +723,10 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
>>                 if (ulen < skb->len) {
>>                         if (pskb_trim_rcsum(skb, ulen))
>>                                 goto short_packet;
>> +
>> +                       if (skb_csum_unnecessary(skb))
>> +                               skb->ip_summed = CHECKSUM_NONE;
>> +
>>                         saddr = &ipv6_hdr(skb)->saddr;
>>                         daddr = &ipv6_hdr(skb)->daddr;
>>                         uh = udp_hdr(skb);
>>
> 
> I really dont know if this fix is the right one.
> 
> pskb_trim_rcsum() already contains a check. Should this check be changed
> to include yours ?

Oh..... I don't think so.
pskb_trim_rcsum() is also used when IPv4/IPv6 protocol receiving packets
and reassembling fragments. IP protocol does the right check and should
trust CHECKSUM_UNNECESSARY flag that drivers set, So we no need to 
change IP protocol.
If we add the skb_csum_unnecessary(skb) check into pskb_trim_rcsum() and
reset ip_summed with CHECKSUM_NONE, the checksum check that NIC hardward 
has done is wasted.

Only for UDP protocol over IPv4/IPv6, and length parameter is lower than
skb->len, We reset ip_summed with CHECKSUM_NONE.


-- 
Best Regards
-----
Shan Wei

