From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: Re: [PATCH] net: take care of bonding in build_skb_flow_key (v3)
Date: Thu, 21 Jan 2016 13:15:43 +0800
Message-ID: <56A0697F.9030703@oracle.com>
References: <1453267933-25381-1-git-send-email-wen.gang.wang@oracle.com>
 <20160120151820.GA1765@bistromath.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jay.vosburgh@canonical.com
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:29333 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbcAUFM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 00:12:27 -0500
In-Reply-To: <20160120151820.GA1765@bistromath.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



=E5=9C=A8 2016=E5=B9=B401=E6=9C=8820=E6=97=A5 23:18, Sabrina Dubroca =E5=
=86=99=E9=81=93:
> 2016-01-20, 13:32:13 +0800, Wengang Wang wrote:
>> In a bonding setting, we determines fragment size according to MTU a=
nd
>> PMTU associated to the bonding master. If the slave finds the fragme=
nt
>> size is too big, it drops the fragment and calls ip_rt_update_pmtu()=
,
>> passing _skb_ and _pmtu_, trying to update the path MTU.
>> Problem is that the target device that function ip_rt_update_pmtu ac=
tually
>> tries to update is the slave (skb->dev), not the master. Thus since =
no
>> PMTU change happens on master, the fragment size for later packets d=
oesn't
>> change so all later fragments/packets are dropped too.
>>
>> The fix is letting build_skb_flow_key() take care of the transition =
of
>> device index from bonding slave to the master. That makes the master=
 become
>> the target device that ip_rt_update_pmtu tries to update PMTU to.
>>
>> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
>> ---
>>   net/ipv4/route.c | 13 ++++++++++++-
>>   1 file changed, 12 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>> index 85f184e..c59fb0d 100644
>> --- a/net/ipv4/route.c
>> +++ b/net/ipv4/route.c
>> @@ -523,10 +523,21 @@ static void build_skb_flow_key(struct flowi4 *=
fl4, const struct sk_buff *skb,
>>   			       const struct sock *sk)
>>   {
>>   	const struct iphdr *iph =3D ip_hdr(skb);
>> -	int oif =3D skb->dev->ifindex;
>> +	struct net_device *master =3D NULL;
>>   	u8 tos =3D RT_TOS(iph->tos);
>>   	u8 prot =3D iph->protocol;
>>   	u32 mark =3D skb->mark;
>> +	int oif;
>> +
>> +	if (skb->dev->flags & IFF_SLAVE) {
> Maybe use netif_is_bond_slave here instead, since you have this
> problem with bonding slaves?
>
>
>> +		rtnl_lock();
>> +		master =3D netdev_master_upper_dev_get(skb->dev);
>> +		rtnl_unlock();
>> +	}
> As zhuyj said, this is called from dev_queue_xmit, so you cannot take
> rtnl_lock here.
>
>> +	if (master)
>> +		oif =3D master->ifindex;
> You cannot dereference master after you release the rtnl lock.
>
> So it would probably be best to use netdev_master_upper_dev_get_rcu,
> as zhuyj suggested earlier, and make sure that you only use the resul=
t
> between rcu_read_lock()/rcu_read_unlock():
>
>      rcu_read_lock();
>      master =3D netdev_master_upper_dev_get_rcu(skb->dev);
>      if (master)
>          oif =3D master->ifindex;
>      rcu_read_unlock();
>
OK, thanks for advising.

thanks,
wengang

> Thanks,
>
