From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 2/4] net: dev: don't set the same mac address
 for netdev
Date: Sat, 7 Jun 2014 13:53:13 +0800
Message-ID: <5392A8C9.4000703@huawei.com>
References: <1401951028-9800-1-git-send-email-dingtianhong@huawei.com> <1401951028-9800-3-git-send-email-dingtianhong@huawei.com> <539033BC.3000703@lab.ntt.co.jp> <53903D5A.7050702@huawei.com> <53907982.8030700@gmail.com> <53913B89.4020305@huawei.com> <5391CB7C.8060100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	<kaber@trash.net>, <davem@davemloft.net>, <edumazet@google.com>,
	<vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:12368 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbaFGFxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jun 2014 01:53:39 -0400
In-Reply-To: <5391CB7C.8060100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/6/6 22:09, Vlad Yasevich wrote:
> On 06/05/2014 11:54 PM, Ding Tianhong wrote:
>> On 2014/6/5 22:06, Vlad Yasevich wrote:
>>> On 06/05/2014 05:50 AM, Ding Tianhong wrote:
>>>> On 2014/6/5 17:09, Toshiaki Makita wrote:
>>>>> (2014/06/05 15:50), Ding Tianhong wrote:
>>>>>> Most of netdev just like bond, team, vlan will set the mac address
>>>>>> and propagate to the upperdev or lowerdev regardless the mac address
>>>>>> is  same or not, I could not find that the same mac address could
>>>>>> make affect, so add equal check when set mac address.
>>>>>>
>>>>>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>>>>>> ---
>>>>>>  net/core/dev.c | 2 ++
>>>>>>  1 file changed, 2 insertions(+)
>>>>>>
>>>>>> diff --git a/net/core/dev.c b/net/core/dev.c
>>>>>> index 5367bfb..4008a51 100644
>>>>>> --- a/net/core/dev.c
>>>>>> +++ b/net/core/dev.c
>>>>>> @@ -5570,6 +5570,8 @@ int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
>>>>>>  		return -EINVAL;
>>>>>>  	if (!netif_device_present(dev))
>>>>>>  		return -ENODEV;
>>>>>> +	if (ether_addr_equal_64bits(dev->dev_addr, sa->sa_data))
>>>>>> +		return 0;
>>>>>>  	err = ops->ndo_set_mac_address(dev, sa);
>>>>>>  	if (err)
>>>>>>  		return err;
>>>>>>
>>>>>
>>>>> Bridge uses addr_assign_type to check if bridge_id can be propageted by
>>>>> bridge ports. If user set mac address, and even if it is the same as
>>>>> current one, bridge uses the fact that the mac address is set by user.
>>>>>
>>>>
>>>> OK
>>>>
>>>>> Although I'm not aware of a driver that needs calling of
>>>>> ndo_set_mac_address() for the same mac address, this change looks a bit
>>>>> risky to me.
>>>>> (For example, old bridge code needed this call because it managed
>>>>> BR_SET_MAC_ADDR in bridge flags.)
>>>>>
>>>> Except the old bridge, I still don't think any other driver need to call ndo_set_mac_address()
>>>> for the same mac address, if the dev_set_mac_address() don't do anything for the same address,
>>>> I think some drivers should ignore the same mac address themselves just like bonding, macvlan, vlan and so on.
>>>>
>>>
>>> Ok so may be a check like:
>>>     /* If the address has already been set by user and it
>>>      * is the same as before, don't do anything.
>>>      */
>>>     if (dev->addr_assign_type == NET_ADDR_SET &&
>>>         ether_addr_equal_64bits(dev->dev_addr, sa->sa_data))
>>>             return 0;
>>>
>>> This way, if the device does it's own address management (like bridge),
>>> the user can still pin the mac address, but subsequent setting to the
>>> same value don't cause all sorts of propagation.
>>>
>>
>> Great solution for br, but I think it couldn't fix the problem in br2684_mac_addr() just like Toshiaki said, I am not
>> sure how many place in the kernel use like this.
>>
> 
> Sure it would.  The first time through, we always call
> ndo_set_mac_address(), so br2684_mac_addr() would get called.
> 
> The second time through, we check to see if the user is setting
> the same address and skip it if it's the same.  As far as br2684
> is concerned, the address is still the same and the flag is still
> set.
> 
> -vlad
> 

Yep, you are right, the NET_ADDR_SET could show that the dev has calling ndo_set_mac_addreee() once
and decide whether to set a same mac address again.

I will resend this patch, thanks for your advise.

Ding

>> Ding 
>>
>>> -vlad
>>>
>>>> Ding 
>>>>
>>>>> Thanks,
>>>>> Toshiaki Makita
>>>>>
>>>>
>>>>
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>>
>>>
>>> .
>>>
>>
>>
> 
> 
> .
> 
