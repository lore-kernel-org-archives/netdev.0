From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Mon, 29 Sep 2014 13:53:39 -0700
Message-ID: <CA+mtBx8r05=qs2J58LFq56762tFB7wF4Dsr3C5TC9w5qQP5jGw@mail.gmail.com>
References: <1411962607-27878-1-git-send-email-therbert@google.com>
	<CAJ3xEMi-TRXevenx87UM7JnKqRQQATW4MBjbz8JdnQE9gk3KZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin Shelar <pshelar@nicira.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:58373 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753950AbaI2Uxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 16:53:39 -0400
Received: by mail-ie0-f179.google.com with SMTP id tp5so16223834ieb.38
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 13:53:39 -0700 (PDT)
In-Reply-To: <CAJ3xEMi-TRXevenx87UM7JnKqRQQATW4MBjbz8JdnQE9gk3KZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2014 at 12:59 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Mon, Sep 29, 2014 at 6:50 AM, Tom Herbert <therbert@google.com> wrote:
>> Add ndo_gso_check which a device can define to indicate whether is
>> is capable of doing GSO on a packet. This funciton would be called from
>> the stack to determine whether software GSO is needed to be done.
>
> please, no...
>
> We should strive to have a model/architecture under which the driver
> can clearly advertize up something (bits, collection of bits,
> whatever) which the stack can run through some dec-sion making code
> and decide if to GSO yes/no, do it ala SW or ala HW. As life, this
> model need not be perfect and can be biased towards being
> simple/robust/conservative and developed incrementally.
>
Please make a specific proposal then.

> We certainly don't want each driver that support some sort of HW
> offloads for tunnels (today we have 4-5, tomorrow maybe 40...) to
> implement their super sophisticated/efficient "dig in a packet and
> tell myself if I can GSO/CSUM it or not" code, while repeating (expect
> many copy/paste bugs...) the other drivers' code.
>
I would encourage vendors to implement protocol agnostic, generic
mechanisms so that they don't need to dig into the packet.

> Saying that, while looking quickly on the fm10k driver during it's
> super fast upstream review cycle, I saw something which looked like
> yellow light, I drove one, but now I see it was very much a red one:
> the chain of calls:
>
> fm10k_xmit_frame_ring --> fm10k_tso -->
> fm10k_tx_encap_offload --> {fm10k_port_is_vxlan,  fm10k_port_is_nvgre}
>
> is pretty much live example to what you are describing here, right?
>
> L2 Drivers are not supposed to do such heavy duty lookups in packets
> with tons of code that can be generic.
>
> I would suggest as band aid to the current situation with non-VXLAN
> UDP offloads enabled upstream and few drivers that don't really
> support GSO/CSUM for udp tunnels which are not vxlan -- to have a
> VXLAN bit which tells to the stack "I can do HW GSO to VXLAN" and have
> the stack to enable HW GSO over these devices only to VXLAN. This
> would bring the upstream code into consistent/well-defined state, and
> we can take it from there.
>
> Or.
>
> SB another comment
>
>> A driver should populate this function if it advertises GSO types for
>> which there are combinations that it wouldn't be able to handle. For
>> instance a device that performs UDP tunneling might only implement
>> support for transparent Ethernet bridging type of inner packets
>> or might have limitations on lengths of inner headers.
>>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>> ---
>>  include/linux/netdevice.h | 12 +++++++++++-
>>  net/core/dev.c            |  2 +-
>>  2 files changed, 12 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 9f5d293..f8c2027 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -997,6 +997,12 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>>   *     Callback to use for xmit over the accelerated station. This
>>   *     is used in place of ndo_start_xmit on accelerated net
>>   *     devices.
>> + * bool        (*ndo_gso_check) (struct sk_buff *skb,
>> + *                       struct net_device *dev);
>> + *     Called by core transmit path to determine if device is capable of
>> + *     performing GSO on a packet. The device returns true if it is
>> + *     able to GSO the packet, false otherwise. If the return value is
>> + *     false the stack will do software GSO.
>>   */
>>  struct net_device_ops {
>>         int                     (*ndo_init)(struct net_device *dev);
>> @@ -1146,6 +1152,8 @@ struct net_device_ops {
>>                                                         struct net_device *dev,
>>                                                         void *priv);
>>         int                     (*ndo_get_lock_subclass)(struct net_device *dev);
>> +       bool                    (*ndo_gso_check) (struct sk_buff *skb,
>> +                                                 struct net_device *dev);
>>  };
>>
>>  /**
>> @@ -3536,10 +3544,12 @@ static inline bool skb_gso_ok(struct sk_buff *skb, netdev_features_t features)
>>                (!skb_has_frag_list(skb) || (features & NETIF_F_FRAGLIST));
>>  }
>>
>> -static inline bool netif_needs_gso(struct sk_buff *skb,
>> +static inline bool netif_needs_gso(struct net_device *dev, struct sk_buff *skb,
>>                                    netdev_features_t features)
>>  {
>>         return skb_is_gso(skb) && (!skb_gso_ok(skb, features) ||
>> +               (dev->netdev_ops->ndo_gso_check &&
>> +                !dev->netdev_ops->ndo_gso_check(skb, dev)) ||
>>                 unlikely((skb->ip_summed != CHECKSUM_PARTIAL) &&
>>                          (skb->ip_summed != CHECKSUM_UNNECESSARY)));
>>  }
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index e2ced01..8c2b9bb 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -2680,7 +2680,7 @@ struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device *dev)
>>         if (skb->encapsulation)
>>                 features &= dev->hw_enc_features;
>>
>> -       if (netif_needs_gso(skb, features)) {
>> +       if (netif_needs_gso(dev, skb, features)) {
>>                 struct sk_buff *segs;
>>
>>                 segs = skb_gso_segment(skb, features);
>
> unrelated fix? best to put in a different patch.
