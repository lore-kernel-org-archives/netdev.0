From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next v2 RESEND 1/4] macvlan: support mac address changes
 when fwd_priv is enable
Date: Fri, 13 Jun 2014 11:10:35 +0800
Message-ID: <539A6BAB.9040009@huawei.com>
References: <1402127143-6456-1-git-send-email-dingtianhong@huawei.com> <1402127143-6456-2-git-send-email-dingtianhong@huawei.com> <5395E617.5080307@redhat.com> <53990628.9070202@huawei.com> <5399B837.3020000@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>
To: <vyasevic@redhat.com>, <kaber@trash.net>, <davem@davemloft.net>,
	<edumazet@google.com>, <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:40724 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750989AbaFMDLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 23:11:32 -0400
In-Reply-To: <5399B837.3020000@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/6/12 22:24, Vlad Yasevich wrote:
> On 06/11/2014 09:45 PM, Ding Tianhong wrote:
>> On 2014/6/10 0:51, Vlad Yasevich wrote:
>>> [.. CC John Fastabend <john.r.fastabend@intel.com> ]
>>>
>>> On 06/07/2014 03:45 AM, Ding Tianhong wrote:
>>>> If lowerdev supports L2 forwarding offload, the macvlan's hw address
>>>> will be set to the rar of the lowerdev and no need to set uc list,
>>>> and when the macvlan's hw address changes, the macvlan should remove
>>>> the old fwd and rebuild a new fwd for the macvlan.
>>>>
>>>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>>>> ---
>>>>  drivers/net/macvlan.c | 21 +++++++++++++++++++++
>>>>  1 file changed, 21 insertions(+)
>>>>
>>>> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
>>>> index 453d55a..67485ab 100644
>>>> --- a/drivers/net/macvlan.c
>>>> +++ b/drivers/net/macvlan.c
>>>> @@ -523,6 +523,27 @@ static int macvlan_sync_address(struct net_device *dev, unsigned char *addr)
>>>>  		if (macvlan_addr_busy(vlan->port, addr))
>>>>  			return -EBUSY;
>>>>  
>>>> +		if (vlan->fwd_priv) {
>>>> +			lowerdev->netdev_ops->ndo_dfwd_del_station(lowerdev,
>>>> +								   vlan->fwd_priv);
>>>> +			vlan->fwd_priv = NULL;
>>>> +			ether_addr_copy(dev->perm_addr, dev->dev_addr);
>>>> +			ether_addr_copy(dev->dev_addr, addr);
>>>> +			vlan->fwd_priv =
>>>> +			    lowerdev->netdev_ops->ndo_dfwd_add_station(lowerdev,
>>>> +								       dev);
>>>> +			/* If we get a NULL pointer back, or if we get an error
>>>> +			 * then we should restore the old mac address and fwd.
>>>> +			 */
>>>> +			if (IS_ERR_OR_NULL(vlan->fwd_priv)) {
>>>> +				ether_addr_copy(dev->dev_addr, dev->perm_addr);
>>>> +				vlan->fwd_priv =
>>>> +				    lowerdev->netdev_ops->ndo_dfwd_add_station(lowerdev,
>>>> +									       dev);
>>>> +				return -EINVAL;
>>>> +			}
>>>> +			return 0;
>>>> +		}
>>>
>>> Calling del_stations add_station causes all sorts of VMDQ/ring
>>> operations to happen...  Not sure if we can do that while we have a live
>>> macvlan/macvtap that is capable of transmitting data.
>>>
>>> Wouldn't it be sufficient to have a call to call to update with mac
>>> filter with the appropriate VMDQ.
>>>
>>> John, I defer to you here.  The above looks really heavy-weight and
>>> I am not sure if its correct.
>>>
>>> Thanks
>>> -vlad
>>
>> I have used two 82599 nic to test this problem, I modify the ixgbe drivers and set the  L2 forwarding offload default,
>> without this patch, when I change the macvlan mac address, the kernel oops, and if I apply this patch, the ixgbe could
>> work well with the maclvan, so I don't think this solution has problem.
> 
> Have you tried changing the address while at the same time
> transmitting data through the macvlan?
> 
> -vlad
> 

Yes, I tried, the lowerdev will be closed when calling ixgbe_fwd_del, then the transmitting was broken and about 1 second later,
the transmitting restored and start to work again.

64 bytes from 192.168.10.8: icmp_seq=14 ttl=64 time=0.109 ms
64 bytes from 192.168.10.8: icmp_seq=15 ttl=64 time=0.112 ms
ping: sendmsg: Network is down
64 bytes from 192.168.10.8: icmp_seq=17 ttl=64 time=1000 ms
64 bytes from 192.168.10.8: icmp_seq=18 ttl=64 time=0.147 ms

Ding

>>
>> Thanks
>> Ding
>>
>>>
>>>>  		if (!vlan->port->passthru) {
>>>>  			err = dev_uc_add(lowerdev, addr);
>>>>  			if (err)
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
