From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH] net: take care of bonding in build_skb_flow_key (v3)
Date: Wed, 20 Jan 2016 14:29:40 +0800
Message-ID: <569F2954.9080103@gmail.com>
References: <1453267933-25381-1-git-send-email-wen.gang.wang@oracle.com>
 <569F2806.70608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jay.vosburgh@canonical.com
To: Wengang Wang <wen.gang.wang@oracle.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36775 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbcATG3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 01:29:13 -0500
Received: by mail-pa0-f52.google.com with SMTP id yy13so372092416pab.3
        for <netdev@vger.kernel.org>; Tue, 19 Jan 2016 22:29:13 -0800 (PST)
In-Reply-To: <569F2806.70608@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/20/2016 02:24 PM, zhuyj wrote:
> On 01/20/2016 01:32 PM, Wengang Wang wrote:
>> In a bonding setting, we determines fragment size according to MTU and
>> PMTU associated to the bonding master. If the slave finds the fragment
>> size is too big, it drops the fragment and calls ip_rt_update_pmtu(),
>> passing _skb_ and _pmtu_, trying to update the path MTU.
>> Problem is that the target device that function ip_rt_update_pmtu 
>> actually
>> tries to update is the slave (skb->dev), not the master. Thus since no
>> PMTU change happens on master, the fragment size for later packets 
>> doesn't
>> change so all later fragments/packets are dropped too.
>>
>> The fix is letting build_skb_flow_key() take care of the transition of
>> device index from bonding slave to the master. That makes the master 
>> become
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
>> @@ -523,10 +523,21 @@ static void build_skb_flow_key(struct flowi4 
>> *fl4, const struct sk_buff *skb,
>>                      const struct sock *sk)
>>   {
>>       const struct iphdr *iph = ip_hdr(skb);
>> -    int oif = skb->dev->ifindex;
>> +    struct net_device *master = NULL;
>>       u8 tos = RT_TOS(iph->tos);
>>       u8 prot = iph->protocol;
>>       u32 mark = skb->mark;
>> +    int oif;
>> +
>> +    if (skb->dev->flags & IFF_SLAVE) {
>> +        rtnl_lock();
>> +        master = netdev_master_upper_dev_get(skb->dev);
>> +        rtnl_unlock();
> update_pmtu is called very frequently. Is it appropriate to use 
> rtnl_lock here?
> That is, rtnl_lock is called frequently. Maybe other functions have 
> little chance to call rtnl_lock.

Maybe this function netdev_upper_get_next_dev_rcu is better? I am not sure.

>
> Best Regards!
> Zhu Yanjun
>> +    }
>> +    if (master)
>> +        oif = master->ifindex;
>> +    else
>> +        oif = skb->dev->ifindex;
>>         __build_flow_key(fl4, sk, iph, oif, tos, prot, mark, 0);
>>   }
>
