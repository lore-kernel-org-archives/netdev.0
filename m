From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH net-next 2/3] myri10ge: Add vlan rx for better GRO perf.
Date: Wed, 14 Nov 2012 10:43:40 -0500
Message-ID: <50A3BC2C.4000708@myri.com>
References: <50A3975B.7020608@myri.com> <1352904408.4497.11.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f174.google.com ([209.85.213.174]:63815 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754316Ab2KNPno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 10:43:44 -0500
Received: by mail-ye0-f174.google.com with SMTP id m12so94768yen.19
        for <netdev@vger.kernel.org>; Wed, 14 Nov 2012 07:43:43 -0800 (PST)
In-Reply-To: <1352904408.4497.11.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/12 09:46, Eric Dumazet wrote:
> On Wed, 2012-11-14 at 08:06 -0500, Andrew Gallatin wrote:
>>
>> Unlike LRO, GRO requires that vlan tags be removed before
>> aggregation can occur.  Since the myri10ge NIC does not support
>> hardware vlan tag offload, we must remove the tag in the driver
>> to achieve performance comparable to LRO for vlan tagged frames.
>>
>> Signed-off-by: Andrew Gallatin <gallatin@myri.com>
>> ---
>>    drivers/net/ethernet/myricom/myri10ge/myri10ge.c |   47
>> ++++++++++++++++++++++
>>    1 file changed, 47 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
>> b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
>> index a5ab2f2..b9b6dfd 100644
>> --- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
>> +++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
>> @@ -1264,6 +1264,48 @@ myri10ge_unmap_rx_page(struct pci_dev *pdev,
>>    	}
>>    }
>>
>> +/*
>> + * GRO does not support acceleration of tagged vlan frames, and
>> + * this NIC does not support vlan tag offload, so we must pop
>> + * the tag ourselves to be able to achieve GRO performance that
>> + * is comparable to LRO.
>> + */
>> +
>> +static inline void
>> +myri10ge_vlan_rx(struct net_device *dev, void *addr, struct sk_buff *skb)
>> +{
>> +	u8 *va;
>> +	struct vlan_ethhdr *veh;
>> +	struct ethhdr *eh;
>> +	struct skb_frag_struct *frag;
>> +	u16 proto;
>> +
>> +	va = addr;
>> +	va += MXGEFW_PAD;
>> +	veh = (struct vlan_ethhdr *) va;
>> +	if ((dev->features & (NETIF_F_HW_VLAN_RX | NETIF_F_GRO)) ==
>> +	    (NETIF_F_HW_VLAN_RX | NETIF_F_GRO) &&
>> +	    (veh->h_vlan_proto == ntohs(ETH_P_8021Q))) {
>> +		/* fixup csum if needed */
>> +		if (skb->ip_summed == CHECKSUM_COMPLETE)
>> +			skb->csum = csum_sub(skb->csum,
>> +					     csum_partial(va + ETH_HLEN,
>> +							  VLAN_HLEN, 0));
>> +		/* pop tag */
>> +		__vlan_hwaccel_put_tag(skb, ntohs(veh->h_vlan_TCI));
>> +		proto = veh->h_vlan_encapsulated_proto;
> I am not sure you need this @proto ?
>
>> +		memmove(va + VLAN_HLEN, va, ETH_HLEN);
>
> You could only memmove the mac addresses (2 * ETH_ALEN)
> To not touch the proto (and avoid possible aliasing problems)
>
>> +		va += VLAN_HLEN;
>> +		eh = (struct ethhdr *)va;
>> +		eh->h_proto = proto;
>
> and this should not be needed ?

Indeed, your suggestion works and is simpler and less risky.
Thank you for your help.

I also think that I am making a mistake by only popping the tag when
GRO is enabled.  My fear is that something will become confused when
skb->dev->features contains NETIF_F_HW_VLAN_RX, but the tag is not
decap'ed.  So I will remove the check for NETIF_F_GRO when popping
the vlan tag.

Thanks,

Drew
