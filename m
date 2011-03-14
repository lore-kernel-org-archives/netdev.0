From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH][v2] dev : fix mtu check when TSO is enabled
Date: Mon, 14 Mar 2011 21:07:25 +0100
Message-ID: <4D7E757D.6090106@free.fr>
References: <1300129859-9525-1-git-send-email-daniel.lezcano@free.fr> <1300132932.2649.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kaber@trash.net, nightnord@gmail.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:55066 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751813Ab1CNUHk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 16:07:40 -0400
In-Reply-To: <1300132932.2649.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/14/2011 09:02 PM, Eric Dumazet wrote:
> Le lundi 14 mars 2011 =C3=A0 20:10 +0100, Daniel Lezcano a =C3=A9crit=
 :
>> In case the device where is coming from the packet has TSO enabled,
>> we should not check the mtu size value as this one could be bigger
>> than the expected value.
>>
>> This is the case for the macvlan driver when the lower device has
>> TSO enabled. The macvlan inherit this feature and forward the packet=
s
>> without fragmenting them. Then the packets go through dev_forward_sk=
b
>> and are dropped. This patch fix this by checking TSO is not enabled
>> when we want to check the mtu size.
>>
>> Signed-off-by: Daniel Lezcano<daniel.lezcano@free.fr>
>> Cc: Eric Dumazet<eric.dumazet@gmail.com>
>> Cc: Patrick McHardy<kaber@trash.net>
>> Cc: Andrian Nord<nightnord@gmail.com>
>> ---
>>   net/core/dev.c |   24 ++++++++++++++++++++++--
>>   1 files changed, 22 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 6561021..f1607a0 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -1503,6 +1503,27 @@ static inline void net_timestamp_check(struct=
 sk_buff *skb)
>>   		__net_timestamp(skb);
>>   }
>>
>> +static inline bool is_skb_forwardable(struct net_device *dev,
>> +				      struct sk_buff *skb)
>> +{
>> +	unsigned int len;
>> +
>> +	if (!dev->flags&  IFF_UP)
>> +		return false;
> 	if (!(dev->flags&  IFF_UP))
> 		return false;

Argh ! Hopefully you saw it.

>> +
>> +	/* we should not check the mtu size if TSO is enabled otherwise
>> +	 * we may have a packet with a length bigger than the expected
>> +	 * one as it was not segmented before */
>> +	if (skb->dev&&  skb->dev->features&  NETIF_F_TSO)
>> +		return true;
>> +
>> +	len =3D dev->mtu + dev->hard_header_len + VLAN_HLEN;
>> +	if (skb->len>  len)
>> +		return false;
>> +
> I suggest you reorder tests so that the first one is discriminant mos=
t
> of the time
>
> 	maxlen =3D dev->mtu + dev->hard_header_len + VLAN_HLEN;
> 	if (skb->len<  maxlen)
> 		return true;
> =09
> 	if (skb->dev&&  skb->dev->features&  NETIF_F_TSO)
> 		return true;
>
> 	return false;

Ok. Thanks !

   -- Daniel

