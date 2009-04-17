From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] loopback: better handling of packet drops
Date: Fri, 17 Apr 2009 17:05:42 +0200
Message-ID: <49E89AC6.80409@cosmosbay.com>
References: <49E78DE5.10104@hartkopp.net>	<20090417.013853.04495551.davem@davemloft.net>	<49E84459.1060507@cosmosbay.com>	<20090417.015914.09817926.davem@davemloft.net>	<49E84B99.1080502@cosmosbay.com>	<49E854A4.1010204@cosmosbay.com>	<49E85AFD.6080407@cosmosbay.com> <20090417075801.2f9fe64e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54890 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754586AbZDQPFu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 11:05:50 -0400
In-Reply-To: <20090417075801.2f9fe64e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =C3=A9crit :
> On Fri, 17 Apr 2009 12:33:33 +0200
> Eric Dumazet <dada1@cosmosbay.com> wrote:
>>  static int loopback_xmit(struct sk_buff *skb, struct net_device *de=
v)
>>  {
>>  	struct pcpu_lstats *pcpu_lstats, *lb_stats;
>> +	int len;
>> =20
>>  	skb_orphan(skb);
>> =20
>> -	skb->protocol =3D eth_type_trans(skb,dev);
>> +	skb->protocol =3D eth_type_trans(skb, dev);
>> =20
>>  	/* it's OK to use per_cpu_ptr() because BHs are off */
>>  	pcpu_lstats =3D dev->ml_priv;
>>  	lb_stats =3D per_cpu_ptr(pcpu_lstats, smp_processor_id());
>> -	lb_stats->bytes +=3D skb->len;
>> -	lb_stats->packets++;
>> =20
>> -	netif_rx(skb);
>> +	len =3D skb->len;
>> +	if (likely(__netif_rx(skb) =3D=3D NET_RX_SUCCESS)) {
>> +		lb_stats->bytes +=3D len;
>> +		lb_stats->packets++;
>> +		return NETDEV_TX_OK;
>> +	}
>> +	lb_stats->drops++;
>> =20
>> -	return 0;
>> +	return NETDEV_TX_BUSY;
>>  }
>=20
> If you return NETDEV_TX_BUSY, then the xmit logic will retry
> so it is not really a drop but a stall. I think it is confusing
> to call this a packet loss.

Good point, thanks.
So we should not account this stall in dev stats ? Maybe in 'collisions=
' ?

I also discovered we had to do
skb_push(skb, ETH_HLEN); /* undo the skb_pull() done in eth_type_trans(=
) */
before returning NETDEV_TX_BUSY;


