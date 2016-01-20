From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: Re: [PATCH] net: take care of bonding in build_skb_flow_key (v2)
Date: Wed, 20 Jan 2016 12:56:44 +0800
Message-ID: <569F138C.5030102@oracle.com>
References: <1452070997-10395-1-git-send-email-wen.gang.wang@oracle.com>
 <12940.1452630168@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=gbk;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:50003 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869AbcATFXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 00:23:38 -0500
In-Reply-To: <12940.1452630168@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



=D4=DA 2016=C4=EA01=D4=C213=C8=D5 04:22, Jay Vosburgh =D0=B4=B5=C0:
> Wengang Wang <wen.gang.wang@oracle.com> wrote:
>
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
> 	Does the team driver have the equivalent issue?
I didn't make a test for team. It can be separated fix for team in case=
=20
it needs.

>> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
>> ---
>> net/ipv4/route.c | 10 +++++++++-
>> 1 file changed, 9 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>> index 85f184e..fffc7e6 100644
>> --- a/net/ipv4/route.c
>> +++ b/net/ipv4/route.c
>> @@ -523,10 +523,18 @@ static void build_skb_flow_key(struct flowi4 *=
fl4, const struct sk_buff *skb,
>> 			       const struct sock *sk)
>> {
>> 	const struct iphdr *iph =3D ip_hdr(skb);
>> -	int oif =3D skb->dev->ifindex;
>> 	u8 tos =3D RT_TOS(iph->tos);
>> +	struct net_device *master;
>> 	u8 prot =3D iph->protocol;
>> 	u32 mark =3D skb->mark;
>> +	int oif;
>> +
>> +	if (skb->dev->flags & IFF_SLAVE) {
>> +		master =3D netdev_master_upper_dev_get(skb->dev);
>> +		oif =3D master->ifindex;
>> +	} else {
>> +		oif =3D skb->dev->ifindex;
>> +	}
> 	netdev_master_upper_dev_get() requires RTNL to be held; I don't
> see that all callers to build_skb_flow_key will do so.
Yep, it needs a rtnl_lock/rtnl_unlock pair.
> 	I also believe the above would dereference a NULL pointer if an
> eql device is configured, as it uses IFF_SLAVE but doesn't use the
> upper/lower device infrastructure, thus, netdev_master_upper_dev_get(=
)
> would likely return NULL for eql.

I would like to think it's misuse for eql if what you said is true :)
Well, anyway I will send a v3 taking care of this too.

thanks,
wengang

>
> 	-J
>
> ---
> 	-Jay Vosburgh, jay.vosburgh@canonical.com
