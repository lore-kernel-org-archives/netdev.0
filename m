From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Tue, 22 Aug 2017 10:50:41 +0800
Message-ID: <64d451ae-9944-e978-5a05-54bb1a62aaad@redhat.com>
References: <20170819063854.27010-1-den@klaipeden.com>
 <5352c98a-fa48-fcf9-c062-9986a317a1b0@redhat.com>
 <CAF=yD-LZ4=WAYfUtY7xRWi50FRSkrcOa+b7uc46xRnC4sbDCzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Koichiro Den <den@klaipeden.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40646 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754049AbdHVCuy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 22:50:54 -0400
In-Reply-To: <CAF=yD-LZ4=WAYfUtY7xRWi50FRSkrcOa+b7uc46xRnC4sbDCzQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年08月21日 23:41, Willem de Bruijn wrote:
> On Mon, Aug 21, 2017 at 8:33 AM, Jason Wang <jasowang@redhat.com> wrote:
>>
>> On 2017年08月19日 14:38, Koichiro Den wrote:
>>> Facing the possible unbounded delay relying on freeing on xmit path,
>>> we also better to invoke and clear the upper layer zerocopy callback
>>> beforehand to keep them from waiting for unbounded duration in vain.
>>> For instance, this removes the possible deadlock in the case that the
>>> upper layer is a zerocopy-enabled vhost-net.
>>> This does not apply if napi_tx is enabled since it will be called in
>>> reasonale time.
>>>
>>> Signed-off-by: Koichiro Den <den@klaipeden.com>
>>> ---
>>>    drivers/net/virtio_net.c | 8 ++++++++
>>>    1 file changed, 8 insertions(+)
>>>
>>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>>> index 4302f313d9a7..f7deaa5b7b50 100644
>>> --- a/drivers/net/virtio_net.c
>>> +++ b/drivers/net/virtio_net.c
>>> @@ -1290,6 +1290,14 @@ static netdev_tx_t start_xmit(struct sk_buff *skb,
>>> struct net_device *dev)
>>>          /* Don't wait up for transmitted skbs to be freed. */
>>>          if (!use_napi) {
>>> +               if (skb_shinfo(skb)->tx_flags & SKBTX_DEV_ZEROCOPY) {
>>> +                       struct ubuf_info *uarg;
>>> +                       uarg = skb_shinfo(skb)->destructor_arg;
>>> +                       if (uarg->callback)
>>> +                           uarg->callback(uarg, true);
>>> +                       skb_shinfo(skb)->destructor_arg = NULL;
>>> +                       skb_shinfo(skb)->tx_flags &= ~SKBTX_DEV_ZEROCOPY;
>>> +               }
>>>                  skb_orphan(skb);
>>>                  nf_reset(skb);
>>>          }
>>
>>
>> Interesting, deadlock could be treated as a a radical case of the discussion
>> here https://patchwork.kernel.org/patch/3787671/.
>>
>> git grep tells more similar skb_orphan() cases. Do we need to change them
>> all (or part)?
> Most skb_orphan calls are not relevant to the issue of transmit delay.

Yes, but at least we should audit the ones in drivers/net.

>
>> Actually, we may meet similar issues at many other places (e.g netem).
> Netem is an interesting case. Because it is intended to mimic network
> delay, at least in the case where it calls skb_orphan, it may make
> sense to release all references, including calling skb_zcopy_clear.
>
> In general, zerocopy reverts to copy on all paths that may cause
> unbounded delay due to another process. Guarding against delay
> induced by the administrator is infeasible. It is always possible to
> just pause the nic. Netem is one instance of that, and not unbounded.

The problem is, admin may only delay the traffic in e.g one interface, 
but it actually delay or stall all traffic inside a VM.

>
>> Need
>> to consider a complete solution for this. Figuring out all places that could
>> delay a packet is a method.
> The issue described in the referenced patch seems like head of line
> blocking between two flows. If one flow delays zerocopy descriptor
> release from the vhost-net pool, it blocks all subsequent descriptors
> in that pool from being released, also delaying other flows that use
> the same descriptor pool. If the pool is empty, all transmission stopped.
>
> Reverting to copy tx when the pool reaches a low watermark, as the
> patch does, fixes this.

An issue of the referenced patch is that sndbuf could be smaller than 
low watermark.

> Perhaps the descriptor pool should also be
> revised to allow out of order completions. Then there is no need to
> copy zerocopy packets whenever they may experience delay.

Yes, but as replied in the referenced thread, windows driver may treat 
out of order completion as a bug.

>
> On the point of counting copy vs zerocopy: the new msg_zerocopy
> variant of ubuf_info has a field to record whether a deep copy was
> made. This can be used with vhost-net zerocopy, too.

Just to make sure I understand. It's still not clear to me how to reuse 
this for vhost-net, e.g zerocopy flag is in a union which is not used by 
vhost_net.

Thanks
