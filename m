From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ifb: RCU locking avoids touching dev refcount
Date: Mon, 02 Nov 2009 22:34:04 +0100
Message-ID: <4AEF504C.7000401@gmail.com>
References: <4AEE71EC.7040208@gmail.com> <4AEF4B9B.7000205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36851 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755517AbZKBVeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 16:34:05 -0500
In-Reply-To: <4AEF4B9B.7000205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> Eric Dumazet wrote, On 11/02/2009 06:45 AM:
>=20
>> Avoids touching dev refcount in hotpath
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> ---
>>  drivers/net/ifb.c |    6 ++++--
>>  1 files changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
>> index 030913f..69c2566 100644
>> --- a/drivers/net/ifb.c
>> +++ b/drivers/net/ifb.c
>> @@ -98,13 +98,15 @@ static void ri_tasklet(unsigned long dev)
>>  		stats->tx_packets++;
>>  		stats->tx_bytes +=3Dskb->len;
>> =20
>> -		skb->dev =3D dev_get_by_index(&init_net, skb->iif);
>> +		rcu_read_lock();
>> +		skb->dev =3D dev_get_by_index_rcu(&init_net, skb->iif);
>>  		if (!skb->dev) {
>> +			rcu_read_unlock();
>>  			dev_kfree_skb(skb);
>>  			stats->tx_dropped++;
>>  			break;
>>  		}
>> -		dev_put(skb->dev);
>> +		rcu_read_unlock();
>=20
> I wonder if this rcu_read_unlock() isn't too early here. I know, it
> functionally fully replaces the old method, but as a whole it looks
> strange:
>=20
>>                 rcu_read_lock();
>>                 skb->dev =3D dev_get_by_index_rcu(&init_net, skb->ii=
f);
>>                 if (!skb->dev) {
>>                         rcu_read_unlock();
>>                         dev_kfree_skb(skb);
>>                         stats->tx_dropped++;
>>                         break;
>>                 }
>>                 rcu_read_unlock();
>>                 skb->iif =3D _dev->ifindex;
>>
>>                 if (from & AT_EGRESS) {
>>                         dp->st_rx_frm_egr++;
>>                         dev_queue_xmit(skb);
>>                 } else if (from & AT_INGRESS) {
>>                         dp->st_rx_frm_ing++;
>>                         skb_pull(skb, skb->dev->hard_header_len);
>=20
>=20
> So, how is skb->dev protected here, above and below? It seems these
> rcu read blocks need extending, don't they?
>=20

Well, this might be true, but we run under tasklet (softirq) with preem=
ption disabled.

We might move rcu_read_unlock() some lines down to not rely on this.
