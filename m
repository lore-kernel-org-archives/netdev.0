From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware forwarded
 packets
Date: Fri, 20 Mar 2015 14:20:54 -0700
Message-ID: <550C8F36.9030800@cumulusnetworks.com>
References: <1426870714-3225-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bCXTB0eZdyT9+a2FbJvy4K7QHpRzR4WvRGMryE-QZN8zQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	Netdev <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34715 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbbCTVUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 17:20:55 -0400
Received: by pacwe9 with SMTP id we9so120366602pac.1
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 14:20:55 -0700 (PDT)
In-Reply-To: <CAE4R7bCXTB0eZdyT9+a2FbJvy4K7QHpRzR4WvRGMryE-QZN8zQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/20/15, 11:03 AM, Scott Feldman wrote:
> On Fri, Mar 20, 2015 at 9:58 AM,  <roopa@cumulusnetworks.com> wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> On a Linux bridge with bridge forwarding offloaded to switch ASIC,
>> there is a need to not re-forward frames that have already been
>> forwarded in hardware.
>>
>> Typically these are broadcast or multicast frames forwarded by the
>> hardware to multiple destination ports including sending a copy of
>> the packet to the cpu (kernel e.g. an arp broadcast).
>> The bridge driver will try to forward the packet again, resulting in
>> two copies of the same packet.
>>
>> These packets can also come up to the kernel for logging when they hit
>> a LOG acl rule in hardware. In such cases, you do want the packet
>> to go through the bridge netfilter hooks. Hence, this patch adds the
>> required checks just before the packet is being xmited.
>>
>> v2:
>>          - Add a new hw_fwded flag in skbuff to indicate that the packet
>>          is already hardware forwarded. Switch driver will set this flag.
>>          I have been trying to avoid having this flag in the skb
>>          and thats why this patch has been in my tree for long. Cant think
>>          of other better alternatives. Suggestions are welcome. I have put
>>          this under CONFIG_NET_SWITCHDEV to minimize the impact.
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
>> ---
>>   include/linux/skbuff.h  |    7 +++++--
>>   net/bridge/br_forward.c |   11 +++++++++++
>>   2 files changed, 16 insertions(+), 2 deletions(-)
>>
>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> index bba1330..1973b5c 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -560,8 +560,11 @@ struct sk_buff {
>>                                  fclone:2,
>>                                  peeked:1,
>>                                  head_frag:1,
>> -                               xmit_more:1;
>> -       /* one bit hole */
>> +                               xmit_more:1,
>> +#ifdef CONFIG_NET_SWITCHDEV
>> +                               hw_fwded:1;
>> +#endif
>> +       /* one bit hole if CONFIG_NET_SWITCHDEV not defined */
> Did you want this flag not copied in __copy_skb_header()?  Seems those
> flags are special cased.  There is room for a bit here:
>
> #ifdef CONFIG_IPV6_NDISC_NODETYPE
>          __u8                    ndisc_nodetype:2;
> #endif
>          __u8                    ipvs_property:1;
>          __u8                    inner_protocol_type:1;
>          __u8                    remcsum_offload:1;
>          /* 3 or 5 bit hole */
>           <<<<<<<<

thx, yes I can add it here.
(I found the first 1 bit hole and added it there).
>
>>          kmemcheck_bitfield_end(flags1);
>>
>>          /* fields enclosed in headers_start/headers_end are copied
>> diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
>> index 3304a54..b60b96e 100644
>> --- a/net/bridge/br_forward.c
>> +++ b/net/bridge/br_forward.c
>> @@ -37,6 +37,17 @@ static inline int should_deliver(const struct net_bridge_port *p,
>>
>>   int br_dev_queue_push_xmit(struct sk_buff *skb)
>>   {
>> +
>> +#ifdef CONFIG_NET_SWITCHDEV
>> +       /* If skb is already hw forwarded and the port being forwarded
>> +        * to is a switch port, dont reforward
>> +        */
>> +       if (skb->hw_fwded && (skb->dev->features & NETIF_F_HW_SWITCH_OFFLOAD)) {
> The  check for skb->dev->features & NETIF_F_HW_SWITCH_OFFLOAD is redundant.

The skb->dev is the device it is getting forwarded to. The hw_fwded flag 
was set by the
device that originated the skb. The NETIF_F_HW_SWITCH_OFFLOAD flag is 
required because
the device being forwarded to can be a non switch port.

thanks,
Roopa
