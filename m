From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH net-next 8/8] 8021q: Check return of dev_set_promiscuity/allmulti
Date: Fri, 20 Jun 2008 18:02:02 +0800
Message-ID: <485B801A.6090703@cn.fujitsu.com>
References: <485B001F.1070407@cn.fujitsu.com> <485B7C98.80302@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64695 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754065AbYFTKGD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2008 06:06:03 -0400
In-Reply-To: <485B7C98.80302@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy said the following on 2008-6-20 17:47:
> Wang Chen wrote:
>> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
>> index 5d055c2..1f2669b 100644
>> --- a/net/8021q/vlan_dev.c
>> +++ b/net/8021q/vlan_dev.c
>> @@ -547,12 +547,23 @@ static int vlan_dev_open(struct net_device *dev)
>>      }
>>      memcpy(vlan->real_dev_addr, real_dev->dev_addr, ETH_ALEN);
>>  
>> -    if (dev->flags & IFF_ALLMULTI)
>> -        dev_set_allmulti(real_dev, 1);
>> -    if (dev->flags & IFF_PROMISC)
>> -        dev_set_promiscuity(real_dev, 1);
>> +    if (dev->flags & IFF_ALLMULTI) {
>> +        err = dev_set_allmulti(real_dev, 1);
>> +        if (err < 0)
>> +            goto out;
>> +    }
>> +    if (dev->flags & IFF_PROMISC) {
>> +        err = dev_set_promiscuity(real_dev, 1);
>> +        if (err < 0)
>> +            goto out;
>> +    }
>>  
>>      return 0;
>> +
>> +out:
>> +    if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
>> +        dev_unicast_delete(real_dev, dev->dev_addr, dev->addr_len);
>> +    return err;
> 
> This doesn't undo the operations that already succeeded.
> 

Why?
Should I do
 	dev_mc_unsync(real_dev, dev);
	dev_unicast_unsync(real_dev, dev);
before dev_unicast_delete()?

