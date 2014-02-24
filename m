From: Qin Chuanyu <qinchuanyu@huawei.com>
Subject: Re: [PATCH] bridge: orphan frags on local receive
Date: Mon, 24 Feb 2014 22:31:17 +0800
Message-ID: <530B57B5.8010708@huawei.com>
References: <530B4534.3000106@huawei.com> <20140224132926.GF8981@redhat.com> <530B4E8B.5050007@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, KVM list <kvm@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:60631 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163AbaBXObj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 09:31:39 -0500
In-Reply-To: <530B4E8B.5050007@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/24 21:52, Qin Chuanyu wrote:
> On 2014/2/24 21:29, Michael S. Tsirkin wrote:
>> On Mon, Feb 24, 2014 at 09:12:20PM +0800, Qin Chuanyu wrote:
>>> with vhost tx zero_copy, guest nic might get hang when host reserving
>>> skb in socket queue delivered by guest, the case has been solved in
>>> tun, it also been needed by bridge. This could easily happened when a
>>> LAST_ACK state tcp occuring between guest and host.
>>>
>>> Signed-off-by: Chuanyu Qin <qinchuanyu@huawei.com>
>>
>> Do you actually observe guest hang?
>>
> yes, guest nic could not xmit any more until the skb holded by host has
> been freed, the mainly reason is that though virtio-net could use vring
> desc out of order, but ubufs is been used by vhost in order. so only
> one skb could cause guest nic hang.
>> I would expect orphan frags in
>> __netif_receive_skb_core to be enough.
>>
> yes, it would be better. I would deliver another patch soon.
>>
After thinking for a while, I think that orphan frags could only been
involved in virtual nic receive path, because after
__netif_receive_skb_core, skb would been transmitted by physic nic, in
this way orphan frags is unnecessary.
>>> ---
>>>   net/bridge/br_input.c |    3 +++
>>>   1 files changed, 3 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
>>> index 28d5446..744e27a 100644
>>> --- a/net/bridge/br_input.c
>>> +++ b/net/bridge/br_input.c
>>> @@ -117,6 +117,8 @@ int br_handle_frame_finish(struct sk_buff *skb)
>>>           br->dev->stats.multicast++;
>>>       } else if ((dst = __br_fdb_get(br, dest, vid)) &&
>>>               dst->is_local) {
>>> +        if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
>>> +            goto drop;
>>>           skb2 = skb;
>>>           /* Do not forward the packet since it's local. */
>>>           skb = NULL;
>>> @@ -136,6 +138,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
>>>   out:
>>>       return 0;
>>>   drop:
>>> +    skb_tx_error(skb);
>>>       kfree_skb(skb);
>>>       goto out;
>>>   }
>>> --
>>> 1.7.3.1.msysgit.0
>>
>>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
