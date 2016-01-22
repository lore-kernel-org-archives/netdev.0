From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: Re: [PATCH] net: take care of bonding in build_skb_flow_key (v4)
Date: Fri, 22 Jan 2016 12:21:28 +0800
Message-ID: <56A1AE48.4000908@oracle.com>
References: <1453354378-3018-1-git-send-email-wen.gang.wang@oracle.com>
 <20160121083506.GA2251@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sd@queasysnail.net,
	jay.vosburgh@canonical.com, zyjzyj2000@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:37075 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897AbcAVESS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 23:18:18 -0500
In-Reply-To: <20160121083506.GA2251@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



=E5=9C=A8 2016=E5=B9=B401=E6=9C=8821=E6=97=A5 16:35, Jiri Pirko =E5=86=99=
=E9=81=93:
> Thu, Jan 21, 2016 at 06:32:58AM CET, wen.gang.wang@oracle.com wrote:
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
>> net/ipv4/route.c | 9 +++++++++
>> 1 file changed, 9 insertions(+)
>>
>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>> index 85f184e..7e766b5 100644
>> --- a/net/ipv4/route.c
>> +++ b/net/ipv4/route.c
>> @@ -524,10 +524,19 @@ static void build_skb_flow_key(struct flowi4 *=
fl4, const struct sk_buff *skb,
>> {
>> 	const struct iphdr *iph =3D ip_hdr(skb);
>> 	int oif =3D skb->dev->ifindex;
>> +	struct net_device *master;
>> 	u8 tos =3D RT_TOS(iph->tos);
>> 	u8 prot =3D iph->protocol;
>> 	u32 mark =3D skb->mark;
>>
>> +	if (netif_is_bond_slave(skb->dev)) {
>> +		rcu_read_lock();
>> +		master =3D netdev_master_upper_dev_get_rcu(skb->dev);
>> +		if (master)
>> +			oif =3D master->ifindex;
>> +		rcu_read_unlock();
>> +	}
> This is certainly not correct as it should not be bond-specific but
> rather generic.

Then what you would suggest to fix it?
> Note that you may have bond over bond or bridge over
> bond or other scenarios, which this patch ignores.
I don't think bond over bond is a good configuration. Do you have a rea=
l=20
use case for that configuration?

thanks,
wengang
