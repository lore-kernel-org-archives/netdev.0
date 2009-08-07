From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V2 net-next-2.6] net: relax dst refcnt in input path
Date: Fri, 07 Aug 2009 07:05:38 +0200
Message-ID: <4A7BB622.2070007@gmail.com>
References: <4A670469.2050404@gmail.com>	<4A6708A6.1090200@trash.net>	<4A6732D6.90809@gmail.com> <20090806.133518.263376332.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, netdev@vger.kernel.org, markmc@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49429 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766AbZHGFF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 01:05:59 -0400
In-Reply-To: <20090806.133518.263376332.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 22 Jul 2009 17:40:06 +0200
>=20
>> [PATCH net-next-2.6] net: relax dst refcnt in input path
>=20
>=20
> Two things:
>=20
> 1) Don't use a boolean name like "noref" it results in using
>    double-negatives in one's mind while trying to read and understand
>    the code.
>=20
>    Call these arguments "need_ref" or something like that.
>=20
>    Also, use "bool" type.

Sure

>=20
> 2) I wonder about this:
>=20
>> @@ -1700,9 +1700,15 @@ int dev_hard_start_xmit(struct sk_buff *skb, =
struct net_device *dev,
>>  		 * If device doesnt need skb->dst, release it right now while
>>  		 * its hot in this cpu cache
>>  		 */
>> -		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
>> -			skb_dst_drop(skb);
>> -
>> +		if (skb_dst(skb)) {
>> +			if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
>> +				skb_dst_drop(skb);
>> +			else
>> +				/*
>> +				 * make sure dst was refcounted by caller
>> +				 */
>> +				WARN_ON(!(skb->_skb_dst & SKB_DST_REFTAKEN));
>> +		}
>>  		rc =3D ops->ndo_start_xmit(skb, dev);
>>  		if (rc =3D=3D NETDEV_TX_OK)
>=20
> So, won't this warning trigger if we are forwarding to a device that
> does not set IFF_XMIT_DST_RELEASE?

If this device has a queue, we do a skb_dst_force() in dev_queue_xmit()

>=20
> If I understand things correctly, in IPv4 when we're not delivering t=
o
> a socket, we don't take a reference.

yes, that would be the trick

>=20
> We'll get here from the forwarding path with a DST, and the target TX
> device has IFF_XMIT_DST_RELEASE clear, the WARN_ON above will trigger=
=2E

I added this warning to make sure I called skb_dst_force(skb)
from dev_queue_xmit() if device has a queue (packet might be queued
and thus escape from rcu lock section)

I suppose I should also skb_dst_force() if device has no queue and
has IFF_XMIT_DST_RELEASE cleared. Or should audit all these devices
and insert the skb_dst_force() if the packet must be queued in a driver=
 queue,
and its dst needed later.=20

I'll respin patch anyway since commit bbd8a0d3a3b65d341437f8b99c828fa5c=
c29c739
(net: Avoid enqueuing skb for default qdiscs)
changed too many things, when I'll come back from vacations in two week=
s.

Or if you prefer, I might submit it today (my vacations start tomorrow)=
, but
please dont apply it while I cannot react to any bug report :)

Thanks a lot
