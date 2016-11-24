From: YueHaibing <yuehaibing@huawei.com>
Subject: Re: net/arp: ARP cache aging failed.
Date: Thu, 24 Nov 2016 17:06:04 +0800
Message-ID: <c82b7b44-c0ad-9ee7-1114-3eae3b5cf75a@huawei.com>
References: <957c2a80-7302-1ce9-726e-1e7512a941f4@huawei.com>
 <alpine.LFD.2.11.1611230928140.1659@ja.home.ssi.bg>
 <1479902729.8455.479.camel@edumazet-glaptop3.roam.corp.google.com>
 <250d3a88-45ad-891f-389a-997f39d7bdad@stressinduktion.org>
 <1479944967.8455.516.camel@edumazet-glaptop3.roam.corp.google.com>
 <alpine.LFD.2.11.1611240931560.1685@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:40734 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933142AbcKXJIh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 04:08:37 -0500
In-Reply-To: <alpine.LFD.2.11.1611240931560.1685@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/11/24 15:51, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Wed, 23 Nov 2016, Eric Dumazet wrote:
> 
>> On Wed, 2016-11-23 at 15:37 +0100, Hannes Frederic Sowa wrote:
>>
>>> Irregardless about the question if bonding should keep the MAC address
>>> alive, a MAC address can certainly change below a TCP connection.
>>
>> Of course ;)
>>

I configured bonding fail_over_mac=1 ,so the bonding MAC always be the MAC
address of the currently active slave.

>>>
>>> dst_entry is 1:n to neigh_entry and as such we can end up confirming an
>>> aging neighbor while sending a reply with dst->pending_confirm set while
>>> the confirming packet actually came from a different neighbor.
>>>
>>> I agree with Julian, pending_confirm became useless in this way.
>>
>> Let's kill it then ;)
> 
> 	It works for traffic via gateway. I now see that
> we can even avoid write in dst_confirm:
> 
> 	if (!dst->pending_confirm)
> 		dst->pending_confirm = 1;
> 
> 	because it is called by non-dup TCP ACKs.
> 
> 	But for traffic to hosts on LAN we need different solution,
> i.e. for cached dsts with rt_gateway = 0 (last entry below).
> 
> rt_uses_gateway rt_gateway DST_NOCACHE Description
> ====================================================================
> 1               nh_gw      ANY         Traffic via gateway
> 0               LAN_host   1           FLOWI_FLAG_KNOWN_NH (nexthop
>                                        set by IPVS, hdrincl, xt_TEE)
> 0               0          0           1 dst for many subnet hosts
> 
> Regards
> 
> --
> Julian Anastasov <ja@ssi.bg>
> 
> .
> 

As above,Is there a plan to fix the problem ? Should we just not call dst_confirm
when in the case rt->rt_uses_gateway/DST_NOCACHE?
