From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net 1/3] vlan: Fix tcp checksums offloads for Q-in-Q vlan.
Date: Fri, 19 May 2017 05:53:19 -0400
Message-ID: <1eeb2dc0-5877-0834-76af-677f6ca6b5d9@redhat.com>
References: <1495114265-23368-1-git-send-email-vyasevic@redhat.com>
 <1495114265-23368-2-git-send-email-vyasevic@redhat.com>
 <7593b180-9355-2c14-6cd8-b1e4f47a0ae6@lab.ntt.co.jp>
 <95de0652-6d73-9885-875e-8c98d02bd419@redhat.com>
 <ec89c4d9-c6de-673a-2c7a-895804034857@lab.ntt.co.jp>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: mkubecek@suse.cz
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
        Vladislav Yasevich <vyasevich@gmail.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54006 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751861AbdESJxV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 May 2017 05:53:21 -0400
In-Reply-To: <ec89c4d9-c6de-673a-2c7a-895804034857@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2017 04:16 AM, Toshiaki Makita wrote:
> On 2017/05/19 16:09, Vlad Yasevich wrote:
>> On 05/18/2017 10:13 PM, Toshiaki Makita wrote:
>>> On 2017/05/18 22:31, Vladislav Yasevich wrote:
>>>> It appears that since commit 8cb65d000, Q-in-Q vlans have been
>>>> broken.  The series that commit is part of enabled TSO and checksum
>>>> offloading on Q-in-Q vlans.  However, most HW we support can't handle
>>>> it.  To work around the issue, the above commit added a function that
>>>> turns off offloads on Q-in-Q devices, but it left the checksum offload.
>>>> That will cause issues with most older devices that supprort very basic
>>>> checksum offload capabilities as well as some newer devices (we've
>>>> reproduced te problem with both be2net and bnx).
>>>>
>>>> To solve this for everyone, turn off checksum offloading feature
>>>> by default when sending Q-in-Q traffic.  Devices that are proven to
>>>> work can provided a corrected ndo_features_check implemetation.
>>>>
>>>> Fixes: 8cb65d000 ("net: Move check for multiple vlans to drivers")
>>>> CC: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>>>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>>>> ---
>>>>  include/linux/if_vlan.h | 1 -
>>>>  1 file changed, 1 deletion(-)
>>>>
>>>> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
>>>> index 8d5fcd6..ae537f0 100644
>>>> --- a/include/linux/if_vlan.h
>>>> +++ b/include/linux/if_vlan.h
>>>> @@ -619,7 +619,6 @@ static inline netdev_features_t vlan_features_check(const struct sk_buff *skb,
>>>>  						     NETIF_F_SG |
>>>>  						     NETIF_F_HIGHDMA |
>>>>  						     NETIF_F_FRAGLIST |
>>>> -						     NETIF_F_HW_CSUM |
>>>>  						     NETIF_F_HW_VLAN_CTAG_TX |
>>>>  						     NETIF_F_HW_VLAN_STAG_TX);
>>>>  
>>>
>>> I guess HW_CSUM theoretically can handle Q-in-Q packets and the problem
>>> is IP_CSUM and IPV6_CSUM.
>>> So wouldn't it be better to leave HW_CSUM and drop IP_CSUM/IPV6_CSUM,
>>> i.e. change intersection into bitwise AND?
>>>
>>
>> It wasn't really a problem before accelerations got enabled on q-in-q
>> vlans.
> 
> Right for stacked vlan device.
> But I think the check was there for packets from guests forwarded by
> bridge to vlan device so it was a problem before 8cb65d000.

Not really, since stacked vlans in guests wouldn't have accelerations on.
Haven't really tried a new guest on old hosts.  It might be an issue there...

> 
>>> The intersection was introduced in db115037bb57 ("net: fix checksum
>>> features handling in netif_skb_features()"), but I guess for this
>>> particular check the intersection was not needed.
>>>
>>
>> So, to put it another way, leave the intersection with HW_CSUM in the mask,
>> and then do:
>>
>>   return features & ~(NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
>>
>> This might work, but it assumes that everyone who announce HW_CSUM can
>> do q-in-q vlans.  It's been a bit of a pain tracking this down and I'd rather
>> fix it for everyone and let individual driver authors verify that Q-in-Q works
>> correctly with HW checksum.  However, I am willing to do the above if
>> that's what people want.
> 
> At least HW_CSUM in the check was introduced intentionally.
> https://www.spinics.net/lists/netdev/msg152016.html
> 
> And I think HW_CSUM should work with any packets.
> You know, include/linux/skbuff.h says
>>  *	NETIF_F_HW_CSUM	- The driver (or its device) is able to compute one
>>  *			  IP (one's complement) checksum for any combination
>>  *			  of protocols or protocol layering.
> 
> We should be able to safely enable it.
> 
> ...But you are so worried about layer2 protocol handling of HW_CSUM
> devices, I'm ok with disabling it for now.
> 

It's a concern after running across this issue.  Granted, the few devices
we've seen this bug on use IP/IPV6 checksum features.  I am hoping someone
else might weigh in here.

-vlad
