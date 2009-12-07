From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] bonding: allow arp_ip_targets to be on a
 separate vlan from bond device
Date: Mon, 07 Dec 2009 19:24:57 +0100
Message-ID: <4B1D4879.3040809@gmail.com>
References: <20091130201453.GF1639@gospo.rdu.redhat.com> <29892.1259625638@death.nxdomain.ibm.com> <20091201012145.GH1639@gospo.rdu.redhat.com> <6611.1259632635@death.nxdomain.ibm.com> <20091201144410.GI1639@gospo.rdu.redhat.com> <21331.1259702893@death.nxdomain.ibm.com> <20091202212449.GL1639@gospo.rdu.redhat.com> <20091207181349.GN1639@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40802 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758017AbZLGSY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 13:24:59 -0500
In-Reply-To: <20091207181349.GN1639@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek a =E9crit :

>> Jay,
>>
>> The issue was that that orig_dev was getting set to the active slave=
, so
>> your running tcpdump on the active slave made the conditional inside
>> this loop:
>>
>>         list_for_each_entry_rcu(ptype, &ptype_all, list) {
>>                 if (ptype->dev =3D=3D null_or_orig || ptype->dev =3D=
=3D skb->dev ||
>>                     ptype->dev =3D=3D orig_dev) {
>>                         if (pt_prev)
>>                                 ret =3D deliver_skb(skb, pt_prev, or=
ig_dev);
>>                         pt_prev =3D ptype;
>>                 }
>>         }
>>
>> hit and deliver_skb was being called for all traffic coming toward
>> bond0.<vid>.  I'm not completely happy with this solutoin, but I thi=
nk
>> it resolves both the original problem I was trying to solve and the
>> regression you discovered with your original patch.  Let me know if =
you
>> see everything working now like I do.
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/b=
ond_main.c
>> index 726bd75..b1e3b2f 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -2697,6 +2697,19 @@ static int bond_arp_rcv(struct sk_buff *skb, =
struct net_device *dev, struct pack
>>  	bond =3D netdev_priv(dev);
>>  	read_lock(&bond->lock);
>> =20
>> +	/*
>> +	 * We may have dev passed in as a vlan device, so make sure to get=
 to the
>> +	 * core netdev before continuing.
>> +	 */
>> +	if (dev->priv_flags & IFF_802_1Q_VLAN) {
>> +		dev =3D vlan_dev_real_dev(dev);
>> +		/*
>> +		 * Don't necessarily trust passed in orig_dev since vlan accelera=
ted
>> +		 * netdevs and bonding don't play well together.
>> +		 */
>> +		orig_dev =3D __dev_get_by_index(dev_net(skb->dev),skb->skb_iif);
>> +	}
>> +

>=20
> Any thoughts on the updated patch, Jay?

Unfortunately you still use __dev_get_by_index()
in a non safe context.

