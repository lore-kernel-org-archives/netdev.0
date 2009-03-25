From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] net: release dst entry in dev_queue_xmit()
Date: Wed, 25 Mar 2009 20:40:05 +0100
Message-ID: <49CA8895.8020105@cosmosbay.com>
References: <49C380A6.4000904@cosmosbay.com> <20090324.234354.43714160.davem@davemloft.net> <49C9D99A.2040900@cosmosbay.com> <20090325.001720.238121238.davem@davemloft.net> <49CA7658.4010400@gmail.com> <49CA7AD7.8040401@cosmosbay.com> <20090325191850.GA2928@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51032 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752599AbZCYTkP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 15:40:15 -0400
In-Reply-To: <20090325191850.GA2928@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On Wed, Mar 25, 2009 at 07:41:27PM +0100, Eric Dumazet wrote:
>> Jarek Poplawski a =E9crit :
>>> David Miller wrote, On 03/25/2009 08:17 AM:
>>>
>>>> From: Eric Dumazet <dada1@cosmosbay.com>
>>>> Date: Wed, 25 Mar 2009 08:13:30 +0100
>>>>
>>>>> If done in dev_hard_start_xmit(), skb could be requeued (because =
of
>>>>> NETDEV_TX_BUSY).  Then if requeued, maybe at this time, dst being
>>>>> NULL is not a problem ?
>>>> Usually it should be OK because the packet schedulers have
>>>> a sort-of one-behind state that allows them to reinsert
>>>> the SKB into their queue datastructures without reclassifying.
>>>
>>> Actually, since David has dumped requeuing there is no reinserting;
>>> this last one "requeued" skb is buffered at the top in q->gso_skb
>>> and waiting for better times.
>> Yes indeed, this is what I thought too, thanks Jarek.
>=20
> Alas I'm a bit concerned with virtual devs, e.g. now I'm looking at
> xmits in macvlan and pppoe. Maybe this patch should exclude them?
>=20

Yes, MACVLAN :) its macvlan_start_xmit() function calls
dev_queue_xmit(skb) again, so we go back to packet schedulers and
classifiers, they might need dst again :(

Only other potential problem I found was in=20
drivers/net/appletalk/ipddp.c

static int ipddp_xmit(struct sk_buff *skb, struct net_device *dev)
{
__be32 paddr =3D ((struct rtable*)skb->dst)->rt_gateway;

Not sure this driver is still supported, or if this paddr can be found =
elsewhere...
 __sk_dst_get(skb->sk) ???

