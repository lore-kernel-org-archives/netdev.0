From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: net/arp: ARP cache aging failed.
Date: Wed, 23 Nov 2016 15:37:57 +0100
Message-ID: <250d3a88-45ad-891f-389a-997f39d7bdad@stressinduktion.org>
References: <957c2a80-7302-1ce9-726e-1e7512a941f4@huawei.com>
 <alpine.LFD.2.11.1611230928140.1659@ja.home.ssi.bg>
 <1479902729.8455.479.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: yuehaibing <yuehaibing@huawei.com>, davem@davemloft.net,
        netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>, Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:44896 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S964992AbcKWOsg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 09:48:36 -0500
In-Reply-To: <1479902729.8455.479.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23.11.2016 13:05, Eric Dumazet wrote:
> On Wed, 2016-11-23 at 10:33 +0200, Julian Anastasov wrote:
>> 	Hello,
>>
>> On Wed, 23 Nov 2016, yuehaibing wrote:
>>
>>> 	As to my topo,HOST1 and HOST3 share one route on HOST2, tcp connection between HOST2 and HOST3 may call tcp_ack to set dst->pending_confirm.
>>> 	
>>> So dst_neigh_output may wrongly freshed  n->confirmed which stands for HOST1,however HOST1'MAC had been changed.
>>>
>>> 	The possibility of this occurred Significantly increases ,when ping and TCP transaction are set the same processor affinity on the HOST2.
>>>
>>> 	It seems that the issue is brought in commit 5110effee8fde2edfacac9cd12a9960ab2dc39ea ("net: Do delayed neigh confirmation.").
>>
>> 	Bad news. Problem is not in delayed confirmation but
>> in the mechanism to use same dst for different neighbours on
>> LAN. We don't have a dst->neighbour reference anymore.
>>
>> 	For IPv4 this is related to rt->rt_uses_gateway but
>> also to DST_NOCACHE. In the other cases we can not call
>> dst_confirm, may be we should lookup the neigh entry instead.
>> But we need a way to reduce such lookups on every packet,
>> for example, by remembering in struct sock and checking if
>> some bits of jiffies (at least 4-5) are changed from
>> previous lookup.
> 
> 
> I thought bonding would keep the MAC address 'alive'.

I wonder about this, too.

> If TCP packets are confirmed, this means the old MAC address is still
> valid, what am I missing here ?

Irregardless about the question if bonding should keep the MAC address
alive, a MAC address can certainly change below a TCP connection.

dst_entry is 1:n to neigh_entry and as such we can end up confirming an
aging neighbor while sending a reply with dst->pending_confirm set while
the confirming packet actually came from a different neighbor.

I agree with Julian, pending_confirm became useless in this way.

Bye,
Hannes
