From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next v2 1/3] macvlan: don't update the uc and vlan
 list for L2 forwarding offload
Date: Fri, 06 Jun 2014 13:11:34 -0400
Message-ID: <5391F646.9090302@gmail.com>
References: <1401969663-4464-1-git-send-email-dingtianhong@huawei.com> <1401969663-4464-2-git-send-email-dingtianhong@huawei.com> <53908814.8080303@gmail.com> <53913974.3080006@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, John Fastabend <john.r.fastabend@intel.com>
To: Ding Tianhong <dingtianhong@huawei.com>, kaber@trash.net,
	davem@davemloft.net, edumazet@google.com, vyasevic@redhat.com,
	makita.toshiaki@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f41.google.com ([209.85.216.41]:55426 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751851AbaFFRLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 13:11:37 -0400
Received: by mail-qa0-f41.google.com with SMTP id dc16so4336885qab.28
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 10:11:37 -0700 (PDT)
In-Reply-To: <53913974.3080006@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/2014 11:45 PM, Ding Tianhong wrote:
> On 2014/6/5 23:09, Vlad Yasevich wrote:
>> On 06/05/2014 08:01 AM, Ding Tianhong wrote:
>>> If lowerdev supports L2 forwarding offload, no need to set mac address
>>> to uc list and vlan list, so also don't do that when the macvlan mac address
>>> changes.
>>
>> Same issue as in v1.  Please explain how this actually works, since the
>> new address never makes it to the hw.
>>
> 
> Hi, vlad:
> 
> The fwd only support 82599 nic, and when fwd_priv is true, this means the lowerdev support L2 forwarding offload, and will set the macvlan
> to the ixgbe_fwd_adapter->netdev, and then it is clear that the lowerdev could know that the the upper device is macvlan and could handle
> the skb to the upperdev.
> 
> If I miss something, please remind me, thanks.

You've just changed the mac address of the macvlan device, but the
address is not written to the card's RAR registers.
So what allows the card to receive the traffic and place it into the
queue in the first place?

I can see it possibly working if the card is in promiscuous mode.

Also, I think John is right in that if we simply do dev_uc_add()
to add the address to the card, we'll unmap the address from the vmdqs
and lose the acceleration.  This needs more thought.

-vlad

> 
> Ding
> 
>> -vlad
>>>
>>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>>> ---
>>>  drivers/net/macvlan.c | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
>>> index 453d55a..c3a54a6 100644
>>> --- a/drivers/net/macvlan.c
>>> +++ b/drivers/net/macvlan.c
>>> @@ -515,7 +515,7 @@ static int macvlan_sync_address(struct net_device *dev, unsigned char *addr)
>>>  	struct net_device *lowerdev = vlan->lowerdev;
>>>  	int err;
>>>  
>>> -	if (!(dev->flags & IFF_UP)) {
>>> +	if (!(dev->flags & IFF_UP) || vlan->fwd_priv) {
>>>  		/* Just copy in the new address */
>>>  		ether_addr_copy(dev->dev_addr, addr);
>>>  	} else {
>>>
>>
>>
>>
> 
> 
