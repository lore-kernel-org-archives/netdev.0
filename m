From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH net-next 8/8] 8021q: Check return of dev_set_promiscuity/allmulti
Date: Fri, 20 Jun 2008 23:08:44 +0800
Message-ID: <485BC7FC.1090005@cn.fujitsu.com>
References: <485B001F.1070407@cn.fujitsu.com> <485B7C98.80302@trash.net> <485B801A.6090703@cn.fujitsu.com> <485B81B7.2020000@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62135 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756130AbYFTPMn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2008 11:12:43 -0400
In-Reply-To: <485B81B7.2020000@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy said the following on 2008-6-20 18:08:
> Wang Chen wrote:
>> Patrick McHardy said the following on 2008-6-20 17:47:
>>> Wang Chen wrote:
>>>> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
>>>> index 5d055c2..1f2669b 100644
>>>> --- a/net/8021q/vlan_dev.c
>>>> +++ b/net/8021q/vlan_dev.c
>>>> @@ -547,12 +547,23 @@ static int vlan_dev_open(struct net_device *dev)
>>>>      }
>>>>      memcpy(vlan->real_dev_addr, real_dev->dev_addr, ETH_ALEN);
>>>>  
>>>> -    if (dev->flags & IFF_ALLMULTI)
>>>> -        dev_set_allmulti(real_dev, 1);
>>>> -    if (dev->flags & IFF_PROMISC)
>>>> -        dev_set_promiscuity(real_dev, 1);
>>>> +    if (dev->flags & IFF_ALLMULTI) {
>>>> +        err = dev_set_allmulti(real_dev, 1);
>>>> +        if (err < 0)
>>>> +            goto out;
>>>> +    }
>>>> +    if (dev->flags & IFF_PROMISC) {
>>>> +        err = dev_set_promiscuity(real_dev, 1);
>>>> +        if (err < 0)
>>>> +            goto out;
>>>> +    }
>>>>  
>>>>      return 0;
>>>> +
>>>> +out:
>>>> +    if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
>>>> +        dev_unicast_delete(real_dev, dev->dev_addr, dev->addr_len);
>>>> +    return err;
>>> This doesn't undo the operations that already succeeded.
>>>
>>
>> Why?
>> Should I do
>>      dev_mc_unsync(real_dev, dev);
>>     dev_unicast_unsync(real_dev, dev);
>> before dev_unicast_delete()?
> 
> When returning an error, the state shouldn't change at all,
> so you need to:
> 
> - remove unicast address if changed
> - restore old address in vlan->real_dev_addr
> - undo dev_set_allmulti
> 

Too much cleanup job!
Let me think, how about move dev_set_* ahead of memcpy().
Because unwinding dev_set_* is simpler than restoring
old real_dev_addr.

---
dev_set_promiscuity/allmulti might overflow.
Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
dev_set_promiscuity/allmulti return error number if overflow happened.

Here, we check all positive increment for promiscuity and allmulti
to get error return.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/8021q/vlan_dev.c |   27 +++++++++++++++++++++------
 1 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 5d055c2..083e0c8 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -543,16 +543,31 @@ static int vlan_dev_open(struct net_device *dev)
 	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr)) {
 		err = dev_unicast_add(real_dev, dev->dev_addr, ETH_ALEN);
 		if (err < 0)
-			return err;
+			goto out;
 	}
-	memcpy(vlan->real_dev_addr, real_dev->dev_addr, ETH_ALEN);
 
-	if (dev->flags & IFF_ALLMULTI)
-		dev_set_allmulti(real_dev, 1);
-	if (dev->flags & IFF_PROMISC)
-		dev_set_promiscuity(real_dev, 1);
+	if (dev->flags & IFF_ALLMULTI) {
+		err = dev_set_allmulti(real_dev, 1);
+		if (err < 0)
+			goto del_unicast;
+	}
+	if (dev->flags & IFF_PROMISC) {
+		err = dev_set_promiscuity(real_dev, 1);
+		if (err < 0)
+			goto clear_allmulti;
+	}
 
+	memcpy(vlan->real_dev_addr, real_dev->dev_addr, ETH_ALEN);
 	return 0;
+
+clear_allmulti:
+	if (dev->flags & IFF_ALLMULTI)
+		dev_set_allmulti(real_dev, -1);
+del_unicast:
+	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
+		dev_unicast_delete(real_dev, dev->dev_addr, ETH_ALEN);
+out:
+	return err;
 }
 
 static int vlan_dev_stop(struct net_device *dev)
-- 
1.5.3.4


