From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next 1/4] macvlan: don't update the uc and vlan list
 for L2 forwarding offload
Date: Thu, 05 Jun 2014 07:12:24 -0700
Message-ID: <53907AC8.50607@intel.com>
References: <1401951028-9800-1-git-send-email-dingtianhong@huawei.com> <1401951028-9800-2-git-send-email-dingtianhong@huawei.com> <5390761A.5030808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>,
	Ding Tianhong <dingtianhong@huawei.com>, kaber@trash.net,
	davem@davemloft.net, edumazet@google.com, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4429 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750864AbaFEOMl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 10:12:41 -0400
In-Reply-To: <5390761A.5030808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/5/2014 6:52 AM, Vlad Yasevich wrote:
> On 06/05/2014 02:50 AM, Ding Tianhong wrote:
>> If lowerdev supports L2 forwarding offload, no need to set mac address
>> to uc list and vlan list, so also don't do that when the macvlan mac address
>> changes.
>>
>
> Are you sure about this?  How would the lower dev receive traffic
> destined to the new HW address if it is not in the device unicast filter
> list?

I don't think the offload path works as it is either though (need to
test). The issue is sync'ing with the lowerdev doesn't give the lowerdev
any information on which fwd_priv to set so the lowerdev sets the normal
path with the address. It won't "break" traffic just receive flows wont
use the direct hardware queues. This will be a bigger issue once we get
support for metering and hardware ACLs.

Agreed though, Ding how does this work? Looks like a step back to me. At
very least can we get the commit message to explain this a bit better.

.John

>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>   drivers/net/macvlan.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
>> index 453d55a..c3a54a6 100644
>> --- a/drivers/net/macvlan.c
>> +++ b/drivers/net/macvlan.c
>> @@ -515,7 +515,7 @@ static int macvlan_sync_address(struct net_device *dev, unsigned char *addr)
>>   	struct net_device *lowerdev = vlan->lowerdev;
>>   	int err;
>>
>> -	if (!(dev->flags & IFF_UP)) {
>> +	if (!(dev->flags & IFF_UP) || vlan->fwd_priv) {
>>   		/* Just copy in the new address */
>>   		ether_addr_copy(dev->dev_addr, addr);
>>   	} else {
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
