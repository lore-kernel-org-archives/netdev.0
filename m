From: jeffy <jeffy.chen@rock-chips.com>
Subject: Re: [Patch net] ipv6: only call ip6_route_dev_notify() once for NETDEV_UNREGISTER
Date: Wed, 21 Jun 2017 11:08:29 +0800
Message-ID: <5949E32D.3050507@rock-chips.com>
References: <1497984147-15011-1-git-send-email-xiyou.wangcong@gmail.com> <5949E17A.4020508@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsahern@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from regular1.263xmail.com ([211.150.99.141]:56881 "EHLO
        regular1.263xmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753176AbdFUDIj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 23:08:39 -0400
In-Reply-To: <5949E17A.4020508@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cong Wang,

oh, oops, i did misread.

also, Tested-by: Jeffy Chen <jeffy.chen@rock-chips.com>

On 06/21/2017 11:01 AM, jeffy wrote:
> Hi Cong Wang,
>
> i don't know much about net core, maybe i'm misreading the code...but
>
> On 06/21/2017 02:42 AM, Cong Wang wrote:
>> In commit 242d3a49a2a1 ("ipv6: reorder ip6_route_dev_notifier after
>> ipv6_dev_notf")
>> I assumed NETDEV_REGISTER and NETDEV_UNREGISTER are paired,
>> unfortunately, as reported by jeffy, netdev_wait_allrefs()
>> could rebroadcast NETDEV_UNREGISTER event until all refs are
>> gone.
>>
>> We have to add an additional check to avoid this corner case.
>> For netdev_wait_allrefs() dev->reg_state is NETREG_UNREGISTERED,
>> for dev_change_net_namespace(), dev->reg_state is
>> NETREG_REGISTERED. So check for dev->reg_state != NETREG_UNREGISTERED.
>
> i saw we are calling NETDEV_REGISTER in these cases:
> 1/ register_netdevice_notifier:
> the paired unregister would be:
> a) normal unregister: rollback_registered_many
> b) the error path:
> register_netdevice_notifier->rollback jump label
>
> 2/ register_netdevice:
> the paired unregister would both be rollback_registered_many for
> normal/error cases
>
> 3/ dev_change_net_namespace:
> the paired unregister is the one right before the register notify
>
> i think we are handling all register notifies, but only unregister
> notify from rollback_registered_many now?
>
you are checking for NETREG_UNREGISTERED, so only filter out the 
unregistered after rollback_registered_many, so that indeed covers all 
cases :)
>
>>
>> Fixes: 242d3a49a2a1 ("ipv6: reorder ip6_route_dev_notifier after
>> ipv6_dev_notf")
>> Reported-by: jeffy <jeffy.chen@rock-chips.com>
>> Cc: David Ahern <dsahern@gmail.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>>   net/ipv6/route.c | 6 +++++-
>>   1 file changed, 5 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
>> index 7cebd95..322bd62 100644
>> --- a/net/ipv6/route.c
>> +++ b/net/ipv6/route.c
>> @@ -3722,7 +3722,11 @@ static int ip6_route_dev_notify(struct
>> notifier_block *this,
>>           net->ipv6.ip6_blk_hole_entry->dst.dev = dev;
>>           net->ipv6.ip6_blk_hole_entry->rt6i_idev = in6_dev_get(dev);
>>   #endif
>> -     } else if (event == NETDEV_UNREGISTER) {
>> +     } else if (event == NETDEV_UNREGISTER &&
>> +            dev->reg_state != NETREG_UNREGISTERED) {
>> +        /* NETDEV_UNREGISTER could be fired for multiple times by
>> +         * netdev_wait_allrefs(). Make sure we only call this once.
>> +         */
>>           in6_dev_put(net->ipv6.ip6_null_entry->rt6i_idev);
>>   #ifdef CONFIG_IPV6_MULTIPLE_TABLES
>>           in6_dev_put(net->ipv6.ip6_prohibit_entry->rt6i_idev);
>>
>
