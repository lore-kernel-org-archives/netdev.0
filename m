From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [PATCH net 1/3] vlan: Fix tcp checksums offloads for Q-in-Q vlan.
Date: Fri, 19 May 2017 22:31:41 +0900
Message-ID: <77e89748-1bc2-d676-6d7a-720e947cde3d@gmail.com>
References: <1495114265-23368-1-git-send-email-vyasevic@redhat.com>
 <1495114265-23368-2-git-send-email-vyasevic@redhat.com>
 <7593b180-9355-2c14-6cd8-b1e4f47a0ae6@lab.ntt.co.jp>
 <95de0652-6d73-9885-875e-8c98d02bd419@redhat.com>
 <ec89c4d9-c6de-673a-2c7a-895804034857@lab.ntt.co.jp>
 <1eeb2dc0-5877-0834-76af-677f6ca6b5d9@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: mkubecek@suse.cz
To: vyasevic@redhat.com,
        Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
        Vladislav Yasevich <vyasevich@gmail.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35383 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753606AbdESNbo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 09:31:44 -0400
Received: by mail-pf0-f194.google.com with SMTP id u26so9604007pfd.2
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 06:31:44 -0700 (PDT)
In-Reply-To: <1eeb2dc0-5877-0834-76af-677f6ca6b5d9@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/05/19 (金) 18:53, Vlad Yasevich wrote:
> On 05/19/2017 04:16 AM, Toshiaki Makita wrote:
>> On 2017/05/19 16:09, Vlad Yasevich wrote:
>>> On 05/18/2017 10:13 PM, Toshiaki Makita wrote:
>>>> On 2017/05/18 22:31, Vladislav Yasevich wrote:
>>>>> It appears that since commit 8cb65d000, Q-in-Q vlans have been
>>>>> broken.  The series that commit is part of enabled TSO and checksum
>>>>> offloading on Q-in-Q vlans.  However, most HW we support can't handle
>>>>> it.  To work around the issue, the above commit added a function that
>>>>> turns off offloads on Q-in-Q devices, but it left the checksum offload.
>>>>> That will cause issues with most older devices that supprort very basic
>>>>> checksum offload capabilities as well as some newer devices (we've
>>>>> reproduced te problem with both be2net and bnx).
>>>>>
>>>>> To solve this for everyone, turn off checksum offloading feature
>>>>> by default when sending Q-in-Q traffic.  Devices that are proven to
>>>>> work can provided a corrected ndo_features_check implemetation.
>>>>>
>>>>> Fixes: 8cb65d000 ("net: Move check for multiple vlans to drivers")
>>>>> CC: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>>>>> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
>>>>> ---
>>>>>  include/linux/if_vlan.h | 1 -
>>>>>  1 file changed, 1 deletion(-)
>>>>>
>>>>> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
>>>>> index 8d5fcd6..ae537f0 100644
>>>>> --- a/include/linux/if_vlan.h
>>>>> +++ b/include/linux/if_vlan.h
>>>>> @@ -619,7 +619,6 @@ static inline netdev_features_t vlan_features_check(const struct sk_buff *skb,
>>>>>  						     NETIF_F_SG |
>>>>>  						     NETIF_F_HIGHDMA |
>>>>>  						     NETIF_F_FRAGLIST |
>>>>> -						     NETIF_F_HW_CSUM |
>>>>>  						     NETIF_F_HW_VLAN_CTAG_TX |
>>>>>  						     NETIF_F_HW_VLAN_STAG_TX);
>>>>>
>>>>
>>>> I guess HW_CSUM theoretically can handle Q-in-Q packets and the problem
>>>> is IP_CSUM and IPV6_CSUM.
>>>> So wouldn't it be better to leave HW_CSUM and drop IP_CSUM/IPV6_CSUM,
>>>> i.e. change intersection into bitwise AND?
>>>>
>>>
>>> It wasn't really a problem before accelerations got enabled on q-in-q
>>> vlans.
>>
>> Right for stacked vlan device.
>> But I think the check was there for packets from guests forwarded by
>> bridge to vlan device so it was a problem before 8cb65d000.
>
> Not really, since stacked vlans in guests wouldn't have accelerations on.
> Haven't really tried a new guest on old hosts.  It might be an issue there...

It's real. I'm now remembering that I came across a similar issue before 
introducing 8cb65d000. The situation was that bridge (vlan_filtering) 
adds a vlan tag to a frame which is already tagged by guests, or by a 
vlan device on the top of the bridge (Note that virtio and bridge have 
HW_CSUM in vlan_features). I addressed the problem in drivers side since 
all the IP/IPV6_CSUM drivers I encountered the issue on are able to 
notify devices of IP header offset. Now I checked be2net driver's code 
and realized it doesn't provide IP offset so it makes sense to drop 
IP/IPV6_CSUM by default. Anyway, kernels before 8cb65d000 have that 
problem, not only after 8cb65d000.

Toshiaki Makita
